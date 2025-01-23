package ipv

import (
	"bytes"
	"fcs23pkg/apps/v1/otp"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/coresettings"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/emailUtil"
	"fmt"
	"net/http"
	"strings"
	"text/template"

	uuid "github.com/satori/go.uuid"
)

type IPVUrlStruct struct {
	Url, Email, Mobile, EncEmail, EncMobile, IPVLinkID, UserName, ClientID, Process, OtpType string
}

func GenerateIPVlink(w http.ResponseWriter, r *http.Request) {

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "GET")
	w.Header().Set("Access-Control-Allow-Headers", "ipvurl,Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GenerateIPVlink (+)")

	if strings.EqualFold(r.Method, "GET") {

		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL01", "Somthing is wrong please try again later"))
			return
		}
		lDebug.SetReference(lUid)

		lURL := r.Header.Get("ipvurl")
		if strings.EqualFold(lURL, "") {
			lDebug.Log(helpers.Elog, "GIL04", "url is missing")
			fmt.Fprint(w, helpers.GetError_String("GIL04", "Somthing is wrong please try again later"))
			return
		}

		lForWordErr, lErr := IPVLinkCheck(lDebug, "insert", lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL05", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL05", "Somthing is wrong please try again later"))
			return
		}
		if lForWordErr != nil {
			lDebug.Log(helpers.Elog, "GIL06", lForWordErr)
			fmt.Fprint(w, helpers.GetError_String("GIL06",
				helpers.ErrPrint(lForWordErr)))
			return
		}

		lIPVUrlRec, lErr := InsertIPVLinkInfo(lDebug, lUid, lSid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL07", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL07", "Somthing is wrong please try again later"))
			return
		}

		lIPVUrlRec.Url = fmt.Sprintf("%s/ipvotp/%s", lURL, lIPVUrlRec.IPVLinkID)
		lDebug.Log(helpers.Details, "lIPVUrlRec:", lIPVUrlRec)
		lErr = SendEmail(lDebug, lIPVUrlRec, "eKYC IPV")
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL08", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL08", "Somthing is wrong please try again later"))
			return
		}
		// insert sms send to user
		if strings.ToUpper(common.MobileOtpSend) != "N" {
			lIPVSmsTemplate := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "TemplateCode")
			lErr = otp.SendOtptoMobile(r, "ekyc", lIPVUrlRec.Url, lIPVUrlRec.Mobile, "ekyc", lIPVSmsTemplate, lDebug)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "GIL09", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("GIL09", "Somthing is wrong please try again later"))
				return
			}
		}
		fmt.Fprint(w, helpers.GetMsg_String("", fmt.Sprintf("We have sent a link to complete IPV to your registered mobile '%s' & email '%s'", lIPVUrlRec.EncMobile, lIPVUrlRec.EncEmail)))

		lDebug.Log(helpers.Statement, "GenerateIPVlink (-)")

	}
}

func InsertIPVLinkInfo(pDebug *helpers.HelperStruct, pUid, pSid string) (lIPVUrlRec IPVUrlStruct, lErr error) {
	pDebug.Log(helpers.Statement, "InsertIPVLinkInfo (+)")

	// lSessionSHA256 := sha256.Sum256([]byte((uuid.NewV4()).String()))
	// lIPVUrlRec.IPVLinkID = hex.EncodeToString(lSessionSHA256[:])
	lIPVUrlRec.IPVLinkID = strings.ReplaceAll(uuid.NewV4().String(), "-", "")

	lCorestring := `INSERT INTO ekyc_ipv_link
	(Request_Uid, Session_Id, Updated_Session_Id,complit_Status, Createdtime, Updatedtime, Expiretime,use_status,ipv_session)
	VALUES(?,?,?,?,unix_timestamp(),unix_timestamp(),unix_timestamp(ADDDATE(now(), INTERVAL 10 MINUTE)),?,?);`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lCorestring, pUid, pSid, pSid, "N", "N", lIPVUrlRec.IPVLinkID)
	if lErr != nil {
		return lIPVUrlRec, helpers.ErrReturn(lErr)
	}

	lSelectQry := `select er.Phone,er.Email,er.Name_As_Per_Pan from ekyc_request er where er.Uid = ?`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lSelectQry, pUid)
	if lErr != nil {
		return lIPVUrlRec, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()

	for lRows.Next() {
		lErr := lRows.Scan(&lIPVUrlRec.Mobile, &lIPVUrlRec.Email, &lIPVUrlRec.UserName)
		if lErr != nil {
			return lIPVUrlRec, helpers.ErrReturn(lErr)
		}
	}
	lIPVUrlRec.EncMobile, lErr = common.GetEncryptedMobile(lIPVUrlRec.Mobile)
	if lErr != nil {
		return lIPVUrlRec, helpers.ErrReturn(lErr)
	}

	lIPVUrlRec.EncEmail, lErr = common.GetEncryptedemail(lIPVUrlRec.Email)
	if lErr != nil {
		return lIPVUrlRec, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "InsertIPVLinkInfo (-)")
	return lIPVUrlRec, nil
}

func UpdateIPVLinkUse(pDebug *helpers.HelperStruct, pIPVSid, pUid string) (lErr error) {
	pDebug.Log(helpers.Statement, "UpdateIPVLinkUse (+)")

	lCorestring := `UPDATE ekyc_ipv_link
	SET use_status='Y',Updatedtime=unix_timestamp()
	WHERE ipv_session=? and use_status='N'and Request_Uid=?;`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lCorestring, pIPVSid, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "UpdateIPVLinkUse (-)")
	return nil
}

