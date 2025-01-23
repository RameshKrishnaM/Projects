package ipv

import (
	"crypto/sha256"
	"encoding/hex"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/appsession"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
	"strings"

	uuid "github.com/satori/go.uuid"
)

func SetIpvRequest(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "GET")
	w.Header().Set("Access-Control-Allow-Headers", "ipvsid,Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "SetIpvRequest (+)")

	if strings.EqualFold(r.Method, "GET") {
		lIPVSid := r.Header.Get("ipvsid")
		if strings.EqualFold(lIPVSid, "") {
			lDebug.Log(helpers.Elog, "GIL03", "IPV SID is missing")
			fmt.Fprint(w, helpers.GetError_String("GIL03", "Somthing is wrong please try again later"))
			return
		}
		lDebug.SetReference(lIPVSid)

		lUid, lErr := IPVRequestID(lDebug, lIPVSid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL06", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL06", "Somthing is wrong please try again later"))
			return
		}

		lSid, lErr := GenerateSessionUID(lDebug, lUid, r)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL07", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL07", "Somthing is wrong please try again later"))
			return
		}

		lErr = UpdateIPVSid(lDebug, lIPVSid, lUid, lSid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL08", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL08", "Somthing is wrong please try again later"))
			return

		}

		var lCookieeExpiry int
		lAppMode := r.Header.Get("App_mode")
		if strings.EqualFold(lAppMode, "web") {
			lCookieeExpiry = common.CookieMaxAge
		} else {
			lCookieeExpiry = common.AppCookieMaxAge
		}

		lErr = appsession.KycSetcookie(w, lDebug, common.EKYCCookieName, lSid, lCookieeExpiry)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL09", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL09", "Somthing is wrong please try again later"))
			return

		}

		fmt.Fprint(w, helpers.GetMsg_String("GIL", "Sid Created Success fully"))

		lDebug.Log(helpers.Statement, "SetIpvRequest (-)")

	}
}

func GenerateSessionUID(pDebug *helpers.HelperStruct, pUid string, r *http.Request) (string, error) {
	pDebug.Log(helpers.Statement, "UserIDCreate (+)")

	lSessionId := uuid.NewV4()
	lSessionSHA256 := sha256.Sum256([]byte(lSessionId.String()))
	lSessionSHA256String := hex.EncodeToString(lSessionSHA256[:])

	//insert user session ID in Session table
	lErr := sessionid.UserSessionInsert(pDebug, r, pUid, lSessionSHA256String)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	return lSessionSHA256String, nil

}
