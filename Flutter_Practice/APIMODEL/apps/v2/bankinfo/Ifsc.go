package bankinfo

import (
	"encoding/json"
	"fcs23pkg/apps/v2/bankinfo/model"
	"fcs23pkg/apps/v2/tokenvalidation"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	bankinfo "fcs23pkg/integration/v2/bankInfo"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

// type IfscCode struct {
// 	MICR    string `json:"micr"`
// 	BRANCH  string `json:"branch"`
// 	ADDRESS string `json:"address"`
// 	STATE   string `json:"state"`
// 	BANK    string `json:"bank"`
// 	Status  string `json:"status"`
// 	Success string `json:"success"`
// 	ErrMsg  string `json:"errmsg"`
// }

type IfscStruct struct {
	IFSCCode string `json:"ifsccode"`
}

// -----------------------------------------------------
// function exposed as api to get Bank details of the given ifsc Code.
// Returns the ifsc details in json format.
// -----------------------------------------------------
func GetIFSCdetails(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetIFSCdetails (+)")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "PUT,OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")
	(w).Header().Set("Content-Type", "application/json")

	switch r.Method {
	case "PUT":
		var lResponse model.IfscData
		var lIfsc IfscStruct
		lResponse.Status = common.ErrorCode
		//Returns the clientId
		lBody, _ := ioutil.ReadAll(r.Body)
		lDebug.Log(helpers.Details, "lifsc--", string(lBody))
		// IFSCCode := string(body)
		lErr := json.Unmarshal(lBody, &lIfsc)
		lDebug.Log(helpers.Details, "lifsc--", lIfsc)
		lDebug.SetReference(lIfsc)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GID01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GID01", "Something went wrong. Please try again later."))
			return
		} else {
			IFSCCode := lIfsc.IFSCCode
			lDebug.Log(helpers.Details, "IFSCCode--", IFSCCode)
			IfscDetails, lErr := GetBankDetailsFromRazorpay(IFSCCode, lDebug)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "GID02"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("GID02", "Something went wrong. Please try again later."))
				return
			} else if IfscDetails.Status == common.ErrorCode || IfscDetails.Data.Status == common.ErrorCode {
				if IfscDetails.ErrMsg == "Not Found" {
					lResponse.Status = common.ErrorCode
					fmt.Fprint(w, helpers.GetError_String("Invalid IFSC", "Please enter the valid IFSC Code"))
					return
				}
				lResponse.Status = common.ErrorCode
				lDebug.Log(helpers.Elog, "GID03"+IfscDetails.ErrMsg)
				fmt.Fprint(w, helpers.GetError_String("GID02", "Something went wrong. Please try again later."))
				return
			} else {
				if IfscDetails.Data.BANK == "" {
					IfscDetails, lErr = getIFSCDetailsFromRBIDB(IFSCCode, lDebug)
					if lErr != nil {
						lDebug.Log(helpers.Elog, lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("GID03", "Something went wrong. Please try again later."))
						return
					} else {
						lResponse.Status = common.SuccessCode
					}
				} else {
					lResponse = IfscDetails.Data
					if IfscDetails.Data.MICR == "" {
						// lResponse.MICR, lErr = GetMICRDetails(lDebug, IFSCCode)
						// if lErr != nil {
						// 	lDebug.Log(helpers.Elog, lErr.Error())
						// 	fmt.Fprint(w, helpers.GetError_String("GID04", "Something went wrong. Please try again later."))
						// 	return
						// }
						lResponse.MICR = "NON MICR"
					}
					lResponse.Status = common.SuccessCode
				}
				lDebug.Log(helpers.Details, "lresponse--", lResponse)
			}
		}
		lData, lErr := json.Marshal(lResponse)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GID05", "Something went wrong. Please try again later."))
			return
		} else {
			fmt.Fprint(w, string(lData))
		}
	}
	lDebug.Log(helpers.Statement, "GetIFSCdetails (-)")
	lDebug.RemoveReference()

}

func getIFSCDetailsFromRBIDB(pIFSCCode string, pdebug *helpers.HelperStruct) (model.IfscResponseStruct, error) {
	pdebug.Log(helpers.Statement, "getIFSCDetailsFromRBIDB (+)")
	var lIfscDetails model.IfscResponseStruct
	pdebug.SetReference(pIFSCCode)

	lCoreString := `
			select nvl(bankName,"") ,nvl(branch,""), nvl(address,""), nvl(state,"") from bank_ifsc_master
			where ifsc = ?`
	lRows, lErr := ftdb.MariaEKYCPRD_GDB.Query(lCoreString, pIFSCCode)
	if lErr != nil {
		return lIfscDetails, helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lIfscDetails.Data.BANK, &lIfscDetails.Data.BRANCH, &lIfscDetails.Data.ADDRESS, &lIfscDetails.Data.STATE)
			if lErr != nil {
				return lIfscDetails, helpers.ErrReturn(lErr)
			}
		}
	}

	pdebug.Log(helpers.Details, "IfscDetails", lIfscDetails)
	pdebug.RemoveReference()
	pdebug.Log(helpers.Statement, "getIFSCDetailsFromRBIDB (-)")
	return lIfscDetails, nil
}

