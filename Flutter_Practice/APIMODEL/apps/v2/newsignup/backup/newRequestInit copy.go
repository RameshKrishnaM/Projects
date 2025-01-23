package newsignup

// import (
// 	"crypto/sha256"
// 	"database/sql"
// 	"encoding/hex"
// 	"encoding/json"
// 	"errors"
// 	"fcs23pkg/apps/v2/otp"
// 	"fcs23pkg/common"
// 	"fcs23pkg/ftdb"
// 	"fcs23pkg/helpers"
// 	backofficecheck "fcs23pkg/integration/v1/backofficeCheck"
// 	"fmt"
// 	"net/http"
// 	"strings"

// 	uuid "github.com/satori/go.uuid"
// )

// type ExistingDataStruct struct {
// 	ReqUid           string `json:"requid"`
// 	TempUid          string `json:"tempuid"`
// 	Phone            string `json:"phone"`
// 	Email            string `json:"email"`
// 	IsExisting       string `json:"isexisting"`
// 	FormStatus       string `json:"formstatus"`
// 	CreatedSessionId string
// 	UpdatedSessionId string
// }

// func NewRequestInit(pDebug *helpers.HelperStruct, pValidationRec UserStruct, r *http.Request, w http.ResponseWriter) {

// 	var lOtpSuccessResp OtpValRespStruct

// 	lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "NRI001", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("NRI001", "Somthing is wrong please try again later"))
// 		return
// 	}
// 	defer lDb.Close()

// 	pDebug.Log(helpers.Details, fmt.Sprintf("pValidationRec %v", pValidationRec))

// 	// if pValidationRec.Phone == "" {
// 	// 	pDebug.Log(helpers.Elog, "Page reload")
// 	// 	fmt.Fprint(w, helpers.GetError_String("R", "Somthing is wrong please try again later"))
// 	// 	return
// 	// }

// 	// if condition only for development purpose
// 	if strings.ToUpper(common.BOCheck) != "N" {
// 		//back office check

// 		var lBoMobStatus, lBoEmailStatus, lBoVerifyBoth bool
// 		if pValidationRec.OtpType == "EMAIL" {

// 			lBofficeEmailStatus, lErr := backofficecheck.BofficeCheck(pDebug, pValidationRec.Email, "EMAIL")
// 			if lErr != nil {
// 				pDebug.Log(helpers.Elog, "NRI002", lErr.Error())
// 				fmt.Fprint(w, helpers.GetError_String("NRI002", "Somthing is wrong please try again later"))
// 				return
// 			}
// 			//check user Email already exist
// 			if lBofficeEmailStatus {
// 				pDebug.Log(helpers.Elog, "NRI003", "The given Email ID has an account with us")
// 				fmt.Fprint(w, helpers.GetError_String("EC", "The given Email ID has an account with us"))
// 				return
// 			}
// 			lBoVerifyBoth = true
// 		}
// 		//get moble status
// 		if pValidationRec.OtpType == "phone" || lBoVerifyBoth {
// 			lBofficeMobStatus, lErr := backofficecheck.BofficeCheck(pDebug, pValidationRec.Phone, "mobile")
// 			if lErr != nil {
// 				pDebug.Log(helpers.Elog, "NRI004", lErr.Error())
// 				fmt.Fprint(w, helpers.GetError_String("NRI004", "Somthing is wrong please try again later"))
// 				return
// 			}
// 			//check user mobile already exist
// 			if lBofficeMobStatus {
// 				pDebug.Log(helpers.Elog, "NRI005", "The given Mobile number has an account with us")
// 				fmt.Fprint(w, helpers.GetError_String("MC", "The given Mobile number has an account with us"))
// 				return
// 			}
// 		}

// 		if lBoVerifyBoth {
// 			pDebug.Log(helpers.Details, "lBofficeMobStatus && lBofficeEmailStatus", lBoMobStatus, lBoEmailStatus)
// 			//check user backoffice status
// 			if lBoMobStatus && lBoEmailStatus {
// 				pDebug.Log(helpers.Elog, "NRI006", "The given Mobile number and Email ID has an account with us")
// 				fmt.Fprint(w, helpers.GetError_String("MEA", "The given Mobile number and Email ID has an account with us"))
// 				return
// 			}
// 		}
// 	}

// 	lSearchData := ""
// 	if strings.EqualFold(pValidationRec.OtpType, "phone") {
// 		lSearchData = pValidationRec.Phone
// 	} else {
// 		lSearchData = pValidationRec.Email
// 	}

