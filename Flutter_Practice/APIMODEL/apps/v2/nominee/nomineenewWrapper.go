package nominee

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/model"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/file"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
	"strconv"
	"strings"
)

func NewPostNomineeFile(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "PostNomineeFile (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "  POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	//log.Println("PostNomineeFile+")
	if r.Method == "POST" {

		var nomineeResp nomineePdfResp

		nomineeResp.Status = common.SuccessCode

		//client, err := appsso.ValidateAndGetClientDetails2(r, common.EKYCAppName, common.EKYCCookieName)
		SessionId, Uid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		lDebug.SetReference(Uid)
		if lErr != nil {
			//common.LogError("nominee.PostNomineeFile", Uid+":(NPNF01)", lErr.Error())
			nomineeResp.Status = common.LoginFailure
			nomineeResp.ErrMsg = "UnExpectedError:(NPNF01)" + lErr.Error()

		} else {
			if Uid != "" {
				nomineeResp.RequestId, lErr = NewNomineeFileSave(r, Uid, SessionId, lDebug)
				if lErr != nil {
					//common.LogError("nominee.PostNomineeFile", Uid+":(NPNF02)", lErr.Error())
					nomineeResp.Status = common.ErrorCode
					nomineeResp.ErrMsg = "UnExpectedError:(NPNF02)" + lErr.Error()
				}

			}
		}

		data, err := json.Marshal(nomineeResp)
		lDebug.Log(helpers.Details, "nominee_endpoint", string(data))
		if err != nil {
			fmt.Fprintf(w, "Error taking data"+err.Error())
		} else {
			fmt.Fprint(w, string(data))
		}

	}
	lDebug.RemoveReference()
	lDebug.Log(helpers.Statement, "PostNomineeFile (-)")

}

