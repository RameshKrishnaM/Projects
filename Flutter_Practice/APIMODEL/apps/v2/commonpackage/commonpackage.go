package commonpackage

import (
	"errors"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"log"
	"strings"
)

func GetRid(id string) (string, error) {
	log.Println("getRid(+)")
	var RId string
	corestring := `select Uid from ekyc_request where id = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(corestring, id)
	if lErr != nil {
		log.Println(lErr.Error() + "error")
		return "", lErr
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&RId)
			if lErr != nil {
				log.Println(lErr)
				return "", lErr
			}
		}
	}
	log.Println("getRid(-)")
	return RId, nil
}

func SplitFullName(pDebug *helpers.HelperStruct, pName string) (string, string, string, error) {

	pDebug.Log(helpers.Statement, "SplitName (+)")

	var lFirstName, lMiddleName, lLastName, ErrString string
	var lNameArrTrimmed []string

	if pName == "" {
		ErrString = "name cannot be empty"
		pDebug.Log(helpers.Elog, ErrString)
		return lFirstName, lMiddleName, lLastName, helpers.ErrReturn(errors.New(ErrString))
	}

	lName := strings.Split(pName, " ")
	lNameLen := 0
	for _, data := range lName {
		if strings.Trim(data, " ") != "" {
			lNameLen++
			lNameArrTrimmed = append(lNameArrTrimmed, data)
		}
	}
	switch lNameLen {
	case 1:
		if lNameArrTrimmed[0] != "" {
			lFirstName = lNameArrTrimmed[0]
			lMiddleName = ""
			lLastName = ""
		} else {
			ErrString = " Case 1 ---> Invalid name format"
			pDebug.Log(helpers.Elog, ErrString)
			return lFirstName, lMiddleName, lLastName, helpers.ErrReturn(errors.New(ErrString))
		}
	case 2:
		if lNameArrTrimmed[0] != "" && lNameArrTrimmed[1] != "" {
			lFirstName = lNameArrTrimmed[0]
			lMiddleName = ""
			lLastName = lNameArrTrimmed[1]
		} else {
			ErrString = " Case 2 ---> Invalid name format"
			pDebug.Log(helpers.Elog, ErrString)
			return lFirstName, lMiddleName, lLastName, helpers.ErrReturn(errors.New(ErrString))
		}
	case 3:
		if lNameArrTrimmed[0] != "" && lNameArrTrimmed[1] != "" && lNameArrTrimmed[2] != "" {
			lFirstName = lNameArrTrimmed[0]
			lMiddleName = lNameArrTrimmed[1]
			lLastName = lNameArrTrimmed[2]
		} else {
			ErrString = " Case 3 ---> Invalid name format"
			pDebug.Log(helpers.Elog, ErrString)
			return lFirstName, lMiddleName, lLastName, helpers.ErrReturn(errors.New(ErrString))
		}
	case lNameLen:
		if lNameArrTrimmed[0] != "" {
			lFirstName = lNameArrTrimmed[0]
		}
		if lNameArrTrimmed[1] != "" {
			lMiddleName = lNameArrTrimmed[1]
		}
		if lNameArrTrimmed[2] != "" {
			lLastName = strings.Join(lNameArrTrimmed[2:], " ")
		}
	default:
		ErrString = " Default ---> Invalid name format"
		pDebug.Log(helpers.Elog, ErrString)
		return lFirstName, lMiddleName, lLastName, helpers.ErrReturn(errors.New(ErrString))
	}

	pDebug.Log(helpers.Details, "Last Name:", lLastName)
	pDebug.Log(helpers.Details, "Middle Name:", lMiddleName)
	pDebug.Log(helpers.Details, "First Name:", lFirstName)

	pDebug.Log(helpers.Statement, "SplitName (-)")
	return lFirstName, lMiddleName, lLastName, nil
}
