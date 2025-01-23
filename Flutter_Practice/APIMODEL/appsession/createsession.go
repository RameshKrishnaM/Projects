package appsession

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fcs23pkg/apigate"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"log"
	"net/http"

	uuid "github.com/satori/go.uuid"
)

/*
-----------------------------------------------------------------------------------
function used to generate session for AUTH app
-----------------------------------------------------------------------------------
*/
func InitiateAuthPageSession(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)

	lDebug.Log(helpers.Statement, "InitiateAuthPageSession+")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Methods", "POST,OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
	//w.WriteHeader(200)
	switch r.Method {
	case "POST":
		reqDtl := apigate.GetRequestorDetail(lDebug, r)
		sessionSHA256String := ""
		session := uuid.NewV4()
		sessionSHA256 := sha256.Sum256([]byte(session.String()))
		sessionSHA256String = hex.EncodeToString(sessionSHA256[:])

		insertString := "insert into xxapp_sessions(app,sessionid,createdtime,expiretime,realip,forwardedip,method,path,host,remoteaddr) values (?,?,now() ,ADDTIME(now(), '00:10:00.999998'),?,?,?,?,?,?)"
		_, err := ftdb.MariaFTPRD_GDB.Exec(insertString, common.EKYCAppName, sessionSHA256String, reqDtl.RealIP, reqDtl.ForwardedIP, reqDtl.Method, reqDtl.Path, reqDtl.Host, reqDtl.RemoteAddr)
		if err != nil {
			sessionSHA256String = ""
			log.Println("token insert error", err.Error())
		}

		fmt.Fprint(w, string(sessionSHA256String))
	}
	lDebug.Log(helpers.Statement, "InitiateAuthPageSession-")

}

/*
-----------------------------------------------------------------------------------
function used to generate session for accounts app
-----------------------------------------------------------------------------------
*/
func InitiateAccountsPageSession(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "InitiateAccountsPageSession+")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	switch r.Method {
	case "POST":
		//	body, _ := ioutil.ReadAll(r.Body)
		reqDtl := apigate.GetRequestorDetail(lDebug, r)

		//	reqDtl.Body = string(body)
		//generate session id
		sessionSHA256String := ""
		session := uuid.NewV4()
		sessionSHA256 := sha256.Sum256([]byte(session.String()))
		sessionSHA256String = hex.EncodeToString(sessionSHA256[:])

		insertString := "insert into xxapp_sessions(app,sessionid,createdtime,expiretime,realip,forwardedip,method,path,host,remoteaddr) values (?,?,now() ,ADDTIME(now(), '00:05:00.999998'),?,?,?,?,?,?)"
		_, err := ftdb.MariaFTPRD_GDB.Exec(insertString, common.EKYCAppName, sessionSHA256String, reqDtl.RealIP, reqDtl.ForwardedIP, reqDtl.Method, reqDtl.Path, reqDtl.Host, reqDtl.RemoteAddr)
		if err != nil {
			sessionSHA256String = ""
			log.Println("token insert error", err.Error())
		} else {
			log.Println("session Cookie " + sessionSHA256String)
			cookie := http.Cookie{Name: common.EKYCCookieName, Value: sessionSHA256String, MaxAge: common.CookieMaxAge, HttpOnly: true, Secure: true, Path: "/", Domain: common.EKYCDomain}
			http.SetCookie(w, &cookie)
		}

		fmt.Fprint(w, string(sessionSHA256String))
	}
	//w.WriteHeader(200)
	lDebug.Log(helpers.Statement, "InitiateAccountsPageSession-")
}

/*
-----------------------------------------------------------------------------------
function used to generate session for accounts app
-----------------------------------------------------------------------------------
*/
func InitiateWallPageSession(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "InitiateWallPageSession+")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	switch r.Method {
	case "POST":
		//	body, _ := ioutil.ReadAll(r.Body)
		reqDtl := apigate.GetRequestorDetail(lDebug, r)

		//	reqDtl.Body = string(body)
		//generate session id
		sessionSHA256String := ""
		session := uuid.NewV4()

		sessionSHA256 := sha256.Sum256([]byte(session.String()))
		sessionSHA256String = hex.EncodeToString(sessionSHA256[:])

		insertString := `
			insert into xxapp_sessions(app,sessionid,createdtime,expiretime,realip,forwardedip,method,path,host,remoteaddr) 
			values (?,?,now() ,ADDTIME(now(), '00:05:00.999998'),?,?,?,?,?,?)`
		_, err := ftdb.MariaFTPRD_GDB.Exec(insertString, common.EKYCAppName, sessionSHA256String, reqDtl.RealIP, reqDtl.ForwardedIP, reqDtl.Method, reqDtl.Path, reqDtl.Host, reqDtl.RemoteAddr)
		if err != nil {
			sessionSHA256String = ""
			log.Println("token insert error", err.Error())
		} else {
			//expiration := time.Now().Add(1 * time.Hour)
			log.Println("session Cookie " + sessionSHA256String)
			cookie := http.Cookie{Name: common.EKYCCookieName, Value: sessionSHA256String, MaxAge: common.CookieMaxAge, HttpOnly: true, Secure: true, Path: "/", Domain: common.EKYCDomain}
			http.SetCookie(w, &cookie)
		}

		fmt.Fprint(w, string(sessionSHA256String))
	}
	//w.WriteHeader(200)
	lDebug.Log(helpers.Statement, "InitiateWallPageSession-")

}

