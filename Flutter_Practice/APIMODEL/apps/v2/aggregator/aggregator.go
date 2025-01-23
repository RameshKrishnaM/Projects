package aggregator

import (
	"encoding/json"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/apps/v2/tokenvalidation"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	accaggregator "fcs23pkg/integration/v2/accAggregator"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
	"time"
)

/*
Purpose:
    This method handles the consent request for the Consent Request API. It processes the incoming request, validates it,
    creates the consent request, and responds with either the final redirect encrypted URL on success or an error message on failure.

Response:
    On Success:
        - Handles consent request creation.
        - Calls the appropriate method to return the final redirect encrypted URL to the client.

    On Error:
        - Returns an appropriate error message if any part of the process fails (e.g., parsing error, consent creation failure).

 Author: Logeshkumar
 Date: 19-Jun-2024


 Updatedby : Logeshkumar P
 UpdateDate : 22 Nov 2024

 Description : Modify the api to connect request and resonse in  Onemoney service
*/
func AAConsentRequest(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "ConsentRequest (+)")
	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Allow-Methods", http.MethodPost)
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")
	var lRespUrlData ConsentUrlRespStruct
	if strings.EqualFold(r.Method, http.MethodPost) {
		defer r.Body.Close()
		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		lDebug.SetReference(lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "CR002", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("CR002", "something went wrong please try again later"))
			return
		}
		lReqData, lErr := CollectConsentRequest(lDebug, r)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "CR001: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("CR001", "something went wrong please try again later"))
			return
		}

		lRespUrlData, lErr = AAConsentUrlRequest(lDebug, lUid, lReqData)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "CR005: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("CR005", "something went wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "Respons ConsentRequest", lRespUrlData)

		if lRespUrlData.ErrCode != "" {
			lRespUrlData.Status = common.ErrorCode
		} else {
			lRespUrlData.Status = common.SuccessCode
		}

		lErr = AADataInsert(lDebug, lUid, lSid, lReqData, lRespUrlData.ConsentHandle, lRespUrlData.FipID, lRespUrlData.ErrCode, lRespUrlData.ErrMsg)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "CR006", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("CR006", "something went wrong please try again later"))
			return
		}
		lResponseUrlData, lErr := json.Marshal(lRespUrlData)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "CR007: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("CR007", "Something went wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "Response ConsentRequest: ", string(lResponseUrlData))
		fmt.Fprint(w, string(lResponseUrlData))
		lDebug.Log(helpers.Statement, "ConsentRequest (-)")
	}
}
func AAConsentUrlGenerate(pDebug *helpers.HelperStruct, pUid string, pReqData UserInfoReqStruct) (WebRedirectStruct, string, string, error) {
	pDebug.Log(helpers.Statement, "AAConsentUrlGenerate (+)")
	pDebug.Log(helpers.Details, "Request  AAConsentRequest", pReqData)
	var lUrlData WebRedirectStruct
	var lMobileNumber string
	var lFipID string
	if pReqData.AlterMobileNumber != "" && len(pReqData.AlterMobileNumber) == 10 {
		lMobileNumber = pReqData.AlterMobileNumber
	} else {
		lMobileNumber = pReqData.MobileNumber
	}

	lRespData, lErr := accaggregator.RequestConsentHandler(pDebug, pUid, lMobileNumber)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG001: "+lErr.Error())
		return lUrlData, lFipID, "", helpers.ErrReturn(lErr)
	}

	var lRespConsent ReqConsentRespStruct
	lErr = json.Unmarshal([]byte(lRespData), &lRespConsent)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG002: "+lErr.Error())
		return lUrlData, lFipID, "", helpers.ErrReturn(lErr)
	}
	lConsentHandleId := lRespConsent.Data.ConsentHandleId
	lFipArr, lErr := accaggregator.GetListFipID(pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG003: "+lErr.Error())
		return lUrlData, lFipID, lConsentHandleId, helpers.ErrReturn(lErr)
	}

	pFibNameUpper := strings.ToUpper(pReqData.BankName)
	pDebug.Log(helpers.Details, "lFipArr", lFipArr)
	if len(lFipArr) > 0 {
		for _, fip := range lFipArr {
			if strings.EqualFold(strings.ToUpper(fip.FIPName), pFibNameUpper) {
				lFipID = fip.FIPID
				break
			}
		}
	}

	lRespUrl, lErr := accaggregator.GetEncryptedUrlHandler(pDebug, lRespConsent.Data.ConsentHandleId, lFipID)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG05: "+lErr.Error())
		return lUrlData, lFipID, lConsentHandleId, helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal([]byte(lRespUrl), &lUrlData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG006: "+lErr.Error())
		return lUrlData, lFipID, lConsentHandleId, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "AAConsentUrlGenerate (-)")
	return lUrlData, lFipID, lConsentHandleId, nil
}

