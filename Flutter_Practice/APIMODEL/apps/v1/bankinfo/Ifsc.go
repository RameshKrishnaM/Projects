package bankinfo

import (
	"encoding/json"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/util/apiUtil"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

type IfscCode struct {
	MICR    string `json:"micr"`
	BRANCH  string `json:"branch"`
	ADDRESS string `json:"address"`
	STATE   string `json:"state"`
	BANK    string `json:"bank"`
	Status  string `json:"status"`
	Success string `json:"success"`
	ErrMsg  string `json:"errmsg"`
}

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
		var lResponse IfscCode
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
			// get the bank details for given ifsc code.
			IfscDetails, lErr := GetBankDetailsFromRazorpay(IFSCCode, lDebug)
			if lErr != nil || IfscDetails.ErrMsg == "Not Found" {
				if lErr != nil {
					lDebug.Log(helpers.Elog, "GID02"+lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("GID02", "Something went wrong. Please try again later."))
					return
				} else {
					lResponse.Status = common.ErrorCode
					lResponse.ErrMsg = helpers.GetError_String("Invalid IFSC GID05", "Something went wrong. Please try again later.")
				}
			} else {
				if IfscDetails.BANK == "" {
					IfscDetails, lErr = getIFSCDetailsFromRBIDB(IFSCCode, lDebug)
					if lErr != nil {
						lDebug.Log(helpers.Elog, lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("GID03", "Something went wrong. Please try again later."))
						return
					} else {
						lResponse.Status = common.SuccessCode
					}
				}
				if IfscDetails.BANK != "" {
					lResponse = IfscDetails
					if IfscDetails.MICR == "" {
						lResponse.MICR, lErr = GetMICRDetails(lDebug, IFSCCode)
						if lErr != nil {
							lDebug.Log(helpers.Elog, lErr.Error())
							fmt.Fprint(w, helpers.GetError_String("GID04", "Something went wrong. Please try again later."))
							return
						}
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

func getIFSCDetailsFromRBIDB(pIFSCCode string, pdebug *helpers.HelperStruct) (IfscCode, error) {
	pdebug.Log(helpers.Statement, "getIFSCDetailsFromRBIDB (+)")
	var lIfscDetails IfscCode
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
			lErr := lRows.Scan(&lIfscDetails.BANK, &lIfscDetails.BRANCH, &lIfscDetails.ADDRESS, &lIfscDetails.STATE)
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
// function fetch the bankdeails for the given ifsc code.
// ------------------------------------------------------------------------
func GetBankDetailsFromRazorpay(pIFSCCode string, pDebug *helpers.HelperStruct) (IfscCode, error) {
	pDebug.Log(helpers.Statement, "GetBankDetailsFromRazorpay (+)")
	pIFSCCode = strings.TrimSpace(pIFSCCode)

	//var header apiUtil.HeaderDetails
	var lHeaderArr []apiUtil.HeaderDetails

	var lUser IfscCode
	lUrla := "https://ifsc.razorpay.com/" + pIFSCCode
	pDebug.Log(helpers.Details, "urla----", lUrla)

	lIfsc_Json_Str, lErr := apiUtil.Api_call(pDebug, lUrla, "GET", "", lHeaderArr, "bank.GetBankDetailsFromRazorpay")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "bank.GetBankDetailsFromRazorpay ", "(GBR01)", lErr.Error())
		return lUser, helpers.ErrReturn(lErr)
	} else {
		pDebug.Log(helpers.Details, "Ifsc Api Response: ", lIfsc_Json_Str)
		IfscStr := lIfsc_Json_Str[1 : len(lIfsc_Json_Str)-1]

		if IfscStr != "Not Found" {
			pDebug.Log(helpers.Details, "inside ifsc", IfscStr)

			lErr := json.Unmarshal([]byte(lIfsc_Json_Str), &lUser)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "bank.GetBankDetailsFromRazorpay ", "(GBR02)", lErr.Error())
				return lUser, helpers.ErrReturn(lErr)
			}
		} else {
			lUser.ErrMsg = IfscStr
			return lUser, nil
		}

	}
	lUser.ADDRESS = strings.ReplaceAll(lUser.ADDRESS, "\"", "")
	lUser.ADDRESS = strings.ReplaceAll(lUser.ADDRESS, "'", "")
	lUser.ADDRESS = strings.ReplaceAll(lUser.ADDRESS, "&", " and ")
	lUser.ADDRESS = strings.ReplaceAll(lUser.ADDRESS, "#", "")
	pDebug.Log(helpers.Statement, "GetBankDetailsFromRazorpay (-)")
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
