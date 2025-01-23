package panstatus

import (
	"encoding/json"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	panstatusverify "fcs23pkg/integration/v1/panStatusVerify"
	"fmt"
	"net/http"
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
		var lResp string
		var lPanStatusApiResp PanStatusRespStruct

		_, lUid, lErr := sessionid.GetOldSessionUID(req, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "PSGPD01 ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		}

		lPanStatusRec, lErr = GetPanStatusDetails(lDebug, lUid, lPanStatusRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "PSGPD03 ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		}
		lPanStatusRec.Status = "S"
		lDebug.Log(helpers.Details, "lPanStatusRec", lPanStatusRec)

		if lPanStatusRec.SeedingStatus != "" && lPanStatusRec.PanStatus != "" {
			lRefID, lErr := GetPanRefId(lDebug, lUid)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "PSGPD03 ", lErr)
				fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
				return
			}
			lResp, lErr = panstatusverify.PanStatusCheck(lDebug, lRefID)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "PSGPD04 ", lErr)
				fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
				return
			}
			lErr = json.Unmarshal([]byte(lResp), &lPanStatusApiResp)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "PSGPD05 ", lErr)
				fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
				return
			}
			for i := 0; i < len(lPanStatusApiResp.PanDetails); i++ {
				lPanStatusRec.Pan = lPanStatusApiResp.PanDetails[i].PAN
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

		lDatas, lErr := json.Marshal(lPanStatusRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "PSGPS06 ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		}
		fmt.Fprint(w, string(lDatas))

	}
	lDebug.Log(helpers.Statement, "GetPanStatus (-)")
}
func GetPanStatusDetails(pDebug *helpers.HelperStruct, pUid string, lPanStatusRec PanResponseStruct) (PanResponseStruct, error) {
	pDebug.Log(helpers.Statement, "GetPanStatusDetails (+)")
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

	pDebug.Log(helpers.Statement, "GetPanStatusDetails (-)")
	return lPanStatusRec, nil
}

func GetPanRefId(pDebug *helpers.HelperStruct, pReqId string) (string, error) {
	pDebug.Log(helpers.Statement, "GetPanRefId (+)")
	var lRefId string
	lCoreString := `select ref_id 
					from pan_status_log psl 
					where request_uid = ?
					order by id desc
					limit 1`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pReqId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GPRI01 "+lErr.Error())
		return lRefId, helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr = lRows.Scan(&lRefId)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "GPRI02 "+lErr.Error())
				return lRefId, helpers.ErrReturn(lErr)
			}
		}

	}

	pDebug.Log(helpers.Statement, "GetPanRefId (-)")
	return lRefId, nil
}