func AAConsentUrlRequest(pDebug *helpers.HelperStruct, pUid string, pReqData UserConsentReqStruct) (ConsentUrlRespStruct, error) {
	pDebug.Log(helpers.Statement, "AAConsentUrlGenerate (+)")
	pDebug.Log(helpers.Details, "Request  AAConsentRequest", pReqData)
	var lUrlData ConsentUrlRespStruct
	var lConsentReqData UserConsentReqStruct
	if pReqData.AlterMobileNumber != "" && len(pReqData.AlterMobileNumber) == 10 {
		lConsentReqData.AlterMobileNumber = pReqData.AlterMobileNumber
	}
	lConsentReqData.MobileNumber = pReqData.MobileNumber
	lConsentReqData.BankName = pReqData.BankName
	lCientID, lToken, lErr := tokenvalidation.GenerateToken(pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG001: "+lErr.Error())
		return lUrlData, helpers.ErrReturn(lErr)
	}
	lConsentReqData.ClientId = lCientID
	lConsentReqData.Token = lToken
	lConsentReqData.UID = pUid
	lConsentReqData.RedirectURL = tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "RedirectUrl")
	lConsentReqData.Source = tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "Source")

	lReqBody, lErr := json.Marshal(lConsentReqData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG002: "+lErr.Error())
		return lUrlData, helpers.ErrReturn(lErr)
	}
	lRespData, lErr := accaggregator.RequestConsentService(pDebug, string(lReqBody))
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG003: "+lErr.Error())
		return lUrlData, helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal([]byte(lRespData), &lUrlData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG006: "+lErr.Error())
		return lUrlData, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "AAConsentUrlGenerate (-)")
	return lUrlData, nil
}
func CollectConsentRequest(pDebug *helpers.HelperStruct, pRequest *http.Request) (UserConsentReqStruct, error) {
	// Log the entry point of the function
	pDebug.Log(helpers.Statement, "CollectRequest (+)")

	// Declare a variable to hold the parsed request data
	var lUerinfo UserConsentReqStruct

	// Step 1: Read the body of the incoming HTTP request
	lBody, lErr := ioutil.ReadAll(pRequest.Body)
	if lErr != nil {
		// Log the error if reading the body fails
		pDebug.Log(helpers.Elog, "CollectRequest:002 ", lErr.Error())
		// Return the empty structure and the error
		return lUerinfo, helpers.ErrReturn(lErr)
	}

	// Step 2: Unmarshal the JSON body into the UserInfoReqStruct
	lErr = json.Unmarshal(lBody, &lUerinfo)
	if lErr != nil {
		// Log the error if unmarshaling fails
		pDebug.Log(helpers.Elog, "CollectRequest:003 ", lErr.Error())
		// Return the empty structure and the error
		return lUerinfo, helpers.ErrReturn(lErr)
	}
	// Log the successful completion of the function
	pDebug.Log(helpers.Statement, "CollectRequest (-)")

	// Step 3: Return the parsed request data and nil for error
	return lUerinfo, nil
}

// ValidateIncludesLastThreeMonths validates that the date range includes the last Six months from the current date.

