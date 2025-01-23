package ipv

import (
	"encoding/json"
	"fcs23pkg/apps/v1/commonpackage"
	"fcs23pkg/apps/v1/router"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/ipvapi"
	"fcs23pkg/integration/v1/pdfgenerate"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

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

type ActionStruct struct {
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
}

type SelfiActionStruct struct {
	Type             string               `json:"type"`
	Title            string               `json:"title"`
	Description      string               `json:"description"`
	ValidationMode   string               `json:"validation_mode"`
	FaceMatchObjType string               `json:"face_match_obj_type"`
	SubAcction       interface{}          `json:"sub_actions"`
	ApprovalRule     []ApprovalRuleStruct `json:"approval_rule"`
	Optional         bool                 `json:"optional"`
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
	AutoApproved bool `json:"auto_approved"`
}
type IPVStatusStruct struct {
	Status     string `json:"status"`
	Code       string `json:"code"`
	ImgDocID   string `json:"imgid"`
	VIdeoDocID string `json:"videoid"`
}

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
		var lDataRec DataStruct
		var lActionRec ActionStruct
		var lActionArr []interface{}
		var lApprovalRec ApprovalRuleStruct
		var lApprovalArr []ApprovalRuleStruct
		var lSubAct, lSelfiSubArr []interface{}
		var lSubAcc1Rec SubAcc1
		var lSubAcc2Rec SubAcc2
		var lIpvRec IpvResponse
		var lSelfiRec SelfiSubStruct
		var lSelfiAction SelfiActionStruct

		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DDI01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DDI01", "Somthing is wrong please try again later"))
			return
		}
		lDebug.SetReference(lUid)
		lIpvRec.ReqID, lIpvRec.AccessToken.ID, lIpvRec.CustomerIdentifier, lErr = CheckIPVStatus(lDebug, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DDI02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DDI02", "Somthing is wrong please try again later"))
			return
		}
		if strings.EqualFold(lIpvRec.ReqID, "") {

			lID, lName, lEmail, lErr := BasicInfo(lUid, lDebug)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DDI03", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DDI03", "Somthing is wrong please try again later"))
				return
			}
			lID = fmt.Sprintf("%s_%d", lID, ((time.Now()).Unix())*int64(time.Second/time.Millisecond))

			lIpvVideoLength := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "IpvVideoLength")
			lIpvExpiryDays := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "lIpvExpiryDays")

			lVideoLength, lErr := strconv.Atoi(lIpvVideoLength)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DDI04", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DDI03", "Somthing is wrong please try again later"))
				return
			}

			lExpiryDays, lErr := strconv.Atoi(lIpvExpiryDays)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DDI05", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DDI03", "Somthing is wrong please try again later"))
				return
			}
			lDataRec.CustomerID = lEmail
			lDataRec.CustomerName = lName
			lDataRec.RefID = "RF" + lID
			lDataRec.Notify = false
			lDataRec.GenerateAccToken = true
			lDataRec.TransactionID = "TX" + lID
			lDataRec.Exp = lExpiryDays

			lActionRec.Type = "video"
			lActionRec.Title = "Video KYC"
			// lActionRec.Description = "Please do Video KYC"
			// lActionRec.Method = "otp_text"
			lActionRec.Description = "Please do Video KYC and read OTP"
			lActionRec.Method = "otp_audio"
			lActionRec.ValidationMode = "OTP_STRICT"
			lActionRec.FaceMatchObjType = "match_required"
			lActionRec.VideoLength = lVideoLength

			lSubAcc1Rec.Type = "GEO_TAGGING"
			lSubAcc1Rec.Optional = false
			lSubAcc1Rec.IDAnalysisReq = false

			lSubAcc2Rec.Type = "ASSISTANCE_INSTRUCTION"
			lSubAcc2Rec.Title = "Video Instruction"
			lSubAcc2Rec.Description = "Please capture your clear and complete face"
			lSubAcc2Rec.Optional = false

			lApprovalRec.Property = "FACE_MATCH"
			lApprovalRec.Value = "50"

			lActionRec.Optional = false
			// selfie
			lSelfiRec.FaceMateSource = "source"
			lSelfiRec.Type = "GEO_TAGGING"
			lSelfiRec.Optional = true
			lSelfiRec.IDAnalysisReq = false

			lSelfiAction.Type = "selfie"
			lSelfiAction.Title = "SELFIE KYC"
			lSelfiAction.Description = "Please take a SELFIE to authenticate"
			lSelfiAction.ValidationMode = "LIVENESS_CHECK"
			lSelfiAction.FaceMatchObjType = "SOURCE"

			lSubAct = append(lSubAct, lSubAcc1Rec)
			lSubAct = append(lSubAct, lSubAcc2Rec)
			lActionRec.SubAcction = lSubAct
			lApprovalArr = append(lApprovalArr, lApprovalRec)
			lActionRec.ApprovalRule = lApprovalArr
			lSelfiSubArr = append(lSelfiSubArr, lSelfiRec)
			lSelfiAction.ApprovalRule = lApprovalArr
			lSelfiAction.SubAcction = lSelfiSubArr

			lAdrsComeFrom, lErr := GetIPVType(lDebug, lUid)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DDI04", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DDI04", "Somthing is wrong please try again later"))
				return
			}
			lActionArr = append(lActionArr, lSelfiAction)
			if !strings.EqualFold(lAdrsComeFrom, "Digilocker") {
				//command for selfi
				lActionArr = append(lActionArr, lActionRec)
			}
			lDataRec.Action = lActionArr

			lFinalData, lErr := json.Marshal(lDataRec)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DDI05", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DDI05", "Somthing is wrong please try again later"))
				return
			}

			lValue, lErr := ipvapi.CreatURl(lDebug, string(lFinalData))

			if lErr != nil {
				lDebug.Log(helpers.Elog, "DDI06", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DDI06", "Somthing is wrong please try again later"))
				return
			}

			lErr = json.Unmarshal([]byte(lValue), &lIpvRec)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DDI07", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DDI07", "Somthing is wrong please try again later"))
				return
			}
			lDebug.Log(helpers.Details, "Json lFinalData :", string(lFinalData))

			lDebug.Log(helpers.Details, "resp :", lValue, common.IPVVerified)
			lDebug.Log(helpers.Details, "common.IPVVerified :", common.IPVVerified)

			lErr = sessionid.UpdateZohoCrmDeals(lDebug, r, common.IPVVerified)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DDI08", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DDI08", "Somthing is wrong please try again later"))
				return
			}
			lErr = InsertDigioStatus(lDebug, lIpvRec.ReqID, lIpvRec.AccessToken.ID, lIpvRec.AccessToken.ValidTill, lUid, lSid)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DDI09", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DDI09", "Somthing is wrong please try again later"))
				return
			}
		}
		lIpvRec.Status = common.SuccessCode
		lDigiioId, lErr := json.Marshal(lIpvRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DDI09", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DDI09", "Somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "Json lDigiioId :", string(lDigiioId))
		fmt.Fprint(w, string(lDigiioId))

		lDebug.Log(helpers.Statement, "DigiID (-)")

	}
}

