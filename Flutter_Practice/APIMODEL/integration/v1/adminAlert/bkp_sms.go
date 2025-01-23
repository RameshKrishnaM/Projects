// // backup
package adminAlert

// import (
// 	"bytes"
// 	"database/sql"
// 	"encoding/json"
// 	"fcs23pkg/common"
// 	"fcs23pkg/ftdb"
// 	"fcs23pkg/helpers"
// 	"fmt"
// 	"io/ioutil"
// 	"net/http"
// 	"strings"
// )

// type smsConfigStruct struct {
// 	SmsParam smsParamStruct
// }

// type smsParamStruct struct {
// 	SmsUserName   string
// 	SmsPassword   string
// 	SmsTokenLink  string
// 	SmsAPILink    string
// 	SmsMsgVersion string
// 	SmsSender     string
// }

// type smsAdrsStruct struct {
// 	FROM string `json:"@FROM"`
// 	TO   string `json:"@TO"`
// 	SEQ  string `json:"@SEQ"`
// 	TAG  string `json:"@TAG"`
// }
// type smsMsgStruct struct {
// 	UDH      string          `json:"@UDH"`
// 	CODING   string          `json:"@CODING"`
// 	TEXT     string          `json:"@TEXT"`
// 	PROPERTY string          `json:"@PROPERTY"`
// 	ID       string          `json:"@ID"`
// 	ADDRESS  []smsAdrsStruct `json:"ADDRESS"`
// }
// type smsTypeStruct struct {
// 	Version string `json:"@VER"`
// 	User    struct {
// 		UserName string `json:"@USERNAME"`
// 		PassWord string `json:"@PASSWORD"`
// 	} `json:"USER"`
// 	DLR struct {
// 		URL string `json:"@URL"`
// 	} `json:"DLR"`
// 	SMS []smsMsgStruct `json:"SMS"`
// }

// type msgRepoStrect struct {
// 	MESSAGEACK struct {
// 		GUID struct {
// 			SUBMITDATE string `json:"SUBMITDATE"`
// 			GUID       string `json:"GUID"`
// 			ID         string `json:"ID"`
// 			ERROR      struct {
// 				SEQ  int    `json:"SEQ"`
// 				CODE int    `json:"CODE"`
// 				Desc string `json:"Desc"`
// 			} `json:"ERROR"`
// 		} `json:"GUID"`
// 		CODE string `json:"CODE"`
// 	} `json:"MESSAGEACK"`
// }

// type SmsMsgStruct struct {
// 	PhoneNumber  string `json:"phonenumber"`
// 	ClientId     string `json:"clientid"`
// 	SentFrom     string `json:"sentfrom"`
// 	TemplateCode string `json:"tempaltecode"`
// 	SendOTP      string `json:"sendotp"`
// 	ReturnOTP    string `json:"returnotp"`
// 	Param1       string `json:"param1"`
// 	Param2       string `json:"param2"`
// 	Param3       string `json:"param3"`
// 	Param4       string `json:"param4"`
// 	Param5       string `json:"param5"`
// 	Param6       string `json:"param6"`
// 	Param7       string `json:"param7"`
// 	Realip       string
// 	Forwardedip  string
// 	Method       string
// 	Path         string
// 	Host         string
// 	Remoteaddr   string
// 	Apitoken     string
// 	OTP          string
// 	Name         string
// 	Mobile       string
// 	Email        string
// }

// type smsDetailStruct struct {
// 	Msg      string
// 	Header   string
// 	UserName string
// 	Password string
// }

// type TokenStruct struct {
// 	Token      string `json:"token"`
// 	ExpiryDate string `json:"expiryDate"`
// }

// func SmsMessage(r *http.Request, pSmsMessage SmsMsgStruct, pReqSource string, pDebug *helpers.HelperStruct) error {
// 	pDebug.Log(helpers.Statement, "SmsMessage+")

// 	var lConfig smsConfigStruct
// 	var lErr error

// 	lConfigData := common.ReadTomlConfig("./toml/otpconfig.toml")

// 	lConfig.SmsParam.SmsUserName = fmt.Sprintf("%v", lConfigData.(map[string]interface{})["SmsUserName"])
// 	lConfig.SmsParam.SmsPassword = fmt.Sprintf("%v", lConfigData.(map[string]interface{})["SmsPassword"])
// 	lConfig.SmsParam.SmsTokenLink = fmt.Sprintf("%v", lConfigData.(map[string]interface{})["SmsTokenLink"])
// 	lConfig.SmsParam.SmsAPILink = fmt.Sprintf("%v", lConfigData.(map[string]interface{})["SmsAPILink"])
// 	lConfig.SmsParam.SmsMsgVersion = fmt.Sprintf("%v", lConfigData.(map[string]interface{})["SmsMsgVersion"])
// 	lConfig.SmsParam.SmsSender = fmt.Sprintf("%v", lConfigData.(map[string]interface{})["SmsSender"])

