package adminAlert

import (
	"bytes"
	"encoding/json"
	"fcs23pkg/apigate"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
	// "github.com/BurntSushi/toml"
)

type smsConfigStruct struct {
	SmsParam smsParamStruct
}
type tokenStruct struct {
	Token      string `json:"token"`
	ExpiryDate string `json:"expiryDate"`
}

type smsParamStruct struct {
	SmsUserName   string
	SmsPassword   string
	SmsTokenLink  string
	SmsAPILink    string
	SmsMsgVersion string
	SmsSender     string
}

type smsAddressStruct struct {
	FROM string `json:"@FROM"`
	TO   string `json:"@TO"`
	SEQ  string `json:"@SEQ"`
	TAG  string `json:"@TAG"`
}

type smsMsgStruct struct {
	UDH      string             `json:"@UDH"`
	CODING   string             `json:"@CODING"`
	TEXT     string             `json:"@TEXT"`
	PROPERTY string             `json:"@PROPERTY"`
	ID       string             `json:"@ID"`
	ADDRESS  []smsAddressStruct `json:"ADDRESS"`
}
type smsTypeStruct struct {
	Version string `json:"@VER"`
	User    struct {
		UserName string `json:"@USERNAME"`
		PassWord string `json:"@PASSWORD"`
	} `json:"USER"`
	DLR struct {
		URL string `json:"@URL"`
	} `json:"DLR"`
	SMS []smsMsgStruct `json:"SMS"`
}

type msgResStruct struct {
	MESSAGEACK struct {
		GUID struct {
			SUBMITDATE string `json:"SUBMITDATE"`
			GUID       string `json:"GUID"`
			ID         string `json:"ID"`
			ERROR      struct {
				SEQ  int    `json:"SEQ"`
				CODE int    `json:"CODE"`
				Desc string `json:"Desc"`
			} `json:"ERROR"`
		} `json:"GUID"`
		CODE string `json:"CODE"`
	} `json:"MESSAGEACK"`
}

type SmsMsgTypeStruct struct {
	PhoneNumber  string `json:"phonenumber"`
	ClientId     string `json:"clientid"`
	SentFrom     string `json:"sentfrom"`
	TemplateCode string `json:"tempaltecode"`
	SendOTP      string `json:"sendotp"`
	ReturnOTP    string `json:"returnotp"`
	Param1       string `json:"param1"`
	Param2       string `json:"param2"`
	Param3       string `json:"param3"`
	Param4       string `json:"param4"`
	Param5       string `json:"param5"`
	Param6       string `json:"param6"`
	Param7       string `json:"param7"`
	Realip       string
	Forwardedip  string
	Method       string
	Path         string
	Host         string
	Remoteaddr   string
	Apitoken     string
	OTP          string
	Name         string
	Mobile       string
	Email        string
}

type smsDetailStruct struct {
	Msg      string
	Header   string
	UserName string
	Password string
}

func SmsMessage(r *http.Request, pSmsMessage SmsMsgTypeStruct, pReqSource string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "SmsMessage (+)")

	var lConfig smsConfigStruct

	lConfig.SmsParam.SmsUserName = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "SmsUserName")
	lConfig.SmsParam.SmsPassword = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "SmsPassword")
	lConfig.SmsParam.SmsTokenLink = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "SmsTokenLink")
	lConfig.SmsParam.SmsAPILink = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "SmsAPILink")
	lConfig.SmsParam.SmsMsgVersion = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "SmsMsgVersion")
	lConfig.SmsParam.SmsSender = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "SmsSender")

	// if _, lErr := toml.DecodeFile("./toml/otpconfig.toml", &lConfig); lErr != nil {
	// 	return helpers.ErrReturn(lErr)
	// }

	lReqDtl := apigate.GetRequestorDetail(pDebug, r)

	pSmsMessage.Realip = lReqDtl.RealIP
	pSmsMessage.Forwardedip = lReqDtl.ForwardedIP
	pSmsMessage.Method = lReqDtl.Method
	pSmsMessage.Path = lReqDtl.Path
	pSmsMessage.Host = lReqDtl.Host
	pSmsMessage.Remoteaddr = lReqDtl.RemoteAddr

	pDebug.Log(helpers.Details, "pSmsMessage :", pSmsMessage)

	if pSmsMessage.SentFrom != "" && pSmsMessage.TemplateCode != "" {
		if pSmsMessage.PhoneNumber != "" || pSmsMessage.ClientId != "" {
			//by default set the received phonenumber to mobile
			//number in mobile field will get the sMS
			pSmsMessage.Mobile = pSmsMessage.PhoneNumber
			//if client Id passed and phone number not passed, then
			//derive client details
			//	var smsResponse SmsResponseType
			// if pSmsMessage.ClientId != "" && pSmsMessage.PhoneNumber == "" {
			// 	//getclient detail
			// 	db, lErr := ftdb.LocalDbConnect(ftdb.MainDB)
			// 	if lErr != nil {
			// 		return helpers.ErrReturn(lErr)
			// 	}
			// 	defer db.Close()

			// }
			lErr := triggerSMS(pSmsMessage, lConfig, pReqSource, pDebug)
			if lErr != nil {
				return helpers.ErrReturn(lErr)

			}
		}
	}

	pDebug.Log(helpers.Statement, "SmsMessage (-)")

	return nil
}

