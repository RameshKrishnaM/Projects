package sessionid

import (
	"encoding/json"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/adminAlert"
	"fcs23pkg/integration/v2/zohointegration"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
)

// --------------------------------------------------------------------
// function syncs deal info and assign RM
// --------------------------------------------------------------------
type updatedealstruct struct {
	Ownerid         string `json:"owner_id"`
	Dealid          string `json:"deal_id"`
	OwnerEmail      string `json:"owner_email"`
	Orig_system_ref string `json:"orig_system_ref"`
	Orig_system     string `json:"orig_system"`
}

func ZohoCRMDealUpdate(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.Init()
	(w).Header().Set("Access-Control-Allow-Origin", "*")
	(w).Header().Set("Access-Control-Allow-Methods", "POST")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	w.WriteHeader(200)
	lDebug.Log(helpers.Statement, "ZohoCRMDealUpdate (+)")

	if !strings.EqualFold(r.Method, "POST") {
		lDebug.Log(helpers.Elog, "check your api request", r.Method)
		AdminEmailAlert(lDebug, "invalid api call format "+r.Method, "newekyc_flow", r.URL.Path)
		return
	}

	lBody, lErr := ioutil.ReadAll(r.Body)
	if lErr != nil {
		lDebug.Log(helpers.Elog, lErr)
		AdminEmailAlert(lDebug, lErr.Error(), "newekyc_flow", r.URL.Path)
		return
	}
	lDebug.Log(helpers.Details, string(lBody))

	var lDealInputRec updatedealstruct

	//  body read method
	// v, lErr := url.Parse("http://hello.com/?" + string(lBody))
	// if lErr != nil {
	// 	lDebug.Log(helpers.Elog, lErr)
	// 	AdminEmailAlert(lDebug, lErr.Error(), "newekyc_flow", r.URL.Path)
	// 	return
	// }
	// //get parameter values

	// lQry := v.Query()
	// lDealInputRec.Ownerid = lQry.Get("ownerid")
	// lDealInputRec.Dealid = lQry.Get("dealid")
	// lDealInputRec.OwnerEmail = lQry.Get("owneremail")
	// lDealInputRec.Orig_system_ref = lQry.Get("origsystemref")

	// body Unmarshal

	lErr = json.Unmarshal(lBody, &lDealInputRec)
	if lErr != nil {
		lDebug.Log(helpers.Elog, lErr)
		AdminEmailAlert(lDebug, lErr.Error(), "newekyc_flow", r.URL.Path)
		return
	}
	if lDealInputRec.Orig_system_ref != "" {

		lDebug.Log(helpers.Details, lDealInputRec.Orig_system, "lDealInputRec.Orig_system")

		if strings.EqualFold(lDealInputRec.Orig_system, "NRI") {
			lErr = ZohoCrmDealUpdateNRI(lDebug, lDealInputRec)
			if lErr != nil {
				lDebug.Log(helpers.Elog, lErr)
				AdminEmailAlert(lDebug, helpers.ErrPrint(lErr), "newekyc_flow", r.URL.Path)
				return
			}
		}
		lDebug.Log(helpers.Details, "lDealInputRec", lDealInputRec)
		lErr = InsertRMHistory(lDebug, lDealInputRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr)
			AdminEmailAlert(lDebug, helpers.ErrPrint(lErr), "newekyc_flow", r.URL.Path)
			return
		}

		lErr = InsertOwnerEmail(lDebug, lDealInputRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr)
			AdminEmailAlert(lDebug, helpers.ErrPrint(lErr), "newekyc_flow", r.URL.Path)
			return
		}
		lErr = EkycStaffHistory(lDebug, lDealInputRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr)
			AdminEmailAlert(lDebug, helpers.ErrPrint(lErr), "newekyc_flow", r.URL.Path)
			return
		}
		lErr = FormStatusHistory(lDebug, lDealInputRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr)
			AdminEmailAlert(lDebug, helpers.ErrPrint(lErr), "newekyc_flow", r.URL.Path)
			return
		}

		lErr = GetCRMID(lDebug, lDealInputRec.OwnerEmail, lDealInputRec.Ownerid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr)
			AdminEmailAlert(lDebug, helpers.ErrPrint(lErr), "newekyc_flow", r.URL.Path)
			return
		}

	}

	fmt.Fprintf(w, "200")
	lDebug.Log(helpers.Statement, "ZohoCRMDealUpdate (-)")
	log.Println("ZohoCRMDealUpdate-")

}

