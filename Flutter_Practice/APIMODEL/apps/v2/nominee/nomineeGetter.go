package nominee

import (
	"errors"
	"fcs23pkg/file"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"net/http"
	"strconv"
)

// Getter for PostNomineeFile
func RetriveAndStore_NomineeFileData(FileCount int, r *http.Request, pDebug *helpers.HelperStruct) ([]file.FileDataType, error) {

	pDebug.Log(helpers.Statement, "RetriveAndStore_NomineeFileData (+)")
	var fileDataCollection []file.FileDataType
	var filedata file.FileDataType

	pDebug.Log(helpers.Details, "FileCount--", FileCount)
	//3. all files (based on file count)
	for i := 1; i <= FileCount; i++ {

		//File String
		fileString := r.Form.Get("FileString_" + strconv.Itoa(i))
		filekey := "File_" + strconv.Itoa(i)

		// // Retrieve the file from form data
		// f, h, lErr := r.FormFile("File_" + strconv.Itoa(i))

		// if lErr != nil {

		// 	//common.LogError("nominee.RetriveAndStore_NomineeFileData", "(NRNF01)", err.Error())
		// 	//return fileDataCollection, err
		// 	pDebug.Log(helpers.Elog, lErr.Error())
		// 	return fileDataCollection, helpers.ErrReturn(errors.New("nominee.RetriveAndStore_NomineeFileData --NRNF01"))
		// } else {
		// 	defer f.Close()
		value := r.Form.Get(filekey)
		if _, err := strconv.Atoi(value); err == nil {
			// It's an integer value
			filedata.ParamName = "File_" + strconv.Itoa(i)
			filedata.FileString = fileString
			filedata.DocId = value
			fileDataCollection = append(fileDataCollection, filedata)
		} else {
			//Each File Saving
			_, _, lErr := r.FormFile(filekey)
			if lErr != nil {
				// Check if the error is "http.ErrMissingFile"
				if lErr == http.ErrMissingFile {
					continue
				}
				pDebug.Log(helpers.Elog, helpers.Elog, lErr.Error())
			} else {
				docId, lErr := SaveFileApicall(r, filekey, pDebug)
				// filedata, err := file.FileStorage(f, h)
				if lErr != nil {
					pDebug.Log(helpers.Elog, lErr.Error())
					return fileDataCollection, helpers.ErrReturn(errors.New("nominee.RetriveAndStore_NomineeFileData --NRNF01"))
				} else {

					// pDebug.Log(helpers.Details, "FileString--", string(h.Filename))
					// if filedata != nil {

					filedata.ParamName = "File_" + strconv.Itoa(i)
					filedata.FileString = fileString
					filedata.DocId = docId
					fileDataCollection = append(fileDataCollection, filedata)

					// }
				}
			}
		}
		// }
	}
	pDebug.Log(helpers.Details, "RetriveAndStore_NomineeFileData--fileDataCollection", fileDataCollection)
	//log.Println("RetriveAndStore_NomineeFileData-", fileDataCollection)
	pDebug.Log(helpers.Statement, "RetriveAndStore_NomineeFileData (-)")

	return fileDataCollection, nil
}

func GetRequestTableId(RequestId string, pDebug *helpers.HelperStruct) (int, error) {
	pDebug.Log(helpers.Statement, "GetRequestTableId (+)")
	var lTableId int

	coreString := ` select nvl(er.id,"")  from ekyc_request er 
	where er.Uid =?
			`
	rows, lerr := ftdb.NewEkyc_GDB.Query(coreString, RequestId)
	if lerr != nil {

		pDebug.Log(helpers.Elog, "GRTI01"+lerr.Error())
		return lTableId, helpers.ErrReturn(errors.New("nGRT001"))
	} else {
		defer rows.Close()
		for rows.Next() {
			lerr := rows.Scan(&lTableId)
			if lerr != nil {

				pDebug.Log(helpers.Elog, "GRTI02"+lerr.Error())
				return lTableId, helpers.ErrReturn(errors.New("nGRT001"))
			}
		}
	}
	pDebug.Log(helpers.Statement, "GetRequestTableId (-)")
	return lTableId, nil
}
