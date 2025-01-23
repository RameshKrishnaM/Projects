package kraapi

import (
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
)

var ref = ""

/***************************************************
	Purpose: This method is to call the third party api in  generate the pdf
	Parameter: payload
	body: payload
	Author : Sowmiya L
	Date : 06-June-2023

****************************************************/
func GeneratePdf(pPayload string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "Pandetails (+)")
	// var lLogRec commonpackage.ParameterStruct
	// create an instance of the Array
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//reading configuration values
	

	// Accessing value from toml file
	lGeneratePdf := tomlconfig.GtomlConfigLoader.GetValueString("kra", "GeneratePdf")
	//setting the header values
	lHeaderRec.Key = "Content-type"
	lHeaderRec.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//calling the API
	// common.LogEntry("ppppppppppp",pPayload)
	lResp, lErr := apiUtil.Api_call(pDebug, lGeneratePdf, "POST", pPayload, lHeaderArr, "kraapi.GeneratePdf")

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lResp, helpers.ErrReturn(lErr)
	}
	// lLogRec.Method = "POST"
	// lLogRec.Request = string(pPayload)
	// lLogRec.Response = lResp
	// // lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "Digilocker"
	// // lLogRec.ErrMsg = ""

	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return lResp, helpers.ErrReturn(lErr)
	// }
	pDebug.Log(helpers.Details, "resp", lResp)

	pDebug.Log(helpers.Statement, "Pandetails (-)")

	return lResp, nil
}
