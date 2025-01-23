package panstatus

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	panstatusverify "fcs23pkg/integration/v2/panStatusVerify"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

type PanDataInfo struct {
	PanNumber  string `json:"panno"`
	PanName    string `json:"panname"`
	PanDOB     string `json:"pandob"`
	VerifyFlag string `json:"verifyflag"`
	AppName    string `json:"appname"`
	DigiID     string `json:"digiid"`
}

type PanDataStruct struct {
	PAN         string `json:"pan"`
	Name        string `json:"name"`
	FatherName  string `json:"fathername"`
	DateOfBirth string `json:"dob"`
}
type PanStatusApiStruct struct {
	AppName    string          `json:"app_name"`
	PanDataArr []PanDataStruct `json:"pan_data_arr"`
}

type PanApiRespStruct struct {
	PAN               string `json:"pan"`
	Name              string `json:"name"`
	FatherName        string `json:"fathername"`
	DateOfBirth       string `json:"dob"`
	PanStatus         string `json:"pan_status"`
	PanStatusDesc     string `json:"pan_status_desc"`
	SeedingStatus     string `json:"seeding_status"`
	SeedingStatusDesc string `json:"seeding_status_desc"`
	ReferenceId       string `json:"reference_id"`
}
type BatchRepsStruct struct {
	APIResponseCode     string             `json:"response_Code"`
	APIResponseCodeDesc string             `json:"response_Code_Desc"`
	BatchId             string             `json:"batch_id"`
	OutputData          []PanApiRespStruct `json:"outputData"`
	Status              string             `json:"status"`
	Errmsg              string             `json:"errMsg"`
}
type PanFinalStruct struct {
	PanResponseArr []BatchRepsStruct `json:"pan_response_arr"`
	Status         string            `json:"status"`
}

type RespStruct struct {
	PanData []PanResponseStruct `json:"pandata"`
	Status  string              `json:"status"`
}

type PanResponseStruct struct {
	Pan               string `json:"pan"`
	PanXmlPanNO       string `json:"panxmlpanno"`
	Name              string `json:"name"`
	NameFlag          string `json:"nameflag"`
	FatherName        string `json:"fathername"`
	FatherNameFlag    string `json:"fathernameflag"`
	Dob               string `json:"dob"`
	DobFlag           string `json:"dobflag"`
	PanStatus         string `json:"pan_status"`
	PanStatusDesc     string `json:"pan_status_desc"`
	SeedingStatus     string `json:"seeding_status"`
	SeedingStatusDesc string `json:"seeding_status_desc"`
	ReferenceId       string `json:"reference_id"`
	BatchId           string `json:"batch_id"`
	URL               string `json:"redirecturl"`
	Status            string `json:"status"`
}

const (
	KraStatusVerifyMode = "KRAVERIFY"
	DOBVerifyMode       = "DOBFLAG"
	KRA                 = "KRA"
	USER                = "USER"
	PANXML              = "PANXML"
	AADHARXML           = "AADHARXML"
	AADHARXML_USER      = "AADHARXML-USER"
	ReDirectUrl         = "reDirectUrl"
)

func GetPanStatus(w http.ResponseWriter, req *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)

	lDebug.Log(helpers.Statement, "GetPanStatus (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	(w).Header().Set("Content-Type", "application/json")

	if req.Method == "POST" {
		var lPanRespRec RespStruct
		var lErrcode, lMsg string
		var lDatas []byte

		lPanRespRec.Status = "S"
		lTestUserRec, lErr := TestUserEntry(req, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GPS01 ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		}
		// lPanRespRec.LastName = lTestUserName

		lPanRespRec, lErrcode, lMsg = PanStatusVerification(req, lDebug, lTestUserRec)
		lDebug.Log(helpers.Details, lErrcode, "lErrcode")
		if lMsg != "" {
			lDebug.Log(helpers.Elog, "GPS02 ", lMsg)
			if lErrcode == "" {
				fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			} else {
				fmt.Fprint(w, helpers.GetError_String(lErrcode, lMsg))
			}
			return
		}
		lDebug.Log(helpers.Details, lPanRespRec, "lPanRespRec")
		if len(lPanRespRec.PanData) == 1 {
			lPanRespRec.PanData[0].Status = common.SuccessCode
			lDatas, lErr = json.Marshal(lPanRespRec.PanData[0])
			if lErr != nil {
				lDebug.Log(helpers.Elog, "GPS03 ", lErr)
				fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
				return
			}
		} else {
			lDatas, lErr = json.Marshal(lPanRespRec)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "GPS04 ", lErr)
				fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
				return
			}
		}
		fmt.Fprint(w, string(lDatas))

	} else {
		fmt.Fprint(w, helpers.GetError_String("Invalid Method Type", "Kindly try with POST Method"))
	}
	lDebug.Log(helpers.Statement, "GetPanStatus (-)")
}

