package newsignup

// import (
// 	"crypto/sha256"
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

// 	//Creating Session Id and Uid
// 	lTempUid := uuid.NewV4().String()
// 	lUid := strings.ReplaceAll(uuid.NewV4().String(), "-", "")
// 	lSessionSHA256 := sha256.Sum256([]byte(uuid.NewV4().String()))
// 	lSessionId := hex.EncodeToString(lSessionSHA256[:])

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
// 		pDebug.Log(helpers.Elog, "EOV007", "something went wrong try again later")
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

// 	var lNewEkycReq, lNewTempEkycReq bool
// 	var NewUserRec UserStruct
// 	// var lReqUid string

// 	//Already existing request with only instakyc completed forms

// 	if (lExistingEmailData.FormStatus != "OB" && lExistingEmailData.FormStatus != "") || (lExistingTempData.FormStatus != "OB" && lExistingTempData.FormStatus != "") {
// 		pDebug.Log(helpers.Elog, "EOV010", "The given email id has an account with us")
// 		fmt.Fprint(w, helpers.GetError_String("MC", "The given email id has an account with us"))
// 		return
// 	}

// 	// temp Request Uid and Request Uid matches Request already exists with OB status (old mobile + old email)

// 	// if lExistingTempData.ReqUid != "" && lExistingEmailData.ReqUid != "" && lExistingTempData.ReqUid == lExistingEmailData.ReqUid {
// 	// 	lOldEkycReq = true
// 	// 	lOldTempRec = true

// 	// }

// 	// Existing Email Doesnot Match with New Email (new mobile + old email)

// 	if lExistingTempData.ReqUid != "" && lExistingEmailData.ReqUid != "" && lExistingTempData.ReqUid != lExistingEmailData.ReqUid {

// 		pDebug.Log(helpers.Details, "(new mobile + old email)")

// 		// Email already exists with OB status need to create the new Request Deactive existing record
// 		lErr = DeActiveExistingRecord(pDebug, lDb, lExistingEmailData.ReqUid)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "EOV011", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("EOV011", "Somthing is wrong please try again later"))
// 			return
// 		}

// 		NewUserRec.Email = pValidationRec.Email
// 		NewUserRec.Name = lExistingEmailData.Name
// 		NewUserRec.State = lExistingEmailData.State
// 		NewUserRec.Phone = lExistingEmailData.Phone

// 		// create new temp request

// 		lNewEkycReq = true

// 	}

// 	//Request only present in temp table and not present in the request table ( old mobile + new email)

// 	if lExistingEmailData.ReqTable_Uid == "" && lExistingTempData.ReqTable_Uid != "" {

// 		pDebug.Log(helpers.Details, "( old mobile + new email)")

// 		lErr = DeActiveExistingRecord(pDebug, lDb, lExistingTempData.ReqUid)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "EOV022", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("EOV022", "Somthing is wrong please try again later"))
// 			return
// 		}

// 		NewUserRec.Email = pValidationRec.Email
// 		NewUserRec.Name = lExistingTempData.Name
// 		NewUserRec.State = lExistingTempData.State
// 		NewUserRec.Phone = lExistingTempData.Phone

// 		//Insert into the temp request and ekyc_request table

// 		lNewTempEkycReq = true
// 		lNewEkycReq = true

// 	}

// 	//Request only present in temp table and not present in the request table (new mobile + new email)

// 	if lExistingEmailData.ReqTable_Uid == "" && lExistingTempData.ReqTable_Uid == "" {

// 		pDebug.Log(helpers.Details, "( new mobile + new email)")

// 		NewUserRec.Email = pValidationRec.Email
// 		NewUserRec.Name = lExistingEmailData.Name
// 		NewUserRec.State = lExistingEmailData.State
// 		NewUserRec.Phone = lExistingEmailData.Phone

// 		//Insert into the ekyc_request table

// 		lNewEkycReq = true

// 	}

// 	pDebug.Log(helpers.Details, "lNewEkycReq =>", lNewEkycReq, "lNewTempEkycReq =>", lNewTempEkycReq)
// 	// Capture the data for the (new mobile + new email)

// 	if lNewEkycReq && lNewTempEkycReq {

// 		pDebug.Log(helpers.Details, "New for Temp and Request")

// 		// insert new request in ekyc_prime_request table
// 		lErr = InsertNewTempRequest(pDebug, lDb, NewUserRec, lUid, lTempUid)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "EOV012", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("EOV012", "Somthing is wrong please try again later"))
// 			return
// 		}

