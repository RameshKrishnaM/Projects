package dematandservice

import (
	"encoding/json"
	"fcs23pkg/apps/v1/router"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

type DematAndServiceInsertStruct struct {
	DematInfo    DematStruct `json:"dematinfo"`
	ServiceArr   []string    `json:"servicearr"`
	BrokerageArr []string    `json:"brokeragearr"`
}

func DematServeInsert(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "ServeBrokinsert (+)")

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold("POST", r.Method) {
		var lSrevebrockStructRec DematAndServiceInsertStruct
		lBody, lErr := ioutil.ReadAll(r.Body)

		if lErr != nil {
			lDebug.Log(helpers.Elog, "SSB01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("SSB01", "Somthing is wrong please try again later"))
			return
		}
		// converting json body value to Structue
		lDebug.Log(helpers.Details, "lBody", string(lBody))
		lErr = json.Unmarshal(lBody, &lSrevebrockStructRec)

		// cheack where response will not Error
		if lErr != nil {
			lDebug.Log(helpers.Elog, "SSB02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("SSB02", "Somthing is wrong please try again later"))
			return
		}

		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "SSB04", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("SSB03", "Somthing is wrong please try again later"))
			return
		}

		lErr = InsertAndModifyDb(lDebug, lUid, lSid, lSrevebrockStructRec, r)

		if lErr != nil {
			lDebug.Log(helpers.Elog, "SSB03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("SSB05", "Somthing is wrong please try again later"))
			return
		}

		lDebug.Log(helpers.Details, "lUid:", lUid, "lSid:", lSid)

		fmt.Fprint(w, helpers.GetMsg_String("SSB", "INSERT SUCCESS FULLY"))
	}
	lDebug.Log(helpers.Statement, "ServeBrokinsert (-)")

}

func InsertAndModifyDb(pDebug *helpers.HelperStruct, pUid, pSid string, pDematAndServRec DematAndServiceInsertStruct, r *http.Request) (lErr error) {
	pDebug.Log(helpers.Statement, "InsertAndModifyDb (+)")

	lErr = DematInsert(pDebug, pUid, pSid, pDematAndServRec.DematInfo)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	lErr = ServicesUpdate(pDebug, pUid, pSid, pDematAndServRec.ServiceArr)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	lErr = BrokerageUpdate(pDebug, pUid, pSid, pDematAndServRec.BrokerageArr)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.SegmentVerified)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = router.StatusInsert(pDebug, pUid, pSid, "DematDetails")
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(r, pDebug, common.EKYCCookieName, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	if !strings.EqualFold(lTestUserFlag, "0") {
		lErr = IncomeProofFlag(pDebug, pUid, lTestUserFlag)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "InsertAndModifyDb (-)")
	return nil
}

func DematInsert(pDebug *helpers.HelperStruct, pUid, pSid string, pDematRec DematStruct) (lErr error) {

	pDebug.Log(helpers.Statement, "DematInsert (+)")

	insertString := `
	if not exists (select * from ekyc_demat_details where requestuid=?)
	then
	insert into ekyc_demat_details (requestuid,DP_scheme,DIS,EDIS,RunningAccSettlement,Created_Session_Id,Updated_Session_Id,CreatedDate,UpdatedData)
	values(?,?,?,?,?,?,?,unix_timestamp(),unix_timestamp());
	else
	update ekyc_demat_details set DP_scheme=?,DIS=?,EDIS=?,RunningAccSettlement=?,Updated_Session_Id=?,UpdatedData=unix_timestamp()
	where requestuid=?;
	end if;`

	_, lErr = ftdb.NewEkyc_GDB.Exec(insertString, pUid, pUid, pDematRec.DPscheme, pDematRec.DIS, pDematRec.EDIS, pDematRec.RunningAccSettlement, pSid, pSid, pDematRec.DPscheme, pDematRec.DIS, pDematRec.EDIS, pDematRec.RunningAccSettlement, pSid, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "DematInsert (-)")

	return nil
}

func ServicesUpdate(pDebug *helpers.HelperStruct, pUid, pSid string, pServiceArr []string) (lErr error) {
	pDebug.Log(helpers.Statement, "ServicesInsert (+)")

	lQuery := `UPDATE ekyc_services
	SET selected = CASE
		WHEN Mapping IN (` + strings.Join(pServiceArr, ",") + `) THEN 'Y'
		ELSE 'N'
	END,
	u_selected = CASE
		WHEN Mapping IN (` + strings.Join(pServiceArr, ",") + `) THEN 'Y'
		ELSE 'N'
	END,
	Updated_Session_Id = '` + pSid + `',
	UpdatedDate = UNIX_TIMESTAMP()
	WHERE Request_Uid ='` + pUid + `';`
	pDebug.Log(helpers.Details, "lQuery:", lQuery)

	_, lErr = ftdb.NewEkyc_GDB.Exec(lQuery)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "ServicesInsert (-)")
	return nil
}

func BrokerageUpdate(pDebug *helpers.HelperStruct, pUid, pSid string, pBrokerageArr []string) (lErr error) {
	pDebug.Log(helpers.Statement, "BrokerageUpdate (+)")

	lQuery := `UPDATE ekyc_brokerage
	SET Enabled = CASE
		WHEN Mapping IN (` + strings.Join(pBrokerageArr, ",") + `) THEN 'Y'
		ELSE 'N'
	END,
	Updated_Session_Id = '` + pSid + `',
	UpdatedDate = UNIX_TIMESTAMP()
	WHERE Request_Uid ='` + pUid + `';`

	pDebug.Log(helpers.Details, "lQuery:", lQuery)

	_, lErr = ftdb.NewEkyc_GDB.Exec(lQuery)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "BrokerageUpdate (-)")
	return nil
}

func IncomeProofFlag(pDebug *helpers.HelperStruct, pUid, pTestUserFlag string) (lErr error) {
	var lIncomeFlag int
	pDebug.Log(helpers.Statement, "IncomeProofFlag (+)")
	lCoreString := `SELECT 1
		FROM ekyc_services es
		WHERE es.Request_Uid = ?
		AND es.segement_id IN ('2', '3', '4')
		AND es.Selected = 'Y'
		GROUP BY es.Request_Uid`

	rows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	defer rows.Close()

	for rows.Next() {
		lErr := rows.Scan(&lIncomeFlag)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}

	if lIncomeFlag != 1 {
		lErr = UpdateIncomeProof(pDebug, pUid)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
		lErr = UpdateProofFlag(pDebug, pUid)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "IncomeProofFlag (-)")
	return nil
}

func UpdateIncomeProof(pDebug *helpers.HelperStruct, pUid string) (lErr error) {
	pDebug.Log(helpers.Statement, "UpdateIncomeProof (+)")
	lCoreString := `UPDATE ekyc_attachments ea 
	SET ea.Income_proof = NULL,ea.Income_prooftype=NULL	
	WHERE ea.Request_id = ?`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "UpdateIncomeProof (-)")
	return nil
}

func UpdateProofFlag(pDebug *helpers.HelperStruct, pUid string) (lErr error) {
	pDebug.Log(helpers.Statement, "UpdateProofFlag (+)")
	lCoreString := `UPDATE ekyc_attachmentlog_history eah 
	SET eah.isActive = 0
	WHERE eah.Reqid = ? and eah.Filetype='Income_proof'`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "UpdateProofFlag (-)")
	return nil
}
