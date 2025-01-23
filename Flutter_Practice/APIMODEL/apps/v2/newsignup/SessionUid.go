package newsignup

import (
	"database/sql"
	"fcs23pkg/apigate"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"net/http"
	"strings"
)

func IsActiveRequest(pDebug *helpers.HelperStruct, pDb *sql.DB, pIdType, pUid string) (string, error) {
	pDebug.Log(helpers.Statement, "IsActiveRequest (+)")
	var lReqStatus, lSubstring string
	if strings.EqualFold(pIdType, "Uid") {
		lSubstring = "ekyc_request where Uid='" + pUid + "'"
	} else {
		lSubstring = "ekyc_prime_request where temp_Uid='" + pUid + "'"
	}

	lcoreString := ` select nvl(isActive,'') from  ` + lSubstring

	rows, lErr := pDb.Query(lcoreString)
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
	pDebug.Log(helpers.Details, "pIdType -->", pIdType, "   pUid Id -->", pUid, "   Request Status -->", lReqStatus)

	pDebug.Log(helpers.Statement, "IsActiveRequest (-)")
	return lReqStatus, nil
}

func InsertUserSession(pDebug *helpers.HelperStruct, r *http.Request, pUid, pSid string) (lErr error) {
	pDebug.Log(helpers.Statement, "InsertUserSession (+)")
	pDebug.Log(helpers.Details, "InsertUser first Session Request ***", r)

	lReqDtl := apigate.GetRequestorDetail(pDebug, r)
	pDebug.Log(helpers.Details, "InsertUser second Session Request ***", r)

	lDevicetype := GetOSFromUserAgent(pDebug, r.Header.Get("User-Agent"))

	insertString := `
			insert into ekyc_session(requestuid,sessionid,createdtime,expiretime,realip,forwardedip,method,path,host,remoteaddr,devicetype)
			values (?,?,unix_timestamp() ,unix_timestamp(ADDDATE(now(), INTERVAL 5 HOUR) ),?,?,?,?,?,?,?)`
	_, lErr = ftdb.NewEkyc_GDB.Exec(insertString, pUid, pSid, lReqDtl.RealIP, lReqDtl.ForwardedIP, lReqDtl.Method, lReqDtl.Path, lReqDtl.Host, lReqDtl.RemoteAddr, lDevicetype)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "InsertUserSession (-)")

	return nil
}

func GetOSFromUserAgent(pDebug *helpers.HelperStruct, lUserAgent string) string {
	pDebug.Log(helpers.Statement, "getOSFromUserAgent (+)")

	// Convert user agent string to lowercase for case-insensitive comparison
	lUserAgent = strings.ToLower(lUserAgent)
	pDebug.Log(helpers.Details, lUserAgent, "lUserAgent")
	if strings.Contains(lUserAgent, "android") {
		return "Android"
	} else if strings.Contains(lUserAgent, "iphone") || strings.Contains(lUserAgent, "ipad") || strings.Contains(lUserAgent, "ios") {
		return "iOS"
	} else if strings.Contains(lUserAgent, "Windows NT") {
		return "PC"
	} else if strings.Contains(lUserAgent, "Macintosh") {
		return "Mac"
	} else if strings.Contains(lUserAgent, "X11") {
		return "Desktop (Linux)"
	}
	pDebug.Log(helpers.Statement, "getOSFromUserAgent (-)")
	return "Unknown"
}

// func GetTempUidSessionUID(pTempUid, pEmail string, pDebug *helpers.HelperStruct, r *http.Request) (string, string, string, string, error) {

// 	var lFinalUid, lFinalTempUid, lSessionId, lFinalRecordStatus string

// 	var lTempUid, lTempEmail, lTempTempUid string
// 	var lEmailUid, lEmailEmail, lEmailTempUid string

// 	lSessionSHA256 := sha256.Sum256([]byte(uuid.NewV4().String()))
// 	lSessionId = hex.EncodeToString(lSessionSHA256[:])
// 	lNewUid := strings.ReplaceAll(uuid.NewV4().String(), "-", "")
// 	lNewTempUid := uuid.NewV4().String()

// 	lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
// 	if lErr != nil {
// 		return lFinalUid, lFinalTempUid, lSessionId, lFinalRecordStatus, lErr
// 	}
// 	defer lDb.Close()

// 	insertString := `SELECT Uid, Email, Temp_Uid  FROM ekyc_prime_request WHERE Temp_Uid = ? and isActive='Y'`
// 	rows, lErr := lDb.Query(insertString, pTempUid)
// 	if lErr != nil {
// 		return lFinalUid, lFinalTempUid, lSessionId, lFinalRecordStatus, lErr
// 	}