func (t *AATransactionsStruct) ValidateDateRange() (bool, error) {
	layout := "2006-01-02"
	lStartDate, lErr := time.Parse(layout, t.StartDate)
	if lErr != nil {
		return false, helpers.ErrReturn(lErr)
	}

	lEndDate, lErr := time.Parse(layout, t.EndDate)
	if lErr != nil {
		return false, helpers.ErrReturn(lErr)
	}
	ValidationDuration := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "SixMonth")
	MonthCondition := lStartDate.AddDate(0, 6, -1)
	if !strings.EqualFold(ValidationDuration, common.StatusYes) {
		lCurrentDate := time.Now()
		MonthCondition = lCurrentDate.AddDate(0, -3, 0)
	}

	if lEndDate.Before(MonthCondition) {
		return false, nil
	}
	return true, nil
}

func AAStatementVerify(pTransaction []AAJsonDataStruct) (bool, error) {
	for _, data := range pTransaction {
		lStatus, lErr := data.Transactions.ValidateDateRange()
		if lErr != nil {
			return lStatus, helpers.ErrReturn(lErr)
		} else {
			return lStatus, nil
		}
	}
	return true, nil
}
func FindConsentData(pConsentListData *ResponseConsentList, pConsentHandle string) string {
	var lConsentID string
	for _, lConsent := range pConsentListData.DataArr {
		if lConsent.ConsentHandle == pConsentHandle {
			lConsentID = lConsent.ConsentID
			return lConsentID
		} else if lConsent.ConsentID != "" {
			lConsentID = lConsent.ConsentID
		}
	}
	return lConsentID
}

func UserBankInfo(pDebug *helpers.HelperStruct, lJsonRespData AAJsonDataStruct, lstatementResp AAStatementRespStruct, pJsonDcoId, pPdfDocId string) AAUserBankInfoStruct {
	pDebug.Log(helpers.Statement, "UserBankInfo (+)")
	var lUserBankInsert AAUserBankInfoStruct
	lUserBankInsert.StatementStatus = common.StatusYes

	lHoldingType := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "HoldingType")

	lUserBankInsert.Bank = lJsonRespData.Bank
	lUserBankInsert.AccountType = lJsonRespData.Summary.Type
	lUserBankInsert.TransError = lstatementResp.ErrCode
	lUserBankInsert.TransErrorStatus = lstatementResp.ErrMsg
	lUserBankInsert.TransStartDate = lJsonRespData.Transactions.StartDate
	lUserBankInsert.TransEndDate = lJsonRespData.Transactions.EndDate
	lUserBankInsert.BankAccountStatus = lJsonRespData.Summary.Status
	lUserBankInsert.JsonDocID = pJsonDcoId
	lUserBankInsert.PdfDocID = pPdfDocId
	lUserBankInsert.LinkReferenceNumber = lJsonRespData.LinkReferenceNumber
	if lJsonRespData.Profile.Holders.Type != lHoldingType {
		for _, lHolder := range lJsonRespData.Profile.Holders.Holder {
			lUserBankInsert.UserName += lHolder.Name + ` | `
			lUserBankInsert.Address += lHolder.Address + ` | `
			lUserBankInsert.BankCkycStatus += lHolder.CkycCompliance + ` | `
			lUserBankInsert.DOB += lHolder.Dob + ` | `
			lUserBankInsert.Pan += lHolder.Pan + ` | `
			lUserBankInsert.Email += lHolder.Email + ` | `
			lUserBankInsert.MobileNumber += lHolder.Mobile + ` | `
		}
	} else {
		for _, lHolder := range lJsonRespData.Profile.Holders.Holder {
			lUserBankInsert.UserName += lHolder.Name
			lUserBankInsert.Address += lHolder.Address
			lUserBankInsert.BankCkycStatus += lHolder.CkycCompliance
			lUserBankInsert.DOB += lHolder.Dob
			lUserBankInsert.Pan += lHolder.Pan
			lUserBankInsert.Email += lHolder.Email
			lUserBankInsert.MobileNumber += lHolder.Mobile
		}
	}
	pDebug.Log(helpers.Statement, "UserBankInfo (-)")

	return lUserBankInsert
}
func AAGetJsonData(pMaskAccount string, pJsonRespData AAJsonResponseStruct) AAJsonDataStruct {
	var lResp AAJsonDataStruct
	if len(pJsonRespData.Data) == 0 {
		return lResp
	}

	for _, lbanks := range pJsonRespData.Data {
		if lbanks.MaskedAccountNumber == pMaskAccount {
			return lbanks
		}
	}

	// Check again if the Data slice is empty before accessing the first element
	return pJsonRespData.Data[0]
}
func AAGetDocIDData(pDebug *helpers.HelperStruct, pUid string) (AAValidationStruct, error) {
	pDebug.Log(helpers.Details, "AAGetDocIDData(+)")

	var lvalidate AAValidationStruct
	lCorestring := `SELECT 
    NVL(ea.Income_proof, '') AS Income_proof,
    NVL(ea.Income_prooftype, '') AS Income_prooftype,
    NVL(bankTable.AA_Consent_ID, '') AS AA_Consent_ID,
    NVL(bankTable.Consent_HandleID, '') AS Consent_HandleID 
FROM ekyc_attachments ea  
LEFT JOIN (
    SELECT 
        eba.AA_Consent_ID, 
        eba.Consent_HandleID, 
        eba.Request_Uid
    FROM 
        ekyc_bank_aa eba
    JOIN (
        SELECT 
            Request_Uid, 
            MAX(id) AS max_id
        FROM 
            ekyc_bank_aa
        WHERE 
            Request_Uid = ?
        GROUP BY 
            Request_Uid
    ) latest 
    ON 
        eba.id = latest.max_id
    WHERE 
        eba.Request_Uid = latest.Request_Uid
) AS bankTable ON ea.Request_id = bankTable.Request_Uid 
WHERE ea.Request_id = ?;`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pUid, pUid)
	if lErr != nil {
		return lvalidate, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lvalidate.DocID, &lvalidate.ProofType, &lvalidate.ConsentID, &lvalidate.ConsentHandleID)
		if lErr != nil {
			return lvalidate, helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Details, "AAGetDocIDData(-)")
	return lvalidate, nil
}

