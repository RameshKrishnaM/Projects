package fileoperations

import (
	"encoding/json"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/pdfgenerate"
	"fcs23pkg/tomlconfig"
	"fmt"
	"net/http"
	"strings"
)

type SingleFileIdDataStruct struct {
	HasPassword string `json:"haspassword"`
	Password    string `json:"password"`
	ProofType   string `json:"prooftype"`
	DocType     string `json:"doctype"`
}
type SingleIdStruct struct {
	UploadFile []SingleFileIdDataStruct `json:"uploadfilearr"`
	PageName   string                   `json:"PageName"`
	MergeFile  MergePdfStruct           `json:"mergefile,omitempty"`
}
type MergePdfStruct struct {
	ProofType string `json:"prooftype,omitempty"`
	FileName  string `json:"filename,omitempty"`
	IsMerge   string `json:"merge,omitempty"`
}
type ImageRespStruct struct {
	Status    string            `json:"status"`
	FileDocID []FileDocIDStruct `json:"docid_info"`
	Message   string            `json:"msg"`
}
type FileDocIDStruct struct {
	FileKey     string `json:"filekey"`
	DocID       string `json:"docid"`
	HasPassword string `json:"haspassword"`
	Password    string `json:"password"`
	PageCount   string `json:"pagecount"`
}

type RespFileUpload struct {
	DocId   string `json:"docid"`
	FileKey string `json:"filekey"`
	Status  string `json:"status"`
}
type ResponseFileUpload struct {
	Status    string           `json:"status"`
	RespIdArr []RespFileUpload `json:"resparr"`
}
type MergeFileStruct struct {
	DocId   []string
	FileKey string `json:"filekey"`
}
type AttachStruct struct {
	AttachDocID string `json:"docid"`
	HasPassword string `json:"haspassword"`
	Password    string `json:"password"`
}

