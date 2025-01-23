package pdfgenerate

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"fmt"
	"image"
	"image/jpeg"
	"io"
	"net/http"
	"path/filepath"
	"strings"

	"github.com/disintegration/imaging"
)

//Purpose : carry the template Meta Datas
type TemplateStruct struct {
	JsonData    string         `json:"jsondata"`
	ProcessType string         `json:"processtype"`
	Attachment  []AttachStruct `json:"attachment"`
	ImageData   []ImgStruct    `json:"imagedata"`
	DbName      string         `json:"dbname"`
	SetPassword string         `json:"setpassword"`
	Password    string         `json:"password"`
}

//Purpose : carry Attachment Datas
type AttachStruct struct {
	AttachDocID string `json:"docid"`
	HasPassword string `json:"haspassword"`
	Password    string `json:"password"`
}

//Purpose : carry the Image Meta Datas
type ImgStruct struct {
	ImgDocID  string  `json:"imageid"`
	ImgKey    string  `json:"key"`
	ImgWeigth float64 `json:"weight"`
	ImgHeight float64 `json:"height"`
}

//Purpose : send the success responce Data
type RespStruct struct {
	Status    string `json:"status"`
	FileDocID string `json:"docid"`
	Message   string `json:"msg"`
}

type FileSaveStruct struct {
	FileKey  string `json:"keyname"`
	FileType string `json:"file_content_type"`
	FileName string `json:"filename"`
	File     string `json:"file"`
	Process  string `json:"processtype"`
}

type SavePwdFiletruct struct {
	FileKey     string `json:"keyname"`
	FileType    string `json:"file_content_type"`
	FileName    string `json:"filename"`
	File        string `json:"file"`
	Process     string `json:"processtype"`
	SetPassword string `json:"setpassword"`
	Password    string `json:"password"`
}

type ImageRespStruct struct {
	Status    string `json:"status"`
	FileDocID []struct {
		FileKey string `json:"filekey"`
		DocID   string `json:"docid"`
	} `json:"docid_info"`
	Message string `json:"msg"`
}

type FileReadStruct struct {
	Status   string `json:"status"`
	FileType string `json:"filetype"`
	FileName string `json:"filename"`
	File     string `json:"file"`
	FileByte []byte `json:"filebyte"`
	Message  string `json:"msg"`
}

// Get Pdf Page Count
type PageCount struct {
	Status    string `json:"status"`
	PageCount []int  `json:"pagecount"`
	Message   string `json:"msg"`
}

type ReqZipFileStruct struct {
	FileDocID   string `json:"docid"`
	Password    string `json:"password"`
	ProcessType string `json:"processtype"`
	FileName    string `json:"filename"`
}

type RespZipFileStruct struct {
	Status   string `json:"status"`
	Docid    string `json:"docid"`
	FileName string `json:"filename"`
	Message  string `json:"msg"`
}