// -------------------------------------------------------------------------
// function fetch the bankdetails for the given ifsc code.
// ------------------------------------------------------------------------
func GetBankDetailsFromRazorpay(pIFSCCode string, pDebug *helpers.HelperStruct) (model.IfscResponseStruct, error) {
	pDebug.Log(helpers.Statement, "GetBankDetailsFromRazorpay (+)")
	pIFSCCode = strings.TrimSpace(pIFSCCode)

	// Declare a variable to hold the parsed request data
	var lUser model.IfscResponseStruct
	var lIfscReqRec model.IfscDataReqStruct

	// Validate and generate token
	lClientID, lToken, lErr := tokenvalidation.GenerateToken(pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "bank.GetBankDetailsFromRazorpay ", "(GBR01)", lErr.Error()) // Log error
		return lUser, helpers.ErrReturn(lErr)
	}

	lIfscReqRec.ClientId = lClientID
	lIfscReqRec.Token = lToken
	lIfscReqRec.IFSCCode = pIFSCCode
	lIfscReqRec.Source = "InstaKyc.IFSC.GetBankDetails"

	// Marshal the validationRec struct into JSON format
	lJsonData, lErr := json.Marshal(lIfscReqRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "bank.GetBankDetailsFromRazorpay ", "(GBR02)", lErr.Error()) // Log error
		return lUser, helpers.ErrReturn(lErr)
	} else {
		// Convert JSON data to string
		lReqJsonStr := string(lJsonData)

		lIfscRespData, lErr := bankinfo.GBDIHandler(pDebug, lReqJsonStr, "pReqData.Source")
		if lErr != nil {
			pDebug.Log(helpers.Elog, "bank.GetBankDetailsFromRazorpay ", "(GBR03)", lErr.Error())
			return lUser, helpers.ErrReturn(lErr)
		} else {
			lErr := json.Unmarshal([]byte(lIfscRespData), &lUser)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "bank.GetBankDetailsFromRazorpay ", "(GBR04)", lErr.Error())
				return lUser, helpers.ErrReturn(lErr)
			}
		}
		if lUser.Status == "S" {
			lUser.Data.ADDRESS = SpecialCharacterReplace(pDebug, lUser.Data.ADDRESS, "\"", "")
			lUser.Data.ADDRESS = SpecialCharacterReplace(pDebug, lUser.Data.ADDRESS, "'", "")
			lUser.Data.ADDRESS = SpecialCharacterReplace(pDebug, lUser.Data.ADDRESS, "&", " and ")
			lUser.Data.ADDRESS = SpecialCharacterReplace(pDebug, lUser.Data.ADDRESS, "#", "")
			lUser.Data.BANK = SpecialCharacterReplace(pDebug, lUser.Data.BANK, "&", "and")
			lUser.Data.BANK = SpecialCharacterReplace(pDebug, lUser.Data.BANK, "-", " ")
		}
	}
	pDebug.Log(helpers.Statement, "GetBankDetailsFromRazorpay (-)", lUser)
	return lUser, nil
}

func GetMICRDetails(pDebug *helpers.HelperStruct, pIfscCode string) (string, error) {
	pDebug.Log(helpers.Statement, "GetMICRDetails (+)")

	var lMicrNo string

	lCoreString := `SELECT NVL(MICR_Code, '') 
					FROM micr_master_list mml 
					WHERE IFSC_Code = ?
					AND isActive = 'Y' 
					AND NVL(MICR_Code, '') != ''
					order by UniqueId desc 
					limit 1  `

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pIfscCode)
	if lErr != nil {
		return lMicrNo, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lMicrNo)
		if lErr != nil {
			return lMicrNo, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "GetMICRDetails (-)")
	return lMicrNo, nil
}
func SpecialCharacterReplace(pDebug *helpers.HelperStruct, pVariable, pSpecialCharacter, pSubString string) string {
	pDebug.Log(helpers.Statement, SpecialCharacterReplace, "SpecialCharacterReplace (+)")

	pDebug.Log(helpers.Details, pVariable, "pVariable")
	pDebug.Log(helpers.Details, pSpecialCharacter, "pSpecialCharacter")
	pDebug.Log(helpers.Details, pSubString, "pSubString")

	lRemoveString := strings.ReplaceAll(pVariable, pSpecialCharacter, pSubString)

	pDebug.Log(helpers.Details, lRemoveString, "lRemoveString")

	pDebug.Log(helpers.Statement, SpecialCharacterReplace, "SpecialCharacterReplace (-)")
	return lRemoveString
}
