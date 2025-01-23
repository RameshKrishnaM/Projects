package emailUtil

import (
	"errors"
	"fcs23pkg/ftdb"
	"fcs23pkg/tomlconfig"
	"log"
	"net/smtp"
	"strings"
)

// VoucherNo
// VoucherDate
// ClientId
// Amount

type EmailInput struct {
	//From        string
	FromRaw     string
	FromDspName string
	ReplyTo     string
	ToEmailId   string
	Subject     string
	Body        string
}

type loginAuth struct {
	username, password string
}

func LoginAuth(username, password string) smtp.Auth {
	return &loginAuth{username, password}
}

func (a *loginAuth) Start(server *smtp.ServerInfo) (string, []byte, error) {
	return "LOGIN", []byte(a.username), nil
}

func (a *loginAuth) Next(fromServer []byte, more bool) ([]byte, error) {
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

func SendEmail(input EmailInput, ReqSource string) error {
	log.Println("SendEmail+")


	account := tomlconfig.GtomlConfigLoader.GetValueString("emailconfig", "Account")
	pwd := tomlconfig.GtomlConfigLoader.GetValueString("emailconfig", "Pwd")
	url := tomlconfig.GtomlConfigLoader.GetValueString("emailconfig", "Url")

	ToIDArr := strings.Split(input.ToEmailId, ",")

	mime := "MIME-version: 1.0;\nContent-Type: text/html; charset=\"UTF-8\";\n\n"
	msg := "From: " + input.FromDspName + "<" + input.FromRaw + ">\n" +
		"To: " + strings.Join(ToIDArr, ",") + "\n" +
		"reply-to: " + input.ReplyTo + "\n" +
		"Subject: " + input.Subject + "\n" + mime +
		input.Body

	auth := LoginAuth(account, pwd)

	err := smtp.SendMail(url, auth, input.FromRaw, ToIDArr, []byte(msg))
	if err != nil {
		log.Println(err.Error())
		return err
	} else {
		err := emailLog(input, ReqSource, url)
		if err != nil {
			log.Println(err)
			return err
		}
	}

	log.Println("SendEmail-")
	return nil
}

func emailLog(input EmailInput, ReqSource string, Url string) error {
	log.Println("emailLog+")

	// FromDspName := strings.Split(fmt.Sprintf("%v", config.(map[string]interface{})["From"]), " ")[0]
	// FromRaw := fmt.Sprintf("%v", config.(map[string]interface{})["FromRaw"])
	// ReplyTo := fmt.Sprintf("%v", config.(map[string]interface{})["ReplyTo"])
	//	Subject := fmt.Sprintf("%v", config.(map[string]interface{})["Subject"])
	//Url := fmt.Sprintf("%v", config.(map[string]interface{})["Url"])

	sqlString := `Insert into  emaillog (FromId,ToId ,
			Subject ,Body , CreationDate, SentDate ,Status, EmailServer, FromDspName, Requested_Source, ReplyTo)
		VALUES (?, ?, ?, ?, NOW(),  NOW(),'SENT', ?,?, ?, ?)`
	_, err := ftdb.MariaFTPRD_GDB.Exec(sqlString, input.FromRaw, input.ToEmailId, input.Subject, input.Body, Url, input.FromDspName, ReqSource, input.ReplyTo)
	if err != nil {
		log.Println(err)
		return err
	} else {
		log.Println("Inserted Successfully")
	}

	log.Println("emailLog-")
	return nil

}
