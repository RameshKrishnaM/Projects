package panstatus

import (
	"encoding/json"
	"fcs23pkg/apps/v2/address/kra"
	"fcs23pkg/coresettings"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/kraapi"
	"fcs23pkg/tomlconfig"
	"fmt"
	"net/http"
	"strings"
)

func handleKraVerification(pDebug *helpers.HelperStruct, pReq *http.Request, pTestUserRec TestuserStruct, pSessionId, pUid string, pPanRecAPI PanDataInfo, pNameAsPerKRA string) (RespStruct, string, string) {
	pDebug.Log(helpers.Statement, "handleKraVerification(+)")
	var pPanRespRec RespStruct
	var lStatusCode, lErrmsg string

	_, lErr := HandleKraVerify(pDebug, pUid, pSessionId, pPanRecAPI.PanNumber, pPanRecAPI.PanDOB, pReq)
	if lErr != nil {
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}

	var lTempName interface{}
	var lDataFlag bool
	lTempName = tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "KraName")
	lDataFlag = lTempName != ""
	if lDataFlag {
		pPanRecAPI.PanName = fmt.Sprintf("%v", lTempName)
	} else {
		pPanRecAPI.PanName = pNameAsPerKRA
	}

	var lTempDOB interface{}
	var lDOBFlag bool
	lTempDOB = tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "GivenDOB")
	lDOBFlag = lTempDOB != ""
	if lDOBFlag {
		pPanRecAPI.PanDOB = fmt.Sprintf("%v", lTempDOB)
	}

	lCombinationFlag := KRA
	pPanRespRec, lStatusCode, lErrmsg = PanValidation(pDebug, pPanRecAPI, pPanRespRec, pSessionId, pUid, lCombinationFlag)
	if lStatusCode != "" && lErrmsg != "" {
		if !pTestUserRec.isTestUser {
			lreDirectUrl, lErr := RedirectUrl(pDebug, pPanRecAPI.AppName, pUid)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "PSPPV16 ", lErr.Error())
				return pPanRespRec, "", helpers.ErrPrint(lErr)
			} else {
				return pPanRespRec, ReDirectUrl, lreDirectUrl
			}
		} else {
			return pPanRespRec, lStatusCode, lErrmsg
		}
	}
	// lErr = UpdateCombinations(pDebug, pDb, pUid, lCombinationFlag)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return pPanRespRec, "", helpers.ErrPrint(lErr)
	// }

	pDebug.Log(helpers.Statement, "handleKraVerification(-)")
	return pPanRespRec, lStatusCode, lErrmsg
}

func HandleKraVerify(pDebug *helpers.HelperStruct, pUid, pSessionId, pPanNo, pDob string, pReq *http.Request) (string, error) {
	pDebug.Log(helpers.Statement, "HandleKraVerify(+)")
	var lErr error
	var lUserInfoRec kra.UserdataStruct
	var lFullDetailsFlag, lUserKRAName string
	var lKraStatusRec kra.KraStatusStruct
	var lKRAServiceResp kra.FinalAddressStruct

	lUserInfoRec.PanNo = pPanNo
	lUserInfoRec.DOB = pDob
	lUserInfoRec.AppName = tomlconfig.GtomlConfigLoader.GetValueString("kra", "appname")

	// SQL query to retrieve KRA reference ID
	_, lRefId, lStatusCode, lFullDetailsFlag, _, lErr := kra.GetRefIdInfo(pUid, lUserInfoRec, pDebug)
	pDebug.Log(helpers.Details, "lRefId", lRefId)
	pDebug.Log(helpers.Details, "lStatusCode", lStatusCode)
	pDebug.Log(helpers.Details, "lFullDetailsFlag", lFullDetailsFlag)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	if lStatusCode == "" || lRefId == "" {
		lUserKRAName, lErr = KraStatusVerify(pDebug, pUid, pSessionId, pReq, lUserInfoRec, lKraStatusRec, lKRAServiceResp)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return "", helpers.ErrReturn(lErr)
		}
		return lUserKRAName, nil
	} else {
		lErr = FetchKraFullDetails(pDebug, lStatusCode, lFullDetailsFlag, lRefId, pUid, pSessionId, pReq, lUserInfoRec, lKRAServiceResp)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return "", helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "HandleKraVerify(-)", lKraStatusRec.APP_NAME)
	return lKraStatusRec.APP_NAME, nil
}

