package digio

import (
	"encoding/base64"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
)

/*
Purpose : This method is used to Triger the thirdparty Api to Download EAadhar in Xml Formet
Request :pDebug <<*helpers.HelperStruct>>, pUri <<string>>, pToken <<string>>
Response : Xml Data
===========
On Success:
===========
String formet (EAadhar Xml Data)
===========
On Error:
===========
"Error":
Author : Saravanan selvam
Date : 11-jan-2024
*/

func GenerateSignRequest(pDebug *helpers.HelperStruct, pSignInfo string) (string, error) {
	pDebug.Log(helpers.Statement, "GenerateSignRequest (+)")
	// var lLogRec apilog.ParameterStruct
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//read the value from toml file


	//get URL from toml
	lRequestUrl := tomlconfig.GtomlConfigLoader.GetValueString("digioesign", "request_url")
	lBaseURl := tomlconfig.GtomlConfigLoader.GetValueString("digioesign", "base_url")

	Secret_Key := tomlconfig.GtomlConfigLoader.GetValueString("digioesign", "Secret_Key")
	Secret_Value := tomlconfig.GtomlConfigLoader.GetValueString("digioesign", "Secret_Value")

	lHeaderRec.Key = "Authorization"
	lHeaderRec.Value = "Basic " + basicAuth(Secret_Key, Secret_Value)
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)

	lUrl := lBaseURl + lRequestUrl
	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, "POST", pSignInfo, lHeaderArr, "digio.GenerateSignRequest")

	if lErr != nil {
		return lResp, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "GenerateSignRequest (-)")

	return lResp, nil
}

func basicAuth(username, password string) string {
	auth := username + ":" + password
	return base64.StdEncoding.EncodeToString([]byte(auth))
}
