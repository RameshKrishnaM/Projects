package ipvapi

// import (
// 	"encoding/base64"
// 	"encoding/json"
// 	"errors"
// 	"fcs23pkg/apps/v2/commonpackage"
// 	"fcs23pkg/common"
// 	"fcs23pkg/helpers"
// 	"fcs23pkg/integration/v2/pdfgenerate"
// 	"fcs23pkg/util/apiUtil"
// 	"fmt"
// 	"io"
// 	"io/ioutil"
// 	"net/http"
// 	"strings"
// )

// type DetailsStruct struct {
// 	Address   string  `json:"address"`
// 	Latitude  float64 `json:"latitude"`
// 	Accuracy  float64 `json:"accuracy"`
// 	Longitude float64 `json:"longitude"`
// }

// type SubActionStruct struct {
// 	ID                string        `json:"id"`
// 	Type              string        `json:"type"`
// 	Status            string        `json:"status"`
// 	Details           DetailsStruct `json:"details"`
// 	SubActionRef      string        `json:"sub_action_ref"`
// 	Optional          bool          `json:"optional"`
// 	Actioner          string        `json:"actioner"`
// 	InputData         string        `json:"input_data"`
// 	ObjAnalysisStatus string        `json:"obj_analysis_status"`
// 	FaceMatchObjType  string        `json:"face_match_obj_type"`
// 	FaceMatchStatus   string        `json:"face_match_status"`
// 	CompletedAt       string        `json:"completed_at"`
// }

// type ValidationStruct struct {
// 	OTPStrict struct {
// 		Score  float64 `json:"score"`
// 		Result string  `json:"result"`
// 	} `json:"OTP_STRICT"`
// }

// type ApprovalStruct struct {
// 	Property string `json:"property"`
// 	Value    string `json:"value"`
// }

// type ActionStruct struct {
// 	ID                string            `json:"id"`
// 	Type              string            `json:"type"`
// 	Status            string            `json:"status"`
// 	FileID            string            `json:"file_id"`
// 	SubFileID         string            `json:"sub_file_id"`
// 	SubActions        []SubActionStruct `json:"sub_actions"`
// 	ValidationResult  ValidationStruct  `json:"validation_result"`
// 	CompletedAt       string            `json:"completed_at"`
// 	FaceMatchObjType  string            `json:"face_match_obj_type"`
// 	FaceMatchStatus   string            `json:"face_match_status"`
// 	ObjAnalysisStatus string            `json:"obj_analysis_status"`
// 	Method            string            `json:"method"`
// 	OTP               string            `json:"otp"`
// 	ProcessingDone    bool              `json:"processing_done"`
// 	RetryCount        int               `json:"retry_count"`
// 	RulesData         struct {
// 		ApprovalRule []ApprovalStruct `json:"approval_rule"`
// 	} `json:"rules_data"`
// }

// type FileInfostruct struct {
// 	ID                 string         `json:"id"`
// 	UpdatedAt          string         `json:"updated_at"`
// 	CreatedAt          string         `json:"created_at"`
// 	Status             string         `json:"status"`
// 	CustomerIdentifier string         `json:"customer_identifier"`
// 	Actions            []ActionStruct `json:"actions"`
// 	ReferenceID        string         `json:"reference_id"`
// 	TransactionID      string         `json:"transaction_id"`
// 	CustomerName       string         `json:"customer_name"`
// 	ExpireInDays       int            `json:"expire_in_days"`
// 	ReminderRegistered bool           `json:"reminder_registered"`
// 	AutoApproved       bool           `json:"auto_approved"`
// }

// /*
// Purpose : This method is used to triger the third party API to fetch access token and it's meta data
// Request : body (pcode <String>)
// Response : file
// ===========
// On Success:
// ===========
// String format of access token and it's meta data
// ===========
// On Error:
// ===========
// "Error":

// Author : Saravanan
// Date : 05-June-2023
// */
// func CreatURl(pDebug *helpers.HelperStruct, pCode string) (string, error) {
// 	pDebug.Log(helpers.Statement, "GetTokenProccess (+)")
// 	var lLogRec commonpackage.ParameterStruct

// 	//create a array to carry the header value
// 	var lHeaderArr []apiUtil.HeaderDetails
// 	var lHeaderRec apiUtil.HeaderDetails
// 	//set header value
// 	lHeaderRec.Key = "Content-Type"
// 	lHeaderRec.Value = "application/json; charset=UTF-8"
// 	lHeaderArr = append(lHeaderArr, lHeaderRec)

// 	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)

// 	var lConfigFile = common.ReadTomlConfig("./toml/ipv.toml")
// 	Secret_Key := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["Secret_Key"])
// 	Secret_Value := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["Secret_Value"])
// 	lUrl := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["CreateURL"])

