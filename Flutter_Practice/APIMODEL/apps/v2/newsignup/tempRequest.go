package newsignup

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"strings"
)

type ExistingDataStruct struct {
	ReqUid           string
	TempUid          string
	ReqTable_Uid     string
	Phone            string
	Email            string
	Name             string
	State            string
	FormStatus       string
	CreatedSessionId string
	UpdatedSessionId string
}

func GetExistingData(pDebug *helpers.HelperStruct, pType, pData string) (ExistingDataStruct, error) {
	pDebug.Log(helpers.Statement, "CheckDataExists(+)")

	var lSubCondition string
	var lExistingData ExistingDataStruct

	if strings.EqualFold(pType, "phone") {

		lSubCondition = "and etr.phone=? "

	} else if strings.EqualFold(pType, "email") {

		lSubCondition = "and etr.email=? "

	} else {
		lSubCondition = "and etr.Temp_Uid=? "
	}

	pDebug.Log(helpers.Details, "pType =>", pType, "pData =>", pData)

	lCorestring := `	select 
						nvl(etr.Temp_Uid,'') Temp_Uid , nvl(etr.Uid,'') Uid,nvl(etr.email,'') email,
						nvl(etr.phone,'') phone,nvl(er.Form_Status,'') Form_Status ,
						nvl( etr.Given_Name, '') name ,nvl(etr.Given_State,'') state, nvl(er.Uid,'') requestUid
					from 
						ekyc_prime_request etr
					left join
						ekyc_request er
					on er.Uid = etr.Uid 
					where etr.isActive ='Y'` + lSubCondition

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CPE001", lErr)
		return lExistingData, lErr
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lExistingData.TempUid, &lExistingData.ReqUid, &lExistingData.Email, &lExistingData.Phone, &lExistingData.FormStatus, &lExistingData.Name, &lExistingData.State, &lExistingData.ReqTable_Uid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CPE002", lErr)
			return lExistingData, lErr
		}

	}
	pDebug.Log(helpers.Details, "lExistingData =>", fmt.Sprintf("%v", lExistingData))

	pDebug.Log(helpers.Statement, "CheckDataExists(-)")
	return lExistingData, nil
}

func InsertNewTempRequest(pDebug *helpers.HelperStruct, pValidationRec UserStruct, pUid, pTempUid string) error {
	pDebug.Log(helpers.Statement, "InsertNewTempRequest(+)")

	// lTempUid = uuid.NewV4().String()

	var lEmail, lEmailValue string
	if pValidationRec.Email != "" {
		lEmail = ",email"
		lEmailValue = ",'" + pValidationRec.Email + "'"
	}
	lCorestring := `INSERT INTO ekyc_prime_request
					(Temp_Uid,Uid, Given_Name, Given_State, Phone, CreatedDate, UpdatedDate, isActive` + lEmail + `)
					VALUES(?, ?, ?, ?, ?, unix_timestamp(),unix_timestamp(),'Y'` + lEmailValue + `);`

	pDebug.Log(helpers.Details, "lCorestring =>", lCorestring)

	_, lErr := ftdb.NewEkyc_GDB.Exec(lCorestring, pTempUid, pUid, pValidationRec.Name, pValidationRec.State, pValidationRec.Phone)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "INR001", lErr)
		return lErr
	}
	pDebug.Log(helpers.Statement, "InsertNewTempRequest(-)")
	return nil
}
func UpdateEmailTempRequest(pDebug *helpers.HelperStruct, pEmail, pTempUid string) error {
	pDebug.Log(helpers.Statement, "UpdateEmailTempRequest(+)")

	lSqlString := `	UPDATE ekyc_prime_request 
					SET 
						email=?, 
						UpdatedDate=unix_timestamp()
					WHERE Temp_Uid = ? `

	_, lErr := ftdb.NewEkyc_GDB.Exec(lSqlString, pEmail, pTempUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "UER01", lErr)
		return lErr
	}
	pDebug.Log(helpers.Statement, "UpdateEmailTempRequest(-)")
	return nil
}
