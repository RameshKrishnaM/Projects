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
)

/*
Purpose:
    This API used to create Fund account for the Penny Drop Validation. It processes the incoming request, validates it,
    creates the Fund account, and responds the Fund Account Id on success or an error message on failure.

Response:
    On Success:
        - Creates Fund Account in Razorpay and retruns the Fund Account Id with the Response.

    On Error:
        - Returns an appropriate error message if any part of the process fails (e.g., parsing error, Fund account creation failure).

 Author: Ramesh Krishna M
 Date: 9-Nov-2024
*/

func CreateFundAccount(pDebug *helpers.HelperStruct, pLastInsertedContactId string, pContactId string, pBankDataReq model.BankDetails) (string, string, error) {
	// Log the entry point of the function
	pDebug.Log(helpers.Statement, "CreateFundAccount (+)")

	// Declare a variable to hold the parsed request data
	var lLastInsertedFundId string
	var lFundAccountId string
	var lFundRec model.FundAccountReqStruct
	var lFundResp model.CreateFundAccResp
	// Validate and generate token
	lClientID, lToken, lErr := tokenvalidation.GenerateToken(pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CreateFundAccount:001 ", lErr.Error()) // Log error
		return lLastInsertedFundId, lFundAccountId, helpers.ErrReturn(lErr)
	}
	lFundRec.ClientId = lClientID
	lFundRec.Token = lToken
	lFundRec.Contact_Id = pContactId
	lFundRec.BankData.Name = pBankDataReq.BankName
	lFundRec.BankData.IFSC = pBankDataReq.IFSC
	lFundRec.BankData.AccountNo = pBankDataReq.AccountNo
	lFundRec.Source = "InstaKyc.PennyDrop.CreateFund"

	// Marshal the fundRec struct into JSON format
	lJsonData, lErr := json.Marshal(lFundRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CreateFundAccount:002: "+lErr.Error())
		return lLastInsertedFundId, lFundAccountId, helpers.ErrReturn(lErr)
	}
	// Convert JSON data to string
	lReqJsonStr := string(lJsonData)

	// Insert the fund account log and get the last inserted fund ID
	lLastInsertedFundId, lErr = InsertFundAccountLog(pDebug, lFundRec, lReqJsonStr, pBankDataReq.LoggedBy, pLastInsertedContactId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CreateFundAccount:003: "+lErr.Error())
		return lLastInsertedFundId, lFundAccountId, helpers.ErrReturn(lErr)
	}

	// Api Call to create the fund account and get the response
	lRespData, lErr := bankinfo.CFAHandler(pDebug, lReqJsonStr, "pBankDataReq.Source")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CreateFundAccount004: "+lErr.Error())
		return lLastInsertedFundId, lFundAccountId, helpers.ErrReturn(lErr)
	}
	// Unmarshal the response JSON into the FundAccountResp struct
	lErr = json.Unmarshal([]byte(lRespData), &lFundResp)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CreateFundAccount005: "+lErr.Error())
		return lLastInsertedFundId, lFundAccountId, helpers.ErrReturn(lErr)
	}
	// Update the fund account log with the response data
	lErr = UpdateFundAccountLog(pDebug, lFundResp, lLastInsertedFundId, lRespData, pBankDataReq.LoggedBy)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CreateFundAccount006: "+lErr.Error())
		return lLastInsertedFundId, lFundAccountId, helpers.ErrReturn(lErr)
	}
	// Check if the fund account is active
	if lFundResp.Data.Active {
		lFundAccountId = lFundResp.Data.Id
	} else {
		return lLastInsertedFundId, lFundAccountId, fmt.Errorf("error in Api response")
	}

	// Log the successful completion of the function
	pDebug.Log(helpers.Statement, "CreateFundAccount (-)")
	return lLastInsertedFundId, lFundAccountId, nil
}

func InsertFundAccountLog(pDebug *helpers.HelperStruct, fundRec model.FundAccountReqStruct, reqJson string, LoggedBy string, LastInsertedContactId string) (string, error) {
	pDebug.Log(helpers.Statement, "InsertFundAccountLog (+)")
	var fundId string

	coreString := `insert into xx_fundAccount_log(ReqJson,ContactId,ifsc,accountNo,bankName,CreatedBy,CreatedDate,updatedBy,updatedDate)
	values(?,?,?,?,?,?,now(),?,now())`

	insertRes, err := ftdb.MariaEKYCPRD_GDB.Exec(coreString, reqJson, LastInsertedContactId, fundRec.BankData.IFSC, fundRec.BankData.AccountNo,
		fundRec.BankData.Name, LoggedBy, LoggedBy)

	if err != nil {
		pDebug.Log(helpers.Elog, "InsertFundAccountLog:001: ", err.Error())
		return fundId, err
	} else {
		returnId, _ := insertRes.LastInsertId()

		fundId = strconv.FormatInt(returnId, 10)

		log.Println("inserted successfully")

	}

	pDebug.Log(helpers.Statement, "InsertFundAccountLog (-)")
	return fundId, nil
}

func UpdateFundAccountLog(pDebug *helpers.HelperStruct, pFundRec model.CreateFundAccResp, pLastInsertedFundId string, pRespJson string, pLoggedBy string) error {
	pDebug.Log(helpers.Statement, "UpdateFundAccountLog (+)")
	// Prepare the fields to be updated
	coreString := `update xx_fundAccount_log set RespJson=?, fundAccountId=?, CreatedAt=?, updatedBy=?, updatedDate=now()
	                where id = ?`

	_, err := ftdb.MariaEKYCPRD_GDB.Exec(coreString, pRespJson, pFundRec.Data.Id, pFundRec.Data.Created_At, pLoggedBy, pLastInsertedFundId)
	if err != nil {
		pDebug.Log(helpers.Elog, "UpdateFundAccountLog:001: ", err.Error())
		return err
	} else {
		log.Println("Updated successfully")
	}

	pDebug.Log(helpers.Statement, "UpdateFundAccountLog (-)")
	return nil
}
