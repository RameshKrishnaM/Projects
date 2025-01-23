package bankinfo

import (
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"net/http"
)

// GBDIHandler - Get Bank Details using IFSC Handler
func GBDIHandler(pDebug *helpers.HelperStruct, pJsonData string, pSource string) (string, error) {
	pDebug.Log(helpers.Statement, "RequestGBDIHandler (+)")
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("ifscconfig", "IfscURL")

	var lHeaderArr []apiUtil.HeaderDetails

	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, http.MethodPost, pJsonData, lHeaderArr, pSource)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "RGVSH001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "Response GBDIHandler", lResp)
	pDebug.Log(helpers.Statement, "RequestGBDIHandler (-)")
	return lResp, nil
}
