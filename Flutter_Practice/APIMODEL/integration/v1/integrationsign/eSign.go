package integrationsign

import (
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"log"
	"net/http"
	"strings"
)

func Api_call_processed_data(processType string, inputJson string, pDebug *helpers.HelperStruct, req *http.Request) (string, error) {
	log.Println("Api_call_processed_data+")
	// var lLogRec commonpackage.ParameterStruct
	// var lResultData KycApiResponse
	// var emptyStruct KycApiResponse
	var lResultData string
	var lErr error

	var header apiUtil.HeaderDetails
	var headerArr []apiUtil.HeaderDetails

	header.Key = "Content-Type"
	header.Value = "application/json; charset=UTF-8"
	headerArr = append(headerArr, header)


	EsignRequestAPI := tomlconfig.GtomlConfigLoader.GetValueString("kycutilconfig", "EsignRequestAPI")
	// fmt.Println(EsignRequestAPI, "EsignRequestAPI")
	EsignDocumentAPI := tomlconfig.GtomlConfigLoader.GetValueString("kycutilconfig", "EsignDocumentAPI")
	switch strings.ToUpper(processType) {

	case "ESIGN XML":
		lResultData, lErr = apiUtil.Api_call(pDebug, EsignRequestAPI, "POST", inputJson, headerArr, "Api_call_processed_data")
		// fmt.Println(lResultData, "lResultData")
		if lErr != nil {
			// lLogRec.ErrMsg = lErr.Error()
			pDebug.Log(helpers.Elog, lErr.Error())
			return lResultData, lErr
		}
	case "ESIGN STAMP":
		lResultData, lErr = apiUtil.Api_call(pDebug, EsignDocumentAPI, "POST", inputJson, headerArr, "Api_call_processed_data")
		if lErr != nil {
			// lLogRec.ErrMsg = lErr.Error()
			pDebug.Log(helpers.Elog, lErr.Error())
			return lResultData, lErr
		}
	default:
		lResultData = "Invalid Process Type parameter"

	}
	// lLogRec.Method = "POST"
	// lLogRec.Request = string(inputJson)
	// lLogRec.Response = lResultData
	// lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "Ekyc_Esign"

	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return lResultData, lErr
	// }
	// if err != nil {
	// 	err := adminAlert.SendAlertMsg("sign.Api_call_processed_data", "(SACP01)")
	// 	if err != nil {
	// 		common.LogError("sign.Api_call_processed_data", "(SACP01)", err.Error())
	// 	}
	// }
	log.Println("Api_call_processed_data-")
	return lResultData, lErr

}
