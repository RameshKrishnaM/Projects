package commonpackage

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"strings"
)

func UpdateDocID(pDebug *helpers.HelperStruct, pType, pDocID, pUid, pSid string) error {
	pDebug.Log(helpers.Statement, "UpdateDocID (+)")

	columnName := ""
	if strings.EqualFold(pType, "SignedDocId") {
		columnName = "unsignedDocid =" + pDocID
	} else if strings.EqualFold(pType, "ESignedDocId") {
		columnName = "eSignedDocid =" + pDocID
	} else if strings.EqualFold(pType, "Finish") {
		columnName = "Form_Status = 'FS',submitted_date = unix_timestamp(),Process_Status=null,Owner=null,Staff=null"
	}
	if pSid != "" {
		lUpdateStr := `update ekyc_request set Updated_Session_Id= ?,UpdatedDate=unix_timestamp(),` + columnName + ` where Uid=?`
		_, lErr := ftdb.NewEkyc_GDB.Exec(lUpdateStr, pSid, pUid)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	} else {
		lUpdateStr := `update ekyc_request set UpdatedDate=unix_timestamp(),` + columnName + ` where Uid=?`
		_, lErr := ftdb.NewEkyc_GDB.Exec(lUpdateStr, pUid)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "UpdateDocID (-)")
	return nil
}
