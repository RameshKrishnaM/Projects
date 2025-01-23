package newsignup

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v2/zohocrm"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	backofficecheck "fcs23pkg/integration/v2/backofficeCheck"
	"fcs23pkg/integration/v2/zohointegration"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"strings"

	uuid "github.com/satori/go.uuid"
)

// Final ok

func MobileOtpValidation(pDebug *helpers.HelperStruct, pValidationRec UserStruct, r *http.Request, w http.ResponseWriter) {
	pDebug.Log(helpers.Statement, "MobileOtpValidation(+) ")

	var lOtpSuccessResp OtpValRespStruct

	//Creating Session Id and Uid
	lTempUid := uuid.NewV4().String()
	lUid := strings.ReplaceAll(uuid.NewV4().String(), "-", "")
	lSessionSHA256 := sha256.Sum256([]byte(uuid.NewV4().String()))
	lSessionId := hex.EncodeToString(lSessionSHA256[:])

	lOtpValid, lErr := OtpReqValidation(pDebug, pValidationRec)
	if lErr != nil {
		fmt.Fprint(w, helpers.GetError_String("MOV01", "Something went wrong please try again later"))
		return
	}

	if lOtpValid == "N" {
		fmt.Fprint(w, helpers.GetError_String("MOV02", "Invalid Otp"))
		return
	}

	pDebug.Log(helpers.Details, fmt.Sprintf("pValidationRec %v", pValidationRec))

	//This method is used to check is the given data already pushed to backoffice through instaflow
	lIsBackofficeCompleted, lErr := isBackOfficeCompleted(pDebug, pValidationRec.Phone, "MOBILE")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "MOV000", lErr)
		fmt.Fprint(w, helpers.GetError_String("MOV01", "Something went wrong please try again later"))
		return
	}
	pDebug.Log(helpers.Details, "lIsBackofficeCompleted =>", lIsBackofficeCompleted)

	if strings.ToUpper(common.BOCheck) != "N" && !lIsBackofficeCompleted {

		lBoMobStatus, lErr := backofficecheck.BofficeCheck(pDebug, pValidationRec.Phone, "mobile")
		if lErr != nil {
			pDebug.Log(helpers.Elog, "MOV03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("MOV03", "Somthing is wrong please try again later"))
			return
		}
		// lBoMobStatus = true
		//check user mobile already exist
		if lBoMobStatus {
			pDebug.Log(helpers.Elog, "MOV04", "The given Mobile number has an account with us")
			fmt.Fprint(w, helpers.GetError_String("MC", "The given Mobile number has an account with us"))
			return
		}
	}

	lExistingData, lErr := GetExistingData(pDebug, pValidationRec.OtpType, pValidationRec.Phone)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "MOV06", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("MOV06", "Somthing is wrong please try again later"))
		return

	}
	pDebug.Log(helpers.Details, fmt.Sprintf("lExistingData %v", lExistingData))

	if lExistingData.ReqUid == "" {
		lErr = InsertNewTempRequest(pDebug, pValidationRec, lUid, lTempUid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "MOV07", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("MOV07", "Somthing is wrong please try again later"))
			return
		}
		lOtpSuccessResp.TempUid = lTempUid
	} else {

		//Condition should be checked if the existing data and the given should be changed

		if lExistingData.Name != pValidationRec.Name || lExistingData.State != pValidationRec.State {
			lErr = UpdateNameAndState(pDebug, lExistingData.ReqUid, pValidationRec.Name, pValidationRec.State)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "MOV08", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("MOV08", "Somthing is wrong please try again later"))
				return
			}
		}

		lTestAllow := common.TestAllow
		lTestEmail := common.TestEmail
		lTestMobile := common.TestMobile

		var lIsTestUser bool

		if lTestAllow == "Y" {
			if lExistingData.Phone == lTestMobile && lExistingData.Email == lTestEmail {
				lIsTestUser = true
			}
		}

		if lExistingData.Email != "" && !lIsTestUser {
			lEmailOtpResp, lErr := SendOtpToEmail(pDebug, pValidationRec, lExistingData.Email, r)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "MOV09", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("MOV09", helpers.ErrPrint(lErr)))
				return
			}
			if lEmailOtpResp.Status == "S" {
				lOtpSuccessResp.AttemptCount = lEmailOtpResp.AttemptCount
				lOtpSuccessResp.Encryptedval = lEmailOtpResp.Encryptedval
				lOtpSuccessResp.InsertedID = lEmailOtpResp.InsertedID
			}
		}
		lOtpSuccessResp.TempUid = lExistingData.TempUid
		lUid = lExistingData.ReqUid
	}

	lUtmRec, lErr := ReadUtmInfo(pDebug, pValidationRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "MOV010", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("MOV010", "Somthing went wrong please try again later"))
		return
	}

	lErr = zohocrm.InsertZohoCrmDeal(r, w, &lUtmRec, pDebug, lUid, lSessionId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "MOV011", lErr.Error())
	}

	lErr = InsertUserSession(pDebug, r, lUid, lSessionId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "MOV012", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("MOV012", "Somthing is wrong please try again later"))
		return
	}

	lErr = StatusInsert(pDebug, lUid, lSessionId, "signup")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "MOV013", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("MOV013", "Somthing is wrong please try again later"))
		return
	}

	lOtpSuccessResp.Status = "S"
	lOtpSuccessResp.Description = "OTP Verified Sucessfully !"

	lData, lErr := json.Marshal(lOtpSuccessResp)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "MOV012", lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("MOV012", "Somthing is wrong please try again later"))
		return
	}

	fmt.Fprint(w, string(lData))
	pDebug.Log(helpers.Statement, "MobileOtpValidation(-) ")
}
func ReadUtmInfo(pDebug *helpers.HelperStruct, pUserData UserStruct) (zohointegration.ZohoCrmDealInsertStruct, error) {
	pDebug.Log(helpers.Statement, "ReadUtmInfo(+)")

	// lErr := r.ParseMultipartForm(10 << 20) // Set max memory allocation to 10MB
	// if lErr != nil {
	// 	lDebug.Log(helpers.Elog, "NNR01", lErr.Error())
	// 	fmt.Fprint(w, helpers.GetError_String("NNR01", "Somthing is wrong please try again later"))
	// 	return
	// }

	// lBody := r.Form.Get("userDetails")

	// lUtmRec.Url_RmCode = r.Form.Get("rm_code")
	// lUtmRec.Url_BrCode = r.Form.Get("br_code")
	// lUtmRec.Url_EmpCode = r.Form.Get("emp_code")
	// lUtmRec.Url_UtmSource = r.Form.Get("utm_source")
	// lUtmRec.Url_UtmMedium = r.Form.Get("utm_medium")
	// lUtmRec.Url_UtmCampaign = r.Form.Get("utm_campaign")
	// lUtmRec.Url_UtmTerm = r.Form.Get("utm_term")
	// lUtmRec.Url_UtmContent = r.Form.Get("utm_keyword")
	// lUtmRec.Url_UtmKeyword = r.Form.Get("utm_content")
	// lUtmRec.Url_Mode = r.Form.Get("mode")
	// lUtmRec.Url_ReferalCode = r.Form.Get("referral_code")
	// lUtmRec.Url_Gclid = r.Form.Get("gclid")
	// lErr = json.Unmarshal([]byte(lBody), &lUserRec)
	// if lErr != nil {
	// 	lDebug.Log(helpers.Elog, "NNR02", lErr.Error())
	// return lUserRec
	// }

	var lUtmRec zohointegration.ZohoCrmDealInsertStruct

	if pUserData.Url != "" {

		lParsedURL, lErr := url.Parse(pUserData.Url)
		if lErr != nil {
			pDebug.Log(helpers.Details, "RUI001")
			return lUtmRec, lErr
		}

		lQueryParams := lParsedURL.Query()
		pDebug.Log(helpers.Details, "lQueryParams", lQueryParams)
		lUtmRec.Url_RmCode = lQueryParams.Get("rm_code")
		lUtmRec.Url_BrCode = lQueryParams.Get("br_code")
		lUtmRec.Url_EmpCode = lQueryParams.Get("emp_code")
		lUtmRec.Url_UtmSource = lQueryParams.Get("utm_source")
		lUtmRec.Url_UtmMedium = lQueryParams.Get("utm_medium")
		lUtmRec.Url_UtmCampaign = lQueryParams.Get("utm_campaign")
		lUtmRec.Url_UtmTerm = lQueryParams.Get("utm_term")
		lUtmRec.Url_UtmContent = lQueryParams.Get("utm_keyword")
		lUtmRec.Url_UtmKeyword = lQueryParams.Get("utm_content")
		lUtmRec.Url_Mode = lQueryParams.Get("mode")
		lUtmRec.Url_ReferalCode = lQueryParams.Get("referral_code")
		lUtmRec.Url_Gclid = lQueryParams.Get("gclid")
	}

	log.Printf("UTMINFO %+v", lUtmRec)

	pDebug.Log(helpers.Statement, "ReadUtmInfo(-)")

	return lUtmRec, nil

}

