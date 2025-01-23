package esign

import (
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
)

// type checkEsignResp struct {
// 	DocId  string `json:"docId"`
// 	Status string `json:"status"`
// 	ErrMsg string `json:"errmsg"`
// }

func CheckEsigneCompleted(w http.ResponseWriter, r *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "  PUT, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	w.WriteHeader(200)

	lDebug.Log(helpers.Statement, "CheckEsigneCompleted (+)")

	if r.Method == "PUT" {

		// var lResp checkEsignResp

		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "CEC01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("E", "Something went wrong. Please try again later."))
			return
		}
		if lUid != "" {

			lDocStatus, lErr := checkIsDocumentSigned(lUid, lDebug)
			lDebug.Log(helpers.Details, "****lDocStatus*******", lDocStatus)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "CEC03"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("E", "Something went wrong. Please try again later."))
				return
			} else {
				if lDocStatus == "Y" {
					fmt.Fprint(w, helpers.GetMsg_String("S", "Esign Sucessfully Completed"))
					return
					// } else if lDocStatus == "N" {
					// 	lResp.Status = "A"
				}
			}

		}

		// lData, lErr := json.Marshal(lResp)
		// if lErr != nil {
		// 	fmt.Fprint(w, helpers.GetError_String("E", "Something went wrong"))
		// } else {
		// 	fmt.Fprint(w, string(lData))
		// }
	}
	lDebug.Log(helpers.Statement, "CheckEsigneCompleted (-)")
}

// func ChkEsignCompleted(pRequestId string, pDebug *helpers.HelperStruct) (string, error) {
// 	pDebug.Log(helpers.Statement, "ChkEsignCompleted (+)")

// 	var lDocId string

// 	lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
// 	if lErr != nil {
// 		helpers.ErrReturn(lErr)
// 	} else {
// 		defer lDb.Close()

// 		lCoreString := `select nvl(eSignedDocid, '')  eSignedDocid
// 						from ekyc_request r
// 						where id = ? `

// 		lRows, lErr := lDb.Query(lCoreString, pRequestId)
// 		if lErr != nil {
// 			helpers.ErrReturn(lErr)
// 		} else {
// 			for lRows.Next() {
// 				lErr := lRows.Scan(&lDocId)

// 				if lErr != nil {
// 					helpers.ErrReturn(lErr)
// 				}

// 			}
// 		}

// 	}
// 	pDebug.Log(helpers.Statement, "ChkEsignCompleted (-)")
// 	return lDocId, nil
// }