/*
Purpose : This method is used to Triger the thirdparty Api to create a PDF file
Request :
Response : file
===========
On Success:
===========
docid:"324"
===========
On Error:
===========
"Error":
Author : Saravanan
Date : 18-NOV-2023
*/
func PDFGenerate(pDebug *helpers.HelperStruct, pTemplateData TemplateStruct, pUid, pSid string) (string, error) {
	pDebug.Log(helpers.Statement, "PDFGenerate (+)")
	// var lLogRec commonpackage.ParameterStruct
	//create a array to carry the header value

	lReqData, lErr := json.Marshal(&pTemplateData)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	var lPDFLogRec PDFLogStruct
	lPDFLogRec.ProcessStatus = "I"
	lPDFLogRec.ProcessType = pTemplateData.ProcessType
	lPDFLogRec.ReqJson = string(lReqData)
	lPDFLogRec.Sid = pSid
	lPDFLogRec.UID = pUid

	lErr = PDFGenerateLog(pDebug, lPDFLogRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	var lRespRec RespStruct
	//read the value from toml file

	//get URL from toml
	lPDFGenerateUrl := (tomlconfig.GtomlConfigLoader.GetValueString("fileconfig",
		"baseUrl") + tomlconfig.GtomlConfigLoader.GetValueString("fileconfig",
		"PDFGenerateUrl"))
	//re-build the url adding QueryParameter

	pDebug.Log(helpers.Details, "lPDFGenerateUrl :", lPDFGenerateUrl)
	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lPDFGenerateUrl, "POST", string(lReqData), lHeaderArr, "PDF generate")
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	// lLogRec.Method = "POST"
	// // lLogRec.Request = string(pPayload)
	// lLogRec.Response = lResp
	// // lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "PDF generate"
	// lLogRec.ErrMsg = ""
	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	return "", helpers.ErrReturn(lErr)
	// }

	// fmt.Println("lresp", lResp)
	lErr = json.Unmarshal([]byte(lResp), &lRespRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	if !strings.EqualFold(lRespRec.Status, common.SuccessCode) {
		return "", helpers.ErrReturn(errors.New(lRespRec.Message))
	}
	lPDFLogRec.ProcessStatus = lRespRec.Status
	lPDFLogRec.DocID = lRespRec.FileDocID
	lPDFLogRec.RespJson = lResp
	lErr = PDFGenerateLog(pDebug, lPDFLogRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "PDFGenerate (-)")

	return lRespRec.FileDocID, nil
}

/*
Purpose : This method is used to Triger the thirdparty Api to save a file
Request :
Response : file (base64 encript string)
===========
On Success:
===========
docid:"324"
===========
On Error:
===========
"Error":
Author : Saravanan
Date : 28-NOV-2023
*/
func Savefile(pDebug *helpers.HelperStruct, lFileSaveArr []FileSaveStruct) (ImageRespStruct, error) {

	// log.Println("\n\n\n\n\n\n\n\n\n\n\n***************************************************************************************", pTemplateData, "****************************************************************************************\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
	pDebug.Log(helpers.Statement, "Savefile (+)")
	// var lLogRec commonpackage.ParameterStruct
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	var lRespRec ImageRespStruct
	//read the value from toml file

	//get URL from toml
	lSaveFileUrl := (tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "baseUrl") + tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "savefile"))
	//re-build the url adding QueryParameter

	pDebug.Log(helpers.Details, "lPDFGenerateUrl :", lSaveFileUrl)
	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//call the api to given URL
	lTemplateData, lErr := json.Marshal(lFileSaveArr)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}
	lResp, lErr := apiUtil.Api_call(pDebug, lSaveFileUrl, "POST", string(lTemplateData), lHeaderArr, "Save File")
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}
	// lLogRec.Method = "POST"
	// // lLogRec.Request = string(pPayload)
	// lLogRec.Response = lResp
	// // lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "Save File"
	// lLogRec.ErrMsg = ""
	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	return lRespRec, helpers.ErrReturn(lErr)
	// }
	pDebug.Log(helpers.Statement, "Savefile (-)")

	// fmt.Println("lresp", lResp)
	lErr = json.Unmarshal([]byte(lResp), &lRespRec)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}
	if !strings.EqualFold(lRespRec.Status, common.SuccessCode) {
		return lRespRec, helpers.ErrReturn(errors.New(lRespRec.Message))
	}
	pDebug.Log(helpers.Statement, "Savefile (-)")

	return lRespRec, nil
}

/*
Purpose : This method is used to Triger the thirdparty Api to read the file in base64 encript string
Request : header docid-123
Response :
===========
On Success:
===========
docid:"file (base64 encript string)"
===========
On Error:
===========
"Error":
Author : Saravanan
Date : 28-NOV-2023
*/

