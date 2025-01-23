package docpreview

import (
	"fcs23pkg/coresettings"
	"fcs23pkg/ftdb"
	"fmt"
	"log"
)

// GenerateClientId generates a unique sequence number for the pledge API reference.
// It retrieves the next value from the sequence in the database and formats it as "FZXXXX" where XXXX is the sequence number.
// Returns the formatted sequence number as a string.
func GenerateClientId() (string, string, error) {
	// Log start of the function
	log.Println("GenerateClientId (+)")

	var lClientId string
	var lApplicationNo string

	lClientIdLength := coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, "ClientIdLength")
	lApplicationNoLength := coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, "ApplicationNoLength")

	// Prepare the SQL statement to retrieve the next value from the sequence
	// lCoreString := `SELECT CONCAT("FCS", LPAD(SequenceNo, 4, '0')) FROM (SELECT NEXT VALUE FOR pledge_api_reference SequenceNo) a`
	lCoreString := `SELECT CONCAT("FZ", LPAD(SequenceNo, ` + lClientIdLength + `, '0')) ClientId,CONCAT("FZEKYC", LPAD(SequenceNo, ` + lApplicationNoLength + `, '0')) as ApplicationNo FROM (SELECT NEXT VALUE FOR Client_Id_Generator SequenceNo) Client_Id_Generator`
	lStmt, lErr := ftdb.NewEkyc_GDB.Prepare(lCoreString)
	if lErr != nil {
		log.Println("GenerateClientId:001 (DPGCI-001)", lErr.Error())
		return lClientId, lApplicationNo, fmt.Errorf("DPGCI-001 %v", lErr.Error())
	}
	defer lStmt.Close()
	// Execute the prepared statement
	lRows, lErr := lStmt.Query()
	if lErr != nil {
		log.Println("GenerateClientId:002 (DPGCI-002)", lErr.Error())
		return lClientId, lApplicationNo, fmt.Errorf("DPGCI-002 %v", lErr.Error())
	}
	defer lRows.Close()

	// Process the result
	for lRows.Next() {
		// Scan and store the sequence number
		lErr := lRows.Scan(&lClientId, &lApplicationNo)
		if lErr != nil {
			log.Println("GenerateClientId:003 (DPGCI-003)", lErr.Error())
			return lClientId, lApplicationNo, fmt.Errorf("DPGCI-003 %v", lErr.Error())
		}
	}

	// Log end of the function
	log.Println("GenerateClientId (-)")

	// Return the formatted sequence number and no error
	return lClientId, lApplicationNo, nil
}
