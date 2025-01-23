package email

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"strings"
)

func emailLog(lInput EmailStruct, pReqSource string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "emailLog (+)")

	lFromDspName := strings.Split(tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "From"), " ")[0]
	lFromRaw := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "FromRaw")
	lReplyTo := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "ReplyTo")
	//	Subject := fmt.Sprintf("%v", config.(map[string]interface{})["Subject"])
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Url")

	lSqlString := `Insert into  emaillog (FromId,ToId ,
			Subject ,Body , CreationDate, SentDate ,Status, EmailServer, FromDspName, ReplyTo, Requested_Source)
		VALUES (?, ?, ?, ?, NOW(),  NOW(),'SENT', ?,?,?, ?)`
	_, lErr := ftdb.MariaEKYCPRD_GDB.Exec(lSqlString, lFromRaw, lInput.EmailId, lInput.Subject, lInput.Body, lUrl, lFromDspName, lReplyTo, pReqSource)
	if lErr != nil {
		return helpers.ErrReturn(lErr)

	}
	pDebug.Log(helpers.Details, "Inserted Successfully")

	pDebug.Log(helpers.Statement, "emailLog (-)")
	return nil

}
