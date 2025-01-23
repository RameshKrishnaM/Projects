package newsignup

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fcs23pkg/apps/v2/zohocrm"
	"fcs23pkg/appsession"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	backofficecheck "fcs23pkg/integration/v2/backofficeCheck"
	"fmt"
	"log"
	"net/http"
	"strings"

	uuid "github.com/satori/go.uuid"
)

// Final ok

func EmailOtpValidation(pDebug *helpers.HelperStruct, pValidationRec UserStruct, r *http.Request, w http.ResponseWriter) {
	pDebug.Log(helpers.Statement, "EmailOtpValidation (+)")

	// var lOtpSuccessResp OtpValRespStruct
	var lErr error

	pDebug.Log(helpers.Details, "Email valildation Request ***", r)

	if pValidationRec.Email != "" && pValidationRec.ValidateId != "" && (strings.Contains(pValidationRec.Email, "*") || strings.Contains(pValidationRec.Email, "#")) {

		pValidationRec.Email, lErr = FetchValuefromValidateId(pDebug, pValidationRec.ValidateId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "EOV000", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("EOV000", "something went wrong please try again later "))
			return
		}
	}
	pDebug.Log(helpers.Details, "validate id =>", pValidationRec.ValidateId, "validate Email =>", pValidationRec.Email)

	lOtpValid, lErr := OtpReqValidation(pDebug, pValidationRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "EOV001", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("EOV001", "something went wrong please try again later "))
		return
	}

	if lOtpValid == "N" {
		pDebug.Log(helpers.Elog, "EOV002", "Invalid Otp")
		fmt.Fprint(w, helpers.GetError_String("EOV002", "Invalid Otp"))
		return
	}

	pDebug.Log(helpers.Details, fmt.Sprintf("pValidationRec %v", pValidationRec))

	//This method is used to check is the given data already pushed to backoffice through instaflow
	lIsBackofficeCompleted, lErr := isBackOfficeCompleted(pDebug, pValidationRec.Email, "EMAIL")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "MOV000", lErr)
		fmt.Fprint(w, helpers.GetError_String("MOV01", "Something went wrong please try again later"))
		return
	}
	if strings.ToUpper(common.BOCheck) != "N" && !lIsBackofficeCompleted {

		lBoEmailStatus, lErr := backofficecheck.BofficeCheck(pDebug, pValidationRec.Email, "EMAIL")
		if lErr != nil {
			pDebug.Log(helpers.Elog, "EOV003", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("EOV003", "Somthing went wrong please try again later"))
			return
		}
		// lBoEmailStatus = true
		//check user Email already exist
		log.Println("Backofficecheck***", lBoEmailStatus)
		if lBoEmailStatus {
			pDebug.Log(helpers.Elog, "EOV005", "The given email id has an account with us")
			fmt.Fprint(w, helpers.GetError_String("EC", "The given email id has an account with us"))
			return
		}
	}

	if pValidationRec.TempUid == "" {
		pDebug.Log(helpers.Elog, "EOV007", "PageReolad")
		fmt.Fprint(w, helpers.GetError_String("R", "something went wrong please try again later "))
		return
	}

	// this method is to get existing user info based on Temp uid in temp request table
	lExistingMobileData, lErr := GetExistingData(pDebug, "TempUid", pValidationRec.TempUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "EOV008", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("EOV008", "Somthing went wrong please try again later"))
		return
	}

	pDebug.Log(helpers.Details, fmt.Sprintf("pValidationRec.TempUid => %v  lExistingMobileData => %v", pValidationRec.TempUid, lExistingMobileData))

	// this method is to get existing user info based on Temp uid in temp request table
	lExistingEmailData, lErr := GetExistingData(pDebug, "email", pValidationRec.Email)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "EOV009", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("EOV009", "Somthing went wrong please try again later"))
		return
	}
	pDebug.Log(helpers.Details, fmt.Sprintf("pValidationRec.Email => %v  lExistingEmailData => %v", pValidationRec.Email, lExistingEmailData))

	//Check the phone or email is already completed the form (not in OB status)
	lStatus, lErr := CheckFormCompletedData(pDebug, lExistingMobileData, lExistingEmailData, lExistingMobileData.ReqUid, r, w)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "EOV010", lStatus, lErr.Error())
		fmt.Fprint(w, helpers.GetError_String(lStatus, lErr.Error()))
		return
	}

	// Analyze mobile and email based data and return session Id
	lSessionId, lErr := AnalyzeRequestInfoInit(pDebug, r, lExistingMobileData, lExistingEmailData, pValidationRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "EOV011", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("EOV011", "Somthing went wrong please try again later"))
		return
	}
	//set the cookie
	lCookieeExpiry := common.CookieMaxAge

	lAppMode := r.Header.Get("App_mode")
	if !strings.EqualFold(lAppMode, "web") {
		lCookieeExpiry = common.AppCookieMaxAge
	}
	lErr = appsession.KycSetcookie(w, pDebug, common.EKYCCookieName, lSessionId, lCookieeExpiry)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "EOV012", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("EOV012", "Somthing went wrong please try again later"))
		return
	}

	fmt.Fprint(w, helpers.GetMsg_String("S", "OTP Verified Sucessfully !"))
	pDebug.Log(helpers.Statement, "EmailOtpValidation (-)")
}

