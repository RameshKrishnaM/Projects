package panstatus

import (
	"encoding/json"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/digilockerapicall"
	"fcs23pkg/tomlconfig"
	"fmt"
	"strings"
)

func verifyUsingPanXML(pDebug *helpers.HelperStruct, lPanRecAPI PanDataInfo, pPanRespRec RespStruct, lSessionId, lUid string, lNameAsPerPANXML, lDOBAsPerPANXML string, lResponse digilockerapicall.DigiInfoStruct) (RespStruct, string, string) {
	pDebug.Log(helpers.Statement, "verifyUsingPanXML(+)")
	var lStatusCode, lErrmsg string
	var pPanDetailsRec PanResponseStruct
	var GetPanStatusDetails PanStatusRespStruct

	pDebug.Log(helpers.Details, "PAN Verify mode => Pan Xml from Digilocker, Name As per PAN Xml => ", lNameAsPerPANXML)

	var lTempName interface{}
	var lDataFlag bool
	lTempName = tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "PanXmlName")
	lDataFlag = lTempName != ""
	if lDataFlag {
		lPanRecAPI.PanName = fmt.Sprintf("%v", lTempName)
	} else {
		lPanRecAPI.PanName = lNameAsPerPANXML
	}
	pDebug.Log(helpers.Details, lDOBAsPerPANXML, "lDOBAsPerPANXML")
	lPanRecAPI.PanDOB = strings.ReplaceAll(lDOBAsPerPANXML, "-", "/")
	var lTempDOB interface{}
	var lDOBFlag bool
	lTempDOB = tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "PanXmlDOB")
	lDOBFlag = lTempDOB != ""
	if lDOBFlag {
		lPanRecAPI.PanDOB = fmt.Sprintf("%v", lTempDOB)
	}
	pDebug.Log(helpers.Details, lPanRecAPI.PanDOB, "lPanRecAPI.PanDOB")
	lPanRefernceId, lDob, lErr := GetPanStatusRefID(pDebug, lUid, lPanRecAPI.PanNumber)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV35 ", lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	if lPanRefernceId != "" {
		pPanDetailsRec, lErr = FetchPanStatusDetails(pDebug, lUid, pPanDetailsRec)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "PSPPV36 ", lErr.Error())
			return pPanRespRec, "", helpers.ErrPrint(lErr)
		}
		pPanDetailsRec, lErr = ConstructPanStatusDetails(pDebug, lPanRefernceId, pPanDetailsRec, GetPanStatusDetails, lDob)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "PSPPV37 ", lErr.Error())
			return pPanRespRec, "", helpers.ErrPrint(lErr)
		}
		pPanRespRec.PanData = append(pPanRespRec.PanData, pPanDetailsRec)
		return pPanRespRec, "", ""
	} else {
		lCombinationFlag := PANXML
		pPanRespRec, lStatusCode, lErrmsg = PanValidation(pDebug, lPanRecAPI, pPanRespRec, lSessionId, lUid, lCombinationFlag)
		// if lStatusCode == "" && lErrmsg == "" {
		// 	lErr := UpdateCombinations(pDebug, lDb, lUid, lCombinationFlag)
		// 	if lErr != nil {
		// 		pDebug.Log(helpers.Elog, lErr.Error())
		// 		return pPanRespRec, "", helpers.ErrPrint(lErr)
		// 	}
		// }
	}
	// pPanRespRec, lStatusCode, lErrmsg := PanValidation(pDebug, lPanRecAPI, pTestUserRec, pPanRespRec, lDb, lSessionId, lUid, pReq)
	if lStatusCode == "NAME" || lStatusCode == "NAMEDOB" || lStatusCode == "DOB" {

		pDebug.Log(helpers.Details, "Aadhar Verify mode => Aadhar Xml from Digilocker, Name As per Aadhar Xml => ", lResponse.Name)
		if lStatusCode == "DOB" {
			lPanRecAPI.PanDOB = strings.ReplaceAll(lResponse.DOB, "-", "/")
			var lTempDOB interface{}
			var lDOBFlag bool
			lTempDOB = tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "AadhaarXmlDOB")
			lDOBFlag = lTempDOB != ""
			if lDOBFlag {
				lPanRecAPI.PanDOB = fmt.Sprintf("%v", lTempDOB)
			}
		} else if lStatusCode == "NAME" {
			var lTempName interface{}
			var lDataFlag bool
			lTempName = tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "AadharXMLName")
			lDataFlag = lTempName != ""
			if lDataFlag {
				lPanRecAPI.PanName = fmt.Sprintf("%v", lTempName)
			} else {
				lPanRecAPI.PanName = lResponse.Name
			}
		} else if lStatusCode == "NAMEDOB" {
			lPanRecAPI.PanDOB = strings.ReplaceAll(lResponse.DOB, "-", "/")
			var lTempDOB interface{}
			var lDOBFlag bool
			lTempDOB = tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "AadhaarXmlDOB")
			lDOBFlag = lTempDOB != ""
			if lDOBFlag {
				lPanRecAPI.PanDOB = fmt.Sprintf("%v", lTempDOB)
			}

			var lTempName interface{}
			var lDataFlag bool
			lTempName = tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "AadharXMLName")
			lDataFlag = lTempName != ""
			if lDataFlag {
				lPanRecAPI.PanName = fmt.Sprintf("%v", lTempName)
			} else {
				lPanRecAPI.PanName = lResponse.Name
			}
		}

		pDebug.Log(helpers.Details, lTempName, "lTempName => Aadhar Xml")
		pDebug.Log(helpers.Details, lResponse.Name, "lResponse.Name")
		lPanRefernceId, lDob, lErr := GetPanStatusRefID(pDebug, lUid, lPanRecAPI.PanNumber)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "PSPPV35 ", lErr.Error())
			return pPanRespRec, "", helpers.ErrPrint(lErr)
		}
		if lPanRefernceId != "" {
			pPanDetailsRec, lErr = FetchPanStatusDetails(pDebug, lUid, pPanDetailsRec)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "PSPPV36 ", lErr.Error())
				return pPanRespRec, "", helpers.ErrPrint(lErr)
			}
			pPanDetailsRec, lErr = ConstructPanStatusDetails(pDebug, lPanRefernceId, pPanDetailsRec, GetPanStatusDetails, lDob)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "PSPPV37 ", lErr.Error())
				return pPanRespRec, "", helpers.ErrPrint(lErr)
			}
			pPanRespRec.PanData = append(pPanRespRec.PanData, pPanDetailsRec)
			return pPanRespRec, "", ""
		} else {
			lCombinationFlag := AADHARXML
			pPanRespRec, lStatusCode, lErrmsg = PanValidation(pDebug, lPanRecAPI, pPanRespRec, lSessionId, lUid, lCombinationFlag)
			// if lStatusCode == "" && lErrmsg == "" {
			// 	lErr := UpdateCombinations(pDebug, lDb, lUid, lCombinationFlag)
			// 	if lErr != nil {
			// 		pDebug.Log(helpers.Elog, lErr.Error())
			// 		return pPanRespRec, "", helpers.ErrPrint(lErr)
			// 	}
			// }
			// if lStatusCode == "NAME" || lStatusCode == "NAMEDOB" {
			// 	var lTempName interface{}
			// 	var lDataFlag bool
			// 	lTempName = tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "GivenName")
			// 	lDataFlag = lTempName != ""
			// 	if lDataFlag {
			// 		lPanRecAPI.PanName = fmt.Sprintf("%v", lTempName)
			// 	}
			// 	// } else {
			// 	lCombinationFlag := AADHARXML_USER
			// 	pPanRespRec, lStatusCode, lErrmsg = PanValidation(pDebug, lPanRecAPI, pPanRespRec, lSessionId, lUid, lCombinationFlag)
			// 	// if lStatusCode == "" && lErrmsg == "" {
			// 	// 	lErr := UpdateCombinations(pDebug, lDb, lUid, lCombinationFlag)
			// 	// 	if lErr != nil {
			// 	// 		pDebug.Log(helpers.Elog, lErr.Error())
			// 	// 		return pPanRespRec, "", helpers.ErrPrint(lErr)
			// 	// 	}
			// 	// }
			// }
		}
		// pPanRespRec, lStatusCode, lErrmsg = PanValidation(pDebug, lPanRecAPI, pTestUserRec, pPanRespRec, lDb, lSessionId, lUid, pReq)
	}
	pDebug.Log(helpers.Statement, "verifyUsingPanXML(-)")
	return pPanRespRec, lStatusCode, lErrmsg
}

