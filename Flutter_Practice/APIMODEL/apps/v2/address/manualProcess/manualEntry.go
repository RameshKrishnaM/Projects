package manualProcess

import (
	"encoding/json"
	"fcs23pkg/apps/v2/address/digilocker"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/fileoperations"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"io/ioutil"
	"net/http"
)

type addressDetailsStruct struct {
	//correspondence
	CORAddress1 string `json:"coradrs1"`
	CORAddress2 string `json:"coradrs2"`
	CORAddress3 string `json:"coradrs3"`
	CORCity     string `json:"corcity"`
	CORPincode  string `json:"corpincode"`
	CORState    string `json:"corstate"`
	CORCountry  string `json:"corcountry"`
	//perement address
	PERAddress1          string `json:"peradrs1"`
	PERAddress2          string `json:"peradrs2"`
	PERAddress3          string `json:"peradrs3"`
	PERCity              string `json:"percity"`
	PERPincode           string `json:"perpincode"`
	PERState             string `json:"perstate"`
	PERCountry           string `json:"percountry"`
	PerAdrsProofName     string `json:"peradrsproofname"`
	PERAdrsProofNo       string `json:"peradrsproofno"`
	PERAdrsProofPlaceIsu string `json:"peradrsproofplaceisu"`
	PERAdrsproofIsuDate  string `json:"peradrsproofisudate"`
	PERProofExpriyDate   string `json:"perproofexpirydate"`
	PERDocId1            string `json:"docid1"`
	PERDocId2            string `json:"docid2"`
	Switch               bool   `json:"aspermenantaddr"`
	Source_Of_Address    string `json:"soa"`
}

/*
Purpose : This method is used to insert the user info in db
Request : N/A
Response :
===========
On Success:
===========
{
"Status": "S",
“StatusMsg": "Inserted Successfuly”
}
===========
On Error:
===========
"Error":
Author : Sowmiya L
Date : 20-June-2023
*/
func Manual(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "Manual (+)")

	if r.Method == "POST" {
		lErr := manualInfo(w, r, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "MA01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("MA01", "somthing is wrong please try again later"))
			return
		}
	}
	lDebug.Log(helpers.Statement, "Manual (-)")
}

