package otp

import (
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/mobile"
	"fcs23pkg/tomlconfig"
	"net/http"
)

func SendOtptoMobile(r *http.Request, lClientId string, lParam1 string, lMobileNo string, lReqSource string, lTemplateCode string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "SendOtptoMobile(+)")

	pDebug.Log(helpers.Details, lClientId, lParam1, lMobileNo)


	var lSmsRec mobile.SmsMsgTypeStruct
	lSmsRec.ClientId = lClientId
	lSmsRec.Param1 = lParam1
	lSmsRec.PhoneNumber = lMobileNo
	lSmsRec.TemplateCode = lTemplateCode
	lSmsRec.SentFrom = tomlconfig.GtomlConfigLoader.GetValueString("otpconfig", "SentFrom")

	lErr := mobile.SmsMessage(r, lSmsRec, lReqSource, pDebug)
	if lErr != nil {

		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "SendOtptoMobile(-)")

	return nil
}
