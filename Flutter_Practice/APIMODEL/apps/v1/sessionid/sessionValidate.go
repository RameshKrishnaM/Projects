package sessionid

import (
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
)

func SessionOut(w http.ResponseWriter, req *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)

	lDebug.Log(helpers.Statement, "SessionOut (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	(w).Header().Set("Content-Type", "application/json")

	if req.Method == "GET" {
		lSessionId, lReqId, lErr := GetOldSessionUID(req, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("E", "Something went wrong please try again later"))
			return
		}
		lSessionStatus, lErr := SessionValidate(lDebug, lSessionId)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "KF03"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("E", "Something went wrong please try again later"))
			return
		} else {
			lFormStatus, lErr := GetFormStatus(lDebug, lReqId)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "KF03"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("E", "Something went wrong please try again later"))
				return
			}
			if lSessionStatus == "N" {
				fmt.Fprint(w, helpers.GetError_String("E", "Session expired"))
				return
			} else {
				if lFormStatus == "Submitted" {
					fmt.Fprint(w, helpers.GetMsg_String("FS", "Your form was already been submitted not allowed to modify"))
					return
				}
				fmt.Fprint(w, helpers.GetMsg_String("S", "Inprogress"))
			}

		}

	} else {
		fmt.Fprint(w, helpers.GetError_String("Invalid Method Type", "Kindly try with POST Method"))
		return
	}
	lDebug.Log(helpers.Statement, "SessionOut (-)")

}
func SessionValidate(pDebug *helpers.HelperStruct, sessionID string) (string, error) {
	pDebug.Log(helpers.Statement, "SessionValidate(+)")

	valid := "N"

	sqlString := ` select NVL(min('Y'),'N') 
	from ekyc_session
	where unix_timestamp(NOW()) between createdtime and expiretime 
	and sessionid  = ?`

	rows, lErr := ftdb.NewEkyc_GDB.Query(sqlString, sessionID)
	if lErr != nil {
		return valid, helpers.ErrReturn(lErr)
	}
	defer rows.Close()
	//get app details
	for rows.Next() {
		lErr := rows.Scan(&valid)
		if lErr != nil {
			return valid, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "SessionValidate(-)")

	return valid, nil
}

func GetFormStatus(pDebug *helpers.HelperStruct, pReqId string) (string, error) {
	pDebug.Log(helpers.Statement, "GetFormStatus(+)")

	var FormStatus string

	// sqlString := ` select (case when nvl(submitted_date,'') = '' then  'Submitted' else 'Inprogress' end)
	// from ekyc_request er where Uid =?
	// and Form_Status !='OB'`
	sqlString := `select 'Inprogress'
					from ekyc_request er where Uid =? 
					and Form_Status in ('OB','RJ')`

	rows, lErr := ftdb.NewEkyc_GDB.Query(sqlString, pReqId)
	if lErr != nil {
		return FormStatus, helpers.ErrReturn(lErr)
	}
	defer rows.Close()
	//get app details
	for rows.Next() {
		lErr := rows.Scan(&FormStatus)
		if lErr != nil {
			return FormStatus, helpers.ErrReturn(lErr)
		}
	}
	if FormStatus == "" {
		FormStatus = "Submitted"
	}

	pDebug.Log(helpers.Statement, "GetFormStatus(-)")

	return FormStatus, nil
}