func ZohoCrmDealUpdateNRI(pDebug *helpers.HelperStruct, pDealInputRec updatedealstruct) (lErr error) {
	pDebug.Log(helpers.Statement, "ZohoCrmDealUpdateNRI (+)")

	lPayload, lErr := json.Marshal(pDealInputRec)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	lErr = zohointegration.ZohoCrmDealUpdateNRI(pDebug, string(lPayload))
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "ZohoCrmDealUpdateNRI (-)")
	return nil
}

func AdminEmailAlert(pDebug *helpers.HelperStruct, pMsg, pSource, pEndPoint string) {
	pDebug.Log(helpers.Statement, "TrigearEmailToAdmin (+)")
	pMsg = fmt.Sprintf("ZohoCRMDealUpdate (%s)", pMsg)
	lErr := adminAlert.Email(pMsg, pSource, pEndPoint, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr)
	}
	pDebug.Log(helpers.Statement, "TrigearEmailToAdmin (-)")
}

func GetCRMID(pDebug *helpers.HelperStruct, pOwnerEmail, pCRMID string) (lErr error) {
	pDebug.Log(helpers.Statement, "GetCRMID (+)")
	var lEmailID, lCrmID string

	pDebug.Log(helpers.Details, "pOwnerEmail - GetCRMID :", pOwnerEmail)
	pDebug.Log(helpers.Details, "pCRMID - GetCRMID :", pCRMID)

	lQry := `select nvl(z.EmailId,''), nvl(z.CRM_ID,'') 
	from zohodepartmentmapping z 
	where z.EmailId =?;`
	lRowInfo, lErr := ftdb.NewEkyc_GDB.Query(lQry, pOwnerEmail)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	defer lRowInfo.Close()
	for lRowInfo.Next() {
		lErr = lRowInfo.Scan(&lEmailID, &lCrmID)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Details, "lEmailID - GetCRMID :", lEmailID)
	pDebug.Log(helpers.Details, "lCrmID - GetCRMID :", lCrmID)

	// fmt.Println("lEmailID", lEmailID)
	if strings.EqualFold(lEmailID, "") {
		return helpers.ErrReturn(fmt.Errorf("the given email id (%s) not found in zoho department mapping", pOwnerEmail))
	} else if strings.EqualFold(lCrmID, "") {

		lErr = UpdateCRMID(pDebug, pOwnerEmail, pCRMID)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
		// return lCrmID, helpers.ErrReturn(fmt.Errorf("the given (%s) email id not have CRM ID in zoho department mapping", pOwnerEmail))
	}
	pDebug.Log(helpers.Statement, "GetCRMID (-)")
	return nil
}

func InsertOwnerEmail(pDebug *helpers.HelperStruct, pDealInputRec updatedealstruct) (lErr error) {
	pDebug.Log(helpers.Statement, "InsertOwnerEmail (+)")

	pDebug.Log(helpers.Details, "pDealInputRec.OwnerEmail - InsertOwnerEmail :", pDealInputRec.OwnerEmail)
	pDebug.Log(helpers.Details, "pDealInputRec.Orig_system_ref - InsertOwnerEmail :", pDealInputRec.Orig_system_ref)

	lQry := `UPDATE ekyc_request
	SET Staff=?, UpdatedDate=unix_timestamp() 
	WHERE Uid=?;`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lQry, pDealInputRec.OwnerEmail, pDealInputRec.Orig_system_ref)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "InsertOwnerEmail (-)")
	return nil
}

