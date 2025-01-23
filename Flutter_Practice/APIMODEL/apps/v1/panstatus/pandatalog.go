package panstatus

import (
	"fcs23pkg/apps/v1/router"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"net/http"
)

func PANNoInsertDb(pPanStatusData PanResponseStruct, pDebug *helpers.HelperStruct, req *http.Request, pSessionId, pUid string) error {
	pDebug.Log(helpers.Statement, "panNoInsertDb (+)")

	var NameAsPAn string
	if pPanStatusData.NameFlag == "Y" {
		NameAsPAn = pPanStatusData.Name
	}

	insertString := `update ekyc_request set pan=? ,Name_As_Per_Pan = ?,DOB = ?,Aadhar_Linked = ?,
	ValidPan_Status = ?,NameonthePanCard = ?,Updated_Session_Id = ?,UpdatedDate = unix_timestamp()
	where Uid = ? `

	_, lErr := ftdb.NewEkyc_GDB.Exec(insertString, pPanStatusData.Pan, pPanStatusData.Name, pPanStatusData.Dob, pPanStatusData.SeedingStatus, pPanStatusData.PanStatus, NameAsPAn, pSessionId, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = sessionid.UpdateZohoCrmDeals(pDebug, req, common.PanVerified)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = router.StatusInsert(pDebug, pUid, pSessionId, "PanDetails")
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "panNoInsertDb (-)")
	return nil
}

func InsertPanDetails(pDebug *helpers.HelperStruct, pPanData PanDataStruct, pReqId, pUpdSesId string) (int, error) {
	pDebug.Log(helpers.Statement, "InsertPanDetails (+)")

	var lRowID int64

	lCoreString := `INSERT INTO pan_status_log
	(request_uid, pan, name, dob, father_name, created_Session_Id, createdBy, createdDate, updatedBy, updatedDate)
	VALUES(?, ?, ?, ?, ?, ?, ?, unix_timestamp(now()), ?, unix_timestamp(now()));`

	lRow, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString, pReqId, pPanData.PAN, pPanData.Name, pPanData.DateOfBirth, pPanData.FatherName, pUpdSesId, pPanData.PAN, pPanData.PAN)
	if lErr != nil {
		return int(lRowID), helpers.ErrReturn(lErr)
	}
	lRowID, lErr = lRow.LastInsertId()
	if lErr != nil {
		return int(lRowID), helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "InsertPanDetails (-)")
	return int(lRowID), nil
}

func UpdatePanDetails(pDebug *helpers.HelperStruct, pUpdSesId, pBatchId, pErrorMessage, pRequest, pResponse string, pOutData PanApiRespStruct, pRowId int) error {
	pDebug.Log(helpers.Statement, "UpdatePanDetails (+)")

	lCoreString := `UPDATE pan_status_log
					SET ref_id = ? , batch_id = ? , name_matched = ? , dob_matched = ? , father_name_matched = ? , pan_status = ?, seeding_status = ?, api_status = ?, created_Session_Id = ? , error_message = ? , request = ? , response = ? , updatedBy = ?, updatedDate = unix_timestamp(now())
					where id = ?`

	_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString, pOutData.ReferenceId, pBatchId, pOutData.Name, pOutData.DateOfBirth, pOutData.FatherName, pOutData.PanStatus, pOutData.SeedingStatus, "S", pUpdSesId, pErrorMessage, pRequest, pResponse, common.EKYCAppName, pRowId)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "UpdatePanDetails (-)")
	return nil
}
func UpdateRequest(pDebug *helpers.HelperStruct, pUpdSesId, pUid string, pPanRefID int) error {
	pDebug.Log(helpers.Statement, "UpdatePanDetails (+)")

	lCoreString := `UPDATE ekyc_request set PanRefId=? ,Updated_Session_Id = ?,UpdatedDate = unix_timestamp()
					where Uid = ? `

	_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString, pPanRefID, pUpdSesId, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "UpdatePanDetails (-)")
	return nil
}
