package esigndigio

import (
	"encoding/base64"
	"fcs23pkg/apps/v1/commonpackage"
	"fcs23pkg/apps/v1/router"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	digio "fcs23pkg/integration/v1/digioesign"
	"fcs23pkg/integration/v1/pdfgenerate"
	"fmt"
	"net/http"
	"strings"
)

type EmailBodyStruct struct {
	UserName, Pan, Email, FormStatus string
}

func GetSignFile(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetSignFile (+)")

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "GET")
	w.Header().Set("Access-Control-Allow-Headers", "digid,Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold("get", r.Method) {
		lSignID := r.Header.Get("digid")

		lDebug.Log(helpers.Details, "DIDid :", lSignID)

		if strings.EqualFold(lSignID, "") {
			lDebug.Log(helpers.Elog, "GSF01", "digio responce did not found")
			fmt.Fprint(w, helpers.GetError_String("GSF01", "Somthing is wrong please try again later"))
			return
		}

		lErr := CheckSignStatus(lDebug, lSignID)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GSF02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GSF02", "Somthing is wrong please try again later"))
			return
		}

		lResp, lErr := digio.DownloadFile(lDebug, lSignID)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GSF03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GSF03", "Somthing is wrong please try again later"))
			return
		}
		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GSF04", lErr)
			fmt.Fprint(w, helpers.GetError_String("GSF04", "Somthing is wrong please try again later"))
			return
		}

		lUserInfoRec, lErr := GetReqestPanNo(lDebug, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GSF05", lErr)
			fmt.Fprint(w, helpers.GetError_String("GSF05", "Somthing is wrong please try again later"))
			return
		}
		lSignPDF, lPWDPDF, lErr := SaveFileinDB(lDebug, lResp, lUserInfoRec.Pan, lUid, lSid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GSF06", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GSF06", "Somthing is wrong please try again later"))
			return
		}
		lErr = InsertEsignDocID(lDebug, lUid, lSid, lSignPDF, lPWDPDF, lSignID, r, lUserInfoRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GSF07", lErr)
			fmt.Fprint(w, helpers.GetError_String("GSF07", "Somthing is wrong please try again later"))
			return
		}
		lErr = SendEmail(lDebug, lUid, lPWDPDF, lUserInfoRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GSF08", lErr)
			fmt.Fprint(w, helpers.GetError_String("GSF08", "Somthing is wrong please try again later"))
			return
		}
		fmt.Fprint(w, helpers.GetMsg_String("GSF", "eSign complite"))
		lDebug.Log(helpers.Statement, "GetSignFile (-)")

	}
}

