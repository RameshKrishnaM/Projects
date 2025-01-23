package fileoperations

import (
	"encoding/json"
	"fcs23pkg/apps/v1/router"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/pdfgenerate"
	"fmt"
	"net/http"
	"strings"
)

type response struct {
	Data   []string `json:"data"`
	Status string   `json:"status"`
	Error  string   `json:"errmsg"`
}
type ReqStruct struct {
	Id        []string `json:"id"`
	Key       []string `json:"key"`
	ProofType string   `json:"prooftype"`
}

/*
Purpose : This method is used to upload the multiple file in db
Request : N/A
Response :
===========
On Success:
===========
{
"Status": "Success",
}
===========
On Error:
===========
"Error":
Author : Sowmiya L
Date : 08-July-2023
*/

func MultiFileInsert(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "filestruct,Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "MultiFileInsertDb (+)")
	if r.Method == "POST" {
		// log.Println("MultiFileInsertDb", r)
		var lDocIdArr []string
		var lResp response
		var lReqRec ReqStruct
		lResp.Status = common.SuccessCode
		lHeadVal := r.Header.Get("filestruct")
		// fmt.Println("lHeadVal", lHeadVal)
		lErr := json.Unmarshal([]byte(lHeadVal), &lReqRec)
		lDebug.Log(helpers.Details, "lHeadVal", lHeadVal)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "MFI01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("MFI01", "Something went wrong. Please try again later."))
			return
		}
		lResp.Data = lReqRec.Id
		if len(lReqRec.Key) != 0 {

			lFileSaveArr, lErr := readFile2(lDebug, r, lReqRec.Key)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "MFI02"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("MFI02", "Something went wrong. Please try again later."))
				return
			}
			lFileInfo, lErr := pdfgenerate.Savefile(lDebug, lFileSaveArr)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "MFI03"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("MFI03", "Something went wrong. Please try again later."))
				return
			}
			lDocIdArr = GeneareDocIDArr(lDebug, lReqRec.Id, lFileInfo)
			// if lErr != nil {
			// 	lDebug.Log(helpers.Elog, "MFI06"+lErr.Error())
			// 	fmt.Fprint(w, helpers.GetError_String("MFI06", "Something went wrong. Please try again later."))
			// 	return
			// }
			lResp.Data = lDocIdArr
			lDebug.Log(helpers.Details, "data", lResp.Data)
			if lReqRec.ProofType != "addressProof" {
				if len(lResp.Data) != 4 {
					lDebug.Log(helpers.Elog, "MFI04")
					fmt.Fprint(w, helpers.GetError_String("MFI04", "Something went wrong. Please try again later."))
					return
				} else {
					lErr := proofId(lDebug, lResp.Data, r, lReqRec)
					if lErr != nil {
						lDebug.Log(helpers.Elog, "MFI05", lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("MFI05", "Something went wrong. Please try again later."))
						return
					}
				}
			}
		}
		lPayload, lErr := json.Marshal(lResp)
		lDebug.Log(helpers.Details, "lPayload", lPayload)
		if lErr != nil {
			fmt.Fprint(w, helpers.GetError_String("MFI06", "Something went wrong. Please try again later."))
			return
		}
		// fmt.Println("**************", string(lPayload))
		fmt.Fprint(w, string(lPayload))
	}
	lDebug.Log(helpers.Statement, "MultiFileInsertDb (-)")
}

func readFile2(pDebug *helpers.HelperStruct, r *http.Request, pkeyArr []string) ([]pdfgenerate.FileSaveStruct, error) {

	pDebug.Log(helpers.Statement, "ReadFile (+)")

	var lFinalArr []pdfgenerate.FileSaveStruct

	for _, lkey := range pkeyArr {
		lFileSaveStruct, lErr := pdfgenerate.FileToBase64Encode(pDebug, r, lkey, "Ekyc_proof_upload")
		if lErr != nil {
			return lFinalArr, helpers.ErrReturn(lErr)
		}

		lFinalArr = append(lFinalArr, lFileSaveStruct)

	}
	// lData, lErr := json.Marshal(&lFinalArr)
	// if lErr != nil {
	// 	return lFinalArr, helpers.ErrReturn(lErr)
	// }

	pDebug.Log(helpers.Statement, "ReadFile (-)")

	return lFinalArr, nil

}

