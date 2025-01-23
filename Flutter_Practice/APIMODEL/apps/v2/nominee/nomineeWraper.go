package nominee

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/model"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/file"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"net/http"
	"strconv"
	"strings"
)

// Age Calculation

// func isNomineeMinor(pDob string, pDebug *helpers.HelperStruct) (string, error) {
// 	lResult := "N"
// 	lFormatedDob, lErr := time.Parse("02/01/2006", pDob)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "Error parsing date:", lErr)
// 		return lResult, helpers.ErrReturn(lErr)
// 	}

// 	// Calculate age
// 	now := time.Now()
// 	years := now.Year() - lFormatedDob.Year()
// 	months := int(now.Month()) - int(lFormatedDob.Month())
// 	days := now.Day() - lFormatedDob.Day()

// 	// Adjust age if birthday hasn't occurred yet this year
// 	if months < 0 || (months == 0 && days < 0) {
// 		years--
// 	}

// 	// Check if age is less than 18
// 	if years < 18 {
// 		lResult = "Y"
// 	}
// 	return lResult, nil
// }

// wrapper for PostNomineeFile

func NomineeFileSave(r *http.Request, pUid string, SessionId string, pDebug *helpers.HelperStruct) (string, error) {
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
				FileCount, lErr := strconv.Atoi(r.Form.Get("FileCount"))
				// fmt.Println(FileCount, "FileCount-------------------------------")
				if lErr != nil {
					pDebug.Log(helpers.Elog, lErr.Error())
					return lRequestId, helpers.ErrReturn(errors.New("nominee.NomineeFileSave ," + pUid + ":(NNFS06)"))
					//return lRequestId, lErr
				} else {
					lErr := UpdateDeleteFlag(pUid, pDebug)
					if lErr != nil {

						pDebug.Log(helpers.Elog, lErr.Error())
						return lRequestId, helpers.ErrReturn(errors.New("nominee.NomineeFileSave ," + pUid + ":(NNFS07)"))
						//return lRequestId, lErr
					} else {
						// for i := 0; i < len(NomineeCollection); i++ {
						// 	isNomineeMinor, lErr := isNomineeMinor(NomineeCollection[i].NomineeDOB, pDebug)
						// 	if lErr != nil {
						// 		pDebug.Log(helpers.Elog, lErr.Error())
						// 		return lRequestId, helpers.ErrReturn(errors.New("nominee.NomineeFileSave ," + pUid + ":(NNFS07)"))
						// 		//return lRequestId, lErr
						// 	}
						// 	pDebug.Log(helpers.Details, isNomineeMinor, "isNomineeMinor")
						// if NomineeCollection[i].NomineeFileUploadDocIds == "" || (NomineeCollection[i].GuardianName != "" && NomineeCollection[i].GuardianFileUploadDocIds == "") {
						fileDataCollection, lErr = RetriveAndStore_NomineeFileData(FileCount, r, pDebug)
						//_, err := RetriveAndStore_NomineeFileData(FileCount, r)
						pDebug.Log(helpers.Details, "fileDataCollection in Line 66 ", fileDataCollection)
						if lErr != nil {
							pDebug.Log(helpers.Elog, lErr.Error())
							return lRequestId, helpers.ErrReturn(errors.New("nominee.NomineeFileSave ," + pUid + ":(NNFS08)"))
							//return lRequestId, lErr
						}
						// }

						// }
						for i := 0; i < len(NomineeCollection); i++ {
							NomineeCollection, lErr := ProcessNomineeDetails(pUid, fileDataCollection, NomineeCollection[i], RequestTableId, SessionId, pDebug)
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
							lErr = commonpackage.AttachmentlogFile(pUid, lFiletypeKey.FileType, lFiletypeKey.Value, pDebug)
							if lErr != nil {
								return "", helpers.ErrReturn(lErr)
							}
						}

						lErr = router.StatusInsert(pDebug, pUid, SessionId, "NomineeDetails")
						if lErr != nil {
							pDebug.Log(helpers.Elog, lErr.Error())
							return "", helpers.ErrReturn(lErr)
						}
						lErr := DeleteRecords(pUid, pDebug)
						if lErr != nil {
							pDebug.Log(helpers.Elog, lErr.Error())
							return lRequestId, helpers.ErrReturn(errors.New("nominee.NomineeFileSave ," + pUid + ":(NNFS12)"))
							//return lRequestId, lErr
						}
					}
				}
			}
		}

	}
	pDebug.Log(helpers.Statement, "NomineeFileSave-")
	return pUid, nil
}

func ProcessNomineeDetails(requestId string, fileDataCollection []file.FileDataType, NomineeCollection model.NomineeData_Model, requestTableId int, SessionId string, pDebug *helpers.HelperStruct) (model.NomineeData_Model, error) {

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

		// }

	}

	if !strings.EqualFold(NomineeCollection.ModelState, "deleted") {

		lErr := Insert_Nominee_Details(NomineeCollection, requestId, requestTableId, SessionId, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return NomineeCollection, helpers.ErrReturn(errors.New("insert Nominee Details"))

		}
	}
	pDebug.Log(helpers.Statement, "ProcessNomineeDetails (-)")

	return NomineeCollection, nil
}

// wrapper for Get_Nominee_Pdf

func UpdateDeleteFlag(RequestId string, pDebug *helpers.HelperStruct) error {
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

func DeleteRecords(RequestId string, pDebug *helpers.HelperStruct) error {
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
