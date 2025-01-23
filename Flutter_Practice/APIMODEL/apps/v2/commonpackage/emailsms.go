package commonpackage

import (
	"bytes"
	"fcs23pkg/common"
	"fcs23pkg/coresettings"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/emailUtil"
	"fmt"
	"strings"
	"text/template"
)

type UserInfoStruct struct {
	Email, EmailTemplate, Mobile, SmsTemplate, UserName, ProcessType, FileName, SubjectType string
	EmailBodyData                                                                           interface{}
	File                                                                                    []byte
}

type EncryptStrStruct struct {
	lEnpEmail, lEnpSms string
}

// func SentMessage(pDebug *helpers.HelperStruct, r *http.Request, pType string, pUserInfo UserInfoStruct) (lEncRec EncryptStrStruct, lErr error) {
// 	pDebug.Log(helpers.Statement, "SentMessage (+)")

// 	if strings.EqualFold(pType, "") {
// 		return lEncRec, helpers.ErrReturn(fmt.Errorf("please Enter the process type"))
// 	}
// 	if strings.EqualFold(pUserInfo.UserName, "") {
// 		return lEncRec, helpers.ErrReturn(fmt.Errorf("user name is empty"))
// 	}
// 	if strings.EqualFold(pType, "SMS") {
// 		// lErr = SendSMS(pDebug, r, pUserInfo)
// 		// if lErr != nil {
// 		// 	return lEncRec, helpers.ErrReturn(lErr)
// 		// }
// 	} else if strings.EqualFold(pType, "Email") {
// 		lErr = SendEmail(pDebug, pUserInfo)
// 		if lErr != nil {
// 			return lEncRec, helpers.ErrReturn(lErr)
// 		}
// 	} else if strings.EqualFold(pType, "both") {
// 		// lErr = SendSMS(pDebug, r, pUserInfo)
// 		// if lErr != nil {
// 		// 	return lEncRec, helpers.ErrReturn(lErr)
// 		// }
// 		lErr = SendEmail(pDebug, pUserInfo)
// 		if lErr != nil {
// 			return lEncRec, helpers.ErrReturn(lErr)
// 		}
// 	}

// 	lEncRec, lErr = GenerateEncStr(pDebug, pUserInfo)
// 	if lErr != nil {
// 		return lEncRec, helpers.ErrReturn(lErr)
// 	}

// 	pDebug.Log(helpers.Statement, "SentMessage (-)")
// 	return lEncRec, nil
// }

func SendEmailWithAttachment(pDebug *helpers.HelperStruct, pUserInfo UserInfoStruct) (lEncRec EncryptStrStruct, lErr error) {
	lErr = EmailCheck(pDebug, pUserInfo)
	if lErr != nil {
		return lEncRec, helpers.ErrReturn(lErr)
	}
	var lEmailRec emailUtil.EmailInput
	var lTpl bytes.Buffer

	lTemp, lErr := template.ParseFiles(pUserInfo.EmailTemplate)
	if lErr != nil {
		return lEncRec, helpers.ErrReturn(lErr)
	}

	lTemp.Execute(&lTpl, pUserInfo.EmailBodyData)
	lEmailRec.Body = lTpl.String()

	//fetch details from toml
	lEmailRec.FromRaw = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig", "FromEmail")
	lEmailRec.FromDspName = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig", "FromDspName")
	lEmailRec.ReplyTo = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig", "ReplyTo")
	lEmailRec.Subject = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig", pUserInfo.SubjectType)
	lEmailRec.FromRaw = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD_GDB, lEmailRec.FromRaw)
	lEmailRec.FromDspName = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD_GDB, lEmailRec.FromDspName)
	lEmailRec.ReplyTo = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD_GDB, lEmailRec.ReplyTo)
	// lEmailRec.ReplyTo = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD, lEmailRec.ReplyTo)
	// lEmailRec.Subject = fmt.Sprintf("%s %s", pUserInfo.ProcessType, time.Now().Format("02/Jan/2006 3:04:05 PM"))
	lEmailRec.Subject = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD_GDB, lEmailRec.Subject)
	lEmailRec.ToEmailId = pUserInfo.Email
	// lEmailRec.ToEmailId = "saravanan.s@fcsonline.co.in"

	lErr = emailUtil.SendEmailAttachment(pDebug, lEmailRec, pUserInfo.ProcessType, pUserInfo.FileName, pUserInfo.File)
	if lErr != nil {
		return lEncRec, helpers.ErrReturn(lErr)
	}
	return GenerateEncStr(pDebug, pUserInfo)
}

// func SendSMS(pDebug *helpers.HelperStruct, r *http.Request, pUserInfo UserInfoStruct) (lErr error) {
// 	pDebug.Log(helpers.Statement, "SendSMS (+)")
// 	if strings.EqualFold(common.MobileOtpSend, "N") {
// 		return nil
// 	}
// 	lErr = SMSCheck(pDebug, pUserInfo)
// 	if lErr != nil {
// 		return helpers.ErrReturn(lErr)
// 	}
// 	lErr = otp.SendOtptoMobile(r, "ekyc", pUserInfo.AttachmentPath, pUserInfo.Mobile, "ekyc", pUserInfo.SmsTemplate, pDebug)
// 	if lErr != nil {
// 		return helpers.ErrReturn(lErr)
// 	}

// 	pDebug.Log(helpers.Statement, "SendSMS (-)")
// 	return nil
// }

func EmailCheck(pDebug *helpers.HelperStruct, pUserInfo UserInfoStruct) (lErr error) {
	pDebug.Log(helpers.Statement, "EmailCheck (+)")
	if strings.EqualFold(pUserInfo.Email, "") {
		return helpers.ErrReturn(fmt.Errorf("user email id is empty"))
	}
	if strings.EqualFold(pUserInfo.EmailTemplate, "") {
		return helpers.ErrReturn(fmt.Errorf("email template is empty"))
	}
	pDebug.Log(helpers.Statement, "EmailCheck (-)")
	return nil
}
func SMSCheck(pDebug *helpers.HelperStruct, pUserInfo UserInfoStruct) (lErr error) {
	pDebug.Log(helpers.Statement, "SMSCheck (+)")
	if strings.EqualFold(pUserInfo.Mobile, "") {
		return helpers.ErrReturn(fmt.Errorf("user mobile number is empty"))
	}
	if strings.EqualFold(pUserInfo.SmsTemplate, "") {
		return helpers.ErrReturn(fmt.Errorf("sms template is empty"))
	}
	pDebug.Log(helpers.Statement, "SMSCheck (-)")
	return nil
}

func GenerateEncStr(pDebug *helpers.HelperStruct, pUserInfo UserInfoStruct) (lEncRec EncryptStrStruct, lErr error) {
	pDebug.Log(helpers.Statement, "GenerateEncStr (+)")

	if !strings.EqualFold(pUserInfo.Mobile, "") {
		lEncRec.lEnpSms, lErr = common.GetEncryptedMobile(pUserInfo.Mobile)
		if lErr != nil {
			return lEncRec, helpers.ErrReturn(lErr)
		}
	}

	if !strings.EqualFold(pUserInfo.Email, "") {
		lEncRec.lEnpEmail, lErr = common.GetEncryptedemail(pUserInfo.Email)
		if lErr != nil {
			return lEncRec, helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "GenerateEncStr (-)")
	return lEncRec, nil
}
