package router

import (
	"encoding/json"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

type RouterStatusStruct struct {
	RouterStatus   string   `json:"routerstatus"`
	RouterName     string   `json:"routername"`
	RouterEndPoint string   `json:"routerendpoint"`
	UserEditable   string   `json:"usereditable"`
	RejectMessage  []string `json:"message"`
}

type FullRouterStruct struct {
	Status     string               `json:"status"`
	RouterData []RouterStatusStruct `json:"routerdata"`
}

type RouterMoveStruct struct {
	Status        string   `json:"status"`
	RoutStatus    string   `json:"routerstatus"`
	RouterName    string   `json:"routername"`
	RouterMove    string   `json:"routeraction"`
	EndPoint      string   `json:"endpoint"`
	RejectMessage []string `json:"message"`
}

func RouterInfo(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "GET")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if r.Method == "GET" {
		lDebug.Log(helpers.Statement, "RouterInfo (+)")

		var lFinalRec FullRouterStruct

		lFinalRec.Status = common.SuccessCode

		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "RRI01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("RRI01", "Somthing is wrong please try again later"))
			return
		}
		lDebug.SetReference(lUid)
		_, lFinalRec.RouterData, lErr = GetOnboadingStatus(r, lDebug, lUid)

		if lErr != nil {
			lDebug.Log(helpers.Elog, "RRI02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("RRI02", "Somthing is wrong please try again later"))
			return
		}

		lDebug.Log(helpers.Details, "User page status:", lFinalRec)

		lData, lErr := json.Marshal(lFinalRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "RRI03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("RRI03", "Somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "RouterInfo", string(lData))
		fmt.Fprint(w, string(lData))

		lDebug.Log(helpers.Statement, "RouterInfo (-)")

	}
}

func GetOnboadingStatus(pReq *http.Request, pDebug *helpers.HelperStruct, pUid string) (lEditRouterDataArr, lAllRouterDataArr []RouterStatusStruct, lErr error) {
	pDebug.Log(helpers.Statement, "GetOnboadingStatus (+)")

	var lRouterDataRec RouterStatusStruct
	var lFlag bool

	// lSessionInfo, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(pReq, pDebug, common.EKYCCookieName, pUid)
	// if lErr != nil {
	// 	return nil, nil, helpers.ErrReturn(lErr)
	// }

	lSessionId, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(pReq, pDebug, common.EKYCCookieName, pUid)
	if lErr != nil {
		return nil, nil, helpers.ErrReturn(lErr)
	}

	lSelectString := `select eri.Router_Name ,eri.Router_EndPoint , nvl(eos.Status,"N")
	from ekyc_request er LEFT JOIN ekyc_personal ep ON er.Uid = ep.Request_Uid 
	,ekyc_router_info eri left join ( SELECT eos.Page_Name, eos.Status 
		FROM ekyc_onboarding_status eos
		WHERE eos.Request_id = ?
		and ( ? or eos.Created_Session_Id  = ?)
		AND eos.id = ( SELECT MAX(eos2.id)
						FROM ekyc_onboarding_status eos2
						WHERE eos2.Page_Name = eos.Page_Name
						AND eos2.Request_id = ?
						and ( ? or eos2.Created_Session_Id  = ?)
						))as eos on eri.Router_Name =eos.Page_Name  
	where er.Uid = ?
	AND (ep.Nominee IS NULL OR ep.Nominee <> 'N' OR eri.Router_Name != 'NomineeDetails')
	and (? or eri.Router_Name != 'IPV')
	order by eri.newPosition`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lSelectString, pUid, lTestUserFlag, lSessionId, pUid, lTestUserFlag, lSessionId, pUid, lTestUserFlag)
	if lErr != nil {
		return nil, nil, helpers.ErrReturn(lErr)
	}

	lFormStatus, lErr := CheckFormStatus(pDebug, pUid)
	if lErr != nil {
		return nil, nil, helpers.ErrReturn(lErr)
	}
	lStageMap, lErr := GetRejectMsg(pDebug, pUid)
	if lErr != nil {
		return nil, nil, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()

	for lRows.Next() {
		lErr := lRows.Scan(&lRouterDataRec.RouterName, &lRouterDataRec.RouterEndPoint, &lRouterDataRec.RouterStatus)
		if lErr != nil {
			return nil, nil, helpers.ErrReturn(lErr)
		}
		lRouterDataRec.UserEditable = "Y"
		if strings.EqualFold(lFormStatus, "Y") {
			lRouterDataRec.RejectMessage, lFlag = lStageMap[lRouterDataRec.RouterName]
			if !lFlag {
				lRouterDataRec.UserEditable = "N"
			} else {
				lEditRouterDataArr = append(lEditRouterDataArr, lRouterDataRec)
			}
		}
		// if lTestUserFlag && strings.EqualFold(lSessionInfo, "current") {
		// 	lRouterDataRec.RouterStatus = "N"
		// }
		lAllRouterDataArr = append(lAllRouterDataArr, lRouterDataRec)
	}

	pDebug.Log(helpers.Statement, "GetOnboadingStatus (-)")
	return lEditRouterDataArr, lAllRouterDataArr, nil
}

