package uploadDocument

import (
	"encoding/json"
	"fcs23pkg/apps/v2/address/digilocker"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/dematandservice"
	"fcs23pkg/apps/v2/fileoperations"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

type InsertProofDataStruct struct {
	AadhaarNumber string `json:"aadhaarNo"`
	CashOnlyFlag  string `json:"cashOnlyFlag"`
	AadhaarFlag   string `json:"aadhaarFlag"`
	ProofType     string `json:"prooftype"`
	BankProofID   string `json:"bankProof"`
	IncomeProofID string `json:"incomeProof"`
	SignatureID   string `json:"signature"`
	PanProofID    string `json:"panProof"`
}

func InsertProofDetails(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "InsertProofDetails (+)")

	if r.Method == "POST" {
		var lInputRec InsertProofDataStruct
		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "UDIPD01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("UDIPD01", "Something went wrong. Please try again later."))
			return
		}
		lBody, lErr := ioutil.ReadAll(r.Body)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "UDIPD02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("UDIPD02", "Something went wrong. Please try again later."))
			return
		}
		lErr = json.Unmarshal(lBody, &lInputRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "UDIPD03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("UDIPD03", "Something went wrong. Please try again later."))
			return
		}

		_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(r, lDebug, common.EKYCCookieName, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "UDIPD04 ", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("UDIPD04", "Something went wrong. Please try again later."))
			return
		}

		lErr = CashOnlyDataUpdates(lDebug, lInputRec, lSid, lUid, lTestUserFlag)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "UDIPD06 ", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("UDIPD06", "Something went wrong. Please try again later."))
			return
		}

		if lInputRec.AadhaarNumber != "" && len(lInputRec.AadhaarNumber) == 4 {
			lInputRec.AadhaarNumber = "XXXXXXXX" + lInputRec.AadhaarNumber
			lErr := fileoperations.AadhaarDataUpdate(lDebug, lUid, lSid, lInputRec.AadhaarNumber)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "UDIPD07 ", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("UDIPD07", "Something went wrong. Please try again later."))
				return
			}
		}
		if lInputRec.CashOnlyFlag == "Y" {
			lInputRec.IncomeProofID = ""
			lInputRec.ProofType = ""
		}
		lErr = InsertProofData(lDebug, lInputRec, lSid, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "UDIPD08 ", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("UDIPD08", "Something went wrong. Please try again later."))
			return
		}

		lErr = sessionid.UpdateZohoCrmDeals(lDebug, r, common.DocumnetVerified)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "UDIPD09 ", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("UDIPD09", "Something went wrong. Please try again later."))
			return
		}
		lErr = router.StatusInsert(lDebug, lUid, lSid, "DocumentUpload")
		if lErr != nil {
			lDebug.Log(helpers.Elog, "UDIPD10 ", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("UDIPD10", "Something went wrong. Please try again later."))
			return
		}

		fmt.Fprint(w, helpers.GetMsg_String("S", "Inserted Successfully...."))
		lDebug.Log(helpers.Statement, "InsertProofDetails (-)")
	}
}

func CashOnlyDataUpdates(pDebug *helpers.HelperStruct, pInputRec InsertProofDataStruct, pSid, pUid, pTestUserFlag string) error {
	pDebug.Log(helpers.Statement, "CashOnlyDataUpdates (-)")

	lUpdateQuery := `UPDATE ekyc_demat_details SET CashOnly_Flag =?, Updated_Session_Id =?, UpdatedData=UNIX_TIMESTAMP() where requestuid =?`

	_, lErr := ftdb.NewEkyc_GDB.Exec(lUpdateQuery, pInputRec.CashOnlyFlag, pSid, pUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	if strings.EqualFold(pInputRec.CashOnlyFlag, "Y") {
		lErr = dematandservice.CashOnlyUpdate(pDebug, pUid, pSid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
		if !strings.EqualFold(pTestUserFlag, "0") {
			lErr = dematandservice.UpdateIncomeProof(pDebug, pUid)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}

			lErr = dematandservice.UpdateProofFlag(pDebug, pUid)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
	}

	pDebug.Log(helpers.Statement, "CashOnlyDataUpdates (-)")
	return nil
}

func InsertProofData(pDebug *helpers.HelperStruct, pInputRec InsertProofDataStruct, pSid, pUid string) error {
	pDebug.Log(helpers.Statement, "InsertProofData (+)")

	var lSqlString, lCoreString string

	lSqlString = `select 1 
    from ekyc_attachments ea 
    where Request_id = ?`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lSqlString, pUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	if lRows.Next() {
		lCoreString = `UPDATE ekyc_attachments
        SET  Bank_proof=?, Income_proof=?, Signature=?, Pan_proof=?, Income_prooftype=?, UpdatedSesion_Id=?, UpdatedDate=unix_timestamp() 
        WHERE Request_id = ?`
		_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pInputRec.BankProofID, pInputRec.IncomeProofID, pInputRec.SignatureID, pInputRec.PanProofID, pInputRec.ProofType, pSid, pUid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	} else {
		lCoreString = `INSERT INTO ekyc_attachments
        (Request_id, Bank_proof, Income_proof, Signature, Pan_proof, Income_prooftype, Session_Id,  UpdatedSesion_Id, CreatedDate, UpdatedDate)
        VALUES(?, ?, ?, ?, ?, ?, ?, ?, unix_timestamp(), unix_timestamp());`
		_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pUid, pInputRec.BankProofID, pInputRec.IncomeProofID, pInputRec.SignatureID, pInputRec.PanProofID, pInputRec.ProofType, pSid, pSid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}
	var lFiletypeRec digilocker.KeyPairStruct
	var lFiletypeArr []digilocker.KeyPairStruct
	// Check if Bank_proof is not empty
	if pInputRec.BankProofID != "" {
		lFiletypeRec.FileType = "Bank_proof"
		lFiletypeRec.Value = pInputRec.BankProofID
		lFiletypeArr = append(lFiletypeArr, lFiletypeRec)
	}

	// Check if Income_proof is not empty
	if pInputRec.IncomeProofID != "" {
		lFiletypeRec.FileType = "Income_proof"
		lFiletypeRec.Value = pInputRec.IncomeProofID
		lFiletypeArr = append(lFiletypeArr, lFiletypeRec)
	}

	// Check if Signature is not empty
	if pInputRec.SignatureID != "" {
		lFiletypeRec.FileType = "Signature"
		lFiletypeRec.Value = pInputRec.SignatureID
		lFiletypeArr = append(lFiletypeArr, lFiletypeRec)
	}

	// Check if Pan_proof is not empty
	if pInputRec.PanProofID != "" {
		lFiletypeRec.FileType = "Pan_proof"
		lFiletypeRec.Value = pInputRec.PanProofID
		lFiletypeArr = append(lFiletypeArr, lFiletypeRec)
	}
	for _, lFiletypeKey := range lFiletypeArr {

		lErr = commonpackage.DocIdActiveOrNOt(pUid, lFiletypeKey.FileType, lFiletypeKey.Value, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "InsertProofData (-)")
	return nil
}
