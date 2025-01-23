package otp

import (
	"fcs23pkg/common"
	"fcs23pkg/coresettings"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
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

type HtmlStruct struct {
	Otp      string
	HtmlPath string
	Subject  string
	EmailId  string
	Reason   string
}

func SendOtp(pDetails UserdataStruct, r *http.Request, pDebug *helpers.HelperStruct) (string, string, error) {

	pDebug.Log(helpers.Statement, "SendOtp(+)")

	var OtpInput LogOtpStruct
	var htmlInput HtmlStruct

	lTestAllow := common.TestAllow
	lTestEmail := common.TestEmail
	lTestMobile := common.TestMobile
	lTestOTP := common.TestOTP

	pDebug.Log(helpers.Details, "details:", pDetails)

	lClientId := common.GetSetClient(pDetails.ClientID)
	lLoggedBy := common.GetLoggedBy(pDetails.ClientID)
	lOtp := common.GenerateOTP()
	if strings.EqualFold(lTestAllow, "Y") && (strings.EqualFold(pDetails.Sendto, lTestEmail) || strings.EqualFold(pDetails.Sendto, lTestMobile)) {
		lOtp = lTestOTP
	}
	pDebug.Log(helpers.Details, "otp:", lOtp)

	lEmailparth := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Emailparth")
	// lEmailSubject := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["EmailSubject"])


	lEmailSubject := tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig", "OTPSubject")
	lEmailSubject = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD_GDB, lEmailSubject)

	if strings.EqualFold(pDetails.Sendtotype, "EMAIL") {
		htmlInput.HtmlPath = lEmailparth
		htmlInput.Subject = lEmailSubject
		htmlInput.Otp = lOtp
		htmlInput.EmailId = pDetails.Sendto
		// if condition only for development purpose
		if strings.ToUpper(common.EmailOtpSend) != "N" && !(strings.EqualFold(pDetails.Sendto, lTestEmail) && strings.ToUpper(lTestAllow) == "Y") {
			err := SendOtptoEmail(lClientId, "Email", htmlInput, pDebug)
			if err != nil {
				return "", "", helpers.ErrReturn(err)
			}
		}
	} else {
		// if condition only for development purpose
		if strings.ToUpper(common.MobileOtpSend) != "N" && !(strings.EqualFold(pDetails.Sendto, lTestMobile) && strings.ToUpper(lTestAllow) == "Y") {
			lOtptemplet := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "MobileParth")
			lErr := SendOtptoMobile(r, lClientId, lOtp, pDetails.Sendto, "SMS", lOtptemplet, pDebug)
			if lErr != nil {
				return "", "", helpers.ErrReturn(lErr)
			}
		}
	}

	//----------------------------------------------------------------------------

	lEncrytedval, lErr := EncryptString(pDetails.Sendtotype, pDetails.Sendto, pDebug)
	if !strings.EqualFold(common.AppRunMode, "prod") {
		lEncrytedval = lEncrytedval + "##" + lOtp
	}

	if lErr != nil {
		return "", "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "encrytedval:", lEncrytedval)

	//-----------------------------------------------------------------------------

	//----------------------------------------------------------------------------

	OtpInput.ClientID = lClientId
	OtpInput.LoggedBy = lLoggedBy
	OtpInput.OTP = lOtp
	OtpInput.SendTo = pDetails.Sendto
	OtpInput.SendToType = pDetails.Sendtotype
	OtpInput.Process = pDetails.Process

	pDebug.Log(helpers.Details, "OtpInput", OtpInput)

	lInsertedID, lErr := LogOtp(OtpInput, pDebug)

	pDebug.Log(helpers.Details, "InsertedID", lInsertedID)
	if lErr != nil {
		return lEncrytedval, "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "SendOtp(-)")

	return lEncrytedval, lInsertedID, nil
}

func EncryptString(giventype string, value string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "EncryptString(+)")

	var encrytedval string
	var lErr error
	if strings.EqualFold(giventype, "EMAIL") {
		// encrytedval, lErr = common.GetEncryptedemail(value)
		encrytedval, lErr = common.NewGetEncryptedemail(value)
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
