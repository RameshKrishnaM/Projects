package ipvapi

import (
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
)

/***************************************************
	Purpose: This method is used to get the current location address using by longtitude and latitude
	Parameter: pLatitude, pLongtitude string, pDebug *helpers.HelperStruct

	Author : Sowmiya L
	Date : 02-Feb-2024

****************************************************/
func GetGeoAddress(pLatitude, pLongtitude string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "GetGeoAddress (+)")
	// var lLogRec commonpackage.ParameterStruct
	// create an instance of the Array
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//reading configuration values


	// Accessing value from toml file
	GeoUrl := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "GeoUrl")
	//setting the header values
	lHeaderRec.Key = "Content-type"
	lHeaderRec.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lConstrcutData := `latitude=` + pLatitude + `&longitude=` + pLongtitude
	GeoUrl = GeoUrl + lConstrcutData
	//calling the API
	lResp, lErr := apiUtil.Api_call(pDebug, GeoUrl, "GET", "", lHeaderArr, "ipv.GeoLocation")

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		// lLogRec.ErrMsg = lErr.Error()
		return lResp, helpers.ErrReturn(lErr)
	}
	// lLogRec.Method = "GET"
	// lLogRec.Request = string(lConstrcutData)
	// lLogRec.Response = lResp
	// // lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "IPV Current Address"

	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return lResp, helpers.ErrReturn(lErr)
	// }
	pDebug.Log(helpers.Details, "GetGeoAddress()_resp", lResp)
	pDebug.Log(helpers.Statement, "GetGeoAddress (-)")

	return lResp, nil
}
