package newsignup

// import (
// 	"crypto/sha256"
// 	"encoding/hex"
// 	"encoding/json"
// 	"fcs23pkg/common"
// 	"fcs23pkg/ftdb"
// 	"fcs23pkg/helpers"
// 	backofficecheck "fcs23pkg/integration/v1/backofficeCheck"
// 	"fmt"
// 	"net/http"
// 	"strings"

// 	uuid "github.com/satori/go.uuid"
// )

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
// 			lOtpSuccessResp.TempUid = lExistingData.TempUid
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
