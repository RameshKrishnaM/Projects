package email

import (
	"errors"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/adminAlert"
	"fcs23pkg/tomlconfig"
	"net/smtp"
)

type CsvStruct struct {
	Column1 string
	Column2 string
}

type loginAuthStruct struct {
	username, password string
}

type ClientdetailStruct struct {
	ClientId   string
	ClientName string
	EmailId    string
	Otp        string
	Reason     string
}

type DynamicEmailStruct struct {
	Name     string
	Otp      string
	ClientId string
	Reason   string
}
type EmailStruct struct {
	Body    string
	EmailId string
	Subject string
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

func SendEmail(pInput EmailStruct, pReqSource string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "SendEmail (+)")

	lFrom := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "From")
	lFromraw := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "FromRaw")
	lReplyto := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "ReplyTo")
	//subject := fmt.Sprintf("%v", config.(map[string]interface{})["Subject"])

	lAccount := tomlconfig.GtomlConfigLoader.GetValueString("emailconfig", "Account")
	lPwd := tomlconfig.GtomlConfigLoader.GetValueString("emailconfig", "Pwd")
	// lUrl := tomlconfig.GtomlConfigLoader.GetValueString("emailconfig", "Url")
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("emailconfig", "SMTPUrl")

	lMime := "MIME-version: 1.0;\nContent-Type: text/html; charset=\"UTF-8\";\n\n"
	lMsg := "From: " + lFrom + "\n" +
		"To: " + pInput.EmailId + "\n" +
		"reply-to: " + lReplyto + "\n" +
		"Subject: " + pInput.Subject + "\n" + lMime +
		pInput.Body

	lAuth := LoginAuth(lAccount, lPwd)

	lErr := smtp.SendMail(lUrl, lAuth, lFromraw, []string{pInput.EmailId}, []byte(lMsg))
	if lErr != nil {
		lErr = adminAlert.SendAlertMsg("Email", "(ESE02)", "emailUtil263", pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)

		}
		return helpers.ErrReturn(lErr)
	}
	lErr = emailLog(pInput, pReqSource, pDebug)
	if lErr != nil {
		return helpers.ErrReturn(lErr)

	}

	pDebug.Log(helpers.Statement, "SendEmail (-)")

	return nil
}
