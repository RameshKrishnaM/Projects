package zohointegration

import (
	"encoding/json"
	"fcs23pkg/coresettings"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
)

type ZohoCrmDealStruct struct {
	Calltype        string `json:"calltype"`
	Clientname      string `json:"clientname"`
	Pan             string `json:"pan"`
	Email           string `json:"email"`
	Phone           string `json:"phone"`
	Lang            string `json:"lang"`
	Rmcode          string `json:"rm_code"`
	Brcode          string `json:"br_code"`
	Empcode         string `json:"emp_code"`
	Utm_source      string `json:"utm_source"`
	Utm_medium      string `json:"utm_medium"`
	Utm_campaign    string `json:"utm_campaign"`
	Utm_keyword     string `json:"utm_keyword"`
	Utm_term        string `json:"utm_term"`
	Utm_content     string `json:"utm_content"`
	Mode            string `json:"mode"`
	Referral_code   string `json:"referral_code"`
	Gclid           string `json:"gclid"`
	Stage           string `json:"stage"`
	Orig_system_ref string `json:"orig_system_ref"`
	AppName         string `json:"c_utm_source"`
	AppType         string `json:"c_utm_medium"`
	ClientID        string `json:"ClientID"` // ADDED BY VIJAY ON DEC 2 2024
}

type ZohoCrmDealInsertStruct struct {
	Calltype        string `json:"calltype"`
	Clientname      string `json:"clientname"`
	Pan             string `json:"pan"`
	Email           string `json:"email"`
	Phone           string `json:"phone"`
	Lang            string `json:"lang"`
	Rmcode          string `json:"rm_code"`
	Brcode          string `json:"br_code"`
	Empcode         string `json:"emp_code"`
	Utm_source      string `json:"utm_source"`
	Utm_medium      string `json:"utm_medium"`
	Utm_campaign    string `json:"utm_campaign"`
	Utm_keyword     string `json:"utm_keyword"`
	Utm_term        string `json:"utm_term"`
	Utm_content     string `json:"utm_content"`
	Mode            string `json:"mode"`
	Referral_code   string `json:"referral_code"`
	Gclid           string `json:"gclid"`
	Stage           string `json:"stage"`
	Url_RmCode      string `json:"url_rmCode"`
	Url_BrCode      string `json:"url_brCode"`
	Url_EmpCode     string `json:"url_empCode"`
	Url_UtmSource   string `json:"url_utmSource"`
	Url_UtmMedium   string `json:"url_utmMedium"`
	Url_UtmCampaign string `json:"url_utmCampaign"`
	Url_UtmTerm     string `json:"url_utmTerm"`
	Url_UtmContent  string `json:"url_utmContent"`
	Url_UtmKeyword  string `json:"url_utmKeyword"`
	Url_Mode        string `json:"url_mode"`
	Url_ReferalCode string `json:"url_referalCode"`
	Url_Gclid       string `json:"url_gclid"`
	AppName         string `json:"c_utm_source"`
	AppType         string `json:"c_utm_medium"`
	ClientID        string `json:"ClientID"` // ADDED BY VIJAY ON DEC 2 2024
}

type UtmCookieStruct struct {
	Rmcode        string `json:"rm_code"`
	Brcode        string `json:"br_code"`
	Empcode       string `json:"emp_code"`
	Utm_source    string `json:"utm_source"`
	Utm_medium    string `json:"utm_medium"`
	Utm_campaign  string `json:"utm_campaign"`
	Utm_keyword   string `json:"utm_keyword"`
	Utm_term      string `json:"utm_term"`
	Utm_content   string `json:"utm_content"`
	Mode          string `json:"mode"`
	Referral_code string `json:"referral_code"`
	Gclid         string `json:"gclid"`
}

func ZohoCrmDealUpdate(pDebug *helpers.HelperStruct, pZohoRec *ZohoCrmDealStruct) error {
	pDebug.Log(helpers.Statement, "ZohoCrmDealUpdate (+)")

	var lHeader apiUtil.HeaderDetails
	var lHeaderArr []apiUtil.HeaderDetails

	lHeader.Key = "Content-Type"
	lHeader.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeader)

	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "ZOHOCRMDEALURL")

	lData, lErr := json.Marshal(pZohoRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "ZZCDU01 ", helpers.ErrReturn(lErr))
		return lErr
	}

	lResponse, lErr := apiUtil.Api_call(pDebug, lUrl, "PUT", string(lData), lHeaderArr, "ZohoCrmDealUpdate")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "ZZCDU02 ", helpers.ErrReturn(lErr))
		return lErr
	}

	pDebug.Log(helpers.Details, "lResponse", lResponse)

	pDebug.Log(helpers.Statement, "ZohoCrmDealUpdate (-)")
	return nil
}

func ZohoCrmDealUpdateNRI(pDebug *helpers.HelperStruct, pPayload string) error {
	pDebug.Log(helpers.Statement, "ZohoCrmDealUpdateNRI (+)")

	var lHeader apiUtil.HeaderDetails
	var lHeaderArr []apiUtil.HeaderDetails

	lHeader.Key = "Content-Type"
	lHeader.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeader)

	lUrlKey := tomlconfig.GtomlConfigLoader.GetValueString("crmdealconfig", "ZOHOCRMDEALNRIURL")

	lUrl := coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, lUrlKey)

	lResponse, lErr := apiUtil.Api_call(pDebug, lUrl, "POST", pPayload, lHeaderArr, "ZohoCrmDealUpdateNRI")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "ZZCDU02 ", helpers.ErrReturn(lErr))
		return lErr
	}

	pDebug.Log(helpers.Details, "lResponse", lResponse)

	pDebug.Log(helpers.Statement, "ZohoCrmDealUpdateNRI (-)")
	return nil
}
