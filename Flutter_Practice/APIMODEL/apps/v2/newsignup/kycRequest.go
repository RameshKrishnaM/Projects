package newsignup

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"net/http"
)

//  Final ok
func DeActiveExistingRecord(pDebug *helpers.HelperStruct, pUid string) (lErr error) {
	pDebug.Log(helpers.Statement, "DeActiveExistingRecord(+)")

	lSqlString := `	UPDATE ekyc_request er
					JOIN ekyc_prime_request etr ON er.Uid = etr.Uid
					SET er.isActive = 'N', etr.isActive = 'N'
					WHERE er.Uid = ? `

	_, lErr = ftdb.NewEkyc_GDB.Exec(lSqlString, pUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "DAER01", lErr)
		return lErr
	}

	pDebug.Log(helpers.Statement, "DeActiveExistingRecord(-)")
	return nil
}

// New Record Insert -- new uid
func InsertNewRequest(pDebug *helpers.HelperStruct, pReq *http.Request, pSessionId, pTemp_Uid string) (lErr error) {
	pDebug.Log(helpers.Statement, "InsertNewRequest(+)")

	lDeviceName := pReq.Header.Get("App_mode")
	pDebug.Log(helpers.Details, "lDeviceName", lDeviceName)

	lSqlString := `
    INSERT INTO ekyc_request (
        Uid, Given_Name, Given_State, Phone, Email, Form_Status, CreatedDate, UpdatedDate, isActive, Created_Session_Id, Updated_Session_Id,app
    )
    SELECT
        Uid, Given_Name, Given_State, Phone, Email, 'OB', CreatedDate, UpdatedDate, isActive, ?, ?, ?
    FROM
        ekyc_prime_request
    WHERE
        Temp_Uid = ?
`

	_, lErr = ftdb.NewEkyc_GDB.Exec(lSqlString, pSessionId, pSessionId, lDeviceName, pTemp_Uid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "INR01", lErr)
		return lErr
	}

	pDebug.Log(helpers.Statement, "InsertNewRequest(-)")
	return nil
}

func StatusInsert(pDebug *helpers.HelperStruct, pUid, pSid, pPage_Name string) error {
	pDebug.Log(helpers.Statement, "StatusInsert (+)")
	insertString := `
		IF EXISTS (select * from ekyc_onboarding_status eos where Page_Name =? and Request_id =?)
		then
		 INSERT INTO ekyc_onboarding_status (Request_id, Page_Name, Status, Created_Session_Id, CreatedDate)
		 values(?,?,'U',?,unix_timestamp());
		ELSE
		 INSERT INTO ekyc_onboarding_status (Request_id, Page_Name, Status, Created_Session_Id, CreatedDate)
		 values(?,?,'I',?,unix_timestamp());
		END IF;`

	_, lErr := ftdb.NewEkyc_GDB.Exec(insertString, pPage_Name, pUid, pUid, pPage_Name, pSid, pUid, pPage_Name, pSid)
	if lErr != nil {
		pDebug.Log(helpers.Details, "SI01", lErr)
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "StatusInsert (-)")
	return nil
}