// 	if pSmsMessage.SentFrom != "" && pSmsMessage.TemplateCode != "" {
// 		if pSmsMessage.PhoneNumber != "" || pSmsMessage.ClientId != "" {
// 			//by default set the received phonenumber to mobile
// 			//number in mobile field will get the sMS
// 			pSmsMessage.Mobile = pSmsMessage.PhoneNumber
// 			//if client Id passed and phone number not passed, then
// 			//derive client details
// 			//	var smsResponse SmsResponseType
// 			if pSmsMessage.ClientId != "" && pSmsMessage.PhoneNumber == "" {
// 				//getclient detail
// 				//lDb := util.Getdb("mssql", config.Database)
// 				lDb, lErr := ftdb.LocalDbConnect(ftdb.MainDB)
// 				if lErr != nil {
// 					helpers.ErrReturn(lErr)
// 				}
// 				defer lDb.Close()
// 				clientDetails, lErr := GetClientDetails(pDebug)

// 				if lErr != nil {
// 					helpers.ErrReturn(lErr)
// 				}
// 				pSmsMessage.Name = clientDetails.Process
// 				pSmsMessage.Mobile = clientDetails.Sendto
// 				pSmsMessage.Email = clientDetails.Sendto
// 				//if we do not get the client details
// 				if pSmsMessage.Mobile == "" {
// 					pSmsMessage.Name = "INVALID_CLIENT_CODE"
// 				}

// 			}
// 		}
// 	}
// 	lErr = triggerSMS(pSmsMessage, lConfig, pReqSource, pDebug)
// 	if lErr != nil {
// 		return helpers.ErrReturn(lErr)
// 	}

// 	pDebug.Log(helpers.Statement, "SmsMessage-")

// 	return nil
// }

// // -------------------------------------------------------
// // send sms message
// // -------------------------------------------------------
// func triggerSMS(pSmsMessage SmsMsgStruct, pConfig smsConfigStruct, pReqSource string, pDebug *helpers.HelperStruct) error {
// 	pDebug.Log(helpers.Statement, "triggerSMS+")

// 	//var config smsConfig
// 	lDb, lErr := ftdb.LocalDbConnect(ftdb.MariaEKYCPRD)
// 	if lErr != nil {
// 		helpers.ErrReturn(lErr)
// 	} else {
// 		defer lDb.Close()
// 		var lSmsMsg smsDetailStruct
// 		lInterfaceResp := ""
// 		var lSmsResp msgRepoStrect
// 		//if mobile number is provided, then send SMS
// 		if pSmsMessage.Mobile != "" {
// 			//get smsMessage
// 			lSmsMsg, lErr = getSMSMessage2(lDb, pSmsMessage.TemplateCode, pDebug)
// 			if lErr != nil {
// 				helpers.ErrReturn(lErr)
// 			} else {
// 				//get dynamic values in the smsMsg
// 				//smsMsg = setParams(smsMsg, smsMessage)
// 				lSmsMsg.Msg = setParams(lSmsMsg.Msg, pSmsMessage, pDebug)
// 				//send SMS
// 				//interfaceResp, smsResp = sendSMS(config.SMSParams.SmsSender, smsMessage.Mobile, smsMsg, "TEXT1")
// 				lInterfaceResp, lSmsResp, lErr = sendSMS2(pConfig.SmsParam.SmsSender, pSmsMessage.Mobile, lSmsMsg, "TEXT1", pConfig, pDebug)
// 				if lErr != nil {
// 					helpers.ErrReturn(lErr)
// 				} else {
// 					lSqlString := `insert into smsmessagelog(PhoneNumber,ClientId,SentFrom,TemplateCode,Param1,Param2,Param3,Param4,Param5,
// 						Param6,Param7,createddate,smsmessagereceived,smsmessagesent,smsresponse,realip,forwardedip,methods,paths,host,
// 						remoteaddr,apitoken,SendOTP,ReturnOTP,otp,clientname,mobile,email,guid, Requested_Source)
// 						values (?, ?, ?, ?, ?, ?, ?, ?, ?,?, ?,Now(), ?,?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?,?, ?)`
// 					_, lInserterr := lDb.Exec(lSqlString, pSmsMessage.PhoneNumber, pSmsMessage.ClientId, pSmsMessage.SentFrom, pSmsMessage.TemplateCode, pSmsMessage.Param1,
// 						pSmsMessage.Param2, pSmsMessage.Param3, pSmsMessage.Param4, pSmsMessage.Param5, pSmsMessage.Param6, pSmsMessage.Param7, "", lSmsMsg.Msg,
// 						lInterfaceResp, pSmsMessage.Realip, pSmsMessage.Forwardedip, pSmsMessage.Method, pSmsMessage.Path, pSmsMessage.Host, pSmsMessage.Remoteaddr,
// 						pSmsMessage.Apitoken, pSmsMessage.SendOTP, pSmsMessage.ReturnOTP, pSmsMessage.OTP, pSmsMessage.Name, pSmsMessage.Mobile, pSmsMessage.Email,
// 						lSmsResp.MESSAGEACK.GUID.GUID, pReqSource)
// 					if lInserterr != nil {
// 						pDebug.Log(helpers.Statement, lInserterr)
// 						helpers.ErrReturn(lInserterr)
// 					}
// 				}

