package aggregator

import (
	"encoding/base64"
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/apps/v2/tokenvalidation"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/pdfgenerate"
	accaggregator "fcs23pkg/integration/v2/accAggregator"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

/*
Purpose: The purpose of this method is to fetch the PDF statement through the Fetch PDF Statement API.
 Arguments:
    - w http.ResponseWriter: The response writer to send the response back to the client.
    - r *http.Request: The incoming HTTP request containing the body with user information.

 Response:
    On Success
    ==========
    Returns a JSON response containing:
        - PDF statement data in the expected format.

    On Error
    ========
    Returns an error message in JSON format indicating the error code and a description of the issue.

 Author: Logeshkumar
 Date: 19-Jun-2024

 **********************************************

 Updatedby : Logeshkumar P
 UpdateDate : 22 Nov 2024

 Description : Modify the api to connect request and resonse in  Onemoney service
*/
func AAFetchStatement(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "FetchPdfStatement (+)")
	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Allow-Methods", http.MethodPost)
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold(r.Method, http.MethodPost) {
		defer r.Body.Close()
		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "FDS001: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("FDS001", "Something went wrong please try again later"))
			return
		}
		lReqData, lErr := CollectStatementRequest(lDebug, r)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "FDS002: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("FDS002", "Something went wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "Request FetchPdfStatement", lReqData)

		lstatementResp, lErr := AAConsentFetchService(lDebug, lUid, lSid, lReqData)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "FDS005: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("FDS005", "Something went wrong please try again later"))
			return
		}
		lResponseData, lErr := json.Marshal(lstatementResp)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "FDS006: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("FDS006", "Something went wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "Response FetchPdfStatement", string(lResponseData))
		fmt.Fprint(w, string(lResponseData))
	}
	lDebug.Log(helpers.Statement, "FetchPdfStatement (-)")
}

/* CollectConsentRequest processes an HTTP request to collect user consent data.

This function  provided HTTP request to construct a UserInfoReqStruct,
which contains user consent details.ensuring that appropriate error messages are
returned if the request is malformed or the expected data is missing.

Parameters:
  - pDebug (*helpers.HelperStruct): A pointer to a helper struct for debugging purposes.
  - pRequest (*http.Request): The HTTP request containing the user consent data.

Returns:
  - UserInfoReqStruct: A struct containing the parsed user consent details.
  - error: An error, if any occurred during the processing of the request. If no error, nil is returned.
*/
func CollectStatementRequest(pDebug *helpers.HelperStruct, pRequest *http.Request) (UserInfoReqStruct, error) {
	pDebug.Log(helpers.Statement, "CollectRequest (+)")

	// Step 1: Read the request body.
	var lErr error
	var lUserInfo UserInfoReqStruct
	lBody, lErr := ioutil.ReadAll(pRequest.Body)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CollectRequest:002 ", lErr.Error())
		return lUserInfo, helpers.ErrReturn(lErr)
	} else {
		// Step 2: Unmarshal the request body into the UserInfoReqStruct.
		lErr = json.Unmarshal(lBody, &lUserInfo)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CollectRequest:003 ", lErr.Error())
			return lUserInfo, helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "CollectRequest (-)")

	return lUserInfo, nil
}

