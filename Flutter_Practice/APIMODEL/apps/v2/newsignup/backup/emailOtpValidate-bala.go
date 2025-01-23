package newsignup

// import (
// 	"crypto/sha256"
// 	"database/sql"
// 	"encoding/hex"
// 	"fcs23pkg/apps/v2/zohocrm"
// 	"fcs23pkg/appsession"
// 	"fcs23pkg/common"
// 	"fcs23pkg/ftdb"
// 	"fcs23pkg/helpers"
// 	backofficecheck "fcs23pkg/integration/v2/backofficeCheck"
// 	"fmt"
// 	"net/http"
// 	"strings"

// 	uuid "github.com/satori/go.uuid"
// )

// // Final ok

// func EmailOtpValidation(pDebug *helpers.HelperStruct, pValidationRec UserStruct, r *http.Request, w http.ResponseWriter) {
// 	pDebug.Log(helpers.Statement, "EmailOtpValidation (+)")

// 	// var lOtpSuccessResp OtpValRespStruct

// 	lOtpValid, lErr := OtpReqValidation(pDebug, pValidationRec)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV001", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV001", "something went wrong try again later "))
// 		return
// 	}

// 	if lOtpValid == "N" {
// 		pDebug.Log(helpers.Elog, "EOV002", "Invalid Otp")
// 		fmt.Fprint(w, helpers.GetError_String("EOV002", "Invalid Otp"))
// 		return
// 	}

// 	pDebug.Log(helpers.Details, fmt.Sprintf("pValidationRec %v", pValidationRec))

// 	if strings.ToUpper(common.BOCheck) != "N" {

// 		lBoEmailStatus, lErr := backofficecheck.BofficeCheck(pDebug, pValidationRec.Email, "EMAIL")
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "EOV003", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("EOV003", "Somthing is wrong please try again later"))
// 			return
// 		}
// 		//check user Email already exist
// 		if lBoEmailStatus {
// 			pDebug.Log(helpers.Elog, "EOV005", "The given email id has an account with us")
// 			fmt.Fprint(w, helpers.GetError_String("MC", "The given email id has an account with us"))
// 			return
// 		}
// 	}

// 	lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV006", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV006", "Somthing is wrong please try again later"))
// 		return
// 	}
// 	defer lDb.Close()

// 	if pValidationRec.TempUid == "" {
// 		pDebug.Log(helpers.Elog, "EOV007", "PageReolad")
// 		fmt.Fprint(w, helpers.GetError_String("R", "something went wrong try again later "))
// 		return
// 	}

// 	// this method is to get existing user info based on Temp uid in temp request table
// 	lExistingTempData, lErr := GetExistingData(pDebug, "TempUid", pValidationRec.TempUid)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV008", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV008", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	pDebug.Log(helpers.Details, fmt.Sprintf("pValidationRec.TempUid => %v  lExistingTempData => %v", pValidationRec.TempUid, lExistingTempData))

// 	// this method is to get existing user info based on Temp uid in temp request table
// 	lExistingEmailData, lErr := GetExistingData(pDebug, "email", pValidationRec.Email)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV009", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV009", "Somthing is wrong please try again later"))
// 		return
// 	}
// 	pDebug.Log(helpers.Details, fmt.Sprintf("pValidationRec.Email => %v  lExistingEmailData => %v", pValidationRec.Email, lExistingEmailData))

// 	// Previous code commented Below //

// 	fmt.Fprint(w, helpers.GetMsg_String("S", "OTP Verified Sucessfully !"))
// 	pDebug.Log(helpers.Statement, "EmailOtpValidation (-)")
// }

// func SucccessSenarios(pDebug *helpers.HelperStruct, r *http.Request, w http.ResponseWriter, pDb *sql.DB, pMobileBased, pEmailBased ExistingDataStruct, pUserGivenRcd UserStruct) {

// 	//Creating Session Id and Uid
// 	pNewTempUid := uuid.NewV4().String()
// 	pNewUid := strings.ReplaceAll(uuid.NewV4().String(), "-", "")
// 	lSessionSHA256 := sha256.Sum256([]byte(uuid.NewV4().String()))
// 	pSessionId := hex.EncodeToString(lSessionSHA256[:])

// 	// New Mobile + New Email
// 	if pMobileBased.Email == "" && pEmailBased.Email == "" {
// 		EmailUpdateNewRequestIns(pDebug, w, pDb, pUserGivenRcd.Email, pSessionId, pMobileBased.TempUid)
// 		StatusUpdateNCookieSet(pDebug, r, w, pDb, pMobileBased.ReqUid, pSessionId)
// 		return
// 	}

// 	// Existing Mobile + Existing Email
// 	if pMobileBased.Email != "" && pEmailBased.Email != "" && pMobileBased.Email == pEmailBased.Email {
// 		StatusUpdateNCookieSet(pDebug, r, w, pDb, pMobileBased.ReqUid, pSessionId)
// 		return
// 	}