// 			}

// 		}

// 	}

// 	pDebug.Log(helpers.Statement, "triggerSMS-")
// 	return nil
// }

// // --------------------------------------------------------------------------
// // function retrives sms message from db for the given message template code
// // --------------------------------------------------------------------------
// func getSMSMessage2(lDb *sql.DB, lSmsTemplate string, pDebug *helpers.HelperStruct) (smsDetailStruct, error) {
// 	pDebug.Log(helpers.Statement, "getSMSMessage2+")

// 	var lSmsDetailRec smsDetailStruct
// 	lSqlString := `select xt.templateMessage,xt.smsheader,xa.smsaccount,xa.smspassword from xxsms_template xt,
// 	xxsms_accounts xa where xt.smsaccount = xa.smsaccount and xt.enabled = 'Y' and xa.enabled='Y' and xt.templateCode = '` + lSmsTemplate + `'`
// 	lRows, lErr := lDb.Query(lSqlString)
// 	if lErr != nil {
// 		return lSmsDetailRec, helpers.ErrReturn(lErr)
// 	} else {
// 		//-----------Before Looping records----------
// 		for lRows.Next() {
// 			lErr := lRows.Scan(&lSmsDetailRec.Msg, &lSmsDetailRec.Header, &lSmsDetailRec.UserName, &lSmsDetailRec.Password)
// 			if lErr != nil {
// 				return lSmsDetailRec, helpers.ErrReturn(lErr)
// 			}
// 		}
// 	}
// 	pDebug.Log(helpers.Statement, "getSMSMessage2-")
// 	return lSmsDetailRec, nil
// }

// // -------------------------------------------------------
// // function set dynamic values in the sms message
// // -------------------------------------------------------
// func setParams(pSmsMsg string, pSmsMessage SmsMsgStruct, pDebug *helpers.HelperStruct) string {
// 	pDebug.Log(helpers.Statement, "setParams+")
// 	pSmsMsg = strings.Replace(pSmsMsg, "{#otp#}", pSmsMessage.OTP, 10)
// 	pSmsMsg = strings.Replace(pSmsMsg, "{#param1#}", pSmsMessage.Param1, 10)
// 	pSmsMsg = strings.Replace(pSmsMsg, "{#param2#}", pSmsMessage.Param2, 10)
// 	pSmsMsg = strings.Replace(pSmsMsg, "{#param3#}", pSmsMessage.Param3, 10)
// 	pSmsMsg = strings.Replace(pSmsMsg, "{#param4#}", pSmsMessage.Param4, 10)
// 	pSmsMsg = strings.Replace(pSmsMsg, "{#param5#}", pSmsMessage.Param5, 10)
// 	pSmsMsg = strings.Replace(pSmsMsg, "{#param6#}", pSmsMessage.Param6, 10)
// 	pSmsMsg = strings.Replace(pSmsMsg, "{#param7#}", pSmsMessage.Param7, 10)

// 	pDebug.Log(helpers.Statement, "setParams-")
// 	return pSmsMsg
// }

