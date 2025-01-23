package pennydrop

import (
	"encoding/json"
	"fcs23pkg/apps/v2/bankinfo/model"
	"fcs23pkg/apps/v2/tokenvalidation"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	bankinfo "fcs23pkg/integration/v2/bankInfo"
	"fmt"
	"strconv"
)

func CreateContact(pDebug *helpers.HelperStruct, pReqData model.BankDetails) (string, string, error) {
	// Log the entry point of the function
	pDebug.Log(helpers.Statement, "CreateContact (+)")
	//Declare variables to hold the resulting data and intermediate values
	var lContactResp model.CreateContactResp
	var lLastInsertedContactId string
	var lContactId string

	// Validate and generate token
	lClientID, lToken, lErr := tokenvalidation.GenerateToken(pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CreateContact:001: ", lErr.Error()) // Log error
		return lLastInsertedContactId, lContactId, helpers.ErrReturn(lErr)
	}
	// Declare a variable to hold the parsed request data
	var lContactRec model.CreateContactReqStruct
	lContactRec.ClientId = lClientID
	lContactRec.Token = lToken
	lContactRec.Name = pReqData.Name
	lContactRec.Email = pReqData.Email
	lContactRec.Phone = pReqData.Phone
	lContactRec.Reference_Id = pReqData.ClientId
	lContactRec.Source = "InstaKyc.PennyDrop.CreateContact"

	//Marshal the JSON body into the JSON format
	lJsonData, lErr := json.Marshal(lContactRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CreateContact:002: "+lErr.Error())
		return lLastInsertedContactId, lContactId, helpers.ErrReturn(lErr)
	} else {
		// Convert JSON data to string
		lReqJsonStr := string(lJsonData)

		//Insert the Request of CreateContact into the Log Table and get the last inserted contact Id
		lLastInsertedContactId, lErr = InsertContactLog(pDebug, lContactRec, lReqJsonStr, pReqData)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CreateContact:003: "+lErr.Error())
			return lLastInsertedContactId, lContactId, helpers.ErrReturn(lErr)
		}
		//Api Call Create the Contact and get the response
		lContactRespJsonStr, lErr := bankinfo.CCHandler(pDebug, lReqJsonStr, "pennydrop.CreateContact")
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CreateContact:004: "+lErr.Error())
			return lLastInsertedContactId, lContactId, helpers.ErrReturn(lErr)
		}
		//Unmarshal the JSON body into the ContactResponse
		lErr = json.Unmarshal([]byte(lContactRespJsonStr), &lContactResp)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CreateContact:005: "+lErr.Error())
			return lLastInsertedContactId, lContactId, helpers.ErrReturn(lErr)
		}
		//Update the Response of CreateContact into the Log Table
		lErr = UpdateContactLog(pDebug, lContactResp, lLastInsertedContactId, lContactRespJsonStr, pReqData.LoggedBy)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CreateContact:006: "+lErr.Error())
			return lLastInsertedContactId, lContactId, helpers.ErrReturn(lErr)
		}
		// Check if the contact is active
		if lContactResp.Data.Active {
			lContactId = lContactResp.Data.Id
		} else {
			return lLastInsertedContactId, lContactId, fmt.Errorf("%s", "Error in contact creation")
		}
	}
	// Log the successful completion of the function
	pDebug.Log(helpers.Statement, "CreateContact (-)")
	return lLastInsertedContactId, lContactId, nil

}

func InsertContactLog(pDebug *helpers.HelperStruct, pContactRec model.CreateContactReqStruct, pReqJson string, pBankInput model.BankDetails) (string, error) {
	pDebug.Log(helpers.Statement, "InsertContactLog (+)")

	var lContactId string

	lCoreString := `insert into xx_contact_log(ReqJson,ReferenceId,Name,Email,PhoneNo,OriginalSys, OriginalSysId, 
	CreatedBy,CreatedDate,updatedBy,updatedDate) 
	values(?,?,?,?,?,?,?,?,now(),?,now())`

	lInsertRes, err := ftdb.MariaEKYCPRD_GDB.Exec(lCoreString, pReqJson, pContactRec.Reference_Id, pContactRec.Name, pContactRec.Email, pContactRec.Phone,
		pBankInput.OriginalSys, pBankInput.OriginalSysId, pBankInput.LoggedBy, pBankInput.LoggedBy)

	if err != nil {
		pDebug.Log(helpers.Elog, "InsertContactLog:001: ", err.Error())
		return lContactId, err
	} else {
		lReturnId, _ := lInsertRes.LastInsertId()
		lContactId = strconv.FormatInt(lReturnId, 10)
		pDebug.Log(helpers.Statement, "inserted successfully")
	}

	pDebug.Log(helpers.Statement, "InsertContactLog (-)")
	return lContactId, nil
}

func UpdateContactLog(pDebug *helpers.HelperStruct, pContactRec model.CreateContactResp, pContactId string, pRespJson string, pLoggedBy string) error {
	pDebug.Log(helpers.Statement, "UpdateContactLog (+)")

	lCoreString := `update xx_contact_log set RespJson=?, ContactId=?, CreatedAt=?, updatedBy=?, updatedDate=now()
	                where id = ?`
	_, err := ftdb.MariaEKYCPRD_GDB.Exec(lCoreString, pRespJson, pContactRec.Data.Id, pContactRec.Data.Created_At, pLoggedBy, pContactId)
	if err != nil {
		pDebug.Log(helpers.Elog, "UpdateContactLog:001: ", err.Error())
		return err
	} else {
		pDebug.Log(helpers.Statement, "Updated successfully")
	}

	pDebug.Log(helpers.Statement, "UpdateContactLog (-)")
	return nil
}
