package fileoperations

import (
	"encoding/json"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/dematandservice"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/pdfgenerate"
	"fmt"
	"net/http"
	"strings"
)

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

type FileDataStruct struct {
	ChangeFlag                            bool
	InsertColArr, InsertValArr, UpdateArr []string
	UploadLog                             string
}

func MultiFileUpload(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "filestruct,Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "MultiFileInsertDb (+)")
	if r.Method == "POST" {
		// log.Println("MultiFileInsertDb", r)

		var lResp response
		var lReqRec IdStruct

		lResp.Status = common.SuccessCode
		lHeadVal := r.Header.Get("filestruct")
		lDebug.Log(helpers.Details, "lHeadVal", lHeadVal)
		lErr := json.Unmarshal([]byte(lHeadVal), &lReqRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "MFI01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("MFI01", "Something went wrong. Please try again later."))
			return
		}

		lDebug.Log(helpers.Details, "lReqRec", lReqRec)

		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "MFI02"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("MFI02", "Something went wrong. Please try again later."))
			return

		}

		lFileSaveArr, lDocIdArr, lErr := readFile(lDebug, r, lReqRec.IdArr)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "MFI03"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("MFI03", "Something went wrong. Please try again later."))
			return
		}

		_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(r, lDebug, common.EKYCCookieName, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "MFI07"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("MFI07", "Something went wrong. Please try again later."))
			return
		}
		if len(lFileSaveArr.InsertColArr)+len(lFileSaveArr.InsertValArr)+len(lFileSaveArr.UpdateArr) > 0 {
			lErr = InsertData(r, lDebug, lFileSaveArr, lReqRec.ProofType, lUid, lSid, lReqRec.AadhaarNumber, lReqRec.CashOnlyFlag, lTestUserFlag)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "MFI05"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("MFI05", "Something went wrong. Please try again later."))
				return
			}

			for _, lFileData := range lDocIdArr.FileDocID {
				lErr = commonpackage.AttachmentlogFile(lUid, lFileData.FileKey, lFileData.DocID, lDebug)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "MFI06"+lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("MFI06", "Something went wrong. Please try again later."))
					return

				}
			}
		}
		fmt.Fprint(w, helpers.GetMsg_String("", "Insert SuccessFully"))
	}
	lDebug.Log(helpers.Statement, "MultiFileInsertDb (-)")
}

func readFile(pDebug *helpers.HelperStruct, r *http.Request, pkeyArr []FileIdDataStruct) (lFileInfo FileDataStruct, lDocIdArr pdfgenerate.ImageRespStruct, lErr error) {

	pDebug.Log(helpers.Statement, "ReadFile (+)")

	var lFinalInsertArr []pdfgenerate.FileSaveStruct

	for _, lkey := range pkeyArr {
		if strings.EqualFold(lkey.UploadFlag, "Y") {
			lFileInfo.ChangeFlag = true
			lFileSaveStruct, lErr := pdfgenerate.FileToBase64Encode(pDebug, r, lkey.DocType, "Ekyc_proof_upload")
			if lErr != nil {
				return lFileInfo, lDocIdArr, helpers.ErrReturn(lErr)
			}
			lFinalInsertArr = append(lFinalInsertArr, lFileSaveStruct)
		} else {
			lFileInfo.InsertColArr = append(lFileInfo.InsertColArr, lkey.DocType)
			lFileInfo.InsertValArr = append(lFileInfo.InsertValArr, lkey.DocId)
			lFileInfo.UpdateArr = append(lFileInfo.UpdateArr, fmt.Sprintf("%s='%s'", lkey.DocType, lkey.DocId))
		}

	}
	if lFileInfo.ChangeFlag {

		// lFilebyte, lErr := json.Marshal(&lFinalInsertArr)
		// if lErr != nil {
		// 	return lFileInfo, lDocIdArr, helpers.ErrReturn(lErr)
		// }

		lFileArr, lErr := pdfgenerate.Savefile(pDebug, lFinalInsertArr)
		if lErr != nil {
			return lFileInfo, lDocIdArr, helpers.ErrReturn(lErr)
		}

		for _, lFileData := range lFileArr.FileDocID {
			lFileInfo.InsertColArr = append(lFileInfo.InsertColArr, lFileData.FileKey)
			lFileInfo.InsertValArr = append(lFileInfo.InsertValArr, lFileData.DocID)
			lFileInfo.UpdateArr = append(lFileInfo.UpdateArr, fmt.Sprintf("%s='%s'", lFileData.FileKey, lFileData.DocID))
		}
		lDocIdArr = lFileArr
	}
	pDebug.Log(helpers.Statement, "ReadFile (-)")

	return lFileInfo, lDocIdArr, nil

}
func LogFileCreate(pDebug *helpers.HelperStruct, lQry *string, ReqID, FileType, DocID string) {
	pDebug.Log(helpers.Statement, "LogFileCreate (+)")

	// Prepare values for insertion
	lInsertValues := []string{ReqID, FileType, "1", DocID, "Unix_timestamp()", "EKYC"}

	// Check if the query is empty and adjust accordingly
	if strings.EqualFold(*lQry, "") {
		*lQry += ""
	} else {
		*lQry += ","
	}

	// Append the new values to the query
	*lQry += fmt.Sprintf("('%s')", strings.Join(lInsertValues, "','"))
	*lQry = strings.ReplaceAll(*lQry, "'Unix_timestamp()'", "Unix_timestamp()")
	pDebug.Log(helpers.Statement, "LogFileCreate (-)")
}

