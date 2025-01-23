package apiUtil

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
)

// This Structure is Used to pass parameters to LogEntry method.
type ApiCallLog struct {
	URL           string `json:"url"`
	Request_Json  string `json:"request_Json"`
	Response_Json string `json:"response_Json"`
	Method        string `json:"method"`
	Source        string `json:"source"`
	Flag          string `json:"flag"`
	LastId        int    `json:"lastId"`
	ErrorType     string `json:"error_type"`
}

/*
Pupose: This method is used to store the data for endppoint datatable
Parameters:

	send ApiCallLog as a parameter to this method

Response:

	    *On Sucess
	    =========
	    In case of a successful execution of this method, you will get the dpStructArr data
		from the a_ipo_oder_header Data Table

	    !On Error
	    ========
	    In case of any exception during the execution of this method you will get the
	    error details. the calling program should handle the error

Author: Vijay
Date: 13January2024
modify by :saravanan selvam (18-jan-2024)
*/
func ApiLogEntry(pDebug *helpers.HelperStruct, pInput ApiCallLog) (int, error) {
	pDebug.Log(helpers.Statement, "ApiLogEntry (+)")

	// create a instace to hold last inserted Id
	var lLastInsertId int

	// check is the flag is Insert
	if pInput.Flag == "INSERT" {
		lCorestring1 := `insert into xxexternal_apicall_log (EndPoint,RequestJson,ResponseJson,Method,CreatedBy,CreatedDate)
				values (?,?,?,?,?,now())`

		lInsertedId, lErr := ftdb.NewEkyc_GDB.Exec(lCorestring1, pInput.URL, helpers.ReplaceBase64String(pInput.Request_Json, 0), helpers.ReplaceBase64String(pInput.Response_Json, 0), pInput.Method, pInput.Source)
		if lErr != nil {
			// log.Println("ApiLogEntry:002", lErr.Error())
			return lLastInsertId, helpers.ErrReturn(lErr)
		} else {
			lLog, _ := lInsertedId.LastInsertId()
			lLastInsertId = int(lLog)
		}
		// Check if the flag is Update
	} else if pInput.Flag == "UPDATE" {
		lCorestring2 := `Update xxexternal_apicall_log SET ResponseJson = ?,UpdatedBy = ?,UpdatedDate = now() ,ErrMsg=?
			where id = ?`

		_, lErr := ftdb.NewEkyc_GDB.Exec(lCorestring2, helpers.ReplaceBase64String(pInput.Response_Json, 0), pInput.Source, pInput.ErrorType, pInput.LastId)
		if lErr != nil {
			// log.Println("ApiLogEntry:003", lErr.Error())
			return lLastInsertId, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "ApiLogEntry (-)")
	return lLastInsertId, nil
}
