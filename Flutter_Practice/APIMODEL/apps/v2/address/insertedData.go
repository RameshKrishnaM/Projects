package address

import (
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"strings"
)

func PersonalDataInsertion(pColumnName, pValue, pHeadercode, pPrompt, pRequestId, pSessionId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "PersonalDataInsertion(+)")
	var lErr error
	if pPrompt == "Digilocker" {
		if pValue == "M" {
			pValue = "111"
		} else if pValue == "F" {
			pValue = "112"
		}
	} else {
		if pHeadercode != "" && pPrompt != "" {
			pValue, lErr = commonpackage.GetDefaultCodeFromPrompt(pDebug, pHeadercode, pPrompt, pValue)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
	}
	var lFlag string

	lCorestring := `SELECT CASE WHEN count(*) > 0 THEN 'Y' ELSE 'N' END AS Flag
	FROM ekyc_personal
	WHERE Request_Uid  = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lFlag)
			pDebug.Log(helpers.Details, "lFlag", lFlag)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
		if lFlag == "Y" {
			lCoreString := `update ekyc_personal set ` + pColumnName + `=?,Updated_Session_Id=?,UpdatedDate=unix_timestamp()
	  where Request_Uid=?`
			_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString, pValue, pSessionId, pRequestId)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		} else if lFlag == "N" {
			lCoreString := `insert into ekyc_personal(Request_Uid,` + pColumnName + `,Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate)
			values(?,?,?,?,unix_timestamp(),unix_timestamp())`
			_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pRequestId, pValue, pSessionId, pSessionId)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
	}
	pDebug.Log(helpers.Statement, "PersonalDataInsertion(-)")
	return nil
}
func KRAInsertion(pValue, pColumnName, pRequestId, pSessionId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "KRAInsertion(+)")

	lCoreString := `update ekyc_request set ` + pColumnName + `=?,Updated_Session_Id=?,UpdatedDate=unix_timestamp()
	  where Uid=?`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString, pValue, pSessionId, pRequestId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "KRAInsertion(-)")
	return nil
}
func RefIdInsert(pRefId, pRequestId, pSessionId, pColumnName string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "RefIdInsert (+)")
	var lFlag string

	lCorestring := `SELECT CASE WHEN count(*) > 0 THEN 'Y' ELSE 'N' END AS Flag
		FROM ekyc_address
		WHERE Request_Uid  = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lFlag)
			pDebug.Log(helpers.Details, "lFlag", lFlag)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}

		if lFlag == "Y" {
			lCorestring := `update ekyc_address set ` + pColumnName + `=?,Updated_Session_Id=?,UpdatedDate=unix_timestamp() where Request_Uid=?`
			_, lErr := ftdb.NewEkyc_GDB.Exec(lCorestring, pRefId, pSessionId, pRequestId)
			// fmt.Println(lCorestring, "lCorestring")
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		} else if lFlag == "N" {
			lCoreString := `insert into ekyc_address (Request_Uid,` + pColumnName + `,Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate)
		values(?,?,?,?,unix_timestamp(),unix_timestamp())`
			_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pRequestId, pRefId, pSessionId, pSessionId)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
	}

	pDebug.Log(helpers.Statement, "RefIdInsert (-)")

	return nil
}
func ProofId(pDebug *helpers.HelperStruct, pDocId, pRequestId, pSessionId, pColumnName, pTestUserFlag string) error {
	pDebug.Log(helpers.Statement, "ProofId (+)")
	var lFlag string

	// if strings.EqualFold(pTestUserFlag, "0") {
	// 	lSQLString := `update ekyc_attachments ea
	// 					set Bank_proof = '' , Income_proof = '', Signature = '', Pan_proof = '' , Income_prooftype = ''
	// 					where Request_id = ?
	// 					`
	// 	_, lErr := lDb.Query(lSQLString, pRequestId)
	// 	if lErr != nil {
	// 		return helpers.ErrReturn(lErr)
	// 	}
	// }
	if strings.EqualFold(pTestUserFlag, "0") {
		lErr := router.StatusInsert(pDebug, pRequestId, pSessionId, "DocumentUpload")
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}

	lCorestring := `SELECT CASE WHEN count(*) > 0 THEN 'Y' ELSE 'N' END AS Flag
		FROM ekyc_attachments
		WHERE Request_id  = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lFlag)
			pDebug.Log(helpers.Details, "lFlag", lFlag)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}

		if lFlag == "Y" {
			lCorestring := `update ekyc_attachments set ` + pColumnName + `=?,UpdatedSesion_Id=?,UpdatedDate=unix_timestamp() where Request_id=?`
			_, lErr := ftdb.NewEkyc_GDB.Exec(lCorestring, pDocId, pSessionId, pRequestId)
			// fmt.Println(lCorestring, "lCorestring")
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		} else if lFlag == "N" {
			lCoreString := `insert into ekyc_attachments (Request_id,` + pColumnName + `,Session_Id,UpdatedSesion_Id,CreatedDate,UpdatedDate)
		values(?,?,?,?,unix_timestamp(),unix_timestamp())`
			_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pRequestId, pDocId, pSessionId, pSessionId)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
	}

	pDebug.Log(helpers.Statement, "ProofId (-)")
	return nil
}

func ReplaceContainsString(pDebug *helpers.HelperStruct, pString string) string {
	pDebug.Log(helpers.Statement, "ReplaceContainsString (+)")
	pString = strings.ReplaceAll(pString, "[", "(")
	pString = strings.ReplaceAll(pString, "]", ")")
	pString = strings.ReplaceAll(pString, "#", "")
	pString = strings.ReplaceAll(pString, "{", "(")
	pString = strings.ReplaceAll(pString, "}", ")")
	pDebug.Log(helpers.Statement, "ReplaceContainsString (-)")
	return pString
}
