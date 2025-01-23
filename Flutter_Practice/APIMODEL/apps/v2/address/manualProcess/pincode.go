package manualProcess

import (
	"encoding/json"
	// "fcs23pkg/common"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"

	// "io/ioutil"
	"net/http"
)

type Response struct {
	State string `json:"state"`
	City  string `json:"city"`
	// Pincode string `json:"pincode"`
}
type Result struct {
	Resp   Response `json:"resp"`
	ErrMsg string   `json:"errmsg"`
	Status string   `json:"status"`
}

/*
Purpose : This method is used to fetch the state and city
Request : pincode
Response :
===========
On Success:
===========
resp: {state: 'Tamil Nadu', city: 'CUDDALORE', pincode: '606105'}
status: "S"
===========
On Error:
===========
"Error":
Author : Sowmiya L
Date : 02-June-2023
*/
func Pincode(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "pincode,Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	debug := new(helpers.HelperStruct)
	debug.SetUid(r)
	debug.Log(helpers.Statement, "Pincode (+)")

	if r.Method == "GET" {
		var lResp Response
		var lresu Result
		// lresu.Status = "S"

		lPincode := r.Header.Get("pincode")
		debug.SetReference("lPincode" + lPincode)
		debug.Log(helpers.Details, "lPincode", lPincode)

		lCoreString := `select nvl(xpd.StateName,"") ,nvl(xpd.District,"")
					from xx_pincode_details xpd
					where Pincode = ?`
		lRows, lErr := ftdb.MariaEKYCPRD_GDB.Query(lCoreString, lPincode)
		if lErr != nil {
			debug.Log(helpers.Elog, lErr.Error())
		}
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lResp.State, &lResp.City)
			if lErr != nil {
				debug.Log(helpers.Elog, lErr.Error())
			} else {
				lresu.Resp = lResp
			}
		}

		lresu.Status = common.SuccessCode
		if lresu.Resp.City == "" || lresu.Resp.State == "" {
			fmt.Fprint(w, helpers.GetError_String("E", "Please enter valid Pincode"))
		} else {
			lDatas, lErr := json.Marshal(lresu)
			debug.Log(helpers.Details, "lDatas", string(lDatas))
			if lErr != nil {
				debug.Log(helpers.Elog, lErr.Error())
			} else {
				fmt.Fprint(w, string(lDatas))
			}
			debug.Log(helpers.Statement, "Pincode (-)")
		}
	}
}