func KraStatusVerify(pDebug *helpers.HelperStruct, pUid, pSessionId string, pReq *http.Request, pUserInfoRec kra.UserdataStruct, pKraStatusRec kra.KraStatusStruct, pKRAServiceResp kra.FinalAddressStruct) (string, error) {
	pDebug.Log(helpers.Statement, "KraStatusVerify(+)")
	var lErrorRec helpers.Error_Response
	var lErr error
	// var lModifyAppStatusArr []string
	lErr = kra.KRADataInsertion(pDebug, pKRAServiceResp, "", "", "N", "", "", pUid, pSessionId, "", pReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	// Marshal user information to JSON
	lUserInfo, lErr := json.Marshal(pUserInfoRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	// Fetch KRA information using PAN information
	lKRAStatusResponse, lErr := kraapi.GetKRAInfo(pDebug, string(lUserInfo), "KRASTATUS")
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", helpers.ErrReturn(lErr)
	} else {
		if strings.Contains(lKRAStatusResponse, "statusCode") && strings.Contains(lKRAStatusResponse, "msg") {
			lErr = json.Unmarshal([]byte(lKRAStatusResponse), &lErrorRec)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return "", helpers.ErrReturn(lErr)
			}
			pDebug.Log(helpers.Elog, lErrorRec.ErrorMessage)
			return "", nil
		} else {
			// Unmarshal the KRA response to the KraStatus Struct
			lErr = json.Unmarshal([]byte(lKRAStatusResponse), &pKraStatusRec)
			pDebug.Log(helpers.Details, "lKraStatusRec", pKraStatusRec)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return "", helpers.ErrReturn(lErr)
			} else {
				pKRAServiceResp.KRAReferenceid = pKraStatusRec.Ref_Id
				lErr = kra.KRADataInsertion(pDebug, pKRAServiceResp, pKraStatusRec.APP_AGENCY_NAME, pKraStatusRec.APP_STATUS, "Y", "", pKraStatusRec.APP_NAME, pUid, pSessionId, pKraStatusRec.APP_UPDT_STATUS, pReq)
				if lErr != nil {
					pDebug.Log(helpers.Elog, lErr.Error())
					return "", helpers.ErrReturn(lErr)
				}
			}
		}
	}
	pDebug.Log(helpers.Statement, "KraStatusVerify(-)")
	return pKraStatusRec.APP_NAME, nil
}