// 	lHeaderRec.Key = "Authorization"
// 	lHeaderRec.Value = "Basic " + basicAuth(Secret_Key, Secret_Value)
// 	lHeaderArr = append(lHeaderArr, lHeaderRec)
// 	lHeaderRec.Key = "Content-Type"
// 	lHeaderRec.Value = "application/json"
// 	lHeaderArr = append(lHeaderArr, lHeaderRec)

// 	//call the api to given URL
// 	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, "POST", pCode, lHeaderArr, "digilockerapi.GetTokenProccess")
// 	if lErr != nil {

// 		return lResp, helpers.ErrReturn(lErr)
// 	}
// 	lLogRec.EndPoint = lUrl
// 	lLogRec.Method = "POST"
// 	lLogRec.Request = pCode
// 	lLogRec.Response = lResp
// 	lLogRec.RequestType = "Digio API request create"
// 	lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, lErr.Error())
// 		return lResp, helpers.ErrReturn(lErr)
// 	}

// 	pDebug.Log(helpers.Statement, "GetTokenProccess (-)")

// 	return lResp, nil
// }

// func basicAuth(username, password string) string {
// 	auth := username + ":" + password
// 	return base64.StdEncoding.EncodeToString([]byte(auth))
// }

// func FileDownload(pdebug *helpers.HelperStruct, pId string) ([]pdfgenerate.FileSaveStruct, FileInfostruct, error) {

// 	pdebug.Log(helpers.Statement, "FileDownload (+)")
// 	pdebug.Log(helpers.Details, "pId :", pId)
// 	var lFileSaveArr []pdfgenerate.FileSaveStruct
// 	lFileData, lErr := GetFileData(pdebug, pId)
// 	if lErr != nil {
// 		return nil, lFileData, helpers.ErrReturn(lErr)
// 	}
// 	var lConfigFile = common.ReadTomlConfig("./toml/ipv.toml")
// 	lUrl := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["Download_URL"])
// 	lSecretKey := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["Secret_Key"])
// 	lSecretValue := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["Secret_Value"])
// 	lFilePath := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["DigiioFilePath"])
// 	for _, lFileInfo := range lFileData.Actions {

// 		lVideoURL := lUrl + lFileInfo.FileID
// 		lFileInfo, lErr := FileSave(pdebug, lVideoURL, lSecretKey, lSecretValue, lFilePath)
// 		if lErr != nil {
// 			return nil, lFileData, helpers.ErrReturn(lErr)
// 		}
// 		lFileSaveArr = append(lFileSaveArr, lFileInfo)
// 	}
// 	pdebug.Log(helpers.Statement, "FileDownload (-)")
// 	return lFileSaveArr, lFileData, nil

// }

// func FileSave(pdebug *helpers.HelperStruct, pUrl, pKey, pValue, pFilePath string) (pdfgenerate.FileSaveStruct, error) {
// 	pdebug.Log(helpers.Statement, "FileSave (+)")

// 	// Create a new HTTP client with Basic Authentication headers
// 	var lLogRec commonpackage.ParameterStruct
// 	var lFileSaveRec pdfgenerate.FileSaveStruct

// 	client := &http.Client{
// 		Transport: &http.Transport{
// 			Proxy: http.ProxyFromEnvironment,
// 		},
// 	}

// 	// Create a new HTTP request
// 	req, lErr := http.NewRequest("GET", pUrl, nil)
// 	if lErr != nil {
// 		return lFileSaveRec, helpers.ErrReturn(lErr)
// 	}
// 	lLogRec.EndPoint = pUrl
// 	lLogRec.Method = "GET"
// 	lLogRec.Response = "image/video file"
// 	lLogRec.RequestType = "Digio API file get"

// 	// Set Basic Authentication headers
// 	req.SetBasicAuth(pKey, pValue)

// 	// Make the GET request with the custom client
// 	lResp, lErr := client.Do(req)
// 	if lErr != nil {
// 		return lFileSaveRec, helpers.ErrReturn(lErr)
// 	}
// 	defer lResp.Body.Close()

// 	if strings.Contains(lResp.Header.Get("Content-Type"), "json") {
// 		lBody, lErr := ioutil.ReadAll(lResp.Body)
// 		if lErr != nil {
// 			return lFileSaveRec, helpers.ErrReturn(lErr)
// 		}
// 		lLogRec.ErrMsg = string(lBody)
// 		lErr = commonpackage.ApiLogEntry(lLogRec, pdebug)
// 		if lErr != nil {
// 			pdebug.Log(helpers.Elog, lErr.Error())
// 			return lFileSaveRec, helpers.ErrReturn(lErr)
// 		}
// 		return lFileSaveRec, helpers.ErrReturn(errors.New(string(lBody)))
// 	}

