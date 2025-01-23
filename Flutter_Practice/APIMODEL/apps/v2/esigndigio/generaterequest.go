package esigndigio

import (
	"encoding/json"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	digio "fcs23pkg/integration/v2/digioesign"
	"fcs23pkg/tomlconfig"
	"fmt"
	"net/http"
	"strings"
)

func DigioSignRequ(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "DigioSignRequ (+)")

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "GET")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold("get", r.Method) {

		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSR01", lErr)
			fmt.Fprint(w, helpers.GetError_String("DSR01", "Somthing is wrong please try again later"))
			return
		}
		lEsignInfoRec, lErr := GetUserInfo(lDebug, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSR02", lErr)
			fmt.Fprint(w, helpers.GetError_String("DSR02", "Somthing is wrong please try again later"))
			return
		}
		lSignInfo, lErr := GenerateSignReq(lDebug, lEsignInfoRec, lUid, lSid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSR03", lErr)
			fmt.Fprint(w, helpers.GetError_String("DSR03", "Somthing is wrong please try again later"))
			return
		}
		lSignResp, lErr := json.Marshal(lSignInfo)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DSR04", lErr)
			fmt.Fprint(w, helpers.GetError_String("DSR04", "Somthing is wrong please try again later"))
			return
		}
		fmt.Fprint(w, string(lSignResp))
		lDebug.Log(helpers.Statement, "DigioSignRequ (-)")

	}
}

func GetUserInfo(pDebug *helpers.HelperStruct, pUid string) (lEsignInfoRec ESignInfoStruct, lErr error) {
	pDebug.Log(helpers.Statement, "GetUserInfo (+)")

	lQuery := `SELECT Phone,Name_As_Per_Pan,unsignedDocid
	FROM ekyc_request
	WHERE Uid=?;
	`
	lRow, lErr := ftdb.NewEkyc_GDB.Query(lQuery, pUid)
	if lErr != nil {
		return lEsignInfoRec, helpers.ErrReturn(lErr)
	}
	defer lRow.Close()
	for lRow.Next() {
		lErr = lRow.Scan(&lEsignInfoRec.Mobile, &lEsignInfoRec.UserName, &lEsignInfoRec.PDFID)
		if lErr != nil {
			return lEsignInfoRec, helpers.ErrReturn(lErr)
		}
	}

	//get URL from toml
	lEsignInfoRec.ProcessType = tomlconfig.GtomlConfigLoader.GetValueString("digioesign", "ProcessType")
	lEsignInfoRec.SignType = tomlconfig.GtomlConfigLoader.GetValueString("digioesign", "SignType")
	lEsignInfoRec.Reason = tomlconfig.GtomlConfigLoader.GetValueString("digioesign", "SignReason")

	pDebug.Log(helpers.Statement, "GetUserInfo (-)")
	return lEsignInfoRec, nil
}

func CheckSignStatus(pDebug *helpers.HelperStruct, pDid string) error {
	pDebug.Log(helpers.Statement, "CheckSignStatus (+)")

	var lAgreementRec AgreementStruct

	lResp, lErr := digio.GetSignInfo(pDebug, pDid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	lErr = json.Unmarshal([]byte(lResp), &lAgreementRec)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	if !strings.EqualFold(lAgreementRec.AgreementStatus, "completed") {
		return helpers.ErrReturn(fmt.Errorf("e-sign is Not Completed"))

	}

	pDebug.Log(helpers.Statement, "CheckSignStatus (-)")
	return nil
}
