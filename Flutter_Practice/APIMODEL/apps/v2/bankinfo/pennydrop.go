package bankinfo

import (
	"encoding/json"
	"fcs23pkg/apps/v2/bankinfo/model"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fmt"
	"io/ioutil"
	"net/http"
)

type BankDetails struct {
	ClientId      string `json:"clientId"`
	LoggedBy      string `json:"loggedBy"`
	Name          string `json:"name"`
	Email         string `json:"email"`
	Phone         string `json:"phone"`
	IFSC          string `json:"iFSC"`
	AccountNo     string `json:"accountNo"`
	BankName      string `json:"bankName"`
	OriginalSysId string `json:"originalSysId"`
	OriginalSys   string `json:"originalSys"`
}

type ValidationResp struct {
	IsCompleted   string `json:"IsCompleted"`
	ValidateId    string `json:"ValidateId"`
	AccountStatus string `json:"AccountStatus"`
	RegisterName  string `json:"RegisterName"`
	Status        string `json:"status"`
	ErrMsg        string `json:"errMsg"`
}

func CheckPennyDrop(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "CheckPennyDrop (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "PUT,OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")
	(w).Header().Set("Content-Type", "application/json")

	//w.WriteHeader(200)
	//log.Println("GetIFSCdetails(+) " + r.Method)
	switch r.Method {
	case "PUT":
		var lResponse ValidationResp
		var lBankDetailsStruct BankDetails
		var lBankDetails model.BankDetails
		var lPennyDropResult model.PennyDropRespStruct

		lResponse.Status = common.ErrorCode
		lBody, _ := ioutil.ReadAll(r.Body)
		lDebug.Log(helpers.Details, "body", string(lBody))
		// IFSCCode := string(body)
		lErr := json.Unmarshal(lBody, &lBankDetailsStruct)
		lDebug.Log(helpers.Details, "lBankDetailsStruct", lBankDetailsStruct)
		lDebug.SetReference(lBankDetailsStruct.AccountNo)
		if lErr != nil {
			lResponse.Status = common.ErrorCode
			lDebug.Log(helpers.Elog, "CPD01"+lErr.Error())
			lResponse.ErrMsg = helpers.GetError_String("UnExpectedError:(bCPD01)", lErr.Error())
		} else {
			lBankDetails.ClientId = lBankDetailsStruct.ClientId
			lBankDetails.LoggedBy = lBankDetailsStruct.LoggedBy
			lBankDetails.Name = lBankDetailsStruct.Name
			lBankDetails.Email = lBankDetailsStruct.Email
			lBankDetails.Phone = lBankDetailsStruct.Phone
			lBankDetails.IFSC = lBankDetailsStruct.IFSC
			lBankDetails.AccountNo = lBankDetailsStruct.AccountNo
			lBankDetails.BankName = lBankDetailsStruct.BankName
			// BankDetails.OriginalSysId = lBankDetailsStruct.OriginalSysId
			lBankDetails.OriginalSys = lBankDetailsStruct.OriginalSys

			lPennyDropResult, lErr = PennyDropValidation(lDebug, lBankDetails)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "CPD02"+lErr.Error())
				lResponse.Status = common.ErrorCode
				lResponse.ErrMsg = helpers.GetError_String("UnExpectedError:(CPD02)", lErr.Error())

			} else {
				lResponse.IsCompleted = lPennyDropResult.Data.IsCompleted
				lResponse.ValidateId = lPennyDropResult.Data.ValidateId
				lResponse.AccountStatus = lPennyDropResult.Data.AccountStatus
				lResponse.RegisterName = lPennyDropResult.Data.RegisterName
				lResponse.Status = common.SuccessCode
				lResponse.ErrMsg = ""
			}
		}
		lData, lErr := json.Marshal(lResponse)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "CPD03"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("Error taking data", lErr.Error()))
		} else {
			fmt.Fprint(w, string(lData))
		}

	}
	lDebug.RemoveReference()
	lDebug.Log(helpers.Statement, "CheckPennyDrop (-)")
}