//-------------------------------------------------------
//send sms message
//-------------------------------------------------------
func triggerSMS(pSmsMessage SmsMsgTypeStruct, pConfig smsConfigStruct, pReqSource string, pDebug *helpers.HelperStruct) error {

	pDebug.Log(helpers.Statement, "triggerSMS (+)")
	pDebug.Log(helpers.Details, "smsMessagesmsMessage :", pSmsMessage.PhoneNumber)

	interfaceResp := ""
	reqJson := ""
	var smsResp msgResStruct
	//if mobile number is provided, then send SMS
	if pSmsMessage.Mobile != "" {
		//get smsMessage
		smsMsg, lErr := getSMSMessage2(pSmsMessage.TemplateCode, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)

		}
		//get dynamic values in the smsMsg
		smsMsg.Msg = setParams(smsMsg.Msg, pSmsMessage, pDebug)
		//send SMS
		// interfaceResp, smsResp, reqJson, lErr = sendSMS2(pConfig.SmsParam.SmsSender, pSmsMessage.Mobile, smsMsg, "TEXT1", pConfig, pDebug)
		// if lErr != nil {
		// 	return helpers.ErrReturn(lErr)
		// }
		// err1 := adminAlert.SendAlertMsg("SMS", "(STS03)", "smsUtil", pDebug)
		// if err1 != nil {
		// 	return helpers.ErrReturn(lErr)

		// }
		interfaceResp, smsResp, reqJson, lErr = sendSMS2(pConfig.SmsParam.SmsSender, pSmsMessage.Mobile, smsMsg, "TEXT1", pConfig, pDebug)
		if lErr != nil {
			common.LogError("smsUtil.triggerSMS", "(STS03)", lErr.Error())
			lErr1 := SendAlertMsg("SMS", "(STS03)", "smsUtil", pDebug)
			if lErr1 != nil {
				common.LogError("emailUtil.SendEmail", "(STS04)", lErr1.Error())
			}
			return helpers.ErrReturn(lErr)
		}
		sqlString := `insert into smsmessagelog(PhoneNumber,ClientId,SentFrom,TemplateCode,Param1,Param2,Param3,Param4,Param5,Param6,Param7,
						createddate,smsmessagereceived,smsmessagesent,smsresponse,realip,forwardedip,methods,paths,host,remoteaddr,apitoken,SendOTP,
						ReturnOTP,otp,clientname,mobile,email,guid, Requested_Source, ReqJson) values (?, ?, ?, ?, ?, ?, ?, ?, ?,?, ?,Now(), ?,?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`
		_, lErr = ftdb.MariaEKYCPRD_GDB.Exec(sqlString, pSmsMessage.PhoneNumber, pSmsMessage.ClientId, pSmsMessage.SentFrom, pSmsMessage.TemplateCode, pSmsMessage.Param1,
			pSmsMessage.Param2, pSmsMessage.Param3, pSmsMessage.Param4, pSmsMessage.Param5, pSmsMessage.Param6, pSmsMessage.Param7, "", smsMsg.Msg, interfaceResp,
			pSmsMessage.Realip, pSmsMessage.Forwardedip, pSmsMessage.Method, pSmsMessage.Path, pSmsMessage.Host, pSmsMessage.Remoteaddr, pSmsMessage.Apitoken,
			pSmsMessage.SendOTP, pSmsMessage.ReturnOTP, pSmsMessage.OTP, pSmsMessage.Name, pSmsMessage.Mobile, pSmsMessage.Email, smsResp.MESSAGEACK.GUID.GUID, pReqSource, reqJson)
		if lErr != nil {
			return helpers.ErrReturn(lErr)

		}

	}
	pDebug.Log(helpers.Statement, "triggerSMS (-)")

	return nil
}

