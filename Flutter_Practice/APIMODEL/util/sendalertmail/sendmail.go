package sendalertmail

import (
	"bytes"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/emailSrv"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/emailUtil"
	"log"
	"strings"
	"text/template"
	"time"
)

type IntegrationError struct {
	Sno          int
	ClientId     string
	Response     string
	RejectReason string
}

type AlertStruct struct {
	CDSLRejectAlert []IntegrationError
	Header          string
	Content         string
}

// Send email to prod support if there is any Rejection in Form Integration [CDSL].
func CommonAlertMail(pDebug *helpers.HelperStruct, pSource string, dynamicEmailValues AlertStruct, pSubject, pToEmail string) error {
	log.Println("CommonAlertMail (+)")

	if pDebug == nil {
		pDebug = new(helpers.HelperStruct)
		pDebug.Init()
	}

	var tpl bytes.Buffer
	var lEmailRec emailUtil.EmailInput

	lCommonMailTemplate := tomlconfig.GtomlConfigLoader.GetValueString("commonhtmlpath", "CommonMailTemplate")

	lTemp, lErr := template.ParseFiles(lCommonMailTemplate)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CAM001", lErr.Error())
		return lErr
	} else {
		lTemp.Execute(&tpl, dynamicEmailValues)
		lEmailbody := tpl.String()
		lEmailRec.Body = lEmailbody
		lEmailRec.FromRaw = tomlconfig.GtomlConfigLoader.GetValueString("emailconfig", "FromRaw")
		lEmailRec.FromDspName = tomlconfig.GtomlConfigLoader.GetValueString("alertconfig", "FromDSPName")
		lEmailRec.ReplyTo = tomlconfig.GtomlConfigLoader.GetValueString("emailconfig", "ReplyTo")
		lSource := "INSTAKYC"

		lDt := time.Now().Format("02/Jan/2006 3:04:05 PM")

		// 	//fetch details from coresettings

		lEmailRec.Subject = pSubject + " " + lDt
		// lEmailRec.FromRaw = coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, lEmailRec.FromRaw)
		// lEmailRec.FromDspName = coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, lEmailRec.FromDspName)
		// lEmailRec.ReplyTo = coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, lEmailRec.ReplyTo)
		// lEmailRec.ToEmailId = coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, pToEmail)

		pToEmailArr := strings.Split(pToEmail, ",")
		pDebug.Log(helpers.Statement, "pToEmail --> ", pToEmailArr)
		lEMailServiceReq := emailSrv.EmailRequest{
			FromDspName: lEmailRec.FromDspName,
			FromRaw:     lEmailRec.FromRaw,
			ReplyTo:     lEmailRec.ReplyTo,
			To:          pToEmailArr,
			Subject:     lEmailRec.Subject,
			Body:        lEmailRec.Body,
			Source:      lSource,
		}
		lErr = emailSrv.SendMail(pDebug, lEMailServiceReq)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CAM002", lErr.Error())
			return helpers.ErrReturn(lErr)
		}
		lErr = EmailLog(lEMailServiceReq, pSource, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CAM003", lErr.Error())
		}
	}
	pDebug.Log(helpers.Statement, "CommonAlertMail (-)")
	return nil
}

func EmailLog(input emailSrv.EmailRequest, ReqSource string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "EmailLog +")

	lTo := strings.Join(input.To, ",")

	sqlString := `Insert into  emaillog (FromId,ToId ,
			Subject ,Body , CreationDate, SentDate ,Status, EmailServer, FromDspName,ReplyTo,Requested_Source)
		VALUES (?, ?, ?, ?, NOW(),  NOW(),'SENT', ?,?,?,?)`

	_, lErr := ftdb.MariaEKYCPRD_GDB.Exec(sqlString, input.FromRaw, lTo, input.Subject, input.Body, "", input.FromDspName, input.ReplyTo, ReqSource)
	if lErr != nil {
		common.LogError("CommonAlertMail.Email", "(EEL01)", lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "EmailLog -")
	return nil

}