func manualInfo(w http.ResponseWriter, r *http.Request, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "ManualInfo (+)")
	var lReq addressDetailsStruct
	var lFlag string

	var lFiletypeRec digilocker.KeyPairStruct
	var lFiletypeArr []digilocker.KeyPairStruct
	lBody, lErr := ioutil.ReadAll(r.Body)
	pDebug.Log(helpers.Details, string(lBody), "lBody")

	if lErr != nil {
		pDebug.Log(helpers.Elog, "MI01"+lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal(lBody, &lReq)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "MI02"+lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	lSessionId, lUid, lErr := sessionid.GetOldSessionUID(r, pDebug, common.EKYCCookieName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "MI03"+lErr.Error())
		return helpers.ErrReturn(lErr)
	}


	// lReq.PerAdrsProofName, lErr = commonpackage.GetDefaultCode(lDb1, pDebug, "AddressProof", lReq.PerAdrsProofName)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return helpers.ErrReturn(lErr)
	// }
	lReq.CORCountry, lErr = commonpackage.GetDefaultCode( pDebug, "country", lReq.CORCountry)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lReq.CORState, lErr = commonpackage.GetDefaultCode(pDebug, "state", lReq.CORState)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lReq.PERCountry, lErr = commonpackage.GetDefaultCode( pDebug, "country", lReq.PERCountry)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lReq.PERState, lErr = commonpackage.GetDefaultCode( pDebug, "state", lReq.PERState)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lCorestring := `SELECT CASE WHEN count(*) > 0 THEN 'Yes' ELSE 'No' END AS Flag
			FROM ekyc_address
			WHERE Request_Uid  = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "MI05"+lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lFlag)
			pDebug.Log(helpers.Details, "lFlag", lFlag)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "MI06"+lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
		// lCoreString := `insert into ekyc_address (Request_Uid,Source_Of_Address,CorAddress1,CorAddress2,CorAddress3,CorCity,CorState,CorPincode,CorCountry,PerAddress1,PerAddress2,PerAddress3,PerCity,PerState,PerPincode,PerCountry,proof_Doc_Id,CreatedDate,UpdatedDate)
		// values("111","Manual",?,?,?,?,?,?,?,?,?,?,?,?,?,?,"123",unix_timestamp(),unix_timestamp())`
		// _, lErr = lDb.Exec(lCoreString, lReq.CorAdrs1, lReq.CorAdrs2, lReq.CorAdrs3, lReq.CorCity, lReq.CorState, lReq.CorPincode, lReq.CorCountry, lReq.PerAdrs1, lReq.PerAdrs2, lReq.PerAdrs3, lReq.PerCity, lReq.PerState, lReq.PerPincode, lReq.PerCountry)
		// if lErr != nil {
		// 	debug.Log(helpers.Elog, lErr.Error())
		// } else {
		// 	debug.Log(helpers.Statement, "Inserted successfully")
		// }
		// // for lRows.Next() {
		// // 	lErr := lRows.Scan(&lResp.State, &lResp.City, &lResp.Pincode)
		// // 	if lErr != nil {
		// // 		debug.Log(helpers.Elog, lErr.Error())
		// // 	} else {
		// // 		lresu.Resp = lResp
		// // 	}
		// // }
		// // }
		if lReq.Source_Of_Address == "" {
			lReq.Source_Of_Address = "Manual"
		}
		var lSignal string
		if lReq.Switch {
			lSignal = "Y"
		} else {
			lSignal = "N"
		}
		// Check if PERDocId1 is not empty
		if lReq.PERDocId1 != "" {
			lFiletypeRec.FileType = "Manual Address Proof 1"
			lFiletypeRec.Value = lReq.PERDocId1
			lFiletypeArr = append(lFiletypeArr, lFiletypeRec)
		}

		// Check if PERDocId2 is not empty
		if lReq.PERDocId2 != "" {
			lFiletypeRec.FileType = "Manual Address Proof 2"
			lFiletypeRec.Value = lReq.PERDocId2
			lFiletypeArr = append(lFiletypeArr, lFiletypeRec)
		}
		if lFlag == "Yes" {
			lCoreString := `update ekyc_address set Source_Of_Address=?,CorAddress1=?,CorAddress2=?,CorAddress3=?,CorCity=?,CorState=?,CorPincode=?,CorCountry=?,SameAsPermenentAddress=?, PerAddress1=?,PerAddress2=?,
				PerAddress3=?,PerCity=?,PerState=?,PerPincode=?,PerCountry=?,U_PerAddress1 = ?,U_PerAddress2 = ?,U_PerAddress3 = ?,U_CorAddress1 = ?,U_CorAddress2 = ?,U_CorAddress3 = ?,proofType=?,dateofProofIssue=?,ProofExpriyDate=?,ProofOfIssue=?,Proof_No=?,Proof_Doc_Id1=?,Proof_Doc_Id2=?,Updated_Session_Id=?,UpdatedDate=unix_timestamp() where Request_Uid=?`
			_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString, lReq.Source_Of_Address, lReq.CORAddress1, lReq.CORAddress2, lReq.CORAddress3, lReq.CORCity, lReq.CORState, lReq.CORPincode, lReq.CORCountry, lSignal, lReq.PERAddress1, lReq.PERAddress2, lReq.PERAddress3, lReq.PERCity, lReq.PERState, lReq.PERPincode, lReq.PERCountry, lReq.PERAddress1, lReq.PERAddress2, lReq.PERAddress3, lReq.CORAddress1, lReq.CORAddress2, lReq.CORAddress3, lReq.PerAdrsProofName, lReq.PERAdrsproofIsuDate, lReq.PERProofExpriyDate, lReq.PERAdrsProofPlaceIsu, lReq.PERAdrsProofNo, lReq.PERDocId1, lReq.PERDocId2, lSessionId, lUid)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "MI07"+lErr.Error())
				return helpers.ErrReturn(lErr)
			} else {
				for _, lFiletypeKey := range lFiletypeArr {
					lErr = commonpackage.AttachmentlogFile( lUid, lFiletypeKey.FileType, lFiletypeKey.Value, pDebug)
					if lErr != nil {
						return helpers.ErrReturn(lErr)
					}
				}
				lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.AddressVerified)
				if lErr != nil {
					return helpers.ErrReturn(lErr)
				}
				lErr = router.StatusInsert(pDebug, lUid, lSessionId, "AddressVerification")
				if lErr != nil {
					pDebug.Log(helpers.Elog, "MI08"+lErr.Error())
					return helpers.ErrReturn(lErr)
				}
			}
		} else if lFlag == "No" {
			lCoreString := `insert into ekyc_address (Request_Uid,Source_Of_Address,CorAddress1,CorAddress2,CorAddress3,CorCity,CorState,CorPincode,CorCountry,SameAsPermenentAddress,PerAddress1,PerAddress2,PerAddress3,PerCity,PerState,PerPincode,PerCountry,U_PerAddress1,U_PerAddress2,U_PerAddress3,U_CorAddress1,U_CorAddress2,U_CorAddress3,proofType,dateofProofIssue,ProofExpriyDate,ProofOfIssue,Proof_No,Proof_Doc_Id1,Proof_Doc_Id2,Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate)
		values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,unix_timestamp(),unix_timestamp())`
			_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, lUid, lReq.Source_Of_Address, lReq.CORAddress1, lReq.CORAddress2, lReq.CORAddress3, lReq.CORCity, lReq.CORState, lReq.CORPincode, lReq.CORCountry, lSignal, lReq.PERAddress1, lReq.PERAddress2, lReq.PERAddress3, lReq.PERCity, lReq.PERState, lReq.PERPincode, lReq.PERCountry, lReq.PERAddress1, lReq.PERAddress2, lReq.PERAddress3, lReq.CORAddress1, lReq.CORAddress2, lReq.CORAddress3, lReq.PerAdrsProofName, lReq.PERAdrsproofIsuDate, lReq.PERProofExpriyDate, lReq.PERAdrsProofPlaceIsu, lReq.PERAdrsProofNo, lReq.PERDocId1, lReq.PERDocId2, lSessionId, lSessionId)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "MI09"+lErr.Error())
				return helpers.ErrReturn(lErr)
			} else {
				for _, lFiletypeKey := range lFiletypeArr {
					lErr = commonpackage.AttachmentlogFile( lUid, lFiletypeKey.FileType, lFiletypeKey.Value, pDebug)
					if lErr != nil {
						return helpers.ErrReturn(lErr)
					}
				}
				lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.AddressVerified)
				if lErr != nil {
					return helpers.ErrReturn(lErr)
				}
				lErr = router.StatusInsert(pDebug, lUid, lSessionId, "AddressVerification")
				if lErr != nil {
					pDebug.Log(helpers.Elog, "MI10"+lErr.Error())
					return helpers.ErrReturn(lErr)
				}
			}
		}
	}
	_, lErr = fileoperations.KraAnexureAddrPdfCheck(pDebug, lUid, lSessionId)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	lDatas, lErr := json.Marshal(lReq)
	pDebug.Log(helpers.Details, "lDatas", string(lDatas))

	if lErr != nil {
		pDebug.Log(helpers.Elog, "MI12"+lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		fmt.Fprint(w, helpers.GetMsg_String("S", "Inserted Successfully"))
	}

	pDebug.Log(helpers.Statement, "ManualInfo (-)")
	return nil
}