//--------------------------------------------------------------------------
//function retrives sms message from db for the given message template code
//--------------------------------------------------------------------------
func getSMSMessage2(pSmsTemplate string, pDebug *helpers.HelperStruct) (smsDetailStruct, error) {
	pDebug.Log(helpers.Statement, "getSMSMessage2 (+)")

	var smsDetailRec smsDetailStruct

	lSqlString := `select xt.templateMessage,xt.smsheader,xa.smsaccount,xa.smspassword from xxsms_template xt, 
	xxsms_accounts xa where xt.smsaccount = xa.smsaccount and xt.enabled = 'Y' and xa.enabled='Y' and xt.templateCode = '` + pSmsTemplate + `'`
	lRows, lErr := ftdb.MariaEKYCPRD_GDB.Query(lSqlString)
	if lErr != nil {
		return smsDetailRec, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	//-----------Before Looping records----------
	for lRows.Next() {
		lErr := lRows.Scan(&smsDetailRec.Msg, &smsDetailRec.Header, &smsDetailRec.UserName, &smsDetailRec.Password)
		if lErr != nil {
			return smsDetailRec, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "getSMSMessage2 (-)")

	return smsDetailRec, nil
}

//-------------------------------------------------------
//function set dynamic values in the sms message
//-------------------------------------------------------
func setParams(smsMsg string, smsMessage SmsMsgTypeStruct, pDebug *helpers.HelperStruct) string {
	pDebug.Log(helpers.Statement, "setParams (+)")

	smsMsg = strings.Replace(smsMsg, "{#otp#}", smsMessage.OTP, 10)
	smsMsg = strings.Replace(smsMsg, "{#param1#}", smsMessage.Param1, 10)
	smsMsg = strings.Replace(smsMsg, "{#param2#}", smsMessage.Param2, 10)
	smsMsg = strings.Replace(smsMsg, "{#param3#}", smsMessage.Param3, 10)
	smsMsg = strings.Replace(smsMsg, "{#param4#}", smsMessage.Param4, 10)
	smsMsg = strings.Replace(smsMsg, "{#param5#}", smsMessage.Param5, 10)
	smsMsg = strings.Replace(smsMsg, "{#param6#}", smsMessage.Param6, 10)
	smsMsg = strings.Replace(smsMsg, "{#param7#}", smsMessage.Param7, 10)

	pDebug.Log(helpers.Details, "smsMsg :", smsMsg)

	pDebug.Log(helpers.Statement, "setParams (-)")

	return smsMsg
}

func sendSMS2(pFrom string, pTo string, pMsg smsDetailStruct, pUniqueRef string, pConfig smsConfigStruct, pDebug *helpers.HelperStruct) (string, msgResStruct, string, error) {
	pDebug.Log(helpers.Statement, "sendSMS2 (+)")

	var smsMsgRec smsTypeStruct
	var smsTxtRec smsMsgStruct
	var smsToRec smsAddressStruct
	var rspMsgRec msgResStruct
	var lAny interface{}
	smsMsgRec.Version = pConfig.SmsParam.SmsMsgVersion

	smsTxtRec.UDH = "0"
	smsTxtRec.CODING = "1"
	smsTxtRec.PROPERTY = "0"
	smsTxtRec.ID = pUniqueRef
	smsTxtRec.TEXT = pMsg.Msg
	smsToRec.FROM = pMsg.Header
	smsToRec.TO = pTo
	smsToRec.SEQ = "1"
	smsTxtRec.ADDRESS = append(smsTxtRec.ADDRESS, smsToRec)
	smsMsgRec.SMS = append(smsMsgRec.SMS, smsTxtRec)

	pDebug.Log(helpers.Details, "smsMsgRec :", smsMsgRec)

	lUrla := pConfig.SmsParam.SmsAPILink

	lPostBody, lErr := json.Marshal(smsMsgRec)
	if lErr != nil {
		return "", rspMsgRec, "", helpers.ErrReturn(lErr)
	}
	lPostJsonBody := bytes.NewBuffer(lPostBody)
	lReqJson := string(lPostBody)

	lReqs, lErr := http.NewRequest("POST", lUrla, lPostJsonBody)
	if lErr != nil {
		return "", rspMsgRec, lReqJson, helpers.ErrReturn(lErr)

	}
	lToken, lErr := getTokenFromCoresetting(pDebug)
	if lErr != nil {
		return "", rspMsgRec, lReqJson, helpers.ErrReturn(lErr)

	}
	if lToken == "" {
		lToken, lErr = getToken2(pMsg.UserName, pMsg.Password, pConfig, pDebug)
		if lErr != nil {
			return "", rspMsgRec, lReqJson, helpers.ErrReturn(lErr)

		}
	}
	var lBearer = "Bearer " + lToken
	lReqs.Header.Add("Authorization", lBearer)
	lReqs.Header.Add("Content-Type", "application/json")
	lEesponse, lErr := apiUtil.GClient.Do(lReqs)
	if lErr != nil {
		return "", rspMsgRec, lReqJson, helpers.ErrReturn(lErr)

	}
	lBody, lErr := ioutil.ReadAll(lEesponse.Body)
	if lErr != nil {
		return "", rspMsgRec, lReqJson, helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal(lBody, &lAny)
	if lErr != nil {
		return "", rspMsgRec, lReqJson, helpers.ErrReturn(lErr)

	}
	lReturndata := fmt.Sprintf("%s", lAny)

	pDebug.Log(helpers.Details, "lAny :", lAny)

	lErr = json.Unmarshal(lBody, &rspMsgRec)
	if lErr != nil {
		return lReturndata, rspMsgRec, lReqJson, helpers.ErrReturn(lErr)

	}

	pDebug.Log(helpers.Statement, "sendSMS2 (-)")

	return lReturndata, rspMsgRec, lReqJson, nil
}
func getTokenFromCoresetting(pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "getTokenFromCoresetting (+)")

	var lToken string

	lSmsToken := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "SmsToken")

	lCoreString := `select (case when  DATEDIFF(CURDATE(), date(updatedDate)) < 7 then valueV else '' end) token
        from coresettings c
        where KEYV = '` + lSmsToken + `'`
	lRows, lErr2 := ftdb.MariaFTPRD_GDB.Query(lCoreString)
	if lErr2 != nil {
		common.LogError("smsUtil.getTokenFromCoresetting", "(STFC01)", lErr2.Error())
		return lToken, helpers.ErrReturn(lErr2)

	}
	//-----------Before Looping records----------
	defer lRows.Close()
	for lRows.Next() {
		lErr2 = lRows.Scan(&lToken)
		if lErr2 != nil {
			common.LogError("smsUtil.getTokenFromCoresetting", "(STFC02)", lErr2.Error())
			return lToken, helpers.ErrReturn(lErr2)

		}
	}

	pDebug.Log(helpers.Statement, "getTokenFromCoresetting (-)")

	return lToken, nil

}

func UpdateTokenInCoresetting(pDebug *helpers.HelperStruct, pToken string) error {
	pDebug.Log(helpers.Statement, "UpdateTokenInCoresetting (+)")

	lSmsToken := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "SmsToken")

	lCoreString := `update coresettings set  Valuev = ?, UpdatedBy='Autobot', updatedDate=Now() where KeyV=?`

	_, lErr := ftdb.MariaFTPRD_GDB.Exec(lCoreString, pToken, lSmsToken)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "UpdateTokenInCoresetting (-)")

	return nil
}

