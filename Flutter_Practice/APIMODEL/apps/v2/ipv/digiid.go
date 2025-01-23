package ipv

import (
	"encoding/json"
	"fcs23pkg/apps/v2/bankinfo"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/ipvapi"
	"fcs23pkg/integration/v2/pdfgenerate"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

//digion Request struct

type DataStruct struct {
	CustomerID       string        `json:"customer_identifier"`
	CustomerName     string        `json:"customer_name"`
	RefID            string        `json:"reference_id"`
	Action           []interface{} `json:"actions"`
	Notify           bool          `json:"notify_customer"`
	Exp              int           `json:"expire_in_days"`
	GenerateAccToken bool          `json:"generate_access_token"`
	TransactionID    string        `json:"transaction_id"`
}

// video capture action struct
type VideoActionStruct struct {
	Type             string               `json:"type"`
	Title            string               `json:"title"`
	Description      string               `json:"description"`
	Method           string               `json:"method"`
	ValidationMode   string               `json:"validation_mode"`
	FaceMatchObjType string               `json:"face_match_obj_type"`
	VideoLength      int                  `json:"video_length"`
	SubAcction       interface{}          `json:"sub_actions"`
	ApprovalRule     []ApprovalRuleStruct `json:"approval_rule"`
	Optional         bool                 `json:"optional"`
	ActionType       string               `json:"action_ref"`
}

// selfi capture action struct
type SelfiActionStruct struct {
	Type             string               `json:"type"`
	Title            string               `json:"title"`
	Description      string               `json:"description"`
	ValidationMode   string               `json:"validation_mode"`
	FaceMatchObjType string               `json:"face_match_obj_type"`
	SubAcction       interface{}          `json:"sub_actions"`
	ApprovalRule     []ApprovalRuleStruct `json:"approval_rule"`
	Optional         bool                 `json:"optional"`
	ActionType       string               `json:"action_ref"`
}

// sign capture action struct
type SignActionStruct struct {
	Type              string `json:"type"`
	Title             string `json:"title"`
	Description       string `json:"description"`
	ImageUploadStatus bool   `json:"allow_image_upload"`
	UploadMode        string `json:"image_upload_mode"`
	ValidationType    string `json:"strict_validation_type"`
	ActionType        string `json:"action_ref"`
}

type ApprovalRuleStruct struct {
	Property string `json:"property"`
	Value    string `json:"value"`
}

type SubAcc1 struct {
	Type          string `json:"type"`
	Optional      bool   `json:"optional"`
	IDAnalysisReq bool   `json:"id_analysis_required"`
}

type SelfiSubStruct struct {
	Type           string `json:"type"`
	Optional       bool   `json:"optional"`
	IDAnalysisReq  bool   `json:"id_analysis_required"`
	FaceMateSource string `json:"face_match_obj_type"`
}
type SubAcc2 struct {
	Type        string `json:"type"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Optional    bool   `json:"optional"`
}

// Request capture dialog information
type IpvResponse struct {
	ReqID              string `json:"id"`
	CreatedAt          string `json:"created_at"`
	Status             string `json:"status"`
	CustomerIdentifier string `json:"customer_identifier"`
	ReferenceID        string `json:"reference_id"`
	TransactionID      string `json:"transaction_id"`
	CustomerName       string `json:"customer_name"`
	ExpireInDays       int    `json:"expire_in_days"`
	ReminderRegistered bool   `json:"reminder_registered"`
	AccessToken        struct {
		CreatedAt string `json:"created_at"`
		ID        string `json:"id"`
		EntityID  string `json:"entity_id"`
		ValidTill string `json:"valid_till"`
	} `json:"access_token"`
	AutoApproved      bool `json:"auto_approved"`
	RegenerateFlag    string
	IPVCompliteStatus string
	ExpireFlag        string
}

// Ipv DocID structur
type IPVStatusStruct struct {
	Status            string `json:"status"`
	Code              string `json:"code"`
	ImgDocID          string `json:"imgid"`
	VIdeoDocID        string `json:"videoid"`
	SignatureId       string `json:"signatureId"`
	IsVideoApplicable string `json:"isVideoApplicable"`
	IsSignApplicable  string `json:"isSignApplicable"`
}

// IPV location Structur
type LocationStruct struct {
	Latitude                  float64 `json:"latitude"`
	LookupSource              string  `json:"lookupSource"`
	Longitude                 float64 `json:"longitude"`
	LocalityLanguageRequested string  `json:"localityLanguageRequested"`
	Continent                 string  `json:"continent"`
	ContinentCode             string  `json:"continentCode"`
	CountryName               string  `json:"countryName"`
	CountryCode               string  `json:"countryCode"`
	PrincipalSubdivision      string  `json:"principalSubdivision"`
	PrincipalSubdivisionCode  string  `json:"principalSubdivisionCode"`
	City                      string  `json:"city"`
	Locality                  string  `json:"locality"`
	Postcode                  string  `json:"postcode"`
	PlusCode                  string  `json:"plusCode"`
}
type KeyPairStruct struct {
	Key      string `json:"key"`
	FileType string `json:"filetype"`
	Value    string `json:"value"`
}

func DigiID(w http.ResponseWriter, r *http.Request) {

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold(r.Method, "post") {
		lDebug := new(helpers.HelperStruct)
		lDebug.SetUid(r)
		lDebug.Log(helpers.Statement, "DigiID (+)")
		var lIpvRec IpvResponse
		// get client sid and uid
		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DDI01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DDI01", "Somthing is wrong please try again later"))
			return
		}
		lDebug.SetReference(lUid)
		//get client ipv digio request info
		lIpvRec.ReqID, lIpvRec.AccessToken.ID, lIpvRec.CustomerIdentifier, lIpvRec.RegenerateFlag, lIpvRec.IPVCompliteStatus, lIpvRec.ExpireFlag, _, lErr = CheckIPVStatus(lDebug, lUid, "")
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DDI02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DDI02", "Somthing is wrong please try again later"))
			return
		}
		// generate new request
		if strings.EqualFold(lIpvRec.IPVCompliteStatus, "S") || strings.EqualFold(lIpvRec.ExpireFlag, "Y") || strings.EqualFold(lIpvRec.IPVCompliteStatus, "") {
			lIpvRec, lErr = GenerateNweRequest(lDebug, lUid, lSid)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DDI04", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DDI04", "Somthing is wrong please try again later"))
				return
			}
		} else if strings.EqualFold(lIpvRec.RegenerateFlag, "Y") {
			// regenerate access token
			lDebug.Log(helpers.Details, "current token :", lIpvRec.AccessToken.ID)
			lIpvRec.AccessToken.ID, lErr = ReGenerateToken(lDebug, lUid, lSid, lIpvRec.ReqID, "")
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DDI03", lErr.Error())
				// fmt.Fprint(w, helpers.GetError_String("DDI03", "Somthing is wrong please try again later"))
				// return
				lIpvRec, lErr = GenerateNweRequest(lDebug, lUid, lSid)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "DDI05", lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("DDI05", "Somthing is wrong please try again later"))
					return
				}
			}
			lDebug.Log(helpers.Details, "modify token :", lIpvRec.AccessToken.ID)
		}
		// update zohocrm info
		lErr = sessionid.UpdateZohoCrmDeals(lDebug, r, common.IPVVerified)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DDI06", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DDI06", "Somthing is wrong please try again later"))
			return
		}
		lIpvRec.Status = common.SuccessCode
		lDigiioId, lErr := json.Marshal(lIpvRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DDI07", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DDI07", "Somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "Json lDigiioId :", string(lDigiioId))
		fmt.Fprint(w, string(lDigiioId))

		lDebug.Log(helpers.Statement, "DigiID (-)")

	}
}

// get client ipv request renerate info
func GetIPVType(lDebug *helpers.HelperStruct, lUid string) (lAdrsComeFrom, lSignExist string, lErr error) {
	lDebug.Log(helpers.Statement, "GetIPVType (+)")

	// client address type
	lCorestring := `
		select NVL(ea.Source_Of_Address,'') 
		from ekyc_address ea
		where ea.Request_Uid =?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
	if lErr != nil {
		return "", "", helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lAdrsComeFrom)
		lDebug.Log(helpers.Details, "lRows", lRows)
		if lErr != nil {
			return "", "", helpers.ErrReturn(lErr)

		}
	}
	// check user complite sign document
	lCorestring = `select case when nvl(ea.Signature,'')<>''then 'Y'else 'N' end from ekyc_attachments ea
		where ea.Request_id =?`
	lRows, lErr = ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
	if lErr != nil {
		return "", "", helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lSignExist)
		lDebug.Log(helpers.Details, "lRows", lRows)
		if lErr != nil {
			return "", "", helpers.ErrReturn(lErr)

		}
	}

	lDebug.Log(helpers.Statement, "GetIPVType (-)")
	return lAdrsComeFrom, lSignExist, nil
}

