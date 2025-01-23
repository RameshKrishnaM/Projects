package ipvapi

import (
	"encoding/base64"
	"encoding/json"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/pdfgenerate"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"strings"
	"time"
)

type DetailsStruct struct {
	Address   string  `json:"address"`
	Latitude  float64 `json:"latitude"`
	Accuracy  float64 `json:"accuracy"`
	Longitude float64 `json:"longitude"`
}

type SubActionStruct struct {
	ID                string        `json:"id"`
	Type              string        `json:"type"`
	Status            string        `json:"status"`
	Details           DetailsStruct `json:"details"`
	SubActionRef      string        `json:"sub_action_ref"`
	Optional          bool          `json:"optional"`
	Actioner          string        `json:"actioner"`
	InputData         string        `json:"input_data"`
	ObjAnalysisStatus string        `json:"obj_analysis_status"`
	FaceMatchObjType  string        `json:"face_match_obj_type"`
	FaceMatchStatus   string        `json:"face_match_status"`
	CompletedAt       string        `json:"completed_at"`
}

type ValidationStruct struct {
	OTPStrict struct {
		Score  float64 `json:"score"`
		Result string  `json:"result"`
	} `json:"OTP_STRICT"`
}

type ApprovalStruct struct {
	Property string `json:"property"`
	Value    string `json:"value"`
}

type ActionStruct struct {
	ID                string            `json:"id"`
	Type              string            `json:"type"`
	Status            string            `json:"status"`
	FileID            string            `json:"file_id"`
	AcctionType       string            `json:"action_ref"`
	SubFileID         string            `json:"sub_file_id"`
	SubActions        []SubActionStruct `json:"sub_actions"`
	ValidationResult  ValidationStruct  `json:"validation_result"`
	CompletedAt       string            `json:"completed_at"`
	FaceMatchObjType  string            `json:"face_match_obj_type"`
	FaceMatchStatus   string            `json:"face_match_status"`
	ObjAnalysisStatus string            `json:"obj_analysis_status"`
	Method            string            `json:"method"`
	OTP               string            `json:"otp"`
	ProcessingDone    bool              `json:"processing_done"`
	RetryCount        int               `json:"retry_count"`
	RulesData         struct {
		ApprovalRule []ApprovalStruct `json:"approval_rule"`
	} `json:"rules_data"`
}

type FileInfostruct struct {
	ID                 string         `json:"id"`
	UpdatedAt          string         `json:"updated_at"`
	CreatedAt          string         `json:"created_at"`
	Status             string         `json:"status"`
	CustomerIdentifier string         `json:"customer_identifier"`
	Actions            []ActionStruct `json:"actions"`
	ReferenceID        string         `json:"reference_id"`
	TransactionID      string         `json:"transaction_id"`
	CustomerName       string         `json:"customer_name"`
	ExpireInDays       int            `json:"expire_in_days"`
	ReminderRegistered bool           `json:"reminder_registered"`
	AutoApproved       bool           `json:"auto_approved"`
}

/*
Purpose : This method is used to triger the third party API to fetch access token and it's meta data
Request : body (pcode <String>)
Response : file
===========
On Success:
===========
String format of access token and it's meta data
===========
On Error:
===========
"Error":

Author : Saravanan
Date : 05-June-2023
*/
func CreatURl(pDebug *helpers.HelperStruct, pCode string) (string, error) {
	pDebug.Log(helpers.Statement, "GetTokenProccess (+)")

	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails

	Secret_Key := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Secret_Key")
	Secret_Value := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Secret_Value")
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "CreateURL")

	lHeaderRec.Key = "Authorization"
	lHeaderRec.Value = "Basic " + basicAuth(Secret_Key, Secret_Value)
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)
	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, "POST", pCode, lHeaderArr, "digilockerapi.GetTokenProccess")
	if lErr != nil {

		return lResp, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "GetTokenProccess (-)")

	return lResp, nil
}

func basicAuth(username, password string) string {
	auth := username + ":" + password
	return base64.StdEncoding.EncodeToString([]byte(auth))
}

type ActionInfoStruct struct {
	ActionType, FileID, CompliteAt string
}

