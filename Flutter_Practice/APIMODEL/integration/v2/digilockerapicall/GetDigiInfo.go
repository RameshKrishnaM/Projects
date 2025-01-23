package digilockerapicall

import (
	"encoding/json"
	"errors"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"strings"
)

type DigiInfoStruct struct {
	Status         string            `json:"status"`
	Error          string            `json:"msg"`
	PERAddress1    string            `json:"perAdrs1"`
	PERAddress2    string            `json:"perAdrs2"`
	PERAddress3    string            `json:"perAdrs3"`
	PERCity        string            `json:"perCity"`
	PERState       string            `json:"perState"`
	PERCountry     string            `json:"perCountry"`
	PERPincode     string            `json:"perPincode"`
	MaskedAatharNo string            `json:"aadharno"`
	Gender         string            `json:"gender"`
	Name           string            `json:"name"`
	DOB            string            `json:"dob"`
	DocIDArr       []FileDocIDstruct `json:"docids"`
}

type FileDocIDstruct struct {
	FileKey string `json:"filekey"`
	DocID   string `json:"docid"`
}

func GetDigilockerInfo(pDebug *helpers.HelperStruct, pDigiId string) (lDigiInfoRec DigiInfoStruct, lErr error) {

	pDebug.Log(helpers.Statement, "GetDigilockerInfo (+)")
	//create a array to carry the header value
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	//read the value from toml file


	//get URL from toml
	lBaseUrl := tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "BaseUrl")
	lDigiIdUrl := tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "DigilockerInfoUrl")
	//set header value
	lHeaderRec.Key = "DigiID"
	lHeaderRec.Value = pDigiId
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json; charset=UTF-8"
	lHeaderArr = append(lHeaderArr, lHeaderRec)

	pDebug.Log(helpers.Details, "headerArr :", lHeaderArr)

	//call the api to given URL
	lResp, lErr := apiUtil.Api_call(pDebug, lBaseUrl+lDigiIdUrl, "GET", "", lHeaderArr, "digilockerapi.GetDigilockerInfo")

	if lErr != nil {
		return lDigiInfoRec, helpers.ErrReturn(lErr)
	}

	lErr = json.Unmarshal([]byte(lResp), &lDigiInfoRec)
	if lErr != nil {
		return lDigiInfoRec, helpers.ErrReturn(lErr)
	}

	if !strings.EqualFold(lDigiInfoRec.Status, "S") {
		return lDigiInfoRec, helpers.ErrReturn(errors.New(lDigiInfoRec.Error))
	}

	pDebug.Log(helpers.Statement, "GetDigilockerInfo (-)")
	return lDigiInfoRec, nil
}