func Read_file(pDebug *helpers.HelperStruct, pDocID string) (FileReadStruct, error) {
	pDebug.Log(helpers.Statement, "Read_file (+)")
	var lFileReadRec FileReadStruct
	// var lLogRec commonpackage.ParameterStruct
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//read the value from toml file

	//get URL from toml
	lReadFileUrl := (tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "baseUrl") + tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "ReadFile"))
	//re-build the url adding QueryParameter

	pDebug.Log(helpers.Details, "lPDFGenerateUrl :", lReadFileUrl)
	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "docid"
	lHeaderRec.Value = pDocID
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lReadFileUrl, "GET", "", lHeaderArr, "Read File")
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)
	}
	// lLogRec.Method = "GET"
	// // lLogRec.Request = string(pPayload)
	// lLogRec.Response = lResp
	// // lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "Read File"
	// lLogRec.ErrMsg = ""
	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	return lFileReadRec, helpers.ErrReturn(lErr)
	// }

	// fmt.Println("lresp", lResp)
	lErr = json.Unmarshal([]byte(lResp), &lFileReadRec)
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)
	}

	lFileReadRec.FileByte, lErr = base64.StdEncoding.DecodeString(lFileReadRec.File)
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)

	}

	if !strings.EqualFold(lFileReadRec.Status, common.SuccessCode) {
		return lFileReadRec, helpers.ErrReturn(errors.New(lFileReadRec.Message))
	}

	pDebug.Log(helpers.Statement, "Read_file (-)")
	return lFileReadRec, nil
}

// func FileToBase64Encode(pDebug *helpers.HelperStruct, pReq *http.Request, pKeyName, pProcess string) (FileSaveStruct, error) {
// 	pDebug.Log(helpers.Statement, "FileToBase64Encode (+)")

// 	var lFileStruct FileSaveStruct

// 	// Read content from the file
// 	lFileBody, lFileHeader, lErr := pReq.FormFile(pKeyName)
// 	if lErr != nil {
// 		return lFileStruct, helpers.ErrReturn(lErr)
// 	}
// 	lContent, lErr := io.ReadAll(lFileBody)
// 	if lErr != nil {
// 		return lFileStruct, helpers.ErrReturn(lErr)
// 	}
// 	lFileStruct.File = base64.StdEncoding.EncodeToString(lContent)
// 	lFileStruct.FileKey = pKeyName
// 	lFileStruct.FileName = lFileHeader.Filename
// 	lFileStruct.FileType = GetFileType(lFileHeader.Filename)
// 	lFileStruct.Process = pProcess
// 	// Encode the content in Base64

// 	// Construct the file struct or perform any other operations you need

// 	pDebug.Log(helpers.Statement, "FileToBase64Encode (-)")
// 	return lFileStruct, nil
// }

func FileToBase64Encode(pDebug *helpers.HelperStruct, pReq *http.Request, pKeyName, pProcess string) (FileSaveStruct, error) {
	pDebug.Log(helpers.Statement, "FileToBase64Encode (+)")

	var lFileStruct FileSaveStruct

	// Read content from the file
	lFileBody, lFileHeader, lErr := pReq.FormFile(pKeyName)
	if lErr != nil {
		return lFileStruct, helpers.ErrReturn(lErr)
	}
	lContent, lErr := io.ReadAll(lFileBody)
	if lErr != nil {
		return lFileStruct, helpers.ErrReturn(lErr)
	}
	lFielType := GetFileType(lFileHeader.Filename)
	if !strings.EqualFold(lFielType, "application/pdf") {
		if lFileHeader.Size > (1024*1024)*4 {
			lContent, lErr = CompressImageFile(pDebug, lContent, 1024*5, 90)
			if lErr != nil {
				fmt.Println(lErr)
			}
		}
	}

	lFileStruct.File = base64.StdEncoding.EncodeToString(lContent)
	lFileStruct.FileKey = pKeyName
	lFileStruct.FileName = lFileHeader.Filename
	lFileStruct.FileType = lFielType
	lFileStruct.Process = pProcess
	// Encode the content in Base64

	// Construct the file struct or perform any other operations you need

	pDebug.Log(helpers.Statement, "FileToBase64Encode (-)")
	return lFileStruct, nil
}

