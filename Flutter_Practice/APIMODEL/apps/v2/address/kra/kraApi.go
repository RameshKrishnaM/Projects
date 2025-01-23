package kra

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v2/address"
	"fcs23pkg/apps/v2/address/digilocker"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/coresettings"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/kraapi"
	"fcs23pkg/tomlconfig"
	"fmt"
	"net/http"
	"strings"
)

/*
***************************************************************

	Purpose : This structure is used to get KRA pan details

Author : Sowmiya L
Date : 5-Feb-2024
****************************************************************
*/
type FinalAddressStruct struct {
	CORAddress1                string `json:"coraddress1"`
	CORAddress2                string `json:"coraddress2"`
	CORAddress3                string `json:"coraddress3"`
	CORCity                    string `json:"corcity"`
	CORPincode                 string `json:"corpincode"`
	CORState                   string `json:"corstate"`
	CORState_Desc              string `json:"corstatedesc"`
	CORCountry                 string `json:"corcountry"`
	CORCountry_Desc            string `json:"corcountrydesc"`
	CORProofofAddressType      string `json:"corproofofaddresstype"`
	CORProofofAddressType_Desc string `json:"corproofofaddresstypedesc"`
	CORProofofAddressno        string `json:"corproofofaddressno"`
	CORProofofAddressDate      string `json:"corproofofaddressdate"`
	PERAddress1                string `json:"peraddress1"`
	PERAddress2                string `json:"peraddress2"`
	PERAddress3                string `json:"peraddress3"`
	PERCity                    string `json:"percity"`
	PERPincode                 string `json:"perpincode"`
	PERState                   string `json:"perstate"`
	PERState_Desc              string `json:"perstatedesc"`
	PERCountry                 string `json:"percountry"`
	PERCountry_Desc            string `json:"percountrydesc"`
	PERProofofAddressType      string `json:"perproofofaddresstype"`
	PERProofofAddressType_Desc string `json:"perproofofaddresstypedesc"`
	PERProofofAddressNo        string `json:"perproofofaddressno"`
	PERProofofAddressDate      string `json:"perproofofaddressdate"`
	XmlDocId                   string `json:"xmlDocId"`
	PdfDocID                   string `json:"pdfDocId"`
	PanNo                      string `json:"panNo"`
	DOB                        string `json:"dob"`
	Gender                     string `json:"gender"`
	Name                       string `json:"name"`
	AccountOpenDate            string `json:"accountOpenDate"`
	AgencyName                 string `json:"agencyName"`
	KycStatus                  string `json:"kycStatus"`
	KycCreationDate            string `json:"kycCreationDate"`
	KycLastUpdateDate          string `json:"kycLastUpdateDate"`
	Remarks                    string `json:"remarks"`
	UpdatedRemarks             string `json:"updatedRemarks"`
	KycMode                    string `json:"kycMode"`
	KRAReferenceid             string `json:"krareferenceid"`
	KRAAppNo                   string `json:"kraappno"`
	FatherName                 string `json:"fathername"`
	MaritalStatus              string `json:"maritalstatus"`
	Status                     string `json:"status"`
}
type FinalRespStruct struct {
	Name                       string `json:"name"`
	CORAddress1                string `json:"coradrs1"`
	CORAddress2                string `json:"coradrs2"`
	CORAddress3                string `json:"coradrs3"`
	CORCity                    string `json:"corcity"`
	CORPincode                 string `json:"corpincode"`
	CORState                   string `json:"corstate"`
	CORCountry                 string `json:"corcountry"`
	CORProofofAddressType      string `json:"corproofofaddresstype"`
	CORProofofAddressType_Desc string `json:"coradrsproofname"`
	CORProofofAddressno        string `json:"corproofofaddressno"`
	CORProofofAddressDate      string `json:"corproofofaddressdate"`
	PERAddress1                string `json:"peradrs1"`
	PERAddress2                string `json:"peradrs2"`
	PERAddress3                string `json:"peradrs3"`
	PERCity                    string `json:"percity"`
	PERPincode                 string `json:"perpincode"`
	PERState                   string `json:"perstate"`
	PERCountry                 string `json:"percountry"`
	PERProofofAddressType      string `json:"perproofofaddresstype"`
	PERProofofAddressType_Desc string `json:"peradrsproofname"`
	PERAdrsProofNo             string `json:"peradrsproofno"`
	PERProofofAddressNo        string `json:"perproofofaddressno"`
	PERProofofAddressDate      string `json:"perproofofaddressdate"`
	PdfDocID                   string `json:"docid1"`
	Status                     string `json:"status"`
}

