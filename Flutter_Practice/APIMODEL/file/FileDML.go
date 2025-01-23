package file

import (
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"log"
	"path/filepath"
	"strconv"
	"strings"
)

type FileDataType struct {
	DocId          string `json:"DocId"`
	FullFilePath   string `json:"FullFilePath"`
	ActualfileName string `json:"ActualfileName"`
	ParamName      string `json:"ParamName"`
	FileString     string `json:"FileString"`
}

func InsertIntoAttachments(InputData []FileDataType, clientId string) ([]FileDataType, error) {
	log.Println("insertIntoAttachments+")

	insertedID := ""

	for i := 0; i < len(InputData); i++ {

		coreString := `insert into document_attachment_details(FileType,FileName,FilePath,CreatedDate,CreatedBy,UpdatedDate,UpdatedBy)
					   values(?,?,?,Now(),?,Now(),?)`
		insertRes, err := ftdb.MariaEKYCPRD_GDB.Exec(coreString, getFileType(InputData[i].ActualfileName), InputData[i].ActualfileName, InputData[i].FullFilePath, clientId, clientId)
		if err != nil {
			common.LogError("file.InsertIntoAttachments", "(FIIA01)", err.Error())
			// return insertedID, err
			return InputData, err
		} else {
			returnId, _ := insertRes.LastInsertId()
			insertedID = strconv.FormatInt(returnId, 10)
			InputData[i].DocId = insertedID

			log.Println("inserted successfully")

		}
	}
	log.Println("InputData in FileDML.go Line 43", InputData)
	log.Println("insertIntoAttachments-")

	return InputData, nil
}

func getFileType(filename string) string {
	extn := strings.ToUpper((filepath.Ext(filename)))
	var result = ""

	switch extn {

	case ".PDF":
		result = "application/pdf"

	case ".JPEG":
		result = "images/jpeg"

	case ".JPG":
		result = "images/jpeg"

	case ".PNG":
		result = "images/png"

	}

	return result
}
