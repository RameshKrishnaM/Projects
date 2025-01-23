package panstatus

import (
	"encoding/json"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"io/ioutil"
	"net/http"
)

func InsertPanStatusDetails(w http.ResponseWriter, req *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)

	lDebug.Log(helpers.Statement, "InsertPanStatusDetails (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Methods", "POST")
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	(w).Header().Set("Content-Type", "application/json")

	// fmt.Println("req test", req)
	if req.Method == "POST" {
		var lPanRespRec PanResponseStruct
		lBody, lErr := ioutil.ReadAll(req.Body)
		lDebug.Log(helpers.Details, "lBody", string(lBody))
		if lErr != nil {
			lDebug.Log(helpers.Elog, "IPSD01 ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		}
		// converting json body value to Structue
		lErr = json.Unmarshal(lBody, &lPanRespRec)
		// cheack where response will not Error
		if lErr != nil {
			lDebug.Log(helpers.Elog, "IPSD02 ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		}

		lSessionId, lUid, lErr := sessionid.GetOldSessionUID(req, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "IPSD03 ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		}
		lDebug.SetReference(lUid)
		
		lErr = PANNoInsertDb(lPanRespRec, lDebug, req, lSessionId, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "IPSD05 ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		} else {
			lDebug.Log(helpers.Details, "Inserted successfully")
			fmt.Fprint(w, helpers.GetMsg_String("S", "Inserted successfully"))
			return
		}
	} else {
		fmt.Fprint(w, helpers.GetError_String("Invalid Method Type", "Kindly try with POST Method"))
	}
	lDebug.Log(helpers.Statement, "InsertPanStatusDetails (-)")
}

// Helper function to update PAN info in database
func updatePANNo(pDebug *helpers.HelperStruct, lPanRecAPI PanDataInfo, lUid string) error {
	pDebug.Log(helpers.Statement, "updatePANNo(+)")
	lPanNo, _, _, lErr := GetPanDataInfo(lUid, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "", lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	if lPanNo == lPanRecAPI.PanNumber || lPanNo == "" {
		pDebug.Log(helpers.Details, "If")
		lSqlString := `update ekyc_request er set er.Pan  = ?, er.DOB = ? where er.Uid  =?`
		_, lErr = ftdb.NewEkyc_GDB.Exec(lSqlString, lPanRecAPI.PanNumber, lPanRecAPI.PanDOB, lUid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "", lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	} else {
		pDebug.Log(helpers.Details, "else")
		lSqlString := `update ekyc_request er,ekyc_address ea set er.Pan  = ?, er.DOB = ?,er.Name_As_Per_KRA = null,er.PanRefId = null,
		er.KRA_App_No = null,ea.KraVerified = null,ea.KRA_Reference_Id = null,
		ea.KRA_agency_Name = null,ea.KraStatusCode = null,ea.FullDetailsFlag = null,ea.Digilockerreferenceid = null
		where er.Uid  = ? and er.Uid = ea.Request_Uid`
		_, lErr = ftdb.NewEkyc_GDB.Exec(lSqlString, lPanRecAPI.PanNumber, lPanRecAPI.PanDOB, lUid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "", lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "updatePANNo(-)")
	return lErr
}