func AAGetUserData(pDebug *helpers.HelperStruct, pUid string) (string, string, error) {
	pDebug.Log(helpers.Details, "AAGetUserData(+)")

	var lPhoneNum, lBankName string
	lCorestring := `SELECT 
  CASE 
    WHEN eba.Alt_Phone_number != '' THEN eba.Alt_Phone_number 
    ELSE eba.Phone_Number 
  END AS PhoneNumber,
  eba.Bank_Name 
FROM ekyc_bank_aa eba 
JOIN (
  SELECT Request_Uid, MAX(id) AS max_id
  FROM ekyc_bank_aa 
  WHERE Request_Uid = ?
  GROUP BY Request_Uid
) AS latest 
ON eba.id = latest.max_id
WHERE eba.Request_Uid = latest.Request_Uid`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pUid)
	if lErr != nil {
		return "", "", helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lPhoneNum, &lBankName)
		if lErr != nil {
			return "", "", helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Details, "AAGetUserData(-)")
	return lPhoneNum, lBankName, nil
}

/*
AADataInsert inserts a new record into the `ekyc_bank_aa` table with the provided user information and consent details.
This function is utilized to log information related to a user's banking data request, including any error codes
and statuses, along with relevant session information.

Parameters:
- pDebug: A pointer to the `HelperStruct` used for logging details throughout the method execution.
- pUid: The unique identifier of the user making the request.
- pSid: The current session ID to track the update session.
- lUserInfo: A struct containing user information such as mobile numbers and bank name.
- pConsentHandle: The consent handle ID related to the user's request.
- pFipId: The Financial Information Provider ID associated with the request.
- pErrCode: The error code, if any, generated during the request process.
- pErrStatus: The error status message, if any, generated during the request process.
- pProvider: The service provider associated with the user's banking data.

Returns:
- An error if the database insertion fails, or `nil` if the operation is successful.
*/

