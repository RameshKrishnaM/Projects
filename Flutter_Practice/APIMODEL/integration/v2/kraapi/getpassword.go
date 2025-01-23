package kraapi

import (
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"net/http"
)

// type logStruct struct {
// 	Method   string `json:"method"`
// 	Request  string `json:"request"`
// 	Response string `json:"response"`
// 	ErrorMsg string `json:"errmsg"`
// }

/****************************************************************************
	Purpose: This method is to call the third party api and get the passcode,
			 that can be used in the subsequent KRA api calls
	Parameter: payload
	body: payload
	hearder:{
		key : SOAPAction
		value : getpassword
	}
	Author : Sowmiya L
	Date : 06-June-2023
*****************************************************************************/
func Getpassword(pPayload string, pDebug *helpers.HelperStruct, req *http.Request) (string, error) {
	pDebug.Log(helpers.Statement, "Getpassword (+)")
	// var lLogRec commonpackage.ParameterStruct
	// create an instance of the Array
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//reading configuration values

	// Accessing value from toml file
	lPassUrl := tomlconfig.GtomlConfigLoader.GetValueString("kra", "pass_url")
	lGetPassword := tomlconfig.GtomlConfigLoader.GetValueString("kra", "getpassword")
	lSOAPAction := tomlconfig.GtomlConfigLoader.GetValueString("kra", "SOAPAction")
	//setting the header values
	lHeaderRec.Key = lSOAPAction
	lHeaderRec.Value = lGetPassword
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-type"
	lHeaderRec.Value = "text/xml; charset=utf-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//calling the API
	lResp, lErr := apiUtil.Api_call(pDebug, lPassUrl, "POST", pPayload, lHeaderArr, "kraapi.Getpassword")
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lResp, helpers.ErrReturn(lErr)
	}

	// lLogRec.Method = "POST"
	// lLogRec.Request = string(pPayload)
	// lLogRec.Response = lResp
	// lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "Ekyc_Pan(Password verify)"
	// lLogRec.ErrMsg = ""

	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return lResp, helpers.ErrReturn(lErr)
	// }
	// common.LogEntry("resp", lResp)
	pDebug.Log(helpers.Details, "resp", lResp)
	pDebug.Log(helpers.Statement, "Getpassword (-)")

	return lResp, nil
}
