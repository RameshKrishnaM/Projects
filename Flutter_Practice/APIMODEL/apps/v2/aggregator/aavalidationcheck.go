package aggregator

import (
	"encoding/json"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
	"strings"
)

/*
Purpose: The purpose of this method is to validate the account aggregation status by retrieving document and consent IDs based on the session ID from the request.
Arguments:
    - w http.ResponseWriter: The response writer to send the response back to the client.
    - r *http.Request: The incoming HTTP request containing session information.

Response:
    On Success
    ==========
    Returns a JSON response containing:
        - Status: string indicating success.
        - DocID: string representing the document ID.
        - ConsentID: string representing the consent ID.
        - ConsentHandleID: string representing the consent handle ID.

    On Error
    ========
    Returns an error message in JSON format indicating the error code and a description of the issue.

Author: Logeshkumar
Date: 28-Jun-2024
*/
func AAValidationCheck(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "AAValidationCheck (+)")
	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-XSRF-TOKEN, Authorization, credentials")
	if strings.EqualFold(r.Method, "POST") {
		var lResp AAValidationStruct
		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "AVC002: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("AVC001", "Something went wrong please try again later"))
			return
		}
		_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(r, lDebug, common.EKYCCookieName, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "AVC002: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("AVC002", "Something went wrong please try again later"))
			return
		}
		lResp, lErr = AAGetDocIDData(lDebug, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "AVC003: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("AVC003", "Something went wrong please try again later"))
			return
		}
		if lTestUserFlag == "0" {
			lResp.TestUser = "Y"
		} else {
			lResp.TestUser = "N"
		}
		lResp.Status = common.SuccessCode
		lRespData, lErr := json.Marshal(lResp)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "AVC004: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("AVC004", "Something went wrong please try again later"))
			return
		}
		fmt.Fprint(w, string(lRespData))
		lDebug.Log(helpers.Statement, "AAValidationCheck (-)")
	}
}