/*
Purpose:
 The purpose of this method is to fetch the statement data based on the users consent and handle the required operations to generate the PDF statement.
Arguments:
    - pDebug: A pointer to a HelperStruct for logging and debugging.
    - pUid: A string representing the user ID.
    - pSid: A string representing the session ID.
    - pReqData: A UserInfoReqStruct containing the request data necessary for fetching the statement.


 Author: Logeshkumar
 Date: 22 Nov 2024
*/
func AAConsentFetchService(pDebug *helpers.HelperStruct, pUid, pSid string, pReqData UserInfoReqStruct) (AAStatementRespStruct, error) {
	pDebug.Log(helpers.Statement, "AAConsentFetchService (+)")
	var lReq UserFiFetchReqStruct
	var lStatementResp AAStatementRespStruct
	var lResp StatementRespStruct
	var lJsonRespData AAJsonResponseStruct
	lStatementResp.Status = common.SuccessCode

	lMobileNumber, lBankName, lErr := AAGetUserData(pDebug, pUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CFS001: "+lErr.Error())
		return lStatementResp, helpers.ErrReturn(lErr)
	}

	lCientID, lToken, lErr := tokenvalidation.GenerateToken(pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG002: "+lErr.Error())
		return lStatementResp, helpers.ErrReturn(lErr)
	}

	lReq.MobileNumber = lMobileNumber
	lReq.BankName = lBankName
	lReq.ConsentHandle = pReqData.ConsentHandle
	lReq.MaskAccount = pReqData.MaskAccount
	lReq.UID = pUid
	lReq.ClientId = lCientID
	lReq.Token = lToken
	lReq.Source = tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "Source")

	lReqBody, lErr := json.Marshal(lReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG003: "+lErr.Error())
		return lStatementResp, helpers.ErrReturn(lErr)
	}

	lRespData, lErr := accaggregator.ConsentFetchService(pDebug, string(lReqBody))
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG004: "+lErr.Error())
		return lStatementResp, helpers.ErrReturn(lErr)
	}

	lErr = json.Unmarshal([]byte(lRespData), &lResp)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG005: "+lErr.Error())
		return lStatementResp, helpers.ErrReturn(lErr)
	}

	if lResp.Status == common.ErrorCode {
		pDebug.Log(helpers.Elog, "CUG006: "+lResp.ErrCode+lResp.ErrMsg)
		return lStatementResp, helpers.ErrReturn(errors.New(lResp.ErrMsg))
	}

	if lResp.PDFEncode == "" || lResp.JSONEncode == "" {
		pDebug.Log(helpers.Elog, "CFS007: "+"No Data Found Given Consent")
		return lStatementResp, helpers.ErrReturn(errors.New("no Data Found given consent"))
	}

	lJsonBody, lErr := base64.StdEncoding.DecodeString(lResp.JSONEncode)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG008: "+lErr.Error())
		return lStatementResp, helpers.ErrReturn(lErr)
	}

	lErr = json.Unmarshal(lJsonBody, &lJsonRespData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CUG009: "+lErr.Error())
		return lStatementResp, helpers.ErrReturn(lErr)
	}

	lJsonStData := AAGetJsonData(pReqData.MaskAccount, lJsonRespData)
	var lFileSave pdfgenerate.FileSaveStruct
	var lFileSaveArr []pdfgenerate.FileSaveStruct

	lJsonKey := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "JSONFileKey")
	lPdfKey := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "PDFFileKey")
	//Sava file Request Structure
	lFileSave.FileName = `AA_PDF` + pReqData.MobileNumber + `.pdf`
	lFileSave.File = lResp.PDFEncode
	lFileSave.FileType = tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "PDFFileType")
	lFileSave.FileKey = lPdfKey
	lFileSave.Process = tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "Process")
	lFileSaveArr = append(lFileSaveArr, lFileSave)

	lFileSave.FileName = `AA_JSON` + pReqData.MobileNumber + `.json`
	lFileSave.File = lResp.JSONEncode
	lFileSave.FileType = tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "Content_value")
	lFileSave.FileKey = lJsonKey
	lFileSave.Process = tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "Process")
	lFileSaveArr = append(lFileSaveArr, lFileSave)
	lSaveFileResp, lErr := pdfgenerate.Savefile(pDebug, lFileSaveArr)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CFS010: "+lErr.Error())
		return lStatementResp, helpers.ErrReturn(lErr)
	}

	var lPdfDocId string
	var lJsonDcoId string
	if lSaveFileResp.Status == common.SuccessCode {
		if lSaveFileResp.FileDocID != nil {
			for _, lDoc := range lSaveFileResp.FileDocID {
				if lDoc.FileKey == lPdfKey {
					lPdfDocId = lDoc.DocID
				}
				if lDoc.FileKey == lJsonKey {
					lJsonDcoId = lDoc.DocID
				}
			}
		}
	}
	pDebug.Log(helpers.Details, "lPdfDocId", lPdfDocId)
	pDebug.Log(helpers.Details, "lJsonDocId", lJsonDcoId)

	lUserInfo := UserBankInfo(pDebug, lJsonStData, lStatementResp, lJsonDcoId, lPdfDocId)
	lStatus, lErr := AAStatementVerify(lJsonRespData.Data)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CFS011: "+lErr.Error())
		return lStatementResp, helpers.ErrReturn(lErr)
	}
	if !lStatus {
		lUserInfo.StatementStatus = common.StatusNew
		lUserInfo.TransError = common.ErrorCode
		lUserInfo.TransErrorStatus = "statement not full fill the six month"
		lStatementResp.ErrCode = common.ErrorCode
		lStatementResp.ErrMsg = "statement not full fill the six month"
		lStatementResp.Msg = "statement not full fill the six month"
	}
	lProofType := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ProofType")
	lErr = AAInsertDocIdData(pDebug, lProofType, lPdfDocId, pUid, pSid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CFS012: "+lErr.Error())
		return lStatementResp, helpers.ErrReturn(lErr)
	}

	lErr = AADataFetchUpdate(pDebug, pUid, pSid, lResp.ConsentID, pReqData.ConsentHandle, lPdfDocId, lUserInfo)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CFS013: "+lErr.Error())
		return lStatementResp, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "AAConsentFetchService (-)")
	return lStatementResp, nil
}