// 	lErr = commonpackage.ApiLogEntry(lLogRec, pdebug)
// 	if lErr != nil {
// 		pdebug.Log(helpers.Elog, lErr.Error())
// 		return lFileSaveRec, helpers.ErrReturn(lErr)
// 	}

// 	filename := getFilenameFromHeader(lResp.Header.Get("Content-Disposition"))

// 	lFileSaveRec.FileName = filename
// 	// lFileSaveRec.FullFilePath = pFilePath + filename
// 	// // Create a new file to save the downloaded content
// 	// file, lErr := os.Create(lFileSaveRec.FullFilePath)
// 	// if lErr != nil {
// 	// 	return lFileSaveRec, helpers.ErrReturn(lErr)
// 	// }
// 	// defer file.Close()

// 	// // Copy the response body to the file
// 	// _, lErr = io.Copy(file, lResp.Body)
// 	// if lErr != nil {
// 	// 	return lFileSaveRec, helpers.ErrReturn(lErr)
// 	// }

// 	var buffer strings.Builder

// 	// Create a new base64 encoder that writes to the buffer
// 	encoder := base64.NewEncoder(base64.StdEncoding, &buffer)

// 	// Copy the data from the reader to the encoder
// 	_, lErr = io.Copy(encoder, lResp.Body)
// 	if lErr != nil {
// 		return lFileSaveRec, helpers.ErrReturn(lErr)
// 	}

// 	// Close the encoder to flush any remaining data
// 	encoder.Close()

// 	// Get the Base64-encoded string from the buffer
// 	lFileSaveRec.File = buffer.String()
// 	lFileSaveRec.FileType = pdfgenerate.GetFileType(lFileSaveRec.FileName)

// 	lFileSaveRec.FileKey = "Image"
// 	if strings.Contains(lFileSaveRec.FileName, ".webm") {
// 		lFileSaveRec.FileKey = "Video"
// 	}
// 	lFileSaveRec.Process = "Ekyc_proof_upload"
// 	pdebug.Log(helpers.Statement, "FileSave (-)")
// 	return lFileSaveRec, nil

// }

// func getFilenameFromHeader(header string) string {
// 	parts := strings.Split(header, "filename=")
// 	if len(parts) > 1 {
// 		return strings.Trim(parts[1], "\" ")
// 	}
// 	return "default_filename"
// }

// func GetFileData(pDebug *helpers.HelperStruct, pId string) (FileInfostruct, error) {
// 	pDebug.Log(helpers.Statement, "GetFileData (+)")
// 	var lFileInfoRec FileInfostruct
// 	var lLogRec commonpackage.ParameterStruct
// 	var lHeaderArr []apiUtil.HeaderDetails
// 	var lHeaderRec apiUtil.HeaderDetails
// 	//set header value
// 	lHeaderRec.Key = "Content-Type"
// 	lHeaderRec.Value = "application/json; charset=UTF-8"
// 	lHeaderArr = append(lHeaderArr, lHeaderRec)

// 	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)

// 	var lConfigFile = common.ReadTomlConfig("./toml/ipv.toml")
// 	Secret_Key := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["Secret_Key"])
// 	Secret_Value := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["Secret_Value"])
// 	lUrl := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["FileDataUrl"]) + pId + "/response"

// 	lHeaderRec.Key = "Authorization"
// 	lHeaderRec.Value = "Basic " + basicAuth(Secret_Key, Secret_Value)
// 	lHeaderArr = append(lHeaderArr, lHeaderRec)
// 	lHeaderRec.Key = "Content-Type"
// 	lHeaderRec.Value = "application/json"
// 	lHeaderArr = append(lHeaderArr, lHeaderRec)

// 	//call the api to given URL
// 	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, "POST", "", lHeaderArr, "digilockerapi.GetFileData")
// 	if lErr != nil {
// 		return lFileInfoRec, helpers.ErrReturn(lErr)
// 	}
// 	lErr = json.Unmarshal([]byte(lResp), &lFileInfoRec)
// 	if lErr != nil {
// 		return lFileInfoRec, helpers.ErrReturn(lErr)
// 	}
// 	pDebug.Log(helpers.Details, lResp)

// 	lLogRec.EndPoint = lUrl
// 	lLogRec.Method = "POST"
// 	lLogRec.Response = lResp
// 	lLogRec.RequestType = "Digio API IPV meta data "

// 	lErr = commonpackage.ApiLogEntry(lLogRec, pDebug)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, lErr.Error())
// 		return lFileInfoRec, helpers.ErrReturn(lErr)
// 	}

// 	pDebug.Log(helpers.Statement, "GetFileData (-)")
// 	return lFileInfoRec, nil
// }
