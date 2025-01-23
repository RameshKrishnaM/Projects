package pan

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	backofficecheck "fcs23pkg/integration/v2/backofficeCheck"
	panstatusverify "fcs23pkg/integration/v2/panStatusVerify"
	"fmt"
	"io/ioutil"
	"net/http"
	"regexp"
	"strings"
	"unicode/utf8"
)

type PanDataInfo struct {
	PanNumber string `json:"panno"`
	PanName   string `json:"panname"`
	PanDOB    string `json:"pandob"`
}
type PanStatusApiStruct struct {
	PanDataArr  []string `json:"PanDataArr"`
	ProcessType string   `json:"Processtype"`
}
type PanVerifyStruct struct {
	PanNumber          string `json:"PanNumber"`
	PanStatus          string `json:"PanStatus"`
	PanStatusDesc      string `json:"PanStatusDesc"`
	LastName           string `json:"LastName"`
	FirstName          string `json:"FirstName"`
	MiddleName         string `json:"MiddleName"`
	PanTitle           string `json:"PanTitle"`
	LastUpdatedDate    string `json:"LastUpdatedDate"`
	Nameofthecard      string `json:"Nameofthecard"`
	AadharLinkedStatus string `json:"AadharLinkedStatus"`
}
type PanStatusRespStruct struct {
	ReturnCode     string            `json:"ReturnCode"`
	ReturnCodeDesc string            `json:"ReturnCodeDesc"`
	RespRec        []PanVerifyStruct `json:"RespRec"`
	Status         string            `json:"status"`
	ErrMsg         string            `json:"ErrMsg"`
}
type RespStruct struct {
	LastName string `json:"lastname"`
	Status   string `json:"status"`
	ErrMsg   string `json:"msg"`
}

func GetPanStatus(w http.ResponseWriter, req *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)

	lDebug.Log(helpers.Statement, "GetPanStatus (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
	(w).Header().Set("Content-Type", "application/json")

	// fmt.Println("req test", req)
	if req.Method == "POST" {
		var lPanRespRec RespStruct
		var lErrcode, lMsg string

		lPanRespRec.Status = "S"
		lTestUserRec, lErr := TestUserEntry(req, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		}
		// lPanRespRec.LastName = lTestUserName

		lPanRespRec, lErrcode, lMsg = panProcessVerification(req, lDebug, lPanRespRec, lTestUserRec)
		if lErrcode != "" {
			fmt.Fprint(w, helpers.GetError_String(lErrcode, lMsg))
			return
		}

		lDatas, lErr := json.Marshal(lPanRespRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "Something Went Wrong, Please Try again after sometime "))
			return
		}
		fmt.Fprint(w, string(lDatas))

	} else {
		fmt.Fprint(w, helpers.GetError_String("Invalid Method Type", "Kindly try with POST Method"))
	}
	lDebug.Log(helpers.Statement, "GetPanStatus (-)")
}

type TestuserStruct struct {
	Pan, Dob, Name string
	isTestUser     bool
}

func TestUserEntry(req *http.Request, pDebug *helpers.HelperStruct) (lTestUserRec TestuserStruct, lErr error) {
	pDebug.Log(helpers.Statement, "TestUserEntry (+)")
	// var lPanData PanDataInfo
	// var lPanStatusData PanStatusRespStruct
	// var lRespRec PanVerifyStruct
	lTestAllow := common.TestAllow
	lTestUserRec.Pan = common.TestPan
	lTestUserRec.Dob = common.TestDOB
	// lTestUserRec.Dob = common.AlterDob
	// lTestUserRec.Pan = common.AlterPan
	lBodyData := fmt.Sprintf("%v", req.Body)
	lTestUserRec.isTestUser = (strings.EqualFold(lTestAllow, "Y") && strings.Contains(lBodyData, lTestUserRec.Pan) && strings.Contains(lBodyData, lTestUserRec.Dob))
	lTestUserRec.Name = "TEST USER"
	// if !lFlag {
	// 	lPanData.PanDOB = lTestDOB
	// 	lPanData.PanNumber = lTestPan
	// 	lPanData.PanName = lTestUserName

	// 	lRespRec.LastName = "Test User"
	// 	lRespRec.AadharLinkedStatus = "Y"
	// 	lRespRec.Nameofthecard = "Test User"
	// 	lRespRec.PanStatus = "E"
	// 	lRespRec.PanNumber = lTestPan
	// 	lPanStatusData.RespRec = append(lPanStatusData.RespRec, lRespRec)
	// 	lErr := panNoInsertDb(lPanData, lPanStatusData, pDebug, req)
	// 	if lErr != nil {
	// 		pDebug.Log(helpers.Elog, lErr.Error())
	// 		return "Test User", lFlag, helpers.ErrReturn(lErr)
	// 	}
	// }
	pDebug.Log(helpers.Statement, "TestUserEntry (-)")

	return lTestUserRec, nil
}