func SingleFileUpload(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "SingleFileUpload (+)")
	if r.Method == "POST" {
		var lRespRec ResponseFileUpload
		var lFileResp RespFileUpload
		var lReqRec SingleIdStruct

		lRespRec.Status = common.SuccessCode
		lFileStruct := r.FormValue("FileStruct")
		lDebug.Log(helpers.Details, "lFileStruct", lFileStruct)
		lErr := json.Unmarshal([]byte(lFileStruct), &lReqRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "FOSFU01 ", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("FOSFU01", "Something went wrong. Please try again later."))
			return
		}

		lDebug.Log(helpers.Details, "lReqRec", lReqRec)

		lSessionId, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)

		if lErr != nil {
			lDebug.Log(helpers.Elog, "FOSFU03 ", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("FOSFU03", "Something went wrong. Please try again later."))
			return
		}
		if lReqRec.MergeFile.IsMerge == common.StatusYes {
			var lDociIDArr []pdfgenerate.AttachStruct
			lFileArr, lErr := ReadMultiFile(lDebug, r, lReqRec.UploadFile)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "FOSFU04 ", lErr.Error())
				if lFileArr.Message != "" && strings.Contains(lFileArr.Message, "pdfcpu: please provide the correct password") {
					fmt.Fprint(w, helpers.GetError_String("FOSFU04", "Please Provide the Correct Password"))
					lDebug.Log(helpers.Elog, "FOSFU04 ", lErr.Error())
					return
				}
				fmt.Fprint(w, helpers.GetError_String("FOSFU04", "Something went wrong. Please try again later."))
				return
			}
			for _, lFileData := range lFileArr.FileDocID {
				var lAttach pdfgenerate.AttachStruct
				lAttach.AttachDocID = lFileData.DocID
				lDociIDArr = append(lDociIDArr, lAttach)
			}
			ProcessType := tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "PDFProcessType3")
			lPDFInfo, lErr := pdfgenerate.MergeFiletoPdf(lDebug, ProcessType, lUid, lSessionId, lDociIDArr)
			if lErr != nil {
				fmt.Fprint(w, helpers.GetError_String("FOSFU05", "Please Provide the Correct Password"))
				lDebug.Log(helpers.Elog, "FOSFU05 ", lErr.Error())
				return
			}
			if lPDFInfo.Docid == "" {
				lDebug.Log(helpers.Elog, "FOSFU06 ", "DOCID Not Found")
				fmt.Fprint(w, helpers.GetError_String("FOSFU06", "Something went wrong. Please try again later."))
				return
			}
			lErr = UpdateTable(lDebug, lReqRec.PageName, lReqRec.MergeFile.FileName, lPDFInfo.Docid, lReqRec.MergeFile.ProofType, lUid, lSessionId)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "FOSFU010 ", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("FOSFU010", "Something went wrong. Please try again later."))
				return
			}

			lErr = commonpackage.AttachmentlogFile(lUid, lReqRec.MergeFile.FileName, lPDFInfo.Docid, lDebug)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "FOSFU011 ", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("FOSFU011", "Something went wrong. Please try again later."))
				return
			}
			lFileResp.Status = common.SuccessCode
			lFileResp.DocId = lPDFInfo.Docid
			lFileResp.FileKey = lReqRec.MergeFile.ProofType
			lRespRec.RespIdArr = append(lRespRec.RespIdArr, lFileResp)

		} else {
			for _, lFile := range lReqRec.UploadFile {
				lDocIdArr, lErr := ReadSingleFile(lDebug, r, lFile)

				if lErr != nil {
					lDebug.Log(helpers.Elog, "FOSFU09 ", lErr.Error())
					if lDocIdArr.Message != "" && strings.Contains(lDocIdArr.Message, "pdfcpu: please provide the correct password") {
						fmt.Fprint(w, helpers.GetError_String("FOSFU09", "Please Provide the Correct Password"))
						lDebug.Log(helpers.Elog, "FOSFU09 ", lErr.Error())
						return
					}
					fmt.Fprint(w, helpers.GetError_String("FOSFU09", "Something went wrong. Please try again later."))
					return
				}

				for _, lFileData := range lDocIdArr.FileDocID {
					lFileResp.Status = common.SuccessCode
					lFileResp.DocId = lFileData.DocID
					lFileResp.FileKey = lFileData.FileKey
					// DocId Change in pariticular Table
					lErr := UpdateTable(lDebug, lReqRec.PageName, lFileData.FileKey, lFileData.DocID, lFile.ProofType, lUid, lSessionId)
					if lErr != nil {
						lDebug.Log(helpers.Elog, "FOSFU010 ", lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("FOSFU010", "Something went wrong. Please try again later."))
						return
					}

					lErr = commonpackage.AttachmentlogFile(lUid, lFileData.FileKey, lFileData.DocID, lDebug)
					if lErr != nil {
						lDebug.Log(helpers.Elog, "FOSFU011 ", lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("FOSFU011", "Something went wrong. Please try again later."))
						return
					}
					if lFileResp.DocId == "" {
						lDebug.Log(helpers.Elog, "FOSFU012 ", "DOCID Not Found")
						fmt.Fprint(w, helpers.GetError_String("FOSFU012", "Something went wrong. Please try again later."))
						return
					}
					lRespRec.RespIdArr = append(lRespRec.RespIdArr, lFileResp)
				}
			}
		}

		lRespData, lErr := json.Marshal(lRespRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "FOSFU013 ", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("FOSFU013", "Something went wrong. Please try again later."))
			return
		}
		fmt.Fprint(w, string(lRespData))
	}
	lDebug.Log(helpers.Statement, "SingleFileUpload (-)")
}
func ReadSingleFile(pDebug *helpers.HelperStruct, r *http.Request, pKey SingleFileIdDataStruct) (pdfgenerate.ImageRespStruct, error) {

	pDebug.Log(helpers.Statement, "ReadSingleFile (+)")

	var lFinalInsertArr []pdfgenerate.FileSaveStruct
	var lDocIdArr pdfgenerate.ImageRespStruct

	lFileSaveStruct, lErr := pdfgenerate.FileToBase64Encode(pDebug, r, pKey.DocType, "Ekyc_proof_upload")
	if lErr != nil {
		return lDocIdArr, helpers.ErrReturn(lErr)
	}
	lFileSaveStruct.HasPassword = pKey.HasPassword
	lFileSaveStruct.Password = pKey.Password

	lFinalInsertArr = append(lFinalInsertArr, lFileSaveStruct)

	lDocIdArr, lErr = pdfgenerate.Savefile(pDebug, lFinalInsertArr)
	if lErr != nil {
		return lDocIdArr, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "ReadSingleFile (-)")

	return lDocIdArr, nil

}

