package commonpackage

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
)

// This Structure is Used to pass parameters to LogEntry method.
type ParameterStruct struct {
	EndPoint    string `json:"endPoint"`
	Request     string `json:"request"`
	Response    string `json:"response"`
	Method      string `json:"method"`
	Status      string `json:"status"`
	ErrMsg      string `json:"errmsg"`
	RequestType string `json:"requesttype"`
}

/*
Pupose: This method is used to store the data for endppoint datatable
Parameters:

	send ParameterStruct as a parameter to this method

Response:

	    *On Sucess
	    =========
	    In case of a successful execution of this method, you will get the dpStructArr data
		from the a_ipo_oder_header Data Table

	    !On Error
	    ========
	    In case of any exception during the execution of this method you will get the
	    error details. the calling program should handle the error

Author:Sowmiya.L
Date:19-July-2023
*/
func ApiLogEntry(pInput ParameterStruct, pDebug *helpers.HelperStruct) error {

	pDebug.Log(helpers.Statement, "ApiLogEntry (+)")
	Created := "EKYC"
	// create a instace to hold last inserted Id
	// var lLogId int

	// lApiLogDetails := apigate.GetRequestorDetail(r)

	// check is the flag is Insert
	lSqlString1 := `insert into xxexternal_apicall_log (Method,RequestType,RequestJson,ResponseJson,EndPoint,CreatedBy,CreatedDate,UpdatedBy,UpdatedDate)
				values (?,?,?,?,?,?,now(),?,now())`

	_, lErr := ftdb.NewEkyc_GDB.Exec(lSqlString1, pInput.Method, pInput.RequestType, pInput.Request, pInput.Response, pInput.EndPoint, Created, Created)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "ALE02"+lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	// Check if the flag is Update

	pDebug.Log(helpers.Statement, "ApiLogEntry (-)")
	return nil
}
