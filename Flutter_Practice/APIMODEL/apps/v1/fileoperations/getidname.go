package fileoperations

import (
	"encoding/json"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
	"strings"
)

type IdStruct struct {
	Status        string             `json:"status"`
	ProofType     string             `json:"prooftype"`
	IdArr         []FileIdDataStruct `json:"idarr"`
	AadhaarNumber string             `json:"aadhaarNo"`
	AadhaarFlag   string             `json:"aadhaarFlag"`
}
type FileIdDataStruct struct {
	DocId      string      `json:"id"`
	DocType    string      `json:"doctype"`
	Flag       string      `json:"flag"`
	File       interface{} `json:"file"`
	UploadFlag string      `json:"uploadflag"`
}

/*
Purpose : This method is used to fetch the user upload files name in db
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
"Error": "something went wrong"
Author : saravanan selvam
Date : 01-FEB-2024
*/
func GetIdName(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetIdName (+)")

	if r.Method == "GET" {
		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIN01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIN01", "Something went wrong. Please try agin later."))
			return
		}

		lIdRec, lErr := CheckRequerFile(lDebug, lUid, r)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIN02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIN02", "Something went wrong. Please try agin later."))
			return
		}

		lDatas, lErr := json.Marshal(lIdRec)
		lDebug.Log(helpers.Details, "lDatas", string(lDatas))

		if lErr != nil {
			lDebug.Log(helpers.Elog, "GIN03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GIN03", "Something went wrong. Please try agin later."))
			return
		}

		fmt.Fprint(w, string(lDatas))

		lDebug.Log(helpers.Statement, "GetIdName (-)")
		lDebug.RemoveReference()
	}
}

func CheckRequerFile(pDebug *helpers.HelperStruct, pUid string, pReq *http.Request) (lRespRec IdStruct, lErr error) {
	pDebug.Log(helpers.Statement, "CheckRequerFile (+)")

	lRespRec.Status = common.SuccessCode
	lRespRec.IdArr = make([]FileIdDataStruct, 4)

	lSessionId, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(pReq, pDebug, common.EKYCCookieName, pUid)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, lSessionId, lTestUserFlag)

	// lExistSelect := `select nvl(Bank_proof,""),
	// 'Bank_proof','Y' as bank_flag,
	// nvl(Income_proof,""),
	// 'Income_proof',case when exists(select * from ekyc_services es where es.Request_Uid=ea.Request_id and  es.segement_id in ('2','3','4') and Selected='Y') then 'Y'else'N'end as income_flag,
	// nvl(Signature,""),
	// 'Signature','Y'as sign_flag,
	// nvl(Pan_proof,""),
	// 'Pan_proof',case when exists(select * from ekyc_address eaad where eaad.Request_Uid=ea.Request_id and eaad.Source_Of_Address like '%Digilocker%') and nvl(Pan_proof,"")!='' then 'N' else 'Y' end as pan_flag,
	// nvl(Income_prooftype,"") from ekyc_attachments ea where Request_id =  ?
	// and ( ? or ea.UpdatedSesion_Id  = ?);`

	// lNotExistSelect := `select '','Bank_proof','Y' as bank_flag,
	// '','Income_proof',case when exists(select * from ekyc_services es where es.Request_Uid=? and ( ? or es.Updated_Session_Id  = ?) and  es.segement_id in ('2','3','4') and Selected='Y') then 'Y'else'N'end as income_flag,
	// '','Signature','Y'as sign_flag,
	// '','Pan_proof','Y' as pan_flag,
	// '' ;`

	// lSelectqry := `if exists (select * FROM ekyc_attachments WHERE Request_id  = ? and ( ? or UpdatedSesion_Id  = ?))
	// then
	// ` + lExistSelect + `
	// else
	// ` + lNotExistSelect + `
	// end if;`

	lExistSelect := `select nvl(Bank_proof,""),
	'Bank_proof','Y' as bank_flag,
	nvl(Income_proof,""),
	'Income_proof',case when exists(select * from ekyc_services es where es.Request_Uid=ea.Request_id and  es.segement_id in ('2','3','4') and Selected='Y') then 'Y'else'N'end as income_flag,
	nvl(Signature,""),
	'Signature','Y'as sign_flag,
	nvl(Pan_proof,""), 
	'Pan_proof',case when exists(select * from ekyc_address eaad where eaad.Request_Uid=ea.Request_id and eaad.Source_Of_Address like '%Digilocker%') and nvl(Pan_proof,"")!='' then 'N' else 'Y' end as pan_flag,
	nvl(Income_prooftype,"") from ekyc_attachments ea where Request_id =  ?
	;`

	lNotExistSelect := `select '','Bank_proof','Y' as bank_flag,
	'','Income_proof',case when exists(select * from ekyc_services es where es.Request_Uid=? and es.segement_id in ('2','3','4') and Selected='Y') then 'Y'else'N'end as income_flag,
	'','Signature','Y'as sign_flag,
	'','Pan_proof','Y' as pan_flag,
	'' ;`

	lSelectqry := `if exists (select * FROM ekyc_attachments WHERE Request_id  = ?)
	then
	` + lExistSelect + `
	else
	` + lNotExistSelect + `
	end if;`

	// lRows, lErr := lDb.Query(lSelectqry, pUid, lTestUserFlag, lSessionId, pUid, lTestUserFlag, lSessionId, pUid, lTestUserFlag, lSessionId)
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lSelectqry, pUid, pUid, pUid)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()

	for lRows.Next() {
		lErr := lRows.Scan(&lRespRec.IdArr[0].DocId, &lRespRec.IdArr[0].DocType, &lRespRec.IdArr[0].Flag,
			&lRespRec.IdArr[1].DocId, &lRespRec.IdArr[1].DocType, &lRespRec.IdArr[1].Flag,
			&lRespRec.IdArr[2].DocId, &lRespRec.IdArr[2].DocType, &lRespRec.IdArr[2].Flag,
			&lRespRec.IdArr[3].DocId, &lRespRec.IdArr[3].DocType, &lRespRec.IdArr[3].Flag, &lRespRec.ProofType)
		if lErr != nil {
			return lRespRec, helpers.ErrReturn(lErr)
		}
	}
	lExsistAadhaar := `
	SELECT 
    CASE
        WHEN er.AadhraNo IS null OR er.AadhraNo = '' or er.Form_Status = 'RJ' THEN 'Y' 
        ELSE 'N'
    END AS Flag ,nvl(er.AadhraNo,"") 
FROM ekyc_request AS er 
WHERE er.Uid = ?`

	rows, lErr := ftdb.NewEkyc_GDB.Query(lExsistAadhaar, pUid)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}
	defer rows.Close()

	for rows.Next() {
		lErr := rows.Scan(&lRespRec.AadhaarFlag, &lRespRec.AadhaarNumber)
		if lErr != nil {
			return lRespRec, helpers.ErrReturn(lErr)
		}

	}

	// Print the last four digits of AadhaarNumber
	if lRespRec.AadhaarNumber != "" && len(lRespRec.AadhaarNumber) == 12 {
		lRespRec.AadhaarNumber = strings.ReplaceAll(strings.ReplaceAll(lRespRec.AadhaarNumber, "x", ""), "X", "")
	}

	if lErr := rows.Err(); lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "CheckRequerFile (-)")
	return lRespRec, nil
}