func GetIPVType(lDebug *helpers.HelperStruct, lUid string) (lAdrsComeFrom string, lErr error) {
	lDebug.Log(helpers.Statement, "GetIPVType (+)")

	lCorestring := `
		select ea.Source_Of_Address
		from ekyc_address ea
		where ea.Request_Uid =?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lAdrsComeFrom)
		lDebug.Log(helpers.Details, "lRows", lRows)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
	}

	lDebug.Log(helpers.Statement, "GetIPVType (-)")
	return lAdrsComeFrom, nil
}

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

type data struct {
	ID      string `json:"digio_doc_id"`
	Message string `json:"message"`
	TxnId   string `json:"txn_id"`
}

func SaveFile(w http.ResponseWriter, r *http.Request) {

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "ipvurl,Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold(r.Method, "post") {
		lDebug := new(helpers.HelperStruct)
		lDebug.SetUid(r)
		// lDebug.SetUid(r)
		lDebug.Log(helpers.Statement, "SaveFile (+)")

		var lDataint data
		lURL := r.Header.Get("ipvurl")
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
		lDebug.Log(helpers.Details, "lBody", lBody)
		lErr = json.Unmarshal(lBody, &lDataint)

		// cheack where response will not Error
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF02", "Somthing is wrong please try again later"))
			return
		}

		lDigiFileInfo, lErr := ipvapi.GetFileData(lDebug, lDataint.ID)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF03", "Somthing is wrong please try again later"))
			return
		}
		lFinalArr, lErr := ipvapi.DigioFileDownload(lDebug, lDigiFileInfo)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF03", "Somthing is wrong please try again later"))
			return
		}
		// lData, lErr := json.Marshal(&lFinalArr)
		// if lErr != nil {
		// 	lDebug.Log(helpers.Elog, "DSF04", lErr.Error())
		// 	fmt.Fprint(w, helpers.GetError_String("DSF04", "Somthing is wrong please try again later"))
		// 	return
		// }
		lFileInfo, lErr := pdfgenerate.Savefile(lDebug, lFinalArr)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF05", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF05", "Somthing is wrong please try again later"))
			return
		}

		lErr = IPVInsert(lDebug, r, lFileInfo, lDigiFileInfo, lCurrentAddressRec, lURL)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSF06", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DSF06", "Somthing is wrong please try again later"))
			return
		}

		lDebug.Log(helpers.Details, "lIPVInfo :", lDigiFileInfo)

		fmt.Fprint(w, helpers.GetMsg_String("DSF0", "SUCCESS"))
		lDebug.Log(helpers.Statement, "SaveFile (-)")

	}
}

func IPVInsert(pDebug *helpers.HelperStruct, r *http.Request, pDocinfo pdfgenerate.ImageRespStruct, pIPVData ipvapi.FileInfostruct, plocationStruct LocationStruct, pUrl string) error {
	pDebug.Log(helpers.Statement, "IPVInsert (+)")

	var lFiletypeRec KeyPairStruct
	var lFiletypeArr []KeyPairStruct

	lFileDocID := pDocinfo.FileDocID

	lSid, lUid, lErr := sessionid.GetOldSessionUID(r, pDebug, common.EKYCCookieName)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	var lVideoID, lImgID, lOTP, lLatitude, lLongitude, lTimeStamp string
	// lDocInfo, lErr := InsertIntoAttachments(lFileDB, lFileDocID, "DIG-IO")
	for _, lFileInfo := range lFileDocID {
		if strings.EqualFold(lFileInfo.FileKey, "Video") {
			lVideoID = lFileInfo.DocID
			lFiletypeRec.FileType = "IPV Video"
			lFiletypeRec.Value = lVideoID
			lFiletypeArr = append(lFiletypeArr, lFiletypeRec)
		} else {
			lImgID = lFileInfo.DocID
			lFiletypeRec.FileType = "IPV Image"
			lFiletypeRec.Value = lImgID
			lFiletypeArr = append(lFiletypeArr, lFiletypeRec)
		}
	}

	for _, lIPVInfo := range pIPVData.Actions {
		if !strings.EqualFold(lIPVInfo.Type, "video") {
			lLatitude = fmt.Sprintf("%v", lIPVInfo.SubActions[0].Details.Latitude)
			lLongitude = fmt.Sprintf("%v", lIPVInfo.SubActions[0].Details.Longitude)
			lTimeStamp = lIPVInfo.CompletedAt
		} else {
			lOTP = lIPVInfo.OTP
		}

	}
	lCurrentAddress, lErr := ipvapi.GetGeoAddress(lLatitude, lLongitude, pDebug)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal([]byte(lCurrentAddress), &plocationStruct)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lUpdateString := `
    	update ekyc_ipv_request_status set req_status= 'S' ,Updated_Session_Id=?,UpdatedDate=unix_timestamp()
		where Request_Uid=? and ipv_requestid=?;
	`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lUpdateString, lSid, lUid, pIPVData.ID)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

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

	_, lErr = ftdb.NewEkyc_GDB.Exec(lInsertString, lUid, lOTP, lVideoID, lImgID, lLatitude, lLongitude, lTimeStamp, plocationStruct.City, lSid, lUid, lUid, lOTP, lVideoID, lImgID, lLatitude, lLongitude, lTimeStamp, plocationStruct.City, lSid, lSid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	lErr = UpdateIPVComplit(pDebug, lSid, lUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	for _, lFiletypeKey := range lFiletypeArr {
		lErr = commonpackage.AttachmentlogFile(lUid, lFiletypeKey.FileType, lFiletypeKey.Value, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	lErr = router.StatusInsert(pDebug, lUid, lSid, "IPV")
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	// if strings.Contains(strings.ToLower(pUrl), strings.ToLower("ipv_id")) {

	// 	lUrlInfo, lErr := url.Parse(pUrl)
	// 	if lErr != nil {
	// 		return helpers.ErrReturn(lErr)
	// 	}
	// 	lQuery := lUrlInfo.Query()
	// 	lID := lQuery.Get("ipv_id")

	// 	lErr = UpdateIPVLinkUse(pDebug, lDb, lSid, lID)
	// 	if lErr != nil {
	// 		return helpers.ErrReturn(lErr)
	// 	}

	// }

	pDebug.Log(helpers.Statement, "IPVInsert (-)")
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
		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DGI01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DGI01", "Somthing is wrong please try again later"))
			return
		}
		lDebug.SetReference(lUid)

		lSessionId, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(r, lDebug, common.EKYCCookieName, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DGI03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DGI03", "Somthing is wrong please try again later"))
			return
		}

		lCorestring := `select nvl(image_Doc_Id,""),nvl(video_Doc_Id,""),nvl(ipv_otp,"")
		from ekyc_ipv 
		where Request_Uid=? 
		and ( ? or Updated_Session_Id  = ?) `

		lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid, lTestUserFlag, lSessionId)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DGI04", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DGI04", "Somthing is wrong please try again later"))
			return
		}
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lAdrsComRec.ImgDocID, &lAdrsComRec.VIdeoDocID, &lAdrsComRec.Code)
			lDebug.Log(helpers.Details, "lRows", lRows)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "DGI05", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("DGI05", "Somthing is wrong please try again later"))
				return
			}
		}

		lDatas, lErr := json.Marshal(&lAdrsComRec)
		lDebug.Log(helpers.Details, "lDatas", string(lDatas))

		if lErr != nil {
			lDebug.Log(helpers.Elog, "DGI06", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DGI06", "Somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "string(lDatas)", string(lDatas))
		fmt.Fprint(w, string(lDatas))

		lDebug.Log(helpers.Statement, "GetIPVStatus (-)")

	}
}

// func InsertIntoAttachments(db *sql.DB, InputData []file.FileDataType, clientId string) ([]file.FileDataType, error) {
// 	log.Println("insertIntoAttachments+")

// 	insertedID := ""

// 	for i := 0; i < len(InputData); i++ {

// 		coreString := `insert into document_attachment_details(FileType,FileName,FilePath,CreatedDate,CreatedBy,UpdatedDate,UpdatedBy)
// 					   values(?,?,?,Now(),?,Now(),?)`
// 		insertRes, err := db.Exec(coreString, GetFileType(InputData[i].ActualfileName), InputData[i].ActualfileName, InputData[i].FullFilePath, clientId, clientId)
// 		if err != nil {
// 			common.LogError("file.InsertIntoAttachments", "(FIIA01)", err.Error())
// 			// return insertedID, err
// 			return InputData, err
// 		} else {
// 			returnId, _ := insertRes.LastInsertId()
// 			insertedID = strconv.FormatInt(returnId, 10)
// 			InputData[i].DocId = insertedID

// 			log.Println("inserted successfully")

// 		}
// 	}
// 	log.Println("InputData in FileDML.go Line 43", InputData)
// 	log.Println("insertIntoAttachments-")

// 	return InputData, nil
// }

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

func CheckIPVStatus(pDebug *helpers.HelperStruct, pRequID string) (string, string, string, error) {
	pDebug.Log(helpers.Statement, "CheckIPVStatus (+)")

	var lIPVRequestID, lAccessToken, lEmailID string

	lCorestring := `select nvl(ipv_requestid,""), nvl(accessToken,""),(select nvl(Email,"") from ekyc_request where Uid = ?) as email 
	from ekyc_ipv_request_status
	where req_status= 'E' and validity < date_add(validity,interval 15 minute) and Request_Uid=? `
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequID, pRequID)
	if lErr != nil {
		return "", "", "", helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lIPVRequestID, &lAccessToken, &lEmailID)
		if lErr != nil {
			return "", "", "", helpers.ErrReturn(lErr)

		}
	}
	pDebug.Log(helpers.Statement, "CheckIPVStatus (-)")

	return lIPVRequestID, lAccessToken, lEmailID, nil

}

func InsertDigioStatus(pDebug *helpers.HelperStruct, pIPVReqID, pAccessToken, pValiditiy, pUid, pSid string) error {
	pDebug.Log(helpers.Statement, "InsertDigioStatus (+)")

	lInsertString := `
    	insert into ekyc_ipv_request_status(Request_Uid,ipv_requestid,accessToken,validity,req_status,Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate)
    	values(?,?,?,?,?,?,?,unix_timestamp(),unix_timestamp());
	`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lInsertString, pUid, pIPVReqID, pAccessToken, pValiditiy, "E", pSid, pSid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "InsertDigioStatus (-)")

	return nil

}