func panProcessVerification(req *http.Request, pDebug *helpers.HelperStruct, pPanRespRec RespStruct, pTestUserRec TestuserStruct) (RespStruct, string, string) {
	var lPanRec PanDataInfo
	var lPanStatusData PanStatusRespStruct
	pDebug.Log(helpers.Statement, "panProcessVerification (+)")
	// create an variable of the config file

	//reading the input
	lData, lErr := readInput(req, lPanRec, pDebug)
	pDebug.Log(helpers.Details, "lData", lData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PF01"+lErr.Error())
		return pPanRespRec, "PF01", "Please Check your Pan number or DOB"
	}
	if lData.PanDOB != "" {
		ErrMsg, key := IsDateFormatValidate(lData.PanDOB)
		if !key {
			return pPanRespRec, "E", ErrMsg
		}
	}
	if pTestUserRec.isTestUser {
		lData.PanDOB = pTestUserRec.Dob
		lData.PanNumber = pTestUserRec.Pan
	}
	// if condition only for development purpose
	if strings.ToUpper(common.BOCheck) != "N" && !pTestUserRec.isTestUser {
		lPanBackOffice, lErr := backofficecheck.BofficeCheck(pDebug, lData.PanNumber, "pan")
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return pPanRespRec, "E", "Something Went Wrong, Please Try again after sometime"
		}
		if lPanBackOffice {
			return pPanRespRec, "AA", "The given PAN number has an account with us"
		}
		// This method is used to check the pan number is existed or not in db
		lErr = panNoCheck(lData.PanNumber, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return pPanRespRec, "AA", "The given PAN number is already registered with us"
		}
	}
	// fmt.Println(len(lData.PanNumber), "***********")
	lPanError := validatePanNo(strings.ToUpper(lData.PanNumber), pDebug)
	if lPanError != "" {
		pDebug.Log(helpers.Elog, "PF05"+lPanError)
		return pPanRespRec, "PF05", lPanError
	} else {
		//getting the pan Status
		lPanStatusData, lErr = PanVerify(req, pDebug, lData.PanNumber, "EKYC_PanStatu _Verify")
		if lErr != nil {
			pDebug.Log(helpers.Elog, "PF07"+lErr.Error())
			return pPanRespRec, "PF08", helpers.ErrPrint(lErr)
		} else {
			if lPanStatusData.ReturnCode == "1" {
				// lPanError := validatePanNo("", pDebug)
				if lPanStatusData.RespRec[0].AadharLinkedStatus != "Y" {
					return pPanRespRec, "NA", "PAN and AADHAAR not linked"
				}
				if lPanStatusData.RespRec[0].PanStatus != "F" && lPanStatusData.RespRec[0].PanStatus != "X" && lPanStatusData.RespRec[0].PanStatus != "D" &&
					lPanStatusData.RespRec[0].PanStatus != "N" {

					lErr = panNoInsertDb(lData, lPanStatusData, pDebug, req)
					if lErr != nil {
						pDebug.Log(helpers.Elog, "PF09"+lErr.Error())
						return pPanRespRec, "PF09", lErr.Error()
					} else {
						pPanRespRec.LastName = lPanStatusData.RespRec[0].LastName
						if lPanStatusData.RespRec[0].MiddleName != "" && lPanStatusData.RespRec[0].FirstName != "" {
							pPanRespRec.LastName += " " + lPanStatusData.RespRec[0].MiddleName + " " + lPanStatusData.RespRec[0].FirstName
						} else if lPanStatusData.RespRec[0].MiddleName == "" && lPanStatusData.RespRec[0].FirstName != "" {
							pPanRespRec.LastName += " " + lPanStatusData.RespRec[0].FirstName
						}
					}
				} else {
					return pPanRespRec, "E", lPanStatusData.RespRec[0].PanStatusDesc
				}
			} else {
				return pPanRespRec, "E", lPanStatusData.ReturnCodeDesc
			}
		}
	}
	pDebug.Log(helpers.Statement, "panProcessVerification (-)")
	return pPanRespRec, "", ""
}