// This method is used to update the Given Name and Given State in the request and temp request table
func UpdateNameAndState(pDebug *helpers.HelperStruct, pUid, pGivenName, pState string) error {
	pDebug.Log(helpers.Statement, "UpdateNameAndState(+)")

	lCorestring2 := `IF EXISTS (select * from ekyc_request where Uid =? and isActive='Y')
	               THEN
				    UPDATE ekyc_request er
					JOIN ekyc_prime_request etr ON er.Uid = etr.Uid
					SET er.Given_Name = ?, etr.Given_Name = ?, er.Given_State = ?, etr.Given_State = ?
					WHERE er.Uid = ?;
					ELSE
					update ekyc_prime_request set Given_Name=? ,Given_State=? where Uid =? ;
					END IF;
					`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lCorestring2, pUid, pGivenName, pGivenName, pState, pState, pUid, pGivenName, pState, pUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "UNS002", lErr.Error())
		return lErr
	}

	pDebug.Log(helpers.Statement, "UpdateNameAndState(-)")
	return nil

}

/*
Purpose :=> This method is  used to check the given client data has been pushed to backoffice or not

Return => boolean value if pushed return true else return false and error if any error occurs
*/
func isBackOfficeCompleted(pDebug *helpers.HelperStruct, pData, pType string) (bool, error) {
	pDebug.Log(helpers.Statement, "isBackOfficeCompleted(+)")
	var lColoumName, lRequestId, lStatus string
	var lIsBackofficeComplete bool

	pDebug.Log(helpers.Details, "pData =>", pData)
	pDebug.Log(helpers.Details, "pType =>", pType)

	//Condition to be checked whether need to check for phone or email
	if strings.EqualFold(pType, "EMAIL") {
		lColoumName = "Email = '" + pData + "'"
	} else if strings.EqualFold(pType, "MOBILE") {
		lColoumName = "Phone = '" + pData + "'"
	} else {
		return lIsBackofficeComplete, errors.New("phone or email should not be empty")
	}

	lCorestring := `	select nvl(nih.requestUid,''),nvl(nih.status,'')
					from ekyc_request er left join newekyc_integration_history nih on er.Uid =nih.requestUid 
					where ` + lColoumName + ` and Form_Status ='RJ' and er.isActive ='Y'
					and nih.Stage ='Backoffice' order by nih.id desc limit 1`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "FVV002", lErr.Error())
		return lIsBackofficeComplete, lErr
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lRequestId, &lStatus)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "FVV003", lErr.Error())
			return lIsBackofficeComplete, lErr
		}
		pDebug.Log(helpers.Details, "lRequestId =>", lRequestId)
		pDebug.Log(helpers.Details, "lStatus =>", lStatus)

	}

	//Condition to be checked if the status is AB (AB for Approved Backoffice) then need to assing true in the phone not exist in request table need by default it should be false
	if lStatus == "AB" {
		lIsBackofficeComplete = true
	}

	pDebug.Log(helpers.Statement, "isBackOfficeCompleted(-)")
	return lIsBackofficeComplete, nil
}
