package backofficecheck

import (
	"encoding/json"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"strings"
)

type BofficeStruct struct {
	Status string `json:"clientExists"`
}

func BofficeCheck(pDebug *helpers.HelperStruct, pValue, pType string) (bool, error) {

	pDebug.Log(helpers.Statement, "IssuedDocProcess (+)")
	pDebug.Log(helpers.Statement, "\n******************************************************************************\n", pType, pValue)
	if pValue == "" {
		return false, nil
	}
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//read the value from toml file


	//get URL from toml for pan
	lPanCheckurl := tomlconfig.GtomlConfigLoader.GetValueString("backoffice", "BackOfficeUrl")
	var lkey, ltype string
	// constrect the url based on ptype
	if strings.EqualFold(pType, "pan") {
		lval := tomlconfig.GtomlConfigLoader.GetValueString("backoffice", "panKey")
		lkey = "/?qc=" + lval
		ltype = tomlconfig.GtomlConfigLoader.GetValueString("backoffice", "type")
	} else if strings.EqualFold(pType, "EMAIL") {
		lval := tomlconfig.GtomlConfigLoader.GetValueString("backoffice", "emailId")
		lkey = "/?id=" + lval
		ltype = tomlconfig.GtomlConfigLoader.GetValueString("backoffice", "type")
	} else if strings.EqualFold(pType, "mobile") {
		lval := tomlconfig.GtomlConfigLoader.GetValueString("backoffice", "mobileId")
		lkey = "/?id=" + lval
		ltype = tomlconfig.GtomlConfigLoader.GetValueString("backoffice", "type")
	}

	lPanCheckurl = lPanCheckurl + lkey + "&typ=" + ltype + "&qp1=" + pValue
	//set header value
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)

	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lPanCheckurl, "GET", "", lHeaderArr, "digilockerapi.IssuedDocProcess")

	if lErr != nil {
		return false, helpers.ErrReturn(lErr)
	}
	var lBoffice []BofficeStruct
	lErr = json.Unmarshal([]byte(lResp), &lBoffice)
	if lErr != nil {
		return false, helpers.ErrReturn(lErr)
	}

	var lStatus string
	for _, bOfficeStatus := range lBoffice {
		lStatus = bOfficeStatus.Status
	}
	if strings.EqualFold(lStatus, "y") {
		return true, nil
	}
	pDebug.Log(helpers.Details, "sendto:", pType, "data:", pValue, "status:", lStatus)
	pDebug.Log(helpers.Statement, "IssuedDocProcess (-)")
	return false, nil
}
