package fileoperations

import (
	"encoding/base64"
	"fcs23pkg/apps/v1/address"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	files "fcs23pkg/file"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/pdfgenerate"
	"mime/multipart"
	"net/http"
	"os"
	"strings"
)

func XmlDataToFile(pReq *http.Request, pdebug *helpers.HelperStruct, pXmlData, pColumnName, pProcesstype string) error {
	pdebug.Log(helpers.Statement, "XMLDataToFile (+)")
	var lPanNO, lPanProofId string
	var lFileStructRec pdfgenerate.FileSaveStruct
	var lFiledataInfo pdfgenerate.ImageRespStruct
	lSessionId, lUid, lErr := sessionid.GetOldSessionUID(pReq, pdebug, common.EKYCCookieName)
	if lErr != nil {
		pdebug.Log(helpers.Elog, "XDF01"+lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	pdebug.SetReference(lUid)

	lCorestring := `SELECT nvl(Pan,"")
			FROM ekyc_request
			WHERE Uid  = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
	if lErr != nil {
		pdebug.Log(helpers.Elog, "XDF03"+lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lPanNO)
			pdebug.Log(helpers.Details, "lPanNO", lPanNO)
			if lErr != nil {
				pdebug.Log(helpers.Elog, "XDF04"+lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
	}
	lFileStructRec.FileName = pProcesstype + lPanNO + ".xml"
	pdebug.Log(helpers.Details, "lFileStructRec.FileName :", lFileStructRec.FileName)

	lFileStructRec.FileKey = "XMLProof"
	lFileStructRec.File = base64.StdEncoding.EncodeToString([]byte(pXmlData))
	lFileStructRec.FileType = "application/xml"
	lFileStructRec.Process = "Ekyc_proof_upload"
	var lFileStructArr []pdfgenerate.FileSaveStruct
	lFileStructArr = append(lFileStructArr, lFileStructRec)

	// lData, lErr := json.Marshal(&lFileStructArr)
	// if lErr != nil {
	// 	pdebug.Log(helpers.Elog, lErr.Error())
	// 	return helpers.ErrReturn(lErr)
	// }
	lFiledataInfo, lErr = pdfgenerate.Savefile(pdebug, lFileStructArr)
	if lErr != nil {
		pdebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lDocId := lFiledataInfo.FileDocID
	for _, lDocIdInfo := range lDocId {
		if strings.EqualFold(lDocIdInfo.FileKey, "XMLProof") {
			lPanProofId = lDocIdInfo.DocID
		}
	}
	// // lFilename := "SDFRSTGRET.xml"
	// lErr = writeToFile(lFilename, []byte(lXmlData), pdebug)
	// if lErr != nil {
	// 	pdebug.Log(helpers.Elog, "XDF05"+lErr.Error())
	// 	return helpers.ErrReturn(lErr)
	// }
	// lXMLFile, lErr := os.Open(lFilename)
	// if lErr != nil {
	// 	pdebug.Log(helpers.Elog, "XDF06"+lErr.Error())
	// 	return helpers.ErrReturn(lErr)
	// }

	// // lFileId, lErr := kycapi.XMLFileConstruct(lXmlData, lFilename)
	// // if lErr != nil {
	// // 			pdebug.Log(helpers.Elog, "XDF02"+lErr.Error())
	// // }
	// lFinal, lErr := GetFileStorageResult(lXMLFile, lFilename, pdebug)
	// if lErr != nil {
	// 	pdebug.Log(helpers.Elog, "XDF07"+lErr.Error())
	// 	return helpers.ErrReturn(lErr)
	// }

	// lFileId, lErr := HandleFinalResult(lFinal, pdebug)
	// if lErr != nil {
	// 	pdebug.Log(helpers.Elog, "XDF08"+lErr.Error())
	// 	return helpers.ErrReturn(lErr)
	// }
	// fmt.Println(lFileId)
	_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(pReq, pdebug, common.EKYCCookieName, lUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = address.ProofId(pdebug, lPanProofId, lUid, lSessionId, pColumnName, lTestUserFlag)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pdebug.RemoveReference()
	pdebug.Log(helpers.Statement, "XMLDataToFile (-)")
	return nil
}

func writeToFile(pFileName string, pData []byte, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "writeToFile(+)")
	lFile, lErr := os.Create(pFileName)
	if lErr != nil {
		return lErr
	}
	defer lFile.Close()

	_, lErr = lFile.Write(pData)
	pDebug.Log(helpers.Statement, "writeToFile(-)")
	return lErr
}

// func writeToFile(pFileName string, pData []byte) error {
// 	log.Println("writeToFile(+)")

// 	// Check if the file already exists
// 	if _, err := os.Stat(pFileName); !os.IsNotExist(err) {
// 		return errors.New("file already exists. Not overwriting")
// 	}

// 	// Create the file
// 	lFile, lErr := os.Create(pFileName)
// 	if lErr != nil {
// 		return lErr
// 	}
// 	defer lFile.Close()

// 	// Write data to the file
// 	_, lErr = lFile.Write(pData)
// 	if lErr != nil {
// 		return lErr
// 	}

// 	log.Println("writeToFile(-)")
// 	return nil
// }

func GetFileStorageResult(xmlData *os.File, pFilename string, pDebug *helpers.HelperStruct) (*files.FileDataType, error) {
	pDebug.Log(helpers.Statement, "getFileStorageResult(+) ")
	// file, lErr := os.Open(tempFilePath)
	// if lErr != nil {
	// 	log.Println(lErr.Error())
	// }
	defer xmlData.Close()

	fileHeader := &multipart.FileHeader{
		Filename: pFilename,
	}
	pDebug.Log(helpers.Statement, "getFileStorageResult(-) ")
	return files.FileStorage(xmlData, fileHeader)
}

func HandleFinalResult(lFinal *files.FileDataType, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "handleFinalResult(+) ")
	var data string

	var lFinalArr []files.FileDataType
	lFinalArr = append(lFinalArr, *lFinal)

	lInsertArr, lErr := files.InsertIntoAttachments(lFinalArr, "EKYC")
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", nil
	}
	data = lInsertArr[0].DocId

	pDebug.Log(helpers.Statement, "handleFinalResult(-) ")
	return data, nil
}