func GetReqestPanNo(pDebug *helpers.HelperStruct, pUid string) (lEmailBodyRec EmailBodyStruct, lErr error) {
	pDebug.Log(helpers.Statement, "GetReqestPanNo (+)")

	// lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
	// if lErr != nil {
	// 	return lEmailBodyRec, helpers.ErrReturn(lErr)
	// }
	// defer lDb.Close()
	lCorestring := ` SELECT 
    NVL(Email, '') AS Email, 
    NVL(Name_As_Per_Pan, '') AS Name_As_Per_Pan, 
    NVL(Pan, '') AS Pan, 
    CASE 
        WHEN submitted_date IS NOT NULL AND Form_Status = 'RJ' AND Process_Status = 'RJ' THEN 'RS' 
        ELSE 'FS' 
    END AS Form_Status 
FROM 
    ekyc_request where Uid=?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pUid)
	if lErr != nil {
		return lEmailBodyRec, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lEmailBodyRec.Email, &lEmailBodyRec.UserName, &lEmailBodyRec.Pan, &lEmailBodyRec.FormStatus)
		if lErr != nil {
			return lEmailBodyRec, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "GetReqestPanNo (-)")
	return lEmailBodyRec, nil

}

func SendEmail(pDebug *helpers.HelperStruct, pUid, pDocID string, lEmailBodyRec EmailBodyStruct) (lErr error) {
	pDebug.Log(helpers.Statement, "SendEmail (+)")

	// var lEmailBodyRec EmailBodyStruct
	var lUserInfoRec commonpackage.UserInfoStruct

	// lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
	// if lErr != nil {
	// 	return helpers.ErrReturn(lErr)
	// }
	// defer lDb.Close()

	lUserInfoRec.Email = lEmailBodyRec.Email
	lEmailBodyRec.UserName = strings.ToUpper(lEmailBodyRec.UserName)
	lUserInfoRec.ProcessType = "EKYC"
	lUserInfoRec.EmailTemplate = "./html/FormCompleted.html"
	lUserInfoRec.EmailBodyData = lEmailBodyRec

	lUserInfoRec.FileName = fmt.Sprintf("%s.zip", lEmailBodyRec.Pan)

	lFileInfo, lErr := pdfgenerate.Read_file(pDebug, pDocID)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lUserInfoRec.File = lFileInfo.FileByte

	lUserInfoRec.SubjectType = "FormCompleteSubject"

	_, lErr = commonpackage.SendEmailWithAttachment(pDebug, lUserInfoRec)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "SendEmail (-)")
	return nil
}

func SaveFileinDB(pDebug *helpers.HelperStruct, pResp []byte, pPanNo, pUid, pSid string) (lSignPDF, lPwsSignPdf string, lErr error) {

	var lFileSaveRec pdfgenerate.FileSaveStruct
	var lFileSaveArr []pdfgenerate.FileSaveStruct

	lFileSaveRec.FileName = "EKYC.PDF"
	lFileSaveRec.File = base64.StdEncoding.EncodeToString(pResp)
	lFileSaveRec.FileType = pdfgenerate.GetFileType(lFileSaveRec.FileName)
	lFileSaveRec.FileKey = "PDF"
	lFileSaveRec.Process = "Ekyc_proof_upload"
	lFileSaveArr = append(lFileSaveArr, lFileSaveRec)
	// lReqData, lErr := json.Marshal(lFileSaveArr)
	// if lErr != nil {
	// 	return lSignFile, helpers.ErrReturn(lErr)
	// }
	lSignFile, lErr := pdfgenerate.Savefile(pDebug, lFileSaveArr)
	if lErr != nil {
		return "", "", helpers.ErrReturn(lErr)
	}
	lPwdDocId, lErr := pdfgenerate.SavePwdZipFile(pDebug, lFileSaveRec.Process, pUid, pSid, lSignFile.FileDocID[0].DocID, pPanNo)
	if lErr != nil {
		return "", "", helpers.ErrReturn(lErr)
	}

	return lSignFile.FileDocID[0].DocID, lPwdDocId, nil

}

func InsertEsignDocID(pDebug *helpers.HelperStruct, pUid, pSid, pSignDocID, pPwsPDF, pEsignID string, r *http.Request, pEmailBodyRec EmailBodyStruct) (lErr error) {
	pDebug.Log(helpers.Statement, "InsertEsignDocID (+)")

	// lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
	// if lErr != nil {
	// 	return helpers.ErrReturn(lErr)
	// }
	// defer lDb.Close()

	linsertQry := `UPDATE ekyc_digioesign_request_status
	SET  req_status='S',Updated_Session_Id=?, UpdatedDate=unix_timestamp() 
	WHERE Request_Uid=? and esign_requestid=? ;
	 `
	_, lErr = ftdb.NewEkyc_GDB.Exec(linsertQry, pSid, pUid, pEsignID)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = InsertFormStatus(pDebug, pUid, pSid, pSignDocID, pPwsPDF, pEmailBodyRec)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = InsertFormHistory(pDebug, pUid, pEmailBodyRec)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = router.StatusInsert(pDebug, pUid, pSid, "ReviewDetails")
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.InProgress)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = router.CloseAllMsg(pDebug, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = commonpackage.AttachmentlogFile(pUid, "eSigned PDF", pSignDocID, pDebug)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = commonpackage.AttachmentlogFile(pUid, "PWD eSigned PDF", pPwsPDF, pDebug)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "InsertEsignDocID (-)")
	return nil
}

func InsertFormStatus(pDebug *helpers.HelperStruct, pUid, pSid, pSignDocID, pPwsPDF string, pEmailBodyRec EmailBodyStruct) (lErr error) {
	pDebug.Log(helpers.Statement, "InsertFormStatus (+)")
	linsertQry := `UPDATE ekyc_request
	SET 
		Updated_Session_Id = ?,
		UpdatedDate = UNIX_TIMESTAMP(),
		Form_Status = ?,
		eSignedDocid = ?,
		PWD_eSignDocid=?,
		submitted_date = UNIX_TIMESTAMP(),
		Process_Status = null,
		Owner = null
	WHERE Uid = ?;`

	_, lErr = ftdb.NewEkyc_GDB.Exec(linsertQry, pSid, pEmailBodyRec.FormStatus, pSignDocID, pPwsPDF, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "InsertFormStatus (-)")
	return nil
}

func InsertFormHistory(pDebug *helpers.HelperStruct, pUid string, pEmailBodyRec EmailBodyStruct) (lErr error) {
	pDebug.Log(helpers.Statement, "InsertFormHistory (+)")
	Stage := "New"
	if strings.EqualFold(pEmailBodyRec.FormStatus, "RS") {
		Stage = "Re Submit"
	}

	lInsertQry := `INSERT INTO newekyc_formstatus_history(requestUid, stage, status,  CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
					VALUES(?,?,?,?,UNIX_TIMESTAMP(),?,UNIX_TIMESTAMP());`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lInsertQry, pUid, Stage, pEmailBodyRec.FormStatus, pEmailBodyRec.Email, pEmailBodyRec.Email)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "InsertFormHistory (-)")
	return nil
}

// func GetReqestPanNo(pDebug *helpers.HelperStruct, pUid string) (lPagNo string, lErr error) {
// 	pDebug.Log(helpers.Statement, "GetReqestPanNo (+)")
// 	lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
// 	if lErr != nil {
// 		return "", helpers.ErrReturn(lErr)
// 	}
// 	defer lDb.Close()
// 	lQry := `SELECT  Pan
// 	FROM ekyc_request
// 	WHERE Uid =?; `
// 	lRows, lErr := lDb.Query(lQry, pUid)
// 	if lErr != nil {
// 		return "", helpers.ErrReturn(lErr)
// 	}
// 	for lRows.Next() {
// 		lErr := lRows.Scan(&lPagNo)
// 		if lErr != nil {
// 			return "", helpers.ErrReturn(lErr)
// 		}
// 	}
// 	if strings.EqualFold(lPagNo, "") {
// 		return "", helpers.ErrReturn(fmt.Errorf("pan no is not found for the id : %s", pUid))
// 	}

// 	pDebug.Log(helpers.Statement, "GetReqestPanNo (-)")
// 	return lPagNo, nil
// }
