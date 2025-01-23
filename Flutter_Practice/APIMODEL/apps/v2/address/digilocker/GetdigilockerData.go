package digilocker

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v2/address"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/appsession"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/digilockerapicall"
	"fcs23pkg/integration/v2/pdfgenerate"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"
)

type FinalStruct struct {
	PERAddress1    string                              `json:"peradrs1"`
	PERAddress2    string                              `json:"peradrs2"`
	PERAddress3    string                              `json:"peradrs3"`
	PERCity        string                              `json:"percity"`
	PERState       string                              `json:"perstate"`
	PERCountry     string                              `json:"percountry"`
	PERPincode     string                              `json:"perpincode"`
	PERAdrsProofNo string                              `json:"peradrsproofno"`
	Status         string                              `json:"status"`
	MaskedAatharNo string                              `json:"aadharno"`
	Gender         string                              `json:"gender"`
	Name           string                              `json:"name"`
	DOB            string                              `json:"dob"`
	DocIDArr       []digilockerapicall.FileDocIDstruct `json:"docids"`
	DigiId         string                              `json:"digiid"`
	PdfDocID       string                              `json:"docid1"`
}

//Purpose : carry the Authorized Code and Codetype
type getCodeStruct struct {
	Digi_id string `json:"digi_id"`
	Rd_URL  string `json:"url"`
}

/*
Purpose : This method is used to fetch the user Aadhar details from Digilocker Site
Request : Code,TokenType
Response :
===========
On Success:
===========
{
"DocId": "2076",
"Status": "Success",
“StatusMsg": "Document is processed successfuly”
}
===========
On Error:
===========
"Error":
Author : Saravanan
Date : 05-June-2023
modify author : Sowmiya L
*/

// var ref="abc"
func GetDigilockerInfo(w http.ResponseWriter, req *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)

	lDebug.Log(helpers.Statement, "GetDigilockerApi (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")
	(w).Header().Set("Content-Type", "application/json")

	if strings.EqualFold(req.Method, "POST") {
		//call the over all digilocker flow function
		var lAdrsData FinalStruct
		lUid, lErr := appsession.Getuid(req, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GDA01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GDA01", "Something went wrong. Please try agin later."))
			return
		}

		_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(req, lDebug, common.EKYCCookieName, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GDA02: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GDA02", "Something went wrong. Please try again later."))
			return
		}
		if lTestUserFlag == "1" {
			lAdrsData, lErr = GetDigiDataProcess(lDebug, req, lAdrsData)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "GDA03: "+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("GDA03", helpers.ErrPrint(lErr)))
				return
			}
		}
		lAdrsData.Status = common.SuccessCode
		userInfo, lErr := json.Marshal(lAdrsData)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GDA04"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GDA04", "Something went wrong. Please try again later."))
			return
		}
		lDebug.Log(helpers.Details, "UserInfo", string(userInfo))
		fmt.Fprint(w, string(userInfo))

	}
	lDebug.Log(helpers.Statement, "GetDigilockerApi (-)")
}

/*
Purpose : This method is used to check Token Type And Carry the flow of entire Digilocker Proccess
Arguments :req <http.Request>
===========
On Success:
===========// //Purpose : carry the Authorized Code and Codetype
// type getCodeStruct struct {
// 	Code      string `json:"code"`
// 	TokenType string `json:"tokentype"`
// 	Rd_URL    string `json:"url"`
// }

{
"DocId": "2076",
"Status": "Success",
“StatusMsg": "Document is processed successfuly”
}
===========
On Error:
===========
"Error":
Author : Saravanan
Date : 05-June-2023
modify author : Sowmiya L
*/

