package ipv

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/ipvapi"
	"fmt"
	"strings"
	"time"
)

func CaptureSubRequInfo(pDebug *helpers.HelperStruct, pUid, pSid string, pRequestInfo ipvapi.FileInfostruct) (lErr error) {
	pDebug.Log(helpers.Statement, "CaptureSubRequInfo (+)")

	lTimeStamp := fmt.Sprint((time.Now()).Unix())
	var lInsertQryValue string

	for _, lFileInfo := range pRequestInfo.Actions {
		pDebug.Log(helpers.Details, lFileInfo.AcctionType, lFileInfo.ID)
		ConstructInsertQry(pDebug, &lInsertQryValue, pUid, pRequestInfo.ID, pSid, lFileInfo.AcctionType, lFileInfo.ID, lFileInfo.FileID, lFileInfo.Status, lTimeStamp)
	}
	if !strings.EqualFold(lInsertQryValue, "") {
		lInsertQry := fmt.Sprintf(`INSERT INTO ekyc_ipv_sub_request (Request_Uid, ipv_requestid, action_type, action_id, action_status, file_id, Session_Id, CreatedDate)
		values%s;`, lInsertQryValue)
		pDebug.Log(helpers.Details, "lInsertQry", lInsertQry)

		_, lErr = ftdb.NewEkyc_GDB.Exec(lInsertQry)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "CaptureSubRequInfo (-)")
	return nil
}

func ConstructInsertQry(pDebug *helpers.HelperStruct, lQryStr *string, pUid, pRefID, pSid, pDigioActionType, pDigioActionId, pFileId, pReqStatus, pTimeStamp string) {
	pDebug.Log(helpers.Statement, "ConstructInsertQry (+)")
	lInsertArr := []string{pUid, pRefID, pDigioActionType, pDigioActionId, pReqStatus, pFileId, pSid, pTimeStamp}

	if *lQryStr != "" {
		*lQryStr += ","
	}
	*lQryStr += fmt.Sprintf("('%s')", strings.Join(lInsertArr, "','"))
	pDebug.Log(helpers.Statement, "ConstructInsertQry (-)")

}

func ReGenerateToken(pDebug *helpers.HelperStruct, pUid, pSid, pAccessToken, pActionType string) (lAccessToken string, lErr error) {
	pDebug.Log(helpers.Details, "ReGenerateToken (+)")

	lAccessTokenInfo, lErr := ipvapi.ReGenTokenApiCall(pDebug, pAccessToken)
	if lErr != nil {
		return lAccessToken, helpers.ErrReturn(lErr)
	}
	lQry := `UPDATE ekyc_ipv_request_status
SET accessToken = ?, 
    validity = ?, 
    Action_type = IF(? = '', NULL, ?), 
    Updated_Session_Id = ?, 
    UpdatedDate = unix_timestamp()
WHERE Request_Uid = ? 
AND ipv_requestid = ?;`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lQry, lAccessTokenInfo.Response.TokenId, lAccessTokenInfo.Response.ValidTill, pActionType, pActionType, pActionType, pSid, pUid, lAccessTokenInfo.Response.EntityID)
	if lErr != nil {
		return lAccessToken, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "ReGenerateToken (-)")
	return lAccessTokenInfo.Response.TokenId, nil
}
func UpdateActionTypeToken(pDebug *helpers.HelperStruct, pUid, pSid, IPVReqID, pActionType, FetchActionType string) error {
	pDebug.Log(helpers.Details, "UpdateActionTypeToken (+)")
	pDebug.Log(helpers.Details, "pActionType==FetchActionType ==>", pActionType+" "+FetchActionType)
	if pActionType == FetchActionType {
		lQry := `UPDATE ekyc_ipv_request_status
		SET Action_type = IF(? = '', NULL, ?), 
		    Updated_Session_Id = ?, 
		    UpdatedDate = unix_timestamp()
		WHERE Request_Uid = ? 
		AND ipv_requestid = ?;`
		_, lErr := ftdb.NewEkyc_GDB.Exec(lQry, pActionType, pActionType, pSid, pUid, IPVReqID)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Details, "UpdateActionTypeToken (-)")
	return nil
}

func GetSubActionInfo(pDebug *helpers.HelperStruct, pUid, pRefID, pActionType string) (lActionId, lReCreateflag string, lErr error) {
	pDebug.Log(helpers.Statement, "GetActionInfo (+)")

	lSelectQry := `select action_id ,case when action_status in ('rejected', 'approval_pending', 'completed' , 'success')then 'Y' else 'N' end as regenaction from ekyc_ipv_sub_request
where Request_Uid =? and ipv_requestid =? and action_type=?`
	lRowInfo, lErr := ftdb.NewEkyc_GDB.Query(lSelectQry, pUid, pRefID, pActionType)
	if lErr != nil {
		return lActionId, lReCreateflag, helpers.ErrReturn(lErr)
	}
	defer lRowInfo.Close()
	for lRowInfo.Next() {
		lErr = lRowInfo.Scan(&lActionId, &lReCreateflag)
		if lErr != nil {
			return lActionId, lReCreateflag, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "GetActionInfo (-)")
	return lActionId, lReCreateflag, nil
}

func ReCreateSubAction(pDebug *helpers.HelperStruct, pUid, pSid, pRefID, pActionType, pActionID string) (lErr error) {
	pDebug.Log(helpers.Statement, "ReCreateSubAction (+)")
	var lSubActionRec ipvapi.ReCaptureReqStruct
	lSubActionRec.ActionIdArr = append(lSubActionRec.ActionIdArr, pActionID)
	lSubActionRec.NodifyCustomer = false
	lSubActionRec.Reason = "Recapture"
	lRecaptureinfo, lErr := ipvapi.ReCaptureApiCall(pDebug, lSubActionRec, pRefID)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "lRecaptureinfo", lRecaptureinfo)

	lInsertQry := `INSERT INTO ekyc_ipv_sub_request (Request_Uid, ipv_requestid,action_type,action_id, action_status, Session_Id, CreatedDate)
		values(?,?,?,?,?,?,unix_timestamp());`
	pDebug.Log(helpers.Details, "lInsertQry", pUid, pRefID, pActionType, pActionID, lSubActionRec.Reason, pSid)

	_, lErr = ftdb.NewEkyc_GDB.Exec(lInsertQry, pUid, pRefID, pActionType, pActionID, lSubActionRec.Reason, pSid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "ReCreateSubAction (-)")
	return nil
}
