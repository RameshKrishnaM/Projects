package digio

import (
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

func DownloadFile(pDebug *helpers.HelperStruct, DocID string) ([]byte, error) {
	pDebug.Log(helpers.Statement, "DownloadFile (+)")
	// var lLogRec apilog.ParameterStruct
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//read the value from toml file


	//get URL from toml
	lDownloadtUrl := tomlconfig.GtomlConfigLoader.GetValueString("digioesign", "download_url")
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

	lUrl := lBaseURl + lDownloadtUrl + DocID
	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, "GET", "", lHeaderArr, "digio.DownloadFile")

	if lErr != nil {
		return nil, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "DownloadFile (-)")

	return []byte(lResp), nil
}
