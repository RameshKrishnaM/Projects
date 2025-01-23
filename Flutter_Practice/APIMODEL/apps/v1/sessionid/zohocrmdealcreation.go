package sessionid

import (
	"fcs23pkg/apps/v1/commonpackage"
	"fcs23pkg/appsession"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/zohointegration"
	"fcs23pkg/tomlconfig"
	"net/http"
	"strings"
)

/* =====================================
     create deal in crm and set utm info cookiee
===================================== */

func InsertZohoCrmDeal(pReq *http.Request, pRespWriter http.ResponseWriter, lZohoInsRec *zohointegration.ZohoCrmDealInsertStruct, pDebug *helpers.HelperStruct, pUid, pSessionId string) error {
	pDebug.Log(helpers.Statement, "InsertZohoCrmDeal (+)")

	SetCrmStages()

	lCrmDealReq := SetUtmCookie(pDebug, pReq, pRespWriter, lZohoInsRec)

	// update stage
	lZohoInsRec.Stage = common.MobileVerified
	lCrmDealReq.Stage = common.MobileVerified
	//
	lErr := GetClientDetails(pDebug, pUid, lZohoInsRec, &lCrmDealReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIIZCD02 ", lErr)
		return helpers.ErrReturn(lErr)
	}

	lErr = NewExistingDeal(pDebug, pUid, lZohoInsRec, &lCrmDealReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIIZCD03 ", lErr)
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "lZohoRec --- ", lZohoInsRec)

	if !strings.EqualFold(common.CRMDeal, "prod") {
		ClientName := lZohoInsRec.Clientname
		lZohoInsRec.Clientname = "TEST_DATA_" + ClientName
		lCrmDealReq.Clientname = "TEST_DATA_" + ClientName
	}

	lAppMode := pReq.Header.Get("App_mode")
	lUserAgent := pReq.Header.Get("User-Agent")
	lDeviceInfo := GetDeviceType(lAppMode, lUserAgent)

	lCrmDealReq.AppName = common.AppName
	lCrmDealReq.AppType = lDeviceInfo

	lErr = InsertZohoCrmDeals(pDebug, pUid, pSessionId, lDeviceInfo, lZohoInsRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIIZCD04 ", lErr)
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "common.CRMDeal --- ", common.CRMDeal)

	lErr = zohointegration.ZohoCrmDealUpdate(pDebug, &lCrmDealReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIIZCD05 ", lErr)
		return helpers.ErrReturn(lErr)

	}
	pDebug.Log(helpers.Statement, "InsertZohoCrmDeal (-)")
	return nil
}

/* =====================================
     Stage update without utm information for below listed status in Onboarding app
      > PHONE_VERIFIED
      > PAN_VERFIFIED
      > ADDRESS_CAPTURED
      > BANK_CAPTURED
      > SEGMENT_SELECTED
      > DOCUMENT_UPLOADED
      > IPV_COMPLETED
      > VALIDATION_INPROGRESS
===================================== */

