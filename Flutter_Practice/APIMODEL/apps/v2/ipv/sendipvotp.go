package ipv

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

type IPVotpStruct struct {
	EncEmail     string `json:"encemail"`
	EncMobile    string `json:"encmobile"`
	InsertedID   string `json:"validateid"`
	AttemptCount int    `json:"attemptcount"`
	Status       string `json:"status"`
}

type IPVOtpUserStruct struct {
	IPVSid       string `json:"ipvsid"`
	OTPFlag      string `json:"otpflag"`
	OtpType      string `json:"otptype"`
	UserOtpMedia string `json:"usermedia"`
}

func SendIpvOtp(w http.ResponseWriter, r *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "SendIpvOtp (+)")

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "ipvsid,otpflag,Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold(r.Method, "POST") {
		lDebug.Log(helpers.Details, "r.body", r.Body)
		var lIPVOtpUserRec IPVOtpUserStruct
		lBodyData, lErr := ioutil.ReadAll(r.Body)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL01", "Somthing is wrong please try again later"))
			return
		}
		lErr = json.Unmarshal(lBodyData, &lIPVOtpUserRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL02", "Somthing is wrong please try again later"))
			return
		}
		if strings.EqualFold(lIPVOtpUserRec.IPVSid, "") || strings.EqualFold(lIPVOtpUserRec.OTPFlag, "") || strings.EqualFold(lIPVOtpUserRec.OtpType, "") || strings.EqualFold(lIPVOtpUserRec.UserOtpMedia, "") {
			lDebug.Log(helpers.Elog, "ipv otp user data is missing")
			fmt.Fprint(w, helpers.GetError_String("", "Somthing is wrong please try again later"))
			return
		}

		if !strings.EqualFold(lIPVOtpUserRec.OTPFlag, "Y") {

			lForWordErr, lErr := IPVLinkCheck(lDebug, "update", lIPVOtpUserRec.IPVSid)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "GIL04", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("GIL04", "Somthing is wrong please try again later"))
				return
			}
			if lForWordErr != nil {
				lDebug.Log(helpers.Elog, "Expire", lForWordErr.Error())
				fmt.Fprint(w, helpers.GetError_String("Expire", helpers.ErrPrint(lForWordErr)))
				return
			}
		}

		lUid, lErr := IPVRequestID(lDebug, lIPVOtpUserRec.IPVSid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL05", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL05", "Somthing is wrong please try again later"))
			return
		}

		lErr = UpdateIPVLinkUse(lDebug, lIPVOtpUserRec.IPVSid, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL06", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL06", "Somthing is wrong please try again later"))
			return
		}

		lUserBaseInfo, lErr := CheckIPVUserData(lDebug, lIPVOtpUserRec.OtpType, lIPVOtpUserRec.UserOtpMedia, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL07", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL07", "Somthing is wrong please try again later"))
			return
		}
		if strings.EqualFold(lUserBaseInfo.UserName, "") {
			lDebug.Log(helpers.Elog, "GIL08", "given media will not user request id '", lUid, "' media :", lIPVOtpUserRec.UserOtpMedia)
			fmt.Fprint(w, helpers.GetError_String("GIL08", "the given is not registered "+lIPVOtpUserRec.OtpType+" :"+lIPVOtpUserRec.UserOtpMedia))
			return
		}

		lResp, lErr := SendOTPInit(lDebug, lUserBaseInfo, r)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL09", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL09", helpers.ErrPrint(lErr)))
			return
		}
		lRespJson, lErr := json.Marshal(lResp)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIL10", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIL10", "Somthing is wrong please try again later"))
			return
		}
		fmt.Fprint(w, string(lRespJson))

		lDebug.Log(helpers.Statement, "SendIpvOtp (-)")

	}
}

func GetUserData(pDebug *helpers.HelperStruct, pUid string) (lIPVUrlRec IPVUrlStruct, lErr error) {
	pDebug.Log(helpers.Statement, "GetUserData (+)")

	lSelectQry := `select er.Phone,er.Email,er.Name_As_Per_Pan from ekyc_request er where er.Uid = ?`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lSelectQry, pUid)
	if lErr != nil {
		return lIPVUrlRec, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()

	for lRows.Next() {
		lErr := lRows.Scan(&lIPVUrlRec.Mobile, &lIPVUrlRec.Email, &lIPVUrlRec.UserName)
		if lErr != nil {
			return lIPVUrlRec, helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "GetUserData (-)")
	return lIPVUrlRec, nil
}

func CheckIPVUserData(pDebug *helpers.HelperStruct, pIPVType, pIPVMedia, pUid string) (lIPVUrlRec IPVUrlStruct, lErr error) {
	pDebug.Log(helpers.Statement, "CheckIPVUserData (+)")

	lSelectQry := `select er.Phone,er.Email,er.Name_As_Per_Pan from ekyc_request er where er.Uid = ?`
	lIPVUrlRec.OtpType = pIPVType
	if strings.EqualFold(pIPVType, "Mobile") {
		lSelectQry += " and er.Phone=?"
	} else {
		lSelectQry += " and er.Email=?"
	}
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lSelectQry, pUid, pIPVMedia)
	if lErr != nil {
		return lIPVUrlRec, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()

	for lRows.Next() {
		lErr := lRows.Scan(&lIPVUrlRec.Mobile, &lIPVUrlRec.Email, &lIPVUrlRec.UserName)
		if lErr != nil {
			return lIPVUrlRec, helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "CheckIPVUserData (-)")
	return lIPVUrlRec, nil
}

func SendOTPInit(pDebug *helpers.HelperStruct, userdataRec IPVUrlStruct, pReq *http.Request) (lResponseRec IPVotpStruct, lErr error) {
	pDebug.Log(helpers.Statement, "SendOTPInit (+)")


	if userdataRec.ClientID == "" {
		userdataRec.ClientID = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "ClientID")
	}
	if userdataRec.Process == "" {
		userdataRec.Process = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Process")
	}

	lAttemptCount, lErr := otp.OtpCount(fmt.Sprintf("%s@@%s", userdataRec.Mobile, userdataRec.Email), userdataRec.OtpType, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lResponseRec, helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))

	}

	lCount := tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "Count")
	count, lErr := strconv.Atoi(lCount)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lResponseRec, helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))

	}

	if lAttemptCount >= count {
		pDebug.Log(helpers.Details, "responseRec.AttemptCount :", lAttemptCount)
		pDebug.Log(helpers.Elog, " You have reached maximum no. of attempts to generate OTP for the date, please try later")
		return lResponseRec, helpers.ErrReturn(errors.New(" You have reached maximum no. of attempts to generate OTP for the date, please try later"))

	}

	if lAttemptCount < count {

		lResponseRec, lErr = SendOtp(userdataRec, pReq, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return lResponseRec, helpers.ErrReturn(errors.New(" Somthing is wrong try again some time"))

		}
		pDebug.Log(helpers.Details, "response.InsertedID", lResponseRec)

		lResponseRec.AttemptCount = lAttemptCount + 1
		lResponseRec.Status = common.SuccessCode

	}

	pDebug.Log(helpers.Statement, "SendOTPInit (-)")
	return lResponseRec, nil

}
