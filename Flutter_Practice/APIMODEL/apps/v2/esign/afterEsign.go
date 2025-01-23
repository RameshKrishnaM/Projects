package esign

import (
	"encoding/json"
	update "fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
	"strings"
)

func AfterEsign(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold("POST", r.Method) {
		lDebug.Log(helpers.Statement, "AfterEsign (+)")

		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "AE01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("AE01", "Something went wrong"))
			return
		}

		lErr = update.UpdateDocID(lDebug, "Finish", "", lUid, lSid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "AE03", lErr.Error())
			return
		} else {
			lErr = router.StatusInsert(lDebug, lUid, lSid, "ReviewDetails")
			if lErr != nil {
				lDebug.Log(helpers.Elog, "AE03", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("AE03", "Error updating status during E-sign"))
				return
			}
			fmt.Fprint(w, helpers.GetMsg_String("NEWEKYC", "Esign File Upload SuccessFully"))

		}
	}
	lDebug.Log(helpers.Statement, "AfterEsign (-)")
}

type FormStatusStruct struct {
	Status            string              `json:"status"`
	EmailID           string              `json:"email"`
	MobileNo          string              `json:"mobileno"`
	ApplicationNo     string              `json:"applicationno"`
	ApplicationStatus string              `json:"applicationstatus"`
	EsignedDocId      string              `json:"esigneddocid"`
	RejectMessage     string              `json:"rejectmsg"`
	StageMessage      map[string][]string `json:"stagemsg"`
	UserName          string              `json:"username"`
}

func UserApplicationstatus(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "GET")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold("GET", r.Method) {
		lDebug.Log(helpers.Statement, "UserApplicationstatus (+)")
		var lFormStatusRec FormStatusStruct
		lFormStatusRec.Status = common.SuccessCode

		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GFS08", lErr.Error())
			return
		}
		lDebug.SetReference(lUid)

		lCorestring := ` select nvl(Email,""),nvl(Phone,""),nvl(Form_Status,""),nvl(applicationNo,""),nvl(PWD_eSignDocid,""),nvl(Name_As_Per_Pan,"") from ekyc_request where Uid=?`
		lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GFS01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GFS01", "Something went wrong. Please try again later."))
			return
		}
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lFormStatusRec.EmailID, &lFormStatusRec.MobileNo, &lFormStatusRec.ApplicationStatus, &lFormStatusRec.ApplicationNo, &lFormStatusRec.EsignedDocId, &lFormStatusRec.UserName)
			lDebug.Log(helpers.Details, "lFormStatusRec", lFormStatusRec)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "GFS02", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("GFS02", "Something went wrong. Please try again later."))
				return
			}
		}

		// if lFormStatusRec.ApplicationStatus, _, lErr = update.ReadDropDownData("NewekycTableStatus", "NewekycTableStatus", lFormStatusRec.ApplicationStatus, lDebug); lErr != nil {
		// 	lDebug.Log(helpers.Elog, "GFS03", lErr.Error())
		// 	fmt.Fprint(w, helpers.GetError_String("GFS03", "Something went wrong. Please try again later."))
		// 	return
		// }
		pLookUpRec, lErr := update.GetLookUpDescription(lDebug, "NewekycTableStatus", lFormStatusRec.ApplicationStatus, "code")
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GFS03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GFS03", "Something went wrong. Please try again later."))
			return
		}
		lFormStatusRec.ApplicationStatus = pLookUpRec.Descirption
		if lFormStatusRec.MobileNo, lErr = common.GetEncryptedMobile(lFormStatusRec.MobileNo); lErr != nil {
			lDebug.Log(helpers.Elog, "GFS04", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GFS04", "Something went wrong. Please try again later."))
			return
		}
		if lFormStatusRec.EmailID, lErr = common.GetEncryptedemail(lFormStatusRec.EmailID); lErr != nil {
			lDebug.Log(helpers.Elog, "GFS05", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GFS05", "Something went wrong. Please try again later."))
			return
		}
		lDebug.Log(helpers.Details, "lFormStatusRec_Encrypt_data", lFormStatusRec)

		lFormStatusRec.RejectMessage, lErr = GetRejectMsg(lDebug, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GFS06", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GFS06", "Something went wrong. Please try again later."))
			return
		}
		lFormStatusRec.StageMessage,_, lErr = router.GetRejectMsg(lDebug, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GFS07", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GFS07", "Something went wrong. Please try again later."))
			return
		}

		lFormStatus, lErr := json.Marshal(lFormStatusRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GFS08", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GFS08", "Something went wrong. Please try again later."))
			return
		}
		fmt.Fprint(w, string(lFormStatus))
		lDebug.RemoveReference()
	}
	lDebug.Log(helpers.Statement, "UserApplicationstatus (-)")
}

func GetRejectMsg(pDebug *helpers.HelperStruct, pUid string) (lMessage string, lErr error) {
	pDebug.Log(helpers.Statement, "GetRejectMsg (+)")
	lSelectQyr := `select nch.comments 
	from ekyc_request er ,newekyc_comments_history nch
	where er.Uid =nch.requestUid and er.Process_Status ='RJ'and nch.stage ='Verification' and er.Uid = ?`
	lRow, lErr := ftdb.NewEkyc_GDB.Query(lSelectQyr, pUid)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	defer lRow.Close()
	for lRow.Next() {
		lErr = lRow.Scan(&lMessage)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "GetRejectMsg (-)")
	return lMessage, nil
}