/*
***************************************************************

	Purpose : This structure is used to get the pan status details

Author : Sowmiya L
Date : 5-Feb-2024
****************************************************************
*/
type KraStatusStruct struct {
	APP_PAN_NO             string `json:"appPanNo"`
	APP_NAME               string `json:"appName"`
	APP_STATUS             string `json:"appStatus"`
	APP_STATUS_DESC        string `json:"appStatusdesc"`
	APP_STATUSDT           string `json:"appStatusDt"`
	APP_ENTRYDT            string `json:"appEntryDt"`
	APP_MODDT              string `json:"appModDt"`
	APP_STATUS_DELTA       string `json:"appStatusDelta"`
	APP_UPDT_STATUS        string `json:"appUpdtStatus"`
	APP_HOLD_DEACTIVE_RMKS string `json:"appHoldDeactiveRmks"`
	APP_UPDT_RMKS          string `json:"appUpdtRmks"`
	APP_KYC_MODE           string `json:"appKycMode"`
	APP_KYC_MODE_DESC      string `json:"appKycModedesc"`
	APP_IPV_FLAG           string `json:"appIpvFlag"`
	APP_IPV_FLAG_DESC      string `json:"appIpvFlagdesc"`
	APP_UBO_FLAG           string `json:"appUboFlag"`
	APP_PER_ADD_PROOF      string `json:"appPerAddProof"`
	APP_PER_ADD_PROOF_DESC string `json:"appPerAddProofDesc"`
	APP_COR_ADD_PROOF      string `json:"appCorAddProof"`
	APP_COR_ADD_PROOF_DESC string `json:"appCorAddProofDesc"`
	Ref_Id                 string `json:"krareferenceid"`
	APP_AGENCY_NAME        string `json:"appagencyname"`
	Status                 string `json:"status"`
}

/*
Purpose : This structure is used to input of the PanfullDetailsStruct

Authorization : Sowmiya L
Date : 05-Feb-2024
*/
type UserdataStruct struct {
	PanNo   string `json:"pan"`
	DOB     string `json:"dob"`
	AppName string `json:"appname"`
	RefId   string `json:"refid"`
}

/*
Purpose : This method is used to fetch the user Pan details from KRA
Request : pan,dob
Response :
===========
On Success:
===========

	{
					"coraddress1": "57 VAISIYAR STREET",
	    			"coraddress2": "TIYAGADURUGAM KALLAKURICHI TALUK",
	    			"coraddress3": "VILUPPURAM",
	    			"corcity": "VILUPPURAM",
	    			"corpincode": "606206",
	    			"corstate": "033",
	    			"corstatedesc": "Tamil Nadu",
	    			"corcountry": "101",
	    			"corcountrydesc": "India",
	    			"corproofofaddresstype": "31",
	    			"corproofofaddresstypedesc": "AADHAAR",
	    			"peraddress1": "57 VAISIYAR STREET",
	    			"peraddress2": "TIYAGADURUGAM KALLAKURICHI TALUK",
	    			"peraddress3": "VILUPPURAM",
	    			"percity": "VILUPPURAM",
	    			"perpincode": "606206",
	    			"perstate": "033",
	    			"perstatedesc": "Tamil Nadu",
	    			"percountry": "101",
	    			"percountrydesc": "India",
	    			"perproofofaddresstype": "31",
	    			"perproofofaddresstypedesc": "AADHAAR",
	    			"xmlDocId": "9014",
	    			"pdfDocId": "9015",
	    			"panNo": "LVZPS0459L",
	    			"dob": "06/11/2001",
	    			"accountOpenDate": "01/01/1900",
	    			"agencyName": "CVLKRA",
	    			"kycStatus": "07",
	    			"kycCreationDate": "05-05-2023 22:07:58",
	    			"kycLastUpdateDate": "29-07-2023 17:58:47",
	    			"remarks": "",
	    			"updatedRemarks": "",
	    			"kycMode": "5",
	    			"refId": "29",
	    			"status": ""
				}
		===========
	   	On Error:
		===========
				{
					"Error": "Error"
					"ErrorMsg":Check the pan number or dob
				}
	   Authorization : Sowmiya L
	   Date : 05-June-2023
*/
func GetKRAPanDetails(w http.ResponseWriter, req *http.Request) {
	// Initialize a debug helper
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)
	lDebug.Log(helpers.Statement, "GetPanStatus (+)")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET,OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")
	(w).Header().Set("Content-Type", "application/json")
	if strings.EqualFold(req.Method, "GET") {
		// Initialize a structure to hold KRA address information
		var lKRAAddressRec FinalRespStruct
		// Call the GetKradata function to fetch KRA data

		lKRAAddressRec, lErr := GetKradata(req, lDebug, lKRAAddressRec)
		if lErr != nil {
			// Log an error and return an error response
			lDebug.Log(helpers.Elog, "GDA01: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GDA01", helpers.ErrPrint(lErr)))
			return
		}
		// Check if the address information is empty
		if lKRAAddressRec.PERAddress1 == "" {
			// Log an error and return an error response
			lDebug.Log(helpers.Elog, "GDA02")
			fmt.Fprint(w, helpers.GetError_String("GDA02", "Unable to retrieve address information. Please try again later."))
			return
		}
		// Set the status code to success
		lKRAAddressRec.Status = common.SuccessCode
		// Marshal the user information to JSON
		userInfo, lErr := json.Marshal(lKRAAddressRec)
		if lErr != nil {
			// Log an error and return an error response
			lDebug.Log(helpers.Elog, "GDA03"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GDA03", "Something went wrong. Please try again later."))
			return
		}
		// Log details and write the JSON response
		lDebug.Log(helpers.Details, "UserInfo", string(userInfo))
		fmt.Fprint(w, string(userInfo))
	}
	lDebug.Log(helpers.Statement, "GetPanStatus(-)")

}

