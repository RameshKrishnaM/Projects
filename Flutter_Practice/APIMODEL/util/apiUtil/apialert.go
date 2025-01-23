package apiUtil

import (
	"bytes"
	"fcs23pkg/coresettings"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/emailUtil"
	"html/template"
	"time"
)

type AdminEmailAlertStruct struct {
	ErrorCode    string
	EndPoint     string
	Source       string
	ProgramNo    string
	AlertHeading string
}

func AdminEmailAlert(pDebug *helpers.HelperStruct, pTemplateData AdminEmailAlertStruct, pAppName string) error {
	pDebug.Log(helpers.Statement, "AdminEmailAlert(+)")

	var lEmailRec emailUtil.EmailInput
	var lTpl bytes.Buffer

	pTemplateData.AlertHeading = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig", "CreatedProgramName")
	pTemplateData.ProgramNo = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig", "CreatedProgramNo")

	lEmailPath := "./html/AdminAlert.html"

	lTemp, err := template.ParseFiles(lEmailPath)
	if err != nil {
		// log.Println("CLES01 ", err)
		return helpers.ErrReturn(err)
	}

	lTemp.Execute(&lTpl, pTemplateData)
	lEmailbody := lTpl.String()

	// var lEmailRec util.EmailLogType
	lEmailRec.Body = lEmailbody
	// lEmailRec.Action = constant.INSERT

	//fetch details from toml
	lEmailRec.FromRaw = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig","FromEmail")
	lEmailRec.FromDspName = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig","FromDspName")
	// lEmailRec.EmailServer = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig","EmailServer")
	lEmailRec.ToEmailId = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig","MgrGrpEmail")
	lEmailRec.ReplyTo = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig","ReplyTo")
	// lEmailRec.CreatedProgram = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig","CreatedProgramNo")
	lEmailRec.Subject = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig","EmailSubject")

	dt := time.Now().Format("02/Jan/2006 3:04:05 PM")

	//fetch details from coresettings

	lEmailRec.Subject = coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, lEmailRec.Subject) + " " + dt
	lEmailRec.FromRaw = coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, lEmailRec.FromRaw)
	lEmailRec.FromDspName = coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, lEmailRec.FromDspName)
	// lEmailRec.EmailServer = coresettings.GetCoreSettingValue(ftdb.NewKycDB, lEmailRec.EmailServer)
	lEmailRec.ToEmailId = coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, lEmailRec.ToEmailId)
	lEmailRec.ReplyTo = coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, lEmailRec.ReplyTo)
	err = emailUtil.SendEmail(lEmailRec, pAppName)
	if err != nil {
		// log.Println("CLES02 ", err)
		return helpers.ErrReturn(err)
	}
	pDebug.Log(helpers.Statement, "AdminEmailAlert(-)")
	// }
	return nil
}
