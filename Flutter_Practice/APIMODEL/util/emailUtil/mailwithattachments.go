package emailUtil

import (
	"encoding/base64"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"net/smtp"
	"strings"
)

func SendEmailAttachment(pDebug *helpers.HelperStruct, pInput EmailInput, pProcessType, pFileName string, pFile []byte) (lErr error) {
	pDebug.Log(helpers.Statement, "SendEmailAttachment (+)")
	lEmailMsg := InstantCreatemsg(pInput, pFileName, pFile)

	lAccount := tomlconfig.GtomlConfigLoader.GetValueString("emailconfig", "Account")
	lPwd := tomlconfig.GtomlConfigLoader.GetValueString("emailconfig", "Pwd")
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("emailconfig", "Url")
	lAuth := LoginAuth(lAccount, lPwd)

	lErr = smtp.SendMail(lUrl, lAuth, pInput.FromRaw, strings.Split(pInput.ToEmailId, ","), []byte(lEmailMsg))
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = emailLog(pInput, pProcessType, lUrl)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "SendEmailAttachment (-)")
	return nil
}

func InstantCreatemsg(input EmailInput, pFileName string, pFile []byte) string {
	// pFilepath = "./file.png"
	// fmt.Println(" input.FromRaw:", input.FromRaw)
	msg := "From: " + input.FromDspName + "<" + input.FromRaw + ">\r\n" +
		"To: " + input.ToEmailId + "\r\n" +
		"Reply-To: " + input.ReplyTo + "\r\n" +
		"Subject: " + input.Subject + "\r\n" +
		"MIME-version: 1.0;\r\n" +
		"Content-Type: multipart/mixed; boundary=boundary\r\n\r\n" +
		"--boundary\r\n" +
		"Content-Type: text/html; charset=\"UTF-8\"\r\n\r\n" +
		input.Body + "\r\n"

	if strings.HasSuffix(pFileName, ".jpg") || strings.HasSuffix(pFileName, ".jpeg") {
		// log.Println("1")
		encode := base64.StdEncoding.EncodeToString(pFile)
		msg = msg + "--boundary\r\n" +
			"Content-Type: image/jpeg; name=\"" + pFileName + "\"\r\n" +
			"Content-Disposition: attachment; filename=\"" + pFileName + "\"\r\n" +
			"Content-Transfer-Encoding: base64\r\n\r\n" +
			encode + "\r\n" +
			"--boundary--\r\n"
	} else if strings.HasSuffix(pFileName, ".png") {
		// log.Println("2")
		encode := base64.StdEncoding.EncodeToString(pFile)
		msg = msg + "--boundary\r\n" +
			"Content-Type: image/png; name=\"" + pFileName + "\"\r\n" +
			"Content-Disposition: attachment; filename=\"" + pFileName + "\"\r\n" +
			"Content-Transfer-Encoding: base64\r\n\r\n" +
			encode + "\r\n" +
			"--boundary--\r\n"
	} else if strings.HasSuffix(pFileName, ".pdf") {
		// log.Println("3")
		encode := base64.StdEncoding.EncodeToString(pFile)
		msg = msg + "--boundary\r\n" +
			"Content-Type: application/pdf; name=\"" + pFileName + "\"\r\n" +
			"Content-Disposition: attachment; filename=\"" + pFileName + "\"\r\n" +
			"Content-Transfer-Encoding: base64\r\n\r\n" +
			encode + "\r\n" +
			"--boundary--\r\n"
	} else if strings.HasSuffix(pFileName, ".txt") || strings.HasSuffix(pFileName, ".text") {
		// log.Println("4")
		msg = msg + "--boundary\r\n" +
			"Content-Type: text/plain; name=\"" + pFileName + "\"\r\n" +
			"Content-Disposition: attachment; filename=\"" + pFileName + "\"\r\n" +
			string(pFile) + "\r\n" +
			"--boundary--\r\n"
	} else if strings.HasSuffix(pFileName, ".html") || strings.HasSuffix(pFileName, ".htm") {
		// log.Println("5")
		msg = msg + "--boundary\r\n" +
			"Content-Type: text/html; name=\"" + pFileName + "\"\r\n" +
			"Content-Disposition: attachment; filename=\"" + pFileName + "\"\r\n" +
			string(pFile) + "\r\n" +
			"--boundary--\r\n"
	} else if strings.HasSuffix(pFileName, ".zip") {
		// log.Println("6")
		encode := base64.StdEncoding.EncodeToString(pFile)
		msg = msg + "--boundary\r\n" +
			"Content-Type: application/zip; name=\"" + pFileName + "\"\r\n" +
			"Content-Disposition: attachment; filename=\"" + pFileName + "\"\r\n" +
			"Content-Transfer-Encoding: base64\r\n\r\n" +
			encode + "\r\n" +
			"--boundary--\r\n"
	} else if strings.HasSuffix(pFileName, ".csv") {
		// log.Println("7")
		msg = msg + "--boundary\r\n" +
			"Content-Type: text/csv; name=\"" + pFileName + "\"\r\n" +
			"Content-Disposition: attachment; filename=\"" + pFileName + "\"\r\n" +
			string(pFile) + "\r\n"
	} else if strings.HasSuffix(pFileName, ".xls") || strings.HasSuffix(pFileName, ".xlsx") {
		// log.Println("8")
		encode := base64.StdEncoding.EncodeToString(pFile)
		msg = msg + "--boundary123\r\n" +
			"Content-Type:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; name=\"" + pFileName + "\"\r\n" +
			"Content-Disposition: attachment; filename=\"" + pFileName + "\"\r\n" +
			"Content-Transfer-Encoding: base64\r\n\r\n" +
			encode + "\r\n"
	}

	return msg
}