func GeneareDocIDArr(pDebug *helpers.HelperStruct, pDocIdmap []string, pdbDocId pdfgenerate.ImageRespStruct) []string {
	pDebug.Log(helpers.Statement, "idContstruct (+)")
	lCount := 0
	var lDocid []string
	lDocArr := pdbDocId.FileDocID

	// for _, lKey := range pDocIdmap {
	// 	if lKey == "" {
	// 		lDocid = append(lDocid, lDocArr[lCount].DocID)
	// 		lCount += 1
	// 	} else {
	// 		lDocid = append(lDocid, lKey)
	// 	}
	// }
	for _, lKey := range pDocIdmap {
		if lKey == "" && lCount < len(lDocArr) {
			lDocid = append(lDocid, lDocArr[lCount].DocID)
			lCount++
		} else {
			lDocid = append(lDocid, lKey)
		}
	}
	pDebug.Log(helpers.Statement, "idContstruct (-)")
	return lDocid
}

func proofId(pDebug *helpers.HelperStruct, pDocId []string, r *http.Request, lReqRec ReqStruct) error {
	pDebug.Log(helpers.Statement, "proofId (+)")
	var lFlag string

	lSessionId, lUid, lErr := sessionid.GetOldSessionUID(r, pDebug, common.EKYCCookieName)
	if lErr != nil {
		return helpers.ErrReturn(lErr)

	}
	pDebug.SetReference(lUid)

	lCorestring := `SELECT CASE WHEN count(*) > 0 THEN 'Y' ELSE 'N' END AS Flag
		FROM ekyc_attachments
		WHERE Request_id  = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)

	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lFlag)
			pDebug.Log(helpers.Details, "lFlag", lFlag)
			if lErr != nil {
				return helpers.ErrReturn(lErr)

			}
		}

		if lFlag == "Y" {
			lCorestring := `update ekyc_attachments set Bank_proof=?,Income_proof=?,Signature=?,Pan_proof=?,Income_prooftype=?,UpdatedSesion_Id=?,UpdatedDate=unix_timestamp() where Request_id=?`
			_, lErr := ftdb.NewEkyc_GDB.Exec(lCorestring, pDocId[0], pDocId[1], pDocId[2], pDocId[3], lReqRec.ProofType, lSessionId, lUid)
			if lErr != nil {
				return helpers.ErrReturn(lErr)

			} else {
				lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.DocumnetVerified)
				if lErr != nil {
					return helpers.ErrReturn(lErr)
				}
				lErr = router.StatusInsert(pDebug, lUid, lSessionId, "DocumentUpload")
				if lErr != nil {
					return helpers.ErrReturn(lErr)
				}
			}
		} else if lFlag == "N" {
			// fmt.Println("inside else if")
			lCoreString := `insert into ekyc_attachments (Request_id,Bank_proof,Income_proof,Signature,Pan_proof,Income_prooftype,Session_Id,UpdatedSesion_Id,CreatedDate,UpdatedDate)
		values(?,?,?,?,?,?,?,?,unix_timestamp(),unix_timestamp())`
			_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, lUid, pDocId[0], pDocId[1], pDocId[2], pDocId[3], lReqRec.ProofType, lSessionId, lSessionId)
			if lErr != nil {
				return helpers.ErrReturn(lErr)

			} else {
				lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.DocumnetVerified)
				if lErr != nil {
					return helpers.ErrReturn(lErr)
				}
				lErr = router.StatusInsert(pDebug, lUid, lSessionId, "DocumentUpload")
				if lErr != nil {
					return helpers.ErrReturn(lErr)
				}
			}
		}
	}

	pDebug.RemoveReference()
	pDebug.Log(helpers.Statement, "proofId (-)")
	return nil
}

func KraAnexureAddrPdfCheck(pDebug *helpers.HelperStruct, pUid, pSid string) (lFinalDocID string, lErr error) {
	pDebug.Log(helpers.Statement, "KraAnexureAddrPdfCheck (+)")

	var lDocID1, lDocID2 string
	var lDocumentCount int

	var lPDFGridRec pdfgenerate.PDFGridStruct
	var lDocIDRec pdfgenerate.AttachStruct
	var lDocIDArr []pdfgenerate.AttachStruct

	lSqlString := ` select 
case 
	when nvl(ea.Proof_Doc_Id1,'')<>'' and nvl(ea.Proof_Doc_Id2,'')<>'' 	then 2 
	when nvl(ea.Proof_Doc_Id1,'')<>'' or nvl(ea.Proof_Doc_Id2,'')<>'' then 1 
	else 0 
end as document_count,nvl(ea.Proof_Doc_Id1,''),nvl(ea.Proof_Doc_Id2,'') 
from ekyc_address ea 
where ea.Request_Uid =?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lSqlString, pUid)
	if lErr != nil {
		return lFinalDocID, helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lDocumentCount, &lDocID1, &lDocID2)
		pDebug.Log(helpers.Details, "lDocumentCount,lDocID1,lDocID2", lDocumentCount, lDocID1, lDocID2)
		if lErr != nil {
			return lFinalDocID, helpers.ErrReturn(lErr)

		}
	}
	lFileType := "KraAnexureAddrPdf"

	lCorestring2 := ` UPDATE ekyc_attachmentlog_history eah 
	SET eah.isActive = 0
	WHERE eah.Reqid = ? and eah.Filetype=?`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lCorestring2, pUid, lFileType)
	if lErr != nil {
		return lFinalDocID, helpers.ErrReturn(lErr)
	}
	if lDocumentCount == 0 {
		return lFinalDocID, helpers.ErrReturn(fmt.Errorf("DocIDs not found"))
	} else if lDocumentCount == 1 {
		lPageCount, lErr := pdfgenerate.GetPageCount(pDebug, lDocID1)
		if lErr != nil {
			return lFinalDocID, helpers.ErrReturn(lErr)
		}
		if lPageCount.PageCount[0] > 1 {
			lDocIDRec.AttachDocID = lDocID1
			lDocIDArr = append(lDocIDArr, lDocIDRec)
		} else {
			return lFinalDocID, nil
		}
	} else {
		lDocIDRec.AttachDocID = lDocID1
		lDocIDArr = append(lDocIDArr, lDocIDRec)
		lDocIDRec.AttachDocID = lDocID2
		lDocIDArr = append(lDocIDArr, lDocIDRec)
	}

	lPDFGridRec.DocID = lDocIDArr
	lPDFGridRec.ProcessType = "Ekyc_proof_upload"
	lPDFGridRec.Column = 2
	lPDFGridRec.Row = 1

	lFinalDocID, lErr = pdfgenerate.PDFGrid(pDebug, lPDFGridRec, pUid, pSid)
	if lErr != nil {
		return lFinalDocID, helpers.ErrReturn(lErr)
	}

	if !strings.EqualFold(lFinalDocID, "") {
		lCorestring2 = ` INSERT INTO ekyc_attachmentlog_history (Reqid, Filetype, isActive, DocId, CreatedDate, CreatedBy)
	 values(?,?,1,?,unix_timestamp(),?);`
		_, lErr = ftdb.NewEkyc_GDB.Exec(lCorestring2, pUid, lFileType, lFinalDocID, "EKYC")
		if lErr != nil {
			return lFinalDocID, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "KraAnexureAddrPdfCheck (-)")
	return lFinalDocID, nil
}

