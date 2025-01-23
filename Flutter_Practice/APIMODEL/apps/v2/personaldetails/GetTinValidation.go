package personaldetails

import (
	"encoding/json"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

/* Response :
===========
On Success:
===========
{
"Status": "Success",
ErrMsg": "",
"pattern":"regexp",
"countryname":"countryname",
"formatvalue":"sample value"
}
===========
On Error:
===========
{
"Status": "Error",
ErrMsg": error
}
Author : Logeshkumar
Date : 29-Augest-2024
*/
// Response structure for the API
type TinValidateReqStruct struct {
	Code        string `json:"code"`
	CountryCode string `json:"countrycode"`
}

// Response structure for the API
type TinValidateRespStruct struct {
	Pattern      string `json:"pattern"`
	CountryName  string `json:"countryname"`
	SampleFormat string `json:"formatvalue"`
	ErrMsg       string `json:"msg"`
	Status       string `json:"status"`
}

//TinValidatePattern API is used to fetch status and pattern and sample value based on select the country code
func TinValidatePattern(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "InsertPersonalDetails (+)")
	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")
	if strings.EqualFold(r.Method, "POST") {
		lDebug.Log(helpers.Statement, "TinValidatePattern (+)")

		var lReq TinValidateReqStruct
		var lResp TinValidateRespStruct

		lReqData, lErr := ioutil.ReadAll(r.Body)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "TVP001", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("TVP001", "Something Went Wrong, Please Try again after sometime "))
			return
		}
		lErr = json.Unmarshal(lReqData, &lReq)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "TVP002", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("TVP002", "Something Went Wrong, Please Try again after sometime "))
			return
		}

		lResp, lErr = FetchTinPattern(lDebug, lReq.CountryCode, lReq.Code)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "TVP004", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("TVP004", "Something Went Wrong, Please Try again after sometime "))
			return
		}
		lResp.Status = common.SuccessCode

		lRespData, lErr := json.Marshal(lResp)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "TVP005", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("TVP005", "Something Went Wrong, Please Try again after sometime "))
			return
		}
		fmt.Fprint(w, string(lRespData))
		lDebug.Log(helpers.Statement, "TinValidatePattern (-)")
	}
}

//FetchTinPattern method used to fetch the descriptioon ,pattern and sample value in lookup details
func FetchTinPattern(pDebug *helpers.HelperStruct, pCountryCode string, pCode string) (lResp TinValidateRespStruct, lErr error) {
	pDebug.Log(helpers.Statement, "FetchTinPattern (+)")

	lCoreString := `select NVL(ld.description, ''), NVL(ld.Attr1, ''), NVL(ld.Attr2, '') from lookup_details ld where ld.Code = ? and headerid = (select lh.id from lookup_header lh where lh.Code = ?)`

	lResult, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pCountryCode, pCode)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "FTP001: ", lErr.Error())
		return lResp, helpers.ErrReturn(lErr)
	}
	defer lResult.Close() // Ensure result set is closed after query execution

	for lResult.Next() {
		lErr = lResult.Scan(&lResp.CountryName, &lResp.Pattern, &lResp.SampleFormat)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "FTP002", lErr.Error())
			return lResp, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "FetchTinPattern (-)")
	return lResp, nil
}
