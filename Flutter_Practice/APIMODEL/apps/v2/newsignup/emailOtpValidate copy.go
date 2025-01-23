package newsignup

// Partially working
import (
	"crypto/sha256"
	"encoding/hex"
	"fcs23pkg/apps/v2/zohocrm"
	"fcs23pkg/appsession"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	backofficecheck "fcs23pkg/integration/v2/backofficeCheck"
	"fmt"
	"net/http"
	"strings"

	uuid "github.com/satori/go.uuid"
)

// Final ok

func EmailOtpValidation2(pDebug *helpers.HelperStruct, pValidationRec UserStruct, r *http.Request, w http.ResponseWriter) {
	pDebug.Log(helpers.Statement, "EmailOtpValidation (+)")

	// var lOtpSuccessResp OtpValRespStruct

	//Creating Session Id and Uid
	lTempUid := uuid.NewV4().String()
	lUid := strings.ReplaceAll(uuid.NewV4().String(), "-", "")
	lSessionSHA256 := sha256.Sum256([]byte(uuid.NewV4().String()))
	lSessionId := hex.EncodeToString(lSessionSHA256[:])

	lOtpValid, lErr := OtpReqValidation(pDebug, pValidationRec)
	if lErr != nil {
		fmt.Fprint(w, helpers.GetError_String("ORV003", "something went wrong try again later "))
		return
	}

	if lOtpValid == "N" {
		fmt.Fprint(w, helpers.GetError_String("ORV003", "Invalid Otp"))
		return
	}

	pDebug.Log(helpers.Details, fmt.Sprintf("pValidationRec %v", pValidationRec))

	if strings.ToUpper(common.BOCheck) != "N" {

		lBoEmailStatus, lErr := backofficecheck.BofficeCheck(pDebug, pValidationRec.Email, "EMAIL")
		if lErr != nil {
			pDebug.Log(helpers.Elog, "NRI004", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NRI004", "Somthing is wrong please try again later"))
			return
		}
		//check user Email already exist
		if lBoEmailStatus {
			pDebug.Log(helpers.Elog, "NRI005", "The given email id has an account with us")
			fmt.Fprint(w, helpers.GetError_String("MC", "The given email id has an account with us"))
			return
		}
	}

	if pValidationRec.TempUid == "" {
		pDebug.Log(helpers.Elog, "NRI005", "something went wrong try again later")
		fmt.Fprint(w, helpers.GetError_String("R", "something went wrong try again later "))
		return
	}

	// this method is to get existing user info based on Temp uid in temp request table
	lExistingTempData, lErr := GetExistingData(pDebug, "TempUid", pValidationRec.TempUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "NRI007", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("NRI007", "Somthing is wrong please try again later"))
		return
	}
	pDebug.Log(helpers.Details, fmt.Sprintf("Data Fetched based on Temp ID  =>  pValidationRec.TempUid => %v  lExistingTempData => %v", pValidationRec.TempUid, lExistingTempData))

	// this method is to get existing user info based on Temp uid in temp request table
	lExistingEmailData, lErr := GetExistingData(pDebug, "email", pValidationRec.Email)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "NRI007", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("NRI007", "Somthing is wrong please try again later"))
		return
	}
	pDebug.Log(helpers.Details, fmt.Sprintf("Data Fetched based on email id => %v", lExistingEmailData))

	// Previous code commented Below //

	var lReqUid, isNewRcd, lUpdateMobileStatus string

	// Existing Email Doesnot Match with New Email
	if lExistingTempData.ReqUid != lExistingEmailData.ReqUid && lExistingTempData.Email != lExistingEmailData.Email {
		// status needs to be update and handle in front end
		// check if Existing Email form was already submitted
		pDebug.Log(helpers.Details, "New Recorde exists ")
		if lExistingEmailData.FormStatus != "OB" {
			pDebug.Log(helpers.Elog, "NRI006", "The given email id has an account with us")
			fmt.Fprint(w, helpers.GetError_String("MC", "The given email id has an account with us"))
			return
		} else {
			lReqUid = lUid
			isNewRcd = "Y"
			lUpdateMobileStatus = "Y"

			// Deactive existing record
			if lExistingEmailData.ReqUid != "" {
				lErr = DeActiveExistingRecord(pDebug, lExistingEmailData.ReqUid)
				if lErr != nil {
					pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
					return
				}
			}

			// create new temp request
			var NewUserRec UserStruct
			NewUserRec.Email = pValidationRec.Email
			NewUserRec.Name = lExistingEmailData.Name
			NewUserRec.State = lExistingEmailData.State
			NewUserRec.Phone = lExistingEmailData.Phone

			//insert new request in ekyc_prime_request table
			lErr = InsertNewTempRequest(pDebug, NewUserRec, lReqUid, lTempUid)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
				return
			}

		}
	}

	if lExistingTempData.Email == pValidationRec.Email {
		pDebug.Log(helpers.Details, "Email matched old record ")

		lReqUid = lExistingTempData.ReqUid
		isNewRcd = "N"
	}

	if lExistingTempData.Email == "" && lExistingEmailData.Email == "" {
		pDebug.Log(helpers.Details, "Email matched old record ")

		lReqUid = lExistingTempData.ReqUid
		isNewRcd = "Y"
	}

	pDebug.Log(helpers.Details, "isNewRcd =>", isNewRcd)

	if isNewRcd == "Y" {

		lErr = InsertNewRequest(pDebug, r, lSessionId, lReqUid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
			return
		}

	} else {
		lErr = UpdateEmailTempRequest(pDebug, pValidationRec.Email, pValidationRec.TempUid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
			return
		}
	}
	if lUpdateMobileStatus == "Y" {

		if lExistingEmailData.ReqUid != "" {
			lErr = zohocrm.UpdatePhoneZohoCrmDeals(pDebug, r, lUid, lSessionId)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
			}

			//update the status signup status in the status table for new request
			lErr = StatusInsert(pDebug, lUid, lSessionId, "signup")
			if lErr != nil {
				pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
				return
			}
		}
	}
	// create new deal in zoho crm as new user for Existing Email

	lErr = zohocrm.UpdateEmailZohoCrmDeals(pDebug, r, lUid, common.EmailVerified, lSessionId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
	}

	lErr = InsertUserSession(pDebug, r, lUid, lSessionId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
		return
	}

	lErr = StatusInsert(pDebug, lUid, lSessionId, "EmailVerification")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
		return
	}

	var lCookieeExpiry int
	lAppMode := r.Header.Get("App_mode")
	if strings.EqualFold(lAppMode, "web") {
		lCookieeExpiry = common.CookieMaxAge
	} else {
		lCookieeExpiry = common.AppCookieMaxAge
	}
	//set cokkie in browser
	lErr = appsession.KycSetcookie(w, pDebug, common.EKYCCookieName, lSessionId, lCookieeExpiry)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
		return
	}

	fmt.Fprint(w, helpers.GetMsg_String("S", "OTP Verified Sucessfully !"))
	pDebug.Log(helpers.Statement, "EmailOtpValidation (-)")
}

