package sessionid

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fcs23pkg/appsession"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"

	uuid "github.com/satori/go.uuid"
)

func SetCookie(w http.ResponseWriter, r *http.Request) {
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
			lDebug.Log(helpers.Elog, "CSC01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("CSC01", "Somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "lBody", lBody)
		// converting json body value to Structue
		lErr = json.Unmarshal(lBody, &lUserRec)

		// cheack where response will not Error
		if lErr != nil {
			lDebug.Log(helpers.Elog, "CSC02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("CSC02", "Somthing is wrong please try again later"))
			return
		}

		lDebug.SetReference(lUserRec.Phone)

		lDebug.Log(helpers.Details, "P&E:", lUserRec.Phone, lUserRec.Email)

		if lUserRec.Phone == "" || lUserRec.Email == "" {
			lDebug.Log(helpers.Elog, "Page reload")
			fmt.Fprint(w, helpers.GetError_String("R", ""))
			return
		}
		// check user status based on user uploade data or new user
		_, lErr = SetCookieInit(w, r, lDebug, lUserRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "CSC03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("CSC03", "Somthing is wrong please try again later"))
			return
		}
	}
	fmt.Fprint(w, helpers.GetMsg_String("CSC", "Sid Created Success fully"))
	lDebug.Log(helpers.Statement, "InitiateKycPageSession (-)")

}

func SetCookieInit(w http.ResponseWriter, r *http.Request, pDebug *helpers.HelperStruct, pUserRec UserStruct) (string, error) {
	pDebug.Log(helpers.Statement, "SetCookieInit (+)")

	_, lErr := appsession.KycReadCookie(r, pDebug, common.EKYCCookieName)
	if lErr != nil {
		if lErr == http.ErrNoCookie {
			_, lSid, lStatus, lErr := GetSessionUID(pUserRec.Phone, pUserRec.Email, pDebug, r)
			if lErr != nil {
				return "", helpers.ErrReturn(lErr)
			}
			pDebug.Log(helpers.Statement, "SetCookieInit *************,:", lSid, lStatus, lErr)
			// if lStatus != "new" {
			//set cokkie in browser
			var lCookieeExpiry int
			lAppMode := r.Header.Get("App_mode")
			if strings.EqualFold(lAppMode, "web") {
				lCookieeExpiry = common.CookieMaxAge
			} else {
				lCookieeExpiry = common.AppCookieMaxAge
			}

			lErr = appsession.KycSetcookie(w, pDebug, common.EKYCCookieName, lSid, lCookieeExpiry)
			if lErr != nil {
				return "", helpers.ErrReturn(lErr)

			}
			// }
			return "", nil
		}

		return "", helpers.ErrReturn(lErr)

	}
	pDebug.Log(helpers.Statement, "SetCookieInit (-)")
	return "", nil
}

func GetSessionUID(pPhone, pEmail string, pDebug *helpers.HelperStruct, r *http.Request) (string, string, string, error) {
	pDebug.Log(helpers.Statement, "UserIDCreate (+)")

	lSessionId := uuid.NewV4()
	lSessionSHA256 := sha256.Sum256([]byte(lSessionId.String()))
	lSessionSHA256String := hex.EncodeToString(lSessionSHA256[:])

	lReqId := strings.ReplaceAll(uuid.NewV4().String(), "-", "")

	var dReqId string

	insertString := `select nvl(Uid,"") from ekyc_request where Phone =? and Email =? and isActive='Y'`
	rows, lErr := ftdb.NewEkyc_GDB.Query(insertString, pPhone, pEmail)
	if lErr != nil {
		return "", "", "", helpers.ErrReturn(lErr)
	}
	defer rows.Close()
	for rows.Next() {
		lErr := rows.Scan(&dReqId)
		if lErr != nil {
			return "", "", "", helpers.ErrReturn(lErr)
		}
	}
	if dReqId != "" {
		lReqStatus, lErr := IsActiveRequest(pDebug, dReqId)
		if lErr != nil {
			return "", "", "", helpers.ErrReturn(lErr)
		}

		if lReqStatus == "Y" {
			//Existing User
			//insert user session ID in Session table
			lErr = UserSessionInsert(pDebug, r, dReqId, lSessionSHA256String)
			if lErr != nil {
				return "", "", "", helpers.ErrReturn(lErr)
			}
			return dReqId, lSessionSHA256String, "old", nil
		}
	}
	//insert user session ID in Session table
	lErr = UserSessionInsert(pDebug, r, lReqId, lSessionSHA256String)
	if lErr != nil {
		return "", "", "", helpers.ErrReturn(lErr)
	}
	// if dReqId != "" {
	// 	//Existing User
	// 	//insert user session ID in Session table
	// 	lErr = UserSessionInsert(pDebug, r, lDb, dReqId, lSessionSHA256String)
	// 	if lErr != nil {
	// 		return "", "", "", helpers.ErrReturn(lErr)
	// 	}
	// 	return dReqId, lSessionSHA256String, "old", nil
	// }
	// //insert user session ID in Session table
	// lErr = UserSessionInsert(pDebug, r, lDb, lReqId, lSessionSHA256String)
	// if lErr != nil {
	// 	return "", "", "", helpers.ErrReturn(lErr)
	// }
	lReqId = strings.ReplaceAll(lReqId, "-", "")
	pDebug.Log(helpers.Statement, "UserIDCreate (-)")
	// New User
	return lReqId, lSessionSHA256String, "new", nil

}