// get user basic information
func BasicInfo(pRequestId string, pDebug *helpers.HelperStruct) (string, string, string, error) {
	pDebug.Log(helpers.Statement, "BasicInfo (+)")
	var lName, lID, lEmail string

	lCorestring := `select nvl(id,""),nvl(Name_As_Per_Pan,""),nvl(Email,"") from ekyc_request where Uid = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return "", "", "", helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lID, &lName, &lEmail)
		if lErr != nil {
			return "", "", "", helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "BasicInfo (-)")
	return lID, lName, lEmail, nil
}

// document ref id struct
type data struct {
	ID      string `json:"digio_doc_id"`
	Message string `json:"message"`
	TxnId   string `json:"txn_id"`
}

func SaveFile(w http.ResponseWriter, r *http.Request) {

	if strings.EqualFold(r.Method, "post") {
		lDebug := new(helpers.HelperStruct)
		lDebug.SetUid(r)
		// lDebug.SetUid(r)
		lDebug.Log(helpers.Statement, "SaveFile (+)")

		var lDataint data
		lURL := r.Header.Get("ipvurl")
		lActionType := r.Header.Get("ActionType")
		lDebug.Log(helpers.Details, "lURL :", lURL)

		var lCurrentAddressRec LocationStruct
		lBody, lErr := ioutil.ReadAll(r.Body)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF01", "Somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, string(lBody), "lBody")
		// converting json body value to Structue
		lErr = json.Unmarshal(lBody, &lDataint)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF02", "Somthing is wrong please try again later"))
			return
		}
		//get client sid ,uid info
		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF03", "Somthing is wrong please try again later"))
			return
		}
		// digio ipv file and meta data info
		lDigiFileInfo, lErr := ipvapi.GetFileData(lDebug, lDataint.ID)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF04", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF04", "Somthing is wrong please try again later"))
			return
		}
		// get before complite ipv file id info
		lActionMap, lErr := GetActionInfo(lDebug, lUid, lDigiFileInfo.ID)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF09", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF09", "Somthing is wrong please try again later"))
			return
		}
		// save ipv subacction information
		lErr = CaptureSubRequInfo(lDebug, lUid, lSid, lDigiFileInfo)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF05", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF05", "Somthing is wrong please try again later"))
			return
		}
		// download ipv files using digio apicall
		lFinalArr, lCurrectActionMap, lErr := ipvapi.DigioFileDownload(lDebug, lDigiFileInfo, lActionMap)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF06", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF06", "Somthing is wrong please try again later"))
			return
		}
		//save download files
		lFileInfo, lErr := pdfgenerate.Savefile(lDebug, lFinalArr)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF07", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF07", "Somthing is wrong please try again later"))
			return
		}
		if strings.EqualFold(lActionType, "ReCapture") {
			// save onlu recapture information
			lErr = IPVReCaptureInsert(lDebug, lFileInfo, lDigiFileInfo, lCurrentAddressRec, lURL, lSid, lUid, lCurrectActionMap)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DSF08", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DSF08", "Somthing is wrong please try again later"))
				return
			}
		} else {
			// save all information
			lErr = IPVInsert(lDebug, lFileInfo, lDigiFileInfo, lCurrentAddressRec, lURL, lSid, lUid)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DSF08", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DSF08", "Somthing is wrong please try again later"))
				return
			}
		}
		// Penny Drop status api
		lErr = bankinfo.PennyDropValidationStatus(lUid, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "PennyDrop Status api error occured", lErr)
		}
		lDebug.Log(helpers.Details, "lIPVInfo :", lDigiFileInfo)

		fmt.Fprint(w, helpers.GetMsg_String("DSF0", "SUCCESS"))
		lDebug.Log(helpers.Statement, "SaveFile (-)")

	}
}

func IPVInsert(pDebug *helpers.HelperStruct, pDocinfo pdfgenerate.ImageRespStruct, pIPVData ipvapi.FileInfostruct, plocationStruct LocationStruct, pUrl, pSid, pUid string) error {
	pDebug.Log(helpers.Statement, "IPVInsert (+)")

	var lFiletypeRec KeyPairStruct
	var lFiletypeArr []KeyPairStruct

	lFileDocID := pDocinfo.FileDocID

	var lVideoID, lImgID, lOTP, lLatitude, lLongitude, lTimeStamp, lSignImageID string
	// Get file docid using dockey
	for _, lFileInfo := range lFileDocID {
		if strings.EqualFold(lFileInfo.FileKey, "digi_video") {
			lVideoID = lFileInfo.DocID
		} else if strings.EqualFold(lFileInfo.FileKey, "digi_selfie") {
			lImgID = lFileInfo.DocID
		} else if strings.EqualFold(lFileInfo.FileKey, "digi_Sign") {
			lSignImageID = lFileInfo.DocID
		}
		lFiletypeRec.FileType = lFileInfo.FileKey
		lFiletypeRec.Value = lFileInfo.DocID
		lFiletypeArr = append(lFiletypeArr, lFiletypeRec)
	}
	// get ipv meta information
	for _, lIPVInfo := range pIPVData.Actions {
		if strings.EqualFold(lIPVInfo.AcctionType, "digi_selfie") {
			lLatitude = fmt.Sprintf("%v", lIPVInfo.SubActions[0].Details.Latitude)
			lLongitude = fmt.Sprintf("%v", lIPVInfo.SubActions[0].Details.Longitude)
			lTimeStamp = lIPVInfo.CompletedAt
		} else if strings.EqualFold(lIPVInfo.AcctionType, "digi_video") {
			lOTP = lIPVInfo.OTP
		}

	}
	if !strings.EqualFold(lSignImageID, "") {
		// insert signature docid
		lErr := UpdateSignImage(pDebug, pUid, pSid, lSignImageID)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	// get location information using digio lLatitude and Longitude
	lCurrentAddress, lErr := ipvapi.GetGeoAddress(lLatitude, lLongitude, pDebug)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal([]byte(lCurrentAddress), &plocationStruct)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	// update digion request status complite
	lUpdateString := `
    	update ekyc_ipv_request_status set req_status= 'S' ,Updated_Session_Id=?,UpdatedDate=unix_timestamp()
		where Request_Uid=? and ipv_requestid=?;
	`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lUpdateString, pSid, pUid, pIPVData.ID)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	// insert or update ipv information

	lInsertString := `
	IF EXISTS (SELECT * FROM ekyc_ipv ei WHERE ei.Request_Uid=?)
    then
    	update ekyc_ipv set ipv_otp=?,video_Doc_Id=?,image_Doc_Id=?,latitude=?,longitude=?,time_stamp=?,Current_Address=?,Updated_Session_Id=?,UpdatedDate=unix_timestamp(),isActive=1
		where Request_Uid=?;
    ELSE
    	insert into ekyc_ipv(Request_Uid,ipv_otp,video_Doc_Id,image_Doc_Id,latitude,longitude,time_stamp,Current_Address,Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate,isActive)
    	values(?,?,?,?,?,?,?,?,?,?,unix_timestamp(),unix_timestamp(),1);
    END IF;
	`

	_, lErr = ftdb.NewEkyc_GDB.Exec(lInsertString, pUid, lOTP, lVideoID, lImgID, lLatitude, lLongitude, lTimeStamp, plocationStruct.City, pSid, pUid, pUid, lOTP, lVideoID, lImgID, lLatitude, lLongitude, lTimeStamp, plocationStruct.City, pSid, pSid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	// update ipv complite status
	lErr = UpdateIPVComplit(pDebug, pSid, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	// insert and update docid in attachment history table
	for _, lFiletypeKey := range lFiletypeArr {
		lErr = commonpackage.AttachmentlogFile(pUid, lFiletypeKey.FileType, lFiletypeKey.Value, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	// update in onboading status table
	lErr = router.StatusInsert(pDebug, pUid, pSid, "IPV")
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "IPVInsert (-)")
	return nil
}

func IPVReCaptureInsert(pDebug *helpers.HelperStruct, pDocinfo pdfgenerate.ImageRespStruct, pIPVData ipvapi.FileInfostruct, plocationStruct LocationStruct, pUrl, pSid, pUid string, lCurrectActionMap map[string]ipvapi.ActionInfoStruct) error {
	pDebug.Log(helpers.Statement, "IPVReCaptureInsert (+)")

	var lFiletypeRec KeyPairStruct
	var lFiletypeArr []KeyPairStruct

	lFileDocID := pDocinfo.FileDocID

	var lLatitude, lLongitude, lSignImageID string
	// Get file docid using dockey
	var lUpDateArr []string
	for _, lFileInfo := range lFileDocID {
		if strings.EqualFold(lFileInfo.FileKey, "digi_video") {
			lUpDateArr = append(lUpDateArr, fmt.Sprintf("video_Doc_Id=%s", lFileInfo.DocID))
		} else if strings.EqualFold(lFileInfo.FileKey, "digi_selfie") {
			lUpDateArr = append(lUpDateArr, fmt.Sprintf("image_Doc_Id=%s", lFileInfo.DocID))
		} else if strings.EqualFold(lFileInfo.FileKey, "digi_Sign") {
			lSignImageID = lFileInfo.DocID
		}
		lFiletypeRec.FileType = lFileInfo.FileKey
		lFiletypeRec.Value = lFileInfo.DocID
		lFiletypeArr = append(lFiletypeArr, lFiletypeRec)
	}
	// get ipv meta information only modify process
	for _, lIPVInfo := range pIPVData.Actions {
		if strings.EqualFold(lCurrectActionMap[lIPVInfo.AcctionType].CompliteAt, lIPVInfo.CompletedAt) {
			if strings.EqualFold(lIPVInfo.AcctionType, "digi_selfie") {
				lUpDateArr = append(lUpDateArr, fmt.Sprintf("latitude=%v", lIPVInfo.SubActions[0].Details.Latitude))
				lUpDateArr = append(lUpDateArr, fmt.Sprintf("longitude=%v", lIPVInfo.SubActions[0].Details.Longitude))
				lUpDateArr = append(lUpDateArr, fmt.Sprintf("time_stamp='%v'", lIPVInfo.CompletedAt))
			} else if strings.EqualFold(lIPVInfo.AcctionType, "digi_video") {
				lUpDateArr = append(lUpDateArr, fmt.Sprintf("ipv_otp=%v", lIPVInfo.OTP))
			}
		}

	}
	if !strings.EqualFold(lSignImageID, "") {
		// insert signature docid
		lErr := UpdateSignImage(pDebug, pUid, pSid, lSignImageID)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	// get location information using digio lLatitude and Longitude
	if !(strings.EqualFold(lLatitude, "") && strings.EqualFold(lLongitude, "")) {
		lCurrentAddress, lErr := ipvapi.GetGeoAddress(lLatitude, lLongitude, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
		lErr = json.Unmarshal([]byte(lCurrentAddress), &plocationStruct)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
		lUpDateArr = append(lUpDateArr, fmt.Sprintf("Current_Address=%v", plocationStruct.City))
	}
	// insert or update ipv information
	if len(lUpDateArr) != 0 {
		lInsertString := fmt.Sprintf(`
    	update ekyc_ipv set Updated_Session_Id=?,UpdatedDate=unix_timestamp(),isActive=1,%s
		where Request_Uid=?;
	`, strings.Join(lUpDateArr, ","))
		pDebug.Log(helpers.Details, "Qry :", lInsertString)
		_, lErr := ftdb.NewEkyc_GDB.Exec(lInsertString, pSid, pUid)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	// update digion request status complite
	lUpdateString := `
    	update ekyc_ipv_request_status set req_status= 'S' ,Updated_Session_Id=?,UpdatedDate=unix_timestamp()
		where Request_Uid=? and ipv_requestid=?;
	`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lUpdateString, pSid, pUid, pIPVData.ID)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	// update ipv complite status
	lErr = UpdateIPVComplit(pDebug, pSid, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	// insert and update docid in attachment history table
	for _, lFiletypeKey := range lFiletypeArr {
		lErr = commonpackage.AttachmentlogFile(pUid, lFiletypeKey.FileType, lFiletypeKey.Value, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	// update in onboading status table
	lErr = router.StatusInsert(pDebug, pUid, pSid, "IPV")
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "IPVReCaptureInsert (-)")
	return nil
}

// insert or update sign docid information
func UpdateSignImage(pDebug *helpers.HelperStruct, pUid, pSid, pSingId string) (lErr error) {
	pDebug.Log(helpers.Statement, "UpdateSignImage (+)")
	lQry := `IF EXISTS (SELECT 1 FROM ekyc_attachments WHERE Request_id = ?) THEN
    UPDATE ekyc_attachments
    SET Signature = ?, UpdatedSesion_Id = ?, UpdatedDate = UNIX_TIMESTAMP()
    WHERE Request_id = ?;
ELSE
    INSERT INTO ekyc_attachments(Request_id,Signature, Session_Id, UpdatedSesion_Id,CreatedDate, UpdatedDate)
VALUES(?,?,?,?, unix_timestamp() ,unix_timestamp() );
END IF;`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lQry, pUid, pSingId, pSid, pUid, pUid, pSingId, pSid, pSid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "UpdateSignImage (-)")
	return nil
}

func GetIPVStatus(w http.ResponseWriter, r *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetIPVStatus (+)")
	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "GET")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold("get", r.Method) {
		var lAdrsComRec IPVStatusStruct
		lAdrsComRec.Status = common.SuccessCode
		// get client UID
		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DGI01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DGI01", "Somthing is wrong please try again later"))
			return
		}
		lDebug.SetReference(lUid)

		// check where client will be test user or not
		lSessionId, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(r, lDebug, common.EKYCCookieName, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DGI03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DGI03", "Somthing is wrong please try again later"))
			return
		}
		// select ipv information
		lCorestring := `select nvl(ei.image_Doc_Id,""),nvl(ei.video_Doc_Id,""),nvl(ei.ipv_otp,""),nvl(ea.Signature,'')
		from ekyc_ipv ei,ekyc_attachments ea
		where  ei.Request_Uid = ea.Request_id
		and Request_Uid=?
		and ( ? or Updated_Session_Id  = ?) `

		lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid, lTestUserFlag, lSessionId)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DGI04", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DGI04", "Somthing is wrong please try again later"))
			return
		}
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lAdrsComRec.ImgDocID, &lAdrsComRec.VIdeoDocID, &lAdrsComRec.Code, &lAdrsComRec.SignatureId)
			lDebug.Log(helpers.Details, "lRows", lRows)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DGI05", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DGI05", "Somthing is wrong please try again later"))
				return
			}
		}

		lAdrsComeFrom, _, lErr := GetIPVType(lDebug, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DGI06", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DGI06", "Somthing is wrong please try again later"))
			return
		}
		lAdrsComRec.IsSignApplicable = "Y"
		lAdrsComRec.IsVideoApplicable = "Y"
		if strings.EqualFold(lAdrsComeFrom, "Digilocker") || strings.EqualFold(lAdrsComeFrom, "KRA") {
			lAdrsComRec.IsVideoApplicable = "N"
		}

		Wet_Sign_Flag := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Wet_Sign_Flag")
		if !strings.EqualFold(Wet_Sign_Flag, "Y") {
			lAdrsComRec.IsSignApplicable = "N"
			lAdrsComRec.SignatureId = ""
		}

		lDatas, lErr := json.Marshal(&lAdrsComRec)
		lDebug.Log(helpers.Details, "lDatas", string(lDatas))

		if lErr != nil {
			lDebug.Log(helpers.Elog, "DGI07", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DGI07", "Somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "string(lDatas)", string(lDatas))
		fmt.Fprint(w, string(lDatas))

		lDebug.Log(helpers.Statement, "GetIPVStatus (-)")

	}
}

// get content type of the given document name
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

// check the client ipv request status
func CheckIPVStatus(pDebug *helpers.HelperStruct, pRequID, pActionType string) (string, string, string, string, string, string, string, error) {
	pDebug.Log(helpers.Statement, "CheckIPVStatus (+)")

	var lIPVRequestID, lAccessToken, lEmailID, lReGenerateFlag, lIpvCompliteStatus, lExpiryFlag, lActionType string

	lCorestring := `select nvl(ipv_requestid,""), nvl(accessToken,""),(select nvl(Email,"") from ekyc_request where Uid = ?) as email,CASE WHEN  validity > DATE_ADD(now() , INTERVAL 10 MINUTE) THEN 'N' ELSE 'Y' END AS re_generate_flag, req_status,CASE WHEN expire_date > DATE_ADD(now() , INTERVAL 15 MINUTE) THEN 'N' ELSE 'Y' END AS ExpireFlag,nvl(Action_type ,"")
	from ekyc_ipv_request_status
	where Request_Uid=? and Action_type is null or Action_type=? order by id desc limit 1;`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequID, pRequID, pActionType)
	if lErr != nil {
		return "", "", "", "", "", "", "", helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lIPVRequestID, &lAccessToken, &lEmailID, &lReGenerateFlag, &lIpvCompliteStatus, &lExpiryFlag, &lActionType)
		if lErr != nil {
			return "", "", "", "", "", "", "", helpers.ErrReturn(lErr)

		}
	}
	pDebug.Log(helpers.Statement, "CheckIPVStatus (-)")

	return lIPVRequestID, lAccessToken, lEmailID, lReGenerateFlag, lIpvCompliteStatus, lExpiryFlag, lActionType, nil

}

// insert ipv digion sub action information
func InsertRecaptureDigioStatus(pDebug *helpers.HelperStruct, pIPVReqID, pAccessToken, pValiditiy, pUid, pSid, pRefID, pTXTID, pActionType string, pExpDate int) error {
	pDebug.Log(helpers.Statement, "InsertDigioStatus (+)")

	lInsertString := `
    	INSERT INTO ekyc_ipv_request_status
  (Request_Uid, Action_type, ipv_requestid, accessToken, validity, req_status, Session_Id, Updated_Session_Id, CreatedDate, UpdatedDate, expire_date, referID, TXTID)
VALUES
  (?,CASE WHEN ? = '' THEN NULL ELSE ? END, ?, ?, ?, ?, ?, ?, unix_timestamp(), unix_timestamp(), DATE_ADD(NOW(), INTERVAL ? DAY), ?, ?);
	`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lInsertString, pUid, pActionType, pActionType, pIPVReqID, pAccessToken, pValiditiy, "I", pSid, pSid, pExpDate, pRefID, pTXTID)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "InsertDigioStatus (-)")

	return nil

}
func InsertDigioStatus(pDebug *helpers.HelperStruct, pIPVReqID, pAccessToken, pValiditiy, pUid, pSid, pRefID, pTXTID string, pExpDate int) error {
	pDebug.Log(helpers.Statement, "InsertDigioStatus (+)")

	lInsertString := `
    	insert into ekyc_ipv_request_status(Request_Uid,ipv_requestid,accessToken,validity,req_status,Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate,expire_date,referID,TXTID)
    	values(?,?,?,?,?,?,?,unix_timestamp(),unix_timestamp(),date_add(now(),interval ? day),?,?);
	`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lInsertString, pUid, pIPVReqID, pAccessToken, pValiditiy, "I", pSid, pSid, pExpDate, pRefID, pTXTID)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "InsertDigioStatus (-)")

	return nil

}

// create a new request to digio
func GenerateNweRequest(pDebug *helpers.HelperStruct, lUid, lSid string) (lIpvRec IpvResponse, lErr error) {
	pDebug.Log(helpers.Statement, "GenerateNweRequest (+)")
	var lDataRec DataStruct
	var lvideoActionRec VideoActionStruct
	var lSignActionRec SignActionStruct
	var lActionArr []interface{}
	// var lApprovalRec ApprovalRuleStruct
	// var lApprovalArr []ApprovalRuleStruct
	var lSubAct, lSelfiSubArr []interface{}
	var lSubAcc1Rec SubAcc1
	var lSubAcc2Rec SubAcc2
	var lSelfiRec SelfiSubStruct
	var lSelfiAction SelfiActionStruct
	// get client basic info
	lID, lName, lEmail, lErr := BasicInfo(lUid, pDebug)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}
	lID = fmt.Sprintf("%s_%d", lID, ((time.Now()).Unix())*int64(time.Second/time.Millisecond))
	// get ipv request config information

	lIpvVideoLength := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "IpvVideoLength")
	lIpvExpiryDays := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "lIpvExpiryDays")

	lVideoLength, lErr := strconv.Atoi(lIpvVideoLength)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}

	lExpiryDays, lErr := strconv.Atoi(lIpvExpiryDays)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}
	lDataRec.CustomerID = lEmail
	lDataRec.CustomerName = lName
	lDataRec.RefID = "RF" + lID
	lDataRec.Notify = false
	lDataRec.GenerateAccToken = true
	lDataRec.TransactionID = "TX" + lID
	lDataRec.Exp = lExpiryDays

	//video
	lvideoActionRec.Type = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_Type")
	lvideoActionRec.Title = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_Title")
	lvideoActionRec.Description = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_Description")
	lvideoActionRec.Method = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_Method")
	lvideoActionRec.ValidationMode = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_ValidationMode")
	lvideoActionRec.FaceMatchObjType = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_FaceMatchObjType")
	lvideoActionRec.VideoLength = lVideoLength
	lvideoActionRec.ActionType = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_ActionType")

	lSubAcc1Rec.Type = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Location_Type")
	lSubAcc1Rec.Optional = false
	lSubAcc1Rec.IDAnalysisReq = false

	lSubAcc2Rec.Type = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "VideoSub_Type")
	lSubAcc2Rec.Title = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "VideoSub_Title")
	lSubAcc2Rec.Description = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "VideoSub_Description")
	lSubAcc2Rec.Optional = false

	// lApprovalRec.Property = "FACE_MATCH"
	// lApprovalRec.Value = "50"

	lvideoActionRec.Optional = false
	// selfie
	lSelfiRec.FaceMateSource = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "SelfieSub_FaceMateSource")
	lSelfiRec.Type = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Location_Type")
	lSelfiRec.Optional = false
	lSelfiRec.IDAnalysisReq = false

	lSelfiAction.Type = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Selfie_Type")
	lSelfiAction.Title = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Selfie_Title")
	lSelfiAction.Description = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Selfie_Description")
	lSelfiAction.ValidationMode = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Selfie_ValidationMode")
	lSelfiAction.FaceMatchObjType = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Selfie_FaceMatchObjType")
	lSelfiAction.ActionType = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Selfie_ActionType")
	//signature
	lSignActionRec.Type = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Sign_Type")
	lSignActionRec.Title = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Sign_Title")
	lSignActionRec.Description = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Sign_Description")
	lSignActionRec.ImageUploadStatus = true
	lSignActionRec.UploadMode = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Sign_UploadMode")
	lSignActionRec.ValidationType = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Sign_ValidationType")
	lSignActionRec.ActionType = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Sign_ActionType")

	lSubAct = append(lSubAct, lSubAcc1Rec)
	lSubAct = append(lSubAct, lSubAcc2Rec)
	lvideoActionRec.SubAcction = lSubAct
	// lApprovalArr = append(lApprovalArr, lApprovalRec)
	// lvideoActionRec.ApprovalRule = lApprovalArr
	lSelfiSubArr = append(lSelfiSubArr, lSelfiRec)
	// lSelfiAction.ApprovalRule = lApprovalArr
	lSelfiAction.SubAcction = lSelfiSubArr
	// get client source of adrs
	lAdrsComeFrom, _, lErr := GetIPVType(pDebug, lUid)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}
	lActionArr = append(lActionArr, lSelfiAction)
	// if lErr != nil {
	// 	return lIpvRec, helpers.ErrReturn(lErr)
	// }
	// check where source of adrs is Digilocker or not
	if !strings.EqualFold(lAdrsComeFrom, "Digilocker") && !strings.EqualFold(lAdrsComeFrom, "KRA") {
		//command for selfi
		lActionArr = append(lActionArr, lvideoActionRec)
		pDebug.Log(helpers.Details, "Adding video IPV Action Arr")
	}
	Wet_Sign_Flag := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Wet_Sign_Flag")
	if strings.EqualFold(Wet_Sign_Flag, "Y") {
		pDebug.Log(helpers.Details, "sign request Add")
		lActionArr = append(lActionArr, lSignActionRec)
	}
	lDataRec.Action = lActionArr

	lFinalData, lErr := json.Marshal(lDataRec)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "lFinalData\n\n\n", string(lFinalData), "\n\n")

	lValue, lErr := ipvapi.CreatURl(pDebug, string(lFinalData))

	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "lValue\n\n\n", string(lValue), "\n\n")

	lErr = json.Unmarshal([]byte(lValue), &lIpvRec)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "Json lFinalData :", string(lFinalData))

	pDebug.Log(helpers.Details, "resp :", lValue, common.IPVVerified)
	pDebug.Log(helpers.Details, "common.IPVVerified :", common.IPVVerified)

	lErr = InsertDigioStatus(pDebug, lIpvRec.ReqID, lIpvRec.AccessToken.ID, lIpvRec.AccessToken.ValidTill, lUid, lSid, lIpvRec.ReferenceID, lIpvRec.TransactionID, lIpvRec.ExpireInDays)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "GenerateNweRequest (-)")
	return lIpvRec, nil
}

func GenerateRecaptureRequest(pDebug *helpers.HelperStruct, lUid, lSid, pActionType string) (lIpvRec IpvResponse, lErr error) {
	pDebug.Log(helpers.Statement, "GenerateNweRequest (+)")
	var lDataRec DataStruct
	var lvideoActionRec VideoActionStruct
	var lSignActionRec SignActionStruct
	var lActionArr []interface{}
	// var lApprovalRec ApprovalRuleStruct
	// var lApprovalArr []ApprovalRuleStruct
	var lSubAct, lSelfiSubArr []interface{}
	var lSubAcc1Rec SubAcc1
	var lSubAcc2Rec SubAcc2
	var lSelfiRec SelfiSubStruct
	var lSelfiAction SelfiActionStruct
	// get client basic info
	lID, lName, lEmail, lErr := BasicInfo(lUid, pDebug)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}
	lID = fmt.Sprintf("%s_%d", lID, ((time.Now()).Unix())*int64(time.Second/time.Millisecond))
	// get ipv request config information

	lIpvVideoLength := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "IpvVideoLength")
	lIpvExpiryDays := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "lIpvExpiryDays")

	lVideoLength, lErr := strconv.Atoi(lIpvVideoLength)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}

	lExpiryDays, lErr := strconv.Atoi(lIpvExpiryDays)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}
	lDataRec.CustomerID = lEmail
	lDataRec.CustomerName = lName
	lDataRec.RefID = "RF" + lID
	lDataRec.Notify = false
	lDataRec.GenerateAccToken = true
	lDataRec.TransactionID = "TX" + lID
	lDataRec.Exp = lExpiryDays

	//video
	lvideoActionRec.Type = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_Type")
	lvideoActionRec.Title = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_Title")
	lvideoActionRec.Description = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_Description")
	lvideoActionRec.Method = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_Method")
	lvideoActionRec.ValidationMode = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_ValidationMode")
	lvideoActionRec.FaceMatchObjType = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_FaceMatchObjType")
	lvideoActionRec.VideoLength = lVideoLength
	lvideoActionRec.ActionType = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Video_ActionType")

	lSubAcc1Rec.Type = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Location_Type")
	lSubAcc1Rec.Optional = false
	lSubAcc1Rec.IDAnalysisReq = false

	lSubAcc2Rec.Type = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "VideoSub_Type")
	lSubAcc2Rec.Title = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "VideoSub_Title")
	lSubAcc2Rec.Description = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "VideoSub_Description")
	lSubAcc2Rec.Optional = false

	// lApprovalRec.Property = "FACE_MATCH"
	// lApprovalRec.Value = "50"

	lvideoActionRec.Optional = false
	// selfie
	lSelfiRec.FaceMateSource = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "SelfieSub_FaceMateSource")
	lSelfiRec.Type = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Location_Type")
	lSelfiRec.Optional = false
	lSelfiRec.IDAnalysisReq = false

	lSelfiAction.Type = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Selfie_Type")
	lSelfiAction.Title = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Selfie_Title")
	lSelfiAction.Description = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Selfie_Description")
	lSelfiAction.ValidationMode = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Selfie_ValidationMode")
	lSelfiAction.FaceMatchObjType = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Selfie_FaceMatchObjType")
	lSelfiAction.ActionType = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Selfie_ActionType")
	//signature
	lSignActionRec.Type = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Sign_Type")
	lSignActionRec.Title = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Sign_Title")
	lSignActionRec.Description = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Sign_Description")
	lSignActionRec.ImageUploadStatus = true
	lSignActionRec.UploadMode = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Sign_UploadMode")
	lSignActionRec.ValidationType = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Sign_ValidationType")
	lSignActionRec.ActionType = tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Sign_ActionType")

	lSubAct = append(lSubAct, lSubAcc1Rec)
	lSubAct = append(lSubAct, lSubAcc2Rec)
	lvideoActionRec.SubAcction = lSubAct
	// lApprovalArr = append(lApprovalArr, lApprovalRec)
	// lvideoActionRec.ApprovalRule = lApprovalArr
	lSelfiSubArr = append(lSelfiSubArr, lSelfiRec)
	// lSelfiAction.ApprovalRule = lApprovalArr
	lSelfiAction.SubAcction = lSelfiSubArr
	// get client source of adrs
	lAdrsComeFrom, _, lErr := GetIPVType(pDebug, lUid)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}
	// lActionArr = append(lActionArr, lSelfiAction)
	// // check where source of adrs is Digilocker or not
	// if !strings.EqualFold(lAdrsComeFrom, "Digilocker") {
	// 	//command for selfi
	// 	lActionArr = append(lActionArr, lvideoActionRec)
	// 	pDebug.Log(helpers.Details, "Adding video IPV Action Arr")
	// }
	if pActionType == "digi_selfie" {
		lActionArr = append(lActionArr, lSelfiAction)
	} else if pActionType == "digi_video" {
		lActionArr = append(lActionArr, lvideoActionRec)
	} else {
		lActionArr = append(lActionArr, lSelfiAction)
		// check where source of adrs is Digilocker or not
		if !strings.EqualFold(lAdrsComeFrom, "Digilocker") && !strings.EqualFold(lAdrsComeFrom, "KRA") {
			//command for selfi
			lActionArr = append(lActionArr, lvideoActionRec)
			pDebug.Log(helpers.Details, "Adding video IPV Action Arr")
		}
	}
	Wet_Sign_Flag := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Wet_Sign_Flag")
	if strings.EqualFold(Wet_Sign_Flag, "Y") {
		pDebug.Log(helpers.Details, "sign request Add")
		lActionArr = append(lActionArr, lSignActionRec)
	}
	if (len(lActionArr) > 1 && Wet_Sign_Flag == "N") || (len(lActionArr) > 2 && Wet_Sign_Flag == "Y") {
		pActionType = ""
	}
	lDataRec.Action = lActionArr

	lFinalData, lErr := json.Marshal(lDataRec)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "lFinalData\n\n\n", string(lFinalData), "\n\n")

	lValue, lErr := ipvapi.CreatURl(pDebug, string(lFinalData))

	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "lValue\n\n\n", string(lValue), "\n\n")

	lErr = json.Unmarshal([]byte(lValue), &lIpvRec)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "Json lFinalData :", string(lFinalData))

	pDebug.Log(helpers.Details, "resp :", lValue, common.IPVVerified)
	pDebug.Log(helpers.Details, "common.IPVVerified :", common.IPVVerified)

	lErr = InsertRecaptureDigioStatus(pDebug, lIpvRec.ReqID, lIpvRec.AccessToken.ID, lIpvRec.AccessToken.ValidTill, lUid, lSid, lIpvRec.ReferenceID, lIpvRec.TransactionID, pActionType, lIpvRec.ExpireInDays)
	if lErr != nil {
		return lIpvRec, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "GenerateNweRequest (-)")
	return lIpvRec, nil
}

func GetActionRequ(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "GET")
	w.Header().Set("Access-Control-Allow-Headers", "ActionType,Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold(r.Method, "GET") {
		lDebug := new(helpers.HelperStruct)
		lDebug.SetUid(r)
		lDebug.Log(helpers.Statement, "GetActionRequ (+)")
		var lIpvRec IpvResponse
		var lFetchActionType string
		lActionType := r.Header.Get("ActionType")

		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GAR01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GAR01", "Somthing is wrong please try again later"))
			return
		}
		lDebug.SetReference(lUid)
		if strings.EqualFold("", lActionType) {
			lDebug.Log(helpers.Elog, "GAR02", "Action type is empty")
			fmt.Fprint(w, helpers.GetError_String("GAR02", "Somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "lActionType :", lActionType)

		lIpvRec.ReqID, lIpvRec.AccessToken.ID, lIpvRec.CustomerIdentifier, lIpvRec.RegenerateFlag, lIpvRec.IPVCompliteStatus, lIpvRec.ExpireFlag, lFetchActionType, lErr = CheckIPVStatus(lDebug, lUid, lActionType)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GAR03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GAR03", "Somthing is wrong please try again later"))
			return
		}
		// if strings.EqualFold(lIpvRec.RegenerateFlag, "Y") {
		// 	lIpvRec.AccessToken.ID, lErr = ReGenerateToken(lDebug, lUid, lSid, lIpvRec.ReqID)
		// 	if lErr != nil {
		// 		lDebug.Log(helpers.Elog, "GAR04", lErr.Error())
		// 		fmt.Fprint(w, helpers.GetError_String("GAR04", "Somthing is wrong please try again later"))
		// 		return
		// 	}
		// }
		if strings.EqualFold(lIpvRec.ExpireFlag, "Y") || strings.EqualFold(lIpvRec.ExpireFlag, "") {
			lIpvRec, lErr = GenerateRecaptureRequest(lDebug, lUid, lSid, lActionType)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "GAR05", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("GAR05", "Somthing is wrong please try again later"))
				return
			}
		} else {
			lActionId, lRecreateFlag, lErr := GetSubActionInfo(lDebug, lUid, lIpvRec.ReqID, lActionType)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "GAR06", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("GAR06", "Somthing is wrong please try again later"))
				return
			}
			lDebug.Log(helpers.Details, "lActionID", lActionId)
			lDebug.Log(helpers.Details, "lRecreateFlag", lRecreateFlag)
			lDebug.Log(helpers.Details, "RegenreateFlag", lIpvRec.RegenerateFlag)

			if strings.EqualFold(lActionId, "") {
				lIpvRec, lErr = GenerateRecaptureRequest(lDebug, lUid, lSid, lActionType)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "GAR05", lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("GAR05", "Somthing is wrong please try again later"))
					return
				}

			} else if strings.EqualFold(lRecreateFlag, "Y") {
				lErr = ReCreateSubAction(lDebug, lUid, lSid, lIpvRec.ReqID, lActionType, lActionId)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "GAR07", lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("GAR07", "Somthing is wrong please try again later"))
					return
				}
			}
			if strings.EqualFold(lIpvRec.RegenerateFlag, "Y") {
				lDebug.Log(helpers.Details, "current token :", lIpvRec.AccessToken.ID)
				lIpvRec.AccessToken.ID, lErr = ReGenerateToken(lDebug, lUid, lSid, lIpvRec.ReqID, lActionType)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "GAR08", lErr.Error())
					// fmt.Fprint(w, helpers.GetError_String("GAR08", "Somthing is wrong please try again later"))
					// return
					lIpvRec, lErr = GenerateRecaptureRequest(lDebug, lUid, lSid, lActionType)
					if lErr != nil {
						lDebug.Log(helpers.Elog, "GAR08", lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("GAR08", "Somthing is wrong please try again later"))
						return
					}
				}
				lDebug.Log(helpers.Details, "modify token :", lIpvRec.AccessToken.ID)
			} else {
				if !strings.EqualFold(lFetchActionType, lActionType) {
					lIpvRec, lErr = GenerateRecaptureRequest(lDebug, lUid, lSid, lActionType)
					if lErr != nil {
						lDebug.Log(helpers.Elog, "GAR05", lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("GAR05", "Somthing is wrong please try again later"))
						return
					}
				}
				lErr := UpdateActionTypeToken(lDebug, lUid, lSid, lIpvRec.ReqID, lActionType, lFetchActionType)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "GAR09", lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("GAR09", "Somthing is wrong please try again later"))
					return
				}
			}
		}
		lErr = sessionid.UpdateZohoCrmDeals(lDebug, r, common.IPVVerified)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GAR010", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GAR010", "Somthing is wrong please try again later"))
			return
		}
		lIpvRec.Status = common.SuccessCode
		lDigiioId, lErr := json.Marshal(lIpvRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GAR011", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GAR011", "Somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "Json lDigiioId :", string(lDigiioId))
		fmt.Fprint(w, string(lDigiioId))

		lDebug.Log(helpers.Statement, "GetActionRequ (-)")

	}
}

func GetActionInfo(pDebug *helpers.HelperStruct, pUid, pRefID string) (lActionInfo map[string]string, lErr error) {
	pDebug.Log(helpers.Statement, "GetActionInfo (+)")
	lActionInfo = make(map[string]string)

	var lActionType, lActionID string

	lQry := `SELECT nvl(edrs1.action_type,'') ,nvl(edrs1.file_id,'') 
FROM ekyc_ipv_sub_request edrs1,(
    SELECT  MAX(id) as max_id,action_type
    FROM ekyc_ipv_sub_request
    WHERE Request_Uid = ? 
    AND ipv_requestid = ?
    GROUP BY action_type
) eds
where edrs1.id=eds.max_id and edrs1.action_status not in('Recapture')`

	lRowInfo, lErr := ftdb.NewEkyc_GDB.Query(lQry, pUid, pRefID)

	if lErr != nil {
		return lActionInfo, helpers.ErrReturn(lErr)
	}
	defer lRowInfo.Close()
	for lRowInfo.Next() {
		lErr = lRowInfo.Scan(&lActionType, &lActionID)
		if lErr != nil {
			return lActionInfo, helpers.ErrReturn(lErr)
		}
		lActionInfo[lActionType] = lActionID
	}

	pDebug.Log(helpers.Statement, "GetActionInfo (-)")
	return lActionInfo, nil
}
