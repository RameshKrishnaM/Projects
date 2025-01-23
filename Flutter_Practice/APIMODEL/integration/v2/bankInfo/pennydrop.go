package bankinfo

import (
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"net/http"
)

type PDHeaderStruct struct {
	ContentType        string
	Content_value      string
	AuthorizationKey   string
	AuthorizationValue string
}

// CCHandler - Create Contact Handler
func CCHandler(pDebug *helpers.HelperStruct, pJsonData string, pSource string) (string, error) {
	pDebug.Log(helpers.Statement, "RequestCCHandler (+)")

	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "ContactURL")

	var lHeaderArr []apiUtil.HeaderDetails
	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, http.MethodPost, pJsonData, lHeaderArr, pSource)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "RCCH001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "Response CCHandler", lResp)

	pDebug.Log(helpers.Statement, "RequestCCHandler (-)")
	return lResp, nil
}

// CFAHandler -  Create Fund Account Handler
func CFAHandler(pDebug *helpers.HelperStruct, pJsonData string, pSource string) (string, error) {
	pDebug.Log(helpers.Statement, "RequestCCHandler (+)")
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "FundURL")

	var lHeaderArr []apiUtil.HeaderDetails

	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, http.MethodPost, pJsonData, lHeaderArr, pSource)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "RCFAH001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "Response CCHandler", lResp)

	pDebug.Log(helpers.Statement, "RequestCCHandler (-)")
	return lResp, nil
}

// VBAHandler - Validation Bank Account Handler
func VBAHandler(pDebug *helpers.HelperStruct, pJsonData string, pSource string) (string, error) {
	pDebug.Log(helpers.Statement, "RequestVBAHandler (+)")
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "ValidateURL")

	var lHeaderArr []apiUtil.HeaderDetails

	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, http.MethodPost, pJsonData, lHeaderArr, pSource)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "RVBAH001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "Response VBAHandler", lResp)

	pDebug.Log(helpers.Statement, "RequestVBAHandler (-)")
	return lResp, nil
}

// GVSHandler - Get Validation Status Handler
func GVSHandler(pDebug *helpers.HelperStruct, pJsonData string, pSource string) (string, error) {
	pDebug.Log(helpers.Statement, "RequestGVSHandler (+)")
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "ValidateStatusUrl")

	var lHeaderArr []apiUtil.HeaderDetails

	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, http.MethodPost, pJsonData, lHeaderArr, pSource)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "RGVSH001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "Response GVSHandler", lResp)

	pDebug.Log(helpers.Statement, "RequestGVSHandler (-)")
	return lResp, nil
}