/*
   Purpose : This method is used to read the input body
   parameter : PanDataInfo
   Author : Sowmiya L
   Date : 05-June-2023
*/
func readInput(req *http.Request, lPanRec PanDataInfo, pDebug *helpers.HelperStruct) (PanDataInfo, error) {
	pDebug.Log(helpers.Statement, "readinput (+)")
	var lErr error
	//  create an instance of the structure

	//reading the request body
	lBody, lErr := ioutil.ReadAll(req.Body)
	pDebug.Log(helpers.Details, "lBody", string(lBody))
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lPanRec, helpers.ErrReturn(errors.New(" Unable to read the input"))
	}
	//converting the input into the structure
	lErr = json.Unmarshal(lBody, &lPanRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lPanRec, helpers.ErrReturn(errors.New(" Unable to read the input"))
	}

	// fmt.Println("lPanRec---------", lPanRec)
	pDebug.SetReference(lPanRec.PanNumber)
	//check if pan number is provided
	if len(lPanRec.PanNumber) == 0 {
		return lPanRec, helpers.ErrReturn(errors.New("PAN Number is missing. cannot continue processing"))
	}
	pDebug.Log(helpers.Statement, "readinput (-)")

	return lPanRec, nil
}
func IsDateFormatValidate(Date string) (string, bool) {

	if Date == "" {
		return "DOB Should not be Null", false
	}
	dateRegex, _ := regexp.Compile(`^(0[1-9]|[12]\d|3[01])/(0[1-9]|1[0-2])/\d{4}$`)

	match := dateRegex.MatchString(Date)
	if !match {
		return "DOB should in DD/MM/YYYY format", false
	}

	return "", true

}
func validatePanNo(pPanNo string, pDebug *helpers.HelperStruct) string {
	pDebug.Log(helpers.Statement, "validatePanNo (+)")
	if pPanNo == "" {
		return "PanNo Should not be empty "
	} else {
		if utf8.RuneCountInString(pPanNo) != 10 {
			return "PanNo should contain 10 Characters Only "
		}
		specialCharRegex := regexp.MustCompile("^[A-Z]{5}[0-9]{4}[A-Z]{1}$")
		flag := specialCharRegex.MatchString(pPanNo)
		if !flag {
			return "PanNo should contain 1st Five Characters Alphabets next Four characters Numberic last characters is Aplhabets "
		}
	}
	pDebug.Log(helpers.Statement, "validatePanNo (-)")
	return ""
}

/*
Purpose : This method is used to fetch the Pan Status in NSDL Api
Request : N/A
Response :
===========
On Success:
===========
{
    "ReturnCode": "Success",
    "RespRec": [
        {
            "PanNumber": "PVWPS2856G",
            "PanStatus": "EXISTING AND VALID",
            "LastName": "SOWMIYA",
            "FirstName": "LAKSHMANAN",
            "MiddleName": "",
            "PanTitle": "Kumari",
            "LastUpdatedDate": "12/07/2022",
            "Nameofthecard": "SOWMIYA LAKSHMANAN",
            "AadharLinkedStatus": "Y"
        },
		]
	}
===========
On Error:
===========
{
    "ReturnCode": "Authentication Failure",
    "RespRec": null
}
===========
On Error:
===========
"Error":
Author : Sowmiya L
Date : 20-November-2023
*/
func PanVerify(req *http.Request, pDebug *helpers.HelperStruct, pPanData string, pProcessType string) (PanStatusRespStruct, error) {
	pDebug.Log(helpers.Statement, "PanVerify (+)")
	var lPanDataRec PanStatusApiStruct
	var lPanServiceResp PanStatusRespStruct
	lPanDataRec.PanDataArr = append(lPanDataRec.PanDataArr, pPanData)
	lPanDataRec.ProcessType = pProcessType

	lPayload, lErr := json.Marshal(lPanDataRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PV01"+lErr.Error())
		return lPanServiceResp, helpers.ErrReturn(lErr)
	}
	//calling the Pan Status api
	lPanStatusAPIResp, lErr := panstatusverify.PanStatusverifyApiCall(string(lPayload), pDebug, req)
	pDebug.Log(helpers.Details, "lPanStatusAPIResp*******************", lPanStatusAPIResp)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PV02"+lErr.Error())
		return lPanServiceResp, helpers.ErrReturn(lErr)
	}
	//convert the xml response to a structure
	lErr = json.Unmarshal([]byte(lPanStatusAPIResp), &lPanServiceResp)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PV03"+lErr.Error())
		return lPanServiceResp, helpers.ErrReturn(errors.New("unable to process"))
	}
	pDebug.Log(helpers.Statement, "PanVerify (-)")
	return lPanServiceResp, nil
}