func UpdateIPVSid(pDebug *helpers.HelperStruct, pIPVSid, pUid, pSid string) (lErr error) {
	pDebug.Log(helpers.Statement, "UpdateIPVSid (+)")

	lCorestring := `UPDATE ekyc_ipv_link
	SET Updated_Session_Id=?,Updatedtime=unix_timestamp()
	WHERE ipv_session=? and use_status='Y'and Request_Uid=?;`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lCorestring, pSid, pIPVSid, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "UpdateIPVSid (-)")
	return nil
}

func UpdateIPVComplit(pDebug *helpers.HelperStruct, pSid, pUid string) (lErr error) {
	pDebug.Log(helpers.Statement, "UpdateIPVComplit (+)")

	lCorestring := `UPDATE ekyc_ipv_link
	SET complit_Status='Y',Updatedtime=unix_timestamp()
	WHERE Request_Uid=? and Updated_Session_Id=? and use_status='Y' and complit_Status='N';`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lCorestring, pUid, pSid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "UpdateIPVComplit (-)")
	return nil
}

func IPVLinkCheck(pDebug *helpers.HelperStruct, pActionType, pId string) (lCustemErr, lErr error) {
	pDebug.Log(helpers.Statement, "IPVLinkCheck (+)")

	lAttempCount := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Count")

	var lSelectQry, lErrorString, lFlag string

	if strings.EqualFold(pActionType, "insert") {
		lSelectQry = fmt.Sprintf("WHEN (SELECT COUNT(*) FROM ekyc_ipv_link eil WHERE eil.Request_Uid = '%s' AND FROM_UNIXTIME(Createdtime) >= CURDATE()) <= %s", pId, lAttempCount)
		lErrorString = fmt.Sprintf("You Try to More then %s times.", lAttempCount)
	} else if strings.EqualFold(pActionType, "update") {
		lSelectQry = fmt.Sprintf("WHEN EXISTS(select * from ekyc_ipv_link eil where unix_timestamp(NOW()) between eil.Createdtime  and eil.Expiretime and eil.complit_Status='N' and eil.ipv_session ='%s')", pId)
		lErrorString = "link time has been Expire"
	} else {
		return nil, helpers.ErrReturn(fmt.Errorf("there will be no action name like %s", pActionType))
	}

	lQry := fmt.Sprintf(`SELECT 
    CASE 
        %s
        THEN 'N'
        ELSE 'Y'
    END AS Result;`, lSelectQry)
	pDebug.Log(helpers.Details, "lQry", lQry)

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lQry)
	if lErr != nil {
		return nil, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()

	for lRows.Next() {
		lErr := lRows.Scan(&lFlag)
		if lErr != nil {
			return nil, helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Details, "lQry Flag", lFlag)
	if strings.EqualFold(lFlag, "Y") {
		return helpers.ErrReturn(fmt.Errorf(lErrorString)), nil
	}

	pDebug.Log(helpers.Statement, "IPVLinkCheck (-)")

	return nil, nil
}

func IPVRequestID(pDebug *helpers.HelperStruct, pDbID string) (lUid string, lErr error) {
	pDebug.Log(helpers.Statement, "IPVRequestID (+)")

	lQry := `select eil.Request_Uid from ekyc_ipv_link eil where eil.ipv_session =?`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lQry, pDbID)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	defer lRows.Close()

	for lRows.Next() {
		lErr := lRows.Scan(&lUid)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "IPVRequestID (-)")

	return lUid, nil
}

func SendEmail(pDebug *helpers.HelperStruct, pTemplateData IPVUrlStruct, pAppName string) error {
	pDebug.Log(helpers.Statement, "SendEmail(+)")

	var lEmailRec emailUtil.EmailInput
	var lTpl bytes.Buffer

	lEmailPath := "./html/ipv.html"

	lTemp, err := template.ParseFiles(lEmailPath)
	if err != nil {
		// log.Println("CLES01 ", err)
		return helpers.ErrReturn(err)
	}

	lTemp.Execute(&lTpl, pTemplateData)
	lEmailbody := lTpl.String()

	// var lEmailRec util.EmailLogType
	lEmailRec.Body = lEmailbody
	// lEmailRec.Action = constant.INSERT

	//fetch details from toml
	lEmailRec.FromRaw = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig", "FromEmail")
	lEmailRec.FromDspName = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig", "FromDspName")
	// lEmailRec.EmailServer = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig","EmailServer")
	lEmailRec.ToEmailId = pTemplateData.Email
	// lEmailRec.ToEmailId = "saravanan.s@fcsonline.co.in"
	lEmailRec.ReplyTo = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig", "ReplyTo")
	// lEmailRec.CreatedProgram = tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig","CreatedProgramNo")
	// lEmailRec.Subject = "ekyv IPV Process"
	lEmailSubject := tomlconfig.GtomlConfigLoader.GetValueString("emaildetailconfig", "IPVSubject")

	// dt := time.Now().Format("02/Jan/2006 3:04:05 PM")

	//fetch details from coresettings

	// lEmailRec.Subject = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD, lEmailRec.Subject) + " " + dt
	lEmailRec.FromRaw = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD_GDB, lEmailRec.FromRaw)
	lEmailRec.FromDspName = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD_GDB, lEmailRec.FromDspName)
	// lEmailRec.EmailServer = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD, lEmailRec.EmailServer)
	// lEmailRec.ToEmailId = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD, lEmailRec.ToEmailId)
	lEmailRec.ReplyTo = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD_GDB, lEmailRec.ReplyTo)
	lEmailRec.Subject = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD_GDB, lEmailSubject)
	err = emailUtil.SendEmail(lEmailRec, pAppName)
	if err != nil {
		// log.Println("CLES02 ", err)
		return helpers.ErrReturn(err)
	}
	pDebug.Log(helpers.Statement, "SendEmail(-)")
	// }
	return nil
}