/*
-----------------------------------------------------------------------------------
function used to generate session for accounts app NEKYC
-----------------------------------------------------------------------------------
*/

// cokkie set
func KycSetcookie(w http.ResponseWriter, pDebug *helpers.HelperStruct, pCokkieName string, pValue interface{}, pExpir int) error {

	pDebug.Log(helpers.Statement, "KycSetCokkie (+)")
	pDebug.Log(helpers.Details, "Cokkie Set Name :", pCokkieName)
	pDebug.Log(helpers.Details, "Cokkie Set data :", pValue)
	pDebug.Log(helpers.Details, "Cokkie domain :", common.EKYCDomain)

	lData, lErr := json.Marshal(pValue)
	if lErr != nil {
		return lErr
	}
	pDebug.Log(helpers.Details, "Cokkie value :", string(lData))
	lcokkieval := string(lData)
	cookie := http.Cookie{
		Name:     pCokkieName,
		Value:    lcokkieval[1 : len(lcokkieval)-1],
		Path:     "/",
		Domain:   common.EKYCDomain,
		MaxAge:   pExpir,
		HttpOnly: true,
		Secure:   true,
		SameSite: http.SameSiteStrictMode}

	http.SetCookie(w, &cookie)

	pDebug.Log(helpers.Statement, "KycSetCokkie (-)")
	return nil
}

// Delete cookie
func DeleteCookie(w http.ResponseWriter, req *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)
	lDebug.Log(helpers.Statement, "DeleteCookie(+) ")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	switch req.Method {
	case "GET":
		// lCookie := http.Cookie{
		// 	Name:     common.EKYCCookieName,
		// 	Value:    "",
		// 	MaxAge:   -1,
		// 	HttpOnly: true,
		// 	Secure:   true,
		// 	Path:     "/",
		// 	Domain:   common.EKYCDomain,
		// 	SameSite: 0,
		// }
		// http.SetCookie(w, &lCookie)
		lClientcookie := http.Cookie{
			Name:     common.EKYCCookieName,
			Value:    "",
			MaxAge:   -1,
			HttpOnly: true,
			Secure:   true,
			Path:     "/",
			Domain:   common.EKYCDomain,
			SameSite: 0,
		}
		http.SetCookie(w, &lClientcookie)
		fmt.Fprint(w, helpers.GetMsg_String("", "Cookie cleared successfully"))

		lDebug.Log(helpers.Statement, "DeleteCookie(-)")
	}
}

//cokkie read
func KycReadCookie(r *http.Request, pDebug *helpers.HelperStruct, pCokkieName string) (string, error) {
	pDebug.Log(helpers.Statement, "KycReadCokkie (+)")
	// Read the cookie
	lCookiePtr, lErr := r.Cookie(pCokkieName)
	if lErr != nil {
		if lErr == http.ErrNoCookie {
			// Cookie is not set
			return "Not Set", helpers.ErrReturn(lErr)
		} else {
			// Other error occurred while reading the cookie
			return "", helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "KycReadCokkie (-)")
	return lCookiePtr.Value, nil
}

func Getuid(r *http.Request, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "\nKycReadCokkie (+)")
	var id string
	lEncSid, lErr := KycReadCookie(r, pDebug, common.EKYCCookieName)

	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	insertString := `
	select es.requestuid 
	from ekyc_session es 
	where es.sessionid =? `
	rows, lErr := ftdb.NewEkyc_GDB.Query(insertString, lEncSid)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)

	}
	defer rows.Close()
	for rows.Next() {

		lErr := rows.Scan(&id)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "KycReadCokkie (+)")

	return id, nil
}
