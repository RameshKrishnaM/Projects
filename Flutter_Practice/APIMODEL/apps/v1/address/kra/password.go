package kra

import (
	"encoding/xml"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/kraapi"
	"fcs23pkg/tomlconfig"
	"fmt"
	"net/http"
)

/****************************************************************
  Purpose : This structure is used to generate the new password

  Author : Sowmiya L
  Date : 06-June-2023
*****************************************************************/
type passwordSoapStruct struct {
	XMLName xml.Name `xml:"Envelope"`
	Text    string   `xml:",chardata"`
	Xmlns   string   `xml:"xmlns,attr"`
	Body    struct {
		Text        string `xml:",chardata"`
		GetPassword struct {
			Text   string `xml:",chardata"`
			Xmlns  string `xml:"xmlns,attr"`
			WebApi struct {
				Text     string `xml:",chardata"`
				Password string `xml:"password"`
				PassKey  string `xml:"passKey"`
			} `xml:"webApi"`
		} `xml:"GetPassword"`
	} `xml:"Body"`
}

/****************************************************************
  Purpose : This method is used to get the password
  Parameter : password,passkey
  Author : Sowmiya L
  Date : 06-June-2023
*****************************************************************/
func PasswordSoapProcess(pStrpassword string, pStrPassKey string, pDebug *helpers.HelperStruct, req *http.Request) (string, error) {
	pDebug.Log(helpers.Statement, "PasswordSoapProcess(+)")
	// read toml

	// create an instance of the structure
	var lPassSoapRec passwordSoapStruct
	//constructing details for the API
	lPassSoapRec.Xmlns = tomlconfig.GtomlConfigLoader.GetValueString("kra", "Xmlns")
	lPassSoapRec.Body.GetPassword.Xmlns = tomlconfig.GtomlConfigLoader.GetValueString("kra", "GetPanStatus_Xmlns")

	lPassSoapRec.Body.GetPassword.WebApi.PassKey = pStrPassKey
	lPassSoapRec.Body.GetPassword.WebApi.Password = pStrpassword
	//converting the struct to XML
	lPayload, lErr := xml.MarshalIndent(lPassSoapRec, " ", "  ")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSP01"+lErr.Error())
		return "", helpers.ErrReturn(fmt.Errorf("unable to process"))
	}
	//calling API
	lResult, lErr := kraapi.Getpassword(string(lPayload), pDebug, req)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSP02"+lErr.Error())
		return lResult, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "PasswordSoapProcess(-)")
	return lResult, nil
}