func InsertRMHistory(pDebug *helpers.HelperStruct, pDealInputRec updatedealstruct) (lErr error) {
	pDebug.Log(helpers.Statement, "InsertRMHistory (+)")

	pDebug.Log(helpers.Details, "pDealInputRec.Ownerid - InsertRMHistory :", pDealInputRec.Ownerid)
	pDebug.Log(helpers.Details, "pDealInputRec.Dealid - InsertRMHistory :", pDealInputRec.Dealid)
	pDebug.Log(helpers.Details, "pDealInputRec.OwnerEmail - InsertRMHistory :", pDealInputRec.OwnerEmail)
	pDebug.Log(helpers.Details, "pDealInputRec.Orig_system_ref - InsertRMHistory :", pDealInputRec.Orig_system_ref)

	lQry := `INSERT INTO newekyc_zohocrm_rm_history
	(owner_id, deal_id, owner_email, original_sys_ref, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
	VALUES(?,?,?,?,'CRM API',unix_timestamp(),'CRM API',unix_timestamp());`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lQry, pDealInputRec.Ownerid, pDealInputRec.Dealid, pDealInputRec.OwnerEmail, pDealInputRec.Orig_system_ref)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "InsertRMHistory (-)")
	return nil
}

func EkycStaffHistory(pDebug *helpers.HelperStruct, pDealInputRec updatedealstruct) (lErr error) {
	pDebug.Log(helpers.Statement, "EkycStaffHistory (+)")

	pDebug.Log(helpers.Details, "pDealInputRec.OwnerEmail - EkycStaffHistory :", pDealInputRec.OwnerEmail)
	pDebug.Log(helpers.Details, "pDealInputRec.Orig_system_ref - EkycStaffHistory :", pDealInputRec.Orig_system_ref)

	lQry := `INSERT INTO ekyc_staff_history
	( requestUid, Staff, Status, Reason, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
	VALUES(?, ?, 'AM', 'New form assigned', 'CRM API', unix_timestamp(), 'CRM API', unix_timestamp());`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lQry, pDealInputRec.Orig_system_ref, pDealInputRec.OwnerEmail)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "EkycStaffHistory (-)")
	return nil
}
func FormStatusHistory(pDebug *helpers.HelperStruct, pDealInputRec updatedealstruct) (lErr error) {
	pDebug.Log(helpers.Statement, "FormStatusHistory (+)")

	pDebug.Log(helpers.Details, "pDealInputRec.Orig_system_ref - FormStatusHistory :", pDealInputRec.Orig_system_ref)
	pDebug.Log(helpers.Details, "pDealInputRec.OwnerEmail - FormStatusHistory :", pDealInputRec.OwnerEmail)

	lQry := `INSERT INTO newekyc_formstatus_history
	( requestUid, stage, status, assignTo, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
	VALUES( ?, 'RM Assigned', 'AM', ?, 'CRM API', unix_timestamp(), 'CRM API', unix_timestamp());`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lQry, pDealInputRec.Orig_system_ref, pDealInputRec.OwnerEmail)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "FormStatusHistory (-)")
	return nil
}

func UpdateCRMID(pDebug *helpers.HelperStruct, pOwnerEmail, pCRMID string) (lErr error) {
	pDebug.Log(helpers.Statement, "UpdateCRMID (+)")

	pDebug.Log(helpers.Details, "pOwnerEmail - UpdateCRMID :", pOwnerEmail)
	pDebug.Log(helpers.Details, "pCRMID - UpdateCRMID :", pCRMID)

	lQry := `UPDATE zohodepartmentmapping
	SET CRM_ID= ?,UpdatedProgram='FLOW(CRM API)', UpdatedDate=now() 
	WHERE EmailId= ?;`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lQry, pCRMID, pOwnerEmail)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "UpdateCRMID (-)")
	return nil
}
