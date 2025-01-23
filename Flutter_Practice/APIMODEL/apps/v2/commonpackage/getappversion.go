package commonpackage

import (
	"encoding/json"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
	"strings"
)

// AppVersionRespStruct represents the structure for the response containing application version details.
type AppVersionRespStruct struct {
	Url         string `json:"url"`         // URL for the application .
	Version     string `json:"version"`     // Version of the application.
	ForceUpdate string `json:"forceUpdate"` // Indicates whether the update is mandatory.
	Status      string `json:"status"`      // Status of the response.
}

/*
   Purpose: This API is used to get the App version
   Request: Nil
   ========
   Header: N/A
   Response:
   On success
   ==========
   {
		"url": "https://flattrade.in/",
		"version": "1.0.0",
		"forceUpdate": "Y"
		"status": "S",
	}
	On Error
   =========
	{
		"status": "E",
		"statusCode": "EGLBD04 ",
		"msg": "Something went wrong. Please try again later."
	}
   Author: Ayyanar
   Date: '09-04-2024'
*/
func GetAppVersion(w http.ResponseWriter, r *http.Request) {
	// Initialization and setup
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetAppVersion (+)")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	// Handling GET request
	if r.Method == "GET" {
		var lAppResp AppVersionRespStruct
		lAppResp.Status = "S"

		// Extracting user agent from the request header
		lUserAgent := r.UserAgent()
		lDebug.Log(helpers.Details, "lUserAgent --> ", lUserAgent)

		// Determining the operating system from the user agent
		lOperatingSystem := GetOSFromUserAgent(lDebug, lUserAgent)
		if lOperatingSystem != "Unknown" {
			lDebug.Log(helpers.Details, "lOperatingSystem --> IF", lOperatingSystem)
			// Fetching application updates based on the operating system
			lErr := GetAppupdates(lDebug, lOperatingSystem, &lAppResp)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "CGAV01 ", helpers.ErrReturn(lErr))
				fmt.Fprint(w, helpers.GetError_String("E", "Unable to Get Version Updates "))
				return
			}
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

/*
   Purpose: This method is used to get os deatils from the useragent
   Parameters: *helpers.HelperStruct ,pUserAgent string
   Return : String
   Author: Ayyanar
   Date: '09-04-2024'
*/

func GetOSFromUserAgent(pDebug *helpers.HelperStruct, pUserAgent string) string {
	pDebug.Log(helpers.Statement, "GetOSFromUserAgent (+)")

	// Convert user agent string to lowercase for case-insensitive comparison
	pUserAgent = strings.ToLower(pUserAgent)

	// Check if user agent contains keywords to determine the operating system
	if strings.Contains(pUserAgent, "android") {
		return "Android"
	} else if strings.Contains(pUserAgent, "iphone") || strings.Contains(pUserAgent, "ipad") || strings.Contains(pUserAgent, "ios") {
		return "iOS"
	}

	// If the operating system cannot be determined from the user agent, return "Unknown"
	pDebug.Log(helpers.Statement, "GetOSFromUserAgent (-)")
	return "Unknown"
}

/*
   Purpose: GetAppupdates is a function to fetch application updates from the database based on the device OS.
   Parameters: *helpers.HelperStruct ,pDeviceOs string, pAppResp *AppVersionRespStruct
   Return : error
   Author: Ayyanar
   Date: '09-04-2024'
*/
func GetAppupdates(pDebug *helpers.HelperStruct, pDeviceOs string, pAppResp *AppVersionRespStruct) error {
	pDebug.Log(helpers.Statement, "GetAppupdates (+)")

	// SQL query to fetch application update details
	lCoreString := `select nvl(url,'') url ,nvl(force_update,'') force_update ,nvl(version,'') version 
					from ekyc_version_controller evc 
					where os = ?
					and status = 'Y'
					order by id desc 
					limit 1`

	// Executing the query
	lRows1, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pDeviceOs)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	defer lRows1.Close()
	for lRows1.Next() {
		// Processing query results and populating application response structure
		lErr := lRows1.Scan(&pAppResp.Url, &pAppResp.ForceUpdate, &pAppResp.Version)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "GetAppupdates (-)")
	return nil
}
