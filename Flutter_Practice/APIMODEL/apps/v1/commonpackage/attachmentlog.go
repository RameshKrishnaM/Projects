package commonpackage

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"strings"
)

func AttachmentlogFile(pReqId, pFiletype, pDocId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "AttachmentlogFile(+)")
	pDebug.Log(helpers.Details, "pFiletype", pFiletype)
	pDebug.Log(helpers.Details, "pDocId", pDocId)
	pDebug.Log(helpers.Details, "pReqId", pReqId)
	var lErr error
	var lCoreString string
	CreatedBy := "EKYC"
	if !strings.EqualFold(pDocId, "") {
		lCoreString = `UPDATE ekyc_attachmentlog_history
		SET isActive = '0'
		WHERE Filetype = ? AND Reqid = ? AND NOT EXISTS (
								 SELECT 1
								 FROM ekyc_attachmentlog_history
								where DocId = ?
							 )`
		_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pFiletype, pReqId, pDocId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}

	lCoreString = `INSERT INTO ekyc_attachmentlog_history (Reqid, Filetype, isActive, DocId, CreatedDate, CreatedBy)
	SELECT ?, ?, "1", ?, UNIX_TIMESTAMP(), ?
	FROM ekyc_attachmentlog_history eah
	WHERE NOT EXISTS (
		SELECT 1
		FROM ekyc_attachmentlog_history
		WHERE Reqid = ? AND DocId = ? AND Reqid = eah.Reqid AND DocId = eah.DocID
	)
	AND NOT EXISTS (
		SELECT 1
		FROM ekyc_attachmentlog_history
		WHERE Reqid = ? AND DocId = ?
	)
	LIMIT 1;`

	_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pReqId, pFiletype, pDocId, CreatedBy, pReqId, pDocId, pReqId, pDocId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "AttachmentlogFile(-)")
	return nil
}
