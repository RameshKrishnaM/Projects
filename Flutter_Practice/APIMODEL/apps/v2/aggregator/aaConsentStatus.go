package aggregator

import (
	"encoding/json"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/apps/v2/tokenvalidation"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	accaggregator "fcs23pkg/integration/v2/accAggregator"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

/*
Purpose: The purpose of this method is to check the status of a consent in the Consent Status API.
Arguments :N/A

 Response:
 On Success
   =========
    return ConsentStatus handles decrypting the URL and returning consent status

  On Error
   ========
    return error message

 Author: Logeshkumar
 Date: 19-Jun-2024

 Updatedby : Logeshkumar P
 UpdateDate : 22 Nov 2024

 Description : Modify the api to connect request and resonse in  Onemoney service
*/
func AAConsentStatus(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "ConsentStatus (+)")
	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Allow-Methods", http.MethodPost)
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")
	if strings.EqualFold(r.Method, http.MethodPost) {
		defer r.Body.Close()
		var lRespData DecryptUrlRespStruct
		// Retrieve the session ID and user ID from the request cookies
		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		lDebug.SetReference(lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "ACS001: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("ACS002", "something went wrong please try again later"))
			return
		}
		lReqData, lErr := CollectStatusRequest(lDebug, r)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "ACS002: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("ACS002", "something went wrong please try again later"))
			return
		}
		lRespData, lErr = CheckConsentStatus(lDebug, lReqData, lUid, lSid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "ACS003: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("ACS003", "something went wrong please try again later"))
			return
		}
		// Marshal the decrypted URL response back into JSON and send it as the final response
		lRespUrlData, lErr := json.Marshal(lRespData)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "ACS004: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("ACS004", "something went wrong please try again later"))
			return
		}
		// Log the successful response data and send the response back to the client
		lDebug.Log(helpers.Details, "Response ConsentStatus: ", string(lRespUrlData))
		fmt.Fprint(w, string(lRespUrlData))
		// Log the end of ConsentStatus handling
		lDebug.Log(helpers.Statement, "ConsentStatus (-)")
	}
}
func CheckConsentStatus(pDebug *helpers.HelperStruct, pReqData ConsentStatusRequest, pUid, pSid string) (DecryptUrlRespStruct, error) {
	// Log the incoming request data for debugging purposes
	pDebug.Log(helpers.Statement, "CheckConsentStatus (+)")
	var lRespData DecryptUrlRespStruct

	lCientID, lToken, lErr := tokenvalidation.GenerateToken(pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CCS001: "+lErr.Error())
		return lRespData, helpers.ErrReturn(lErr)
	}
	pReqData.ClientId = lCientID
	pReqData.Token = lToken
	pReqData.Source = tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "Source")

	lReqBody, lErr := json.Marshal(pReqData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CCS002: "+lErr.Error())
		return lRespData, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "Request  AAConsentStatus", pReqData)
	lResp, lErr := accaggregator.ConsentStatusService(pDebug, string(lReqBody))
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CCS003: "+lErr.Error())
		return lRespData, helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal([]byte(lResp), &lRespData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CCS004: "+lErr.Error())
		return lRespData, helpers.ErrReturn(lErr)
	}
	lRespData.Status = common.SuccessCode
	// Update the consent data status in the system using AADataStatusUpdate function

	// Expected response from One Money
	lActive := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ACTIVE")
	lRejected := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "REJECTED")
	lConsentError := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ConsentError")
	lRedirectError := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "RedirectError")
	// Check for specific error codes in the response data and log accordingly
	if lRespData.Data.ErrorCode != lActive {
		// lRespData.Status = common.ErrorCode
		if lRespData.Data.ErrorCode == lRejected {
			lRespData.ErrMsg = "user rejects the consent"
		} else if lRespData.Data.ErrorCode == lConsentError {
			lRespData.ErrMsg = "Consent request not found with the Account Aggregator"
		} else if lRespData.Data.ErrorCode == lRedirectError {
			lRespData.ErrMsg = "The redirection request has invalid data"
		}
		// Log the specific error code and message, then respond with an error
		lErr = AADataStatusUpdate(pDebug, pUid, pSid, lRespData)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CCS005: "+lErr.Error())
			return lRespData, helpers.ErrReturn(lErr)
		}
		pDebug.Log(helpers.Elog, "CCS006: "+lRespData.Data.ErrorCode+lRespData.ErrMsg)

		// return lRespData, helpers.ErrReturn(errors.New(lErrMsg))
	} else {
		lErr = AADataStatusUpdate(pDebug, pUid, pSid, lRespData)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CCS005: "+lErr.Error())
			return lRespData, helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "CheckConsentStatus (-)")
	return lRespData, nil
}

/* CollectConsentRequest processes an HTTP request to collect user consent data.

This function  provided HTTP request to construct a DecryptUrlRequest,
which contains user consent details.ensuring that appropriate error messages are
returned if the request is malformed or the expected data is missing.

Parameters:
  - pDebug (*helpers.HelperStruct): A pointer to a helper struct for debugging purposes.
  - pRequest (*http.Request): The HTTP request containing the user consent data.

Returns:
  - DecryptUrlRequest: A struct containing the parsed user consent details.
  - error: An error, if any occurred during the processing of the request. If no error, nil is returned.
*/
func CollectStatusRequest(pDebug *helpers.HelperStruct, pRequest *http.Request) (ConsentStatusRequest, error) {
	pDebug.Log(helpers.Statement, "CollectRequest (+)")

	var lConsentStatus ConsentStatusRequest

	// Step 1: Read the body of the incoming HTTP request
	lBody, lErr := ioutil.ReadAll(pRequest.Body)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CollectRequest:002 ", lErr.Error())
		return lConsentStatus, helpers.ErrReturn(lErr)
	}

	// Step 2: Unmarshal the JSON body into the DecryptUrlRequest struct
	lErr = json.Unmarshal(lBody, &lConsentStatus)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CollectRequest:003 ", lErr.Error())
		return lConsentStatus, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "CollectRequest (-)")
	return lConsentStatus, nil
}