func InsertData(r *http.Request, pDebug *helpers.HelperStruct, pFileSaveArr FileDataStruct, pIncomeType, pUid, pSid, pAadhaarNo string, pCashOnlyFlag string, pTestUserFlag string) error {
	pDebug.Log(helpers.Statement, "InsertData (+)", pFileSaveArr.ChangeFlag)

	lUpdateQuery := `UPDATE ekyc_demat_details SET CashOnly_Flag =?, Updated_Session_Id =?, UpdatedData=UNIX_TIMESTAMP() where requestuid =?`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lUpdateQuery, pCashOnlyFlag, pSid, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	if pCashOnlyFlag == "Y" {
		lErr := dematandservice.CashOnlyUpdate(pDebug, pUid, pSid)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
		if !strings.EqualFold(pTestUserFlag, "0") {

			lErr = dematandservice.UpdateIncomeProof(pDebug, pUid)
			if lErr != nil {
				return helpers.ErrReturn(lErr)
			}

			lErr = dematandservice.UpdateProofFlag(pDebug, pUid)
			if lErr != nil {
				return helpers.ErrReturn(lErr)
			}
		}
	}

	if pFileSaveArr.ChangeFlag {

		lInsertQry := fmt.Sprintf(`insert into ekyc_attachments (%s,Request_id,Income_prooftype,Session_Id,UpdatedSesion_Id,CreatedDate,UpdatedDate) 
	values('%s',?,?,?,?,unix_timestamp(),unix_timestamp());`, strings.Join(pFileSaveArr.InsertColArr, ","), strings.Join(pFileSaveArr.InsertValArr, "','"))

		lUpdateQry := fmt.Sprintf(`update ekyc_attachments set %s,Income_prooftype=?,UpdatedSesion_Id=?,UpdatedDate=unix_timestamp() where Request_id = ? ;`, strings.Join(pFileSaveArr.UpdateArr, ","))

		insertString := `
	if not exists (select * FROM ekyc_attachments WHERE Request_id  = ?)
	then
	` + lInsertQry + `
	else
	` + lUpdateQry + `
	end if;`

		pDebug.Log(helpers.Details, "insertString", insertString)

		_, lErr := ftdb.NewEkyc_GDB.Exec(insertString, pUid, pUid, pIncomeType, pSid, pSid, pIncomeType, pSid, pUid)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
		pDebug.Log(helpers.Details, "common.DocumnetVerified :", common.DocumnetVerified)

	}
	if pAadhaarNo != "" && len(pAadhaarNo) == 4 {
		pAadhaarNo = "XXXXXXXX" + pAadhaarNo

		lErr := AadhaarDataUpdate(pDebug, pUid, pSid, pAadhaarNo)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}

	lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.DocumnetVerified)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "ID001", lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lErr = router.StatusInsert(pDebug, pUid, pSid, "DocumentUpload")
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.RemoveReference()
	pDebug.Log(helpers.Statement, "InsertData (-)")
	return nil
}

func AadhaarDataUpdate(pDebug *helpers.HelperStruct, pUid, pSid, pAadhaarNo string) (lErr error) {
	pDebug.Log(helpers.Statement, "AadhaarDataUpdate (+)")
	pDebug.Log(helpers.Details, "pAadhaarNo", pAadhaarNo)

	lCoreString := `UPDATE ekyc_request AS er
	SET er.AadhraNo = ?,
		er.Updated_Session_Id = ?,
		er.UpdatedDate = UNIX_TIMESTAMP()  
	WHERE er.Uid = ?`

	_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pAadhaarNo, pSid, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lCoreString = `UPDATE ekyc_address AS ea
SET 
    ea.Proof_No = CASE 
                    WHEN ea.Proof_No IS NULL OR ea.Proof_No = '' AND ea.proofType = '12' THEN ? 
                    ELSE ea.Proof_No 
                  END,
    ea.COR_ProofNo = CASE 
                      WHEN ea.COR_ProofNo IS NULL OR ea.COR_ProofNo = '' AND ea.COR_ProofType = '12' THEN ?
                      ELSE ea.COR_ProofNo 
                    END,
    Updated_Session_Id = ?,
    UpdatedDate = UNIX_TIMESTAMP()
WHERE ea.Request_Uid = ?`

	_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pAadhaarNo, pAadhaarNo, pSid, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "AadhaarDataUpdate (-)")
	return nil
}
