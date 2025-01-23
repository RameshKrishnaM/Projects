package emailSrv

import (
	"encoding/base64"
	"encoding/json"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"

	"net/http"

	"fmt"
)

// structure for mail detials
type EmailRequest struct {
	FromDspName string     `json:"FD"`  //FromDspName - M
	FromRaw     string     `json:"FR"`  //From Raw - M
	ReplyTo     string     `json:"R"`   //ReplyTo mail - M
	To          []string   `json:"T"`   //To adrs - M
	CC          []string   `json:"C"`   //CC
	BCC         []string   `json:"BC"`  //BCC
	Subject     string     `json:"S"`   //Mail Subject - M
	Body        string     `json:"B"`   //Html Content - M
	DocId       []string   `json:"D"`   //DocId For Attachment
	FileInfo    []FileInfo `json:"FFN"` //Form File Name
	Source      string     `json:"SO"`  // Code Name or Application Name - M
}

// Response structure for email service
type EmailResponseStruct struct {
	Status     string `json:"status"`
	StatusCode string `json:"statusCode"`
	Msg        string `json:"msg"`
}

// Structure for file details
type FileInfo struct {
	FileName string `json:"FN"`
	File     string `json:"FD"`
}

// Request structure for email service
type EmailContent struct {
	EmailContent string `json:"emailContent"`
	Token        string `json:"token"`
	ClientID     string `json:"client_id"`
}

/*
Purpose :
The purpose of this method is used to
 1. Validate the code created for the registered client and then generate the token.
 2. Then generate the token.
 3. Send email with the help of generated token.

Parameters : pDebug,pEmailRec,pSource
Response :

	On success
	==========
	It return's nil in error
	On error
	========
	It return's error message in error

Authorization : Logeshkumar P
Date : 08 Nov 2024
*/
func SendMail(pDebug *helpers.HelperStruct, pEmailRec EmailRequest) error {
	pDebug.Log(helpers.Statement, "SendMail +")

	// call the service to send email.
	lClientID, lToken, lErr := GenerateToken(pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GenerateToken001: "+lErr.Error())
		return helpers.ErrReturn(fmt.Errorf("Error on GenerateToken001 >> " + lErr.Error()))
	}
	lErr = ESSendEmail(pDebug, pEmailRec, lClientID, lToken)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "ESSendEmail01: "+lErr.Error())
		return helpers.ErrReturn(fmt.Errorf("Error on send mail service >> " + lErr.Error()))
	}
	pDebug.Log(helpers.Statement, "SendMail -")
	return nil
}

/*
Purpose : The purpose of this method is used to call the email service via apiUtil.
Parameters :

	pDebug,
	pEmailRec : {
	    FromDspName : "ABCD"
	    FromRaw     : "xx_example@gmail.com"
	    ReplyTo     : "xx_example@gmail.com"
	    To          : ["xx_example1@gmail.com","xx_example2@gmail.com"]
	    CC          : ["xx_example1@gmail.com","xx_example2@gmail.com"]
	    BCC         : ["xx_example1@gmail.com","xx_example2@gmail.com"]
	    Subject     : "subject"
	    Body        : "body" or Html content
	    DocId       : [23,34]
	    FileInfo    : [{"filename",file}]
	    Source      : "App name"
	}
	, pToken, pTomlDataStruct

Response :

	On success
	==========
		It return's nil in error
	On error
	========
		It return's error message in error

Authorization : Logeshkumar P
Date : 08 Nov 2024
*/
func ESSendEmail(pDebug *helpers.HelperStruct, pEmailRec EmailRequest, ClientID, pToken string) error {
	pDebug.Log(helpers.Statement, "ESSendEmail -")

	// Convert e-mail struct into JSON
	lEmailRecStruct, lErr := json.Marshal(pEmailRec)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	// base64 encryption
	lEncodedData := base64.StdEncoding.EncodeToString([]byte(lEmailRecStruct))

	var lEmailContent EmailContent
	lEmailContent.EmailContent = lEncodedData
	lEmailContent.ClientID = ClientID
	lEmailContent.Token = pToken

	// Marshal the Request
	lEmailService, lErr := json.Marshal(lEmailContent)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	//Intilize the Header variable and Set the Content Type
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	lHeaderRec.Key = "sid"
	lHeaderRec.Value = pDebug.Sid
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	// Call the service via apiUtil package
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("serviceconfig", "SendMail")
	lApiCall_Resp, lErr := apiUtil.Api_call(pDebug, lUrl, http.MethodPut, string(lEmailService), lHeaderArr, pEmailRec.Source)
	pDebug.Log(helpers.Details, "ESSendEmail Response : ", lApiCall_Resp)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	var lEmailResp EmailResponseStruct
	// Unmarshal the resp into our structure
	lErr = json.Unmarshal([]byte(lApiCall_Resp), &lEmailResp)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	// In case of any error, return the api error response
	if lEmailResp.Status != "S" {
		return helpers.ErrReturn(fmt.Errorf(lEmailResp.StatusCode + "-" + lEmailResp.Msg))
	}

	pDebug.Log(helpers.Statement, "ESSendEmail -")
	return nil
}