// 	for rows.Next() {
// 		lErr := rows.Scan(&lTempUid, &lTempEmail, &lTempTempUid)
// 		if lErr != nil {
// 			return lFinalUid, lFinalTempUid, lSessionId, lFinalRecordStatus, lErr
// 		}
// 	}
// 	time.Sleep(5 * time.Second)
// 	insertString = `SELECT Uid, Email, Temp_Uid  FROM ekyc_prime_request WHERE Email = ? and isActive='Y'`
// 	rows, lErr = lDb.Query(insertString, pEmail)
// 	if lErr != nil {
// 		return lFinalUid, lFinalTempUid, lSessionId, lFinalRecordStatus, lErr
// 	}

// 	for rows.Next() {
// 		lErr := rows.Scan(&lEmailUid, &lEmailEmail, &lEmailTempUid)
// 		if lErr != nil {
// 			return lFinalUid, lFinalTempUid, lSessionId, lFinalRecordStatus, lErr
// 		}
// 	}

// 	if lTempTempUid == lEmailTempUid {
// 		lFinalTempUid = lTempTempUid
// 	} else {
// 		lFinalTempUid = lNewTempUid
// 	}

// 	if lTempEmail == lEmailEmail {
// 		lFinalRecordStatus = "Old"
// 	} else {
// 		lFinalRecordStatus = "New"
// 	}

// 	if lTempUid == lEmailUid {
// 		lFinalUid = lTempUid
// 	} else {
// 		lFinalUid = lNewUid
// 	}

// 	return lFinalUid, lFinalTempUid, lSessionId, lFinalRecordStatus, lErr

// }

// func GetTempUidSessionUID(pTempUid, pEmail string, pDebug *helpers.HelperStruct, r *http.Request) (string, string, string, string, error) {
// 	var lFinalUid, lFinalTempUid, lSessionId, lFinalRecordStatus string

// 	// Generate session ID and new UIDs
// 	lSessionId = hex.EncodeToString(sha256.New().Sum([]byte(uuid.NewV4().String())))
// 	lNewUid := strings.ReplaceAll(uuid.NewV4().String(), "-", "")
// 	lNewTempUid := uuid.NewV4().String()

// 	// Connect to the database
// 	lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
// 	if lErr != nil {
// 		return "", "", lSessionId, "", lErr
// 	}
// 	defer lDb.Close()

// 	// Combined query for Temp_Uid and Email
// 	query := `
// 		SELECT
// 			nvl(t1.Uid, '') AS TempUid,
// 			nvl(t1.Temp_Uid, '') AS TempTempUid,
// 			nvl(t2.Uid, '') AS EmailUid,
// 			nvl(t2.Temp_Uid, '') AS EmailTempUid,
// 			CASE
// 				WHEN t1.Uid = t2.Uid THEN t1.Uid
// 				WHEN t1.Uid IS NULL THEN t2.Uid
// 				WHEN t2.Uid IS NULL THEN t1.Uid
// 				ELSE ?
// 			END AS FinalUid,
// 			CASE
// 				WHEN t1.Temp_Uid = t2.Temp_Uid THEN t1.Temp_Uid
// 				ELSE ?
// 			END AS FinalTempUid,
// 			CASE
// 				WHEN t1.Uid = t2.Uid THEN 'Old'
// 				ELSE 'New'
// 			END AS RecordStatus
// 		FROM
// 			(SELECT Uid, Temp_Uid FROM ekyc_prime_request WHERE Temp_Uid = ? AND isActive = 'Y') t1
// 		FULL OUTER JOIN
// 			(SELECT Uid, Temp_Uid FROM ekyc_prime_request WHERE Email = ? AND isActive = 'Y') t2
// 		ON t1.Uid = t2.Uid`

// 	var tempUid, tempTempUid, emailUid, emailTempUid string

// 	rows, lErr := lDb.Query(query, lNewUid, lNewTempUid, pTempUid, pEmail)
// 	if lErr != nil {
// 		return lFinalUid, lFinalTempUid, lSessionId, lFinalRecordStatus, lErr
// 	}

// 	for rows.Next() {
// 		lErr := rows.Scan(&tempUid, &tempTempUid, &emailUid, &emailTempUid, &lFinalUid, &lFinalTempUid, &lFinalRecordStatus)
// 		if lErr != nil {
// 			return lFinalUid, lFinalTempUid, lSessionId, lFinalRecordStatus, lErr
// 		}
// 	}
// 	return lFinalUid, lFinalTempUid, lSessionId, lFinalRecordStatus, nil
// }
