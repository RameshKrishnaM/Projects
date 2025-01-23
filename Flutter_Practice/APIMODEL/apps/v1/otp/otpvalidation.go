package otp

import (
	"encoding/json"
	"errors"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

type OtpVerifyStruct struct {
	ID       string `json:"validateid"`
	Otp      string `json:"otp"`
	ClientID string `json:"clientid"`
}

//-----------------------------------------------------
// function exposed as api to Check the given otp is valid or not
// This method return the  data in json format
//-----------------------------------------------------
func ValidateOtp(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "PUT, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	w.WriteHeader(200)
	lDebug.Log(helpers.Statement, "ValidateOtp(+) ")

	if strings.EqualFold(r.Method, "PUT") {
		lErr := verifyflow(w, r, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "OVO01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("OVO01", "somthing is wrong please try again later"))
		}

	}
	lDebug.Log(helpers.Statement, "ValidateOtp(-) ")

}

func verifyflow(w http.ResponseWriter, r *http.Request, pDebug *helpers.HelperStruct) error {

	pDebug.Log(helpers.Statement, "verifyflow(+) ")

	var lOTPStatusRec OtpVerifyStruct
	// var response OtpVerifyOutputStruct
	// method to check whether the cookie is active between cookie created time and end time
	// Returns the clientId
	lBody, lErr := ioutil.ReadAll(r.Body)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "lBody :", string(lBody))

	//convert the input json into a structure variable
	lErr = json.Unmarshal(lBody, &lOTPStatusRec)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	if lOTPStatusRec.ID == "" {
		return helpers.ErrReturn(errors.New("ID IS EMPT"))
	}

	// Get the Given otp is valid or not
	var LoggedBy string
	if lOTPStatusRec.ClientID != "" {
		LoggedBy = common.GetLoggedBy(lOTPStatusRec.ClientID)
	} else {
		LoggedBy = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "ClientID")

	}
	pDebug.Log(helpers.Details, "lOTPStatusRec : ", lOTPStatusRec)

	lMsg, lErr1 := OtpValidation(lOTPStatusRec.ID, lOTPStatusRec.Otp, LoggedBy, pDebug)
	if lErr1 != nil {
		return helpers.ErrReturn(lErr1)
	} else if lMsg == "Y" {
		fmt.Fprint(w, helpers.GetMsg_String("S", "OTP Verify Successfully"))
	} else {
		fmt.Fprint(w, helpers.GetError_String("OVF01", "Invalid Otp"))
	}
	pDebug.Log(helpers.Statement, "verifyflow(-) ")

	return nil
}

//-----------------------------------------------------------------------------------
// function Check the  given otp is valid or not.
// if otp is valid & update the otp vaalidated column
//----------------------------------------------------------------------------------
func OtpValidation(pID string, pOtp string, pLoggedBy string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "OtpValidation(+) ")

	pDebug.Log(helpers.Details, "OTP Id:", pID)

	pDebug.Log(helpers.Details, "OTP :", pOtp)

	lMsg, lErr := IsOtpValid(pID, pOtp, pDebug)
	pDebug.Log(helpers.Details, "msg", lMsg)
	if lErr != nil {

		return "", helpers.ErrReturn(lErr)
	}
	if lMsg == "Y" {
		lErr := UpdateValidated(pID, pLoggedBy, pDebug)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "OtpValidation(-) ")

	return lMsg, nil

}

//------------------------------------------------
// function Check the given otp is valid or not
//  returns the Validated column in otplog table.
//-------------------------------------------------
func IsOtpValid(pID string, pOtp string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "IsOtpValid(+)")
	var msg string

	sqlString := `select (case when otp = ? then 'Y' else 'N' end) validate
							from otplog o 
						where id= ?`
	rows, err := ftdb.MariaEKYCPRD_GDB.Query(sqlString, pOtp, pID)
	if err != nil {
		return "", helpers.ErrReturn(err)

	}
	defer rows.Close()
	for rows.Next() {
		err := rows.Scan(&msg)
		if err != nil {
			return "", helpers.ErrReturn(err)
		}
	}
	pDebug.Log(helpers.Statement, "IsOtpValid(-)")

	return msg, nil
}

//--------------------------------------------------
// function update the validated column in otplog table,
// for a given id.
//--------------------------------------------------
func UpdateValidated(pid string, pLoggedBy string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "UpdateValidated(+)")

	coreString := `update  otplog set validated='Y', updatedBy=?, updatedDate=NOW() where id=?`

	_, lErr := ftdb.MariaEKYCPRD_GDB.Exec(coreString, pLoggedBy, pid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "Updated Successfully")

	pDebug.Log(helpers.Statement, "UpdateValidated(-)")

	return nil
}