// 	// New Mobile + Existing OB Email
// 	if pMobileBased.Email == "" && pEmailBased.Email != "" {

// 		var lNewUserRec UserStruct
// 		lNewUserRec.Name = pMobileBased.Name
// 		lNewUserRec.Phone = pMobileBased.Phone
// 		lNewUserRec.State = pMobileBased.State
// 		lNewUserRec.Email = pEmailBased.Email

// 		pOldUid := pEmailBased.ReqUid

// 		DeActiveOldNAddNewRequest(pDebug, r, w, pDb, lNewUserRec, pOldUid, pNewUid, pNewTempUid, pSessionId)
// 		StatusUpdateNCookieSet(pDebug, r, w, pDb, pNewUid, pSessionId)
// 		return
// 	}

// 	// Existing OB Mobile + New Email
// 	if pMobileBased.Email != "" && pEmailBased.Email == "" {

// 		var lNewUserRec UserStruct
// 		lNewUserRec.Name = pEmailBased.Name
// 		lNewUserRec.Phone = pEmailBased.Phone
// 		lNewUserRec.State = pEmailBased.State
// 		lNewUserRec.Email = pMobileBased.Email

// 		pOldUid := pMobileBased.ReqUid

// 		DeActiveOldNAddNewRequest(pDebug, r, w, pDb, lNewUserRec, pOldUid, pNewUid, pNewTempUid, pSessionId)
// 		StatusUpdateNCookieSet(pDebug, r, w, pDb, pNewUid, pSessionId)
// 		return
// 	}
// }

// // Doubt - Need to check
// func CompareDatas2(pDebug *helpers.HelperStruct, r *http.Request, w http.ResponseWriter, pDb *sql.DB, pSessionId, pNewTempUid, pNewUid string, pMobileBased, pEmailBased ExistingDataStruct, pUserGivenRcd UserStruct) {

// 	// New Onboarding User
// 	if pMobileBased.ReqUid != "" && pEmailBased.ReqUid == "" && pMobileBased.Email == "" && pEmailBased.Email == "" {
// 		EmailUpdateNewRequestIns(pDebug, w, pDb, pUserGivenRcd.Email, pSessionId, pMobileBased.TempUid)
// 		StatusUpdateNCookieSet(pDebug, r, w, pDb, pMobileBased.ReqUid, pSessionId)
// 		return
// 	}

// 	if pMobileBased.ReqUid != "" && pEmailBased.ReqUid != "" && pMobileBased.ReqUid == pEmailBased.ReqUid {
// 		// Existing Onboarding User With same Mobile & Email
// 		if pMobileBased.Email != "" && pEmailBased.Email != "" && pMobileBased.Email == pEmailBased.Email {
// 			StatusUpdateNCookieSet(pDebug, r, w, pDb, pMobileBased.ReqUid, pSessionId)
// 			return
// 		}
// 	}

// 	// New Mobile With Existing Onboarding Email User
// 	if pMobileBased.ReqUid != "" && pEmailBased.ReqUid != "" && pMobileBased.ReqUid != pEmailBased.ReqUid {
// 		if pMobileBased.Email == "" && pEmailBased.Email != "" {
// 			var lNewUserRec UserStruct
// 			lNewUserRec.Name = pEmailBased.Name
// 			lNewUserRec.Phone = pEmailBased.Phone
// 			lNewUserRec.State = pEmailBased.State
// 			lNewUserRec.Email = pEmailBased.Email

// 			pOldUid := pEmailBased.ReqUid

// 			DeActiveOldNAddNewRequest(pDebug, r, w, pDb, lNewUserRec, pOldUid, pNewUid, pNewTempUid, pSessionId)
// 			StatusUpdateNCookieSet(pDebug, r, w, pDb, pMobileBased.ReqUid, pSessionId)
// 			return
// 		}
// 	}

// 	// Existing Onboarding User With same Mobile & New Email   - Final
// 	// pMobileBased.ReqUid != "" && =>
// 	if pMobileBased.ReqUid != "" && pEmailBased.ReqUid == "" {
// 		if pMobileBased.Email != "" && pEmailBased.Email == "" && pMobileBased.Email != pUserGivenRcd.Email {
// 			var lNewUserRec UserStruct
// 			lNewUserRec.Name = pMobileBased.Name
// 			lNewUserRec.Phone = pMobileBased.Phone
// 			lNewUserRec.State = pMobileBased.State
// 			lNewUserRec.Email = pEmailBased.Email

// 			pOldUid := pMobileBased.ReqUid