func IsActiveRequest(pDebug *helpers.HelperStruct, pRequestUid string) (string, error) {
	pDebug.Log(helpers.Statement, "IsActiveRequest (+)")
	var lReqStatus string

	lcoreString := ` select nvl(isActive,'') from ekyc_request er where Uid=? `
	rows, lErr := ftdb.NewEkyc_GDB.Query(lcoreString, pRequestUid)
	if lErr != nil {
		return lReqStatus, helpers.ErrReturn(lErr)
	}
	defer rows.Close()
	for rows.Next() {
		lErr := rows.Scan(&lReqStatus)
		if lErr != nil {
			return lReqStatus, helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Details, "Request Id -->", lReqStatus, "   Request Status -->", lReqStatus)

	pDebug.Log(helpers.Statement, "IsActiveRequest (-)")
	return lReqStatus, nil
}
func GetOldSessionUID(r *http.Request, pDebug *helpers.HelperStruct, pCokkieName string) (string, string, error) {
	pDebug.Log(helpers.Statement, "GetOldSessionUID (+)")
	var lRequestId string
	lSessionId, lErr := appsession.KycReadCookie(r, pDebug, pCokkieName)

	pDebug.Log(helpers.Details, "Session ID -", lSessionId)
	if lErr != nil {
		return lSessionId, lRequestId, helpers.ErrReturn(lErr)
	} else {

		lcoreString := ` select nvl(es.requestuid,"") from ekyc_session es where es.sessionid =? `
		rows, lErr := ftdb.NewEkyc_GDB.Query(lcoreString, lSessionId)
		if lErr != nil {
			return lSessionId, lRequestId, helpers.ErrReturn(lErr)
		} else {
			defer rows.Close()
			for rows.Next() {
				lErr := rows.Scan(&lRequestId)
				if lErr != nil {
					return lSessionId, lRequestId, helpers.ErrReturn(lErr)
				}
			}
			pDebug.Log(helpers.Details, "Request UID -", lRequestId)
		}

	}
	pDebug.Log(helpers.Statement, "GetOldSessionUID (-)")
	return lSessionId, lRequestId, nil
}

func VerifyTestUserSession(r *http.Request, pDebug *helpers.HelperStruct, pCokkieName, pRequestId string) (string, string, error) {
	pDebug.Log(helpers.Statement, "VerifyTestUserSession (+)")
	var lSessionId string
	lTestUserFlag := "1"
	lSessionId, lErr := appsession.KycReadCookie(r, pDebug, pCokkieName)
	if lErr != nil {
		return lSessionId, lTestUserFlag, helpers.ErrReturn(lErr)
	}

	// pDebug.Log(helpers.Details, "Session ID -", lSessionId)

	// lCoreString := `SELECT
	// 					CASE
	// 						WHEN (
	// 							SELECT sessionid
	// 							FROM ekyc_session
	// 							WHERE requestuid = ?
	// 							ORDER BY id DESC
	// 							LIMIT 1
	// 						) = ?
	// 						THEN 'Current'
	// 						ELSE 'Old'
	// 					END AS Flag
	// 				FROM ekyc_session es
	// 				WHERE requestuid = ?
	// 				AND sessionid = ? `
	// lRows, lErr := lDb.Query(lCoreString, pRequestId, lSessionId, pRequestId, lSessionId)
	// if lErr != nil {
	// 	return lSessionId, lTestUserFlag, helpers.ErrReturn(lErr)
	// }
	// for lRows.Next() {
	// 	lErr := lRows.Scan(&lSessionInfo)
	// 	if lErr != nil {
	// 		return lSessionId, lTestUserFlag, helpers.ErrReturn(lErr)
	// 	}
	// }

	var lDbPhone, lDbEmail string

	lSqlString := `select Phone , Email 
					from ekyc_request er 
					where Uid = ? `
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lSqlString, pRequestId)
	if lErr != nil {
		return lSessionId, lTestUserFlag, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lDbPhone, &lDbEmail)
		if lErr != nil {
			return lSessionId, lTestUserFlag, helpers.ErrReturn(lErr)
		}
	}

	if lDbPhone == common.TestMobile && lDbEmail == common.TestEmail && strings.EqualFold(common.TestAllow, "Y") {
		lTestUserFlag = "0"
	}
	// pDebug.Log(helpers.Details, "lSessionInfo", lSessionInfo)
	pDebug.Log(helpers.Statement, "VerifyTestUserSession (-)")
	return lSessionId, lTestUserFlag, nil
}
