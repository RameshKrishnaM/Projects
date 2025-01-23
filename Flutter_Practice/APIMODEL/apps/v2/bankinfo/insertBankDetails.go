package bankinfo

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v2/bankinfo/model"
	"fcs23pkg/apps/v2/creditsmanage"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"
	"strings"
)

type BankStruct struct {
	Uid     string `json:"uid"`
	ACCNO   string `json:"accno"`
	IFSC    string `json:"ifsc"`
	MICR    string `json:"micr"`
	BANK    string `json:"bank"`
	BRANCH  string `json:"branch"`
	ADDRESS string `json:"address"`
	Account string `json:"account"`
	Acctype string `json:"acctype"`
}

type Reponse struct {
	Status string `json:"status"`
	ErrMsg string `json:"errmsg"`
}

func InsertBankDetails(w http.ResponseWriter, req *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)
	lDebug.Log(helpers.Statement, "InsertBankDetails (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "PUT,OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")
	(w).Header().Set("Content-Type", "application/json")

	if req.Method == "PUT" {
		var lBankInfo BankStruct
		var lResponse Reponse

		lResponse.Status = common.SuccessCode
		lBody, lErr := ioutil.ReadAll(req.Body)
		lDebug.Log(helpers.Details, "body", string(lBody))
		if lErr != nil {
			lDebug.Log(helpers.Elog, "IBD01"+lErr.Error())
			lResponse.Status = common.ErrorCode
			lResponse.ErrMsg = "Something Went Wrong Please try again later"
		} else {
			lErr = json.Unmarshal(lBody, &lBankInfo)
			lDebug.SetReference(lBankInfo.ACCNO)
			if lErr != nil {
				lResponse.Status = common.ErrorCode
				lDebug.Log(helpers.Elog, "IBD02"+lErr.Error())
				lResponse.ErrMsg = "Something Went Wrong Please try again later"
			} else {
				lMsg, lErr := BankInsertProcess(req, lBankInfo, lDebug)
				if lErr != nil && lMsg == "" {
					lResponse.Status = common.ErrorCode
					lDebug.Log(helpers.Elog, "IBD02"+lErr.Error())
					lResponse.ErrMsg = "Something Went Wrong Please try again later"
				} else if lErr == nil && lMsg != "" {
					lResponse.Status = common.ErrorCode
					lResponse.ErrMsg = lMsg
				} else {
					lResponse.Status = common.SuccessCode
					lResponse.ErrMsg = "Inserted SuccessFully"
				}
			}
		}
		lData, lErr := json.Marshal(lResponse)
		if lErr != nil {
			lResponse.Status = common.ErrorCode
			lDebug.Log(helpers.Elog, "IBD15"+lErr.Error())
			lResponse.ErrMsg = "Something Went Wrong Please try again later"
			return
		} else {
			fmt.Fprint(w, string(lData))
		}
		lDebug.Log(helpers.Details, "lResponse", lResponse)
		lDebug.Log(helpers.Statement, "InsertBankDetails (-)")
		lDebug.RemoveReference()
	}

}
func BankInsertProcess(pReq *http.Request, pBankInfo BankStruct, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "BankInsertProcess (+)")

	lSessionId, lRequestId, lErr := sessionid.GetOldSessionUID(pReq, pDebug, common.EKYCCookieName)
	pDebug.SetReference(lRequestId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "IBD04"+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	} else {

		lPDfixedCount, _ := strconv.Atoi(tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "PennyDropCount"))

		lPDtotalCount, lErr := PennydropDetailsCount(lRequestId, pDebug)
		PDtotalCount, _ := strconv.Atoi(lPDtotalCount)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "IBD05"+lErr.Error())
			return "", helpers.ErrReturn(lErr)
		} else {
			if PDtotalCount >= lPDfixedCount {
				pDebug.Log(helpers.Elog, "IBD06"+" Maximum Number of Account already added")
				return " Maximum Number of Account already added", nil
			} else {
				lPennyDetails, lErr := GetPDetails(lRequestId, lSessionId, pBankInfo, pDebug)
				if lErr != nil {
					pDebug.Log(helpers.Elog, "IBD07"+lErr.Error())
					return "", helpers.ErrReturn(lErr)
				} else {
					var lBankDetails model.BankDetails
					var lPennyDropResult model.PennyDropRespStruct
					var lErr error
					lBankDetails.ClientId = lPennyDetails.Pan
					lBankDetails.LoggedBy = lPennyDetails.Pan
					lBankDetails.Name = lPennyDetails.Name
					lBankDetails.Email = lPennyDetails.Email
					lBankDetails.Phone = lPennyDetails.Phone
					lBankDetails.IFSC = pBankInfo.IFSC
					lBankDetails.AccountNo = pBankInfo.ACCNO
					lBankDetails.BankName = pBankInfo.BANK
					// For Testing
					lBankDetails.OriginalSysId = lPennyDetails.Id
					lBankDetails.OriginalSys = "NEWEKYC"
					lFlag, lErr := AccountChecking(lRequestId, lBankDetails.AccountNo, lBankDetails.IFSC, pDebug)
					if lErr != nil {
						pDebug.Log(helpers.Elog, "IBD08"+lErr.Error())
						return "", helpers.ErrReturn(lErr)
					} else {
						pDebug.Log(helpers.Details, "lFlag", lFlag)
						if lFlag == "N" {
							pDebug.Log(helpers.Details, "Inside Flag Y")
							lPennyDropResult, lErr = PennyDropValidation(pDebug, lBankDetails)
							if lErr != nil {
								pDebug.Log(helpers.Elog, "IBD09"+lErr.Error())
								return "", helpers.ErrReturn(lErr)
							} else {
								if lPennyDropResult.Data.PennyDropStatus == "completed" || lPennyDropResult.Data.PennyDropStatus == "created" {
									pDebug.Log(helpers.Details, "Completed")

									//Add a Credit in Vendor Credit log ====================================

									creditsmanage.LogVendorCredit(pDebug, "RzrPayPDVndr", "RzrPayPDSrv", lRequestId)

									//========================================================================

									ActiveStatus := "Y"
									pBankInfo.ACCNO = strings.TrimSpace(pBankInfo.ACCNO)
									lErr := EkycBankInsert(lRequestId, lPennyDetails.Id, pBankInfo, ActiveStatus, lPennyDropResult, lSessionId, pDebug)
									if lErr != nil {
										pDebug.Log(helpers.Elog, "IBD10"+lErr.Error())
										return "", helpers.ErrReturn(lErr)
									} else {
										lErr := ActiveStatusUpdate(lRequestId, lBankDetails.AccountNo, lBankDetails.IFSC, pBankInfo.Acctype, lSessionId, pDebug)
										if lErr != nil {
											pDebug.Log(helpers.Elog, "IBD11"+lErr.Error())
											return "", helpers.ErrReturn(lErr)
										} else {
											lErr = sessionid.UpdateZohoCrmDeals(pDebug, pReq, common.BankVerified)
											if lErr != nil {
												pDebug.Log(helpers.Elog, "IBD12"+lErr.Error())
												return "", helpers.ErrReturn(lErr)
											}
										}
									}
								}
							}
						} else if lFlag == "Y" {
							pDebug.Log(helpers.Details, "Else Flag N")
							lErr := ActiveStatusUpdate(lRequestId, lBankDetails.AccountNo, lBankDetails.IFSC, pBankInfo.Acctype, lSessionId, pDebug)
							if lErr != nil {
								pDebug.Log(helpers.Elog, "IBD13"+lErr.Error())
								return "", helpers.ErrReturn(lErr)
							}
						}
						lFlag = ""
					}
				}
				lErr = router.StatusInsert(pDebug, lRequestId, lSessionId, "BankDetails")
				if lErr != nil {
					pDebug.Log(helpers.Elog, "IBD14"+lErr.Error())
					return "", helpers.ErrReturn(lErr)
				}
			}
		}
	}

	pDebug.Log(helpers.Statement, "BankInsertProcess (-)")
	return "", nil
}
func AccountChecking(pRequestId string, pAccountNo string, pIFSC string, pDebug *helpers.HelperStruct) (string, error) {
	var lflag string
	lCorestring := `select case when count(eb.Acc_Number) > 0 then 'Y' else 'N' end from ekyc_bank eb 
								where eb.Request_Uid =?
								and eb.Acc_Number = ?
								and eb.IFSC=?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId, pAccountNo, pIFSC)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "bACC001"+lErr.Error())
		return lflag, helpers.ErrReturn(errors.New("bACC001"))

	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lflag)
			pDebug.Log(helpers.Details, "lFlag", lflag)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "bACC002"+lErr.Error())
				return lflag, helpers.ErrReturn(errors.New("bACC002"))
			}
		}
	}
	return lflag, nil
}
func EkycBankInsert(pRequestId string, pPdRefId int, pBankInfo BankStruct, pActiveStatus string, pPennyDropResult model.PennyDropRespStruct, pSessionId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "EkycBankInsert +", pBankInfo.Acctype)
	var lErr error
	lAddress := pBankInfo.BANK + " - " + pBankInfo.BRANCH

	lCoreString := `insert into ekyc_bank (Request_Uid,Acc_Number,Acctype,IFSC,MICR,Bank_Name,Bank_Branch,Bank_Address,U_BankAddress,
		Penny_Drop_Status,Penny_Drop_Acc_Status,isPrimaryAcc,Name_As_Per_PennyDrop,Session_Id,Updated_Session_Id,
		CreatedDate,UpdatedDate,PD_RefId)values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,unix_timestamp(now()),unix_timestamp(now()),?)
		`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pRequestId, pBankInfo.ACCNO, pBankInfo.Acctype, pBankInfo.IFSC, pBankInfo.MICR, pBankInfo.BANK, pBankInfo.BRANCH, lAddress, lAddress, pPennyDropResult.Data.PennyDropStatus, pPennyDropResult.Data.AccountStatus, pActiveStatus, pPennyDropResult.Data.RegisterName, pSessionId, pSessionId, pPdRefId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "EBI001"+lErr.Error())
		return helpers.ErrReturn(errors.New("EBI001"))
	}
	pDebug.Log(helpers.Statement, "EkycBankInsert -")
	return nil
}

func PennydropDetailsCount(pRequestId string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Details, "PennydropDetailsCount +")
	var lErr error
	var lBankDetailCount string

	pDebug.Log(helpers.Details, "RequestId", pRequestId)

	lCoreString := `select nvl(count(*),0) from ekyc_bank eb where Request_Uid =?;`

	pDebug.Log(helpers.Details, "coreString", lCoreString)

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pRequestId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PDDC001"+lErr.Error())
		return "", helpers.ErrReturn(errors.New("PDDC001"))
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lBankDetailCount)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "PDDC002"+lErr.Error())
			return "", helpers.ErrReturn(errors.New("PDDC002"))
		}
	}

	pDebug.Log(helpers.Details, "PennydropDetailsCount -")
	return lBankDetailCount, nil
}

func ActiveStatusUpdate(pRequestId string, pACCNO string, pIFSC, pAcctype, pSessionId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Details, "ActiveStatusUpdate +")
	var lErr error
	pDebug.Log(helpers.Details, "ACCNO", pACCNO)
	pDebug.Log(helpers.Details, "RequestId", pRequestId)
	pDebug.Log(helpers.Details, "IFSC", pIFSC)
	lCoreString := `UPDATE ekyc_bank
	SET isPrimaryAcc = CASE
		WHEN Acc_Number = ? AND IFSC = ? THEN 'Y'
		ELSE 'N'
	  END,
	 Acctype = ? ,
	 Updated_Session_Id = ?
	WHERE Request_Uid = ?;`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pACCNO, pIFSC, pAcctype, pSessionId, pRequestId)
	pDebug.Log(helpers.Details, "coreString", lCoreString)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "ASU001"+lErr.Error())
		return helpers.ErrReturn(errors.New("ASU001"))
	}
	pDebug.Log(helpers.Details, "ActiveStatusUpdate -")
	return nil
}

type BankUpdateStruct struct {
	ACCNO   string `json:"accno"`
	IFSC    string `json:"ifsc"`
	MICR    string `json:"micr"`
	BANK    string `json:"bank"`
	BRANCH  string `json:"branch"`
	ADDRESS string `json:"address"`
	Acctype string `json:"acctype"`
}
type response struct {
	BankStruct BankUpdateStruct `json:"bankstruct"`
	Status     string           `json:"status"`
	ErrMsg     string           `json:"errmsg"`
}

func GetBankDetailsUpdate(w http.ResponseWriter, req *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)
	lDebug.Log(helpers.Statement, "GetBankDetailsUpdate (+)")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")

	if req.Method == "GET" {
		//var details staffList
		var lResponse response
		lResponse.Status = common.ErrorCode

		_, lUid, lErr := sessionid.GetOldSessionUID(req, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lResponse.Status = common.ErrorCode
			lDebug.Log(helpers.Elog, "bGBDU002"+lErr.Error())
			lResponse.ErrMsg = helpers.GetError_String("bGBDU002", lErr.Error())
		} else {

			lSessionId, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(req, lDebug, common.EKYCCookieName, lUid)
			if lErr != nil {
				lResponse.Status = common.ErrorCode
				lDebug.Log(helpers.Elog, "bGBDU002"+lErr.Error())
				lResponse.ErrMsg = helpers.GetError_String("bGBDU002", lErr.Error())
			}

			lCoreString := ` select nvl(eb.Acc_Number,"") ,nvl(eb.IFSC,"") ,nvl(eb.MICR,"") ,nvl(eb.Bank_Name,"") ,nvl(eb.Bank_Branch,"") ,nvl(eb.Bank_Address,""),nvl(eb.Acctype,"") 
				from ekyc_bank eb 
				where eb.Request_Uid =?
				and eb.isPrimaryAcc='Y' and   ( ? or Updated_Session_Id  = ?)`
			lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, lUid, lTestUserFlag, lSessionId)
			if lErr != nil {
				lResponse.Status = common.ErrorCode
				lDebug.Log(helpers.Elog, "bGBDU003"+lErr.Error())
				lResponse.ErrMsg = helpers.GetError_String("bGBDU003", lErr.Error())
			} else {
				lResponse.Status = common.SuccessCode
				defer lRows.Close()
				for lRows.Next() {
					lErr := lRows.Scan(&lResponse.BankStruct.ACCNO, &lResponse.BankStruct.IFSC, &lResponse.BankStruct.MICR, &lResponse.BankStruct.BANK, &lResponse.BankStruct.BRANCH, &lResponse.BankStruct.ADDRESS, &lResponse.BankStruct.Acctype)
					if lErr != nil {
						lResponse.Status = common.ErrorCode
						lDebug.Log(helpers.Elog, "bGBDU004"+lErr.Error())
						lResponse.ErrMsg = helpers.GetError_String("bGBDU004", lErr.Error())
					} else {
						lResponse.Status = common.SuccessCode
					}
				}

			}
		}

		lData, lErr := json.Marshal(lResponse)
		lDebug.Log(helpers.Details, "data--", lResponse)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "pGPU005"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("pGPU005", lErr.Error()))
		} else {
			fmt.Fprint(w, string(lData))
		}
		lDebug.Log(helpers.Statement, "GetBankDetailsUpdate (-)")
	}
}