func getToken2(pUsername string, Ppassword string, pConfig smsConfigStruct, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "getToken2 (+)")
	var lToken tokenStruct
	//var config smsConfig
	lUrla := pConfig.SmsParam.SmsTokenLink //(PAN_Number:equals:" + pan + ")"

	lReqs, lErr := http.NewRequest("POST", lUrla, nil)
	if lErr != nil {
		return lToken.Token, helpers.ErrReturn(lErr)
	}
	lReqs.SetBasicAuth(pUsername, Ppassword)
	response, lErr := apiUtil.GClient.Do(lReqs)
	if lErr != nil {
		return lToken.Token, helpers.ErrReturn(lErr)
	}
	lBody, lErr := ioutil.ReadAll(response.Body)
	if len(lBody) > 0 {
		// if strings.Contains(string(lBody), "Error") {
		// 	var result string
		// 	indexA := strings.Index(string(lBody), "<body>")
		// 	indexString := strings.Index(string(lBody), "</body>")

		// 	if indexA != -1 && indexString != -1 && indexA < indexString {
		// 		result = string(lBody)[indexA+len("<body>") : indexString]
		// 		pDebug.Log(helpers.Statement, "SMS HTML ERROR : ", result)
		// 		return lToken.Token, helpers.ErrReturn(lErr)
		// 	} else {
		// 		pDebug.Log(helpers.Statement, "SMS HTML ERROR : ", result)
		// 		return lToken.Token, helpers.ErrReturn(lErr)
		// 	}
		// } else {
		if lErr != nil {
			return lToken.Token, helpers.ErrReturn(lErr)
		}
		lErr = json.Unmarshal(lBody, &lToken)
		if lErr != nil {
			return lToken.Token, helpers.ErrReturn(fmt.Errorf("%s => %s", lErr.Error(), string(lBody)))
		}
		lErr = UpdateTokenInCoresetting(pDebug, lToken.Token)
		if lErr != nil {
			return lToken.Token, helpers.ErrReturn(lErr)
		}
		// }
	}
	pDebug.Log(helpers.Statement, "getToken2 (-)")
	return lToken.Token, nil

}
