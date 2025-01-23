package bankinfo

import (
	"errors"
	pennydrop "fcs23pkg/apps/v2/bankinfo/pennyDrop"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"strings"
)

func PennyDropValidationStatus(pReqId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "PennyDropValidationStatus(+)")

	var lValidateBankAccountId, lLastInsertedFundAccountId, lPennyDropStatus, lPennyDropAccountStatus string

	lCoreString := `select Penny_Drop_Status,Penny_Drop_Acc_Status 
					from ekyc_bank eb , ekyc_request er 
					where Request_Uid = er.Uid 
					and eb.isPrimaryAcc = 'Y'
					and er.Uid = ? and er.isActive = 'Y'`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pReqId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr)
		return helpers.ErrReturn(lErr)
	}

	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lPennyDropStatus, &lPennyDropAccountStatus)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr)
			return helpers.ErrReturn(lErr)
		}

	}

	pDebug.Log(helpers.Details, lPennyDropStatus, "lPennyDropStatus")
	pDebug.Log(helpers.Details, lPennyDropAccountStatus, "lPennyDropAccountStatus")

	if !strings.EqualFold(lPennyDropStatus, "Completed") {

		lPDRefId, lClientPanNo, lErr := GetRefID(pReqId, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr)
			return helpers.ErrReturn(lErr)
		}
		lValidateBankAccountId, lLastInsertedFundAccountId, lErr = GetPDStatusId("NEWEKYC", lPDRefId, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr)
			return helpers.ErrReturn(lErr)
		}
		_, lErr = pennydrop.GetValidationStatus(pDebug, lLastInsertedFundAccountId, lValidateBankAccountId, lClientPanNo, lPDRefId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr)
			return helpers.ErrReturn(lErr)
		}

	}
	pDebug.Log(helpers.Statement, "PennyDropValidationStatus(-)")
	return nil
}

func GetPDStatusId(pAppName string, pPdRefId int, pDebug *helpers.HelperStruct) (string, string, error) {
	pDebug.Log(helpers.Statement, "getValidateId (+)")

	var lValidateId, lFundAccountId string

	pDebug.Log(helpers.Details, "AppName", pAppName)
	pDebug.Log(helpers.Details, "pPdRefId", pPdRefId)
	lCoreString := `select xvl.validate_Id ,  xvl.fundAccountId 
	from xx_contact_log xcl , xx_fundaccount_log xfl , xx_validatebankaccount_log xvl 
	where xcl.id = xfl.ContactId 
	and xfl.id = xvl.fundAccountId 
	and xvl.ReqJson <> ''
	and xcl.OriginalSysId = ?
	and xcl.OriginalSys = ?
	`
	lRows, lErr := ftdb.MariaEKYCPRD_GDB.Query(lCoreString, pPdRefId, pAppName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr)
		return lValidateId, lFundAccountId, lErr
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lValidateId, &lFundAccountId)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr)
				return lValidateId, lFundAccountId, lErr
			}

		}

	}
	pDebug.Log(helpers.Details, "lValidateId", lValidateId)
	pDebug.Log(helpers.Details, "lFundAccountId", lFundAccountId)

	pDebug.Log(helpers.Statement, "getValidateId (-)")
	return lValidateId, lFundAccountId, nil

}

func GetRefID(pReqId string, pDebug *helpers.HelperStruct) (int, string, error) {
	pDebug.Log(helpers.Statement, "GetRefID (+)")

	var lPdrefID int
	var lClientPanNo string

	lSqlString := `select nvl(PD_RefId,0),er.Pan
					from ekyc_bank eb , ekyc_request er 
					where Request_Uid = er.Uid 
					and er.Uid = ? and er.isActive = 'Y'`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lSqlString, pReqId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr)
		return lPdrefID, lClientPanNo, helpers.ErrReturn(lErr)
	}

	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lPdrefID, &lClientPanNo)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr)
			return lPdrefID, lClientPanNo, helpers.ErrReturn(lErr)
		}

	}
	if lPdrefID == 0 {
		return lPdrefID, "", helpers.ErrReturn(errors.New("PD Reference Id EMPTY"))
	}
	pDebug.Log(helpers.Statement, "GetRefID (-)")
	return lPdrefID, lClientPanNo, nil
}

// func GetValidationStatus(pLoggedBy string, pValidateId string, pLastInsertedFundId string, pReqId int, pDebug *helpers.HelperStruct) (pennydrop.ValidateStatusResp, error) {
// 	pDebug.Log(helpers.Statement, "GetValidationStatus+")

// 	var lValidationResp pennydrop.ValidateStatusResp

// 	var lHeaderArr []apiUtil.HeaderDetails
// 	var lHeader apiUtil.HeaderDetails

// 	lValidateBankAccountId, lErr := pennydrop.InsertValidationLog(pLastInsertedFundId, "", pLoggedBy)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "pennydrop.GetValidationStatus", "(PGVS01)", lErr.Error())
// 		return lValidationResp, helpers.ErrReturn(lErr)
// 	} else {
// 		lHeader.Key = "Content-Type"
// 		lHeader.Value = "application/json; charset=UTF-8"
// 		lHeaderArr = append(lHeaderArr, lHeader)
// 		lHeader.Key = "Authorization"
// 		lHeader.Value = tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "HeaderAuthoKey")
// 		lHeaderArr = append(lHeaderArr, lHeader)
// 		pDebug.Log(helpers.Details, "lHeader.Value: ", lHeader.Value)

