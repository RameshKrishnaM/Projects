package bankinfo

import (
	"encoding/json"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fcs23pkg/util/pennydrop"
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
		var response ValidationResp
		var lBankDetailsStruct BankDetails
		var BankDetails pennydrop.BankDetails
		var PennyDropResult pennydrop.ValidationResp

		response.Status = common.ErrorCode
		body, _ := ioutil.ReadAll(r.Body)
		lDebug.Log(helpers.Details, "body", string(body))
		// IFSCCode := string(body)
		lerr := json.Unmarshal(body, &lBankDetailsStruct)
		lDebug.Log(helpers.Details, "lBankDetailsStruct", lBankDetailsStruct)
		lDebug.SetReference(lBankDetailsStruct.AccountNo)
		if lerr != nil {
			response.Status = common.ErrorCode
			lDebug.Log(helpers.Elog, "CPD01"+lerr.Error())
			response.ErrMsg = helpers.GetError_String("UnExpectedError:(bCPD01)", lerr.Error())
		} else {
			BankDetails.ClientId = lBankDetailsStruct.ClientId
			BankDetails.LoggedBy = lBankDetailsStruct.LoggedBy
			BankDetails.Name = lBankDetailsStruct.Name
			BankDetails.Email = lBankDetailsStruct.Email
			BankDetails.Phone = lBankDetailsStruct.Phone
			BankDetails.IFSC = lBankDetailsStruct.IFSC
			BankDetails.AccountNo = lBankDetailsStruct.AccountNo
			BankDetails.BankName = lBankDetailsStruct.BankName
			// BankDetails.OriginalSysId = lBankDetailsStruct.OriginalSysId
			BankDetails.OriginalSys = lBankDetailsStruct.OriginalSys

			PennyDropResult, lerr = pennydrop.PennyDropValidation(BankDetails)
			if lerr != nil {
				lDebug.Log(helpers.Elog, "CPD02"+lerr.Error())
				response.Status = common.ErrorCode
				response.ErrMsg = helpers.GetError_String("UnExpectedError:(CPD02)", lerr.Error())

			} else {
				response.IsCompleted = PennyDropResult.IsCompleted
				response.ValidateId = PennyDropResult.ValidateId
				response.AccountStatus = PennyDropResult.AccountStatus
				response.RegisterName = PennyDropResult.RegisterName
				response.Status = common.SuccessCode
				response.ErrMsg = ""
			}
		}
		data, lerr := json.Marshal(response)
		if lerr != nil {
			lDebug.Log(helpers.Elog, "CPD03"+lerr.Error())
			fmt.Fprint(w, helpers.GetError_String("Error taking data", lerr.Error()))
		} else {
			fmt.Fprint(w, string(data))
		}

	}
	lDebug.RemoveReference()
	lDebug.Log(helpers.Statement, "CheckPennyDrop (-)")
}