func GetDigiDataProcess(pDebug *helpers.HelperStruct, pReq *http.Request, pAdrs FinalStruct) (FinalStruct, error) {

	pDebug.Log(helpers.Statement, "GetDigiDataProcess (+)")

	lSessionId, lUid, lErr := sessionid.GetOldSessionUID(pReq, pDebug, common.EKYCCookieName)
	if lErr != nil {
		return pAdrs, helpers.ErrReturn(lErr)
	}
	pDebug.SetReference(lUid)

	// create an instance of the structure

	var lCodeRec getCodeStruct
	//read the body
	lBody, lErr := ioutil.ReadAll(pReq.Body)
	pDebug.Log(helpers.Details, string(lBody), "lBody")

	if lErr != nil {

		return pAdrs, helpers.ErrReturn(lErr)
	}
	// converting json body value to Structue
	lErr = json.Unmarshal(lBody, &lCodeRec)

	// cheack where response will not Error
	if lErr != nil {

		return pAdrs, helpers.ErrReturn(lErr)
	}

	if len(lCodeRec.Rd_URL) == 0 {
		return pAdrs, helpers.ErrReturn(errors.New(" Missing Code ,Kindly add code value"))
	}

	// Parse the URL
	parsedURL, lErr := url.Parse(lCodeRec.Rd_URL)
	pDebug.Log(helpers.Details, parsedURL, "parsedURL")
	if lErr != nil {
		return pAdrs, helpers.ErrReturn(lErr)
	}
	queryParams := parsedURL.Query()
	pDebug.Log(helpers.Details, queryParams, "queryParams")
	// Retrieve a specific parameter
	lErrstr := queryParams.Get("error")
	if lErrstr != "null" {
		lErrDesc := queryParams.Get("error_description")
		lFinalErrString := lErrstr + ": " + lErrDesc
		pDebug.Log(helpers.Details, "lFinalErrString", lFinalErrString)
		return pAdrs, helpers.ErrReturn(errors.New(lFinalErrString))
	}

	//check the code is not Empty value
	if len(lCodeRec.Digi_id) == 0 {
		return pAdrs, helpers.ErrReturn(errors.New(" Missing Code ,Kindly add code value"))
	}

	lColumnName := tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "DigilockerColName")

	lErr = address.RefIdInsert(lCodeRec.Digi_id, lUid, lSessionId, lColumnName, pDebug)
	if lErr != nil {
		return pAdrs, helpers.ErrReturn(lErr)
	}
	pAdrs, lErr = DigilockerAddressConstruct(pDebug, lCodeRec.Digi_id, lSessionId, lUid, pAdrs, pReq)
	if lErr != nil {
		return pAdrs, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "GetDigiDataProcess (-)")

	return pAdrs, nil
}
func DigilockerAddressConstruct(pDebug *helpers.HelperStruct, lDigiId, lSessionId, lUid string, pAdrs FinalStruct, pReq *http.Request) (FinalStruct, error) {
	pDebug.Log(helpers.Statement, "DigilockerAddressConstruct(+)")
	var lKeyndPair KeyPairStruct
	var lKeyndPairArr []KeyPairStruct

	lResponse, lErr := digilockerapicall.GetDigilockerInfo(pDebug, lDigiId)
	if lErr != nil {
		return pAdrs, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, lResponse, "lResponse")

	for _, lDocInfo := range lResponse.DocIDArr {
		if lDocInfo.FileKey == "ADHAR_xml" {
			lKeyndPair.Value = lDocInfo.DocID
			lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "DigilockerXMLColumnName")
			lKeyndPair.FileType = tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "XmlFiletype")
			lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
		}
		if lDocInfo.FileKey == "PanUnSignPDF" {
			lKeyndPair.Value = lDocInfo.DocID
			lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "PanProofColumnName")
			lKeyndPair.FileType = tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "PanFiletype")
			lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
		}
		if lDocInfo.FileKey == "PANCR_xml" {
			lKeyndPair.Value = lDocInfo.DocID
			lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "PanXmlColumnName")
			lKeyndPair.FileType = tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "PanXmltype")
			lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
		}
		if lDocInfo.FileKey == "AadharXMlPDF" {
			pAdrs.PdfDocID = lDocInfo.DocID
		}
	}
	for i := 0; i < len(lKeyndPairArr); i++ {

		lDocID := lKeyndPairArr[i].Value

		if !strings.EqualFold(common.AppRunMode, "prod") {
			// need remove below for production
			NewDocId, lErr := pdfgenerate.FileMoveProdtoDev(pDebug, lDocID)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return pAdrs, helpers.ErrReturn(lErr)
			} else {
				lDocID = NewDocId
			}
		}
		// need remove above for production
		_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(pReq, pDebug, common.EKYCCookieName, lUid)
		if lErr != nil {
			return pAdrs, helpers.ErrReturn(lErr)
		}

		lErr = address.ProofId(pDebug, lDocID, lUid, lSessionId, lKeyndPairArr[i].Key, lTestUserFlag)
		if lErr != nil {
			return pAdrs, helpers.ErrReturn(lErr)
		}
		lErr = commonpackage.AttachmentlogFile(lUid, lKeyndPairArr[i].FileType, lDocID, pDebug)
		if lErr != nil {
			return pAdrs, helpers.ErrReturn(lErr)
		}
	}
	pAdrs.PERAddress1 = lResponse.PERAddress1
	pAdrs.PERAddress2 = lResponse.PERAddress2
	pAdrs.PERAddress3 = lResponse.PERAddress3
	pAdrs.PERCity = lResponse.PERCity
	pAdrs.PERState = lResponse.PERState
	pAdrs.PERCountry = lResponse.PERCountry
	pAdrs.PERPincode = lResponse.PERPincode
	pAdrs.Status = lResponse.Status
	pAdrs.MaskedAatharNo = strings.ReplaceAll(lResponse.MaskedAatharNo, "x", "X")
	pAdrs.PERAdrsProofNo = strings.ReplaceAll(lResponse.MaskedAatharNo, "x", "X")
	pAdrs.Gender = lResponse.Gender
	pAdrs.Name = lResponse.Name
	pAdrs.DOB = lResponse.DOB
	pAdrs.DocIDArr = lResponse.DocIDArr
	pAdrs.DigiId = lDigiId
	_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(pReq, pDebug, common.EKYCCookieName, lUid)
	if lErr != nil {
		return pAdrs, helpers.ErrReturn(lErr)
	}
	if lTestUserFlag == "1" {
		var lKeyndPairArr []KeyPairStruct
		if pAdrs.Gender != "" {
			// Add Gender to the key-value pair array
			lKeyndPair.Value = pAdrs.Gender
			// Get the column name from the configuration file
			lKeyndPair.Key = tomlconfig.GtomlConfigLoader.GetValueString("kra", "GenderColumnName")
			lKeyndPair.FileType = tomlconfig.GtomlConfigLoader.GetValueString("kra", "Gender")
			lKeyndPairArr = append(lKeyndPairArr, lKeyndPair)
		}
		for i := 0; i < len(lKeyndPairArr); i++ {
			// Insert Gender into the database
			lErr := address.PersonalDataInsertion(lKeyndPair.Key, lKeyndPair.Value, lKeyndPair.FileType, "Digilocker", lUid, lSessionId, pDebug)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return pAdrs, helpers.ErrReturn(lErr)
			}
		}
	}
	lSqlString := `update ekyc_request 
		set Name_As_Per_Aadhar  = ?,AadhraNo = ?
		where  Uid  = ?`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lSqlString, lResponse.Name, lResponse.MaskedAatharNo, lUid)
	if lErr != nil {
		return pAdrs, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "DigilockerAddressConstruct(-)")
	return pAdrs, nil
}