func CompressImageFile(pDebug *helpers.HelperStruct, fileBytes []byte, targetSize int, quality int) ([]byte, error) {
	pDebug.Log(helpers.Statement, "CompressImageFile (+)")

	img, _, lErr := image.Decode(bytes.NewReader(fileBytes))
	if lErr != nil {
		return nil, lErr
	}
	buf := new(bytes.Buffer)
	lErr = jpeg.Encode(buf, img, &jpeg.Options{Quality: quality})
	if lErr != nil {
		return nil, lErr
	}
	targetSize = targetSize * 1024
	initialSize := buf.Len()
	if initialSize <= targetSize {
	} else {
		for {
			resizedImg := imaging.Resize(img, img.Bounds().Dx()/2, img.Bounds().Dy()/2, imaging.Lanczos)

			buf.Reset()
			lErr = jpeg.Encode(buf, resizedImg, &jpeg.Options{Quality: quality})
			if lErr != nil {
				return nil, lErr
			}
			if buf.Len() <= targetSize || quality <= 1 {
				break
			}
			quality -= 10
		}
	}
	pDebug.Log(helpers.Statement, "CompressImageFile (-)")
	return buf.Bytes(), nil
}

func GetFileType(filename string) string {
	extn := strings.ToLower((filepath.Ext(filename)))
	result := ""
	switch extn {

	case ".pdf":
		result = "application/pdf"

	case ".jpeg":
		result = "images/jpeg"

	case ".jpg":
		result = "images/jpeg"

	case ".png":
		result = "images/png"

	default:
		extn = strings.ReplaceAll(extn, ".", "")
		result = "application/" + extn
	}

	return result
}

func Read_filefromPROD(pDebug *helpers.HelperStruct, pDocID string) (FileReadStruct, error) {
	pDebug.Log(helpers.Statement, "Read_filefromPROD (+)")
	var lFileReadRec FileReadStruct
	// var lLogRec commonpackage.ParameterStruct
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//read the value from toml file

	//get URL from toml
	lReadFileUrl := (tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "PRODbaseUrl") + tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "ReadFile"))
	//re-build the url adding QueryParameter

	pDebug.Log(helpers.Details, "lPDFGenerateUrl :", lReadFileUrl)
	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "docid"
	lHeaderRec.Value = pDocID
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lReadFileUrl, "GET", "", lHeaderArr, "Read File")
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)
	}
	// lLogRec.Method = "GET"
	// // lLogRec.Request = string(pPayload)
	// lLogRec.Response = lResp
	// // lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "Read File"
	// lLogRec.ErrMsg = ""
	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	return lFileReadRec, helpers.ErrReturn(lErr)
	// }

	// fmt.Println("lresp", lResp)
	lErr = json.Unmarshal([]byte(lResp), &lFileReadRec)
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)
	}

	lFileReadRec.FileByte, lErr = base64.StdEncoding.DecodeString(lFileReadRec.File)
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)

	}

	if !strings.EqualFold(lFileReadRec.Status, common.SuccessCode) {
		return lFileReadRec, helpers.ErrReturn(errors.New(lFileReadRec.Message))
	}

	pDebug.Log(helpers.Statement, "Read_filefromPROD (-)")
	return lFileReadRec, nil
}

func FileMoveProdtoDev(pDebug *helpers.HelperStruct, DocId string) (string, error) {
	pDebug.Log(helpers.Statement, "FileMoveProdtoDev (+)")

	var lDocID string

	pDebug.Log(helpers.Details, "PROD DocId", DocId)

	lFileInfo, lErr := Read_filefromPROD(pDebug, DocId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "DF03"+lErr.Error())
		return lDocID, helpers.ErrReturn(lErr)
	}
	// log.Println(lFileInfo)
	var lFileSaveRec FileSaveStruct
	var lFileSaveArr []FileSaveStruct
	lFileSaveRec.FileName = lFileInfo.FileName
	lFileSaveRec.File = lFileInfo.File
	lFileSaveRec.FileType = lFileInfo.FileType
	lFileSaveRec.FileKey = "PDF"
	lFileSaveRec.Process = "Ekyc_proof_upload"
	lFileSaveArr = append(lFileSaveArr, lFileSaveRec)
	// lReqData, lErr := json.Marshal(lFileSaveArr)
	// if lErr != nil {
	// 	return lDocID, helpers.ErrReturn(lErr)
	// }

	lSaveFileResp, lErr := Savefile(pDebug, lFileSaveArr)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	lDocID = lSaveFileResp.FileDocID[0].DocID
	pDebug.Log(helpers.Details, "Local DocId", lDocID)

	pDebug.Log(helpers.Statement, "FileMoveProdtoDev (-)")

	return lDocID, nil
}