/* Usage of ReadMultiFile
   ReadMultiFile Method is used to save the file and Return the DocId and filekey

   Paramater:-
    - pDebug *helpers.HelperStruct
	- r *http.Request,
	- pKey []SingleFileIdDataStruct
*/
func ReadMultiFile(pDebug *helpers.HelperStruct, r *http.Request, pKey []SingleFileIdDataStruct) (pdfgenerate.ImageRespStruct, error) {

	pDebug.Log(helpers.Statement, "ReadMultiFile (+)")

	var lFinalInsertArr []pdfgenerate.FileSaveStruct
	var lDocIdArr pdfgenerate.ImageRespStruct

	for i := 0; i < len(pKey); i++ {
		lFileSaveStruct, lErr := pdfgenerate.FileToBase64Encode(pDebug, r, pKey[i].DocType, "Ekyc_proof_upload")
		if lErr != nil {
			return lDocIdArr, helpers.ErrReturn(lErr)
		}
		lFileSaveStruct.HasPassword = pKey[i].HasPassword
		lFileSaveStruct.Password = pKey[i].Password
		lFinalInsertArr = append(lFinalInsertArr, lFileSaveStruct)
	}

	lDocIdArr, lErr := pdfgenerate.Savefile(pDebug, lFinalInsertArr)
	if lErr != nil {
		return lDocIdArr, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "ReadMultiFile (-)")
	return lDocIdArr, nil
}

func UpdateTable(pDebug *helpers.HelperStruct, pageName string, pFileKey, pDocId, pProofType string, pUid, pSessionId string) error {
	pDebug.Log(helpers.Statement, "UpdateTable (+)")

	// ADDRESS
	PerManualAddress1Key := tomlconfig.GtomlConfigLoader.GetValueString("kra", "PerManualAddress1")
	PerManualAddress2Key := tomlconfig.GtomlConfigLoader.GetValueString("kra", "PerManualAddress2")
	CorManualAddress1Key := tomlconfig.GtomlConfigLoader.GetValueString("kra", "CorManualAddress1")
	CorManualAddress2Key := tomlconfig.GtomlConfigLoader.GetValueString("kra", "CorManualAddress2")

	PerAddr1Column := tomlconfig.GtomlConfigLoader.GetValueString("kra", "PerAddr1Column")
	PerAddr2Column := tomlconfig.GtomlConfigLoader.GetValueString("kra", "PerAddr2Column")
	CorAddr1Column := tomlconfig.GtomlConfigLoader.GetValueString("kra", "CorAddr1Column")
	CorAddr2Column := tomlconfig.GtomlConfigLoader.GetValueString("kra", "CorAddr2Column")

	// PROOF UPLOAD

	IncomeProof := tomlconfig.GtomlConfigLoader.GetValueString("kra", "IncomeProof")
	BankProof := tomlconfig.GtomlConfigLoader.GetValueString("kra", "BankProof")
	SignatureProof := tomlconfig.GtomlConfigLoader.GetValueString("kra", "SignatureProof")
	PanProof := tomlconfig.GtomlConfigLoader.GetValueString("kra", "PanProof")

	IncomeProofColumn := tomlconfig.GtomlConfigLoader.GetValueString("kra", "IncomeProofColumn")
	BankProofColumn := tomlconfig.GtomlConfigLoader.GetValueString("kra", "BankProofColumn")
	SignatureProofColumn := tomlconfig.GtomlConfigLoader.GetValueString("kra", "SignatureProofColumn")
	PanProofColumn := tomlconfig.GtomlConfigLoader.GetValueString("kra", "PanProofColumn")
	IncomeProofTypeColumn := tomlconfig.GtomlConfigLoader.GetValueString("kra", "IncomeProofTypeColumn")

	var lChangeColumn, lProofTypeColumn string

	if pageName == "Address" {
		if pFileKey == PerManualAddress1Key {
			lChangeColumn = PerAddr1Column
		} else if pFileKey == PerManualAddress2Key {
			lChangeColumn = PerAddr2Column
		} else if pFileKey == CorManualAddress1Key {
			lChangeColumn = CorAddr1Column
		} else if pFileKey == CorManualAddress2Key {
			lChangeColumn = CorAddr2Column
		}

		lErr := ChangeAddressTable(pDebug, pUid, pSessionId, lChangeColumn, pDocId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "UT001")
			return helpers.ErrReturn(lErr)
		}

	} else if pageName == "ProofUpload" {
		if pFileKey == IncomeProof {
			lChangeColumn = IncomeProofColumn
		} else if pFileKey == BankProof {
			lChangeColumn = BankProofColumn
		} else if pFileKey == SignatureProof {
			lChangeColumn = SignatureProofColumn
		} else if pFileKey == PanProof {
			lChangeColumn = PanProofColumn
		}
		lProofTypeColumn = IncomeProofTypeColumn

		lErr := ChangeProofUoploadTable(pDebug, pUid, pSessionId, lChangeColumn, lProofTypeColumn, pProofType, pDocId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "UT002")
			return helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "UpdateTable (-)")
	return nil
}