// 	lExistingData, lErr := GetExistingData(pDebug, pValidationRec.OtpType, lSearchData)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "NRI007", lErr.Error())
// 		fmt.Fprint(w, helpers.GetError_String("NRI007", "Somthing is wrong please try again later"))
// 		return

// 	}
// 	pDebug.Log(helpers.Details, fmt.Sprintf("lExistingData %v", lExistingData))

// 	if strings.EqualFold(pValidationRec.OtpType, "phone") && strings.EqualFold(lExistingData.IsExisting, "N") {

// 		lErr = InsertNewTempRequest(pDebug, lDb, pValidationRec)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "NRI008", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("NRI008", "Somthing is wrong please try again later"))
// 			return

// 		}
// 	} else if strings.EqualFold(pValidationRec.OtpType, "phone") && strings.EqualFold(lExistingData.IsExisting, "Y") {
// 		lEmailOtpResp, lErr := SendOtpToEmail(pDebug, pValidationRec, lExistingData.Email, r)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "NRI009", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("NRI009", "Somthing is wrong please try again later"))
// 			return

// 		}
// 		if lEmailOtpResp.Status == "S" {
// 			lOtpSuccessResp.Status = "S"
// 			lOtpSuccessResp.Description = "OTP Verified Sucessfully !"
// 			lOtpSuccessResp.AttemptCount = lEmailOtpResp.AttemptCount
// 			lOtpSuccessResp.Encryptedval = lEmailOtpResp.Encryptedval
// 			lOtpSuccessResp.InsertedID = lEmailOtpResp.InsertedID

// 			lData, lErr := json.Marshal(lOtpSuccessResp)
// 			if lErr != nil {
// 				pDebug.Log(helpers.Elog, "NRI010", lErr.Error())
// 				fmt.Fprint(w, helpers.GetMsg_String("S", "OTP Verify Successfully"))
// 				return
// 			}

// 			fmt.Fprint(w, string(lData))
// 			return
// 		} else {
// 			fmt.Fprint(w, helpers.GetMsg_String("S", "OTP Verify Successfully"))
// 			return
// 		}

// 	}

// 	if strings.EqualFold(pValidationRec.OtpType, "email") && lExistingData.Email != pValidationRec.Email {

// 		if lExistingData.FormStatus == "" {
// 			lErr = UpdateExistingRequest(pDebug, lDb, pValidationRec.Email, lExistingData.UpdatedSessionId, lExistingData.ReqUid)
// 			if lErr != nil {
// 				pDebug.Log(helpers.Elog, "NRI011", lErr.Error())
// 				fmt.Fprint(w, helpers.GetError_String("NRI011", "Somthing is wrong please try again later"))
// 				return
// 			}
// 		}

// 		if lExistingData.FormStatus == "" {
// 			lErr = InsertNewRequest(pDebug, lDb, lExistingData.CreatedSessionId, lExistingData.TempUid)
// 			if lErr != nil {
// 				pDebug.Log(helpers.Elog, "NRI011", lErr.Error())
// 				fmt.Fprint(w, helpers.GetError_String("NRI011", "Somthing is wrong please try again later"))
// 				return
// 			}

// 			lErr = DeActiveExistingRecord(pDebug, lDb, lExistingData.ReqUid)
// 			if lErr != nil {
// 				pDebug.Log(helpers.Elog, "NRI011", lErr.Error())
// 				fmt.Fprint(w, helpers.GetError_String("NRI011", "Somthing is wrong please try again later"))
// 				return
// 			}
// 		}
// 	} else {
// 		fmt.Fprint(w, helpers.GetMsg_String("S", "OTP Verify Successfully"))
// 		return
// 	}
// }

// // func NewRequestInit2(pDebug *helpers.HelperStruct, pValidationRec UserStruct, r *http.Request, w http.ResponseWriter) {
// // 	pDebug.Log(helpers.Statement, "NewRequestInit(+)")

// // 	lDb, lErr := ftdb.LocalDbConnect(ftdb.MariaEKYCPRD)
// // 	if lErr != nil {
// // 		pDebug.Log(helpers.Elog, lErr.Error())
// // 		return pOtpResp, helpers.ErrReturn(errors.New(" Somthing went wrong please try again later"))

// // 	}
// // 	defer lDb.Close()