// 		lURL := pennydrop.ValidateURL + pValidateId
// 		pDebug.Log(helpers.Details, "lURL: ", lURL)

// 		ValidationResp_Json_Str, lErr := apiUtil.Api_call(pDebug, lURL, "GET", "", lHeaderArr, "pennydrop.GetValidationStatus")
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "pennydrop.GetValidationStatus", "(PGVS02)", lErr.Error())
// 			return lValidationResp, helpers.ErrReturn(lErr)
// 		} else {
// 			pDebug.Log(helpers.Details, "Validation Api Response: ", ValidationResp_Json_Str)
// 			lErr := json.Unmarshal([]byte(ValidationResp_Json_Str), &lValidationResp)
// 			if lErr != nil {
// 				pDebug.Log(helpers.Elog, "pennydrop.GetValidationStatus", "(PGVS03)", lErr.Error())
// 				return lValidationResp, helpers.ErrReturn(lErr)
// 			} else {
// 				lErr := pennydrop.UpdateValidationLog2(lValidationResp, lValidateBankAccountId, ValidationResp_Json_Str, pLoggedBy)
// 				if lErr != nil {
// 					pDebug.Log(helpers.Elog, "pennydrop.GetValidationStatus", "(PGVS04)", lErr.Error())
// 					return lValidationResp, helpers.ErrReturn(lErr)
// 				} else {
// 					if lValidationResp.Status != "failed" && lValidationResp.Status != "" && lValidationResp.FundAccount.ID != "" {
// 						lErr := UptBankStatusInfo(lValidationResp, pReqId, pDebug)
// 						if lErr != nil {
// 							pDebug.Log(helpers.Elog, "pennydrop.UpdateValidationLog2", "(PUVL2_02)", lErr.Error())
// 							return lValidationResp, helpers.ErrReturn(lErr)
// 						}
// 						// } else {
// 						// 	return lValidationResp, helpers.ErrReturn(errors.New(" Error in getting Penny drop status"))
// 					}
// 				}
// 			}

// 		}
// 	}

// 	pDebug.Log(helpers.Statement, "GetValidationStatus-")
// 	return lValidationResp, nil

// }

// func UptBankStatusInfo(pResp pennydrop.ValidateStatusResp, pPdRefId int, pDebug *helpers.HelperStruct) error {
// 	pDebug.Log(helpers.Statement, "UptBankStatusInfo (+)")

// 	var lSubString string
// 	if pResp.Results.RegisteredName != "" {
// 		lSubString += "Name_As_Per_PennyDrop= '" + pResp.Results.RegisteredName + "',"
// 	}
// 	if pResp.Status != "" {
// 		lSubString += "Penny_Drop_Status='" + pResp.Status + "',"
// 	}
// 	if pResp.Results.AccountStatus != "" {
// 		lSubString += "Penny_Drop_Acc_Status='" + pResp.Results.AccountStatus + "',"
// 	}

// 	// if strings.ToLower(resp.Results.AccountStatus) != "active" {
// 	// 	lSubString += " Penny_Drop_Status='E',"
// 	// }
// 	lCoreString := `	UPDATE ekyc_bank
// 					SET ` + lSubString + `UpdatedDate=unix_timestamp(now())
// 		   			WHERE PD_RefId=?`
// 	_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString, pPdRefId)

// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "pennydrop.UptBankStatusInfo", "(PNBA2_02)", lErr.Error())
// 		return helpers.ErrReturn(lErr)
// 	} else {
// 		pDebug.Log(helpers.Details, "Updated successfully")
// 	}

// 	pDebug.Log(helpers.Statement, "UptBankStatusInfo (-)")
// 	// return insertedID, nil
// 	return nil
// }

// func UpdatePDStatusId(lReqUId, PenneyDropStatus, PenneyDropAccStatus, PennyDropName string, pDebug *helpers.HelperStruct) error {
// 	pDebug.Log(helpers.Statement, "UpdatePDStatusId (+)")

// 	pDebug.Log(helpers.Details, "PenneyDropStatus", PenneyDropStatus)
// 	pDebug.Log(helpers.Details, "PenneyDropAccStatus", PenneyDropAccStatus)
// 	pDebug.Log(helpers.Details, "PennyDropName", PennyDropName)

// 	// lReqUId, lErr := ekyccommon.GetRid(reqRowId)
// 	// if lErr != nil {
// 	// 	pDebug.Log(helpers.Elog, lErr)
// 	// 	return helpers.ErrReturn(lErr)
// 	// }
// 	pDebug.SetReference("lUId" + lReqUId)

// 	var lSubString string
// 	if PennyDropName != "" {
// 		lSubString += "Name_As_Per_PennyDrop= '" + PennyDropName + "',"
// 	}
// 	if PenneyDropStatus != "" {
// 		lSubString += "Penny_Drop='" + PenneyDropStatus + "',"
// 	}
// 	if PenneyDropAccStatus != "" {
// 		lSubString += "Penny_Drop_Status='" + PenneyDropAccStatus + "',"
// 	}

// 	// if strings.ToLower(PenneyDropAccStatus) != "active" {
// 	// 	lSubString += " Penny_Drop_Status='S',"
// 	// }
// 	lCoreString := `UPDATE ekyc_bank
// 	SET ` + lSubString + ` UpdatedDate=  unix_timestamp(now())
// 	WHERE Request_Uid = ?;	`

// 	_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString, lReqUId)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, lErr)
// 		return helpers.ErrReturn(lErr)
// 	}

// 	pDebug.Log(helpers.Statement, "UpdatePDStatusId (-)")
// 	return nil

// }
