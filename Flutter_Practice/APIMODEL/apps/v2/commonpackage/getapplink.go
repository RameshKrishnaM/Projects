package commonpackage

import (
	"encoding/json"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fmt"
	"net/http"
)

type AppLinkRespStruct struct {
	Url    string `json:"url"`    // URL for the application .
	Status string `json:"status"` // Status of the response.
}

func GetAppLink(w http.ResponseWriter, r *http.Request) {
	// Initialization and setup
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetAppVersion (+)")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	// Handling GET request
	if r.Method == http.MethodGet {
		var lAppResp AppLinkRespStruct
		lAppResp.Status = common.SuccessCode

		// Extracting user agent from the request header
		lUserAgent := r.UserAgent()
		lDebug.Log(helpers.Details, "lUserAgent --> ", lUserAgent)

		// Determining the operating system from the user agent
		lOperatingSystem := GetOSFromUserAgent(lDebug, lUserAgent)
		if lOperatingSystem != "Unknown" {
			lDebug.Log(helpers.Details, "lOperatingSystem --> IF", lOperatingSystem)
			// Fetching application updates based on the operating system
			lAppResp.Url = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "AppLink")
		} else {
			lDebug.Log(helpers.Details, "lOperatingSystem --> ELSE", lOperatingSystem)
			lDebug.Log(helpers.Elog, "CGAV02 ", "Unable to Find Device Name")
			fmt.Fprint(w, helpers.GetError_String("E", "Unable to Find Device Name "))
			return
		}

		// Encoding response data to JSON format
		lDebug.Log(helpers.Details, "lAppResp --> ", lAppResp)
		lData, lErr := json.Marshal(lAppResp)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "CGAV03 ", helpers.ErrReturn(lErr))
			fmt.Fprint(w, helpers.GetError_String("E", "Issue in Getting Datas! "))
			return
		} else {
			fmt.Fprint(w, string(lData))
		}
	}
	lDebug.Log(helpers.Statement, "GetAppVersion (-)")
}
