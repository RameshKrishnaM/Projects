package sidcreate

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fcs23pkg/apigate"
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

type UserStruct struct {
	Name        string `json:"name"`
	Phone       string `json:"phone"`
	Email       string `json:"email"`
	UtmSource   string `json:"utmsource"`
	UtmMedium   string `json:"utmmedium"`
	UtmCampaign string `json:"utmcampaign"`
	UtmContent  string `json:"utmcontent"`
	Gclid       string `json:"gclid"`
}

type UtmStruct struct {
	UtmSource   string `json:"utmsource"`
	UtmMedium   string `json:"utmmedium"`
	UtmCampaign string `json:"utmcampaign"`
	UtmContent  string `json:"utmcontent"`
	Gclid       string `json:"gclid"`
}

func InsereUdata(w http.ResponseWriter, r *http.Request) {
	Debug := new(helpers.HelperStruct)
	Debug.SetUid(r)
	Debug.Log(helpers.Statement, "InsereUdata (+)")

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	switch r.Method {
	case "POST":
		_, lErr := UdataFlow(Debug, w, r)
		if lErr != nil {
			Debug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("EKYC", "Somthing is Wrong Please try again later"))
			return
		} else {
			fmt.Fprint(w, helpers.GetMsg_String("EKYC", ""))
		}
	}
	Debug.Log(helpers.Statement, "InsereUdata (-)")

}

func UdataFlow(pDebug *helpers.HelperStruct, w http.ResponseWriter, pReq *http.Request) (string, error) {
	pDebug.Log(helpers.Statement, "userFlow (+)")

	// create an instance of the structure
	var lUserRec UserStruct
	var lUtmRec UtmStruct
	//read the body
	lBody, lErr := ioutil.ReadAll(pReq.Body)

	if lErr != nil {

		return "", helpers.ErrReturn(lErr)
	}
	// converting json body value to Structue
	lErr = json.Unmarshal(lBody, &lUserRec)

	// cheack where response will not Error
	if lErr != nil {

		return "", helpers.ErrReturn(lErr)
	}

	lErr = json.Unmarshal(lBody, &lUtmRec)

	// cheack where response will not Error
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	lReqid, _, lErr := CheckUserStatus(pDebug, lUserRec.Phone, lUserRec.Email)

	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	if lReqid != "" {
		return "user current status", nil
	}

	pDebug.SetReference("phone:" + lUserRec.Phone)

	lErr = CreateUTMCokkie(w, pDebug, lUtmRec)

	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	lUid, lErr := UserdataInsertDB(pDebug, lUserRec, pReq)

	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	lErr = InsertSid(w, pReq, pDebug, lUid)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	return "", nil
}

func UserdataInsertDB(pDebug *helpers.HelperStruct, pUserRec UserStruct, pReq *http.Request) (uuid.UUID, error) {
	pDebug.Log(helpers.Statement, "UdataDb (+)")

	lUid := uuid.NewV4()

	insertString := `
	if not exists (select * from ekyc_request where Uid=?)
	then
	insert into ekyc_request (uid,Given_Name,Phone,Email,Updated_Session_Id,CreatedDate,UpdatedDate)
	values(?,?,?,?,?,unix_timestamp(),unix_timestamp());
	end if;`

	_, lErr := ftdb.NewEkyc_GDB.Exec(insertString, lUid, lUid, pUserRec.Name, pUserRec.Phone, pUserRec.Email, lUid)
	if lErr != nil {
		return lUid, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "UdataDb (-)")

	return lUid, nil
}

func InsertSid(w http.ResponseWriter, r *http.Request, pDebug *helpers.HelperStruct, pSession uuid.UUID) error {
	pDebug.Log(helpers.Statement, "InsertSid (+)")
	// geting the response details
	lReqDtl := apigate.GetRequestorDetail(pDebug, r)

	// generate session id

	pDebug.SetReference(pSession)
	pDebug.Log(helpers.Details, "Uid:", pSession)
	lSessionSHA256 := sha256.Sum256([]byte(pSession.String()))
	lSessionSHA256String := hex.EncodeToString(lSessionSHA256[:])

	insertString := `
			insert into ekyc_session(requestuid,sessionid,createdtime,expiretime,realip,forwardedip,method,path,host,remoteaddr)
			values (?,?,unix_timestamp() ,unix_timestamp(ADDDATE(now(), INTERVAL 5 HOUR) ),?,?,?,?,?,?)`
	_, lErr := ftdb.NewEkyc_GDB.Exec(insertString, pSession, lSessionSHA256String, lReqDtl.RealIP, lReqDtl.ForwardedIP, lReqDtl.Method, lReqDtl.Path, lReqDtl.Host, lReqDtl.RemoteAddr)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "session Cookie :", lSessionSHA256String)
	var lCookieeExpiry int
	lAppMode := r.Header.Get("App_mode")
	if strings.EqualFold(lAppMode, "web") {
		lCookieeExpiry = common.CookieMaxAge
	} else {
		lCookieeExpiry = common.AppCookieMaxAge
	}
	// set the cokkie in browser
	appsession.KycSetcookie(w, pDebug, common.EKYCCookieName, lSessionSHA256String, lCookieeExpiry)

	pDebug.Log(helpers.Statement, "InsertSid (-)")

	return nil
}

func CreateUTMCokkie(w http.ResponseWriter, pDebug *helpers.HelperStruct, lUtmdat UtmStruct) error {
	pDebug.Log(helpers.Statement, "CreateUTMCokkie (+)")

	lErr := appsession.KycSetcookie(w, pDebug, "UTMdata", lUtmdat, 30*24*60*60)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "CreateUTMCokkie (-)")
	return nil
}