/*
Purpose : This method is used to insert the Pan no,Name and DOB in db
Request : N/A
Response :
===========
On Success:
===========
{
"Status": "Success",
}
===========
On Error:
===========
"Error":
Author : Sowmiya L
Date : 30-June-2023
*/

// db insert
func panNoInsertDb(pPanData PanDataInfo, pPanStatusData PanStatusRespStruct, pDebug *helpers.HelperStruct, req *http.Request) error {
	pDebug.Log(helpers.Statement, "panNoInsertDb (+)")

	lSessionId, lUid, lErr := sessionid.GetOldSessionUID(req, pDebug, common.EKYCCookieName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	NameAsPerName := pPanStatusData.RespRec[0].LastName
	if pPanStatusData.RespRec[0].MiddleName != "" && pPanStatusData.RespRec[0].FirstName != "" {
		NameAsPerName += " " + pPanStatusData.RespRec[0].MiddleName + " " + pPanStatusData.RespRec[0].FirstName
	} else if pPanStatusData.RespRec[0].MiddleName == "" && pPanStatusData.RespRec[0].FirstName != "" {
		NameAsPerName += " " + pPanStatusData.RespRec[0].FirstName
	}
	pDebug.Log(helpers.Details, "panNo :", pPanStatusData.RespRec[0].PanNumber, "Name :", pPanStatusData.RespRec[0].LastName, "DOB :", pPanData.PanDOB)
	insertString := `update ekyc_request set pan=? ,Name_As_Per_Pan = ?,DOB = ?,Aadhar_Linked = ?,
	ValidPan_Status = ?,NameonthePanCard = ?,Updated_Session_Id = ?,UpdatedDate = unix_timestamp()
	where Uid = ? `

	_, lErr = ftdb.NewEkyc_GDB.Exec(insertString,
		pPanStatusData.RespRec[0].PanNumber, NameAsPerName, pPanData.PanDOB, pPanStatusData.RespRec[0].AadharLinkedStatus,
		pPanStatusData.RespRec[0].PanStatus, pPanStatusData.RespRec[0].Nameofthecard, lSessionId, lUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = sessionid.UpdateZohoCrmDeals(pDebug, req, common.PanVerified)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = router.StatusInsert(pDebug, lUid, lSessionId, "PanDetails")
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "panNoInsertDb (-)")
	return nil
}
func panNoCheck(pPanNo string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "panNoCheck (+)")

	var lFlag string

	lCorestring := `SELECT CASE WHEN count(*) > 0 THEN 'Yes' ELSE 'No' END AS Flag
		FROM ekyc_request
		WHERE Pan  = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pPanNo)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lFlag)
			pDebug.Log(helpers.Details, "lFlag", lFlag)
			if lErr != nil {
				// pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
			if lFlag == "Yes" {
				// pDebug.Log(helpers.Elog, lErr.Error())
				pDebug.Log(helpers.Elog, "This Pan number is already present")
				return errors.New("pan number is already present")
			} else {
				pDebug.Log(helpers.Details, "This Pan number is continuely proceed")
			}
		}
	}

	return nil
}
