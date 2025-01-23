package otp

import (
	"bytes"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/email"
	"html/template"
)

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

func SendOtptoEmail(pClientId string, pReqSource string, pHtmlInput HtmlStruct, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "SendOtptoEmail(+)")
	var lClientdataRec ClientdetailStruct

	lClientdataRec.ClientId = pClientId
	lClientdataRec.Otp = pHtmlInput.Otp
	lClientdataRec.EmailId = pHtmlInput.EmailId
	lClientdataRec.Reason = pHtmlInput.Reason

	lClientdataRec.ClientName = pDebug.Reference

	pDebug.Log(helpers.Statement, "EmailInput(+)")

	lErr := EmailInputs(lClientdataRec, pReqSource, pHtmlInput, pDebug)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "SendOtptoEmail(-)")

	return nil
}

//---------------------------------------------------------------
// function forms  the input body  string for sent email
// Returns the err
//---------------------------------------------------------------
func EmailInputs(pRecord ClientdetailStruct, pReqSource string, pHtmlInput HtmlStruct, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "EmailInput(+)")

	var lEmailRec email.EmailStruct
	var ltpl bytes.Buffer
	var ldynamicEmailRec DynamicEmailStruct

	ldynamicEmailRec.Name = pRecord.ClientName
	ldynamicEmailRec.Otp = pRecord.Otp
	ldynamicEmailRec.ClientId = pRecord.ClientId
	ldynamicEmailRec.Reason = pRecord.Reason

	lTemp, lErr := template.ParseFiles(pHtmlInput.HtmlPath) // change this
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	} else {
		lTemp.Execute(&ltpl, ldynamicEmailRec)
		emailbody := ltpl.String()
		lEmailRec.Body = emailbody
		lEmailRec.EmailId = pRecord.EmailId
		lEmailRec.Subject = pHtmlInput.Subject

		lErr = email.SendEmail(lEmailRec, pReqSource, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "EmailInput(-)")

	return nil
}
