package accaggregator

import (
	"encoding/json"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"fmt"
	"net/http"
)

//Consent Request data in AA Structure
type AAConsentRequestStruct struct {
	PartyIdentifierType  string `json:"partyIdentifierType"`
	PartyIdentifierValue string `json:"partyIdentifierValue"`
	ProductID            string `json:"productID"`
	AccountID            string `json:"accountID"`
	VUA                  string `json:"vua"`
}

type ConsentDataStruct struct {
	ClientId          string
	ClientSecret      string
	OrganisationId    string
	ApplicationId     string
	ClientIdKey       string
	ClientSecretKey   string
	OrganisationIdKey string
	ApplicationIdKey  string
	ContentType       string
	Content_value     string
}

// Define the FIP structure representing each FIP in the response
type FIPStruct struct {
	FIPID   string `json:"fipId"`
	FIPName string `json:"fipName"`
	// FiTypes []string `json:"FiTypes"`
}

// Define the Data structure representing the nested data in the response
type ListFipDataStruct struct {
	FIPNewListArr []FIPStruct `json:"fip_newlist"`
}

// Define the GetListFipIDResponse structure representing the entire response
type GetListFipIDRespStruct struct {
	Ver     string            `json:"ver"`
	Status  string            `json:"status"`
	Data    ListFipDataStruct `json:"data"`
	Message string            `json:"message"`
}

//get EntryptUrl Request Structure
type EncryptUrlReqStruct struct {
	ConsentHandle string   `json:"consentHandle"`
	RedirectUrl   string   `json:"redirectUrl"`
	FipID         []string `json:"fipID,omitempty"`
}

//
// ReadConsentTomlFile reads configuration details from a TOML file.
func ReadConsentTomlFile() ConsentDataStruct {
	return ConsentDataStruct{
		ClientId:          tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ClientId"),
		ClientSecret:      tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ClientSecret"),
		OrganisationId:    tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "OrganisationId"),
		ApplicationId:     tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ApplicationId"),
		ClientIdKey:       tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ClientID"),
		ClientSecretKey:   tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ClientSecretName"),
		OrganisationIdKey: tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "OrganisationID"),
		ApplicationIdKey:  tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "AppIdentifier"),
		ContentType:       tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "Content_Type"),
		Content_value:     tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "Content_value"),
	}
}

//get Consent status DecryptUrl Request Structure
type DecryptUrlRequest struct {
	WebRedirectionURL struct {
		Ecres   string `json:"ecres"`
		Resdate string `json:"resdate"`
		Fi      string `json:"fi"`
	} `json:"webRedirectionURL"`
}

//get consent List in AA Request structure
type GetConsentListReq struct {
	PartyIdentifierType  string `json:"partyIdentifierType"`
	PartyIdentifierValue string `json:"partyIdentifierValue"`
	ProductID            string `json:"productID"`
	AccountID            string `json:"accountID"`
}

// RequestConsentHandler sends a request to obtain user consent.
/*
Usage of RequestConsentHandler
*/
func RequestConsentHandler(pDebug *helpers.HelperStruct, pUid string, pMobileNumber string) (string, error) {
	var lConsentReqData AAConsentRequestStruct
	lProductID := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ProductID")

	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "RequestConsentUrl")

	lConsentReqData.PartyIdentifierType = tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "PartyIdentifierType")
	lConsentReqData.PartyIdentifierValue = pMobileNumber
	lConsentReqData.ProductID = lProductID
	lConsentReqData.AccountID = pUid
	lConsentReqData.VUA = fmt.Sprintf("%s@onemoney", pMobileNumber)

	pJsonData, lErr := json.Marshal(lConsentReqData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CR003: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	lHeaderArr := ConstructHeader()

	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, http.MethodPost, string(pJsonData), lHeaderArr, "Consent Handle")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "RCH001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "Response consenHandler", lResp)
	pDebug.Log(helpers.Statement, "RequestConsentHandler (-)")
	return lResp, nil
}