type TestuserStruct struct {
	Pan, Dob, Name string
	isTestUser     bool
}

func PanStatusVerification(pReq *http.Request, pDebug *helpers.HelperStruct, pTestUserRec TestuserStruct) (RespStruct, string, string) {
	pDebug.Log(helpers.Statement, "PanStatusVerification(+)")
	var pPanRespRec RespStruct
	var lStatusCode, lErrmsg string

	// Step 1: Get Session ID and UID
	lSessionId, lUid, lErr := sessionid.GetOldSessionUID(pReq, pDebug, common.EKYCCookieName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV03 ", lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}

	// Step 2: Read Input
	lPanRecAPI, lErr := ReadInput(pReq, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV01 ", lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	if lPanRecAPI.PanNumber != "" && lPanRecAPI.DigiID == "" {
		lPanVerifyStatus, lPanVerifyError := ValidatePanReq(pDebug, lPanRecAPI, pTestUserRec, lUid)
		if lPanVerifyError != "" {
			pDebug.Log(helpers.Elog, "PSPPV19 ", lPanVerifyError)
			return pPanRespRec, lPanVerifyStatus, lPanVerifyError
		}
	}

	if lPanRecAPI.DigiID != "" && lPanRecAPI.VerifyFlag == ReDirectUrl {
		pPanRespRec, lStatusCode, lErrmsg = DigilockerVerify(pDebug, lUid, lSessionId, lPanRecAPI.DigiID, pReq, pPanRespRec, pTestUserRec)
		pDebug.Log(helpers.Elog, lStatusCode, lErrmsg)
		return pPanRespRec, lStatusCode, lErrmsg
	} else {
		lPanNo, _, lErr := getPanNumber(lUid, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return pPanRespRec, "", helpers.ErrPrint(lErr)
		}
		if lPanNo != lPanRecAPI.PanNumber {
			lPanRecAPI.VerifyFlag = KraStatusVerifyMode
		}
		// Step 5: Update PAN Info in DB
		lErr = updatePANNo(pDebug, lPanRecAPI, lUid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "PSPPV05 ", lErr.Error())
			return pPanRespRec, "", helpers.ErrPrint(lErr)
		}

		// Step 6: Process Verification based on the retrieved details
		pPanRespRec, lStatusCode, lErrmsg = processVerification(pDebug, pReq, pTestUserRec, lSessionId, lUid, lPanRecAPI)
		if lErrmsg != "" {
			pDebug.Log(helpers.Elog, lStatusCode, lErrmsg)
			return pPanRespRec, lStatusCode, lErrmsg
		}
	}
	pDebug.Log(helpers.Statement, "PanStatusVerification(-)")
	return pPanRespRec, lStatusCode, lErrmsg
}

func ReadInput(req *http.Request, pDebug *helpers.HelperStruct) (PanDataInfo, error) {
	pDebug.Log(helpers.Statement, "readinput (+)")
	var lErr error
	var lPanRec PanDataInfo

	lBody, lErr := ioutil.ReadAll(req.Body)
	pDebug.Log(helpers.Details, "lBody", string(lBody))
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSRI01 ", lErr.Error())
		return lPanRec, helpers.ErrReturn(errors.New(" Unable to read the input"))
	}
	lErr = json.Unmarshal(lBody, &lPanRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSRI02 ", lErr.Error())
		return lPanRec, helpers.ErrReturn(errors.New(" Unable to read the input"))
	}

	pDebug.SetReference(lPanRec.PanNumber)
	if len(lPanRec.PanNumber) == 0 && lPanRec.DigiID == "" {
		pDebug.Log(helpers.Elog, "PSRI03 ", "PAN Number is missing. cannot continue processing")
		return lPanRec, helpers.ErrReturn(errors.New("PAN Number is missing. cannot continue processing"))
	}
	pDebug.Log(helpers.Statement, "readinput (-)")

	return lPanRec, nil
}