// // 	pDebug.Log(helpers.Details, fmt.Sprintf("pValidationRec %v", pValidationRec))

// // 	if pValidationRec.Phone == "" {
// // 		pDebug.Log(helpers.Elog, "NRI001", "Page reload")
// // 		return pOtpResp, helpers.ErrReturn(errors.New(" Somthing went wrong please try again later"))
// // 	}

// // 	if strings.ToUpper(common.BOCheck) != "N" {
// // 		if pValidationRec.OtpType == "phone" {

// // 			isBoMobileExists, lErr := backofficecheck.BofficeCheck(pDebug, pValidationRec.Phone, "phone")
// // 			if lErr != nil {
// // 				pDebug.Log(helpers.Elog, "NRI002", lErr.Error())
// // 				fmt
// // 				return pOtpResp, helpers.ErrReturn(errors.New(" Somthing went wrong please try again later"))
// // 				// helpers.GetError_String("MEA", "The given Mobile number and Email ID has an account with us")
// // 			}

// // 			if isBoMobileExists {
// // 				pDebug.Log(helpers.Elog, "The given Mobile number and Email ID has an account with us")
// // 				fmt.Fprint(w, helpers.GetError_String("MEA", "The given Mobile number and Email ID has an account with us"))
// // 				return
// // 			}
// // 		} else {
// // 			isBoEmailExists, lErr := backofficecheck.BofficeCheck(pDebug, pValidationRec.Email, "email")
// // 			if lErr != nil {
// // 				pDebug.Log(helpers.Elog, "NRI002", lErr.Error())
// // 				return pOtpResp, helpers.ErrReturn(errors.New(" Somthing went wrong please try again later"))

// // 			}

// // 			if isBoEmailExists {
// // 				return pOtpResp, helpers.ErrReturn(errors.New(" The given Email Id has an account with us"))
// // 			}
// // 		}

// // 	}

// // 	lExistingData, lErr := CheckDataExists(pDebug, pValidationRec.OtpType, pValidationRec.Phone)
// // 	if lErr != nil {
// // 		pDebug.Log(helpers.Elog, "NRI003", lErr.Error())
// // 		return pOtpResp, helpers.ErrReturn(errors.New(" Somthing went wrong please try again later"))

// // 	}

// // 	if strings.EqualFold(pValidationRec.OtpType, "phone") && strings.EqualFold(lExistingData.IsExisting, "N") {

// // 		lErr = InsertNewTempRequest(pDebug, lDb, pValidationRec)
// // 		if lErr != nil {
// // 			pDebug.Log(helpers.Elog, "NRI004", lErr.Error())
// // 			return pOtpResp, helpers.ErrReturn(errors.New(" Somthing went wrong please try again later"))

// // 		}
// // 	} else if strings.EqualFold(pValidationRec.OtpType, "phone") && strings.EqualFold(lExistingData.IsExisting, "Y") {
// // 		lEmailOtpResp, lErr := SendOtpToEmail(pDebug, pValidationRec, r)
// // 		if lErr != nil {
// // 			pDebug.Log(helpers.Elog, "NRI004", lErr.Error())
// // 			return pOtpResp, helpers.ErrReturn(errors.New(" Somthing went wrong please try again later"))

// // 		}
// // 		pOtpResp.Description = "OTP Verified Sucessfully !"
// // 		pOtpResp.Status = "S"
// // 		if lEmailOtpResp.Status == "S" {
// // 			pOtpResp.AttemptCount = lEmailOtpResp.AttemptCount
// // 			pOtpResp.Encryptedval = lEmailOtpResp.Encryptedval
// // 			pOtpResp.InsertedID = lEmailOtpResp.InsertedID
// // 		} else {

// // 		}
// // 		return pOtpResp, helpers.ErrReturn(errors.New(" Somthing went wrong please try again later"))
// // 	}

// // 	if strings.EqualFold(pValidationRec.OtpType, "email") && lExistingData.Email != pValidationRec.Email {

// // 		lErr = UpdateNewEmail(pDebug, lDb, pValidationRec)
// // 		if lErr != nil {
// // 			pDebug.Log(helpers.Elog, "NRI005", lErr.Error())
// // 			return lExistingData, helpers.ErrReturn(errors.New(" Somthing went wrong please try again later"))

// // 		}
// // 	}

// // 	pDebug.Log(helpers.Statement, "NewRequestInit(-)")
// // }

