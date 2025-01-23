package adminAlert

import (
	"errors"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"net/smtp"
	"strings"
)

type loginAuthStruct struct {
	username, password string
}

func LoginAuth(username, password string) smtp.Auth {
	return &loginAuthStruct{username, password}
}

func (a *loginAuthStruct) Start(server *smtp.ServerInfo) (string, []byte, error) {
	return "LOGIN", []byte(a.username), nil
}

func (a *loginAuthStruct) Next(fromServer []byte, more bool) ([]byte, error) {
	if more {
		switch string(fromServer) {
		case "Username:":
			return []byte(a.username), nil
		case "Password:":
			return []byte(a.password), nil
		default:
			return nil, errors.New("unkown fromServer")
		}
	}
	return nil, nil
}

func SendEmail(pEmailbody string, pEmailId string, pReqSource string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "SendEmail+")


	//emailId = "sowmya@flattrade.in"

	lAccount := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Account")
	lPwd := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Pwd")

	lFrom := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "From")
	lFromraw := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "FromRaw")
	lReplyto := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "ReplyTo")
	lSubject := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "AdminSubject")
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Url")

	lMime := "MIME-version: 1.0;\nContent-Type: text/html; charset=\"UTF-8\";\n\n"
	lMsg := "From: " + lFrom + "\n" +
		"To: " + pEmailId + "\n" +
		"reply-to: " + lReplyto + "\n" +
		"Subject: " + lSubject + "\n" + lMime +
		pEmailbody

	lAuth := LoginAuth(lAccount, lPwd)

	lErr := smtp.SendMail(lUrl, lAuth, lFromraw, []string{pEmailId}, []byte(lMsg))
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = emailLog(pEmailbody, pReqSource, pDebug)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "SendEmail-")
	return nil
}
func emailLog(lEmailbody string, pReqSource string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "emailLog+")

	lFromDspName := strings.Split(tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "From"), " ")[0]
	lFromRaw := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "FromRaw")
	lReplyTo := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "ReplyTo")
	lSubject := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Subject")
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Url")

	lSqlString := `Insert into  emaillog (FromId,ToId ,
			Subject ,Body , CreationDate, SentDate ,Status, EmailServer, FromDspName, Requested_Source)
		VALUES (?, ?, ?, ?, NOW(),  NOW(),'SENT', ?,?, ?)`
	_, lErr := ftdb.MariaEKYCPRD_GDB.Exec(lSqlString, lFromRaw, lReplyTo, lSubject, lEmailbody, lUrl, lFromDspName, pReqSource)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "Inserted Successfully")

	pDebug.Log(helpers.Statement, "emailLog-")
	return nil

}
