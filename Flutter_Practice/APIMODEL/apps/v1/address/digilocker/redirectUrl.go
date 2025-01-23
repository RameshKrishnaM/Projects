package digilocker

import (
	"encoding/json"
	"fcs23pkg/apps/v1/nominee"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/digilockerapicall"
	"fcs23pkg/tomlconfig"
	"fmt"
	"net/http"
	"strings"
)

// Interface Method

/*
Purpose : This method is used to Rediruct the user to Digilock Site
Request : N/A
Response : N/A
===========
On Success:
===========
 http://domain/api/redirect_url
===========
On Error:
===========
"Error":error
Author : Saravanan
Date : 05-June-2023
*/
type URlStruct struct {
	Statue string `json:"status"`
	URL    string `json:"redirecturl"`
}

func ConstructUrl(w http.ResponseWriter, req *http.Request) {

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "appname,Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")
	(w).Header().Set("Content-Type", "application/json")
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)
	lDebug.Log(helpers.Statement, "ConstructUrl (+)")

	if strings.EqualFold(req.Method, "GET") {
		var lErr error
		var lURLRec URlStruct
		lDevName := req.Header.Get("appname")
		_, lUid, lErr := sessionid.GetOldSessionUID(req, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "RU01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("RU01", "Something went wrong. Please try KRA or manual verification."))
			return
		}
		lDebug.SetReference(lUid)
	
		//get URL from toml
		var lAppName string

		if strings.EqualFold(lDevName, "web") {
			lAppName = tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "webAppName")
		} else if strings.EqualFold(lDevName, "mobile") {
			lAppName = tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "mobileAppName")
		}

		lReqID, lErr := nominee.GetRequestTableId(lUid, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "RU01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("RU01", "Something went wrong. Please try KRA or manual verification."))
			return
		}

		//re-direct the browser page to Digllocker site
		lURLRec.Statue = common.SuccessCode
		lURLRec.URL, lErr = digilockerapicall.GetRedirectUrl(lDebug, lAppName, lReqID)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "RU01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("RU01", "Something went wrong. Please try KRA or manual verification."))
			return
		}
		lRespData, lErr := json.Marshal(lURLRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "RU02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("RU02", "Something went wrong. Please try KRA or manual verification."))
			return
		}
		fmt.Fprint(w, string(lRespData))

		lDebug.Log(helpers.Statement, "ConstructUrl (-)")
	}

}