func NewNomineeFileSave(r *http.Request, pUid string, SessionId string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "NomineeFileSave+")
	var NomineeCollection []model.NomineeData_Model
	// Note:
	// client==Uuid
	var fileDataCollection []file.FileDataType
	var lFiletypeRec model.KeyPairStruct
	var lFiletypeArr []model.KeyPairStruct
	// left shift 32 << 20 which results in 32*2^20 = 33(m),554(k),432(b)
	// x << y, results in x*2^y
	var lRequestId string
	lErr := r.ParseMultipartForm(32 << 20)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lRequestId, helpers.ErrReturn(errors.New("nominee.NomineeFileSave ," + pUid + ":(NNFS01)"))
		//return lRequestId, lErr
	} else {

		RequestTableId, lErr := GetRequestTableId(pUid, pDebug)
		if lErr != nil {
			// pDebug.Log(helpers.Elog, lErr.Error())
			return lRequestId, helpers.ErrReturn(errors.New("nominee.NomineeFileSave ," + pUid + ":(NNFS04)"))
			//return lRequestId, lErr
		} else {
			//Get all params detals - 1. individuals, 2. File count (iterartive data),
			//3. all files (iterative, based on file count), 4. database operation data, file path (stored in fs),
			//5. prepare response data success, validations, errors

			//DB Get Test call starts
			//Get_Nominee_Db_Details()
			//DB Get Test call ends

			//1. individuals //n := r.Form.Get("name") - for all parameters
			inputJsonData := r.Form.Get("inputJsonData")
			ProcessType := r.Form.Get("ProcessType")
			deletedIds := r.Form.Get("deletedIds")

			pDebug.Log(helpers.Details, "inputJsonData :", string(inputJsonData))
			pDebug.Log(helpers.Details, "ProcessType :", string(ProcessType))
			pDebug.Log(helpers.Details, "deletedIds :", string(deletedIds))

			//2. File count (iterartive)   // n := r.Form.Get("name")

			lErr := json.Unmarshal([]byte(inputJsonData), &NomineeCollection)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return lRequestId, helpers.ErrReturn(errors.New("nominee.NomineeFileSave ," + pUid + ":(NNFS05)"))
				//return lRequestId, lErr
			} else {

				lErr := NewUpdateDeleteFlag(pUid, pDebug)
				if lErr != nil {
					pDebug.Log(helpers.Elog, lErr.Error())
					return lRequestId, helpers.ErrReturn(errors.New("nominee.NomineeFileSave ," + pUid + ":(NNFS07)"))
					//return lRequestId, lErr
				}

				for i := 0; i < len(NomineeCollection); i++ {
					NomineeCollection, lErr := NewProcessNomineeDetails(pUid, fileDataCollection, NomineeCollection[i], RequestTableId, SessionId, pDebug)
					if lErr != nil {
						pDebug.Log(helpers.Elog, lErr.Error())
						return lRequestId, helpers.ErrReturn(errors.New("nominee.NomineeFileSave ," + pUid + ":(NNFS11)"))
						//return lRequestId, lErr
					}
					if NomineeCollection.NomineeFileUploadDocIds != "" {
						lFiletypeRec.FileType = "Nominee Proof " + strconv.Itoa(i+1)
						lFiletypeRec.Value = NomineeCollection.NomineeFileUploadDocIds
						lFiletypeArr = append(lFiletypeArr, lFiletypeRec)
					}

					if NomineeCollection.GuardianFileUploadDocIds != "" {
						lFiletypeRec.FileType = "Guardian Proof " + strconv.Itoa(i+1)
						lFiletypeRec.Value = NomineeCollection.GuardianFileUploadDocIds
						lFiletypeArr = append(lFiletypeArr, lFiletypeRec)
					}
				}

				for _, lFiletypeKey := range lFiletypeArr {
					commonpackage.DocIdActiveOrNOt(pUid, lFiletypeKey.FileType, lFiletypeKey.Value, pDebug)
					if lErr != nil {
						return "", helpers.ErrReturn(lErr)
					}
				}
				lErr = router.StatusInsert(pDebug, pUid, SessionId, "NomineeDetails")
				if lErr != nil {
					pDebug.Log(helpers.Elog, lErr.Error())
					return "", helpers.ErrReturn(lErr)
				}
				lErr = NewDeleteRecords(pUid, pDebug)
				if lErr != nil {
					pDebug.Log(helpers.Elog, lErr.Error())
					return lRequestId, helpers.ErrReturn(errors.New("nominee.NomineeFileSave ," + pUid + ":(NNFS12)"))
					//return lRequestId, lErr
				}
			}
		}

	}
	pDebug.Log(helpers.Statement, "NomineeFileSave-")
	return pUid, nil
}

