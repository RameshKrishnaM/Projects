package panstatus

import (
	"encoding/json"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	panstatusverify "fcs23pkg/integration/v2/panStatusVerify"
	"fmt"
	"net/http"
	"strings"
)

type PanStatusRespStruct struct {
	PanDetails []PanStatusStruct `json:"pan_details"`
	Status     string            `json:"status"`
}

type PanStatusStruct struct {
	PAN               string `json:"pan"`
	Name              string `json:"name"`
	NameMatched       string `json:"name_matched"`
	DOBMatched        string `json:"dob_matched"`
	FatherNameMatched string `json:"father_name_matched"`
	PanStatus         string `json:"pan_status"`
	PanStatusDesc     string `json:"pan_status_desc"`
	SeedingStatus     string `json:"seeding_status"`
	SeedingStatusDesc string `json:"seeding_status_desc"`
}

func GetPanDetails(w http.ResponseWriter, req *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)
	lDebug.Log(helpers.Statement, "GetPanStatus (+)")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	(w).Header().Set("Content-Type", "application/json")

	if req.Method == "GET" {
		var lPanStatusRec PanResponseStruct
		var lPanStatusApiResp PanStatusRespStruct
		lPanStatusRec.Status = common.SuccessCode

		_, lUid, lErr := sessionid.GetOldSessionUID(req, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "PSGPD01 ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		}

		_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(req, lDebug, common.EKYCCookieName, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GDA02: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GDA02", "Something went wrong. Please try again later."))
			return
		}
		if lTestUserFlag == "1" {

			lPanStatusRec, lErr = FetchPanStatusDetails(lDebug, lUid, lPanStatusRec)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "PSGPD03 ", lErr)
				fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
				return
			}
			lDebug.Log(helpers.Details, "lPanStatusRec", lPanStatusRec)

			if lPanStatusRec.SeedingStatus != "" && lPanStatusRec.PanStatus != "" {
				lRefID, lDOB, lErr := GetPanRefId(lDebug, lUid)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "PSGPD03 ", lErr)
					fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
					return
				}
				lPanStatusRec, lErr = ConstructPanStatusDetails(lDebug, lRefID, lPanStatusRec, lPanStatusApiResp, lDOB)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "PSGPD04 ", lErr)
					fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
					return
				}
			}
		}
		lDatas, lErr := json.Marshal(lPanStatusRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "PSGPS06 ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		} else {
			fmt.Fprint(w, string(lDatas))
		}

	}
	lDebug.Log(helpers.Statement, "GetPanStatus (-)")
}
func FetchPanStatusDetails(pDebug *helpers.HelperStruct, pUid string, lPanStatusRec PanResponseStruct) (PanResponseStruct, error) {
	pDebug.Log(helpers.Statement, "FetchPanStatusDetails (+)")
	lCoreString := `SELECT nvl(er.Aadhar_Linked,''), nvl(er.Pan,''), nvl(er.Name_As_Per_Pan,''), nvl(er.DOB,''),  nvl(er.ValidPan_Status,'')
					FROM ekyc_request er
					where Uid= ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GPSD001"+lErr.Error())
		return lPanStatusRec, helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr = lRows.Scan(&lPanStatusRec.SeedingStatus, &lPanStatusRec.Pan, &lPanStatusRec.Name, &lPanStatusRec.Dob, &lPanStatusRec.PanStatus)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "GPSD002"+lErr.Error())
				return lPanStatusRec, helpers.ErrReturn(lErr)
			}
		}

	}

	pDebug.Log(helpers.Statement, "FetchPanStatusDetails (-)")
	return lPanStatusRec, nil
}
func ConstructPanStatusDetails(pDebug *helpers.HelperStruct, pRefID string, lPanStatusRec PanResponseStruct, lPanStatusApiResp PanStatusRespStruct, pDob string) (PanResponseStruct, error) {
	pDebug.Log(helpers.Statement, "ConstructPanStatusDetails(+)")
	lResp, lErr := panstatusverify.PanStatusCheck(pDebug, pRefID)
	var lPanAPIReqErr helpers.Error_Response

	if lErr != nil {
		pDebug.Log(helpers.Elog, "CPSD04 ", lErr)
		return lPanStatusRec, helpers.ErrReturn(lErr)
	}
	if strings.Contains(lResp, "statusCode") {
		lErr = json.Unmarshal([]byte(lResp), &lPanAPIReqErr)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CPSD03 ", lErr.Error())
			return lPanStatusRec, helpers.ErrReturn(lErr)
		}
		return lPanStatusRec, helpers.ErrReturn(fmt.Errorf(lPanAPIReqErr.ErrorMessage))
	} else {
		lErr = json.Unmarshal([]byte(lResp), &lPanStatusApiResp)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CPSD05 ", lErr)
			return lPanStatusRec, helpers.ErrReturn(lErr)
		}
		for i := 0; i < len(lPanStatusApiResp.PanDetails); i++ {
			lPanStatusRec.Pan = lPanStatusApiResp.PanDetails[i].PAN
			lPanStatusRec.Dob = pDob
			lPanStatusRec.Name = lPanStatusApiResp.PanDetails[i].Name
			lPanStatusRec.NameFlag = lPanStatusApiResp.PanDetails[i].NameMatched
			lPanStatusRec.DobFlag = lPanStatusApiResp.PanDetails[i].DOBMatched
			lPanStatusRec.PanStatus = lPanStatusApiResp.PanDetails[i].PanStatus
			lPanStatusRec.PanStatusDesc = lPanStatusApiResp.PanDetails[i].PanStatusDesc
			lPanStatusRec.SeedingStatus = lPanStatusApiResp.PanDetails[i].SeedingStatus
			lPanStatusRec.SeedingStatusDesc = lPanStatusApiResp.PanDetails[i].SeedingStatusDesc
			lPanStatusRec.Status = "S"
		}
	}
	pDebug.Log(helpers.Statement, "ConstructPanStatusDetails(-)")
	return lPanStatusRec, nil
}
func GetPanRefId(pDebug *helpers.HelperStruct, pReqId string) (string, string, error) {
	pDebug.Log(helpers.Statement, "GetPanRefId (+)")
	var lRefId, lDOB string
	lCoreString := `select ref_id,dob 
					from pan_status_log psl 
					where request_uid = ?
					order by id desc
					limit 1`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pReqId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GPRI01 "+lErr.Error())
		return lRefId, lDOB, helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr = lRows.Scan(&lRefId, &lDOB)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "GPRI02 "+lErr.Error())
				return lRefId, lDOB, helpers.ErrReturn(lErr)
			}
		}

	}

	pDebug.Log(helpers.Statement, "GetPanRefId (-)")
	return lRefId, lDOB, nil
}
func GetPanDataInfo(pUid string, pDebug *helpers.HelperStruct) (string, string, string, error) {
	pDebug.Log(helpers.Statement, "GetPanDataInfo(+)")
	var lPanNo, lDOB, lGivenName string

	// Query to retrieve PanNo and DOB from the ekyc_request table based on Uid
	lCorestring := `select nvl(er.Pan,""),nvl(er.DOB,""),nvl(er.Given_Name,"") from ekyc_request er where er.Uid =?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pUid)
	if lErr != nil {
		// Log an error and return it if the query fails
		pDebug.Log(helpers.Elog, "GPID01"+lErr.Error())
		return lPanNo, lDOB, lGivenName, helpers.ErrReturn(lErr)
	} else {
		// Iterate through the query result
		defer lRows.Close()
		for lRows.Next() {
			// Scan PanNo and DOB values from the result set
			lErr := lRows.Scan(&lPanNo, &lDOB, &lGivenName)
			if lErr != nil {
				// Log an error and return it if scanning fails
				pDebug.Log(helpers.Elog, "GPID02"+lErr.Error())
				return lPanNo, lDOB, lGivenName, helpers.ErrReturn(lErr)
			}
		}
	}
	pDebug.Log(helpers.Statement, "GetPanDataInfo(-)")
	return lPanNo, lDOB, lGivenName, nil
}