func StatusInsert(pDebug *helpers.HelperStruct, pUid, pSid, pPage_Name string) error {
	pDebug.Log(helpers.Statement, "StatusInsert (+)")

	insertString := `
		IF EXISTS (select * from ekyc_onboarding_status eos where Page_Name =? and Request_id =?)
		then
		 INSERT INTO ekyc_onboarding_status (Request_id, Page_Name, Status, Created_Session_Id, CreatedDate)
		 values(?,?,'U',?,unix_timestamp());
		ELSE
		 INSERT INTO ekyc_onboarding_status (Request_id, Page_Name, Status, Created_Session_Id, CreatedDate)
		 values(?,?,'I',?,unix_timestamp());
		END IF;`

	_, lErr := ftdb.NewEkyc_GDB.Exec(insertString, pPage_Name, pUid, pUid, pPage_Name, pSid, pUid, pPage_Name, pSid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "StatusInsert (-)")
	return nil
}

func GetRouterChange(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetRouterChange (+)")

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold("POST", r.Method) {

		var lRouterRec, lRouterFlowRec RouterMoveStruct
		lBody, lErr := ioutil.ReadAll(r.Body)
		lRouterFlowRec.Status = common.SuccessCode

		if lErr != nil {
			lDebug.Log(helpers.Elog, "RGR01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("RGR01", "Somthing is wrong please try again later"))
			return
		}
		// converting json body value to Structue
		lErr = json.Unmarshal(lBody, &lRouterRec)

		// cheack where response will not Error
		if lErr != nil {
			lDebug.Log(helpers.Elog, "RGR02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("RGR02", "Somthing is wrong please try again later"))
			return
		}

		if lRouterRec.RouterName == "" || lRouterRec.RouterMove == "" {
			lDebug.Log(helpers.Elog, "router data is missing")
			fmt.Fprint(w, helpers.GetError_String("RGR0", "Somthing is wrong please try again later"))
			return

		}

		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "RGR03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("RGR03", "Somthing is wrong please try again later"))
			return
		}
		lDebug.SetReference(lUid)

		lEditRouterData, lAllRouterData, lErr := GetOnboadingStatus(r, lDebug, lUid)
		lDebug.Log(helpers.Details, lEditRouterData, lAllRouterData, "lEditRouterData,lAllRouterData")
		if lErr != nil {
			lDebug.Log(helpers.Elog, "RGR04", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("RGR04", "Somthing is wrong please try again later"))
			return
		}
		if len(lEditRouterData) != 0 {
			lAllRouterData = lEditRouterData
		}

		lRouterIndex, complited := GetRouterIndex(lDebug, lAllRouterData, lRouterRec)
		if complited {
			lRouterFlowRec.EndPoint = "/Account-Status"
			lRouterFlowRec.RouterName = "AccountStatus"
			lRouterFlowRec.RoutStatus = common.SuccessCode
		} else if lRouterIndex == -1 && len(lAllRouterData) == 0 {
			lRouterFlowRec.EndPoint = "/Signup"
			lRouterFlowRec.RouterName = "Signup"
			lRouterFlowRec.RoutStatus = common.SuccessCode
		} else if lRouterIndex == -1 {
			lRouterFlowRec.EndPoint = lAllRouterData[len(lAllRouterData)-1].RouterEndPoint
			lRouterFlowRec.RouterName = lAllRouterData[len(lAllRouterData)-1].RouterName
			lRouterFlowRec.RoutStatus = lAllRouterData[len(lAllRouterData)-1].RouterStatus
			lRouterFlowRec.RejectMessage = lAllRouterData[len(lAllRouterData)-1].RejectMessage
		} else {
			lRouterFlowRec.EndPoint = lAllRouterData[lRouterIndex].RouterEndPoint
			lRouterFlowRec.RouterName = lAllRouterData[lRouterIndex].RouterName
			lRouterFlowRec.RoutStatus = lAllRouterData[lRouterIndex].RouterStatus
			lRouterFlowRec.RejectMessage = lAllRouterData[lRouterIndex].RejectMessage
		}

		lData, lErr := json.Marshal(lRouterFlowRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "RGR04", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("RGR04", "Somthing is wrong please try again later"))
			return
		}
		fmt.Fprint(w, string(lData))
		lDebug.Log(helpers.Details, "final Router status:", string(lData))

		lDebug.Log(helpers.Statement, "GetRouterChange (-)")
	}
}