func AADataInsert(pDebug *helpers.HelperStruct, pUid, pSid string, lUserInfo UserConsentReqStruct, pConsentHandle, pFipId, pErrCode, pErrStatus string) error {
	pDebug.Log(helpers.Details, "AADataInsert(+)")

	lConsentStatus := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ConsentStatus")
	pProvider := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "Provider")
	insertQuery := `INSERT INTO ekyc_bank_aa (Request_Uid, Bank_Ref_ID, Phone_Number, Alt_Phone_number, Bank_Name,Consent_HandleID,AA_ConsentStatus , Session_Id, Updated_Session_Id,FipID,AA_Errcode,AA_ErrorMsg, Service_provider, CreatedDate, UpdatedDate) 
		VALUES (?, (SELECT id FROM ekyc_bank WHERE Request_Uid=? ORDER BY id DESC LIMIT 1), ?, ?, ?, ?, ?,?,?,?,?,?, ?, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());`

	_, lErr := ftdb.NewEkyc_GDB.Exec(insertQuery, pUid, pUid, lUserInfo.MobileNumber, lUserInfo.AlterMobileNumber, lUserInfo.BankName, pConsentHandle, lConsentStatus, pSid, pSid, pFipId, pErrCode, pErrStatus, pProvider)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "AADataInsert(-)")
	return nil
}

/*
AAFetchUpdateConsent updates the `ekyc_bank_aa` table with the provided consent ID and session ID for
a specific request. This function is used to store or update the consent details related to the
given request UID and consent handle.

 Parameters:
  - pDebug: A pointer to the `HelperStruct` used for logging details throughout the method execution.
  - pRequestUid: The unique identifier of the request for which the consent is being updated.
  - pSid: The current session ID to track the update session.
  - pAAConsentID: The new consent ID to be stored in the database.
  - pConsentHandle: The consent handle ID that identifies the consent record to update.

 Returns:
  - An error if the database update fails, or `nil` if the operation is successful.
*/