func TestUserKYCInfo(pDebug *helpers.HelperStruct, pReq *http.Request) (lFlag bool, lErr error) {
	pDebug.Log(helpers.Statement, "TestUserKYCInfo(+)")
	var lUserInfoRec UserdataStruct
	_, lUid, lErr := sessionid.GetOldSessionUID(pReq, pDebug, common.EKYCCookieName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "KF01"+lErr.Error())
		return lFlag, helpers.ErrReturn(lErr)
	}
	// Set the reference ID in the debug helper
	pDebug.SetReference(lUid)
	// Read the configuration file
	// Connect to the local database

	// SQL query to retrieve KRA reference ID
	pDebug.Log(helpers.Details, "lUid", lUid)
	pDebug.Log(helpers.Details, "lUserInfoRec", lUserInfoRec)

	lUserPanInfo, lErr := GetPanInfo(lUid, lUserInfoRec, pDebug)
	pDebug.Log(helpers.Details, "lRefId", lUserPanInfo)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "KF02"+lErr.Error())
		return lFlag, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "lUserPanInfo", lUserPanInfo)

	lTestAllow := tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestAllow")
	lTestPan := tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestPan")
	lTestDOB := tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestDOB")
	lFlag = strings.EqualFold(lTestAllow, "Y") && strings.EqualFold(lUserPanInfo.PanNo, lTestPan) && strings.EqualFold(lUserPanInfo.DOB, lTestDOB)

	pDebug.Log(helpers.Details, "lTestAllow", lTestAllow)
	pDebug.Log(helpers.Details, "lTestPan", lTestPan)
	pDebug.Log(helpers.Details, "lTestDOB", lTestDOB)
	pDebug.Log(helpers.Details, "lFlag", lFlag)

	pDebug.Log(helpers.Statement, "TestUserKYCInfo(-)")
	return lFlag, nil
}

