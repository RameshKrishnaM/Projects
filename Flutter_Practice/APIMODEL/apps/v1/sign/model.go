package sign

import (
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"strings"
)

func Api_call_processed_data(processType string, inputJson string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "Api_call_processed_data+")

	// var resultData KycApiResponse
	// var emptyStruct KycApiResponse
	var resultData string
	var err error

	var header apiUtil.HeaderDetails
	var headerArr []apiUtil.HeaderDetails

	header.Key = "Content-Type"
	header.Value = "application/json; charset=UTF-8"
	headerArr = append(headerArr, header)


	pDebug.Log(helpers.Details, "processType", processType)
	//ClosurePDFAPI := tomlconfig.GtomlConfigLoader.GetValueString("kycutilconfig","ClosurePDFAPI")
	//BankAdditionPDFAPI := tomlconfig.GtomlConfigLoader.GetValueString("kycutilconfig","BankAdditionPDFAPI")
	NomineePDFAPI := tomlconfig.GtomlConfigLoader.GetValueString("kycutilconfig", "NomineePDFAPI")
	//EsignRequestAPI := tomlconfig.GtomlConfigLoader.GetValueString("kycutilconfig","EsignRequestAPI")
	//EsignDocumentAPI := tomlconfig.GtomlConfigLoader.GetValueString("kycutilconfig","EsignDocumentAPI")

	switch strings.ToUpper(processType) {

	// case common.ClosureProcessType:
	// 	resultData, err = apiUtil.Api_call(ClosurePDFAPI, "Post", inputJson, headerArr, "sign.Api_call_processed_data")
	// case common.BankProcessType:
	// 	resultData, err = apiUtil.Api_call(BankAdditionPDFAPI, "Post", inputJson, headerArr, "sign.Api_call_processed_data")
	case common.NomineeProcessType:
		resultData, err = apiUtil.Api_call(pDebug, NomineePDFAPI, "Post", inputJson, headerArr, "sign.Api_call_processed_data")

		if err != nil {
			pDebug.Log(helpers.Elog, err.Error())
			return resultData, helpers.ErrReturn(err)
		}
		// case common.EsignXmlProcessType:
	// 	resultData, err = apiUtil.Api_call(EsignRequestAPI, "Post", inputJson, headerArr, "sign.Api_call_processed_data")
	// case common.EsignStampProcessType:
	// 	resultData, err = apiUtil.Api_call(EsignDocumentAPI, "Post", inputJson, headerArr, "sign.Api_call_processed_data")
	default:
		resultData = "Invalid Process Type parameter"

	}

	// if err != nil {
	// 	err := adminAlert.SendAlertMsg("sign.Api_call_processed_data", "(SACP01)")
	// 	if err != nil {
	// 		common.LogError("sign.Api_call_processed_data", "(SACP01)", err.Error())
	// 	}
	// }

	pDebug.Log(helpers.Statement, "Api_call_processed_data-")
	pDebug.Log(helpers.Details, "resultData", resultData)
	return resultData, nil

}
