package sidcreate

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fcs23pkg/appsession"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	backofficecheck "fcs23pkg/integration/v2/backofficeCheck"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

func InitiateKycPageSession(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "InitiateKycPageSession (+)")

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	switch r.Method {
	case "POST":
		var lUserRec UserStruct
		//read the body
		lBody, lErr := ioutil.ReadAll(r.Body)

		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NEKYC", "Somthing is wrong please try again later"))
			return
		}
		// converting json body value to Structue
		lErr = json.Unmarshal(lBody, &lUserRec)

		// cheack where response will not Error
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NEKYC", "Somthing is wrong please try again later"))
			return
		}

		lDebug.SetReference("phone:" + lUserRec.Phone)

		lDebug.Log(helpers.Details, "P&E:", lUserRec.Phone, lUserRec.Email)

		if lUserRec.Phone == "" || lUserRec.Email == "" {
			lDebug.Log(helpers.Elog, "Page reload")
			fmt.Fprint(w, helpers.GetError_String("R", ""))
			return
		}

		lBofficeMobStatus, lErr := backofficecheck.BofficeCheck(lDebug, lUserRec.Phone, "mobile")
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NEKYC", "Somthing is wrong please try again later"))
			return
		}
		lBofficeEmailStatus, lErr := backofficecheck.BofficeCheck(lDebug, lUserRec.Email, "EMAIL")
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NEKYC", "Somthing is wrong please try again later"))
			return
		}

		lDebug.Log(helpers.Details, "lBofficeMobStatus && lBofficeEmailStatus", lBofficeMobStatus, lBofficeEmailStatus)

		if lBofficeMobStatus && lBofficeEmailStatus {
			lDebug.Log(helpers.Elog, errors.New(" The given mobile is already have ID"))
			fmt.Fprint(w, helpers.GetError_String("A", "You Account as be aproved"))
			return
		}

		if lBofficeMobStatus {
			lDebug.Log(helpers.Elog, errors.New(" The given mobile is already have ID"))
			fmt.Fprint(w, helpers.GetError_String("NEKYC", "The given mobile is already have ID"))
			return
		}
		if lBofficeEmailStatus {
			lDebug.Log(helpers.Elog, errors.New(" The given Email is already have ID"))
			fmt.Fprint(w, helpers.GetError_String("NEKYC", "The given Email is already have ID"))
			return
		}

		_, lErr = InitiateKycFlow(w, r, lDebug, lUserRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NEKYC", "Somthing is wrong please try again later"))
			return
		} else {
			fmt.Fprint(w, helpers.GetMsg_String("NEKYC", ""))
		}

	}
	//w.WriteHeader(200)
	lDebug.Log(helpers.Statement, "InitiateKycPageSession (-)")

}

func InitiateKycFlow(w http.ResponseWriter, r *http.Request, pDebug *helpers.HelperStruct, pUserRec UserStruct) (string, error) {
	pDebug.Log(helpers.Statement, "InitiateKycFlow (+)")

	_, lErr := appsession.KycReadCookie(r, pDebug, common.EKYCCookieName)
	if lErr != nil {
		lUid, _, lErr := CheckUserStatus(pDebug, pUserRec.Phone, pUserRec.Email)

		pDebug.Log(helpers.Details, "UID:", lUid)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
		if lUid != "" {
			pDebug.Log(helpers.Details, "old user")
			lSessionSHA256 := sha256.Sum256([]byte(lUid))
			lSessionSHA256String := hex.EncodeToString(lSessionSHA256[:])
			var lCookieeExpiry int
			lAppMode := r.Header.Get("App_mode")
			if strings.EqualFold(lAppMode, "web") {
				lCookieeExpiry = common.CookieMaxAge
			} else {
				lCookieeExpiry = common.AppCookieMaxAge
			}
			appsession.KycSetcookie(w, pDebug, common.EKYCCookieName, lSessionSHA256String, lCookieeExpiry)
			return "", nil
		}
	}
	_, _, lErr = CheckUserStatus(pDebug, pUserRec.Phone, pUserRec.Email)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "InitiateKycFlow (-)")
	return "", nil
}

func CheckUserStatus(pDebug *helpers.HelperStruct, pPhone, pEmail string) (string, string, error) {
	pDebug.Log(helpers.Statement, "CheckUserStatus (+)")
	var id string

	insertString := `
	select nvl(er.Uid,"")  
	from ekyc_request er 
	where er.Phone =? and er.Email =? `
	rows, lErr := ftdb.NewEkyc_GDB.Query(insertString, pPhone, pEmail)
	if lErr != nil {
		return "", "", helpers.ErrReturn(lErr)

	}
	defer rows.Close()
	for rows.Next() {

		lErr := rows.Scan(&id)
		if lErr != nil {
			return "", "", helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "CheckUserStatus (-)")
	return id, "", nil
}