// GetEncryptedUrlHandler sends a request to obtain an encrypted URL.
func GetEncryptedUrlHandler(pDebug *helpers.HelperStruct, pConsentHandlleId string, pFipID string) (string, error) {

	pDebug.Log(helpers.Statement, "GetEncryptedUrlHandler (+)")
	var lEncryptUrlReq EncryptUrlReqStruct

	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "EncryptUrl")

	RedirectUrl := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "RedirectUrl")

	if pFipID == "" {
		pDebug.Log(helpers.Elog, "CUG004: Fip id not found")
	} else {
		lEncryptUrlReq.FipID = append(lEncryptUrlReq.FipID, pFipID)
	}
	lEncryptUrlReq.ConsentHandle = pConsentHandlleId
	lEncryptUrlReq.RedirectUrl = RedirectUrl
	lJsonData, lErr := json.Marshal(lEncryptUrlReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GEUH001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)

	}
	lHeaderArr := ConstructHeader()

	lResponse, lErr := apiUtil.Api_call(pDebug, lUrl, http.MethodPost, string(lJsonData), lHeaderArr, "Encrypt URL")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GEUH002: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "GetEncryptedUrlHandler (-)")
	return lResponse, nil
}

// DecryptUrlHandler sends a request to decrypt a URL.
func DecryptUrlHandler(pDebug *helpers.HelperStruct, pEncryptUrlResp string, pResDateResp string, pFiresp string) (string, error) {

	pDebug.Log(helpers.Statement, "DecryptUrlHandler (+)")

	var lReqData DecryptUrlRequest

	// lUrl := fmt.Sprintf("%v", lConfigFile.(map[string]interface{})["DecryptUrl"])
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "DecryptUrl")

	lReqData.WebRedirectionURL.Ecres = pEncryptUrlResp
	lReqData.WebRedirectionURL.Resdate = pResDateResp
	lReqData.WebRedirectionURL.Fi = pFiresp
	lReqBody, lErr := json.Marshal(lReqData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "DUH001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	lHeaderArr := ConstructHeader()

	lRespData, lErr := apiUtil.Api_call(pDebug, lUrl, http.MethodPost, string(lReqBody), lHeaderArr, "Decrypt URL")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "DUH002: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "DecryptUrlHandler (-)")
	return lRespData, nil
}

// GetConsentDataList retrieves a list of consent data.
func GetConsentDataList(pDebug *helpers.HelperStruct, pUid string, pMobileNumber string) (string, error) {

	pDebug.Log(helpers.Statement, "ConsentStatusHandler (+)")
	var lConsentListReq GetConsentListReq

	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "GetConsentUrl")

	lProductID := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ProductID")

	lConsentListReq.PartyIdentifierType = tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "PartyIdentifierType")
	lConsentListReq.PartyIdentifierValue = pMobileNumber
	lConsentListReq.ProductID = lProductID
	lConsentListReq.AccountID = pUid
	lReqBody, lErr := json.Marshal(lConsentListReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GCD001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	lHeaderArr := ConstructHeader()

	lReqData := string(lReqBody)
	lResponseData, lErr := apiUtil.Api_call(pDebug, lUrl, http.MethodPost, lReqData, lHeaderArr, "Consent Status")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GCD002: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "Response consentstatus", lResponseData)
	pDebug.Log(helpers.Statement, "ConsentStatusHandler (-)")
	return lResponseData, nil

}

// StatementPdfDownload sends a request to download a statement PDF.
func StatementPdfDownload(pDebug *helpers.HelperStruct, pPdfReq string) (string, error) {
	pDebug.Log(helpers.Statement, "StatementPdfDownload (+)")

	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "GetPdfDownload")

	lHeaderArr := ConstructHeader()

	lResponse, lErr := apiUtil.Api_call(pDebug, lUrl, http.MethodPost, pPdfReq, lHeaderArr, "Statement PDF Download")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SPD001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "StatementPdfDownload(-)")
	return lResponse, nil
}

