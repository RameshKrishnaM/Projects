package ipvapi

import (
	"encoding/json"
	"errors"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"strings"
)

type ReGenTokenReqStruct struct {
	EntityId string `json:"entity_id"`
}

type ReGenerateTokenStruct struct {
	Response struct {
		CreatedAt string `json:"created_at"`
		UpdatedAt string `json:"updated_at"`
		TokenId   string `json:"id"`
		EntityID  string `json:"entity_id"`
		ValidTill string `json:"valid_till"`
	} `json:"response"`

	Session struct {
		Sid        string `json:"sid"`
		IsLoggedIn bool   `json:"is_logged_in"`
	} `json:"session"`
	Err_Detail string `json:"details"`
	Err_code   string `json:"code"`
	Err_Msg    string `json:"message"`
}

func ReGenTokenApiCall(pDebug *helpers.HelperStruct, pToken string) (lDigioTokenRec ReGenerateTokenStruct, lErr error) {
	pDebug.Log(helpers.Statement, "ReGenTokenApiCall (+)")
	var lDigioReqRec ReGenTokenReqStruct
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	lDigioReqRec.EntityId = pToken
	lByteinfo, lErr := json.Marshal(lDigioReqRec)
	if lErr != nil {
		return lDigioTokenRec, helpers.ErrReturn(lErr)
	}


	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "ReGenTokenURL")
	Secret_Key := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Secret_Key")
	Secret_Value := tomlconfig.GtomlConfigLoader.GetValueString("ipv", "Secret_Value")

	lHeaderRec.Key = "Authorization"
	lHeaderRec.Value = "Basic " + basicAuth(Secret_Key, Secret_Value)
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, "POST", string(lByteinfo), lHeaderArr, "digio_ReGenTokenApiCall")
	if lErr != nil {
		return lDigioTokenRec, helpers.ErrReturn(lErr)
	}

	lErr = json.Unmarshal([]byte(lResp), &lDigioTokenRec)
	if lErr != nil {
		return lDigioTokenRec, helpers.ErrReturn(lErr)
	}

	if !strings.EqualFold(lDigioTokenRec.Err_Msg, "") {
		return lDigioTokenRec, helpers.ErrReturn(errors.New(lDigioTokenRec.Err_Msg))
	}
	pDebug.Log(helpers.Details, "lDigioTokenRec", lResp)
	pDebug.Log(helpers.Statement, "ReGenTokenApiCall (-)")

	return lDigioTokenRec, nil
}
