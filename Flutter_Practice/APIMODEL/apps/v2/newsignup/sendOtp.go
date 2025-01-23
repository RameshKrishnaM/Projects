package newsignup

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v2/otp"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"
	"strings"
)

type successOTPStruct struct {
	Encryptedval string `json:"encryptedval"`
	InsertedID   string `json:"validateid"`
	AttemptCount int    `json:"attemptcount"`
	TempUid      string `json:"tempUid"`
	Status       string `json:"status"`
}

func SendOtp(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "SendOtp (+)")

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold("POST", r.Method) {
		var userdataRec otp.UserdataStruct

		lBody, lErr := ioutil.ReadAll(r.Body)
		lDebug.Log(helpers.Details, string(lBody), "lBody")

		if lErr != nil {
			lDebug.Log(helpers.Elog, "SED01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("SED01", helpers.ErrPrint(lErr)))
			return
		}
		defer r.Body.Close()

		lErr = json.Unmarshal(lBody, &userdataRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "SED02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("SED02", helpers.ErrPrint(lErr)))
			return
		}
		fmt.Println("UserDetails", userdataRec)
		lRespData, lErr := ValidateOtpRequest(lDebug, userdataRec, r)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "SED03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("SED03", helpers.ErrPrint(lErr)))
			return
		}

		lData, lErr := json.Marshal(lRespData)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "SED04", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("SED04", helpers.ErrPrint(lErr)))
			return
		}

		fmt.Fprint(w, string(lData))
	}
	lDebug.Log(helpers.Statement, "SendOtp (-)")
}

func ValidateOtpRequest(pDebug *helpers.HelperStruct, pUserdataRec otp.UserdataStruct, r *http.Request) (pResp successOTPStruct, pErr error) {
	pDebug.Log(helpers.Statement, "ValidateOtpRequest (+)")

	pDebug.SetReference(pUserdataRec.Username)
	pDebug.Log(helpers.Details, "requestInput", pUserdataRec)

	if pUserdataRec.Sendto == "" {
		pDebug.Log(helpers.Elog, helpers.ErrReturn(errors.New(pUserdataRec.Sendtotype+" is missing")))
		return pResp, helpers.ErrReturn(errors.New(pUserdataRec.Sendtotype + " is missing"))
	}

	pUserdataRec.ClientID, pUserdataRec.Process = common.EKYCAppName, common.EKYCAppName

	lAttemptCount, lErr := OtpCount(pDebug, pUserdataRec.Sendto, pUserdataRec.Sendtotype)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return pResp, helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))

	}

	lCount := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Count")
	count, lErr := strconv.Atoi(lCount)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return pResp, helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))

	}

	pDebug.Log(helpers.Details, "lAttemptCount => ", lAttemptCount, "  lCount =>", lCount)

	if lAttemptCount >= count {
		pResp.Status = common.ErrorCode
		pResp.AttemptCount = lAttemptCount

		lCustomErr := "you have reached maximum number of attempts for the day, please try again later"

		pDebug.Log(helpers.Elog, lCustomErr)
		return pResp, helpers.ErrReturn(errors.New(lCustomErr))
	}

	if lAttemptCount < count {

		Encryptedval, InsertedID, lErr := otp.SendOtp(pUserdataRec, r, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return pResp, helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))

		}
		pDebug.Log(helpers.Details, "response.InsertedID", InsertedID)
		if InsertedID != "" {
			pResp.InsertedID = InsertedID
			pResp.Encryptedval = Encryptedval
			pResp.AttemptCount = lAttemptCount + 1
			pResp.Status = common.SuccessCode

		} else {
			pDebug.Log(helpers.Elog, "Somthing is wrong try again some time")
			return pResp, helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))

		}
	}

	pDebug.Log(helpers.Statement, "ValidateOtpRequest (-)")

	return pResp, nil
}

func OtpCount(pDebug *helpers.HelperStruct, pTypetosend string, pType string) (int, error) {
	pDebug.Log(helpers.Statement, "OtpCount (+)")

	var lCount int

	lCorestring := ` SELECT COUNT(*) FROM otplog o WHERE o.type = ?	and sentTo = ?	and createdDate >= CURDATE()`

	lRows, lErr := ftdb.MariaEKYCPRD_GDB.Query(lCorestring, pType, pTypetosend)
	if lErr != nil {
		return lCount, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lCount)
		if lErr != nil {
			return lCount, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Details, "pTypetosend =>", pTypetosend, "  pType => ", pType, "  otpcount =>", lCount)

	pDebug.Log(helpers.Statement, "OtpCount (-)")
	return lCount, nil
}