func GetPageCount(pDebug *helpers.HelperStruct, pDocID ...string) (PageCount, error) {
	pDebug.Log(helpers.Statement, "GetPageCount (+)")
	var lPageCountRec PageCount
	// var lLogRec commonpackage.ParameterStruct
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//read the value from toml file

	//get URL from toml
	lGetPageCountUrl := (tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "baseUrl") + tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "GetPageCount"))
	//re-build the url adding QueryParameter

	pDebug.Log(helpers.Details, "lPDFGenerateUrl :", lGetPageCountUrl)
	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "docid"
	lHeaderRec.Value = strings.Join(pDocID, ",")
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lGetPageCountUrl, "GET", "", lHeaderArr, "Get Page Count")
	if lErr != nil {
		return lPageCountRec, helpers.ErrReturn(lErr)
	}
	// lLogRec.Method = "GET"
	// // lLogRec.Request = string(pPayload)
	// lLogRec.Response = lResp
	// // lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "Get Page Count"
	// lLogRec.ErrMsg = ""
	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	return lPageCountRec, helpers.ErrReturn(lErr)
	// }

	// fmt.Println("lresp", lResp)
	lErr = json.Unmarshal([]byte(lResp), &lPageCountRec)
	if lErr != nil {
		return lPageCountRec, helpers.ErrReturn(lErr)
	}
	if !strings.EqualFold(lPageCountRec.Status, common.SuccessCode) {
		return lPageCountRec, helpers.ErrReturn(errors.New(lPageCountRec.Message))
	}

	pDebug.Log(helpers.Statement, "GetPageCount (-)")
	return lPageCountRec, nil
}

type PasswordFileStruct struct {
	Status   string `json:"status"`
	Docid    string `json:"docid"`
	FileType string `json:"filetype"`
	FileName string `json:"filename"`
	FileByte []byte `json:"filebyte"`
	File     string `json:"file"`
	Message  string `json:"msg"`
}
type MergeFileStruct struct {
	InputDocId  []string `json:"input_docid"`
	ProcessType string   `json:"processtype"`
}
type ProtectedFileStruct struct {
	InputDocId  string `json:"input_docid"`
	SetPassword string `json:"setpassword"`
}

func SetPwdFile(pDebug *helpers.HelperStruct, pDocID, pPassword string) (PasswordFileStruct, error) {
	pDebug.Log(helpers.Statement, "SetPwdFile (+)")
	var lFileReadRec PasswordFileStruct
	var lPWDfileRec ProtectedFileStruct
	// var lLogRec commonpackage.ParameterStruct
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//read the value from toml file

	//get URL from toml
	lReadFileUrl := (tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "baseUrl") + tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "SetPwdFile"))
	//re-build the url adding QueryParameter

	pDebug.Log(helpers.Details, "lPDFGenerateUrl :", lReadFileUrl)
	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lPWDfileRec.InputDocId = pDocID
	lPWDfileRec.SetPassword = pPassword

	lBodyData, lErr := json.Marshal(lPWDfileRec)
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "string(lBodyData) :", string(lBodyData))
	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lReadFileUrl, "POST", string(lBodyData), lHeaderArr, "Set Password File")
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)
	}
	// lLogRec.Method = "POST"
	// // lLogRec.Request = string(pPayload)
	// lLogRec.Response = lResp
	// // lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "Set Password File"
	// lLogRec.ErrMsg = ""
	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	return lFileReadRec, helpers.ErrReturn(lErr)
	// }

	// fmt.Println("lresp", lResp)
	lErr = json.Unmarshal([]byte(lResp), &lFileReadRec)
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)
	}

	lFileReadRec.FileByte, lErr = base64.StdEncoding.DecodeString(lFileReadRec.File)
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)

	}

	if !strings.EqualFold(lFileReadRec.Status, common.SuccessCode) {
		return lFileReadRec, helpers.ErrReturn(errors.New(lFileReadRec.Message))
	}

	pDebug.Log(helpers.Statement, "SetPwdFile (-)")
	return lFileReadRec, nil
}