// 			DeActiveOldNAddNewRequest(pDebug, r, w, pDb, lNewUserRec, pOldUid, pNewUid, pNewTempUid, pSessionId)
// 			StatusUpdateNCookieSet(pDebug, r, w, pDb, pMobileBased.ReqUid, pSessionId)
// 			return
// 		}
// 	}
// }

// func DeActiveOldNAddNewRequest(pDebug *helpers.HelperStruct, r *http.Request, w http.ResponseWriter, lDb *sql.DB, lNewUserRec UserStruct, pOldUid, pNewUid, NewTempId, pSessionId string) {

// 	lErr := DeActiveExistingRecord(pDebug, lDb, pOldUid)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV022", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV022", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	// insert new request in ekyc_temp_request2 table
// 	lErr = InsertNewTempRequest(pDebug, lDb, lNewUserRec, pNewUid, NewTempId)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV012", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV012", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	//insert the data into the ekyc_request1 table
// 	lErr = InsertNewRequest(pDebug, lDb, pSessionId, NewTempId)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV017", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV017", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	// create new deal in zoho crm as new user
// 	lErr = zohocrm.UpdatePhoneZohoCrmDeals(pDebug, r, pNewUid, pSessionId)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV014", lErr.Error())
// 	}

// 	//update the status signup status in the status table for new request

// 	lErr = StatusInsert(pDebug, lDb, pNewUid, pSessionId, "signup")
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV015", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV015", "Somthing is wrong please try again later"))
// 		return
// 	}
// }

// func DeActiveOldNAddNewRequest2(pDebug *helpers.HelperStruct, r *http.Request, w http.ResponseWriter, lDb *sql.DB, pMobileBased, pEmailBased ExistingDataStruct, pNewUid, NewTempId, pSessionId string) {

// 	var lNewUserRec UserStruct

// 	lOldUid := pEmailBased.ReqUid
// 	lNewEmail := pEmailBased.Email

// 	lErr := DeActiveExistingRecord(pDebug, lDb, lOldUid)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV022", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV022", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	lNewUserRec.Email = lNewEmail
// 	lNewUserRec.Name = pMobileBased.Name
// 	lNewUserRec.State = pMobileBased.State
// 	lNewUserRec.Phone = pMobileBased.Phone

// 	// insert new request in ekyc_temp_request2 table
// 	lErr = InsertNewTempRequest(pDebug, lDb, lNewUserRec, pNewUid, NewTempId)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV012", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV012", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	//insert the data into the ekyc_request1 table
// 	lErr = InsertNewRequest(pDebug, lDb, pSessionId, NewTempId)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV017", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV017", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	// create new deal in zoho crm as new user
// 	lErr = zohocrm.UpdatePhoneZohoCrmDeals(pDebug, r, pNewUid, pSessionId)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV014", lErr.Error())
// 	}

// 	//update the status signup status in the status table for new request

// 	lErr = StatusInsert(pDebug, lDb, pNewUid, pSessionId, "signup")
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV015", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV015", "Somthing is wrong please try again later"))
// 		return
// 	}
// }

// func EmailUpdateNewRequestIns(pDebug *helpers.HelperStruct, w http.ResponseWriter, lDb *sql.DB, lEmail, lSessionId, lTempUid string) {
// 	// Update the email in the ekyc_temp_request2 table

// 	lErr := UpdateEmailTempRequest(pDebug, lDb, lEmail, lTempUid)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV016", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV016", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	//insert the data into the ekyc_request1 table
// 	lErr = InsertNewRequest(pDebug, lDb, lSessionId, lTempUid)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV017", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV017", "Somthing is wrong please try again later"))
// 		return
// 	}
// }

// func StatusUpdateNCookieSet(pDebug *helpers.HelperStruct, r *http.Request, w http.ResponseWriter, pDb *sql.DB, pReqUid, pSessionId string) {
// 	lErr := zohocrm.UpdateEmailZohoCrmDeals(pDebug, r, pReqUid, common.EmailVerified, pSessionId)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV018", lErr.Error())
// 	}

// 	//update the session in session table

// 	lErr = InsertUserSession(pDebug, r, pDb, pReqUid, pSessionId)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV019", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV019", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	//update the email status in status table

// 	lErr = StatusInsert(pDebug, pDb, pReqUid, pSessionId, "EmailVerification")
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV020", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV020", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	//set the cookie

// 	var lCookieeExpiry int
// 	lAppMode := r.Header.Get("App_mode")

// 	if strings.EqualFold(lAppMode, "web") {

// 		lCookieeExpiry = common.CookieMaxAge

// 	} else {

// 		lCookieeExpiry = common.AppCookieMaxAge
// 	}

// 	lErr = appsession.KycSetcookie(w, pDebug, common.EKYCCookieName, pSessionId, lCookieeExpiry)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV021", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV021", "Somthing is wrong please try again later"))
// 		return
// 	}
// }