// func sendSMS2(pFrom string, pTo string, pMsg smsDetailStruct, pUniqueRef string, pConfig smsConfigStruct, pDebug *helpers.HelperStruct) (string, msgRepoStrect, error) {
// 	pDebug.Log(helpers.Statement, "sendSMS2+")
// 	var SmsMsgRec smsTypeStruct
// 	var SmsTxtRec smsMsgStruct
// 	var SmsToRec smsAdrsStruct
// 	var RspMsgRec msgRepoStrect
// 	//var config smsConfig
// 	var lAny interface{}
// 	lReturndata := ""
// 	SmsMsgRec.Version = pConfig.SmsParam.SmsMsgVersion
// 	SmsTxtRec.UDH = "0"
// 	SmsTxtRec.CODING = "1"
// 	SmsTxtRec.PROPERTY = "0"
// 	SmsTxtRec.ID = pUniqueRef
// 	SmsTxtRec.TEXT = pMsg.Msg
// 	SmsToRec.FROM = pMsg.Header
// 	SmsToRec.TO = pTo
// 	SmsToRec.SEQ = "1"
// 	SmsToRec.TAG = ""
// 	SmsTxtRec.ADDRESS = append(SmsTxtRec.ADDRESS, SmsToRec)
// 	SmsMsgRec.SMS = append(SmsMsgRec.SMS, SmsTxtRec)
// 	pDebug.Log(helpers.Statement, SmsMsgRec)
// 	lUrla := pConfig.SmsParam.SmsAPILink

// 	lPostBody, _ := json.Marshal(SmsMsgRec)
// 	lPostJsonBody := bytes.NewBuffer(lPostBody)
// 	pDebug.Log(helpers.Statement, lPostJsonBody)
// 	lReqs, lErr := http.NewRequest("POST", lUrla, lPostJsonBody)
// 	if lErr != nil {
// 		return lReturndata, RspMsgRec, helpers.ErrReturn(lErr)
// 	}
// 	lToken, lErr := getToken2(pMsg.UserName, pMsg.Password, pConfig, pDebug)
// 	if lErr != nil {
// 		return lReturndata, RspMsgRec, helpers.ErrReturn(lErr)
// 	}
// 	var lBearer = "Bearer " + lToken
// 	lReqs.Header.Add("Authorization", lBearer)
// 	if lErr != nil {
// 		return lReturndata, RspMsgRec, helpers.ErrReturn(lErr)

// 	}
// 	lReqs.Header.Add("Content-Type", "application/json")
// 	lClient := &http.Client{}
// 	lResponse, lErr := lClient.Do(lReqs)
// 	if lErr != nil {
// 		return lReturndata, RspMsgRec, helpers.ErrReturn(lErr)
// 	}
// 	lBody, lErr := ioutil.ReadAll(lResponse.Body)
// 	if lErr != nil {
// 		return lReturndata, RspMsgRec, helpers.ErrReturn(lErr)
// 	}
// 	lErr = json.Unmarshal(lBody, &lAny)
// 	if lErr != nil {
// 		return lReturndata, RspMsgRec, helpers.ErrReturn(lErr)
// 	}
// 	lReturndata = fmt.Sprintf("%s", lAny)
// 	pDebug.Log(helpers.Details, "any :", lAny)

// 	lErr = json.Unmarshal(lBody, &RspMsgRec)
// 	if lErr != nil {
// 		return lReturndata, RspMsgRec, helpers.ErrReturn(lErr)
// 	}

// 	pDebug.Log(helpers.Statement, "sendSMS2-")
// 	return lReturndata, RspMsgRec, nil
// }

// func getToken2(pUsername string, pPassword string, pConfig smsConfigStruct, pDebug *helpers.HelperStruct) (string, error) {
// 	pDebug.Log(helpers.Statement, "getToken2+")
// 	var lToken TokenStruct
// 	//var config smsConfig
// 	lUrla := pConfig.SmsParam.SmsTokenLink //(PAN_Number:equals:" + pan + ")"

// 	lReqs, lErr := http.NewRequest("POST", lUrla, nil)
// 	if lErr != nil {
// 		return "", helpers.ErrReturn(lErr)
// 	}
// 	lReqs.SetBasicAuth(pUsername, pPassword)
// 	//reqs.Header.Add("Content-Type", "application/json")

// 	lClient := &http.Client{}
// 	lResponse, lErr := lClient.Do(lReqs)
// 	if lErr != nil {
// 		return lToken.Token, helpers.ErrReturn(lErr)
// 	}
// 	lBody, lErr := ioutil.ReadAll(lResponse.Body)
// 	if len(lBody) > 0 {
// 		if lErr != nil {
// 			return lToken.Token, helpers.ErrReturn(lErr)
// 		}
// 		lErr = json.Unmarshal(lBody, &lToken)
// 		if lErr != nil {
// 			return lToken.Token, helpers.ErrReturn(lErr)
// 		}
// 	}

// 	pDebug.Log(helpers.Statement, "getToken2-")
// 	return lToken.Token, nil

// }
