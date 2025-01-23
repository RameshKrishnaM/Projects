package ipv

import (
	"fcs23pkg/apps/v2/otp"
	"fcs23pkg/common"
	"fcs23pkg/coresettings"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fmt"
	"net/http"
	"strconv"
	"strings"
)

type LogOtpStruct struct {
	SendToType string
	SendTo     string
	OTP        string
	ClientID   string
	LoggedBy   string
	Process    string
}

func SendOtp(pDetails IPVUrlStruct, r *http.Request, pDebug *helpers.HelperStruct) (lRespStruct IPVotpStruct, lErr error) {

	pDebug.Log(helpers.Statement, "SendOtp(+)")

	var OtpInput LogOtpStruct
	var htmlInput otp.HtmlStruct

	pDebug.Log(helpers.Details, "details:", pDetails)

	lClientId := common.GetSetClient(pDetails.ClientID)
	lLoggedBy := common.GetLoggedBy(pDetails.ClientID)

	lTestAllow := tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestAllow")
	lTestEmail := tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestEmail")
	lTestMobile := tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestMobile")
	lTestOTP := tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestOTP")

	lOtp := common.GenerateOTP()
	if strings.EqualFold(lTestAllow, "Y") && (strings.EqualFold(pDetails.Email, lTestEmail) || strings.EqualFold(pDetails.Mobile, lTestMobile)) {
		lOtp = lTestOTP
	}

	pDebug.Log(helpers.Details, "otp:", lOtp)


	lEmailparth := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Emailparth")
	// lEmailSubject := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["EmailSubject"])


	lEmailSubject := tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig","OTPSubject")
	lEmailSubject = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD_GDB, lEmailSubject)

	// if strings.EqualFold(pDetails.Sendtotype, "EMAIL") {
	htmlInput.HtmlPath = lEmailparth
	htmlInput.Subject = lEmailSubject
	htmlInput.Otp = lOtp
	htmlInput.EmailId = pDetails.Email
	// if condition only for development purpose

	if strings.EqualFold(pDetails.OtpType, "Email") {
		if strings.ToUpper(common.EmailOtpSend) != "N" && !(strings.EqualFold(lTestAllow, "Y") && strings.EqualFold(pDetails.Email, lTestEmail)) {
			lErr = otp.SendOtptoEmail(lClientId, "Email", htmlInput, pDebug)
			if lErr != nil {
				return lRespStruct, helpers.ErrReturn(lErr)
			}
		}
		lRespStruct.EncEmail, lErr = common.GetEncryptedemail(pDetails.Email)
		if lErr != nil {
			return lRespStruct, helpers.ErrReturn(lErr)
		}
	} else {
		if strings.ToUpper(common.MobileOtpSend) != "N" && !(strings.EqualFold(lTestAllow, "Y") && strings.EqualFold(pDetails.Mobile, lTestMobile)) {
			lOtptemplet := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "MobileParth")
			lErr = otp.SendOtptoMobile(r, lClientId, lOtp, pDetails.Mobile, "SMS", lOtptemplet, pDebug)
			if lErr != nil {
				return lRespStruct, helpers.ErrReturn(lErr)
			}
		}
		lRespStruct.EncMobile, lErr = common.GetEncryptedMobile(pDetails.Mobile)
		if lErr != nil {
			return lRespStruct, helpers.ErrReturn(lErr)
		}

	}

	//----------------------------------------------------------------------------

	if !strings.EqualFold(common.AppRunMode, "prod") {
		lRespStruct.EncEmail = lRespStruct.EncEmail + "##" + lOtp
	}

	pDebug.Log(helpers.Details, "encrytedval:", lRespStruct.EncEmail)

	//-----------------------------------------------------------------------------

	//----------------------------------------------------------------------------

	OtpInput.ClientID = lClientId
	OtpInput.LoggedBy = lLoggedBy
	OtpInput.OTP = lOtp
	OtpInput.SendTo = fmt.Sprintf("%s@@%s", pDetails.Mobile, pDetails.Email)
	OtpInput.SendToType = pDetails.OtpType
	OtpInput.Process = pDetails.Process

	pDebug.Log(helpers.Details, "OtpInput", OtpInput)

	lRespStruct.InsertedID, lErr = LogOtp(OtpInput, pDebug)

	if lErr != nil {
		return lRespStruct, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "InsertedID", lRespStruct.InsertedID)
	pDebug.Log(helpers.Statement, "SendOtp(-)")

	return lRespStruct, nil
}

func EncryptString(giventype string, value string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "EncryptString(+)")

	var encrytedval string
	var lErr error
	if giventype == "EMAIL" {
		encrytedval, lErr = common.GetEncryptedemail(value)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
		return encrytedval, nil
	}
	encrytedval, lErr = common.GetEncryptedMobile(value)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "EncryptString(-)")

	return encrytedval, nil
}

//----------------------------------------------------------------------------------
// function to log the OTP in existing table
//----------------------------------------------------------------------------------

func LogOtp(OtpInput LogOtpStruct, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "LogOtp(+)")

	sqlString := `Insert into  otplog (type,sentTo ,otp ,validated ,ClientId,  
				      process ,otpExipry, createdDate, updatedDate, createdBy, UpdatedBy)
	                  VALUES (?, ?, ?, 'N', ?,  ?, date_add(NOW(),interval 30 minute), NOW(),NOW(), ?, ?)`
	lInsertRes, lErr := ftdb.MariaEKYCPRD_GDB.Exec(sqlString, OtpInput.SendToType, OtpInput.SendTo, OtpInput.OTP,
		OtpInput.ClientID, OtpInput.Process, OtpInput.LoggedBy, OtpInput.LoggedBy)

	if lErr != nil {

		return "", helpers.ErrReturn(lErr)
	}
	lReturnId, lErr := lInsertRes.LastInsertId()
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)

	}

	lInsertedID := strconv.Itoa(int(lReturnId))

	pDebug.Log(helpers.Details, "insertedID:", lInsertedID)
	pDebug.Log(helpers.Statement, "LogOtp(-)")

	return lInsertedID, nil
}