func PanVerify(pDebug *helpers.HelperStruct, pPanRecAPI PanDataStruct) (PanFinalStruct, error) {
	pDebug.Log(helpers.Statement, "PanVerify (+)")
	var lPanServiceResp PanFinalStruct
	var lPanAPIReq PanStatusApiStruct
	var lPanAPIReqErr helpers.Error_Response

	lPanAPIReq.PanDataArr = append(lPanAPIReq.PanDataArr, pPanRecAPI)
	lPanAPIReq.AppName = "PanStatus_Instakyc"
	lPayload, lErr := json.Marshal(lPanAPIReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPV01 ", lErr.Error())
		return lPanServiceResp, helpers.ErrReturn(lErr)
	}

	lPanStatusAPIResp, lErr := panstatusverify.NewPanStatusVerification(string(lPayload), pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPV02 ", lErr.Error())
		return lPanServiceResp, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "lPanStatusAPIResp", lPanStatusAPIResp)

	if strings.Contains(lPanStatusAPIResp, "statusCode") {
		lErr = json.Unmarshal([]byte(lPanStatusAPIResp), &lPanAPIReqErr)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "PSPV03 ", lErr.Error())
			return lPanServiceResp, helpers.ErrReturn(lErr)
		}
		return lPanServiceResp, helpers.ErrReturn(fmt.Errorf(lPanAPIReqErr.ErrorMessage))
	} else {
		lErr = json.Unmarshal([]byte(lPanStatusAPIResp), &lPanServiceResp)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "PSPV04 ", lErr.Error())
			return lPanServiceResp, helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "PanVerify (-)")
	return lPanServiceResp, nil
}

func TestUserEntry(req *http.Request, pDebug *helpers.HelperStruct) (lTestUserRec TestuserStruct, lErr error) {
	pDebug.Log(helpers.Statement, "TestUserEntry (+)")
	lTestAllow := common.TestAllow
	lTestUserRec.Pan = common.TestPan
	lTestUserRec.Dob = common.TestDOB
	lBodyData := fmt.Sprintf("%v", req.Body)
	if strings.Contains(lBodyData, lTestUserRec.Dob) {
		lTestUserRec.isTestUser = (strings.EqualFold(lTestAllow, "Y") && strings.Contains(lBodyData, lTestUserRec.Pan) && strings.Contains(lBodyData, lTestUserRec.Dob))
	} else {
		lTestUserRec.isTestUser = (strings.EqualFold(lTestAllow, "Y") && strings.Contains(lBodyData, lTestUserRec.Pan))
	}
	lTestUserRec.Name = "TEST USER"
	pDebug.Log(helpers.Statement, "TestUserEntry (-)")

	return lTestUserRec, nil
}