func verifyUsingAadharXML(pDebug *helpers.HelperStruct, lPanRecAPI PanDataInfo, pPanRespRec RespStruct, lSessionId, lUid string, lResponse digilockerapicall.DigiInfoStruct) (RespStruct, string, string) {
	pDebug.Log(helpers.Statement, "verifyUsingAadharXML(+)")
	var lStatusCode, lErrmsg string
	var pPanDetailsRec PanResponseStruct
	var GetPanStatusDetails PanStatusRespStruct

	pDebug.Log(helpers.Details, "Aadhar Verify mode => Aadhar Xml from Digilocker, Name As per Aadhar Xml => ", lResponse.Name)

	var lTempName interface{}
	var lDataFlag bool
	lTempName = tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "AadharXMLName")
	lDataFlag = lTempName != ""
	if lDataFlag {
		lPanRecAPI.PanName = fmt.Sprintf("%v", lTempName)
	} else {
		lPanRecAPI.PanName = lResponse.Name
	}

	lPanRecAPI.PanDOB = strings.ReplaceAll(lResponse.DOB, "-", "/")
	var lTempDOB interface{}
	var lDOBFlag bool
	lTempDOB = tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "AadhaarXmlDOB")
	lDOBFlag = lTempDOB != ""
	if lDOBFlag {
		lPanRecAPI.PanDOB = fmt.Sprintf("%v", lTempDOB)
	}

	pDebug.Log(helpers.Details, lTempName, "lTempName => Aadhar Xml")
	pDebug.Log(helpers.Details, lPanRecAPI.PanName, "lPanRecAPI.PanName")
	pDebug.Log(helpers.Details, lResponse.Name, "lResponse.Name")

	lPanRefernceId, lDob, lErr := GetPanStatusRefID(pDebug, lUid, lPanRecAPI.PanNumber)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV35 ", lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	if lPanRefernceId != "" {
		pPanDetailsRec, lErr = FetchPanStatusDetails(pDebug, lUid, pPanDetailsRec)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "PSPPV36 ", lErr.Error())
			return pPanRespRec, "", helpers.ErrPrint(lErr)
		}
		pPanDetailsRec, lErr = ConstructPanStatusDetails(pDebug, lPanRefernceId, pPanDetailsRec, GetPanStatusDetails, lDob)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "PSPPV37 ", lErr.Error())
			return pPanRespRec, "", helpers.ErrPrint(lErr)
		}
		pPanRespRec.PanData = append(pPanRespRec.PanData, pPanDetailsRec)
		return pPanRespRec, "", ""
	} else {
		lCombinationFlag := AADHARXML
		pPanRespRec, lStatusCode, lErrmsg = PanValidation(pDebug, lPanRecAPI, pPanRespRec, lSessionId, lUid, lCombinationFlag)
		// if lStatusCode == "" && lErrmsg == "" {
		// 	lErr := UpdateCombinations(pDebug, lDb, lUid, lCombinationFlag)
		// 	if lErr != nil {
		// 		pDebug.Log(helpers.Elog, lErr.Error())
		// 		return pPanRespRec, "", helpers.ErrPrint(lErr)
		// 	}
		// }
		if lStatusCode == "NAME" || lStatusCode == "NAMEDOB" {
			var lTempName interface{}
			var lDataFlag bool
			lTempName = tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "GivenName")
			lDataFlag = lTempName != ""
			if lDataFlag {
				lPanRecAPI.PanName = fmt.Sprintf("%v", lTempName)
			}
			// } else {
			lCombinationFlag := AADHARXML_USER
			pPanRespRec, lStatusCode, lErrmsg = PanValidation(pDebug, lPanRecAPI, pPanRespRec, lSessionId, lUid, lCombinationFlag)
			// if lStatusCode == "" && lErrmsg == "" {
			// 	lErr := UpdateCombinations(pDebug, lDb, lUid, lCombinationFlag)
			// 	if lErr != nil {
			// 		pDebug.Log(helpers.Elog, lErr.Error())
			// 		return pPanRespRec, "", helpers.ErrPrint(lErr)
			// 	}
			// }
		}
	}

	pDebug.Log(helpers.Statement, "verifyUsingAadharXML(-)")
	return pPanRespRec, lStatusCode, lErrmsg
}