func AnalyzeRequestInfoInit(pDebug *helpers.HelperStruct, pReq *http.Request, pMobileBased, pEmailBased ExistingDataStruct, pUserGivenRcd UserStruct) (string, error) {
	pDebug.Log(helpers.Statement, "AnalyzeRequestInfoInit(+)")
	pDebug.Log(helpers.Details, "AnalyzeRequestInfoInit valildation Request ***", pReq)

	//Creating Session Id and Uid
	pNewTempUid := uuid.NewV4().String()
	pNewUid := strings.ReplaceAll(uuid.NewV4().String(), "-", "")
	lSessionSHA256 := sha256.Sum256([]byte(uuid.NewV4().String()))
	pSessionId := hex.EncodeToString(lSessionSHA256[:])

	var pReqUid string
	var lErr error

	// New Mobile + New Email
	if pMobileBased.Email == "" && pEmailBased.Email == "" {

		pReqUid = pMobileBased.ReqUid

		// Update Email in Temp Request
		lErr = UpdateEmailTempRequest(pDebug, pUserGivenRcd.Email, pMobileBased.TempUid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "ARI01", lErr.Error())
			return pSessionId, helpers.ErrReturn(lErr)
		}

		//insert the data into the ekyc_request table
		lErr = InsertNewRequest(pDebug, pReq, pSessionId, pMobileBased.TempUid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "ARI02", lErr.Error())
			return pSessionId, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Details, " pMobileBased.Email =>", pMobileBased.Email, "pEmailBased.Email => ", pEmailBased.Email)

	// Existing Mobile + Existing Email
	if pMobileBased.Email != "" && pEmailBased.Email != "" && pMobileBased.Email == pEmailBased.Email {
		pReqUid = pMobileBased.ReqUid
	}

	// New Mobile + Existing OB Email
	if pMobileBased.Email == "" && pEmailBased.Email != "" {

		var lNewUserRec UserStruct
		lNewUserRec.Name = pMobileBased.Name
		lNewUserRec.Phone = pMobileBased.Phone
		lNewUserRec.State = pMobileBased.State
		lNewUserRec.Email = pEmailBased.Email
		lNewUserRec.TempUid = pMobileBased.TempUid

		pOldUid := pEmailBased.ReqUid
		pReqUid = pMobileBased.ReqUid

		//Deactive the old email record and insert the new record based on the email

		lErr = DeActiveOldNAddNewRequest(pDebug, pReq, lNewUserRec, pOldUid, pNewUid, pNewTempUid, pSessionId, "phone")
		if lErr != nil {
			pDebug.Log(helpers.Elog, "ARI03", lErr.Error())
			return pSessionId, helpers.ErrReturn(lErr)
		}

	}

	// Existing OB Mobile + New Email
	if pMobileBased.Email != "" && pEmailBased.Email == "" {

		var lNewUserRec UserStruct
		lNewUserRec.Name = pMobileBased.Name
		lNewUserRec.Phone = pMobileBased.Phone
		lNewUserRec.State = pMobileBased.State
		lNewUserRec.Email = pUserGivenRcd.Email

		pOldUid := pMobileBased.ReqUid
		pReqUid = pNewUid

		lErr = DeActiveOldNAddNewRequest(pDebug, pReq, lNewUserRec, pOldUid, pNewUid, pNewTempUid, pSessionId, "email")
		if lErr != nil {
			pDebug.Log(helpers.Elog, "ARI04", lErr.Error())
			return pSessionId, helpers.ErrReturn(lErr)
		}
	}

	// update the form status to zoho crm
	lErr = zohocrm.UpdateEmailZohoCrmDeals(pDebug, pReq, pReqUid, common.EmailVerified, pSessionId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "ARI05", lErr.Error())
	}

	//update the session in session table
	lErr = InsertUserSession(pDebug, pReq, pReqUid, pSessionId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "ARI06", lErr.Error())
		return pSessionId, helpers.ErrReturn(lErr)
	}

	//update the email status in status table
	lErr = StatusInsert(pDebug, pReqUid, pSessionId, "EmailVerification")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "ARI07", lErr.Error())
		return pSessionId, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "AnalyzeRequestInfoInit(-)")

	return pSessionId, nil
}

