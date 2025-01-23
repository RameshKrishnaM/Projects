package nominee

import (
	"encoding/base64"
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v1/ipv"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"io"
	"mime/multipart"
	"net/http"
)

type DocFile struct {
	FileKey         string `json:"keyname"`
	ContentType     string `json:"file_content_type"`
	FileProcessType string `json:"processtype"`
	File            string `json:"file"`
	FileName        string `json:"filename"`
}
type DocStruct struct {
	StatusCode string           `json:"statusCode"`
	Msg        string           `json:"msg"`
	Status     string           `json:"Status"`
	ErrMsg     string           `json:"ErrMsg"`
	Docid_info []responseStruct `json:"docid_info"`
}

type responseStruct struct {
	Filekey string `json:"filekey"`
	Docid   string `json:"docid"`
}

func SaveFileApicall(r *http.Request, fileString string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "NomineeSaveFile (+)")
	var Req DocFile
	var lReqArr []DocFile
	var docId string
	// Req.ContentType = "application/rtf"

	// var encodedData string
	var hdr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	hdr = append(hdr, lHeaderRec)
	var respFile DocStruct



	baseURL := tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "baseUrl")
	saveFile := tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "savefile")
	lUrl := baseURL + saveFile

	encodedData, header, lErr := fileToBase64Encode(r, fileString, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "--NNSF01"+lErr.Error())
		return docId, helpers.ErrReturn(errors.New("nominee.NomineeSaveFile --NNSF01"))
	}
	Req.FileKey = fileString
	Req.ContentType = ipv.GetFileType(header.Filename)
	Req.FileName = header.Filename
	Req.File = encodedData
	Req.FileProcessType = "Nominee_Proof_Upload"

	lReqArr = append(lReqArr, Req)
	DocFile, err := json.Marshal(lReqArr)
	if err != nil {
		pDebug.Log(helpers.Elog, "--NNSF02"+err.Error())
		return docId, helpers.ErrReturn(errors.New("nominee.NomineeSaveFile --NNSF02"))
	} else {
		ApiReq := string(DocFile)
		pDebug.Log(helpers.Details, "ApiReq", ApiReq)
		lresp, err := apiUtil.Api_call(pDebug, lUrl, "POST", ApiReq, hdr, "")
		if err != nil {
			pDebug.Log(helpers.Elog, "--NNSF03"+err.Error())
			return docId, helpers.ErrReturn(errors.New("nominee.NomineeSaveFile --NNSF03"))
		} else {
			// log.Println("lresp", lresp)
			// Convert lresp to []byte
			lrespBytes := []byte(lresp)
			err = json.Unmarshal(lrespBytes, &respFile)
			if err != nil {
				pDebug.Log(helpers.Elog, "--NNSF04"+err.Error())
				return docId, helpers.ErrReturn(errors.New("nominee.NomineeSaveFile --NNSF04"))
			} else {
				pDebug.Log(helpers.Details, "respFile", respFile)
				if respFile.Status == "S" {
					docId = respFile.Docid_info[0].Docid
					pDebug.Log(helpers.Details, "docId", docId)
				} else if respFile.Status == "--NNSF05"+"E" {
					return docId, helpers.ErrReturn(errors.New("nominee.NomineeSaveFile --NNSF05"))
				}
			}
		}
	}
	pDebug.Log(helpers.Statement, "NomineeSaveFile (-)")
	return docId, nil
}

func fileToBase64Encode(pReq *http.Request, pKeyName string, pDebug *helpers.HelperStruct) (base64Encoded string, lFileHeader *multipart.FileHeader, lErr error) {
	pDebug.Log(helpers.Statement, "fileToBase64Encode (+)")
	lFileBody, lFileHeader, lErr := pReq.FormFile(pKeyName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, helpers.Elog, lErr.Error())
		return "", lFileHeader, helpers.ErrReturn(lErr)
	}
	lContent, lErr := io.ReadAll(lFileBody)
	if lErr != nil {
		pDebug.Log(helpers.Elog, helpers.Elog, lErr.Error())
		return "", lFileHeader, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "fileToBase64Encode (-)")
	return base64.StdEncoding.EncodeToString(lContent), lFileHeader, nil
}
