package sessionid

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"strings"
)

func Dbcheck(pDebug *helpers.HelperStruct, pPhone, pEmail string) (string, string, error) {
	pDebug.Log(helpers.Statement, "Dbcheck(+)")
	var lPorE string

	lCorestring := `
	IF NOT EXISTS (SELECT * FROM ekyc_request  WHERE Phone = ? AND Email = ?)
	THEN
		IF EXISTS (SELECT * FROM ekyc_request WHERE Phone = ?)
		THEN
			SELECT 'P';
		ELSEIF EXISTS (SELECT * FROM ekyc_request WHERE Email = ?)
		THEN
			SELECT 'E';
		ELSE
			SELECT '';
		END IF;
	END IF;
		`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pPhone, pEmail, pPhone, pEmail)
	if lErr != nil {
		return "", "", helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lPorE)
		pDebug.Log(helpers.Details, "lRows", lRows)
		if lErr != nil {
			return "", "", helpers.ErrReturn(lErr)
		}
	}

	if strings.EqualFold(lPorE, "P") {
		return "The given Mobile number is already registered with us", lPorE, nil
	} else if strings.EqualFold(lPorE, "E") {
		return "The given Email ID is already registered with us", lPorE, nil
	}

	pDebug.Log(helpers.Statement, "Dbcheck(-)")
	return "", "", nil
}