/*
Purpose: The purpose of this method is to fetch the statement data based on the user's consent and handle the required operations to generate the PDF statement.
Arguments:
    - pDebug: A pointer to a HelperStruct for logging and debugging.
    - pUid: A string representing the user ID.
    - pSid: A string representing the session ID.
    - pReqData: A UserInfoReqStruct containing the request data necessary for fetching the statement.


Author: Logeshkumar
Date: 19-Jun-2024
*/
func AAConsentFetchStament(pDebug *helpers.HelperStruct, pUid, pSid string, pReqData UserInfoReqStruct) (AAStatementRespStruct, error) {
	pDebug.Log(helpers.Statement, "AAConsentFetchStament (+)")
	var lConsentListData ResponseConsentList
	var lJsonRespData AAJsonResponseStruct
	var lPdfReq PDFDownloadReqStruct
	var lJsonReqData GetAllLatestFiDataStruct
	var lstatementResp AAStatementRespStruct
	lstatementResp.Status = common.SuccessCode
	lMobileNumber, lBankName, lErr := AAGetUserData(pDebug, pUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CFS001: "+lErr.Error())
		return lstatementResp, helpers.ErrReturn(lErr)
	}
	pReqData.MobileNumber = lMobileNumber
	pReqData.BankName = lBankName
	lResp, lErr := accaggregator.GetConsentDataList(pDebug, pUid, pReqData.MobileNumber)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CFS002: "+lErr.Error())
		return lstatementResp, helpers.ErrReturn(lErr)

	}

	lErr = json.Unmarshal([]byte(lResp), &lConsentListData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CFS003: "+lErr.Error())
		return lstatementResp, helpers.ErrReturn(lErr)

	} else {

		lConsentID := FindConsentData(&lConsentListData, pReqData.ConsentHandle)
		if lConsentID == "" {
			pDebug.Log(helpers.Elog, "CFS004: ConsentHandle is empty or null")
			return lstatementResp, helpers.ErrReturn(errors.New("somethings went wrong please try again later"))

		}
		lErr = AAFetchUpdateConsent(pDebug, pUid, pSid, lConsentID, pReqData.ConsentHandle)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CFS005: "+lErr.Error())
			return lstatementResp, helpers.ErrReturn(lErr)
		}
		lPdfReq.ConsentID = lConsentID

		// var lMatchRecord MatchFields
		lJsonReqData.ConsentID = lConsentID
		// lJsonReqData.ReturnAllData = false
		// lMatchRecord.FieldName = "maskedAccountNumber"
		// lMatchRecord.FieldValue = pReqData.MaskAccount
		// lMatchRecord.Criteria = "="
		// lJsonReqData.UniqueRecord = append(lJsonReqData.UniqueRecord, lMatchRecord)

		lReqJsonData, lErr := json.Marshal(lJsonReqData)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CFS006: "+lErr.Error())
			return lstatementResp, helpers.ErrReturn(lErr)

		}
		lRequestBody := string(lReqJsonData)
		lRespJsonData, lErr := accaggregator.AAStatementJsonData(pDebug, lRequestBody)
		pDebug.Log(helpers.Details, "Response FetchJsonData", lRespJsonData)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CFS007: "+lErr.Error())
			return lstatementResp, helpers.ErrReturn(lErr)

		}

		lErr = json.Unmarshal([]byte(lRespJsonData), &lJsonRespData)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CFS008: "+lErr.Error())
			return lstatementResp, helpers.ErrReturn(lErr)

		}
		lJsonStData := AAGetJsonData(pReqData.MaskAccount, lJsonRespData)
		if lJsonStData.LinkReferenceNumber == "" {
			pDebug.Log(helpers.Elog, "CFS009: ", "ljsondata no data")
			return lstatementResp, helpers.ErrReturn(errors.New(lJsonRespData.Message))
		} else {
			lLinkRefNo := lJsonStData.LinkReferenceNumber
			lPdfReq.LinkRefNumber = append(lPdfReq.LinkRefNumber, lLinkRefNo)
			lPdfReqData, lErr := json.Marshal(lPdfReq)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CFS010: "+lErr.Error())
				return lstatementResp, helpers.ErrReturn(lErr)
			}
			lRespData, lErr := accaggregator.StatementPdfDownload(pDebug, string(lPdfReqData))
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CFS011: "+lErr.Error())
				return lstatementResp, helpers.ErrReturn(lErr)
			}
			lJsonBase64 := base64.StdEncoding.EncodeToString([]byte(lRespJsonData))
			lPdfBase64 := base64.StdEncoding.EncodeToString([]byte(lRespData))
			var lFileSave pdfgenerate.FileSaveStruct
			var lFileSaveArr []pdfgenerate.FileSaveStruct
			if lJsonBase64 != "" {
				lFileSave.FileName = `AA_PDF` + pReqData.MobileNumber + `.pdf`
				lFileSave.File = lPdfBase64
				lFileSave.FileType = "application/pdf"
				lFileSave.FileKey = "AA_PDF"
				lFileSave.Process = "Ekyc_proof_upload"
				lFileSaveArr = append(lFileSaveArr, lFileSave)
			}
			if lPdfBase64 != "" {
				lFileSave.FileName = `AA_JSON` + pReqData.MobileNumber + `.json`
				lFileSave.File = lJsonBase64
				lFileSave.FileType = "application/json"
				lFileSave.FileKey = "AA_JSON"
				lFileSave.Process = "Ekyc_proof_upload"
				lFileSaveArr = append(lFileSaveArr, lFileSave)
			}
			lSaveFileResp, lErr := pdfgenerate.Savefile(pDebug, lFileSaveArr)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CFS012: "+lErr.Error())
				return lstatementResp, helpers.ErrReturn(lErr)
			}
			var lPdfDocId string
			var lJsonDcoId string
			if lSaveFileResp.Status == common.SuccessCode {
				if lSaveFileResp.FileDocID != nil {
					for _, lDoc := range lSaveFileResp.FileDocID {
						if lDoc.FileKey == "AA_PDF" {
							lPdfDocId = lDoc.DocID
						}
						if lDoc.FileKey == "AA_JSON" {
							lJsonDcoId = lDoc.DocID
						}
					}
				}
			}
			pDebug.Log(helpers.Details, "lPdfDocId", lPdfDocId)
			pDebug.Log(helpers.Details, "lJsonDocId", lJsonDcoId)

			lUserInfo := UserBankInfo(pDebug, lJsonStData, lstatementResp, lJsonDcoId, lPdfDocId)
			lStatus, lErr := AAStatementVerify(lJsonRespData.Data)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CFS013: "+lErr.Error())
				return lstatementResp, helpers.ErrReturn(lErr)
			}
			if !lStatus {
				lUserInfo.StatementStatus = common.StatusNew
				lUserInfo.TransError = common.ErrorCode
				lUserInfo.TransErrorStatus = "statement not full fill the six month"
				lstatementResp.ErrCode = common.ErrorCode
				lstatementResp.ErrMsg = "statement not full fill the six month"
				lstatementResp.Msg = "statement not full fill the six month"
			}
			lProofType := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ProofType")
			lErr = AAInsertDocIdData(pDebug, lProofType, lPdfDocId, pUid, pSid)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CFS014: "+lErr.Error())
				return lstatementResp, helpers.ErrReturn(lErr)
			}

			lErr = AADataFetchUpdate(pDebug, pUid, pSid, lConsentID, pReqData.ConsentHandle, lPdfDocId, lUserInfo)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CFS015: "+lErr.Error())
				return lstatementResp, helpers.ErrReturn(lErr)

			}
		}
		return lstatementResp, nil
	}
}
