package panstatusverify

import (
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"net/http"
)

/*
	Purpose: This method is used to call the api and fetch the pan status
	Parameter: payload string, pDebug *helpers.HelperStruct, req *http.Request, pConfigFile interface{}
	body: payload
	hearder:{
		key : Content-Language
		value : en-US
	}
	Author : Sowmiya L
	Date : 06-June-2023
*/

func PanStatusverifyApiCall(pPayload string, pDebug *helpers.HelperStruct, req *http.Request) (string, error) {
	pDebug.Log(helpers.Statement, "PanStatusverifyApiCall (+)")

	var lResp string

	// var lLogRec commonpackage.ParameterStruct
	// create an instance of the Array
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	URl := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "GetPanStatus_URL")
	//reading configuration values
	lHeaderRec.Key = "Content-Language"
	lHeaderRec.Value = "en-US"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-type"
	lHeaderRec.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//calling the API
	lResp, lErr := apiUtil.Api_call(pDebug, URl, "POST", pPayload, lHeaderArr, "PanStatusVerify")
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		// lLogRec.ErrMsg = lErr.Error()
		return lResp, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "resp", lResp)
	pDebug.Log(helpers.Statement, "PanStatusverifyApiCall (-)")
	return lResp, nil
}

func NewPanStatusVerification(pPayload string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "NewPanStatusVerification (+)")

	var lResp string

	// var lLogRec commonpackage.ParameterStruct
	// create an instance of the Array
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	URl := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "GetNewPanStatus_URL")
	//reading configuration values
	lHeaderRec.Key = "Content-Language"
	lHeaderRec.Value = "en-US"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-type"
	lHeaderRec.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//calling the API
	lResp, lErr := apiUtil.Api_call(pDebug, URl, "POST", pPayload, lHeaderArr, "PanStatusVerify")
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		// lLogRec.ErrMsg = lErr.Error()
		return lResp, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "resp", lResp)
	pDebug.Log(helpers.Statement, "NewPanStatusVerification (-)")
	return lResp, nil
}

func PanStatusCheck(pDebug *helpers.HelperStruct, pREFID string) (string, error) {
	pDebug.Log(helpers.Statement, "PanStatusCheck (+)")
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails


	URl := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "GetNewPanStatusCheck_URL")
	lHeaderRec.Key = "REFID"
	lHeaderRec.Value = pREFID
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	lResp, lErr := apiUtil.Api_call(pDebug, URl, "GET", "", lHeaderArr, "PanStatusVerify")
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lResp, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "PanStatusCheck (-)")
	return lResp, nil
}