func MergePDFFile(pDebug *helpers.HelperStruct, pProcessType, pUid, pSid string, pDocID ...string) (PasswordFileStruct, error) {
	pDebug.Log(helpers.Statement, "SetPwdFile (+)")
	var lFileReadRec PasswordFileStruct
	// var lLogRec commonpackage.ParameterStruct
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails

	var lMergeFileRec MergeFileStruct
	//read the value from toml file

	//get URL from toml
	lReadFileUrl := (tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "baseUrl") + tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "MergePDF"))
	//re-build the url adding QueryParameter

	pDebug.Log(helpers.Details, "lPDFGenerateUrl :", lReadFileUrl)
	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	lMergeFileRec.ProcessType = pProcessType
	lMergeFileRec.InputDocId = pDocID

	lBodyData, lErr := json.Marshal(lMergeFileRec)
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)
	}

	var lPDFLogRec PDFLogStruct
	lPDFLogRec.ProcessStatus = "I"
	lPDFLogRec.ProcessType = pProcessType
	lPDFLogRec.ReqJson = string(lBodyData)
	lPDFLogRec.Sid = pSid
	lPDFLogRec.UID = pUid

	lErr = PDFGenerateLog(pDebug, lPDFLogRec)
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)
	}

	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lReadFileUrl, "PUT", string(lBodyData), lHeaderArr, "Merge PDF")
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)
	}

	lErr = json.Unmarshal([]byte(lResp), &lFileReadRec)
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)
	}

	lFileReadRec.FileByte, lErr = base64.StdEncoding.DecodeString(lFileReadRec.File)
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)

	}

	if !strings.EqualFold(lFileReadRec.Status, common.SuccessCode) {
		return lFileReadRec, helpers.ErrReturn(errors.New(lFileReadRec.Message))
	}

	lPDFLogRec.DocID = lFileReadRec.Docid
	lPDFLogRec.RespJson = lResp
	lPDFLogRec.ProcessStatus = lFileReadRec.Status
	lErr = PDFGenerateLog(pDebug, lPDFLogRec)
	if lErr != nil {
		return lFileReadRec, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "SetPwdFile (-)")
	return lFileReadRec, nil
}

func SavePwdZipFile(pDebug *helpers.HelperStruct, pProcessType, pUid, pSid, pDocID, pPassword string) (string, error) {
	pDebug.Log(helpers.Statement, "SavePwdZipFile (+)")
	var lFileReadRec RespZipFileStruct
	var lFileDocIDReq ReqZipFileStruct
	// var lLogRec commonpackage.ParameterStruct
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails

	//read the value from toml file

	//get URL from toml
	lReadFileUrl := (tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "baseUrl") + tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "SaveZipFile"))
	//re-build the url adding QueryParameter

	pDebug.Log(helpers.Details, "lPDFGenerateUrl :", lReadFileUrl)
	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	lFileDocIDReq.ProcessType = pProcessType
	lFileDocIDReq.FileDocID = pDocID
	lFileDocIDReq.Password = pPassword
	lFileDocIDReq.FileName = pPassword

	lBodyData, lErr := json.Marshal(lFileDocIDReq)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	var lPDFLogRec PDFLogStruct
	lPDFLogRec.ProcessStatus = "I"
	lPDFLogRec.ProcessType = pProcessType
	lPDFLogRec.ReqJson = string(lBodyData)
	lPDFLogRec.Sid = pSid
	lPDFLogRec.UID = pUid

	lErr = PDFGenerateLog(pDebug, lPDFLogRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lReadFileUrl, "PUT", string(lBodyData), lHeaderArr, "Merge PDF")
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	lErr = json.Unmarshal([]byte(lResp), &lFileReadRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	if !strings.EqualFold(lFileReadRec.Status, common.SuccessCode) {
		return "", helpers.ErrReturn(errors.New(lFileReadRec.Message))
	}

	lPDFLogRec.DocID = lFileReadRec.Docid
	lPDFLogRec.RespJson = lResp
	lPDFLogRec.ProcessStatus = lFileReadRec.Status
	lErr = PDFGenerateLog(pDebug, lPDFLogRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "SavePwdZipFile (-)")
	return lFileReadRec.Docid, nil
}