func GetAdrsProofDocID(pDebug *helpers.HelperStruct, pUid string) (lDocID string, lErr error) {
	pDebug.Log(helpers.Statement, "GetAdrsProofDocID (-)")

	var lMergeDocID, lSourceOfAddress, lDiglockerID, lKraID string

	lSelectQry := `select nvl(ea.Proof_Doc_Id1,''),nvl((select eah.DocId from ekyc_attachmentlog_history eah where eah.Reqid=ea.Request_Uid and eah.isActive=1 and eah.Filetype ='KraAnexureAddrPdf'),'') as mergedocid ,nvl(ea.Source_Of_Address,''),nvl(ea.Kra_docid,''),nvl(ea.digilocker_docid,'')
	from ekyc_address ea 
	where ea.Request_Uid =?`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lSelectQry, pUid)
	if lErr != nil {
		return lDocID, helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lDocID, &lMergeDocID, &lSourceOfAddress, &lKraID, &lDiglockerID)
		pDebug.Log(helpers.Details, "lDocID,lDocID", lDocID, lMergeDocID)
		if lErr != nil {
			return lDocID, helpers.ErrReturn(lErr)

		}
	}
	pDebug.Log(helpers.Details, "lMergeDocID", lMergeDocID)

	if strings.EqualFold(lSourceOfAddress, "KRA") {
		lDocID = lKraID
	} else if strings.EqualFold(lSourceOfAddress, "Digilocker") {
		lDocID = lDiglockerID
	} else if !strings.EqualFold(lMergeDocID, "") {
		lDocID = lMergeDocID
	}

	pDebug.Log(helpers.Statement, "GetAdrsProofDocID (-)")
	return lDocID, nil
}
