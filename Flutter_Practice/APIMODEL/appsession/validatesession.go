package appsession

import (
	"fcs23pkg/ftdb"
	"fmt"
	"log"
	"net/http"
)

/*
-----------------------------------------------------------------------------------
function used to validate session and publick token cookie value of the web application
-----------------------------------------------------------------------------------
*/
func ValidateAppSession(req *http.Request, app string, CookieName string) (string, error) {
	log.Println("ValidateAppSession(+)")
	if CookieName != "" {
		sessionCookie, err := req.Cookie(CookieName)
		if err != nil {
			log.Println("error reading session cookie")
			log.Println(err)
			log.Println("ValidateAppSession(-)")
			return "", fmt.Errorf("invalid Session (0x1000)")
		} else {
			if ValidateSession(sessionCookie.Value, app) == "Y" {
				log.Println("ValidateAppSession(-)")
				return "Y", nil
			} else {
				log.Println("ValidateAppSession(-)")
				return "", fmt.Errorf("invalid Session (0x1001)")
			}
		}
	} else {
		log.Println("ValidateAppSession(-)")
		return "", fmt.Errorf("invalid Session (0x1002)")
	}

}

/*
-----------------------------------------------------------------------------------
function used to validate the validity of a webapp session
-----------------------------------------------------------------------------------
*/
func ValidateSession(sessionID string, app string) string {
	log.Println("ValidateSession+")
	valid := "N"
	//db, err := localdbconnect(MariaFTPRD)
	//db, err := localdbconnect(MariaAuthPRD)

	// sqlString := ` select NVL(min('Y'),'N')
	// 				from xxapp_sessions
	// 				where NOW() between createdtime and expiretime
	// 				and sessionid  = '` + sessionID + `'
	// 				and app  = '` + app + `'
	// 			`
	sqlString := ` select NVL(min('Y'),'N') 
		from xxapp_sessions 
		where NOW() between createdtime and expiretime 
		and sessionid  = ?
		and app  = ?
			`
	rows, err := ftdb.MariaFTPRD_GDB.Query(sqlString, sessionID, app)
	if err != nil {
		log.Println("select ValidateSession error", err.Error())
	} else {
		defer rows.Close()
		//get app details
		for rows.Next() {
			err := rows.Scan(&valid)
			if err != nil {
				log.Println("ValidateSession select record loop", err.Error())
			}
		}
	}

	log.Println("ValidateSession-")
	return valid
}