// if strings.EqualFold(lExistingTempData.IsExisting, "N") {

// 	//Update Uid and Email in ekyc_prime_request table
// 	lErr = UpdateExistingTempRequest(pDebug, lDb, pValidationRec.Email, lUid, pValidationRec.TempUid)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// 		return
// 	}

// 	//insert new request in ekyc_request11 table
// 	lErr = InsertNewRequest(pDebug, lDb, lSessionId, pValidationRec.TempUid)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// 		return
// 	}
// }

// if strings.EqualFold(lExistingTempData.IsExisting, "Y") {

// 	if lExistingTempData.Email != "" && lExistingTempData.Email != pValidationRec.Email {

// 		lErr = DeActiveExistingRecord(pDebug, lDb, lExistingTempData.ReqUid)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// 			return
// 		}
// 		var NewUserRec UserStruct

// 		NewUserRec.Email = pValidationRec.Email
// 		NewUserRec.Name = lExistingTempData.Name
// 		NewUserRec.State = lExistingTempData.State
// 		NewUserRec.Phone = lExistingTempData.Phone

// 		//insert new request in ekyc_prime_request table
// 		lErr = InsertNewTempRequest(pDebug, lDb, NewUserRec, lUid, lTempUid)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// 			return
// 		}

// 		// update New Uid in ekyc_prime_request
// 		lErr = UpdateExistingTempRequest(pDebug, lDb, "", lTempUid)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// 			return
// 		}

// 		//insert new request in ekyc_request table
// 		lErr = InsertNewRequest(pDebug, lDb, lSessionId, lTempUid)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// 			return
// 		}
// 	}
// 	lUid = lExistingTempData.ReqUid

// }
