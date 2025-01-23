package panstatus

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	panstatusverify "fcs23pkg/integration/v1/panStatusVerify"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

type PanDataInfo struct {
	PanNumber string `json:"panno"`
	PanName   string `json:"panname"`
	PanDOB    string `json:"pandob"`
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
	Status            string `json:"status"`
}

func GetPanStatus(w http.ResponseWriter, req *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)

	lDebug.Log(helpers.Statement, "GetPanStatus (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	(w).Header().Set("Content-Type", "application/json")

	// fmt.Println("req test", req)
	if req.Method == "POST" {
		var lPanRespRec RespStruct
		var lErrcode, lMsg string
		var lDatas []byte

		lPanRespRec.Status = "S"
		lTestUserRec, lErr := TestUserEntry(req, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "PSGPS01 ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		}
		// lPanRespRec.LastName = lTestUserName

		lPanRespRec, lErrcode, lMsg = PANProcessVerification(req, lDebug, lTestUserRec)
		if lErrcode != "" {
			lDebug.Log(helpers.Elog, "PSGPS02 ", lMsg)
			if strings.Contains(lErrcode, "PSPPV") {
				fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			} else {
				fmt.Fprint(w, helpers.GetError_String(lErrcode, lMsg))
			}
			return
		}
		if len(lPanRespRec.PanData) == 1 {
			lDatas, lErr = json.Marshal(lPanRespRec.PanData[0])
			if lErr != nil {
				lDebug.Log(helpers.Elog, "PSGPS03 ", lErr)
				fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
				return
			}
		} else {
			lDatas, lErr = json.Marshal(lPanRespRec)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "PSGPS03 ", lErr)
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

func PANProcessVerification(pReq *http.Request, pDebug *helpers.HelperStruct, pTestUserRec TestuserStruct) (RespStruct, string, string) {
	pDebug.Log(helpers.Statement, "panProcessVerification (+)")
	var pPanRespRec RespStruct
	var lPanAPIREC PanDataStruct


	lPanRecAPI, lErr := ReadInput(pReq, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV01 ", lErr.Error())
		return pPanRespRec, "PSPPV01 ", helpers.ErrPrint(lErr)
	}

	lSessionId, lUid, lErr := sessionid.GetOldSessionUID(pReq, pDebug, common.EKYCCookieName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV03 ", lErr.Error())
		return pPanRespRec, "PSPPV03 ", helpers.ErrPrint(lErr)
	}

	pDebug.Log(helpers.Details, "lPanRecAPI", lPanRecAPI)
	lPanVerifyStatus, lPanVerifyError := ValidatePanReq(pDebug, lPanRecAPI, pTestUserRec)
	if lPanVerifyError != "" {
		pDebug.Log(helpers.Elog, "PSPPV04 ", lPanVerifyError)
		return pPanRespRec, lPanVerifyStatus, lPanVerifyError
	}
	lPanAPIREC.DateOfBirth = lPanRecAPI.PanDOB
	lPanAPIREC.Name = lPanRecAPI.PanName
	lPanAPIREC.FatherName = ""
	lPanAPIREC.PAN = lPanRecAPI.PanNumber

	lRowId, lErr := InsertPanDetails(pDebug, lPanAPIREC, lUid, lSessionId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV05 ", helpers.ErrPrint(lErr))
		return pPanRespRec, "PSPPV05 ", helpers.ErrPrint(lErr)
	}
	lPayload, lErr := json.Marshal(lPanAPIREC)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV051 ", lErr.Error())
		return pPanRespRec, "PSPPV051 ", helpers.ErrPrint(lErr)
	}
	//getting the pan Status
	lPanAPIResp, lErr := PanVerify(pReq, pDebug, lPanAPIREC, "EKYC_PanStatu _Verify")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV06 ", lErr.Error())
		return pPanRespRec, "PSPPV06 ", helpers.ErrPrint(lErr)
	}
	lErr = UpdateRequest(pDebug, lSessionId, lUid, lRowId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV060 ", lErr.Error())
		return pPanRespRec, "PSPPV060 ", helpers.ErrPrint(lErr)
	}
	lRespStr, lErr := json.Marshal(lPanAPIResp)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV061 ", lErr.Error())
		return pPanRespRec, "PSPPV061 ", helpers.ErrPrint(lErr)
	}
	for i := 0; i < len(lPanAPIResp.PanResponseArr); i++ {
		if lPanAPIResp.PanResponseArr[i].APIResponseCode == "1" {
			for j := 0; j < len(lPanAPIResp.PanResponseArr[i].OutputData); j++ {

				var lERRMESSAGE string
				if !strings.EqualFold(lPanAPIResp.PanResponseArr[i].APIResponseCodeDesc, "success") {
					lERRMESSAGE = lPanAPIResp.PanResponseArr[i].APIResponseCodeDesc
				}

				lErr := UpdatePanDetails(pDebug, lSessionId, lPanAPIResp.PanResponseArr[i].BatchId, lERRMESSAGE, string(lPayload), string(lRespStr), lPanAPIResp.PanResponseArr[i].OutputData[j], lRowId)
				if lErr != nil {
					pDebug.Log(helpers.Elog, "PSPPV07 ", lErr.Error())
					return pPanRespRec, "PSPPV07 ", helpers.ErrPrint(lErr)
				}

				if lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus != "E" {
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "F") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_F")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "X") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_X")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "D") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_D")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "N") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_N")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "EA") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_EA")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "EC") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_EC")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "ED") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_ED")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "EI") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_EI")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "EL") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_EL")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "EM") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_EM")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "EP") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_EP")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "ES") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_ES")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "EU") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_EU")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "I") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Pan_I")
						return pPanRespRec, "PAN", lERROR
					}
				}
				if lPanAPIResp.PanResponseArr[i].OutputData[j].SeedingStatus != "Y" {
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].SeedingStatus, "R") || strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].SeedingStatus, "") || strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].SeedingStatus, " ") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Aadhar_R")
						return pPanRespRec, "PAN", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].SeedingStatus, "NA") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "Aadhar_NA")
						return pPanRespRec, "PAN", lERROR
					}
				} else {
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].Name, "N") && strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].DateOfBirth, "N") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "NAMENDDOB_ERR")
						return pPanRespRec, "NAMEDOB", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].Name, "N") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "NAME_ERR")
						return pPanRespRec, "NAME", lERROR
					}
					if strings.EqualFold(lPanAPIResp.PanResponseArr[i].OutputData[j].DateOfBirth, "N") {
						lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "DOB_ERR")
						return pPanRespRec, "DOB", lERROR
					}
					var lPanStatusResp PanResponseStruct
					lPanStatusResp.Dob = lPanRecAPI.PanDOB
					lPanStatusResp.Name = lPanRecAPI.PanName
					lPanStatusResp.Pan = lPanAPIResp.PanResponseArr[i].OutputData[j].PAN
					lPanStatusResp.NameFlag = lPanAPIResp.PanResponseArr[i].OutputData[j].Name
					lPanStatusResp.DobFlag = lPanAPIResp.PanResponseArr[i].OutputData[j].DateOfBirth
					lPanStatusResp.PanStatus = lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus
					lPanStatusResp.PanStatusDesc = lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatusDesc
					lPanStatusResp.SeedingStatus = lPanAPIResp.PanResponseArr[i].OutputData[j].SeedingStatus
					lPanStatusResp.SeedingStatusDesc = lPanAPIResp.PanResponseArr[i].OutputData[j].SeedingStatusDesc
					lPanStatusResp.ReferenceId = lPanAPIResp.PanResponseArr[i].OutputData[j].ReferenceId
					lPanStatusResp.BatchId = lPanAPIResp.PanResponseArr[i].BatchId
					lPanStatusResp.FatherName = lPanAPIREC.FatherName
					lPanStatusResp.FatherNameFlag = lPanAPIResp.PanResponseArr[i].OutputData[j].FatherName
					lPanStatusResp.Status = "S"

					pPanRespRec.PanData = append(pPanRespRec.PanData, lPanStatusResp)
					pPanRespRec.Status = "S"

					lErr := PANNoInsertDb(lPanStatusResp, pDebug, pReq, lSessionId, lUid)
					if lErr != nil {
						pDebug.Log(helpers.Elog, "PSPPV08 ", lErr.Error())
						return pPanRespRec, "PSPPV08 ", helpers.ErrPrint(lErr)
					}

				}
			}
		} else {
			return pPanRespRec, "PSPPV09 ", helpers.ErrPrint(fmt.Errorf(" Unable to Get Pan status"))
		}
	}

	pDebug.Log(helpers.Statement, "panProcessVerification (-)")
	return pPanRespRec, "", ""
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
	if len(lPanRec.PanNumber) == 0 {
		pDebug.Log(helpers.Elog, "PSRI03 ", "PAN Number is missing. cannot continue processing")
		return lPanRec, helpers.ErrReturn(errors.New("PAN Number is missing. cannot continue processing"))
	}
	pDebug.Log(helpers.Statement, "readinput (-)")

	return lPanRec, nil
}

func PanVerify(req *http.Request, pDebug *helpers.HelperStruct, lPanRecAPI PanDataStruct, pProcessType string) (PanFinalStruct, error) {
	pDebug.Log(helpers.Statement, "PanVerify (+)")
	var lPanServiceResp PanFinalStruct
	var lPanAPIReq PanStatusApiStruct
	var lPanAPIReqErr helpers.Error_Response

	lPanAPIReq.PanDataArr = append(lPanAPIReq.PanDataArr, lPanRecAPI)
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
	lTestUserRec.isTestUser = (strings.EqualFold(lTestAllow, "Y") && strings.Contains(lBodyData, lTestUserRec.Pan) && strings.Contains(lBodyData, lTestUserRec.Dob))
	lTestUserRec.Name = "TEST USER"
	pDebug.Log(helpers.Statement, "TestUserEntry (-)")

	return lTestUserRec, nil
}