/*
Purpose : This method is used to Triger the thirdparty Api to save a file and set the password
Request :
Response : file (base64 encript string)
===========
On Success:
===========
docid:"324"
===========
On Error:
===========
"Error":
Author : Saravanan
Date : 03-Apr-2024
*/
func PWDSavefile(pDebug *helpers.HelperStruct, pTemplateData string) (ImageRespStruct, error) {

	pDebug.Log(helpers.Statement, "PWDSavefile (+)")
	// var lLogRec commonpackage.ParameterStruct
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	var lRespRec ImageRespStruct
	//read the value from toml file

	//get URL from toml
	lSavePDFpasswordUrl := (tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "baseUrl") + tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "SavePDFpasswordFile"))
	//re-build the url adding QueryParameter

	pDebug.Log(helpers.Details, "SavePDFpasswordFile :", lSavePDFpasswordUrl)
	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lSavePDFpasswordUrl, "POST", pTemplateData, lHeaderArr, "SavePDFpasswordFile")
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}
	// lLogRec.Method = "POST"
	// // lLogRec.Request = string(pPayload)
	// lLogRec.Response = lResp
	// // lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "SavePDFpasswordFile"
	// lLogRec.ErrMsg = ""
	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	return lRespRec, helpers.ErrReturn(lErr)
	// }

	// fmt.Println("lresp", lResp)
	lErr = json.Unmarshal([]byte(lResp), &lRespRec)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}
	if !strings.EqualFold(lRespRec.Status, common.SuccessCode) {
		return lRespRec, helpers.ErrReturn(errors.New(lRespRec.Message))
	}
	pDebug.Log(helpers.Statement, "PWDSavefile (-)")

	return lRespRec, nil
}

type PDFLogStruct struct {
	UID, Sid, ProcessType, ProcessStatus, ReqJson, RespJson, DocID string
}

func PDFGenerateLog(pDebug *helpers.HelperStruct, lPDFLogRec PDFLogStruct) (lErr error) {
	pDebug.Log(helpers.Statement, "PDFGenerateLog (+)")

	var lQry string

	if strings.EqualFold(lPDFLogRec.ProcessStatus, "I") {
		lQry = `INSERT INTO ekyc_pdf_generate_log
		(Request_Id, Session_Id, Template_Name, Request, Process_Status, CreatedDate)
		VALUES(?, ?, ?, ?, ?,UNIX_TIMESTAMP());`
		_, lErr = ftdb.NewEkyc_GDB.Exec(lQry, lPDFLogRec.UID, lPDFLogRec.Sid, lPDFLogRec.ProcessType, helpers.ReplaceBase64String(lPDFLogRec.ReqJson, 0), "N")
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	} else {
		lQry = `UPDATE ekyc_pdf_generate_log
		SET DocID=?, Responce=?, Process_Status=?, UpdatedDate=UNIX_TIMESTAMP()
		WHERE Request_Id=? and Template_Name=?;`
		_, lErr = ftdb.NewEkyc_GDB.Exec(lQry, lPDFLogRec.DocID, helpers.ReplaceBase64String(lPDFLogRec.RespJson, 0), lPDFLogRec.ProcessStatus, lPDFLogRec.UID, lPDFLogRec.ProcessType)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "PDFGenerateLog (-)")
	return nil
}

type ImageDataStruct struct {
	DocID    string  `json:"docid"`
	Width    int     `json:"width"`
	Height   int     `json:"height"`
	Imagepos string  `json:"imagepos"`
	DX       int     `json:"dx"`
	DY       int     `json:"dy"`
	Scale    float64 `json:"scale"`
	PageNo   string  `json:"pageno"`
}

type PDFFormStruct struct {
	DocID        string            `json:"docid"`
	ProcessType  string            `json:"processtype"`
	JsonMapData  string            `json:"jsondata"`
	Attachment   []AttachStruct    `json:"attachment"`
	ImageDataArr []ImageDataStruct `json:"imagearr"`
}

