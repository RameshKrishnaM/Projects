package kra

import (
	"encoding/json"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/appsession"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
	"strings"
)

type DbAddressStatusStruct struct {
	AdrsStatus string `json:"addrstatus"`
	Status     string `json:"status"`
	ErrMsg     string `json:"errmsg"`
}

/*
Purpose : This method is used to fetch the user addres details in db
Request : N/A
Response :
===========
On Success:
===========
{
"Status": "Success",
}
===========
On Error:
===========
"Error": "Something went wrong"
Author : Sowmiya L
Date : 03-August-2023
*/
func AddressStatus(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "AddressStatus (+)")

	if r.Method == "GET" {
		var lResp DbAddressStatusStruct
		lResp.Status = common.SuccessCode
		lUid, lErr := appsession.Getuid(r, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "AS01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("AS01", "Something went wrong. Please try again later"))
			return
		}

		lSessionId, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(r, lDebug, common.EKYCCookieName, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "AS02"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("AS02", "Something went wrong. Please try again later"))
			return
		}

		lCorestring := `select nvl(status,'N') 
						from ekyc_onboarding_status eos 
						where Page_Name ='AddressVerification' 
						and Request_id = ?
						and ( ? or eos.Created_Session_Id  = ?)`
		lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid, lTestUserFlag, lSessionId)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "AS03"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("AS03", "Something went wrong. Please try again later"))
			return
		}
		defer lRows.Close()

		for lRows.Next() {
			lErr := lRows.Scan(&lResp.AdrsStatus)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "AS04"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("AS04", "Something went wrong. Please try again later"))
				return
			}
		}

		lDatas, lErr := json.Marshal(lResp)
		lDebug.Log(helpers.Details, "lDatas", string(lDatas))

		if lErr != nil {
			lDebug.Log(helpers.Elog, "AS05"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("AS05", "Something went wrong. Please try again later"))
			return
		} else {
			fmt.Fprint(w, string(lDatas))
		}
	}
	lDebug.Log(helpers.Statement, "AddressStatus (-)")

}
func KRACheck(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "KRACheck (+)")
	if strings.EqualFold(r.Method, "GET") {
		var lStatus string

		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "KRAC01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("KRAC01", "Something went wrong. Please try again later."))
			return
		}
		lDebug.SetReference(lUid)

		lCorestring := ` select nvl(Kra_XML_Id,"") as kra_flag  from ekyc_attachments  where Request_id =?
		`
		lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "KRAC03"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("KRAC03", "Something went wrong. Please try again later."))
			return
		}
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lStatus)
			lDebug.Log(helpers.Details, "lStatus", lStatus)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "KRAC04"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("KRAC04", "Something went wrong. Please try again later."))
				return
			}
		}
		if strings.EqualFold(lStatus, "") {
			fmt.Fprint(w, helpers.GetMsg_String("E", "New KRA user"))
			return
		}
		fmt.Fprint(w, helpers.GetMsg_String("S", "Existing KRA user"))
		return
	}
	lDebug.Log(helpers.Statement, "KRACheck (-)")
	lDebug.RemoveReference()
}