func UpdateZohoCrmDeals(pDebug *helpers.HelperStruct, pReq *http.Request, pStage string) error {
	pDebug.Log(helpers.Statement, "UpdateZohoCrmDeals (+)")
	var lCrmDealReq zohointegration.ZohoCrmDealStruct
	var lZohoInsRec zohointegration.ZohoCrmDealInsertStruct

	SetCrmStages()

	pDebug.Log(helpers.Details, "pStage --- ", pStage)
	lCrmDealReq.Stage = pStage
	lZohoInsRec.Stage = pStage

	_, lUid, lErr := GetOldSessionUID(pReq, pDebug, common.EKYCCookieName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIUZCD01 ", lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "lUid --- ", lUid)

	lErr = GetClientDetails(pDebug, lUid, &lZohoInsRec, &lCrmDealReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIUZCD03 ", lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	lSessionId := GetUtmCookie(pDebug, pReq, &lZohoInsRec, &lCrmDealReq)

	lErr = NewExistingDeal(pDebug, lUid, &lZohoInsRec, &lCrmDealReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIUZCD04 ", lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "lZohoRec --- ", lCrmDealReq)

	if !strings.EqualFold(common.CRMDeal, "prod") {
		ClientName := lCrmDealReq.Clientname
		lCrmDealReq.Clientname = "TEST_DATA_" + ClientName
		lZohoInsRec.Clientname = "TEST_DATA_" + ClientName
	}

	lAppMode := pReq.Header.Get("App_mode")
	lUserAgent := pReq.Header.Get("User-Agent")
	lDeviceInfo := GetDeviceType(lAppMode, lUserAgent)

	lCrmDealReq.AppName = common.AppName
	lCrmDealReq.AppType = lDeviceInfo

	lErr = InsertZohoCrmDeals(pDebug, lUid, lSessionId, lDeviceInfo, &lZohoInsRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIUZCD05 ", lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	lErr = zohointegration.ZohoCrmDealUpdate(pDebug, &lCrmDealReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIUZCD06 ", lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "UpdateZohoCrmDeals (-)")
	return nil
}

// Get Device Type
func GetDeviceType(pAppMode, pUserAgent string) string {
	pUserAgent = strings.ToLower(pUserAgent)
	lDevicetype := "Web"

	if strings.Contains(pUserAgent, "android") {
		lDevicetype = "Android"
	} else if strings.Contains(pUserAgent, "iphone") || strings.Contains(pUserAgent, "ipad") || strings.Contains(pUserAgent, "ios") {
		lDevicetype = "iOS"
	}

	if strings.EqualFold(pAppMode, "web") {
		return pAppMode
	} else if strings.EqualFold(pAppMode, "app") {
		return pAppMode + "( " + lDevicetype + " )"
	}
	return ""
}

/* =====================================
     Stage update without utm information for below listed status in flow app
     > VALIDATION_REJECTED
     > COMPLETED
===================================== */

func UpdateZohoCrmDealsStatus_flow(pDebug *helpers.HelperStruct, pReqId, pStage string) error {
	pDebug.Log(helpers.Statement, "UpdateZohoCrmDealsStatus (+)")
	var lZohoRec zohointegration.ZohoCrmDealInsertStruct
	var lCrmDealReq zohointegration.ZohoCrmDealStruct
	SetCrmStages()

	lZohoRec.Stage = pStage
	lCrmDealReq.Stage = pStage

	pDebug.Log(helpers.Details, "pStage --- ", pStage)

	lUid, lErr := commonpackage.GetRid(pReqId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIUZCDSF02 ", lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "lUid --- ", lUid)

	lErr = NewExistingDeal(pDebug, lUid, &lZohoRec, &lCrmDealReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIUZCDSF03 ", lErr)
		return helpers.ErrReturn(lErr)
	}
	lErr = GetClientDetails(pDebug, lUid, &lZohoRec, &lCrmDealReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIUZCDSF04 ", lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "lZohoRec --- ", lZohoRec)
	lAppMode := "Flow APP"

	lCrmDealReq.AppName = common.AppName
	lCrmDealReq.AppType = lAppMode

	lErr = InsertZohoCrmDeals(pDebug, lUid, common.AppName, lAppMode, &lZohoRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIUZCDSF05 ", lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "common.CRMDeal --- ", common.CRMDeal)

	if !strings.EqualFold(common.CRMDeal, "prod") {
		ClientName := lZohoRec.Clientname
		lZohoRec.Clientname = "TEST_DATA_" + ClientName
		lCrmDealReq.Clientname = "TEST_DATA_" + ClientName
	}
	lErr = zohointegration.ZohoCrmDealUpdate(pDebug, &lCrmDealReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIUZCDSF06 ", lErr.Error())
		return helpers.ErrReturn(lErr)

	}
	pDebug.Log(helpers.Statement, "UpdateZohoCrmDealsStatus (-)")
	return nil
}

//  insert method common for all zoho crm deal update  methods

func InsertZohoCrmDeals(pDebug *helpers.HelperStruct, pReqUid, lSessionId, lAppMode string, pZohoRec *zohointegration.ZohoCrmDealInsertStruct) error {
	pDebug.Log(helpers.Statement, "InsertZohoCrmDeals (+)")
	lCoreString := `INSERT INTO zohocrm_deals_info
					(RequestUid, CallType, ClientName, Pan, Email, Phone, Lang, RmCode, BrCode, EmpCode, UtmSource, UtmMedium, 
					UtmCampaign, UtmTerm, UtmKeyword,UtmContent, Mode, ReferalCode, Gclid, Stage,url_RmCode, url_BrCode, url_EmpCode, url_UtmSource, url_UtmMedium, url_UtmCampaign, url_UtmTerm, url_UtmContent, url_UtmKeyword, url_Mode, url_ReferalCode, url_Gclid,CreatedSId, CreatedDate,App_mode)
					VALUES(?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?, ?, unix_timestamp(now()),?)`

	_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString, pReqUid, pZohoRec.Calltype, pZohoRec.Clientname, pZohoRec.Pan, pZohoRec.Email, pZohoRec.Phone, pZohoRec.Lang, pZohoRec.Rmcode, pZohoRec.Brcode, pZohoRec.Empcode, pZohoRec.Utm_source, pZohoRec.Utm_medium, pZohoRec.Utm_campaign, pZohoRec.Utm_term, pZohoRec.Utm_keyword, pZohoRec.Utm_content, pZohoRec.Mode, pZohoRec.Referral_code, pZohoRec.Gclid, pZohoRec.Stage, pZohoRec.Url_RmCode, pZohoRec.Url_BrCode, pZohoRec.Url_EmpCode, pZohoRec.Url_UtmSource, pZohoRec.Url_UtmMedium, pZohoRec.Url_UtmCampaign, pZohoRec.Url_UtmTerm, pZohoRec.Url_UtmContent, pZohoRec.Url_UtmKeyword, pZohoRec.Url_Mode, pZohoRec.Url_ReferalCode, pZohoRec.Url_Gclid, lSessionId, lAppMode)

	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIIZCD01 ", lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "InsertZohoCrmDeals (-)")
	return nil
}

//  get client details method common for all zoho crm deal update  methods

func GetClientDetails(pDebug *helpers.HelperStruct, pReqUid string, pZohoRec *zohointegration.ZohoCrmDealInsertStruct, lCrmDealReq *zohointegration.ZohoCrmDealStruct) error {
	pDebug.Log(helpers.Statement, "GetClientDetails (+)")
	var lStateCode string
	lCoreString := `select nvl(Name_As_Per_Pan, Given_Name) Name, nvl(Pan , '') Pan ,nvl(Email , '') Email ,nvl(Phone  , '') Phone  ,nvl(Given_State  , '') State ,nvl(Client_Id , '') Client_Id 
	from ekyc_request er 
	where Uid = ?`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pReqUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIGCD01 ", lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&pZohoRec.Clientname, &pZohoRec.Pan, &pZohoRec.Email, &pZohoRec.Phone, &lStateCode, &pZohoRec.ClientID)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SIGCD02 ", lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}

	lResponse, lErr := commonpackage.GetLookUpDescription(pDebug, "state", lStateCode, "Code")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SIGCD03 "+lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	pZohoRec.Lang = lResponse.Descirption

	lCrmDealReq.Clientname = pZohoRec.Clientname
	lCrmDealReq.Pan = pZohoRec.Pan
	lCrmDealReq.Email = pZohoRec.Email
	lCrmDealReq.Phone = pZohoRec.Phone
	lCrmDealReq.Lang = pZohoRec.Lang
	lCrmDealReq.ClientID = pZohoRec.ClientID

	pDebug.Log(helpers.Statement, "GetClientDetails (-)")
	return nil
}

//  get deal info method common for all zoho crm deal update  methods

func NewExistingDeal(pDebug *helpers.HelperStruct, pReqUid string, pZohoRec *zohointegration.ZohoCrmDealInsertStruct, lCrmDealReq *zohointegration.ZohoCrmDealStruct) error {
	pDebug.Log(helpers.Statement, "NewExistingDeal (+)")
	lCoreString := `SELECT 
						CASE 
							WHEN EXISTS (SELECT 1
											FROM zohocrm_deals_info
											WHERE RequestUid = ? ) 
							THEN 'Update'
							ELSE 'New'
						END AS status;`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pReqUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "NED001", lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&pZohoRec.Calltype)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "NED002", lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}

	lCrmDealReq.Orig_system_ref = pReqUid
	lCrmDealReq.Calltype = pZohoRec.Calltype
	pDebug.Log(helpers.Statement, "NewExistingDeal (-)")
	return nil
}

//  read UTM cookiee method common for all zoho crm deal update  methods

func GetUtmCookie(pDebug *helpers.HelperStruct, pReq *http.Request, lZohoInsRec *zohointegration.ZohoCrmDealInsertStruct, pCrmDealReq *zohointegration.ZohoCrmDealStruct) string {
	pDebug.Log(helpers.Statement, "GetUtmCookie (+)")
	var lSessionId string

	pCrmDealReq.Rmcode, _ = appsession.KycReadCookie(pReq, pDebug, "rm_code")
	pCrmDealReq.Brcode, _ = appsession.KycReadCookie(pReq, pDebug, "br_code")
	pCrmDealReq.Empcode, _ = appsession.KycReadCookie(pReq, pDebug, "emp_code")
	pCrmDealReq.Utm_source, _ = appsession.KycReadCookie(pReq, pDebug, "utm_source")
	pCrmDealReq.Utm_medium, _ = appsession.KycReadCookie(pReq, pDebug, "utm_medium")
	pCrmDealReq.Utm_campaign, _ = appsession.KycReadCookie(pReq, pDebug, "utm_campaign")
	pCrmDealReq.Utm_term, _ = appsession.KycReadCookie(pReq, pDebug, "utm_term")
	pCrmDealReq.Utm_content, _ = appsession.KycReadCookie(pReq, pDebug, "utm_content")
	pCrmDealReq.Gclid, _ = appsession.KycReadCookie(pReq, pDebug, "gclid")
	pCrmDealReq.Mode, _ = appsession.KycReadCookie(pReq, pDebug, "mode")
	pCrmDealReq.Referral_code, _ = appsession.KycReadCookie(pReq, pDebug, "referral_code")
	pCrmDealReq.Utm_keyword, _ = appsession.KycReadCookie(pReq, pDebug, "utm_keyword")

	lZohoInsRec.Rmcode = pCrmDealReq.Rmcode
	lZohoInsRec.Brcode = pCrmDealReq.Brcode
	lZohoInsRec.Empcode = pCrmDealReq.Empcode
	lZohoInsRec.Utm_source = pCrmDealReq.Utm_source
	lZohoInsRec.Utm_medium = pCrmDealReq.Utm_medium
	lZohoInsRec.Utm_campaign = pCrmDealReq.Utm_campaign
	lZohoInsRec.Utm_term = pCrmDealReq.Utm_term
	lZohoInsRec.Utm_content = pCrmDealReq.Utm_content
	lZohoInsRec.Gclid = pCrmDealReq.Gclid
	lZohoInsRec.Mode = pCrmDealReq.Mode
	lZohoInsRec.Referral_code = pCrmDealReq.Referral_code
	lZohoInsRec.Utm_keyword = pCrmDealReq.Utm_keyword

	if pCrmDealReq.Rmcode == "Not Set" {
		pCrmDealReq.Rmcode = ""
		lZohoInsRec.Rmcode = ""
	}
	if pCrmDealReq.Brcode == "Not Set" {
		pCrmDealReq.Brcode = ""
		lZohoInsRec.Brcode = ""
	}
	if pCrmDealReq.Empcode == "Not Set" {
		pCrmDealReq.Empcode = ""
		lZohoInsRec.Empcode = ""
	}
	if pCrmDealReq.Utm_source == "Not Set" {
		pCrmDealReq.Utm_source = ""
		lZohoInsRec.Utm_source = ""
	}
	if pCrmDealReq.Utm_medium == "Not Set" {
		pCrmDealReq.Utm_medium = ""
		lZohoInsRec.Utm_medium = ""
	}
	if pCrmDealReq.Utm_campaign == "Not Set" {
		pCrmDealReq.Utm_campaign = ""
		lZohoInsRec.Utm_campaign = ""
	}
	if pCrmDealReq.Utm_term == "Not Set" {
		pCrmDealReq.Utm_term = ""
		lZohoInsRec.Utm_term = ""
	}
	if pCrmDealReq.Utm_content == "Not Set" {
		pCrmDealReq.Utm_content = ""
		lZohoInsRec.Utm_content = ""
	}
	if pCrmDealReq.Gclid == "Not Set" {
		pCrmDealReq.Gclid = ""
		lZohoInsRec.Gclid = ""
	}
	if pCrmDealReq.Mode == "Not Set" {
		pCrmDealReq.Mode = ""
		lZohoInsRec.Mode = ""
	}
	if pCrmDealReq.Referral_code == "Not Set" {
		pCrmDealReq.Referral_code = ""
		lZohoInsRec.Referral_code = ""
	}
	if pCrmDealReq.Utm_keyword == "Not Set" {
		pCrmDealReq.Utm_keyword = ""
		lZohoInsRec.Utm_keyword = ""
	}

	lSessionId, _ = appsession.KycReadCookie(pReq, pDebug, common.EKYCCookieName)

	pDebug.Log(helpers.Statement, "GetUtmCookie (-)")
	return lSessionId
}

func SetUtmCookie(pDebug *helpers.HelperStruct, pReq *http.Request, pResp http.ResponseWriter, pZohoRec *zohointegration.ZohoCrmDealInsertStruct) zohointegration.ZohoCrmDealStruct {
	pDebug.Log(helpers.Statement, "GetUtmCookie (+)")

	var lCrmDealReq zohointegration.ZohoCrmDealStruct

	pZohoRec.Rmcode, _ = appsession.KycReadCookie(pReq, pDebug, "rm_code")
	pZohoRec.Brcode, _ = appsession.KycReadCookie(pReq, pDebug, "br_code")
	pZohoRec.Empcode, _ = appsession.KycReadCookie(pReq, pDebug, "emp_code")
	pZohoRec.Utm_source, _ = appsession.KycReadCookie(pReq, pDebug, "utm_source")
	pZohoRec.Utm_medium, _ = appsession.KycReadCookie(pReq, pDebug, "utm_medium")
	pZohoRec.Utm_campaign, _ = appsession.KycReadCookie(pReq, pDebug, "utm_campaign")
	pZohoRec.Utm_term, _ = appsession.KycReadCookie(pReq, pDebug, "utm_term")
	pZohoRec.Utm_content, _ = appsession.KycReadCookie(pReq, pDebug, "utm_content")
	pZohoRec.Gclid, _ = appsession.KycReadCookie(pReq, pDebug, "gclid")
	pZohoRec.Mode, _ = appsession.KycReadCookie(pReq, pDebug, "mode")
	pZohoRec.Referral_code, _ = appsession.KycReadCookie(pReq, pDebug, "referral_code")
	pZohoRec.Utm_keyword, _ = appsession.KycReadCookie(pReq, pDebug, "utm_keyword")

	if pZohoRec.Rmcode == "Not Set" {
		lErr := appsession.KycSetcookie(pResp, pDebug, "rm_code", pZohoRec.Url_RmCode, common.UtmMaxAge)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SISUC01 "+lErr.Error())
		}
		pZohoRec.Rmcode = pZohoRec.Url_RmCode
		lCrmDealReq.Rmcode = pZohoRec.Url_RmCode
	} else {
		lCrmDealReq.Rmcode = pZohoRec.Rmcode
	}

	if pZohoRec.Brcode == "Not Set" {
		lErr := appsession.KycSetcookie(pResp, pDebug, "br_code", pZohoRec.Url_BrCode, common.UtmMaxAge)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SISUC02 "+lErr.Error())
		}
		pZohoRec.Brcode = pZohoRec.Url_BrCode
		lCrmDealReq.Brcode = pZohoRec.Url_BrCode
	} else {
		lCrmDealReq.Brcode = pZohoRec.Brcode
	}

	if pZohoRec.Empcode == "Not Set" {
		lErr := appsession.KycSetcookie(pResp, pDebug, "emp_code", pZohoRec.Url_EmpCode, common.UtmMaxAge)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SISUC03 "+lErr.Error())
		}
		pZohoRec.Empcode = pZohoRec.Url_EmpCode
		lCrmDealReq.Empcode = pZohoRec.Url_EmpCode
	} else {
		lCrmDealReq.Empcode = pZohoRec.Empcode
	}

	if pZohoRec.Utm_source == "Not Set" {
		lErr := appsession.KycSetcookie(pResp, pDebug, "utm_source", pZohoRec.Url_UtmSource, common.UtmMaxAge)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SISUC04 "+lErr.Error())
		}
		pZohoRec.Utm_source = pZohoRec.Url_UtmSource
		lCrmDealReq.Utm_source = pZohoRec.Url_UtmSource
	} else {
		lCrmDealReq.Utm_source = pZohoRec.Utm_source
	}

	if pZohoRec.Utm_medium == "Not Set" {
		lErr := appsession.KycSetcookie(pResp, pDebug, "utm_medium", pZohoRec.Url_UtmMedium, common.UtmMaxAge)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SISUC05 "+lErr.Error())
		}
		pZohoRec.Utm_medium = pZohoRec.Url_UtmMedium
		lCrmDealReq.Utm_medium = pZohoRec.Url_UtmMedium
	} else {
		lCrmDealReq.Utm_medium = pZohoRec.Utm_medium
	}

	if pZohoRec.Utm_campaign == "Not Set" {
		lErr := appsession.KycSetcookie(pResp, pDebug, "utm_campaign", pZohoRec.Url_UtmCampaign, common.UtmMaxAge)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SISUC06 "+lErr.Error())
		}
		pZohoRec.Utm_campaign = pZohoRec.Url_UtmCampaign
		lCrmDealReq.Utm_campaign = pZohoRec.Url_UtmCampaign
	} else {
		lCrmDealReq.Utm_campaign = pZohoRec.Utm_campaign
	}

	if pZohoRec.Utm_term == "Not Set" {
		lErr := appsession.KycSetcookie(pResp, pDebug, "utm_term", pZohoRec.Url_UtmTerm, common.UtmMaxAge)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SISUC07 "+lErr.Error())
		}
		pZohoRec.Utm_term = pZohoRec.Url_UtmTerm
		lCrmDealReq.Utm_term = pZohoRec.Url_UtmTerm
	} else {
		lCrmDealReq.Utm_term = pZohoRec.Utm_term
	}

	if pZohoRec.Utm_content == "Not Set" {
		lErr := appsession.KycSetcookie(pResp, pDebug, "utm_content", pZohoRec.Url_UtmContent, common.UtmMaxAge)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SISUC08 "+lErr.Error())
		}
		pZohoRec.Utm_content = pZohoRec.Url_UtmContent
		lCrmDealReq.Utm_content = pZohoRec.Url_UtmContent
	} else {
		lCrmDealReq.Utm_content = pZohoRec.Utm_content
	}

	if pZohoRec.Gclid == "Not Set" {
		lErr := appsession.KycSetcookie(pResp, pDebug, "gclid", pZohoRec.Url_Gclid, common.UtmMaxAge)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SISUC09 "+lErr.Error())
		}
		pZohoRec.Gclid = pZohoRec.Url_Gclid
		lCrmDealReq.Gclid = pZohoRec.Url_Gclid
	} else {
		lCrmDealReq.Gclid = pZohoRec.Gclid
	}

	if pZohoRec.Mode == "Not Set" {
		lErr := appsession.KycSetcookie(pResp, pDebug, "mode", pZohoRec.Url_Mode, common.UtmMaxAge)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SISUC010 "+lErr.Error())
		}
		pZohoRec.Mode = pZohoRec.Url_Mode
		lCrmDealReq.Mode = pZohoRec.Url_Mode
	} else {
		lCrmDealReq.Mode = pZohoRec.Mode
	}
	if pZohoRec.Referral_code == "Not Set" {
		lErr := appsession.KycSetcookie(pResp, pDebug, "referral_code", pZohoRec.Url_ReferalCode, common.UtmMaxAge)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SISUC11 "+lErr.Error())
		}
		pZohoRec.Referral_code = pZohoRec.Url_ReferalCode
		lCrmDealReq.Referral_code = pZohoRec.Url_ReferalCode
	} else {
		lCrmDealReq.Referral_code = pZohoRec.Referral_code
	}
	if pZohoRec.Utm_keyword == "Not Set" {
		lErr := appsession.KycSetcookie(pResp, pDebug, "utm_keyword", pZohoRec.Url_UtmKeyword, common.UtmMaxAge)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "SISUC12 "+lErr.Error())
		}
		pZohoRec.Utm_keyword = pZohoRec.Url_UtmKeyword
		lCrmDealReq.Utm_keyword = pZohoRec.Url_UtmKeyword
	} else {
		lCrmDealReq.Utm_keyword = pZohoRec.Utm_keyword
	}

	pDebug.Log(helpers.Statement, "GetUtmCookie (-)")
	return lCrmDealReq
}

func SetCrmStages() {
	common.CRMDeal = tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "CRMDeal")
	common.MobileVerified = tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "STAGE_PHONE")
	common.PanVerified = tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "STAGE_PAN")
	common.AddressVerified = tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "STAGE_ADDRESS")
	common.BankVerified = tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "STAGE_BANK")
	common.SegmentVerified = tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "STAGE_SEGMENT")
	common.DocumnetVerified = tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "STAGE_DOCUMENT")
	common.IPVVerified = tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "STAGE_IPV")
	common.Rejected = tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "STAGE_REJECTED")
	common.InProgress = tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "STAGE_INPROGRESS")
	common.Completed = tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "STAGE_COMPLETED")

}