func FetchKraFullDetails(pDebug *helpers.HelperStruct, pStatusCode, pFullDetailsFlag, pRefId, pUid, pSessionId string, pReq *http.Request, pUserInfoRec kra.UserdataStruct, pKRAServiceResp kra.FinalAddressStruct) error {
	pDebug.Log(helpers.Statement, "FetchKraFullDetails(+)")
	var lErr error
	var lErrorRec helpers.Error_Response

	//Commented Reason (Fetch all Kra Details for all the status code )

	var lOldAppStatusFlag bool
	var lOldStatusArr []string

	// Get Records from coresettings
	OldAppStatus := tomlconfig.GtomlConfigLoader.GetValueString("kra", "OldAppStatus")
	lOldStatuStr := coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, OldAppStatus)
	//unmarshal the json
	lErr = json.Unmarshal([]byte(lOldStatuStr), &lOldStatusArr)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lOldAppStatusFlag = false
	pDebug.Log(helpers.Details, lOldStatusArr, "lOldStatusArr")
	for _, appStatus := range lOldStatusArr {
		if pStatusCode == appStatus {
			lOldAppStatusFlag = true
			break
		}
	}

	//IF THE ABOVE CODE UNCOMMENTED THEN NEED TO ADD THE CONDITION HERE lOldAppStatusFlag WITH AND CONDITION
	if pFullDetailsFlag != "Y" && lOldAppStatusFlag {
		pUserInfoRec.RefId = pRefId
		lErr = kra.KRADataInsertion(pDebug, pKRAServiceResp, "", "", "N", "", "", pUid, pSessionId, "", pReq)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
		pDebug.Log(helpers.Details, "KRA Reference id", pUserInfoRec.RefId)
		// Marshal user information to JSON
		lUserInfo, lErr := json.Marshal(pUserInfoRec)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
		lResponse, lErr := kraapi.GetKRAInfo(pDebug, string(lUserInfo), "KRADETAILS")
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
		if strings.Contains(lResponse, "statusCode") && strings.Contains(lResponse, "msg") {
			lErr = json.Unmarshal([]byte(lResponse), &lErrorRec)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
			// return   lErrorRec.ErrorMessage --------------------------------------------------------DOUBT
		} else {
			// Unmarshal the KRA response to the FinalAddressStruct
			lErr = json.Unmarshal([]byte(lResponse), &pKRAServiceResp)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
			// Log details about the retrieved address information
			pDebug.Log(helpers.Details, pKRAServiceResp.KRAReferenceid, "lKRAServiceResp.FullDetailsRefId", "lKRAServiceResp.PdfDocID", pKRAServiceResp.PdfDocID)

			// Check if RefId and AgencyName are available, insert them into the database
			if pKRAServiceResp.KRAReferenceid != "" && pKRAServiceResp.AgencyName != "" && (pKRAServiceResp.CORAddress1 != "" || pKRAServiceResp.PERAddress1 != "") {
				lErr := kra.KRADataInsertion(pDebug, pKRAServiceResp, pKRAServiceResp.AgencyName, "", "Y", "Y", pKRAServiceResp.Name, pUid, pSessionId, "", pReq)
				if lErr != nil {
					pDebug.Log(helpers.Elog, lErr.Error())
					return helpers.ErrReturn(lErr)
				}
			}
		}
	}
	pDebug.Log(helpers.Statement, "FetchKraFullDetails(-)")
	return nil
}

func HandlePanNo(pDebug *helpers.HelperStruct, pPanNoAsPerPANXML, pDOBAsPerPANXML, pUid, pSessionId string, pReq *http.Request) error {
	pDebug.Log(helpers.Statement, "HandlePanNo(+)")
	var lKraStatusRec kra.KraStatusStruct
	var lKRAServiceResp kra.FinalAddressStruct
	var lUserInfoRec kra.UserdataStruct

	var lErr error
	lUserInfoRec.PanNo = pPanNoAsPerPANXML
	lUserInfoRec.DOB = strings.ReplaceAll(pDOBAsPerPANXML, "-", "/")
	lUserInfoRec.AppName = tomlconfig.GtomlConfigLoader.GetValueString("kra", "appname")

	_, lErr = KraStatusVerify(pDebug, pUid, pSessionId, pReq, lUserInfoRec, lKraStatusRec, lKRAServiceResp)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	// SQL query to retrieve KRA reference ID
	_, lRefId, lStatusCode, _, _, lErr := kra.GetRefIdInfo(pUid, lUserInfoRec, pDebug)
	pDebug.Log(helpers.Details, "lRefId", lRefId)
	pDebug.Log(helpers.Details, "lStatusCode", lStatusCode)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lErr = FetchKraFullDetails(pDebug, lStatusCode, "N", lRefId, pUid, pSessionId, pReq, lUserInfoRec, lKRAServiceResp)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "HandlePanNo(-)")
	return nil
}
