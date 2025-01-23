package esign

import (
	"encoding/json"
	"fcs23pkg/apps/v2/model"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/file"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/integrationsign"
	"fcs23pkg/tomlconfig"
	"fmt"
	"log"
	"net/http"
	"regexp"
	"strings"
)

type EsignResp struct {
	StatusMsg string `json:"StatusMsg"`
	XmlData   string `json:"XmlData"`
}

func InitiateEsignProcess(w http.ResponseWriter, r *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)

	(w).Header().Set("Access-Control-Allow-Origin", "*")
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "  GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	w.WriteHeader(200)

	lDebug.Log(helpers.Statement, "InitiateEsignProcess (+)")

	if r.Method == "GET" {

		var lEsignResp EsignResp
		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "IEP01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("IEP01", "Something went wrong. Please try again later."))
			return
		}
		lRespHtmlData, lErr := EsignProcess(lUid, lDebug, r)
		lDebug.Log(helpers.Details, "respHtmlData", lRespHtmlData)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "IEP02"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("IEP02", "Something went wrong please try after sometime... "))
			return
		} else {
			if lRespHtmlData != "" {
				lErr := json.Unmarshal([]byte(lRespHtmlData), &lEsignResp)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "IEP03"+lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("IEP03", "Something went wrong please try after sometime... "))
					return
				} else {
					// log.Println(esignResp.XmlData)
					lRespHtmlData, lErr = common.DecodeToString(lEsignResp.XmlData)
					if lErr != nil {
						lDebug.Log(helpers.Elog, "IEP04"+lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("IEP04", "Something went wrong please try after sometime... "))
						return
					} else {
						// log.Println("lRespHtmlData Before", lRespHtmlData)
						// lRespHtmlData = ReplaceRedirectURL(lRespHtmlData, "request", lDebug)
						// log.Println("lRespHtmlData After", lRespHtmlData)
						// lRespHtmlData = strings.Replace(lRespHtmlData, "29091", "28094", 1)
						lRespHtmlData = ReplaceHTML(lRespHtmlData, lDebug)
						lDebug.Log(helpers.Details, "respHtmlData", lRespHtmlData)
						// w.Header().Set("Content-Type", "text/html")
						// w.Header().Set("X-Frame-Options", "SAMEORIGIN")

						fmt.Fprint(w, lRespHtmlData)
						return
					}
				}
			} else {
				lHtmlRespData, lErr := common.HtmlFileToString("./html/StampError.html")
				if lErr != nil {
					lDebug.Log(helpers.Elog, "SED02", lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("SED02", "Something went wrong please try after sometime... "))
					return
				}
				fmt.Fprint(w, lHtmlRespData)
			}
		}

	}
	lDebug.Log(helpers.Statement, "InitiateEsignProcess (-)")
}
func EsignProcess(pRequestId string, pDebug *helpers.HelperStruct, r *http.Request) (string, error) {
	pDebug.Log(helpers.Statement, "EsignProcess (+)")

	var lRespBody string

	lClientId, lUnsigndocid, lUsername, lErr := GetRequestInfo(pRequestId, pDebug)
	pDebug.Log(helpers.Details, "ClientId", lClientId)
	pDebug.Log(helpers.Details, "unsigndocid", lUnsigndocid)
	// unsigndocid = "3900"
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	lAddress, lErr := GetAddress(pRequestId, pDebug)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	if pRequestId != "" && lUnsigndocid != "" {
		lEsign_Json_str, lErr := ConstructEsignRequest(pRequestId, lUnsigndocid, lClientId, lUsername, lAddress, pDebug)
		pDebug.Log(helpers.Details, "Esign_Json_str", lEsign_Json_str)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		} else {
			lEsignXmlProcessType := tomlconfig.GtomlConfigLoader.GetValueString("kycintegrationconfig", "EsignXmlProcessType")
			lRespBody, lErr = integrationsign.Api_call_processed_data(lEsignXmlProcessType, lEsign_Json_str, pDebug, r)
			if lErr != nil {
				return "", helpers.ErrReturn(lErr)
			} else {
				pDebug.Log(helpers.Details, "html Data: ", lRespBody)
			}

		}
	}
	pDebug.Log(helpers.Statement, "EsignProcess (-)")
	return lRespBody, nil

}
func ConstructEsignRequest(reqId, docId, clientId, pUsername, pAddress string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "ConstructEsignRequest (+)")
	var lEsignReq model.XmlGeneration
	var lEsign_Json_str string
	var lErr error

	lEsignReq.FilePath, _, lErr = file.GetFilePath(docId)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	} else {
		lEsignReq.DocId = docId
		lEsignReq.HTMLEnabled = true
		//esignReq.ProcessType = common.NomineeProcessType
		txnId, _, lErr := GenerateReqIDandTxnID(reqId, "txnid", pDebug)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
		lEsignReq.NameToShowOnSignatureStamp = pUsername
		lEsignReq.LocationToShowOnSignatureStamp = pAddress
		lEsignReq.RequestId = "flattrade:esign:" + txnId
		lEsignReq.ClientId = clientId

		lEsignReq.Reason = tomlconfig.GtomlConfigLoader.GetValueString("kycintegrationconfig", "EsignReason")
		lEsignReq.ProcessType = tomlconfig.GtomlConfigLoader.GetValueString("kycintegrationconfig", "ESIGNProcessType")

		Esign_Json, lErr := json.Marshal(lEsignReq)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		} else {
			lEsign_Json_str = string(Esign_Json)
		}
		pDebug.Log(helpers.Details, "Esign_Json_str", lEsign_Json_str)
	}
	pDebug.Log(helpers.Statement, "ConstructEsignRequest (-)")
	return lEsign_Json_str, nil

}

func ReplaceHTML(pFileBody string, pDebug *helpers.HelperStruct) string {
	pDebug.Log(helpers.Statement, "ReplaceHTML (+)")

	var htmlHeader = `<html><head><style>.overlay{left:0;top:0;width:100%;height:100%;position:fixed;background:rgb(33,33,33,.46)}.overlay__inner{left:0;top:0;width:100%;height:100%;position:absolute}.overlay__content{left:50%;position:absolute;top:50%;transform:translate(-50%,-50%);display:flex;flex-direction:column;align-items:center;width:90%;text-align:center}.spinner{width:65px;height:65px;display:inline-block;border-width:4px;border-color:rgba(255,255,255,.05);border-color:#fff;border-bottom-color:transparent;animation:spin 1s infinite linear;border-radius:100%;border-style:solid}.overlay__content h2{color:#fff;font-weight:500;font-size: 18px;font-family: sans-serif;}@keyframes spin{100%{transform:rotate(360deg)}}</style><script>document.addEventListener("DOMContentLoaded", function() { document.forms[0].submit();});</script></head><body><div class="overlay"><div class="overlay__inner"><div class="overlay__content"><span class="spinner"></span><h2>Please wait we are fetching your data ...</h2></div></div></div>`
	var htmlBody = `</body></html>`

	re := regexp.MustCompile(`(?s)<form.*?>([^<]*?)</form>`)
	matches := re.FindAllStringSubmatch(pFileBody, -1)

	var formSections []string
	for _, match := range matches {
		formSections = append(formSections, match[0])
	}
	log.Println("formSections", formSections)
	pFileBody = htmlHeader + strings.Join(formSections, "") + htmlBody
	log.Println("filebody", pFileBody)
	pDebug.Log(helpers.Statement, "ReplaceHTML (-)")
	return pFileBody
}
