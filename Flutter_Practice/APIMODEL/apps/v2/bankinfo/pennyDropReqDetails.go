package bankinfo

import (
	"database/sql"
	"errors"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
)

type pennyDropDetailsStruct struct {
	Pan   string `json:"pan"`
	Name  string `json:"name"`
	Email string `json:"email"`
	Phone string `json:"phone"`
	Id    int    `json:"id"`
}

func GetRequestId(db *sql.DB, SessionId string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "GetRequestid (+)")
	var lReqId string
	coreString := `select nvl(es.requestuid,"") 
	from ekyc_session es 
	where es.sessionid =?`
	rows, lerr := db.Query(coreString, SessionId)
	if lerr != nil {
		pDebug.Log(helpers.Elog, "bGRI001"+lerr.Error())
		return lReqId, helpers.ErrReturn(errors.New("bGRI001"))
	} else {
		defer rows.Close()
		for rows.Next() {
			lerr := rows.Scan(&lReqId)
			if lerr != nil {
				pDebug.Log(helpers.Elog, "bGRI002"+lerr.Error())
				return lReqId, helpers.ErrReturn(errors.New("bGRI002"))
			}
		}
	}
	pDebug.Log(helpers.Statement, "GetRequestid (-)")
	return lReqId, nil
}

func GetPDetails(RequestId, SessionId string, pBankInfo BankStruct, pDebug *helpers.HelperStruct) (pennyDropDetailsStruct, error) {
	pDebug.Log(helpers.Statement, "GetPDetails (+)")

	var lpennyDropDetails pennyDropDetailsStruct

	coreString := `INSERT INTO ekyc_penydrop_request_log
	(Request_Uid, Acc_Number, IFSC, MICR, Bank_Name, Bank_Branch, Session_Id, Updated_Session_Id, CreatedDate, UpdatedDate)
	VALUES( ?, ?, ?, ?, ?, ?, ?,?, unix_timestamp(), unix_timestamp());
			`
	lRows, lerr := ftdb.NewEkyc_GDB.Exec(coreString, RequestId, pBankInfo.ACCNO, pBankInfo.IFSC, pBankInfo.MICR, pBankInfo.BANK, pBankInfo.BRANCH, SessionId, SessionId)
	if lerr != nil {
		pDebug.Log(helpers.Elog, "bGPD001"+lerr.Error())
		return lpennyDropDetails, helpers.ErrReturn(errors.New("bGPD001"))
	}

	lPdRefId, lerr := lRows.LastInsertId()
	if lerr != nil {
		pDebug.Log(helpers.Elog, "bGPD001"+lerr.Error())
		return lpennyDropDetails, helpers.ErrReturn(errors.New("bGPD001"))
	}

	lpennyDropDetails.Id = int(lPdRefId)

	coreString = `select nvl(er.Pan,"") ,nvl(er.Name_As_Per_Pan,"") ,nvl(er.Email,"") ,nvl(er.Phone,"")
	from ekyc_request er 
	where er.Uid =?`
	rows, lerr := ftdb.NewEkyc_GDB.Query(coreString, RequestId)
	if lerr != nil {
		pDebug.Log(helpers.Elog, "bGPD001"+lerr.Error())
		return lpennyDropDetails, helpers.ErrReturn(errors.New("bGPD001"))
	} else {
		defer rows.Close()
		for rows.Next() {
			lerr := rows.Scan(&lpennyDropDetails.Pan, &lpennyDropDetails.Name, &lpennyDropDetails.Email, &lpennyDropDetails.Phone)
			if lerr != nil {
				pDebug.Log(helpers.Elog, "bGPD002"+lerr.Error())
				return lpennyDropDetails, helpers.ErrReturn(errors.New("bGPD002"))
			}
		}
	}
	pDebug.Log(helpers.Statement, "GetPDetails (-)")
	return lpennyDropDetails, nil
}
