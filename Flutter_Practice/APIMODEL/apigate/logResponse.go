package apigate

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"net/http"
	"strings"
)

// --------------------------------------------------------------------
// log request details
// --------------------------------------------------------------------
func LogResponse(pDebug *helpers.HelperStruct, pReq *http.Request, pRespStatus int, pRespData []byte, pRequestID string) {
	pDebug.Log(helpers.Statement, "LogResponse (+)")

	lReqDtl := GetRequestorDetail(pDebug, pReq)

	lRespInfo := ""
	if !strings.Contains(strings.ToLower(http.DetectContentType(pRespData)), "text/plain") {
		lRespInfo = "File Data"
	} else {
		lRespInfo = helpers.ReplaceBase64String(string(pRespData), 0)
	}
	//insert token
	insertString := "insert into xxapi_resp_log(request_id,response,responseStatus,requesteddate,realip,forwardedip,method,path,host,remoteaddr,header,body,endpoint) values (?,?,?,NOW(),?,?,?,?,?,?,?,?,?)"
	_, lErr := ftdb.NewEkyc_GDB.Exec(insertString, pRequestID, lRespInfo, pRespStatus, lReqDtl.RealIP, lReqDtl.ForwardedIP, lReqDtl.Method, lReqDtl.Path, lReqDtl.Host, lReqDtl.RemoteAddr, lReqDtl.Header, helpers.ReplaceBase64String(lReqDtl.Body, 0), lReqDtl.EndPoint)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "api log insert error", lErr.Error())
	}

	pDebug.Log(helpers.Statement, "LogResponse (-)")

}