func GetRefId(pUid, pPanNo string, pDebug *helpers.HelperStruct) (string, string, string, error) {
	pDebug.Log(helpers.Statement, "GetRefId (+)")

	var lKraRefId, lDigilockerRefID, lKRAUserName string

	// Query to retrieve PanNo and DOB from the ekyc_address table based on Uid
	lCorestring := `select nvl(ea.KRA_Reference_Id,"") ,nvl(ea.Digilockerreferenceid,""),nvl(Name_As_Per_KRA,"") from ekyc_address ea,ekyc_request er where ea.Request_Uid = ? and er.Uid=ea.Request_Uid and er.Pan=?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pUid, pPanNo)
	if lErr != nil {
		// Log an error and return it if the query fails
		pDebug.Log(helpers.Elog, "GPID04"+lErr.Error())
		return lKraRefId, lDigilockerRefID, lKRAUserName, helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		// Iterate through the query result
		for lRows.Next() {
			// Scan PanNo and DOB values from the result set
			lErr := lRows.Scan(&lKraRefId, &lDigilockerRefID, &lKRAUserName)
			if lErr != nil {
				// Log an error and return it if scanning fails
				pDebug.Log(helpers.Elog, "GPID03"+lErr.Error())
				return lKraRefId, lDigilockerRefID, lKRAUserName, helpers.ErrReturn(lErr)
			}
		}
	}
	pDebug.Log(helpers.Statement, "GetRefId (-)")

	// Return the retrieved information and a nil error
	return lKraRefId, lDigilockerRefID, lKRAUserName, nil
}

func GetPanStatusRefID(pDebug *helpers.HelperStruct, pUid, pPan string) (string, string, error) {
	pDebug.Log(helpers.Statement, "GetPanStatusRefID(+)")
	var lPanReferenceId, lDOB string
	// Query to retrieve lPanReferenceId from the ekyc_request table based on Uid
	lCorestring := `select psl.ref_id,psl.dob from ekyc_request er ,pan_status_log psl where er.Uid = ? and er.Pan = ? and psl.id = er.PanRefId `
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pUid, pPan)
	if lErr != nil {
		// Log an error and return it if the query fails
		pDebug.Log(helpers.Elog, "GPVD01"+lErr.Error())
		return lPanReferenceId, lDOB, helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		// Iterate through the query result
		for lRows.Next() {
			// Scan lPanReferenceId values from the result set
			lErr := lRows.Scan(&lPanReferenceId, &lDOB)
			if lErr != nil {
				// Log an error and return it if scanning fails
				pDebug.Log(helpers.Elog, "GPVD02"+lErr.Error())
				return lPanReferenceId, lDOB, helpers.ErrReturn(lErr)
			}
		}
	}
	pDebug.Log(helpers.Statement, "GetPanStatusRefID(-)")
	return lPanReferenceId, lDOB, nil
}

func getPanNumber(lUid string, pDebug *helpers.HelperStruct) (string, string, error) {
	pDebug.Log(helpers.Statement, "getPanNumber(+)")
	lPanNo, _, lGivenName, lErr := GetPanDataInfo(lUid, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GPN001", lErr.Error())
		return "", "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "getPanNumber(-)")
	return lPanNo, lGivenName, nil
}

func getKraDetails(lUid, panNumber string, pDebug *helpers.HelperStruct) (string, string, string, error) {
	pDebug.Log(helpers.Statement, "getKraDetails(+)")
	lKraRefId, lDigilockerRefID, lNameAsPerKRA, lErr := GetRefId(lUid, panNumber, pDebug)
	if lErr != nil {
		return "", "", "", lErr
	}
	pDebug.Log(helpers.Statement, "getKraDetails(-)")
	return lKraRefId, lDigilockerRefID, lNameAsPerKRA, nil
}

func GetNameAndDOB(pDebug *helpers.HelperStruct, pUid, pPan, pFlag string) (string, error) {
	pDebug.Log(helpers.Statement, "GetNameAndDOB(+)")
	var lMatchedData, lSelectedStmt, lWhereStmt string
	if pFlag == "DOB" {
		lSelectedStmt = `psl.name`
		lWhereStmt = `psl.name_matched  = 'Y'`
	} else if pFlag == "NAME" {
		lSelectedStmt = `psl.dob`
		lWhereStmt = `psl.dob_matched = 'Y'`
	}
	// Query to retrieve lMatchedData from the ekyc_request table based on Uid
	lCorestring := `select ` + lSelectedStmt + ` from ekyc_request er ,pan_status_log psl
	where er.Uid = psl.request_uid and er.Pan = psl.pan and er.Uid = ? and er.Pan = ? and ` + lWhereStmt + `
	limit 1`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pUid, pPan)
	if lErr != nil {
		// Log an error and return it if the query fails
		pDebug.Log(helpers.Elog, "GNAD01 "+lErr.Error())
		return lMatchedData, helpers.ErrReturn(lErr)
	} else {
		// Iterate through the query result
		defer lRows.Close()
		for lRows.Next() {
			// Scan lMatchedData values from the result set
			lErr := lRows.Scan(&lMatchedData)
			if lErr != nil {
				// Log an error and return it if scanning fails
				pDebug.Log(helpers.Elog, "GNAD02 "+lErr.Error())
				return lMatchedData, helpers.ErrReturn(lErr)
			}
		}
	}
	pDebug.Log(helpers.Details, "lMatchedData", lMatchedData)
	pDebug.Log(helpers.Statement, "GetNameAndDOB(-)")
	return lMatchedData, nil
}
