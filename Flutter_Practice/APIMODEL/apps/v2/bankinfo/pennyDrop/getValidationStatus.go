package pennydrop

import (
	"encoding/json"
	"fcs23pkg/apps/v2/bankinfo/model"
	"fcs23pkg/apps/v2/tokenvalidation"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	bankinfo "fcs23pkg/integration/v2/bankInfo"
)

/*
Purpose:
    This API used to Gives the Status for the Penny Drop Validation. It processes the incoming request, validates it,
    and responds the status on success or an error message on failure.

Response:
    On Success:
        - Get the status of Validation in Razorpay and retruns the status with the Response.

    On Error:
        - Returns an appropriate error message if any part of the process fails (e.g., parsing error, Check Status failure).

 Author: Ramesh Krishna M
 Date: 9-Nov-2024
*/

func GetValidationStatus(pDebug *helpers.HelperStruct, pLastInsertedFundId string, pValidateId string, pLoggedBy string, pReqId int) (model.ValidationResp, error) {
	// Log the entry point of the function
	pDebug.Log(helpers.Statement, "GetValidationStatus (+)")
	// Declare a variable to hold the parsed request data
	var lValidationStatusResp model.ValidationResp

	// Validate and generate token
	lClientID, lToken, lErr := tokenvalidation.GenerateToken(pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GetValidationStatus:001 ", lErr.Error()) // Log error
		return lValidationStatusResp, helpers.ErrReturn(lErr)
	}
	var lValidationStatusRec model.ValidateStatusReqStruct

	lValidationStatusRec.ClientId = lClientID
	lValidationStatusRec.Token = lToken
	lValidationStatusRec.ValidateId = pValidateId
	lValidationStatusRec.Source = "InstaKyc.PennyDrop.GetValidationStatus"

	// Marshal the validationRec struct into JSON format
	lJsonData, lErr := json.Marshal(lValidationStatusRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GetValidationStatus:002 "+lErr.Error())
		return lValidationStatusResp, helpers.ErrReturn(lErr)
	} else {
		// Convert JSON data to string
		lReqJsonStr := string(lJsonData)
		lValidateBankAccountId, lErr := InsertValidationLog(pDebug, pLastInsertedFundId, lReqJsonStr, pLoggedBy)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "GetValidationStatus:003 "+lErr.Error())
			return lValidationStatusResp, helpers.ErrReturn(lErr)
		}
		// Api Call to Validate the bank account and get the response
		lRespData, lErr := bankinfo.GVSHandler(pDebug, lReqJsonStr, "pBankData.Source")
		if lErr != nil {
			pDebug.Log(helpers.Elog, "GetValidationStatus:004 "+lErr.Error())
			return lValidationStatusResp, helpers.ErrReturn(lErr)
		}
		// Unmarshal the response JSON into the BankValidationResp struct
		lErr = json.Unmarshal([]byte(lRespData), &lValidationStatusResp)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "GetValidationStatus:005 "+lErr.Error())
			return lValidationStatusResp, helpers.ErrReturn(lErr)
		}
		// Update the fund account log with the response data
		lErr = UpdateValidationLog(pDebug, lValidationStatusResp, lValidateBankAccountId, lRespData, pLoggedBy)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "GetValidationStatus:006 "+lErr.Error())
			return lValidationStatusResp, helpers.ErrReturn(lErr)
		} else {
			if lValidationStatusResp.Data.Status != "failed" && lValidationStatusResp.Data.Status != "" && lValidationStatusResp.Data.Fund_Account.Id != "" {
				lErr := UptBankStatusInfo(lValidationStatusResp, pReqId, pDebug)
				if lErr != nil {
					pDebug.Log(helpers.Elog, "GetValidationStatus:007 ", lErr.Error())
					return lValidationStatusResp, helpers.ErrReturn(lErr)
				}
			}
		}
	}

	// Log the successful completion of the function
	pDebug.Log(helpers.Statement, "GetValidationStatus (-)")
	return lValidationStatusResp, nil
}

func UptBankStatusInfo(pResp model.ValidationResp, pPdRefId int, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "UptBankStatusInfo (+)")

	var lSubString string
	if pResp.Data.Results.Register_Name != "" {
		lSubString += "Name_As_Per_PennyDrop= '" + pResp.Data.Results.Register_Name + "',"
	}
	if pResp.Status != "" {
		lSubString += "Penny_Drop_Status='" + pResp.Status + "',"
	}
	if pResp.Data.Results.Account_Status != "" {
		lSubString += "Penny_Drop_Acc_Status='" + pResp.Data.Results.Account_Status + "',"
	}

	lCoreString := `	UPDATE ekyc_bank 
					SET ` + lSubString + `UpdatedDate=unix_timestamp(now())
		   			WHERE PD_RefId=?`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString, pPdRefId)

	if lErr != nil {
		pDebug.Log(helpers.Elog, "UptBankStatusInfo:001: ", lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		pDebug.Log(helpers.Details, "Updated successfully")
	}

	pDebug.Log(helpers.Statement, "UptBankStatusInfo (-)")
	return nil
}
