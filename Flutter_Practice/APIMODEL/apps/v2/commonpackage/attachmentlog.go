package commonpackage

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"strings"
)

func AttachmentlogFile(pReqId, pFiletype, pDocId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "AttachmentlogFile(+)")
	if pReqId == "" {
		pDebug.Log(helpers.Statement, "request should not be empty")
	}
	lId, lErr := FetchDocIdExist(pReqId, pFiletype, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Statement, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	if lId != "" {
		lErr = UpdateAttachmentLogHistory(pFiletype, pReqId, pDocId, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}
	lErr = InsertIntoAttachmentLogHistory(pReqId, pFiletype, pDocId, "EKYC", pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "AttachmentlogFile(-)")
	return nil
}

func UpdateAttachmentLogHistory(pFiletype, pReqId, pDocId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "UpdateAttachmentlogFile(+)")
	if !strings.EqualFold(pDocId, "") {
		lCoreString := `UPDATE ekyc_attachmentlog_history
	SET isActive = '0'
	WHERE Filetype = ? AND Reqid = ?`
		_, err := ftdb.NewEkyc_GDB.Exec(lCoreString, pFiletype, pReqId)
		if err != nil {
			pDebug.Log(helpers.Elog, err.Error())
			return helpers.ErrReturn(err)
		}
	}

	pDebug.Log(helpers.Statement, "UpdateAttachmentlogFile(-)")
	return nil
}

func InsertIntoAttachmentLogHistory(pReqId, pFiletype, pDocId string, createdBy string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "InsertIntoAttachmentlogFile(+)")
	lCoreString := `INSERT INTO ekyc_attachmentlog_history (Reqid, Filetype, isActive, DocId, CreatedDate, CreatedBy)
	values(?, ?, "1", ?, UNIX_TIMESTAMP(), ?)`

	_, err := ftdb.NewEkyc_GDB.Exec(lCoreString, pReqId, pFiletype, pDocId, createdBy)
	if err != nil {
		pDebug.Log(helpers.Elog, err.Error())
		return helpers.ErrReturn(err)
	}

	pDebug.Log(helpers.Statement, "InsertIntoAttachmentlogFile(-)")
	return nil
}
func FetchDocIdExist(pReqId, pFiletype string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "FetchDocIdExist(+)")
	var lId string
	lCorestring := `SELECT nvl(id,'')
		FROM ekyc_attachmentlog_history
		WHERE Reqid = ? AND  Filetype= ? `
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pReqId, pFiletype)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "FDE001", lErr.Error())
		return lId, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "FDE002", lErr.Error())
			return lId, helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "FetchDocIdExist(-)")
	return lId, nil
}
func DocIdActiveOrNOt(pReqId, pFiletype, pDocId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "DocIdActiveOrNOt(+)")
	var lisActive string
	lCorestring := `SELECT nvl(isActive,'')
		FROM ekyc_attachmentlog_history
		WHERE Reqid = ? AND  Filetype= ? and DocId = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pReqId, pFiletype, pDocId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "FDE001", lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lisActive)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "FDE002", lErr.Error())
			return helpers.ErrReturn(lErr)
		}
		if lisActive == "0" {
			lCoreString := `UPDATE ekyc_attachmentlog_history
			SET isActive = '0'
			WHERE Filetype = ? AND Reqid = ?`
			_, err := ftdb.NewEkyc_GDB.Exec(lCoreString, pFiletype, pReqId)
			if err != nil {
				pDebug.Log(helpers.Elog, err.Error())
				return helpers.ErrReturn(err)
			}
			lCoreString = `UPDATE ekyc_attachmentlog_history
			SET isActive = '1'
			WHERE Filetype = ? AND Reqid = ? and DocId = ? `
			_, err = ftdb.NewEkyc_GDB.Exec(lCoreString, pFiletype, pReqId, pDocId)
			if err != nil {
				pDebug.Log(helpers.Elog, err.Error())
				return helpers.ErrReturn(err)
			}
		}
	}
	pDebug.Log(helpers.Statement, "DocIdActiveOrNOt(-)")
	return nil
}
