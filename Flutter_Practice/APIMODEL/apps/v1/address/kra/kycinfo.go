package kra

import (
	"encoding/json"
	"fcs23pkg/apps/v1/commonpackage"
	"fcs23pkg/apps/v1/router"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

type insertStruct struct {
	CORAddress1    string `json:"coradrs1"`
	CORAddress2    string `json:"coradrs2"`
	CORAddress3    string `json:"coradrs3"`
	CORCity        string `json:"corcity"`
	CORState       string `json:"corstate"`
	CORCountry     string `json:"corcountry"`
	CORPincode     string `json:"corpincode"`
	PERAddress1    string `json:"peradrs1"`
	PERAddress2    string `json:"peradrs2"`
	PERAddress3    string `json:"peradrs3"`
	PERCity        string `json:"percity"`
	PERState       string `json:"perstate"`
	PERCountry     string `json:"percountry"`
	PERPincode     string `json:"perpincode"`
	ProofofAddress string `json:"peradrsproofname"`
	PERAdrsProofNo string `json:"peradrsproofno"`
	ProofId        string `json:"docid1"`
}

/*
Purpose : This method is used to insert the user kyc info in db
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
Date : 28-June-2023
*/
func Kyc(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "kycinfo (+)")

	if r.Method == "POST" {
		lErr := kraInsertDb(w, r, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "KYC01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("KYC01", "Something went wrong. Please try again later."))
			return
		}
	}
	lDebug.Log(helpers.Statement, "kycinfo (-)")
}