func GetRouterIndex(pDebug *helpers.HelperStruct, pRouterData []RouterStatusStruct, pRouterFlow RouterMoveStruct) (int, bool) {
	pDebug.Log(helpers.Statement, "GetRouterIndex (+)")
	var lIndex, lPosition int
	var flag2 = false
	pDebug.Log(helpers.Details, "pRouterData", pRouterData)
	if strings.EqualFold(pRouterFlow.RouterMove, "NEXT") {
		lPosition = 1
	} else if strings.EqualFold(pRouterFlow.RouterMove, "PREVIOUS") {
		lPosition = -1
	} else if strings.EqualFold(pRouterFlow.RouterMove, "CURRENT") {
		lPosition = 0
	}
	for lIndexID, lData := range pRouterData {
		if lData.RouterName == pRouterFlow.RouterName {
			lIndex = lIndexID + lPosition
			flag2 = true
			break
		}
	}
	flag := false
	if lPosition > 0 {
		if len(pRouterData) == lIndex {
			flag = true
			for lIndexID, lData := range pRouterData {
				if lData.RouterStatus == "N" {
					lIndex = lIndexID
					flag = false
					break
				}
			}
		} else if lIndex == 0 {
			flag = true
			for lIndexID, lData := range pRouterData {
				if lData.RouterStatus == "N" {
					lIndex = lIndexID
					flag = false
					break
				}
			}
		}
	} else if lPosition == 0 {
		if lIndex == 0 && flag2 {
			for lIndexID, lData := range pRouterData {
				if lData.RouterStatus == "N" {
					lIndex = lIndexID
					flag = false
					break
				}
			}
		} else if lIndex == 0 && !flag2 {
			if pRouterData[len(pRouterData)-1].RouterStatus == "N" {
				for lIndexID, lData := range pRouterData {
					if lData.RouterStatus == "N" {
						lIndex = lIndexID
						flag = false
						break
					}
				}
			} else {
				flag = true
			}
		} else {
			if lIndex-1 >= 0 {
				if pRouterData[lIndex-1].RouterStatus == "N" {
					flag = true
					for lIndexID, lData := range pRouterData {
						if lData.RouterStatus == "N" {
							lIndex = lIndexID
							flag = false
							break
						}
					}
				}
			}
		}
	}
	pDebug.Log(helpers.Statement, "GetRouterIndex (-)")
	return lIndex, flag
}

func CloseAllMsg(pDebug *helpers.HelperStruct, pUid string) (lErr error) {
	pDebug.Log(helpers.Details, "CloseAllMsg (+)")
	insertString := `
		UPDATE newekyc_commentstatus nc
SET nc.commentstatus='closed', nc.UpdatedDate=unix_timestamp()
WHERE nc.requestUid=?
and nc.commentstatus='open';
		`
	_, lErr = ftdb.NewEkyc_GDB.Exec(insertString, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "CloseAllMsg (-)")
	return nil
}

func GetRejectMsg(pDebug *helpers.HelperStruct, pUid string) (lMsgMap map[string][]string, lErr error) {
	pDebug.Log(helpers.Details, "GetRejectMsg (+)")
	lMsgMap = make(map[string][]string)
	var lSatageName, lRejectMessage string

	lQry := `select CASE
	WHEN nch.stage = 'Address' THEN 'AddressVerification'
	WHEN nch.stage = 'Bank' THEN 'BankDetails'
	WHEN nch.stage = 'DematAndServices' THEN 'DematDetails'
	WHEN nch.stage = 'IPV' THEN 'IPV'
	WHEN nch.stage = 'Nominee' THEN 'NomineeDetails'
	WHEN nch.stage = 'Personal' THEN 'ProfileDetails'
	WHEN nch.stage = 'Verification' THEN 'ReviewDetails'
	ELSE nch.stage
END AS stage,nch.comments 
from ekyc_request er ,newekyc_comments_history nch ,newekyc_commentstatus nc
where er.Uid =nch.requestUid  
and nch.commentstatusId =nc.id
and er.Uid =?
and er.Form_Status ='RJ'
and nc.commentstatus = 'open'
and nch.role ='Processor'
union all 
select 'DocumentUpload' as stage,nch.comments	
from ekyc_request er ,newekyc_comments_history nch ,newekyc_commentstatus nc
where er.Uid =nch.requestUid  
and nch.commentstatusId =nc.id
and er.Uid =?
and er.Form_Status ='RJ'
and nc.commentstatus = 'open'
and nch.role ='Processor'
and nch.stage in ('BasicInfo','Bank','Personal','SignedDoc')`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lQry, pUid, pUid)
	if lErr != nil {
		return nil, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()

	for lRows.Next() {
		lErr := lRows.Scan(&lSatageName, &lRejectMessage)
		if lErr != nil {
			return nil, helpers.ErrReturn(lErr)
		}
		_, lFlag := lMsgMap[lSatageName]
		if !lFlag {
			lMsgMap[lSatageName] = []string{lRejectMessage}
		} else {
			lMsgMap[lSatageName] = append(lMsgMap[lSatageName], lRejectMessage)
		}
	}

	pDebug.Log(helpers.Details, "GetRejectMsg (-)")
	return lMsgMap, nil
}

func CheckFormStatus(pDebug *helpers.HelperStruct, pUid string) (lRejectFlag string, lErr error) {
	pDebug.Log(helpers.Details, "CheckFormStatus (+)")

	lQry := `select case when er.submitted_date is not null and er.Form_Status ="RJ" then 'Y'else'N'end
	from ekyc_request er 
	where er.Uid = ?`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lQry, pUid)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	defer lRows.Close()

	for lRows.Next() {
		lErr := lRows.Scan(&lRejectFlag)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}

	}
	pDebug.Log(helpers.Details, "CheckFormStatus (-)")
	return lRejectFlag, nil
}