func AAFetchUpdateConsent(pDebug *helpers.HelperStruct, pRequestUid, pSid, pAAConsentID, pConsentHandle string) error {
	pDebug.Log(helpers.Details, "AAFetchUpdateConsent(+)")

	lUpdateQuery := `UPDATE ekyc_bank_aa 
                     SET AA_Consent_ID = ?, Updated_Session_Id=?, UpdatedDate = UNIX_TIMESTAMP()
                     WHERE Request_Uid = ? and Consent_HandleID=?;`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lUpdateQuery, pAAConsentID, pSid, pRequestUid, pConsentHandle)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "AAFetchUpdateConsent(+)")
	return nil
}
func AADataFetchUpdate(pDebug *helpers.HelperStruct, pRequestUid, pSid, pAAConsentID, pConsentHandle, pPdfDocId string, pUserInfo AAUserBankInfoStruct) error {
	pDebug.Log(helpers.Details, "AADataFetchUpdate(+)")

	lActive := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ActiveComments")
	lCompleted := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "CompletedComments")

	var lConsentStatus string
	if pPdfDocId != "" {
		lConsentStatus = lCompleted
	} else {
		lConsentStatus = lActive
	}

	// Update Query
	lUpdateQuery := `UPDATE ekyc_bank_aa 
                     SET AA_Consent_ID = ?, AA_ConsentStatus=?,  Bank_Link_ref_no=?, Updated_Session_Id=?, UpdatedDate = UNIX_TIMESTAMP()
                     WHERE Request_Uid = ? and Consent_HandleID=?;`

	_, lErr := ftdb.NewEkyc_GDB.Exec(lUpdateQuery, pAAConsentID, lConsentStatus, pUserInfo.LinkReferenceNumber, pSid, pRequestUid, pConsentHandle)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	var lExists bool
	lCheckQuery := `SELECT EXISTS(SELECT 1 FROM aa_user_bank_info WHERE Request_id = ?)`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCheckQuery, pRequestUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lExists)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}

	if !lExists {
		// Insert Query
		lInsertQuery := `INSERT INTO aa_user_bank_info 
	     (Request_id, Bank_Ref_ID, Phone_Number, Name, Bank_Name, DOB, Email, PAN, Address, Bank_Ckyc_status,
	      Bank_Account_status, Account_type, Statement_start_date, ConsentID, Statement_end_date,
	      Statement_status, AA_Stt_Doc_ID, AA_Json_Doc_ID, AA_Trans_Error, AA_Trans_Status, Session_Id, 
	      Updated_Session_Id, Bank_Link_ref_no, CreatedDate, UpdatedDate)
	      VALUES (?, 
			(SELECT id FROM ekyc_bank WHERE Request_Uid=? ORDER BY id DESC LIMIT 1), 
			?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, UNIX_TIMESTAMP(), UNIX_TIMESTAMP())`

		_, lErr = ftdb.NewEkyc_GDB.Exec(lInsertQuery, pRequestUid, pRequestUid, pUserInfo.MobileNumber, pUserInfo.UserName, pUserInfo.Bank,
			pUserInfo.DOB, pUserInfo.Email, pUserInfo.Pan, pUserInfo.Address, pUserInfo.BankCkycStatus,
			pUserInfo.BankAccountStatus, pUserInfo.AccountType, pUserInfo.TransStartDate, pAAConsentID,
			pUserInfo.TransEndDate, pUserInfo.StatementStatus, pUserInfo.PdfDocID, pUserInfo.JsonDocID,
			pUserInfo.TransError, pUserInfo.TransErrorStatus, pSid, pSid, pUserInfo.LinkReferenceNumber)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	} else {
		// Prepare the update query
		lUpdateString := `
		 UPDATE aa_user_bank_info 
		 SET 
			 Phone_Number = ?, 
			 Name = ?, 
			 Bank_Name = ?, 
			 DOB = ?, 
			 Email = ?, 
			 PAN = ?, 
			 Address = ?, 
			 Bank_Ckyc_status = ?, 
			 Bank_Account_status = ?, 
			 Account_type = ?, 
			 Statement_start_date = ?, 
			 ConsentID = ?, 
			 Statement_end_date = ?, 
			 Statement_status = ?, 
			 AA_Stt_Doc_ID = ?, 
			 AA_Json_Doc_ID = ?, 
			 AA_Trans_Error = ?, 
			 AA_Trans_Status = ?, 
			 Updated_Session_Id = ?, 
			 Bank_Link_ref_no = ?, 
			 UpdatedDate = UNIX_TIMESTAMP()
		 WHERE 
			 Request_id = ?`

		_, lErr = ftdb.NewEkyc_GDB.Exec(lUpdateString, pUserInfo.MobileNumber, pUserInfo.UserName, pUserInfo.Bank,
			pUserInfo.DOB, pUserInfo.Email, pUserInfo.Pan, pUserInfo.Address, pUserInfo.BankCkycStatus,
			pUserInfo.BankAccountStatus, pUserInfo.AccountType, pUserInfo.TransStartDate, pAAConsentID,
			pUserInfo.TransEndDate, pUserInfo.StatementStatus, pUserInfo.PdfDocID, pUserInfo.JsonDocID,
			pUserInfo.TransError, pUserInfo.TransErrorStatus, pSid, pUserInfo.LinkReferenceNumber, pRequestUid)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Details, "AADataFetchUpdate(-)")
	return nil
}

