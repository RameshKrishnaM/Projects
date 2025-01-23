package kraapi

import (
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
)

func GetKRAInfo(pDebug *helpers.HelperStruct, pUserData, pFlag string) (string, error) {
	pDebug.Log(helpers.Statement, "GetKRAInfo (+)")
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	var lKraURL string
	//read the value from toml file

	//get URL from toml
	if pFlag == "KRASTATUS" {
		lKraURL = tomlconfig.GtomlConfigLoader.GetValueString("kra", "KraStatus")
	} else if pFlag == "KRADETAILS" {
		lKraURL = tomlconfig.GtomlConfigLoader.GetValueString("kra", "KraURL")
	}
	// lDigiIdUrl := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["DigilockerInfoUrl"])
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)

	//call the api to given URL
	lPayload, lErr := apiUtil.Api_call(pDebug, lKraURL, "POST", pUserData, lHeaderArr, "kraapi.GetKraInfo")

	if lErr != nil {
		return lPayload, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "GetKRAInfo (-)")
	return lPayload, nil
}
func GetKRAInfoUseRefID(pDebug *helpers.HelperStruct, pRefID string) (string, error) {
	pDebug.Log(helpers.Statement, "GetKRAInfoUseRefID (+)")
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//read the value from toml file


	//get URL from toml
	lRefUrl := tomlconfig.GtomlConfigLoader.GetValueString("kra", "RefUrl")
	//set header value
	lHeaderRec.Key = "APPNAME"
	lHeaderRec.Value = tomlconfig.GtomlConfigLoader.GetValueString("kra", "appname")
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "REFID"
	lHeaderRec.Value = pRefID
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)

	//call the api to given URL
	lPayload, lErr := apiUtil.Api_call(pDebug, lRefUrl, "GET", "", lHeaderArr, "kraapi.GetKRAInfoUseRefID")

	if lErr != nil {
		return lPayload, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "GetKRAInfoUseRefID (-)")
	return lPayload, nil
}
