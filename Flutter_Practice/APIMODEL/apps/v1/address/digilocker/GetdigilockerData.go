package digilocker

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v1/address"
	"fcs23pkg/apps/v1/commonpackage"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/appsession"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/digilockerapicall"
	"fcs23pkg/integration/v1/pdfgenerate"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"
)

type finalStruct struct {
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
		lAdrsData := new(finalStruct)
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
			lErr = GetDigiDataProcess(lDebug, req, lAdrsData)
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
*/

func GetDigiDataProcess(pDebug *helpers.HelperStruct, pReq *http.Request, pAdrs *finalStruct) error {

	pDebug.Log(helpers.Statement, "GetDigiDataProcess (+)")

	lSessionId, lUid, lErr := sessionid.GetOldSessionUID(pReq, pDebug, common.EKYCCookieName)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.SetReference(lUid)

	// create an instance of the structure
	var lKeyndPair KeyPairStruct
	var lKeyndPairArr []KeyPairStruct
	var lCodeRec getCodeStruct
	//read the body
	lBody, lErr := ioutil.ReadAll(pReq.Body)
	pDebug.Log(helpers.Details, string(lBody), "lBody")

	if lErr != nil {

		return helpers.ErrReturn(lErr)
	}
	// converting json body value to Structue
	lErr = json.Unmarshal(lBody, &lCodeRec)

	// cheack where response will not Error
	if lErr != nil {

		return helpers.ErrReturn(lErr)
	}

	// fmt.Println(lCodeRec.Code, lCodeRec.TokenType, lCodeRec.Rd_URL)
	if len(lCodeRec.Rd_URL) == 0 {
		return helpers.ErrReturn(errors.New(" Missing Code ,Kindly add code value"))
	}

	// Parse the URL
	parsedURL, lErr := url.Parse(lCodeRec.Rd_URL)
	pDebug.Log(helpers.Details, parsedURL, "parsedURL")
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	queryParams := parsedURL.Query()
	pDebug.Log(helpers.Details, queryParams, "queryParams")
	// Retrieve a specific parameter
	lErrstr := queryParams.Get("error")
	if lErrstr != "null" {
		lErrDesc := queryParams.Get("error_description")
		lFinalErrString := lErrstr + ": " + lErrDesc
		pDebug.Log(helpers.Details, "lFinalErrString", lFinalErrString)
		return helpers.ErrReturn(errors.New(lFinalErrString))
	}

	//check the code is not Empty value
	if len(lCodeRec.Digi_id) == 0 {
		return helpers.ErrReturn(errors.New(" Missing Code ,Kindly add code value"))
	}

	lColumnName := tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall","DigilockerColName")

	lErr = address.RefIdInsert(lCodeRec.Digi_id, lUid, lSessionId, lColumnName, pDebug)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lResponse, lErr := digilockerapicall.GetDigilockerInfo(pDebug, lCodeRec.Digi_id)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
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
	pAdrs.DigiId = lCodeRec.Digi_id
	_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(pReq, pDebug, common.EKYCCookieName, lUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	if lTestUserFlag == "1" {
		lErr = address.GenderInsertion(lResponse.Gender, lUid, lSessionId, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	for i := 0; i < len(lKeyndPairArr); i++ {

		lDocID := lKeyndPairArr[i].Value

		if !strings.EqualFold(common.AppRunMode, "prod") {
			// need remove below for production
			NewDocId, lErr := pdfgenerate.FileMoveProdtoDev(pDebug, lDocID)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			} else {
				lDocID = NewDocId
			}
		}
		// need remove above for production
		_, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(pReq, pDebug, common.EKYCCookieName, lUid)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}

		lErr = address.ProofId(pDebug, lDocID, lUid, lSessionId, lKeyndPairArr[i].Key, lTestUserFlag)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
		lErr = commonpackage.AttachmentlogFile(lUid, lKeyndPairArr[i].FileType, lDocID, pDebug)
		if lErr != nil {
			return helpers.ErrReturn(lErr)
		}
	}
	lSqlString := `update ekyc_request 
		set Name_As_Per_Aadhar  = ?,AadhraNo = ?
		where  Uid  = ?`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lSqlString, lResponse.Name, lResponse.MaskedAatharNo, lUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "GetDigiDataProcess (-)")

	return nil
}