func FillPDFFile(pDebug *helpers.HelperStruct, pTemplateData PDFFormStruct, pUid, pSid string) (string, error) {
	pDebug.Log(helpers.Statement, "FillPDFFile (+)")
	// var lLogRec commonpackage.ParameterStruct
	//create a array to carry the header value

	lReqData, lErr := json.Marshal(&pTemplateData)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	var lPDFLogRec PDFLogStruct
	lPDFLogRec.ProcessStatus = "I"
	lPDFLogRec.ProcessType = pTemplateData.ProcessType
	lPDFLogRec.ReqJson = string(lReqData)
	lPDFLogRec.Sid = pSid
	lPDFLogRec.UID = pUid

	lErr = PDFGenerateLog(pDebug, lPDFLogRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	var lRespRec RespStruct
	//read the value from toml file

	//get URL from toml
	lPDFFillableUrl := (tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "baseUrl") + tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "FillPDFFile"))
	//re-build the url adding QueryParameter

	pDebug.Log(helpers.Details, "lPDFFillableUrl :", lPDFFillableUrl)
	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lPDFFillableUrl, "POST", string(lReqData), lHeaderArr, "FillPDFFile")
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	// lLogRec.Method = "POST"
	// // lLogRec.Request = string(pPayload)
	// lLogRec.Response = lResp
	// // lLogRec.EndPoint = req.URL.Path
	// lLogRec.RequestType = "PDF generate"
	// lLogRec.ErrMsg = ""
	// lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
	// if lErr != nil {
	// 	return "", helpers.ErrReturn(lErr)
	// }

	// fmt.Println("lresp", lResp)
	lErr = json.Unmarshal([]byte(lResp), &lRespRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	if !strings.EqualFold(lRespRec.Status, common.SuccessCode) {
		return "", helpers.ErrReturn(errors.New(lRespRec.Message))
	}
	lPDFLogRec.ProcessStatus = lRespRec.Status
	lPDFLogRec.DocID = lRespRec.FileDocID
	lPDFLogRec.RespJson = lResp
	lErr = PDFGenerateLog(pDebug, lPDFLogRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "FillPDFFile (-)")

	return lRespRec.FileDocID, nil
}

type PDFGridStruct struct {
	DocID       []AttachStruct `json:"docid"`
	Row         float64        `json:"rowcount"`
	Column      float64        `json:"columncount"`
	ProcessType string         `json:"processtype"`
}

func PDFGrid(pDebug *helpers.HelperStruct, pTemplateData PDFGridStruct, pUid, pSid string) (string, error) {
	pDebug.Log(helpers.Statement, "PDFGrid (+)")
	// var lLogRec commonpackage.ParameterStruct
	//create a array to carry the header value

	lReqData, lErr := json.Marshal(&pTemplateData)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	var lPDFLogRec PDFLogStruct
	lPDFLogRec.ProcessStatus = "I"
	lPDFLogRec.ProcessType = pTemplateData.ProcessType
	lPDFLogRec.ReqJson = string(lReqData)
	lPDFLogRec.Sid = pSid
	lPDFLogRec.UID = pUid

	lErr = PDFGenerateLog(pDebug, lPDFLogRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	var lRespRec RespStruct
	//read the value from toml file


	//get URL from toml
	lPDFFillableUrl := (tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "baseUrl") + tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "PDFGrid"))
	//re-build the url adding QueryParameter

	pDebug.Log(helpers.Details, "lPDFFillableUrl :", lPDFFillableUrl)
	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lPDFFillableUrl, "POST", string(lReqData), lHeaderArr, "PDFGrid")
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal([]byte(lResp), &lRespRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	if !strings.EqualFold(lRespRec.Status, common.SuccessCode) {
		return "", helpers.ErrReturn(errors.New(lRespRec.Message))
	}
	// fmt.Println(lRespRec)
	lPDFLogRec.ProcessStatus = lRespRec.Status
	lPDFLogRec.DocID = lRespRec.FileDocID
	lPDFLogRec.RespJson = lResp
	lErr = PDFGenerateLog(pDebug, lPDFLogRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "PDFGrid (-)")

	return lRespRec.FileDocID, nil
}