// func GetExistingData(pDebug *helpers.HelperStruct, pType, pData string) (ExistingDataStruct, error) {
// 	pDebug.Log(helpers.Statement, "CheckDataExists(+)")

// 	var lSubCondition string
// 	var lExistingData ExistingDataStruct

// 	lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, lErr.Error())
// 		return lExistingData, helpers.ErrReturn(errors.New(" Somthing went wrong please try again later"))

// 	}
// 	defer lDb.Close()

// 	if strings.EqualFold(pType, "phone") {

// 		lSubCondition = "and etr.phone=? "

// 	} else if strings.EqualFold(pType, "email") {

// 		lSubCondition = "and etr.email=? "

// 	} else {

// 		lSubCondition = "and etr.Temp_Uid=? "

// 	}

// 	pDebug.Log(helpers.Details, "pType =>", pType, "pData =>", pData)

// 	lCorestring := `	select
// 						nvl(etr.Temp_Uid,'') Temp_Uid , nvl(etr.Uid,'') Uid,nvl(etr.email,'') email,
// 						nvl(etr.phone,'') phone,nvl(er.Form_Status,'') Form_Status ,case when nvl(etr.Uid,'')= ''  then 'N' else 'Y'  end as isExisting
// 					from
// 						ekyc_temp_request etr
// 					join
// 						ekyc_request er
// 					on er.Uid = etr.Uid
// 					where etr.isActive ='Y'` + lSubCondition

// 	lRows, lErr := lDb.Query(lCorestring, pData)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "CPE001", lErr)
// 		return lExistingData, lErr
// 	}

// 	for lRows.Next() {
// 		lErr = lRows.Scan(&lExistingData.TempUid, &lExistingData.ReqUid, &lExistingData.Email, &lExistingData.Phone, &lExistingData.FormStatus, &lExistingData.IsExisting)
// 		if lErr != nil {
// 			pDebug.Log(helpers.Elog, "CPE002", lErr)
// 			return lExistingData, lErr
// 		}

// 	}
// 	pDebug.Log(helpers.Details, "lExistingData =>", fmt.Sprintf("%v", lExistingData))

// 	pDebug.Log(helpers.Statement, "CheckDataExists(-)")
// 	return lExistingData, nil
// }

// func InsertNewTempRequest(pDebug *helpers.HelperStruct, pDb *sql.DB, pValidationRec UserStruct) error {
// 	pDebug.Log(helpers.Statement, "InsertNewTempRequest(+)")

// 	lTempUid := uuid.NewV4().String()

// 	lCorestring := `INSERT INTO ekyc_temp_request
// 					(Temp_Uid, Given_Name, Given_State, Phone, CreatedDate, UpdatedDate, isActive)
// 					VALUES(?, ?, ?, ?, unix_timestamp(),unix_timestamp(),'Y');`

// 	_, lErr := pDb.Exec(lCorestring, lTempUid, pValidationRec.Name, pValidationRec.State, pValidationRec.Phone)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "INR001", lErr)
// 		return lErr
// 	}
// 	pDebug.Log(helpers.Statement, "InsertNewTempRequest(-)")
// 	return nil
// }
// func UpdateExistingRequest(pDebug *helpers.HelperStruct, pDb *sql.DB, pEmail, pSessionId, pUid string) error {
// 	pDebug.Log(helpers.Statement, "UpdateExistingRequest(+)")

// 	lSqlString := `	UPDATE ekyc_request er
// 					JOIN ekyc_temp_request etr ON er.Uid = etr.Uid
// 					SET
// 						er.email = ?,
// 						etr.email = ?,
// 						er.UpdatedDate=unix_timestamp(),
// 						etr.UpdatedDate=unix_timestamp(),
// 						er.Updated_Session_Id=?
// 					WHERE er.Uid = ? `

// 	_, lErr := pDb.Exec(lSqlString, pEmail, pEmail, pSessionId, pUid)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "UER01", lErr)
// 		return lErr
// 	}
// 	pDebug.Log(helpers.Statement, "UpdateExistingRequest(-)")
// 	return nil
// }

// func SendOtpToEmail(pDebug *helpers.HelperStruct, pValidationRec UserStruct, pEmail string, r *http.Request) (successOTPStruct, error) {
// 	pDebug.Log(helpers.Statement, "SendOtpToEmail(+)")
// 	var pUserdataRec otp.UserdataStruct