func NewProcessNomineeDetails(requestId string, fileDataCollection []file.FileDataType, NomineeCollection model.NomineeData_Model, requestTableId int, SessionId string, pDebug *helpers.HelperStruct) (model.NomineeData_Model, error) {

	pDebug.Log(helpers.Statement, "ProcessNomineeDetails (+)")
	pDebug.Log(helpers.Details, "fileDataCollection in ProcessNomineeDetails", fileDataCollection)
	// var NomineeCollection []model.NomineeData_Model
	// var NomineeCollection_API []NomineeData_Model

	// var NomineeKYC NomineeKYC_Model

	//err := json.Unmarshal([]byte(inputJsonData), &NomineeCollection)
	// if err != nil {
	// 	common.LogError("nominee.ProcessNomineeDetails", "(NPND01)", err.Error())
	// 	return err
	// } else {

	// 		DeleteString := `delete from ekyc_nominee_details
	// where RequestId =?`
	// 		_, err := db.Exec(DeleteString, requestId)
	// 		if err != nil {
	// 			common.LogError("nominee.Insert_Nominee_Details", "(NIND01)", err.Error())
	// 			return err
	// 		} else {

	// if strings.EqualFold(NomineeCollection.ModelState, "added") {

	for _, fData := range fileDataCollection {

		// Nominee File
		if len(NomineeCollection.NoimineeFileString) > 0 && strings.EqualFold(fData.FileString, NomineeCollection.NoimineeFileString) {
			data_ids := NomineeCollection.NomineeFileUploadDocIds
			if data_ids == "" {
				data_ids = data_ids + string(fData.DocId)
			}
			NomineeCollection.NomineeFileUploadDocIds = data_ids
		}

		// Guardian File
		pDebug.Log(helpers.Details, "NomineeCollection.GuardianVisible", NomineeCollection.GuardianVisible)
		pDebug.Log(helpers.Details, "NomineeCollection.GuardianFileString", NomineeCollection.GuardianFileString)
		pDebug.Log(helpers.Details, "fData.FileString", fData.FileString)
		pDebug.Log(helpers.Details, "NomineeCollection.GuardianFileString", NomineeCollection.GuardianFileString)

		if NomineeCollection.GuardianVisible && len(NomineeCollection.GuardianFileString) > 0 &&
			strings.EqualFold(fData.FileString, NomineeCollection.GuardianFileString) {

			data_ids := NomineeCollection.GuardianFileUploadDocIds
			if data_ids == "" {
				data_ids = data_ids + string(fData.DocId)
			}

			NomineeCollection.GuardianFileUploadDocIds = data_ids
		}
		pDebug.Log(helpers.Details, "NomineeCollection.GuardianFileUploadDocIds", NomineeCollection.GuardianFileUploadDocIds)
		pDebug.Log(helpers.Details, "NomineeCollection.NomineeFileUploadDocIds", NomineeCollection.NomineeFileUploadDocIds)
		pDebug.Log(helpers.Details, "NomineeCollection.GuardianVisible", NomineeCollection.GuardianVisible)
		// }

	}
	pDebug.Log(helpers.Details, "NomineeCollection.GuardianVisible", NomineeCollection.GuardianVisible)
	if !NomineeCollection.GuardianVisible {
		NomineeCollection.GuardianFileUploadDocIds = ""
		NomineeCollection.GuardianCountry = ""
		NomineeCollection.GuardianAddress1 = ""
		NomineeCollection.GuardianAddress2 = ""
		NomineeCollection.GuardianAddress3 = ""
		NomineeCollection.GuardianCity = ""
		NomineeCollection.GuardianEmailId = ""
		NomineeCollection.GuardianFileName = ""
		NomineeCollection.GuardianFilePath = ""
		NomineeCollection.GuardianFileString = ""
		NomineeCollection.GuardianMobileNo = ""
		NomineeCollection.GuardianName = ""
		NomineeCollection.GuardianPincode = ""
		NomineeCollection.GuardianTitle = ""
		NomineeCollection.GuardianState = ""
	}

	if !strings.EqualFold(NomineeCollection.ModelState, "deleted") {

		lErr := NewInsert_Nominee_Details(NomineeCollection, requestId, requestTableId, SessionId, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return NomineeCollection, helpers.ErrReturn(errors.New("insert Nominee Details"))

		}
	}
	pDebug.Log(helpers.Statement, "ProcessNomineeDetails (-)")

	return NomineeCollection, nil
}

func NewUpdateDeleteFlag(RequestId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "UpdateDeleteFlag (+)")
	corestring := `update ekyc_nominee_details set deleteFlag=1
where RequestId =?`
	_, lErr := ftdb.NewEkyc_GDB.Exec(corestring, RequestId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		//return helpers.ErrReturn(errors.New(lErr))
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "UpdateDeleteFlag (-)")
	return nil
}

func NewDeleteRecords(RequestId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "DeleteRecords (+)")
	DeleteString := `delete from ekyc_nominee_details 
	where RequestId =?
	and deleteFlag=1`
	_, lErr := ftdb.NewEkyc_GDB.Exec(DeleteString, RequestId)

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		//return helpers.ErrReturn(errors.New(lErr))
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "DeleteRecords (-)")
	return nil

}
func NewInsert_Nominee_Details(nomineeData model.NomineeData_Model, requestId string, RequestTableId int, SessionId string, pDebug *helpers.HelperStruct) error {

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
