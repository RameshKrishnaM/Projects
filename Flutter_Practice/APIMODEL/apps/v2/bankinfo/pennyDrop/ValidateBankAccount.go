package pennydrop

import (
	"encoding/json"
	"fcs23pkg/apps/v2/bankinfo/model"
	"fcs23pkg/apps/v2/tokenvalidation"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	bankinfo "fcs23pkg/integration/v2/bankInfo"
	"fmt"
	"log"
	"strconv"
	"time"
)

/*
Purpose:
    This API used to Validates the Bank account for the Penny Drop Validation. It processes the incoming request, validates it,
    and responds the Validation Id on success or an error message on failure.

Response:
    On Success:
        - Validates the Bank Account in Razorpay and retruns the Fund Validation Id with the Response.

    On Error:
        - Returns an appropriate error message if any part of the process fails (e.g., parsing error, validation failure).

 Author: Ramesh Krishna M
 Date: 9-Nov-2024
*/

func ValidateBankAccount(pDebug *helpers.HelperStruct, pLoggedBy string, pFundAccountId string, pLastInsertedFundId string, pLastInsertedContactId string) (model.ValidationResp, string, error) {
	// Log the entry point of the function
	pDebug.Log(helpers.Statement, "ValidateBankAccount (+)")
	// Declare a variable to hold the parsed request data
	var lValidationRec model.ValidationReqStruct
	var lValidationResp model.ValidationResp
	var lIsCompleted string
	lClientID, lToken, lErr := tokenvalidation.GenerateToken(pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CreateContactRequest:001 ", lErr.Error()) // Log error
		return lValidationResp, lIsCompleted, helpers.ErrReturn(lErr)
	}
	lValidationRec.ClientId = lClientID
	lValidationRec.Token = lToken
	lValidationRec.LastInsertedContactId = pLastInsertedContactId
	lValidationRec.FundAccountId = pFundAccountId
	lValidationRec.Source = "InstaKyc.PennyDrop.ValidateBankAccount"
	// Marshal the validationRec struct into JSON format
	lJsonData, lErr := json.Marshal(lValidationRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CreateContactRequest:002 "+lErr.Error())
		return lValidationResp, lIsCompleted, helpers.ErrReturn(lErr)
	} else {
		// Convert JSON data to string
		lReqJsonStr := string(lJsonData)
		// Insert the BankValidationInput request and get the last inserted Bank Account ID
		lValidateBankAccountId, lErr := InsertValidationLog(pDebug, pLastInsertedFundId, lReqJsonStr, pLoggedBy)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CreateContactRequest:003 "+lErr.Error())
			return lValidationResp, lIsCompleted, helpers.ErrReturn(lErr)
		}
		// Api Call to Validate the bank account and get the response
		lValidationRespJsonStr, lErr := bankinfo.VBAHandler(pDebug, lReqJsonStr, "pennydrop.ValidateBankAccount")
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CreateContactRequest:004 "+lErr.Error())
			return lValidationResp, lIsCompleted, helpers.ErrReturn(lErr)
		} else {
			// Unmarshal the response JSON into the BankValidationResp struct
			lErr := json.Unmarshal([]byte(lValidationRespJsonStr), &lValidationResp)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CreateContactRequest:005 "+lErr.Error())
				return lValidationResp, lIsCompleted, helpers.ErrReturn(lErr)
			}
			// Update the fund account log with the response data
			lErr = UpdateValidationLog(pDebug, lValidationResp, lValidateBankAccountId, lValidationRespJsonStr, pLoggedBy)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CreateContactRequest:006 "+lErr.Error())
				return lValidationResp, lIsCompleted, helpers.ErrReturn(lErr)
			} else {
				if lValidationResp.Data.Status != "failed" {
					// Check if the the validation is completed
					lIsCompleted, lErr = ChkValidationCmpt(pDebug, lValidationResp.Data.Notes.Notes_Key_1)
					if lErr != nil {
						pDebug.Log(helpers.Elog, "CreateContactRequest:007 "+lErr.Error())
						return lValidationResp, lIsCompleted, helpers.ErrReturn(lErr)
					}
				} else {
					return lValidationResp, lIsCompleted, fmt.Errorf("%s", "Error in validation")
				}
			}
		}
	}
	// Log the successful completion of the function
	pDebug.Log(helpers.Statement, "ValidateBankAccount (-)")
	return lValidationResp, lIsCompleted, nil
}

