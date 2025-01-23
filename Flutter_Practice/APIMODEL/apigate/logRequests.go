package apigate

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
)

//--------------------------------------------------------------------
//log request details
//--------------------------------------------------------------------
func LogRequest(pDebug *helpers.HelperStruct, pToken string, pReqDtl RequestorDetails, pRequestID string) {
	pDebug.Log(helpers.Statement, "LogRequest (+)")

	//insert token
	// if strings.Contains(strings.ToLower(pReqDtl.RequestType), "multipart/form-data") {
	// 	pReqDtl.Body = "file"
	// }
	insertString := "insert into xxapi_log(request_id,token,requesteddate,realip,forwardedip,method,path,host,remoteaddr,header,body,endpoint) values (?,?,NOW(),?,?,?,?,?,?,?,?,?)"
	_, lErr := ftdb.NewEkyc_GDB.Exec(insertString, pRequestID, pToken, pReqDtl.RealIP, pReqDtl.ForwardedIP, pReqDtl.Method, pReqDtl.Path, pReqDtl.Host, pReqDtl.RemoteAddr, pReqDtl.Header, helpers.ReplaceBase64String(pReqDtl.Body, 0), pReqDtl.EndPoint)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "api log insert error", lErr.Error())
	}

	pDebug.Log(helpers.Statement, "LogRequest (-)")

}
