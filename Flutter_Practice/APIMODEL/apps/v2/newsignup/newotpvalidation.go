package newsignup

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v2/otp"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
)

type UserStruct struct {
	Name       string `json:"clientname"`
	Phone      string `json:"phone"`
	Email      string `json:"email"`
	State      string `json:"state"`
	ValidateId string `json:"validateid"`
	Otp        string `json:"otp"`
	OtpType    string `json:"otptype"`
	TempUid    string `json:"tempUid"`
	Url        string `json:"url"`
}

type OtpValRespStruct struct {
	Status       string `json:"status"`
	Description  string `json:"description"`
	Encryptedval string `json:"encryptedval"`
	InsertedID   string `json:"validateid"`
	TempUid      string `json:"tempUid"`
	AttemptCount int    `json:"attemptcount"`
}

func OtpValidation(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "OtpValidation(+) ")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	if strings.EqualFold(r.Method, "POST") {

		var lValidationRec UserStruct

		lBody, lErr := ioutil.ReadAll(r.Body)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "OVO01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("OVO01", "somthing is wrong please try again later"))
			return
		}

		lErr = json.Unmarshal(lBody, &lValidationRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "OVO02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("OVO02", "somthing is wrong please try again later"))
			return
		}

		log.Printf("lValidationRec %+v", lValidationRec)

		if lValidationRec.OtpType == "" {
			lDebug.Log(helpers.Elog, "OVO03", "Otp Type empty")
			fmt.Fprint(w, helpers.GetError_String("OVO03", "somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "Optvalildation Request ***", r)

		if strings.EqualFold(lValidationRec.OtpType, "email") {
			EmailOtpValidation(lDebug, lValidationRec, r, w)
		}
		if strings.EqualFold(lValidationRec.OtpType, "phone") {
			MobileOtpValidation(lDebug, lValidationRec, r, w)
		}
		w.WriteHeader(200)
		lDebug.Log(helpers.Statement, "OtpValidation(-) ")

	}
}

func OtpReqValidation(pDebug *helpers.HelperStruct, pOTPValidationRec UserStruct) (lIsOtpValid string, lErr error) {

	pDebug.Log(helpers.Statement, "OtpReqValidation(+) ")

	lIsOtpValid = "N"

	if pOTPValidationRec.ValidateId == "" {
		pDebug.Log(helpers.Details, "ORV001", "OTPValidation Id Empty")
		return lIsOtpValid, helpers.ErrReturn(errors.New("otp validation id cannot be empty"))
	}

	lLoggedBy := common.EKYCAppName

	pDebug.Log(helpers.Details, "pOTPValidationRec : ", fmt.Sprintf("%v", pOTPValidationRec))

	lIsOtpValid, lErr = otp.IsOtpValid(pOTPValidationRec.ValidateId, pOTPValidationRec.Otp, pDebug)
	pDebug.Log(helpers.Details, "OTP Id =>", pOTPValidationRec.ValidateId, "OTP =>", pOTPValidationRec.Otp, "lIsOtpValid =>", lIsOtpValid)
	if lErr != nil {
		return lIsOtpValid, helpers.ErrReturn(lErr)
	}

	if lIsOtpValid == "Y" {
		lErr := otp.UpdateValidated(pOTPValidationRec.ValidateId, lLoggedBy, pDebug)
		if lErr != nil {
			return lIsOtpValid, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "OtpReqValidation(-) ")

	return lIsOtpValid, nil

}

func SendOtpToEmail(pDebug *helpers.HelperStruct, pValidationRec UserStruct, pEmail string, r *http.Request) (successOTPStruct, error) {
	pDebug.Log(helpers.Statement, "SendOtpToEmail(+)")
	var pUserdataRec otp.UserdataStruct

	pUserdataRec.Username = pValidationRec.Name
	pUserdataRec.Sendto = pEmail
	pUserdataRec.Sendtotype = "email"
	pUserdataRec.ClientID = common.EKYCAppName
	pUserdataRec.Process = common.EKYCAppName

	lOtpResp, lErr := ValidateOtpRequest(pDebug, pUserdataRec, r)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "UNE001", lErr)
		return lOtpResp, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "SendOtpToEmail(-)")
	return lOtpResp, nil
}