/*
AADataStatusUpdate is responsible for updating the `ekyc_bank_aa` table with the latest status
received from an Account Aggregator (AA) response, such as One Money. This method logs the
response and updates the relevant fields in the database based on the AA response codes.

 Steps:
  1. Loads configuration values for expected AA statuses (`ACTIVE`, `REJECTED`, `ConsentError`),
     as well as the corresponding comments for logging purposes.

  2. Updates the `ekyc_bank_aa` table with the transaction ID, error code, user ID, consent status,
     session ID, error message, and request UID.

 Parameters:
  - pDebug: A pointer to the `HelperStruct` used for logging details throughout the method execution.
  - pRequestUid: The unique identifier of the request being updated.
  - pSid: The current session ID.
  - pUrlRespData: A struct containing the decrypted response data from the AA, including the
    transaction ID, user ID, error code, session ID, and error message.

 Returns:
  - An error if the database update fails, or `nil` if the operation is successful.
*/
func AADataStatusUpdate(pDebug *helpers.HelperStruct, pRequestUid, pSid string, pUrlRespData DecryptUrlRespStruct) error {
	pDebug.Log(helpers.Details, "AADataStatusUpdate(+)")

	lConsentStatus := ""
	// Expected response from One Money
	lActive := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ACTIVE")
	lRejected := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "REJECTED")
	lConsentError := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ConsentError")
	// comments for Expected response from One Money from our side to log on table
	lActiveComments := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ActiveComments")
	lRejectedComments := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "RejectedComments")
	lConsentErrorComments := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "NotFoundComments")
	lInvalidRequestComments := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "InvalidRequestComments")

	// Incase of Success
	if pUrlRespData.Data.ErrorCode == lActive {
		lConsentStatus = lActiveComments
	} else if pUrlRespData.Data.ErrorCode == lRejected {
		lConsentStatus = lRejectedComments
	} else if pUrlRespData.Data.ErrorCode == lConsentError {
		lConsentStatus = lConsentErrorComments
	} else {
		lConsentStatus = lInvalidRequestComments
	}

	lUpdateQuery := `UPDATE ekyc_bank_aa 
	                 SET AA_Transaction_ID = ?, AA_Statuscode = ?, AA_userId = ?,AA_ConsentStatus =?,AA_Session_ID =?, Updated_Session_Id = ?,AA_Errcode=?,AA_ErrorMsg=?,UpdatedDate = UNIX_TIMESTAMP()
	                 WHERE Request_Uid = ? and Consent_HandleID=?;`

	_, lErr := ftdb.NewEkyc_GDB.Exec(lUpdateQuery, pUrlRespData.Data.TxnID, pUrlRespData.Data.ErrorCode, pUrlRespData.Data.UserID, lConsentStatus, pUrlRespData.Data.SessionID, pSid, pUrlRespData.ErrCode, pUrlRespData.ErrMsg, pRequestUid, pUrlRespData.Data.SrcRef)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "AADataStatusUpdate(-)")
	return nil
}

/*
AAInsertDocIdData is responsible for inserting or updating records in the `ekyc_attachments` table.
It performs the following actions:
 1. Checks if a record with the provided Request ID (`pUid`) already exists.
 2. If the record does not exist, it inserts a new record with the provided Income Type, Document ID, and Session ID.
 3. If the record exists, it updates the existing record with the new Income Type, Document ID, and Session ID.


Parameters:
 - pDebug: A pointer to the `HelperStruct` for logging and debugging.
 - pIncomeType: The type of income proof (e.g., salary slip, ITR, etc.).
 - pIncomDocID: The ID of the income proof document.
 - pUid: The unique ID of the request.
 - pSid: The session ID associated with the request.

Returns:
- An error if any operation fails, or `nil` if the operation is successful.
*/
func AAInsertDocIdData(pDebug *helpers.HelperStruct, pIncomeType, pIncomDocID, pUid, pSid string) error {
	pDebug.Log(helpers.Statement, "AAInsertDocIdData (+)")

	// Step 1: Check if the record exists for the given Request ID
	var exists bool
	checkExistenceQuery := `SELECT EXISTS(SELECT 1 FROM ekyc_attachments WHERE Request_id = ?)`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(checkExistenceQuery, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	/* Scan the result to check if the record exists */
	for lRows.Next() {
		lErr := lRows.Scan(&exists)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}

	// Step 2: Prepare the SQL queries for inserting and updating records
	lInsertQry := `INSERT INTO ekyc_attachments (Request_id, Income_prooftype, Income_proof, Session_Id, UpdatedSesion_Id, CreatedDate, UpdatedDate) 
                   VALUES (?, ?, ?, ?, ?, unix_timestamp(), unix_timestamp())`

	lUpdateQry := `UPDATE ekyc_attachments SET Income_prooftype = ?, Income_proof = ?, UpdatedSesion_Id = ?, UpdatedDate = unix_timestamp() 
                   WHERE Request_id = ?`

	// Step 3: Execute the appropriate query based on whether the record exists or not
	if !exists {
		_, lErr = ftdb.NewEkyc_GDB.Exec(lInsertQry, pUid, pIncomeType, pIncomDocID, pSid, pSid)
	} else {
		_, lErr = ftdb.NewEkyc_GDB.Exec(lUpdateQry, pIncomeType, pIncomDocID, pSid, pUid)
	}
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "common.DocumnetVerified :", common.DocumnetVerified)

	pDebug.Log(helpers.Statement, "AAInsertDocIdData (-)")
	return nil
}
