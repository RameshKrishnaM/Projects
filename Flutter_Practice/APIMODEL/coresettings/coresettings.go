package coresettings

import (
	"database/sql"
	"fcs23pkg/common"
	"log"
)

// --------------------------------------------------------------------
// function to get value from core setting for a given Key
// --------------------------------------------------------------------
func GetCoreSettingValue(db *sql.DB, key string) string {
	method := "coresettings.GetCoreSettingValue"
	var value string

	sqlString := "select valuev from CoreSettings where keyv ='" + key + "'"
	rows, err := db.Query(sqlString)
	if err != nil {
		log.Println(common.NoPanic, method, err.Error())
		return err.Error()
	}
	defer rows.Close()
	for rows.Next() {
		err := rows.Scan(&value)
		if err != nil {
			log.Println(common.NoPanic, method, err.Error())
		}
	}
	return value

}