func kraInsertDb(w http.ResponseWriter, r *http.Request, pDebug *helpers.HelperStruct) error {

	pDebug.Log(helpers.Statement, "kraInsertDb (+)")

	var lAddressInsert insertStruct
	var lFlag, lPerFlag string
	lBody, lErr := ioutil.ReadAll(r.Body)
	pDebug.Log(helpers.Details, "lBody---kraInsertDb", string(lBody))

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal(lBody, &lAddressInsert)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lFiletype := tomlconfig.GtomlConfigLoader.GetValueString("kra", "Filetype")

	lSessionId, lUid, lErr := sessionid.GetOldSessionUID(r, pDebug, common.EKYCCookieName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	pDebug.SetReference(lUid)

	lAddressInsert.ProofofAddress, lErr = commonpackage.GetDefaultCode(pDebug, "AddressProof", lAddressInsert.ProofofAddress)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lAddressInsert.CORCountry, lErr = commonpackage.GetDefaultCode(pDebug, "country", lAddressInsert.CORCountry)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lAddressInsert.CORState, lErr = commonpackage.GetDefaultCode(pDebug, "state", lAddressInsert.CORState)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lAddressInsert.PERCountry, lErr = commonpackage.GetDefaultCode(pDebug, "country", lAddressInsert.PERCountry)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lAddressInsert.PERState, lErr = commonpackage.GetDefaultCode(pDebug, "state", lAddressInsert.PERState)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	// lCorestring := `select nvl(code,"") from ekyc_lookup_details eld where eld.description = ?`
	// lRows, lErr := lDb.Query(lCorestring, lAddressInsert.ProofofAddress)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return helpers.ErrReturn(lErr)
	// } else {
	// for lRows.Next() {
	// lErr := lRows.Scan(&lAddressInsert.ProofofAddress)
	// // fmt.Println("code", lAddressInsert.ProofofAddress)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return helpers.ErrReturn(lErr)
	// } else {

	lCorestring := `SELECT CASE WHEN count(*) > 0 THEN 'Y' ELSE 'N' END AS Flag
			FROM ekyc_address
			WHERE Request_Uid  = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lFlag)
			pDebug.Log(helpers.Details, "lFlag", lFlag)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
		if lAddressInsert.ProofofAddress == "12" && len(lAddressInsert.PERAdrsProofNo) == 4 {
			lAddressInsert.PERAdrsProofNo = "XXXXXXXX" + lAddressInsert.PERAdrsProofNo
		} else if len(lAddressInsert.PERAdrsProofNo) < 4 {
			lAddressInsert.PERAdrsProofNo = ""
		} else if len(lAddressInsert.PERAdrsProofNo) == 12 && !strings.Contains(lAddressInsert.PERAdrsProofNo, "XXXXXXXX") {
			lAddressInsert.PERAdrsProofNo = ""
		}
		if strings.EqualFold(lAddressInsert.CORAddress1, lAddressInsert.PERAddress1) &&
			strings.EqualFold(lAddressInsert.CORAddress2, lAddressInsert.PERAddress2) &&
			strings.EqualFold(lAddressInsert.CORAddress3, lAddressInsert.PERAddress3) &&
			strings.EqualFold(lAddressInsert.CORCity, lAddressInsert.PERCity) &&
			strings.EqualFold(lAddressInsert.CORState, lAddressInsert.PERState) &&
			strings.EqualFold(lAddressInsert.CORPincode, lAddressInsert.PERPincode) &&
			strings.EqualFold(lAddressInsert.CORCountry, lAddressInsert.PERCountry) {
			lPerFlag = "Y"
		} else {
			lPerFlag = "N"
		}
		if lFlag == "Y" {
			lCoreString := `update ekyc_address set 
						Source_Of_Address="KRA",
						CorAddress1=?,CorAddress2=?,CorAddress3=?,
						CorCity=?,CorState=?,CorPincode=?,CorCountry=?,
						PerAddress1=?,PerAddress2=?,PerAddress3=?,
						PerCity=?,PerState=?,PerPincode=?,PerCountry=?,
						U_PerAddress1 = ?,U_PerAddress2 = ?,U_PerAddress3 = ?,
						U_CorAddress1 = ?,U_CorAddress2 = ?,U_CorAddress3 = ?,
						proofType=?,dateofProofIssue="",ProofOfIssue="",Proof_No=?,
						Proof_Doc_Id1="",Proof_Doc_Id2="",ProofExpriyDate="",
						Updated_Session_Id=?,UpdatedDate=unix_timestamp(),
						SameAsPermenentAddress=?,Kra_docid=?
				  where Request_Uid=?`
			_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString,
				lAddressInsert.CORAddress1, lAddressInsert.CORAddress2, lAddressInsert.CORAddress3,
				lAddressInsert.CORCity, lAddressInsert.CORState, lAddressInsert.CORPincode, lAddressInsert.CORCountry,
				lAddressInsert.PERAddress1, lAddressInsert.PERAddress2, lAddressInsert.PERAddress3,
				lAddressInsert.PERCity, lAddressInsert.PERState, lAddressInsert.PERPincode, lAddressInsert.PERCountry,
				lAddressInsert.PERAddress1, lAddressInsert.PERAddress2, lAddressInsert.PERAddress3,
				lAddressInsert.CORAddress1, lAddressInsert.CORAddress2, lAddressInsert.CORAddress3,
				lAddressInsert.ProofofAddress, lAddressInsert.PERAdrsProofNo, lSessionId, lPerFlag, lAddressInsert.ProofId, lUid)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
			if lAddressInsert.ProofofAddress == "12" && len(lAddressInsert.PERAdrsProofNo) == 12 && strings.Contains(lAddressInsert.PERAdrsProofNo, "XXXXXXXX") {
				lSqlString := `update ekyc_request 
				set AadhraNo = ?
				where  Uid  = ?`
				_, lErr = ftdb.NewEkyc_GDB.Exec(lSqlString, lAddressInsert.PERAdrsProofNo, lUid)
				if lErr != nil {
					return helpers.ErrReturn(lErr)
				}
			}
			lErr = commonpackage.AttachmentlogFile(lUid, lFiletype, lAddressInsert.ProofId, pDebug)
			if lErr != nil {
				return helpers.ErrReturn(lErr)
			}
			lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.AddressVerified)
			if lErr != nil {
				return helpers.ErrReturn(lErr)
			}
			lErr = router.StatusInsert(pDebug, lUid, lSessionId, "AddressVerification")
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		} else if lFlag == "N" {
			lCoreString := `insert into ekyc_address (
							Request_Uid,Source_Of_Address,
							CorAddress1,CorAddress2,CorAddress3,
							CorCity,CorState,CorPincode,CorCountry,
							PerAddress1,PerAddress2,PerAddress3,
							PerCity,PerState,PerPincode,PerCountry,
							U_PerAddress1,U_PerAddress2,U_PerAddress3,
							U_CorAddress1,U_CorAddress2,U_CorAddress3,
							proofType,dateofProofIssue,ProofOfIssue,Proof_No,
							Proof_Doc_Id1,Proof_Doc_Id2,ProofExpriyDate,
							Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate,
							SameAsPermenentAddress,Kra_docid)
							values(?,"KRA",
							?,?,?,
							?,?,?,?,
							?,?,?,
							?,?,?,?,
							?,?,?,
							?,?,?,
							?,"","",?,"","","",?,?,unix_timestamp(),unix_timestamp(),?,?)`
			_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, lUid, lAddressInsert.CORAddress1, lAddressInsert.CORAddress2, lAddressInsert.CORAddress3, lAddressInsert.CORCity, lAddressInsert.CORState, lAddressInsert.CORPincode, lAddressInsert.CORCountry, lAddressInsert.PERAddress1, lAddressInsert.PERAddress2, lAddressInsert.PERAddress3, lAddressInsert.PERCity, lAddressInsert.PERState, lAddressInsert.PERPincode, lAddressInsert.PERCountry, lAddressInsert.PERAddress1, lAddressInsert.PERAddress2, lAddressInsert.PERAddress3, lAddressInsert.CORAddress1, lAddressInsert.CORAddress2, lAddressInsert.CORAddress3, lAddressInsert.ProofofAddress, lAddressInsert.PERAdrsProofNo, lAddressInsert.ProofId, lSessionId, lSessionId, lPerFlag, lAddressInsert.ProofId)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			} else {
				pDebug.Log(helpers.Statement, "Inserted successfully")
				lErr = commonpackage.AttachmentlogFile(lUid, lFiletype, lAddressInsert.ProofId, pDebug)
				if lErr != nil {
					return helpers.ErrReturn(lErr)
				}
				if lAddressInsert.ProofofAddress == "12" && len(lAddressInsert.PERAdrsProofNo) == 12 && strings.Contains(lAddressInsert.PERAdrsProofNo, "XXXXXXXX") {
					lSqlString := `update ekyc_request 
					set AadhraNo = ?
					where  Uid  = ?`
					_, lErr = ftdb.NewEkyc_GDB.Exec(lSqlString, lAddressInsert.PERAdrsProofNo, lUid)
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
					pDebug.Log(helpers.Elog, lErr.Error())
					return helpers.ErrReturn(lErr)
				}

			}
		} else {
			pDebug.Log(helpers.Elog, lErr.Error())
		}
	}
	lDatas, lErr := json.Marshal(lAddressInsert)
	pDebug.Log(helpers.Details, "lDatas", string(lDatas))

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("", "Something went wrong"))
	} else {
		fmt.Fprint(w, helpers.GetMsg_String("S", "Inserted Successfully"))
	}
	pDebug.RemoveReference()
	pDebug.Log(helpers.Statement, "kraInsertDb (-)")
	return nil
}