// StatementJsonData sends a request to download a statement Json.
func AAStatementJsonData(pDebug *helpers.HelperStruct, pJsonReq string) (string, error) {
	pDebug.Log(helpers.Statement, "AAStatementJsonData (+)")

	lJsonUrl := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "GetAllLatestFiData")

	lHeaderArr := ConstructHeader()

	lResponse, lErr := apiUtil.Api_call(pDebug, lJsonUrl, http.MethodPost, pJsonReq, lHeaderArr, "Statement Json Data")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "SJT001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "AAStatementJsonData(-)")
	return lResponse, nil
}

// GetListFipID retrieves the FIP ID for a given FIP name
func GetListFipID(pDebug *helpers.HelperStruct) ([]FIPStruct, error) {
	pDebug.Log(helpers.Statement, "GetListFipID (+)")

	lHeaderArr := ConstructHeader()

	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "GetListFipID")

	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, "GET", "", lHeaderArr, "Get FipID")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GLF001: "+lErr.Error())
		return nil, helpers.ErrReturn(lErr)
	}
	var lRespData GetListFipIDRespStruct
	lErr = json.Unmarshal([]byte(lResp), &lRespData)

	if lErr != nil {
		pDebug.Log(helpers.Elog, "GLF002: "+lErr.Error())
		return nil, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "GetListFipID (-)")
	return lRespData.Data.FIPNewListArr, nil
}
func ConstructHeader() []apiUtil.HeaderDetails {
	lConfig := ReadConsentTomlFile()

	// Initializing the header array directly with values
	lHeaderArr := []apiUtil.HeaderDetails{
		{Key: lConfig.ContentType, Value: lConfig.Content_value},
		{Key: lConfig.ClientIdKey, Value: lConfig.ClientId},
		{Key: lConfig.ClientSecretKey, Value: lConfig.ClientSecret},
		{Key: lConfig.OrganisationIdKey, Value: lConfig.OrganisationId},
		{Key: lConfig.ApplicationIdKey, Value: lConfig.ApplicationId},
	}

	return lHeaderArr
}
func RequestConsentService(pDebug *helpers.HelperStruct, pReqBody string) (string, error) {

	lBaseURl := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ServiceBaseURL")
	lConsentReq := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "SrvConsentReq")
	lURL := lBaseURl + lConsentReq

	var lHeaderArr []apiUtil.HeaderDetails

	lResp, lErr := apiUtil.Api_call(pDebug, lURL, http.MethodPost, pReqBody, lHeaderArr, "Consent Request")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "RCH001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "Response consenHandler", lResp)
	pDebug.Log(helpers.Statement, "RequestConsentHandler (-)")
	return lResp, nil
}
func ConsentStatusService(pDebug *helpers.HelperStruct, pReqBody string) (string, error) {

	lBaseURl := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ServiceBaseURL")
	lConsentStatus := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "SrvConsentStatus")

	var lHeaderArr []apiUtil.HeaderDetails

	lURL := lBaseURl + lConsentStatus
	lResp, lErr := apiUtil.Api_call(pDebug, lURL, http.MethodPost, pReqBody, lHeaderArr, "Consent Status")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "RCH001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "Response consenHandler", lResp)
	pDebug.Log(helpers.Statement, "RequestConsentHandler (-)")
	return lResp, nil
}
func ConsentFetchService(pDebug *helpers.HelperStruct, pReqBody string) (string, error) {

	lBaseURl := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "ServiceBaseURL")
	lConsentFetch := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "SrvConsentFetch")
	lURL := lBaseURl + lConsentFetch

	var lHeaderArr []apiUtil.HeaderDetails

	lResp, lErr := apiUtil.Api_call(pDebug, lURL, http.MethodPost, pReqBody, lHeaderArr, "Consent Fetch")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "RCH001: "+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "Response consenHandler", lResp)
	pDebug.Log(helpers.Statement, "RequestConsentHandler (-)")
	return lResp, nil
}
