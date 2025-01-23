package ipvapi

import (
	"encoding/json"
	"errors"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"fmt"
	"strings"
)

type ReCaptureReqStruct struct {
	ActionIdArr    []string `json:"action_ids"`
	Reason         string   `json:"reason"`
	NodifyCustomer bool     `json:"notify_customer"`
}

type ReCaptureRespStruct struct {
	IPVReqID           string `json:"id"`
	CreatedAt          string `json:"created_at"`
	UpdatedAt          string `json:"updated_at"`
	ExpireInDays       int    `json:"expire_in_days"`
	RequestStatus      string `json:"status"`
	CustomerIdentifier string `json:"customer_identifier"`
	ClientReferenceId  string `json:"client_reference_id"`
	ReferenceId        string `json:"reference_id"`
	TransactionUId     string `json:"transaction_id"`
	CustomerName       string `json:"customer_name"`
	ShowSteps          bool   `json:"show_steps"`
	ShowSkippedSteps   bool   `json:"show_skipped_steps"`
	Err_Detail         string `json:"details"`
	Err_code           string `json:"code"`
	Err_Msg            string `json:"message"`
}

func ReCaptureApiCall(pDebug *helpers.HelperStruct, pSubActionRec ReCaptureReqStruct, pId string) (lDigioTokenRec ReCaptureRespStruct, lErr error) {
	pDebug.Log(helpers.Statement, "ReCaptureApiCall (+)")
	var lHeaderArr []apiUtil.HeaderDetails
	var lHeaderRec apiUtil.HeaderDetails
	lByteinfo, lErr := json.Marshal(pSubActionRec)
	if lErr != nil {
		return lDigioTokenRec, helpers.ErrReturn(lErr)
	}

	lUrl := fmt.Sprintf("%v/%v/reattempt", tomlconfig.GtomlConfigLoader.GetValueString("ipv", "CreateURL"), pId)
	Secret_Key := tomlconfig.GtomlConfigLoader.GetValueString("ipv",
		"Secret_Key")
	Secret_Value := tomlconfig.GtomlConfigLoader.GetValueString("ipv",
		"Secret_Value")

	lHeaderRec.Key = "Authorization"
	lHeaderRec.Value = "Basic " + basicAuth(Secret_Key, Secret_Value)
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lHeaderRec.Key = "Content-Type"
	lHeaderRec.Value = "application/json"
	lHeaderArr = append(lHeaderArr, lHeaderRec)
	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, "POST", string(lByteinfo), lHeaderArr, "digio_ReCaptureApiCall")
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
	pDebug.Log(helpers.Details, "ReCaptureApiCall", lResp)
	pDebug.Log(helpers.Statement, "ReCaptureApiCall (-)")

	return lDigioTokenRec, nil
}