func PanValidation(pDebug *helpers.HelperStruct, lPanRecAPI PanDataInfo, pPanRespRec RespStruct, lSessionId, lUid, pCombinationFlag string) (RespStruct, string, string) {
	pDebug.Log(helpers.Statement, "PanValidation(+)")
	var lPanAPIREC PanDataStruct

	lPanAPIREC.DateOfBirth = lPanRecAPI.PanDOB
	lPanAPIREC.Name = lPanRecAPI.PanName
	lPanAPIREC.FatherName = ""
	lPanAPIREC.PAN = lPanRecAPI.PanNumber

	var lTempArr RespStruct
	pPanRespRec.PanData = lTempArr.PanData
	lRowId, lErr := InsertPanDetails(pDebug, lPanAPIREC, lUid, lSessionId, pCombinationFlag)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV11 ", helpers.ErrPrint(lErr))
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	lPayload, lErr := json.Marshal(lPanAPIREC)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV12 ", lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	//getting the pan Status
	lPanAPIResp, lErr := PanVerify(pDebug, lPanAPIREC)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV13 ", lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	lRespStr, lErr := json.Marshal(lPanAPIResp)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PSPPV15 ", lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	pDebug.Log(helpers.Details, string(lRespStr), "lRespStr")
	for i := 0; i < len(lPanAPIResp.PanResponseArr); i++ {
		if lPanAPIResp.PanResponseArr[i].APIResponseCode == "1" {
			for j := 0; j < len(lPanAPIResp.PanResponseArr[i].OutputData); j++ {

				var lERRMESSAGE string
				if !strings.EqualFold(lPanAPIResp.PanResponseArr[i].APIResponseCodeDesc, "success") {
					lERRMESSAGE = lPanAPIResp.PanResponseArr[i].APIResponseCodeDesc
				}

				lErr := UpdatePanDetails(pDebug, lSessionId, lPanAPIResp.PanResponseArr[i].BatchId, lERRMESSAGE, string(lPayload), string(lRespStr), lPanAPIResp.PanResponseArr[i].OutputData[j], lRowId)
				if lErr != nil {
					pDebug.Log(helpers.Elog, "PSPPV16 ", lErr.Error())
					return pPanRespRec, "", helpers.ErrPrint(lErr)
				}
				pDebug.Log(helpers.Details, lPanAPIResp.PanResponseArr[i].OutputData[j].PanStatus, "PanStatus")
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
					lErr = UpdateRequest(pDebug, lSessionId, lUid, lRowId)
					if lErr != nil {
						pDebug.Log(helpers.Elog, "PSPPV14 ", lErr.Error())
						return pPanRespRec, "", helpers.ErrPrint(lErr)
					}
					// lErr := PANNoInsertDb(lPanStatusResp, lDb, pDebug, pReq, lSessionId, lUid)
					// if lErr != nil {
					// 	pDebug.Log(helpers.Elog, "PSPPV17 ", lErr.Error())
					// 	return pPanRespRec, "PSPPV17 ", helpers.ErrPrint(lErr)
					// }

				}
			}
		} else {
			return pPanRespRec, "PSPPV18 ", helpers.ErrPrint(fmt.Errorf(" Unable to Get Pan status"))
		}
	}
	pDebug.Log(helpers.Statement, "PanValidation(-)")
	return pPanRespRec, "", ""
}
