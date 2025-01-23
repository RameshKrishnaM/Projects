package otp

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
)

func OtpCount(pTypetosend string, pType string, pDebug *helpers.HelperStruct) (int, error) {

	pDebug.Log(helpers.Statement, "OtpCount (+)")

	var Count int

	sqlString := `
	SELECT COUNT(*)
	FROM otplog o 
	WHERE o.type = ?
	and sentTo = ?
	and createdDate >= CURDATE()
	`
	rows, err := ftdb.MariaEKYCPRD_GDB.Query(sqlString, pType, pTypetosend)
	pDebug.Log(helpers.Details, "sqlString:", sqlString)
	if err != nil {
		return Count, helpers.ErrReturn(err)
	}
	defer rows.Close()
	for rows.Next() {

		err := rows.Scan(&Count)
		if err != nil {
			return Count, helpers.ErrReturn(err)
		}

	}

	pDebug.Log(helpers.Details, "count:", Count)
	pDebug.Log(helpers.Statement, "OtpCount (-)")

	return Count, nil

}
