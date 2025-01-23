package kraapi

import (
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"net/http"
)

/*
	Purpose: This method is to call the third party api
	Parameter: payload
	body: payload
	hearder:{
		key : SOAPAction
		value : PANDetailsFetchALLKRA
	}
	Author : Sowmiya L
	Date : 06-June-2023

*/
func Panfulldetails(pPayload string, pDebug *helpers.HelperStruct, req *http.Request) (string, error) {
	pDebug.Log(helpers.Statement, "Pandetails (+)")
	// var lLogRec commonpackage.ParameterStruct
	// create an instance of the Array
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//reading configuration values

	// Accessing value from toml file
	lPass_url := tomlconfig.GtomlConfigLoader.GetValueString("kra",
		"pass_url")
	lPANDetailsFetchALLKRA := tomlconfig.GtomlConfigLoader.GetValueString("kra",
		"PANDetailsFetchALLKRA")
	lSOAPAction := tomlconfig.GtomlConfigLoader.GetValueString("kra",
		"SOAPAction")
	//setting the header values
	lHeaderRec.Key = lSOAPAction
	lHeaderRec.Value = lPANDetailsFetchALLKRA
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-type"
	lHeaderRec.Value = "text/xml; charset=utf-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//calling the API
	lResp, lErr := apiUtil.Api_call(pDebug, lPass_url, "POST", pPayload, lHeaderArr, "kraapi.Panfulldetails")
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lResp, helpers.ErrReturn(lErr)
	}

	// lLogRec.Method = "POST"
	// lLogRec.Request = string(pPayload)
	// lLogRec.Response = lResp
	// lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "Ekyc_Pan(Pan AddressDetails)"
	// lLogRec.ErrMsg = ""
	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return lResp, helpers.ErrReturn(lErr)
	// }
	pDebug.Log(helpers.Details, "lResp--------------------", lResp)

	pDebug.Log(helpers.Statement, "Pandetails (-)")

	return lResp, nil
}