func DigioFileDownload(pdebug *helpers.HelperStruct, lFileData FileInfostruct, pActionMap map[string]string) (lFileSaveArr []pdfgenerate.FileSaveStruct, lActionMApInfo map[string]ActionInfoStruct, lErr error) {

	pdebug.Log(helpers.Statement, "DigioFileDownload (+)")
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails

	var lFileSaveRec pdfgenerate.FileSaveStruct

	lActionMApInfo = make(map[string]ActionInfoStruct)

	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Download_URL")
	lSecretKey := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Secret_Key")
	lSecretValue := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Secret_Value")

	lHeaderRec.Key = "Authorization"
	lHeaderRec.Value = "Basic " + basicAuth(lSecretKey, lSecretValue)
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	for _, lFileInfo := range lFileData.Actions {
		lActionInfo, lActionFlag := lActionMApInfo[lFileInfo.AcctionType]
		var lActionInfoRec ActionInfoStruct
		lActionInfoRec.ActionType = lFileInfo.AcctionType
		lActionInfoRec.CompliteAt = lFileInfo.CompletedAt
		lActionInfoRec.FileID = lFileInfo.FileID
		if !lActionFlag {
			lActionMApInfo[lFileInfo.AcctionType] = lActionInfoRec
		} else {
			lCompleteFlag, lErr := DateCompair(lFileInfo.CompletedAt, lActionInfo.CompliteAt)
			if lErr != nil {
				return nil, lActionMApInfo, helpers.ErrReturn(lErr)
			}
			if lCompleteFlag {
				lActionMApInfo[lFileInfo.AcctionType] = lActionInfoRec
			}
		}

	}
	pdebug.Log(helpers.Details, "lActionMApInfo", lActionMApInfo)

	for _, lFileInfo := range lActionMApInfo {

		if strings.EqualFold(lFileInfo.FileID, pActionMap[lFileInfo.ActionType]) {
			continue
		}

		lResp, lRespFileInfo, lErr := apiUtil.Api_call2(pdebug, lUrl+lFileInfo.FileID, "GET", "", lHeaderArr, "digio.DownloadFile")
		if lErr != nil {
			return nil, lActionMApInfo, helpers.ErrReturn(lErr)
		}
		lFileSaveRec.FileKey = lFileInfo.ActionType
		lFileSaveRec.FileName = lRespFileInfo.FileName
		lFileSaveRec.File = base64.StdEncoding.EncodeToString([]byte(lResp))
		lFileSaveRec.FileType = lRespFileInfo.ContentType
		lFileSaveRec.Process = "Ekyc_proof_upload"

		lFileSaveArr = append(lFileSaveArr, lFileSaveRec)
	}
	pdebug.Log(helpers.Details, "lFileSaveArr", lFileSaveArr)

	pdebug.Log(helpers.Statement, "DigioFileDownload (-)")
	return lFileSaveArr, lActionMApInfo, nil
}

func GetFileData(pDebug *helpers.HelperStruct, pId string) (FileInfostruct, error) {
	pDebug.Log(helpers.Statement, "GetFileData (+)")
	var lFileInfoRec FileInfostruct
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)


	Secret_Key := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Secret_Key")
	Secret_Value := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Secret_Value")
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "FileDataUrl") + pId + "/response"

	lHeaderRec.Key = "Authorization"
	lHeaderRec.Value = "Basic " + basicAuth(Secret_Key, Secret_Value)
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, "POST", "", lHeaderArr, "digilockerapi.GetFileData")
	if lErr != nil {
		return lFileInfoRec, helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal([]byte(lResp), &lFileInfoRec)
	if lErr != nil {
		return lFileInfoRec, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, lResp)

	pDebug.Log(helpers.Statement, "GetFileData (-)")
	return lFileInfoRec, nil
}

func DateCompair(pDay1, pDay2 string) (lFlag bool, lErr error) {
	lLayout := "2006-01-02 15:04:05"
	lDay1, lErr := time.Parse(lLayout, pDay1)
	if lErr != nil {
		return lFlag, lErr
	}
	lDay2, lErr := time.Parse(lLayout, pDay2)
	if lErr != nil {
		return lFlag, lErr
	}
	return lDay1.After(lDay2), nil
}
