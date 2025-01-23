package adminAlert

import (
	"bytes"
	"encoding/json"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fmt"
	"html/template"
	"io/ioutil"
	"net/http"
	"strings"
	"time"
)

type DynamicEmailStrings struct {
	ErrorCode string
	EndPoint  string
	Source    string
}

type alertInput struct {
	Source   string `json:"source"`
	Msg      string `json:"msg"`
	EndPoint string `json:"endPoint"`
}

type alertResp struct {
	Status string `json:"status"`
	ErrMsg string `json:"errMsg"`
}

func AdminAlert(w http.ResponseWriter, r *http.Request, pDebug *helpers.HelperStruct) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)

	(w).Header().Set("Access-Control-Allow-Origin", "*")
	(w).Header().Set("Access-Control-Allow-Methods", "PUT")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	w.WriteHeader(200)
	lDebug.Log(helpers.Statement, "AdminAlert(+)")

	if strings.EqualFold(r.Method, "PUT") {
		lStatus, lErr := adminSms(r, lDebug)
		if lErr != nil {
			fmt.Fprintf(w, helpers.GetError_String("ADMIN ERROR", lErr.Error()))
		} else {
			fmt.Fprintf(w, string(lStatus))

		}
	}

}

func adminSms(r *http.Request, pDebug *helpers.HelperStruct) (string, error) {

	var lInput alertInput
	var lResp alertResp

	lResp.Status = "S"

	lBody, lErr := ioutil.ReadAll(r.Body)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal(lBody, &lInput)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	lErr = SendAlertMsg(lInput.Source, lInput.Msg, lInput.EndPoint, pDebug)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	lData, lErr := json.Marshal(lResp)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "AdminAlert(-)")
	return string(lData), nil
}

func SendAlertMsg(pSource string, pMsg string, pUrl string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "SendAlertMsg+")
	pDebug.Log(helpers.Details, "Source:", pSource)

	var lEndPoint string

	if strings.Contains(pUrl, "/") {
		lStrArr := strings.Split(pUrl, "/")
		//alertSource := Source + " EndPoint: /" + StrArr[len(StrArr)-1]

		pDebug.Log(helpers.Details, lStrArr[len(lStrArr)-1])
		lEndPoint = lStrArr[len(lStrArr)-1]
		if lEndPoint == "" {
			lEndPoint = lStrArr[len(lStrArr)-2]
		}

	} else {
		lEndPoint = pUrl
	}

	if pSource != "SMS" {

		lErr := SMS(pMsg, pSource, lEndPoint, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}

	}
	if pSource != "Email" {
		lErr := Email(pMsg, pSource, pUrl, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "SendAlertMsg-")
	return nil
}

func Email(pMsg string, pSource string, pEndPoint string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "Email+")

	var lTpl bytes.Buffer
	var lDynamicEmailValues DynamicEmailStrings
	lDynamicEmailValues.ErrorCode = pMsg
	lDynamicEmailValues.Source = pSource
	lDynamicEmailValues.EndPoint = pEndPoint

	lEmailId := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "To")

	AdminAlertHtmlPath := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "AdminAlertHtmlPath")

	lTemp, lErr := template.ParseFiles(AdminAlertHtmlPath) // change this
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lTemp.Execute(&lTpl, lDynamicEmailValues)
	lEmailbody := lTpl.String()
	lErr = SendEmail(lEmailbody, lEmailId, pSource, pDebug)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "Email-")
	return nil
}

func SMS(pMsg string, pSource string, pEndPoint string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "SMS+")

	var lInput SmsMsgTypeStruct
	var r *http.Request

	lCurrentTime := time.Now()
	//fmt.Println()

	AdminAlertSmsTemplateCode := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "AdminAlertSms")

	lInput.Param1 = "/" + pEndPoint
	lInput.Param2 = lCurrentTime.String()[:19] + " And " + pMsg
	lInput.Param3 = pSource

	lInput.ClientId = ""
	lInput.TemplateCode = AdminAlertSmsTemplateCode
	lInput.Mobile = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "SendTo")

	lErr := SmsMessage(r, lInput, pSource, pDebug)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "SMS-")
	return nil

}

type ClientDetailStruct struct {
	Process string
	Sendto  string
}

//-------------------------------------------------------
//function gets client details for the given client id
//-------------------------------------------------------
func GetClientDetails(pDebug *helpers.HelperStruct) (ClientDetailStruct, error) {
	pDebug.Log(helpers.Statement, "GetClientDetails(+)")
	// log.Println(ID)
	var DataRec ClientDetailStruct
	//open a db connection


	DataRec.Process = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Process")
	DataRec.Sendto = pDebug.Reference

	pDebug.Log(helpers.Details, "msg", DataRec)
	pDebug.Log(helpers.Statement, "GetClientDetails(-)")

	return DataRec, nil
}