func ChangeAddressTable(pDebug *helpers.HelperStruct, pUid, pSessionId, pColumn, pDocId string) error {
	pDebug.Log(helpers.Statement, "ChangeAddressTable (+)")

	var lFlag string

	// find the request is already present or not in ekyc_address table
	lCorestring1 := `SELECT CASE WHEN count(*) > 0 THEN 'Y' ELSE 'N' END AS Flag
			FROM ekyc_address
			WHERE Request_Uid  = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring1, pUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CAT001"+lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lFlag)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CAT002"+lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
	}

	// Update record
	if lFlag == "Y" {

		lCoreString2 := `UPDATE ekyc_address
SET UpdatedDate = unix_timestamp(),Updated_Session_Id = ?, ` + pColumn + ` = ` + pDocId + `
WHERE Request_Uid = ? `
		_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString2, pSessionId, pUid)

		if lErr != nil {
			pDebug.Log(helpers.Elog, "CAT003")
			return helpers.ErrReturn(lErr)
		}
		// Insert Record
	} else if lFlag == "N" {

		lCoreString3 := `insert into ekyc_address(Request_Uid,Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate,` + pColumn + `) values(?,?,?,unix_timestamp(),unix_timestamp(),?)`

		_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString3, pUid, pSessionId, pSessionId, pDocId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CAT004")
			return helpers.ErrReturn(lErr)
		}

	}

	pDebug.Log(helpers.Statement, "ChangeAddressTable (-)")
	return nil
}

func ChangeProofUoploadTable(pDebug *helpers.HelperStruct, pUid, pSessionId, pColumn, pProofTypeColumn, pIncomeProofType, pDocId string) error {
	pDebug.Log(helpers.Statement, "ChangeProofUoploadTable (+)")

	var lFlag string
	// find the request is already present or not in ekyc_address table
	lCorestring1 := `SELECT CASE WHEN count(*) > 0 THEN 'Y' ELSE 'N' END AS Flag
			FROM ekyc_attachments
			WHERE Request_id  = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring1, pUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CPUT001"+lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lFlag)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CPUT002"+lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
	}

	if lFlag == "Y" {
		// Update record

		lCoreString2 := `UPDATE ekyc_attachments
SET UpdatedDate = unix_timestamp(),UpdatedSesion_Id = ? ,` + pColumn + ` = ` + pDocId + `,` + pProofTypeColumn + `='` + pIncomeProofType + `'
WHERE Request_id = ? `

		_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString2, pSessionId, pUid)

		if lErr != nil {
			pDebug.Log(helpers.Elog, "CPUT003")
			return helpers.ErrReturn(lErr)
		}

	} else if lFlag == "N" {
		// Insert Record

		lCoreString3 := `insert into ekyc_attachments(Request_id,Session_Id,UpdatedSesion_Id,CreatedDate,UpdatedDate,` + pColumn + `,` + pProofTypeColumn + `) values(?,?,?,unix_timestamp(),unix_timestamp(),?,?)`

		_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString3, pUid, pSessionId, pSessionId, pDocId, pIncomeProofType)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CPUT004")
			return helpers.ErrReturn(lErr)
		}

	}

	pDebug.Log(helpers.Statement, "ChangeProofUoploadTable (-)")
	return nil
}