func InsertValidationLog(pDebug *helpers.HelperStruct, pLastInsertedFundId string, pReqJsonStr string, pLoggedBy string) (string, error) {
	pDebug.Log(helpers.Statement, "InsertValidationLog (+)")
	var lValidateBankAccountId string

	lCoreString := `insert into xx_validateBankAccount_log(ReqJson,fundAccountId,CreatedBy,CreatedDate,updatedBy,updatedDate)
	values(?,?,?,now(),?,now())`

	lInsertRes, lErr := ftdb.MariaEKYCPRD_GDB.Exec(lCoreString, pReqJsonStr, pLastInsertedFundId, pLoggedBy, pLoggedBy)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "InsertValidationLog:001 ", lErr.Error())
		return lValidateBankAccountId, lErr
	} else {
		returnId, _ := lInsertRes.LastInsertId()
		lValidateBankAccountId = strconv.FormatInt(returnId, 10)
		pDebug.Log(helpers.Statement, "validateBankAccountId Id: ", lValidateBankAccountId)
		pDebug.Log(helpers.Statement, "inserted successfully")
	}

	pDebug.Log(helpers.Statement, "InsertValidationLog (-)")
	return lValidateBankAccountId, nil
}
func UpdateValidationLog(pDebug *helpers.HelperStruct, pValidateResp model.ValidationResp, pValidateBankAccountId string, pRespJson string, pLoggedBy string) error {
	pDebug.Log(helpers.Statement, "UpdateValidationLog (+)")
	coreString := `update xx_validateBankAccount_log set RespJson=?, status=?, Account_status=?, registered_name=?,
	 CreatedAt=?, validate_Id=?, utr=?, updatedBy=?, updatedDate=now()
	                where id = ?`

	_, err := ftdb.MariaEKYCPRD_GDB.Exec(coreString, pRespJson, pValidateResp.Data.Status, pValidateResp.Data.Results.Account_Status, pValidateResp.Data.Results.Register_Name,
		pValidateResp.Data.Created_At, pValidateResp.Data.Id, pValidateResp.Data.Utr, pLoggedBy, pValidateBankAccountId)

	if err != nil {
		pDebug.Log(helpers.Elog, "UpdateValidationLog:001 ", err.Error())
		return err
	} else {
		log.Println("Updated successfully")
	}
	pDebug.Log(helpers.Statement, "UpdateValidationLog (-)")
	return nil
}

func ChkValidationCmpt(pDebug *helpers.HelperStruct, pContactId string) (string, error) {
	pDebug.Log(helpers.Statement, "ChkValidationCmpt (+)")

	time.Sleep(5 * time.Second)
	lIsCompleted, err := checkStatusIsCompleted(pDebug, pContactId)
	if err != nil {
		pDebug.Log(helpers.Elog, "ChkValidationCmpt:001 ", err.Error())
		return lIsCompleted, err
	} else {
		if lIsCompleted == "N" {
			time.Sleep(5 * time.Second)
			isCompleted, err := checkStatusIsCompleted(pDebug, pContactId)
			if err != nil {
				pDebug.Log(helpers.Elog, "ChkValidationCmpt:002 ", err.Error())
				return isCompleted, err
			}
		}

	}
	pDebug.Log(helpers.Statement, "ChkValidationCmpt (-)")
	return lIsCompleted, nil
}

func checkStatusIsCompleted(pDebug *helpers.HelperStruct, pContactId string) (string, error) {
	pDebug.Log(helpers.Statement, "checkStatusIsCompleted (+)")
	var lIsCompleted string

	coreString := `
	select  (case when vl.status = 'completed' then 'Y' else 'N' end ) isCompleted 
	from xx_contact_log cl, xx_fundAccount_log fl, xx_validateBankAccount_log vl 
	where cl.id  = fl.ContactId 
	and fl.id = vl.fundAccountId 
	and cl.id = ?`

	rows, err := ftdb.MariaEKYCPRD_GDB.Query(coreString, pContactId)
	if err != nil {
		pDebug.Log(helpers.Elog, "checkStatusIsCompleted:001 ", err.Error())
		return lIsCompleted, err
	} else {
		defer rows.Close()
		for rows.Next() {
			err := rows.Scan(&lIsCompleted)

			if err != nil {
				pDebug.Log(helpers.Elog, "checkStatusIsCompleted:002 ", err.Error())
				return lIsCompleted, err
			}
		}

	}
	pDebug.Log(helpers.Statement, "checkStatusIsCompleted (-)")
	return lIsCompleted, nil
}