func processVerification(pDebug *helpers.HelperStruct, pReq *http.Request, pTestUserRec TestuserStruct, pSessionId, pUid string, pPanRecAPI PanDataInfo) (RespStruct, string, string) {
	pDebug.Log(helpers.Statement, "processVerification(+)")
	var pPanRespRec RespStruct
	var lStatusCode, lErrmsg, lKraRefId, lDigilockerRefID, lNameAsPerKRA string
	var pPanDetailsRec PanResponseStruct
	var GetPanStatusDetails PanStatusRespStruct
	var lErr error
	var lIsMinor bool
	lKraRefId, lDigilockerRefID, lNameAsPerKRA, lErr = getKraDetails(pUid, pPanRecAPI.PanNumber, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV04 ", lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	pDebug.Log(helpers.Details, lNameAsPerKRA, "lNameAsPerKRA", lKraRefId, "lKraRefId", lDigilockerRefID, "lDigilockerRefID")
	// if lKraRefId == "" || lDigilockerRefID == "" {
	if pPanRecAPI.VerifyFlag == KraStatusVerifyMode {

		return handleKraAndDigilocker(pDebug, pReq, pTestUserRec, pSessionId, pUid, pPanRecAPI, lKraRefId, lDigilockerRefID, lNameAsPerKRA)

	} else if pPanRecAPI.VerifyFlag == DOBVerifyMode {

		lIsMinor, lErr = commonpackage.IsMinor(pDebug, pPanRecAPI.PanDOB)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "PVIM01", lErr.Error())
			return pPanRespRec, "", helpers.ErrPrint(lErr)
		}
		if lIsMinor {
			pDebug.Log(helpers.Elog, "PVIM02", "You must be 18 or older to proceed with the account creation")
			lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "MINORDOB_ERR")
			return pPanRespRec, "MINORKRADOB", lERROR
			// return pPanRespRec, "PVIM02", helpers.ErrPrint(errors.New("you must be 18 or older to proceed with the account creation"))
		}
		return handleKraVerification(pDebug, pReq, pTestUserRec, pSessionId, pUid, pPanRecAPI, lNameAsPerKRA)

	} else {
		pDebug.Log(helpers.Details, pPanRecAPI.PanName, "lPanRecAPI.PanName ---------------------------->")

		lPanRefernceId, lDob, lErr := GetPanStatusRefID(pDebug, pUid, pPanRecAPI.PanNumber)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return pPanRespRec, "", helpers.ErrPrint(lErr)
		}
		if lPanRefernceId != "" {
			pPanDetailsRec, lErr = FetchPanStatusDetails(pDebug, pUid, pPanDetailsRec)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return pPanRespRec, "", helpers.ErrPrint(lErr)
			}
			pPanDetailsRec, lErr = ConstructPanStatusDetails(pDebug, lPanRefernceId, pPanDetailsRec, GetPanStatusDetails, lDob)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return pPanRespRec, "", helpers.ErrPrint(lErr)
			}
			pPanRespRec.PanData = append(pPanRespRec.PanData, pPanDetailsRec)
			return pPanRespRec, "", ""
		} else {
			if pPanRecAPI.VerifyFlag == "DOB" || pPanRecAPI.VerifyFlag == "NAME" {
				lMatchedData, lErr := GetNameAndDOB(pDebug, pUid, pPanRecAPI.PanNumber, pPanRecAPI.VerifyFlag)
				if lErr != nil {
					pDebug.Log(helpers.Elog, lErr.Error())
					return pPanRespRec, "", helpers.ErrPrint(lErr)
				}
				if pPanRecAPI.VerifyFlag == "NAME" {
					pPanRecAPI.PanDOB = lMatchedData
				} else if pPanRecAPI.VerifyFlag == "DOB" {
					pPanRecAPI.PanName = lMatchedData
				}
			}
			lCombinationFlag := USER
			pPanRespRec, lStatusCode, lErrmsg = PanValidation(pDebug, pPanRecAPI, pPanRespRec, pSessionId, pUid, lCombinationFlag)
			// if lStatusCode == "" && lErrmsg == "" {
			// 	lErr = UpdateCombinations(pDebug, pDb, pUid, lCombinationFlag)
			// 	if lErr != nil {
			// 		pDebug.Log(helpers.Elog, lErr.Error())
			// 		return pPanRespRec, "", helpers.ErrPrint(lErr)
			// 	}
			// }
		}
	}
	pDebug.Log(helpers.Statement, "processVerification(-)")
	return pPanRespRec, lStatusCode, lErrmsg
}

func handleKraAndDigilocker(pDebug *helpers.HelperStruct, pReq *http.Request, pTestUserRec TestuserStruct, pSessionId, pUid string, pPanRecAPI PanDataInfo, pKraRefId, pDigilockerRefID, pNameAsPerKRA string) (RespStruct, string, string) {
	pDebug.Log(helpers.Statement, "handleKraAndDigilocker(+)")
	var pPanRespRec RespStruct
	var lErrmsg string
	var lErr error

	if pKraRefId == "" {
		pNameAsPerKRA, lErr = HandleKraVerify(pDebug, pUid, pSessionId, pPanRecAPI.PanNumber, pPanRecAPI.PanDOB, pReq)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErrmsg)
			return pPanRespRec, "", helpers.ErrPrint(lErr)
		}
	}
	if pNameAsPerKRA != "" {
		return pPanRespRec, DOBVerifyMode, "Please enter your Date of Birth"
	} else if !pTestUserRec.isTestUser {
		if pDigilockerRefID == "" {
			lreDirectUrl, lErr := RedirectUrl(pDebug, pPanRecAPI.AppName, pUid)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return pPanRespRec, "", helpers.ErrPrint(lErr)
			} else {
				return pPanRespRec, ReDirectUrl, lreDirectUrl
			}
		} else {
			return handleDigilockerVerification(pDebug, pReq, pTestUserRec, pSessionId, pUid, pPanRecAPI, pDigilockerRefID)
		}
	} else if pTestUserRec.isTestUser {
		lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "NAMENDDOB_ERR")
		return pPanRespRec, "NAMEDOB", lERROR
	}
	pDebug.Log(helpers.Statement, "handleKraAndDigilocker(-)")
	return pPanRespRec, "", ""
}