func GetKradata(pReq *http.Request, pDebug *helpers.HelperStruct, pAddressRec FinalRespStruct) (FinalRespStruct, error) {
	// Log a statement for entering the function
	pDebug.Log(helpers.Statement, "GetKradata (+)")
	var lUserInfoRec UserdataStruct
	var lRefId, lResponse string
	var lKRAServiceResp FinalAddressStruct
	var lErrorRec helpers.Error_Response
	var lAppStatusFlag, lModifiedStatusFlag bool
	var lValidateStatusArr, lOldStatusArr, lModifiedStatusArr []string
	var lKraStatusRec KraStatusStruct

	// Get session information
	lSessionId, lUid, lErr := sessionid.GetOldSessionUID(pReq, pDebug, common.EKYCCookieName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "KF01"+lErr.Error())
		return pAddressRec, helpers.ErrReturn(lErr)
	}
	// Set the reference ID in the debug helper
	pDebug.SetReference(lUid)
	// SQL query to retrieve KRA reference ID
	lDbResp, lRefId, lStatusCode, lFullDetailsFlag, lModifiedStatusCode, lErr := GetRefIdInfo(lUid, lUserInfoRec, pDebug)
	pDebug.Log(helpers.Details, "lRefId", lRefId)
	lDbResp.AppName = tomlconfig.GtomlConfigLoader.GetValueString("kra", "appname")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "KF02"+lErr.Error())
		return pAddressRec, helpers.ErrReturn(lErr)
	}
	if lStatusCode == "" || lRefId == "" {
		lUserInfo, lErr := json.Marshal(lDbResp)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "GDA03"+lErr.Error())
			return pAddressRec, helpers.ErrReturn(lErr)
		}
		lErr = KRADataInsertion(pDebug, lKRAServiceResp, "", "", "N", "", "", lUid, lSessionId, "", pReq)
		if lErr != nil {
			return pAddressRec, helpers.ErrReturn(lErr)
		}
		// Fetch KRA information using PAN information
		lKRAStatusResponse, lErr := kraapi.GetKRAInfo(pDebug, string(lUserInfo), "KRASTATUS")
		if lErr != nil {
			return pAddressRec, helpers.ErrReturn(lErr)
		} else {
			if strings.Contains(lKRAStatusResponse, "statusCode") && strings.Contains(lKRAStatusResponse, "msg") {
				lErr = json.Unmarshal([]byte(lKRAStatusResponse), &lErrorRec)
				if lErr != nil {
					pDebug.Log(helpers.Elog, "KP01"+lErr.Error())
					return pAddressRec, helpers.ErrReturn(lErr)
				}
				lErr = KRADataInsertion(pDebug, lKRAServiceResp, "", "", "N", "", "", lUid, lSessionId, "", pReq)
				if lErr != nil {
					return pAddressRec, helpers.ErrReturn(lErr)
				}
				return pAddressRec, helpers.ErrReturn(errors.New(lErrorRec.ErrorMessage))
			} else {
				// Unmarshal the KRA response to the KraStatus Struct
				lErr = json.Unmarshal([]byte(lKRAStatusResponse), &lKraStatusRec)
				if lErr != nil {
					pDebug.Log(helpers.Elog, lErr.Error())
					return pAddressRec, helpers.ErrReturn(lErr)
				} else {
					lKRAServiceResp.KRAReferenceid = lKraStatusRec.Ref_Id
					lRefId = lKraStatusRec.Ref_Id
					lStatusCode = lKraStatusRec.APP_STATUS
					lErr = KRADataInsertion(pDebug, lKRAServiceResp, lKraStatusRec.APP_AGENCY_NAME, lKraStatusRec.APP_STATUS, "Y", "", lKraStatusRec.APP_NAME, lUid, lSessionId, lKraStatusRec.APP_UPDT_STATUS, pReq)
					if lErr != nil {
						pDebug.Log(helpers.Elog, lErr.Error())
						return pAddressRec, helpers.ErrReturn(lErr)
					}
				}
			}
		}
	}

	// Get Records from coresettings
	OldAppStatus := tomlconfig.GtomlConfigLoader.GetValueString("kra", "OldAppStatus")
	lOldStatuStr := coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, OldAppStatus)
	//unmarshal the json
	lErr = json.Unmarshal([]byte(lOldStatuStr), &lOldStatusArr)
	if lErr != nil {
		return pAddressRec, helpers.ErrReturn(lErr)
	}

	//Commented Reason (Details Fetch for all status)

	lOldAppStatusFlag := false
	pDebug.Log(helpers.Details, lOldStatusArr, "lOldStatusArr")
	for _, appStatus := range lOldStatusArr {
		if lStatusCode == appStatus {
			lOldAppStatusFlag = true
			break
		}
	}

	pDebug.Log(helpers.Details, "lFullDetailsFlag", lFullDetailsFlag)

	//if Uncomment the lOldAppStatusFlag then add the && condition
	if lFullDetailsFlag != "Y" && lOldAppStatusFlag {

		lDbResp.RefId = lRefId
		lErr = KRADataInsertion(pDebug, lKRAServiceResp, "", "", "N", "", "", lUid, lSessionId, "", pReq)
		if lErr != nil {
			return pAddressRec, helpers.ErrReturn(lErr)
		}
		pDebug.Log(helpers.Details, "KRA Reference id", lDbResp.RefId)
		// Marshal user information to JSON
		lUserInfo, lErr := json.Marshal(lDbResp)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return pAddressRec, helpers.ErrReturn(lErr)
		}
		lResponse, lErr = kraapi.GetKRAInfo(pDebug, string(lUserInfo), "KRADETAILS")
		if lErr != nil {
			return pAddressRec, helpers.ErrReturn(lErr)
		}

		pDebug.Log(helpers.Details, lResponse, "lResponse")

	} else if lFullDetailsFlag == "Y" {
		lResponse, lErr = kraapi.GetKRAInfoUseRefID(pDebug, lRefId, "KRAFullDetails")
		if lErr != nil {
			return pAddressRec, helpers.ErrReturn(lErr)
		}
	} else {
		return pAddressRec, helpers.ErrReturn(errors.New(" KRA fulldetails doesn't exists"))
	}
	// Get Records from coresettings
	ValidateAppStatus := tomlconfig.GtomlConfigLoader.GetValueString("kra", "ValidateAppStatus")
	lAppStatuStr := coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, ValidateAppStatus)
	//unmarshal the json
	lErr = json.Unmarshal([]byte(lAppStatuStr), &lValidateStatusArr)
	if lErr != nil {
		return pAddressRec, helpers.ErrReturn(lErr)
	}
	lAppStatusFlag = false
	pDebug.Log(helpers.Details, lValidateStatusArr, "lValidateStatusArr")
	for _, appStatus := range lValidateStatusArr {
		if lStatusCode == appStatus {
			lAppStatusFlag = true
			break
		}
	}

	if lKraStatusRec.APP_MODDT != "" {
		//Fetch the Modified status coresetting key from the toml
		lModifiedStatusKey := tomlconfig.GtomlConfigLoader.GetValueString("kra", "ModifyAppStatus")

		//This method is used to fetch the value from the coresetting based on the given key
		lModifiedStatusValue := coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, lModifiedStatusKey)

		//unmarshal the json
		lErr = json.Unmarshal([]byte(lModifiedStatusValue), &lModifiedStatusArr)
		if lErr != nil {
			return pAddressRec, helpers.ErrReturn(lErr)
		}

		//Condition to be checked for the Given Modified status should be present in the DB Configured modifiedstatus (05 and 07 series)
		pDebug.Log(helpers.Details, "lModifiedStatusCode", lModifiedStatusCode)
		pDebug.Log(helpers.Details, "lModifiedStatusArr", lModifiedStatusArr)

		for _, modifiedStatus := range lModifiedStatusArr {
			if lModifiedStatusCode == modifiedStatus {
				lModifiedStatusFlag = true
				break
			}
		}
		pDebug.Log(helpers.Details, "lModifiedStatusFlag", lModifiedStatusFlag)
	} else {
		lModifiedStatusFlag = true
	}

	if strings.Contains(lResponse, "statusCode") && strings.Contains(lResponse, "msg") {
		lErr = json.Unmarshal([]byte(lResponse), &lErrorRec)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return pAddressRec, helpers.ErrReturn(lErr)
		}
		return pAddressRec, helpers.ErrReturn(errors.New(lErrorRec.ErrorMessage))
	} else {
		// Unmarshal the KRA response to the FinalAddressStruct
		lErr = json.Unmarshal([]byte(lResponse), &lKRAServiceResp)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return pAddressRec, helpers.ErrReturn(lErr)
		}
		// Log details about the retrieved address information
		pDebug.Log(helpers.Details, lKRAServiceResp.KRAReferenceid, "lKRAServiceResp.FullDetailsRefId", "lKRAServiceResp.PdfDocID", lKRAServiceResp.PdfDocID)

		// Check if RefId and AgencyName are available, insert them into the database
		if lKRAServiceResp.KRAReferenceid != "" && lKRAServiceResp.Name != "" && (lKRAServiceResp.CORAddress1 != "" || lKRAServiceResp.PERAddress1 != "") {
			lErr := KRADataInsertion(pDebug, lKRAServiceResp, lKRAServiceResp.AgencyName, "", "Y", "Y", lKRAServiceResp.Name, lUid, lSessionId, "", pReq)
			if lErr != nil {
				return pAddressRec, helpers.ErrReturn(lErr)
			}
		}
		if lAppStatusFlag && lModifiedStatusFlag {
			pAddressRec.CORAddress1 = lKRAServiceResp.CORAddress1
			pAddressRec.CORAddress2 = lKRAServiceResp.CORAddress2
			pAddressRec.CORAddress3 = lKRAServiceResp.CORAddress3
			pAddressRec.CORCity = lKRAServiceResp.CORCity
			pAddressRec.CORPincode = lKRAServiceResp.CORPincode
			if lKRAServiceResp.CORState_Desc == "" {
				pAddressRec.CORState = lKRAServiceResp.CORState
			} else {
				lLookupdataRespRec, lErr := commonpackage.GetLookUpDescription(pDebug, "state", lKRAServiceResp.CORState, "CVLKRA")
				if lErr != nil {
					pDebug.Log(helpers.Elog, lErr.Error())
					return pAddressRec, helpers.ErrReturn(lErr)
				}
				pAddressRec.CORState = lLookupdataRespRec.Descirption
				pDebug.Log(helpers.Details, pAddressRec.CORState, "pAddressRec.CORState")
				// pAddressRec.CORState = lKRAServiceResp.CORState_Desc
			}
			pAddressRec.CORCountry = lKRAServiceResp.CORCountry_Desc
			pAddressRec.PERAddress1 = lKRAServiceResp.PERAddress1
			pAddressRec.PERAddress2 = lKRAServiceResp.PERAddress2
			pAddressRec.PERAddress3 = lKRAServiceResp.PERAddress3
			pAddressRec.PERCity = lKRAServiceResp.PERCity
			pAddressRec.PERPincode = lKRAServiceResp.PERPincode
			pAddressRec.PERState = lKRAServiceResp.PERState_Desc
			if lKRAServiceResp.PERState_Desc == "" {
				pAddressRec.PERState = lKRAServiceResp.PERState
			} else {
				lLookupdataRespRec, lErr := commonpackage.GetLookUpDescription(pDebug, "state", lKRAServiceResp.PERState, "CVLKRA")
				if lErr != nil {
					pDebug.Log(helpers.Elog, lErr.Error())
					return pAddressRec, helpers.ErrReturn(lErr)
				}
				pAddressRec.PERState = lLookupdataRespRec.Descirption
				pDebug.Log(helpers.Details, pAddressRec.PERState, "pAddressRec.PERState")
				// pAddressRec.PERState = lKRAServiceResp.PERState_Desc
			}
			pAddressRec.PERCountry = lKRAServiceResp.PERCountry_Desc
			pAddressRec.PdfDocID = lKRAServiceResp.PdfDocID
			pAddressRec.Name = lKRAServiceResp.Name
			pAddressRec.PERProofofAddressType = lKRAServiceResp.PERProofofAddressType
			pAddressRec.PERProofofAddressType_Desc = lKRAServiceResp.PERProofofAddressType_Desc
			pAddressRec.PERAdrsProofNo = lKRAServiceResp.PERProofofAddressNo
			pAddressRec.PERProofofAddressDate = lKRAServiceResp.PERProofofAddressDate
			pAddressRec.CORProofofAddressType = lKRAServiceResp.CORProofofAddressType
			pAddressRec.CORProofofAddressType_Desc = lKRAServiceResp.CORProofofAddressType_Desc
			pAddressRec.CORProofofAddressno = lKRAServiceResp.CORProofofAddressno
			pAddressRec.CORProofofAddressDate = lKRAServiceResp.CORProofofAddressDate
		} else {
			return pAddressRec, helpers.ErrReturn(errors.New(" Unable to fetch the KRA details"))
		}
	}
	pDebug.Log(helpers.Statement, "GetKradata (-)")
	// Return the FinalAddressStruct and nil error
	return pAddressRec, nil
}