// 	pUserdataRec.Username = pValidationRec.Name
// 	pUserdataRec.Sendto = pEmail
// 	pUserdataRec.Sendtotype = "email"
// 	pUserdataRec.ClientID = common.EKYCAppName
// 	pUserdataRec.Process = common.EKYCAppName

// 	lOtpResp, lErr := ValidateOtpRequest(pDebug, pUserdataRec, r)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "UNE001", lErr)
// 		return lOtpResp, lErr
// 	}
// 	pDebug.Log(helpers.Statement, "SendOtpToEmail(-)")
// 	return lOtpResp, nil
// }

// func DeActiveExistingRecord(pDebug *helpers.HelperStruct, pDb *sql.DB, pUid string) (lErr error) {
// 	pDebug.Log(helpers.Statement, "DeActiveExistingRecord(+)")

// 	lSqlString := `	UPDATE ekyc_request er
// 					JOIN ekyc_temp_request etr ON er.Uid = etr.Uid
// 					SET er.isActive = 'N', etr.isActive = 'N'
// 					WHERE er.Uid = ? `

// 	_, lErr = pDb.Exec(lSqlString, pUid)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "DAER01", lErr)
// 		return lErr
// 	}

// 	pDebug.Log(helpers.Statement, "DeActiveExistingRecord(-)")
// 	return nil
// }

// // New Record Insert -- new uid
// func InsertNewRequest(pDebug *helpers.HelperStruct, pDb *sql.DB, pSessionId, pTemp_Uid string) (lErr error) {
// 	pDebug.Log(helpers.Statement, "InsertNewRequest(+)")

// 	lSqlString := `
//     INSERT INTO ekyc_request (
//         Uid, Given_Name, Given_State, Phone, Email, CreatedDate, UpdatedDate, isActive, Created_Session_Id, Updated_Session_Id
//     )
//     SELECT
//         Uid, Given_Name, Given_State, Phone, Email, CreatedDate, UpdatedDate, isActive, ?, ?
//     FROM
//         ekyc_temp_request
//     WHERE
//         Temp_Uid = ?
// `

// 	_, lErr = pDb.Exec(lSqlString, pSessionId, pSessionId, pTemp_Uid)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, "INR01", lErr)
// 		return lErr
// 	}

// 	pDebug.Log(helpers.Statement, "InsertNewRequest(-)")
// 	return nil
// }

// func GetUid_Session(pDebug helpers.HelperStruct, pReq *http.Request) {

// }

// func DeriveLogic(oldMob, oldEmail, newMob, newEmail string) (TempId, UID, SessionId string) {
// 	// New Mobile + New Email	New Temp ID & New UID
// 	// New Mobile + Existing OB Email	New Temp ID, Existing UID
// 	// Existing OB Mobile + New Email	New Temp ID, Existing UID
// 	// Existing OB Mobile + Existing OB Email	Existing Temp ID & Existing UID

// 	lNewTempID := uuid.NewV4().String()
// 	lNewUID := strings.ReplaceAll(uuid.NewV4().String(), "-", "")
// 	lSessionId := uuid.NewV4()
// 	lSessionSHA256 := sha256.Sum256([]byte(lSessionId.String()))
// 	lSessionSHA256String := hex.EncodeToString(lSessionSHA256[:])

// 	if newMob != oldMob && newEmail != oldEmail {
// 		// New Mobile + New Email: New Temp ID & New UID
// 		TempId = "new"
// 		UID = "new"
// 		SessionId = lSessionSHA256String

// 	} else if newMob != oldMob && newEmail == oldEmail {
// 		// New Mobile + Existing OB Email: New Temp ID, Existing UID
// 		TempId = "new"
// 		UID = "old"
// 		SessionId = lSessionSHA256String

// 	} else if newMob == oldMob && newEmail != oldEmail {
// 		// Existing OB Mobile + New Email: New Temp ID, Existing UID
// 		TempId = "new"
// 		UID = "old"

// 	} else if newMob == oldMob && newEmail == oldEmail {
// 		// Existing OB Mobile + Existing OB Email: Existing Temp ID & Existing UID
// 		TempId = "old"
// 		UID = "old"
// 	}

// 	if TempId == "new" {
// 		TempId = lNewTempID
// 	} else {
// 		TempId = "old TempId"
// 	}

// 	if UID == "new" {
// 		UID = lNewUID
// 	} else {
// 		UID = "old UID"
// 	}

// 	return TempId, UID, SessionId
// }
