package digilockerapicall

import (
	"encoding/json"
	"errors"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"fmt"
	"strings"
)

type URlStruct struct {
	Status string `json:"status"`
	URL    string `json:"url"`
	Error  string `json:"msg"`
}

func GetRedirectUrl(pDebug *helpers.HelperStruct, lAppName string, pReqID int) (lUrl string, lErr error) {

	pDebug.Log(helpers.Statement, "GetRedirectUrl (+)")
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	var lUrlRec URlStruct
	//read the value from toml file


	//get URL from toml
	lBaseUrl := tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "BaseUrl")
	lRedirectUrl := tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "RedirectUrl")
	//set header value
	lHeaderRec.Key = "Appname"
	lHeaderRec.Value = lAppName
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "ReqID"
	lHeaderRec.Value = fmt.Sprintf("%d", pReqID)
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)

	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lBaseUrl+lRedirectUrl, "GET", "", lHeaderArr, "digilockerapi.GetRedirectUrl")

	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	lErr = json.Unmarshal([]byte(lResp), &lUrlRec)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	if !strings.EqualFold(lUrlRec.Status, "S") {
		return "", helpers.ErrReturn(errors.New(lUrlRec.Error))
	}

	pDebug.Log(helpers.Statement, "GetRedirectUrl (-)")
	return lUrlRec.URL, nil
}
