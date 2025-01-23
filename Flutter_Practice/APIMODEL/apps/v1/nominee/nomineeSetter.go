package nominee

import (
	"database/sql"
	"errors"
	"fcs23pkg/apps/v1/commonpackage"
	"fcs23pkg/apps/v1/model"
	"fcs23pkg/apps/v1/router"
	"fcs23pkg/file"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	//"fcs23pkg/apps/v1/wall/myaccount/request"
)

func InsertNomineeRequest(db *sql.DB, fileDataCollection []file.FileDataType, client, SessionId string, pDebug *helpers.HelperStruct) ([]file.FileDataType, error) {

	pDebug.Log(helpers.Statement, "InsertNomineeRequest (+)")
	//var requestId string
	var lErr error
	//var reqDetails request.ReqDetails

	// LoggedBy := common.GetLoggedBy(client)
	pDebug.Log(helpers.Details, "fileDataCollection Before Insert", fileDataCollection)
	pDebug.Log(helpers.Details, "length of fileDataCollection: ", len(fileDataCollection))
	if len(fileDataCollection) > 0 {

		//Attachments
		fileDataCollection, lErr = file.InsertIntoAttachments(fileDataCollection, client)
		if lErr != nil {
			// common.LogError("nominee.InsertNomineeRequest", "(NINR01)", err.Error())
			// //return fileDataCollection, requestId, err
			// return fileDataCollection, err

			pDebug.Log(helpers.Elog, lErr.Error())
			return fileDataCollection, helpers.ErrReturn(errors.New("nominee.InsertNomineeRequest--(NINR01)"))
		}

	}
	// reqDetails.Client = client
	// reqDetails.Status = common.StatusNew
	// reqDetails.Type = common.NomineeRequestType

	//requestId, err = request.InsertToTableRequests(db, reqDetails)
	// if err != nil {
	// 	common.LogError("nominee.InsertNomineeRequest", "(NINR02)", err.Error())
	// 	return fileDataCollection, requestId, err
	// }

	pDebug.Log(helpers.Details, "fileDataCollection in InsertNomineeRequest--", fileDataCollection)
	//log.Println("fileDataCollection in InsertNomineeRequest", fileDataCollection)
	pDebug.Log(helpers.Statement, "InsertNomineeRequest (-)")
	//return fileDataCollection, requestId, nil
	return fileDataCollection, nil
}

//Nominee Details starts here

func Insert_Nominee_Details(nomineeData model.NomineeData_Model, requestId string, RequestTableId int, SessionId string, pDebug *helpers.HelperStruct) error {

	pDebug.Log(helpers.Statement, "Insert_Nominee_Details(+)")

	pDebug.Log(helpers.Details, "nomineeData.NomineeFileUploadDocIds", nomineeData.NomineeFileUploadDocIds)
	var lErr error
	//insertedID := ""
	// lAddressInsert.ProofofAddress, lErr = commonpackage.GetDefaultCode(lDb1, pDebug, "AddressProof", lAddressInsert.ProofofAddress)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return helpers.ErrReturn(lErr)
	// }
	nomineeData.NomineeCountry, lErr = commonpackage.GetDefaultCode(pDebug, "country", nomineeData.NomineeCountry)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	nomineeData.NomineeState, lErr = commonpackage.GetDefaultCode(pDebug, "state", nomineeData.NomineeState)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	nomineeData.GuardianCountry, lErr = commonpackage.GetDefaultCode(pDebug, "country", nomineeData.GuardianCountry)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	nomineeData.GuardianState, lErr = commonpackage.GetDefaultCode(pDebug, "state", nomineeData.GuardianState)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	coreString := `insert into ekyc_nominee_details(Request_Table_Id,RequestId,NomineeName,NomineeRelationship,NomineeShare,NomineeDOB,NomineeAddress1,NomineeAddress2,NomineeAddress3,U_NomineeAddress1,U_NomineeAddress2,U_NomineeAddress3,NomineeCity,NomineeState,NomineeCountry,NomineePincode,
			NomineeMobileNo,NomineeEmailId,NomineeProofOfIdentity,NomineeProofNumber,NomineeProofPlaceOfIssue,NomineeProofDateOfIssue,NomineeProofExpriyDate,NomineeFileUploadDocIds,GuardianVisible,GuardianName,GuardianRelationship,GuardianAddress1,GuardianAddress2,GuardianAddress3,U_GuardianAddress1,U_GuardianAddress2,U_GuardianAddress3,
			GuardianCity,GuardianState,GuardianCountry,GuardianPincode,GuardianMobileNo,GuardianEmailId,GuardianProofOfIdentity,GuardianProofNumber,GuardianProofPlaceOfIssue,GuardianProofDateOfIssue,GuardianProofExpriyDate,GuardianFileUploadDocIds,ActionState,deleteFlag,Active,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,Nominee_Title,Guardian_Title)
			values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,0,1,?,now(),?,now(),?,?)`

	_, lErr = ftdb.NewEkyc_GDB.Exec(coreString, RequestTableId, requestId, nomineeData.NomineeName, nomineeData.NomineeRelationship, nomineeData.NomineeShare, nomineeData.NomineeDOB, nomineeData.NomineeAddress1,
		nomineeData.NomineeAddress2, nomineeData.NomineeAddress3, nomineeData.NomineeAddress1,
		nomineeData.NomineeAddress2, nomineeData.NomineeAddress3, nomineeData.NomineeCity, nomineeData.NomineeState, nomineeData.NomineeCountry, nomineeData.NomineePincode, nomineeData.NomineeMobileNo, nomineeData.NomineeEmailId,
		nomineeData.NomineeProofOfIdentity, nomineeData.NomineeProofNumber, nomineeData.NomineePlaceofIssue, nomineeData.NomineeProofDateofIssue, nomineeData.NomineeProofExpriyDate, nomineeData.NomineeFileUploadDocIds,
		nomineeData.GuardianVisible, nomineeData.GuardianName, nomineeData.GuardianRelationship, nomineeData.GuardianAddress1, nomineeData.GuardianAddress2, nomineeData.GuardianAddress3, nomineeData.GuardianAddress1, nomineeData.GuardianAddress2, nomineeData.GuardianAddress3, nomineeData.GuardianCity,
		nomineeData.GuardianState, nomineeData.GuardianCountry, nomineeData.GuardianPincode, nomineeData.GuardianMobileNo, nomineeData.GuardianEmailId, nomineeData.GuardianProofOfIdentity, nomineeData.GuardianProofNumber, nomineeData.GuardianPlaceofIssue, nomineeData.GuardianProofDateofIssue, nomineeData.GuardianProofExpriyDate, nomineeData.GuardianFileUploadDocIds, nomineeData.ModelState, SessionId, SessionId, nomineeData.NomineeTitle, nomineeData.GuardianTitle)

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(errors.New("nominee.Insert_Nominee_Details--(NIND02)"))

	} else {
		// returnId, _ := insertRes.LastInsertId()
		// log.Println("Request returnId: ", returnId)
		// insertedID = strconv.FormatInt(returnId, 10)
		// log.Println("insertedID: ", insertedID)
		lErr = router.StatusInsert(pDebug, requestId, SessionId, "NomineeDetails")
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(errors.New("nominee.Insert_Nominee_Details--(NIND03)"))
		}
		pDebug.Log(helpers.Details, "inserted successfully")

	}
	pDebug.Log(helpers.Statement, "Insert_Nominee_Details(-)")

	return nil
}