func DeActiveOldNAddNewRequest(pDebug *helpers.HelperStruct, r *http.Request, lNewUserRec UserStruct, pOldUid, pNewUid, NewTempId, pSessionId, pType string) error {
	pDebug.Log(helpers.Statement, "DeActiveOldNAddNewRequest(+)")
	pDebug.Log(helpers.Details, "AnalyzeRequestInfoInit valildation Request ***", r)

	pDebug.Log(helpers.Details, "lNewRec.Tempid =>", lNewUserRec.TempUid, "pOldUid => ", pOldUid, "pNewUid=>", pNewUid, "NewTempId=>", NewTempId)
	// Deactive the Existing Record
	lErr := DeActiveExistingRecord(pDebug, pOldUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "DAR01", lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	//insert the record for (old mobile + new email (email change))
	if strings.EqualFold(pType, "email") {

		// insert new request in ekyc_prime_request table
		lErr = InsertNewTempRequest(pDebug, lNewUserRec, pNewUid, NewTempId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "DAR02", lErr.Error())
			return helpers.ErrReturn(lErr)
		}

		// create new deal in zoho crm as new user
		lErr = zohocrm.UpdatePhoneZohoCrmDeals(pDebug, r, pNewUid, pSessionId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "DAR03", lErr.Error())
		}

		//update the status signup status in the status table for new request
		lErr = StatusInsert(pDebug, pNewUid, pSessionId, "signup")
		if lErr != nil {
			pDebug.Log(helpers.Elog, "DAR04", lErr.Error())
			return helpers.ErrReturn(lErr)
		}

		//insert the data into the ekyc_request table
		lErr = InsertNewRequest(pDebug, r, pSessionId, NewTempId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "DAR05", lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}

	//Update the (new mobile + existing email) in the temp table
	if strings.EqualFold(pType, "phone") {

		lErr = UpdateEmailTempRequest(pDebug, lNewUserRec.Email, lNewUserRec.TempUid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "DAR06", lErr.Error())
			return helpers.ErrReturn(lErr)
		}

		//insert the data into the ekyc_request table
		lErr = InsertNewRequest(pDebug, r, pSessionId, lNewUserRec.TempUid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "DAR07", lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "DeActiveOldNAddNewRequest(-)")

	return nil
}

//This method is used to check the phone or email is already completed the form