// 		lErr = InsertNewRequest(pDebug, lDb, lSessionId, lUid)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "EOV013", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("EOV013", "Somthing is wrong please try again later"))
// 			return
// 		}

// 		// create new deal in zoho crm as new user

// 		lErr = zohocrm.UpdatePhoneZohoCrmDeals(pDebug, r, lUid, lSessionId)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "EOV014", lErr.Error())
// 		}

// 		//update the status signup status in the status table for new request

// 		lErr = StatusInsert(pDebug, lDb, lUid, lSessionId, "signup")
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "EOV015", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("EOV015", "Somthing is wrong please try again later"))
// 			return
// 		}

// 	}

// 	// Capture the data for the (old mobile (mobile not exists in request table ) + new email )

// 	if lNewEkycReq && !lNewTempEkycReq {

// 		pDebug.Log(helpers.Details, "New for Request and old for Temp ")

// 		//Update the email in the ekyc_prime_request table

// 		lErr = UpdateEmailTempRequest(pDebug, lDb, pValidationRec.Email, pValidationRec.TempUid)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "EOV016", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("EOV016", "Somthing is wrong please try again later"))
// 			return
// 		}

// 		//insert the data into the ekyc_request table

// 		lErr = InsertNewRequest(pDebug, lDb, lSessionId, lExistingTempData.ReqUid)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "EOV017", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("EOV017", "Somthing is wrong please try again later"))
// 			return
// 		}

// 	}

// 	//update the email in zohocrmdeals

// 	lErr = zohocrm.UpdateEmailZohoCrmDeals(pDebug, r, lUid, common.EmailVerified, lSessionId)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV018", lErr.Error())
// 	}

// 	//update the session in session table

// 	lErr = InsertUserSession(pDebug, r, lDb, lUid, lSessionId)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV019", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV019", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	//update the email status in status table

// 	lErr = StatusInsert(pDebug, lDb, lUid, lSessionId, "EmailVerification")
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

// 	lErr = appsession.KycSetcookie(w, pDebug, common.EKYCCookieName, lSessionId, lCookieeExpiry)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "EOV021", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("EOV021", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	fmt.Fprint(w, helpers.GetMsg_String("S", "OTP Verified Sucessfully !"))
// 	pDebug.Log(helpers.Statement, "EmailOtpValidation (-)")
// }

// // if strings.EqualFold(lExistingTempData.IsExisting, "N") {

// // 	//Update Uid and Email in ekyc_prime_request table
// // 	lErr = UpdateExistingTempRequest(pDebug, lDb, pValidationRec.Email, lUid, pValidationRec.TempUid)
// // 	if lErr != nil {
// // 		pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// // 		fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// // 		return
// // 	}

// // 	//insert new request in ekyc_request table
// // 	lErr = InsertNewRequest(pDebug, lDb, lSessionId, pValidationRec.TempUid)
// // 	if lErr != nil {
// // 		pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// // 		fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// // 		return
// // 	}
// // }

// // if strings.EqualFold(lExistingTempData.IsExisting, "Y") {

// // 	if lExistingTempData.Email != "" && lExistingTempData.Email != pValidationRec.Email {

// // 		lErr = DeActiveExistingRecord(pDebug, lDb, lExistingTempData.ReqUid)
// // 		if lErr != nil {
// // 			pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// // 			fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// // 			return
// // 		}
// // 		var NewUserRec UserStruct

// // 		NewUserRec.Email = pValidationRec.Email
// // 		NewUserRec.Name = lExistingTempData.Name
// // 		NewUserRec.State = lExistingTempData.State
// // 		NewUserRec.Phone = lExistingTempData.Phone

// // 		//insert new request in ekyc_prime_request table
// // 		lErr = InsertNewTempRequest(pDebug, lDb, NewUserRec, lUid, lTempUid)
// // 		if lErr != nil {
// // 			pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// // 			fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// // 			return
// // 		}

// // 		// update New Uid in ekyc_prime_request
// // 		lErr = UpdateExistingTempRequest(pDebug, lDb, "", lTempUid)
// // 		if lErr != nil {
// // 			pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// // 			fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// // 			return
// // 		}

// // 		//insert new request in ekyc_request table
// // 		lErr = InsertNewRequest(pDebug, lDb, lSessionId, lTempUid)
// // 		if lErr != nil {
// // 			pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// // 			fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// // 			return
// // 		}
// // 	}
// // 	lUid = lExistingTempData.ReqUid

// // }
