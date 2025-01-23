package otp

import (
	"encoding/json"
	"errors"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"
	"strings"
)

type UserdataStruct struct {
	Username   string `json:"clientname"`
	Sendto     string `json:"sendto"`
	Sendtotype string `json:"sendtotype"`
	ClientID   string `json:"clientid"`
	Process    string `json:"process"`
}

type successOTPStruct struct {
	Encryptedval string `json:"encryptedval"`
	InsertedID   string `json:"validateid"`
	AttemptCount int    `json:"attemptcount"`
	Status       string `json:"status"`
}

/*
Purpose : This method is used to insert the data in otplog db and send OTP to Responsive given device
Arguments :N/A
===========
On Success:
===========
OTP sender successfully and otp meta data in DB
===========
On Error:
===========
"Error":
Author : Saravanan
Date : 17-June-2023
*/

func GetUserData(w http.ResponseWriter, r *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetUserData (+)")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "PUT, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	w.WriteHeader(200)
	if strings.EqualFold(r.Method, "PUT") {
		lData, lErr := VerifyFlow(w, r, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GUD01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GUD01", helpers.ErrPrint(lErr)))
		} else {
			fmt.Fprint(w, lData)
		}

		lDebug.Log(helpers.Statement, "GetUserData (-)")

	}
}

/*
Purpose : This method is used to insert the data in otplog db and send OTP to Responsive given device
Arguments :N/A
===========
On Success:
===========

===========
On Error:
===========
"Error":
Author : Saravanan
Date : 17-June-2023
*/

func VerifyFlow(w http.ResponseWriter, r *http.Request, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "VerifyFlow (+)")

	var userdataRec UserdataStruct
	// var lGivenName string
	lBody, lErr := ioutil.ReadAll(r.Body)
	pDebug.Log(helpers.Details, string(lBody), "lBody")

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))

	}
	defer r.Body.Close()

	// lDb2, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return "", helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))
	// }
	lErr = json.Unmarshal(lBody, &userdataRec)

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))

	}
	pDebug.SetReference(userdataRec.Username)
	pDebug.Log(helpers.Details, "requestInput", userdataRec)

	if userdataRec.Sendto == "" {
		pDebug.Log(helpers.Elog, helpers.ErrReturn(errors.New(userdataRec.Sendtotype+" is missing")))
		return "", helpers.ErrReturn(errors.New(userdataRec.Sendtotype + " is missing"))
	}
	// if strings.EqualFold(userdataRec.Sendtotype, "mobile") {
	// 	lCorestring := `SELECT Given_Name
	// 	FROM ekyc_request
	// 	WHERE Phone = ?`

	// 	// Execute the query for each lUid
	// 	lRows, lErr := lDb2.Query(lCorestring, userdataRec.Sendto)
	// 	if lErr != nil {
	// 		pDebug.Log(helpers.Elog, lErr.Error())
	// 		return "", helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))
	// 	} else {
	// 		for lRows.Next() {
	// 			lErr := lRows.Scan(&lGivenName)
	// 			if lErr != nil {
	// 				pDebug.Log(helpers.Elog, lErr.Error())
	// 				return "", helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))
	// 			}
	// 		}
	// 	}
	// 	if !strings.EqualFold(lGivenName, userdataRec.Username) && lGivenName != "" {
	// 		return "", helpers.ErrReturn(errors.New(" Name was not matched with previous record, Please verify"))
	// 	}
	// }
	responseRec, lErr := SendOTPInit(pDebug, userdataRec, r)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", helpers.ErrReturn(lErr)

	}

	lData, lErr := json.Marshal(responseRec)

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))
	}
	pDebug.Log(helpers.Statement, "VerifyFlow (-)")

	return string(lData), nil
}

func SendOTPInit(pDebug *helpers.HelperStruct, userdataRec UserdataStruct, pReq *http.Request) (responseRec successOTPStruct, lErr error) {
	pDebug.Log(helpers.Statement, "SendOTPInit (+)")
	//open a lDb connection


	if userdataRec.ClientID == "" {
		userdataRec.ClientID = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "ClientID")
	}
	if userdataRec.Process == "" {
		userdataRec.Process = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Process")
	}

	// Get the count of a generated otp
	// for the given Client
	lAttemptCount, lErr := OtpCount(userdataRec.Sendto, userdataRec.Sendtotype, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return responseRec, helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))

	}

	lCount := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Count")
	count, lErr := strconv.Atoi(lCount)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return responseRec, helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))

	}

	if lAttemptCount < count {

		Encryptedval, InsertedID, lErr := SendOtp(userdataRec, pReq, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return responseRec, helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))

		}
		pDebug.Log(helpers.Details, "response.InsertedID", InsertedID)
		if InsertedID != "" {
			// fmt.Println(responseRec.Encryptedval, "-----------", responseRec.InsertedID)
			responseRec.InsertedID = InsertedID
			responseRec.Encryptedval = Encryptedval
			responseRec.AttemptCount = lAttemptCount + 1
			responseRec.Status = common.SuccessCode
		} else {
			responseRec.Status = common.ErrorCode
		}
	} else if lAttemptCount >= count {
		responseRec.Status = common.ErrorCode
		responseRec.AttemptCount = lAttemptCount
		pDebug.Log(helpers.Details, "responseRec.AttemptCount :", responseRec.AttemptCount)
		pDebug.Log(helpers.Elog, "try more then give times")

		return responseRec, helpers.ErrReturn(errors.New(" try more then give times"))

	}

	pDebug.Log(helpers.Statement, "SendOTPInit (-)")
	return responseRec, nil

}