func GetDigilockerInfoFromDb(w http.ResponseWriter, req *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)

	lDebug.Log(helpers.Statement, "GetDigilockerInfoFromDb (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")
	(w).Header().Set("Content-Type", "application/json")

	if strings.EqualFold(req.Method, "GET") {
		//call the over all digilocker flow function
		var lAdrsData FinalStruct
		var lDigilockerReferenceId string
		lUid, lErr := appsession.Getuid(req, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GDA01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GDA01", "Something went wrong. Please try agin later."))
			return
		}

		_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(req, lDebug, common.EKYCCookieName, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GDA02: "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GDA02", "Something went wrong. Please try again later."))
			return
		}
		if lTestUserFlag == "1" {

			lSessionId, lUid, lErr := sessionid.GetOldSessionUID(req, lDebug, common.EKYCCookieName)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "GDA03: "+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("GDA03", "Something went wrong. Please try again later."))
				return
			}
			lDebug.SetReference(lUid)

			// Query to retrieve digilockerReferenceId from the ekyc_request table based on Uid
			lCorestring := `select nvl(ea.Digilockerreferenceid,"") from ekyc_address ea where ea.Request_Uid = ?`
			lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "GDA05: "+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("GDA05", "Something went wrong. Please try again later."))
				return
			} else {
				defer lRows.Close()
				// Iterate through the query result
				for lRows.Next() {
					// Scan DigilockerRefId values from the result set
					lErr := lRows.Scan(&lDigilockerReferenceId)
					if lErr != nil {
						lDebug.Log(helpers.Elog, "GDA06: "+lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("GDA06", "Something went wrong. Please try again later."))
						return
					}
				}
			}
			lDebug.Log(helpers.Details, lDigilockerReferenceId, "lDigilockerReferenceId")
			if lDigilockerReferenceId != "" {
				lAdrsData, lErr = DigilockerAddressConstruct(lDebug, lDigilockerReferenceId, lSessionId, lUid, lAdrsData, req)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "GDA07: "+lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("GDA07", "Something went wrong. Please try again later."))
					return
				}
			}
			lAdrsData.Status = common.SuccessCode
		}
		userInfo, lErr := json.Marshal(lAdrsData)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GDA04"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GDA04", "Something went wrong. Please try again later."))
			return
		}
		lDebug.Log(helpers.Details, "UserInfo", string(userInfo))
		fmt.Fprint(w, string(userInfo))

	}
	lDebug.Log(helpers.Statement, "GetDigilockerInfoFromDb (-)")
}