func CheckFormCompletedData(pDebug *helpers.HelperStruct, pMobileData ExistingDataStruct, pEmailData ExistingDataStruct, pUid string, r *http.Request, w http.ResponseWriter) (string, error) {
	pDebug.Log(helpers.Statement, "CheckFormCompletedData(+)")

	// if pMobileData.Email != "" && pEmailData.Email != "" && pMobileData.Email != pEmailData.Email {

	if pMobileData.FormStatus != "" && pEmailData.FormStatus != "" {

		// Existing OB Mobile + Existing FS Email

		if pMobileData.FormStatus == "OB" && pEmailData.FormStatus != "OB" {
			pDebug.Log(helpers.Elog, "CFC001", "Existing OB Mobile + Existing FS Email")
			return "EC", errors.New(" The given email id has completed the form with different mobile number")
		}

		// Existing FS Mobile + Existing OB Email

		if pMobileData.FormStatus != "OB" && pEmailData.FormStatus == "OB" {
			pDebug.Log(helpers.Elog, "CFC002", "Existing FS Mobile + Existing OB Email")
			return "MC", errors.New(" The given mobile number has completed the form with different email id")
		}

		// Existing FS Mobile + Existing FS Email

		if pMobileData.FormStatus != "OB" && pEmailData.FormStatus != "OB" {

			lSessionSHA256 := sha256.Sum256([]byte(uuid.NewV4().String()))
			lSessionId := hex.EncodeToString(lSessionSHA256[:])
			pDebug.Log(helpers.Details, "Check form completed Request ***", r)

			lErr := InsertUserSession(pDebug, r, pUid, lSessionId)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CFCD003", lErr.Error())
				return "", errors.New(" Somthing went wrong please try again later")

			}

			lErr = StatusInsert(pDebug, pUid, lSessionId, "EmailVerification")
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CFCD004", lErr.Error())
				return "", errors.New(" Somthing went wrong please try again later")

			}

			lCookieeExpiry := common.CookieMaxAge

			lAppMode := r.Header.Get("App_mode")
			if !strings.EqualFold(lAppMode, "web") {
				lCookieeExpiry = common.AppCookieMaxAge
			}
			lErr = appsession.KycSetcookie(w, pDebug, common.EKYCCookieName, lSessionId, lCookieeExpiry)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CFCD005", lErr.Error())
				return "", errors.New(" Somthing went wrong please try again later")
			}

			pDebug.Log(helpers.Elog, "CFCD006", "Existing FS Mobile + Existing FS Email")
			return "MEC", errors.New("the given mobile number and email id is already registered ")
		}
	}

	//Existing FS Mobile + New Email
	if pMobileData.FormStatus != "" && pMobileData.FormStatus != "OB" && pEmailData.FormStatus == "" {
		pDebug.Log(helpers.Elog, "CFCD007", "Existing FS Mobile + New Email")
		return "MC", errors.New(" The given mobile number has completed the form with different email id")
	}

	//New Mobile + Existing FS Email

	if pMobileData.FormStatus == "" && pEmailData.FormStatus != "" && pEmailData.FormStatus != "OB" {
		pDebug.Log(helpers.Elog, "CFCD008", "New  Mobile + Existing FS Email")
		return "EC", errors.New(" The given email id has completed the form with different mobile number")
	}

	pDebug.Log(helpers.Statement, "CheckFormCompletedData(-)")
	return "", nil
}

// Fetch Email or Phone through the validate id in the otp log table
func FetchValuefromValidateId(pDebug *helpers.HelperStruct, pValidateId string) (string, error) {
	pDebug.Log(helpers.Details, "FetchValuefromValidateId(+)")

	var lValue string

	lCorestring := `select nvl(sentTo,'') sendto from otplog where id =?`
	lRows, lErr := ftdb.MariaEKYCPRD_GDB.Query(lCorestring, pValidateId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "FVV002", lErr.Error())
		return lValue, lErr
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lValue)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "FVV003", lErr.Error())
			return lValue, lErr
		}
	}
	pDebug.Log(helpers.Details, "FetchValuefromValidateId(-)")
	return lValue, nil
}
