package digilocker

import (
	"encoding/json"
	"fcs23pkg/apps/v2/address"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/pdfgenerate"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

//	type DigiInsertStruct struct {
//		PERAddress1 string `json:"peradrs1"`
//		PERAddress2 string `json:"peradrs2"`
//		PERAddress3 string `json:"peradrs3"`
//		PERCity     string `json:"percity"`
//		PERState    string `json:"perstate"`
//		PERCountry  string `json:"percountry"`
//		PERPincode  string `json:"perpincode"`
//		ProofId     string `json:"perdocid1"`
//	}
type KeyPairStruct struct {
	Key      string `json:"key"`
	FileType string `json:"filetype"`
	Value    string `json:"value"`
}

func DigiInfoInsert(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "DigiInfoInsert (+)")

	if r.Method == "POST" {
		lErr := digInfo(r, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DII01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DII01", "Something went wrong. Please try again later."))
			return
		}
	}
	fmt.Fprint(w, helpers.GetMsg_String("S", "Inserted Successfully"))
	lDebug.Log(helpers.Statement, "DigiInfoInsert (-)")
}

func digInfo(r *http.Request, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "digInfo (+)")
	var lReq FinalStruct
	var lFlag string

	lBody, lErr := ioutil.ReadAll(r.Body)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal(lBody, &lReq)
	pDebug.Log(helpers.Details, "digInfo----lBody-----", string(lBody))
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	lSessionId, lUid, lErr := sessionid.GetOldSessionUID(r, pDebug, common.EKYCCookieName)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.SetReference(lUid)

	// lDocID := ""
	// for _, lDocInfo := range lReq.DocIDArr {
	// 	if lDocInfo.FileKey == "AadharXMLPDF" {
	// 		lDocID = lDocInfo.DocID
	// 	}
	// }
	if !strings.EqualFold(common.AppRunMode, "prod") {
		// need remove below for production
		NewDocId, lErr := pdfgenerate.FileMoveProdtoDev(pDebug, lReq.PdfDocID)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		} else {
			lReq.PdfDocID = NewDocId
		}
	}
	// need remove above for production

	// lReq.PerAdrsProofName, lErr = commonpackage.GetDefaultCode(lDb1, pDebug, "AddressProof", lReq.PerAdrsProofName)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return helpers.ErrReturn(lErr)
	// }
	lReq.PERCountry, lErr = commonpackage.GetDefaultCode(pDebug, "country", lReq.PERCountry)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lReq.PERState, lErr = commonpackage.GetDefaultCode(pDebug, "state", lReq.PERState)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	lCorestring := `SELECT CASE WHEN count(*) > 0 THEN 'Yes' ELSE 'No' END AS Flag
		FROM ekyc_address
		WHERE Request_Uid  = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lFiletype := tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "Filetype")
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lFlag)
		pDebug.Log(helpers.Details, "lFlag", lFlag)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}
	lUpdatedAddr1 := address.ReplaceContainsString(pDebug, lReq.PERAddress1)
	lUpdatedAddr2 := address.ReplaceContainsString(pDebug, lReq.PERAddress2)
	lUpdatedAddr3 := address.ReplaceContainsString(pDebug, lReq.PERAddress3)
	lCity := address.ReplaceContainsString(pDebug, lReq.PERCity)

	if lFlag == "Yes" {
		lCoreString := `update ekyc_address set Source_Of_Address="Digilocker",CorAddress1=?,CorAddress2=?,CorAddress3=?,CorCity=?,
				CorState=?,CorPincode=?,CorCountry=?,PerAddress1=?,PerAddress2=?,
				PerAddress3=?,PerCity=?,PerState=?,PerPincode=?,PerCountry=?,U_PerAddress1 = ?,U_PerAddress2 = ?,U_PerAddress3 = ?,U_CorAddress1 = ?,U_CorAddress2 = ?,U_CorAddress3 = ?,dateofProofIssue="",ProofOfIssue="",Proof_No=?,COR_ProofNo=?,Proof_Doc_Id1="",Proof_Doc_Id2="",Cor_Address_DocId1="",Cor_Address_DocId2="",ProofExpriyDate="",Updated_Session_Id=?,UpdatedDate=unix_timestamp(),proofType="12",COR_ProofType = 12,SameAsPermenentAddress="Y",Digilocker_docid=?
			  where Request_Uid=?`
		_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString, lReq.PERAddress1, lReq.PERAddress2, lReq.PERAddress3, lCity, lReq.PERState, lReq.PERPincode, lReq.PERCountry, lReq.PERAddress1, lReq.PERAddress2, lReq.PERAddress3, lCity, lReq.PERState, lReq.PERPincode, lReq.PERCountry, lUpdatedAddr1, lUpdatedAddr2, lUpdatedAddr3, lUpdatedAddr1, lUpdatedAddr2, lUpdatedAddr3, lReq.PERAdrsProofNo, lReq.PERAdrsProofNo, lSessionId, lReq.PdfDocID, lUid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
		if lReq.PdfDocID != "" {
			lErr = commonpackage.AttachmentlogFile(lUid, lFiletype, lReq.PdfDocID, pDebug)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}

		lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.AddressVerified)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
		lErr = router.StatusInsert(pDebug, lUid, lSessionId, "AddressVerification")
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}

	} else if lFlag == "No" {
		lCoreString := `insert into ekyc_address 
				(Request_Uid,Source_Of_Address,
					CorAddress1,CorAddress2,CorAddress3,CorCity,CorState,CorPincode,CorCountry,
					PerAddress1,PerAddress2,PerAddress3,PerCity,PerState,PerPincode,PerCountry,
					U_PerAddress1,U_PerAddress2,U_PerAddress3,U_CorAddress1,U_CorAddress2,U_CorAddress3,
					dateofProofIssue,ProofOfIssue,Proof_No,Proof_Doc_Id1,Proof_Doc_Id2,ProofExpriyDate,
					Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate,
					SameAsPermenentAddress,proofType,COR_ProofType,Digilocker_docid,COR_ProofNo)
				values(?,"Digilocker",
				?,?,?,?,?,?,?,
				?,?,?,?,?,?,?,
				?,?,?,?,?,?,
				"","",?,"","","",?,?,unix_timestamp(),unix_timestamp(),"Y","12","12",?,?)`
		_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString,
			lUid,
			lReq.PERAddress1, lReq.PERAddress2, lReq.PERAddress3, lCity, lReq.PERState, lReq.PERPincode, lReq.PERCountry,
			lReq.PERAddress1, lReq.PERAddress2, lReq.PERAddress3, lCity, lReq.PERState, lReq.PERPincode, lReq.PERCountry,
			lUpdatedAddr1, lUpdatedAddr2, lUpdatedAddr3, lUpdatedAddr1, lUpdatedAddr2, lUpdatedAddr3, lReq.PERAdrsProofNo,
			lSessionId, lSessionId, lReq.PdfDocID, lReq.PERAdrsProofNo)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
		if lReq.PdfDocID != "" {
			lErr = commonpackage.AttachmentlogFile(lUid, lFiletype, lReq.PdfDocID, pDebug)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
		lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.AddressVerified)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
		lErr = router.StatusInsert(pDebug, lUid, lSessionId, "AddressVerification")
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "digInfo (-)")
	return nil
}