/*
Purpose : Purpose of this method is to handle the insertion of KRA-related data into a database
Parameter : pDebug *helpers.HelperStruct, lConfigFile interface{}, pAddressRec FinalAddressStruct, lUid, lSessionId string

Return :
******************
On Error : Based on the error

Authorization : Sowmiya L
Date : 08-Feb-2024
*/
func KRADataInsertion(pDebug *helpers.HelperStruct, pAddressRec FinalAddressStruct, pAgencyName, pAppStatus, pKRAVerificationFlag, pFullDetailsFlag, pUserName, lUid, lSessionId, pModifiedStatus string, pReq *http.Request) error {
	pDebug.Log(helpers.Statement, "KRADataInsertion (+)")

	var lKeyndPairArr []digilocker.KeyPairStruct
	var lKeyndPair digilocker.KeyPairStruct
	var lTempArr []digilocker.KeyPairStruct
	if pAddressRec.KRAReferenceid != "" {
		// Add KRAReferenceid to the key-value pair array
		lKeyndPair.Value = pAddressRec.KRAReferenceid
		// Get the column name from the configuration file
		lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "KRARefIdColumnName")
		lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
	}
	if pAppStatus != "" {
		// Add pErrorCode to the key-value pair array
		lKeyndPair.Value = pAppStatus
		// Get the column name from the configuration file
		lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "KRAErrorCodeColumnName")
		lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
	}
	if pAgencyName != "" {
		// Add agency name to the key-value pair array
		lKeyndPair.Value = pAgencyName
		lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "AgencyColumnName")
		lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
	}
	if pFullDetailsFlag != "" {
		// Add pFullDetailsFlag to the key-value pair array
		lKeyndPair.Value = pFullDetailsFlag
		// Get the column name from the configuration file
		lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "FullDetailsFlagColumnName")
		lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
	}
	if pKRAVerificationFlag != "" {
		// Add pKRAVerificationFlag to the key-value pair array
		lKeyndPair.Value = pKRAVerificationFlag
		// Get the column name from the configuration file
		lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "KRAVerificationColumnName")
		lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
	}
	//Condition to be checked for UpdateStatus not empty and assign the value to insert the data
	if pModifiedStatus != "" {
		// Add pErrorCode to the key-value pair array
		lKeyndPair.Value = pModifiedStatus
		// Get the column name from the configuration file
		lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "KRAModifiedStatusColoumName")
		lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
	}

	// Iterate through the key-value pair array and perform ProofId insertion for each pair
	for i := 0; i < len(lKeyndPairArr); i++ {
		// Insert RefId into the database
		lErr := address.RefIdInsert(lKeyndPairArr[i].Value, lUid, lSessionId, lKeyndPairArr[i].Key, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "KP01"+lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}
	lKeyndPairArr = lTempArr
	_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(pReq, pDebug, common.EKYCCookieName, lUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	if lTestUserFlag == "1" {
		if pAddressRec.Gender != "" {
			// Add Gender to the key-value pair array
			lKeyndPair.Value = pAddressRec.Gender
			// Get the column name from the configuration file
			lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "GenderColumnName")
			lKeyndPair.FileType = tomlconfig.GtomlConfigLoader.GetValueString("kra", "Gender")
			lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
		}
		if pAddressRec.FatherName != "" {
			// Add FatherNAme to the key-value pair array
			lKeyndPair.Value = pAddressRec.FatherName
			// Get the column name from the configuration file
			lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "FatherNameColumnName")
			lKeyndPair.FileType = ""
			lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
		}
		if pAddressRec.MaritalStatus != "" {
			// Add FatherNAme to the key-value pair array
			lKeyndPair.Value = pAddressRec.MaritalStatus
			// Get the column name from the configuration file
			lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "MaritalStatusColumnName")
			lKeyndPair.FileType = tomlconfig.GtomlConfigLoader.GetValueString("kra", "MarritalStatus")
			lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
		}
		for i := 0; i < len(lKeyndPairArr); i++ {
			// Insert Gender into the database
			lErr := address.PersonalDataInsertion(lKeyndPairArr[i].Key, lKeyndPairArr[i].Value, lKeyndPairArr[i].FileType, "CVLKRA", lUid, lSessionId, pDebug)
			if lErr != nil {
				return helpers.ErrReturn(lErr)
			}
		}
	}
	lKeyndPairArr = lTempArr
	if pUserName != "" {
		// Add pUserName to the key-value pair array
		lKeyndPair.Value = pUserName
		// Get the column name from the configuration file
		lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "KRAUserNameColumnName")
		lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
	}
	if pAddressRec.KRAAppNo != "" {
		// Add KRAAppNo to the key-value pair array
		lKeyndPair.Value = pAddressRec.KRAAppNo
		// Get the column name from the configuration file
		lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "KRAAppNoColumnName")
		lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
	}
	// Iterate through the key-value pair array and perform ProofId insertion for each pair
	for i := 0; i < len(lKeyndPairArr); i++ {
		// Insert AppNo into the database
		lErr = address.KRAInsertion(lKeyndPairArr[i].Value, lKeyndPairArr[i].Key, lUid, lSessionId, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	_, lTestUserFlag, lErr = sessionid.VerifyTestUserSession(pReq, pDebug, common.EKYCCookieName, lUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	// Call a function to handle additional insertions
	lErr = AdditionalInsertions(pDebug, pAddressRec.XmlDocId, lUid, lSessionId, lTestUserFlag)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "KRADataInsertion (-)")
	return nil
}
func AdditionalInsertions(pDebug *helpers.HelperStruct, pXmlDocId, lUid, lSessionId, lTestUserFlag string) error {
	pDebug.Log(helpers.Statement, "AdditionalInsertions (+)")

	// Initialize a slice to store key-value pairs for additional insertions
	var lKeyndPairArr []digilocker.KeyPairStruct
	var lKeyndPair digilocker.KeyPairStruct

	if pXmlDocId != "" {
		// Add XML document ID to the key-value pair array
		lKeyndPair.Value = pXmlDocId
		lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "KRAXMLColumnName")
		lKeyndPair.FileType = tomlconfig.GtomlConfigLoader.GetValueString("kra", "XmlFiletype")
		lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
	}
	for _, lFiletypeKey := range lKeyndPairArr {
		lErr := commonpackage.AttachmentlogFile(lUid, lFiletypeKey.FileType, lFiletypeKey.Value, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	// Iterate through the key-value pair array and perform ProofId insertion for each pair
	for i := 0; i < len(lKeyndPairArr); i++ {
		// Perform ProofId insertion using the address package
		lErr := address.ProofId(pDebug, lKeyndPairArr[i].Value, lUid, lSessionId, lKeyndPairArr[i].Key, lTestUserFlag)
		if lErr != nil {
			// Return an error if ProofId insertion fails
			return helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "AdditionalInsertions (-)")
	return nil
}

/*
Purpose :  Its purpose is to retrieve information (PanNo and DOB or RefId) from a database based on a given Uid and Flag
Parameter : pDb *sql.DB, pUid, pFlag string, pUserInfoRec UserdataStruct, pDebug *helpers.HelperStruct

Authorization : Sowmiya L
Date : 07-Feb-2024
*/
func GetPanInfo(pUid string, pUserInfoRec UserdataStruct, pDebug *helpers.HelperStruct) (UserdataStruct, error) {
	pDebug.Log(helpers.Statement, "GetPanInfo(+)")
	// Query to retrieve PanNo and DOB from the ekyc_request table based on Uid
	lCorestring := `select nvl(er.Pan,""),nvl(er.DOB,"") from ekyc_request er where er.Uid =?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pUid)
	if lErr != nil {
		// Log an error and return it if the query fails
		pDebug.Log(helpers.Elog, "GPID01"+lErr.Error())
		return pUserInfoRec, helpers.ErrReturn(lErr)
	} else {
		// Iterate through the query result
		defer lRows.Close()
		for lRows.Next() {
			// Scan PanNo and DOB values from the result set
			lErr := lRows.Scan(&pUserInfoRec.PanNo, &pUserInfoRec.DOB)
			if lErr != nil {
				// Log an error and return it if scanning fails
				pDebug.Log(helpers.Elog, "GPID02"+lErr.Error())
				return pUserInfoRec, helpers.ErrReturn(lErr)
			}
		}
	}
	pDebug.Log(helpers.Statement, "GetPanInfo(-)")
	return pUserInfoRec, nil
}
func GetRefIdInfo(pUid string, pUserInfoRec UserdataStruct, pDebug *helpers.HelperStruct) (UserdataStruct, string, string, string, string, error) {
	pDebug.Log(helpers.Statement, "GetRefIdInfo (+)")

	// Initialize the RefId variable
	var lRefId, lStatusCode, lFullDetailsFlag, lModifiedStatusCode string

	// Query to retrieve KRA_Reference_Id from the ekyc_address table based on Request_Uid
	lCorestring := `select nvl(ea.KRA_Reference_Id,""),nvl(ea.KraStatusCode,""),nvl(ea.FullDetailsFlag,""),nvl(er.Pan,""),nvl(er.DOB,""),nvl(KraModifiedStatusCode,'') from ekyc_address ea,ekyc_request er where ea.Request_Uid =? and ea.Request_Uid = er.Uid`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GPID03"+lErr.Error())
		return pUserInfoRec, lRefId, lStatusCode, lFullDetailsFlag, lModifiedStatusCode, helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		// Iterate through the query result
		for lRows.Next() {
			// Scan the RefId value from the result set
			lErr := lRows.Scan(&lRefId, &lStatusCode, &lFullDetailsFlag, &pUserInfoRec.PanNo, &pUserInfoRec.DOB, &lModifiedStatusCode)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "GPID04"+lErr.Error())
				return pUserInfoRec, lRefId, lStatusCode, lFullDetailsFlag, lModifiedStatusCode, helpers.ErrReturn(lErr)
			}
		}
	}

	pDebug.Log(helpers.Details, "pUserInfoRec.DOB", pUserInfoRec.DOB)
	pDebug.Log(helpers.Details, "pUserInfoRec.PanNo", pUserInfoRec.PanNo)

	pDebug.Log(helpers.Statement, "GetRefIdInfo (-)")

	// Return the retrieved information and a nil error
	return pUserInfoRec, lRefId, lStatusCode, lFullDetailsFlag, lModifiedStatusCode, nil
}
