package panstatus

import (
	"errors"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	backofficecheck "fcs23pkg/integration/v2/backofficeCheck"
	"regexp"
	"strings"
	"unicode/utf8"
)

func ValidatePanReq(pDebug *helpers.HelperStruct, pPANData PanDataInfo, pTestUserRec TestuserStruct, ReqId string) (string, string) {
	pDebug.Log(helpers.Statement, "ValidatePanReq (+)")

	if pPANData.PanDOB != "" {
		ErrMsg, key := IsDateFormatValidate(pPANData.PanDOB)
		if !key {
			return "E", ErrMsg
		}
	}
	if pTestUserRec.isTestUser {
		pPANData.PanDOB = pTestUserRec.Dob
		pPANData.PanNumber = pTestUserRec.Pan
	}
	// if condition only for development purpose
	if strings.ToUpper(common.BOCheck) != "N" && !pTestUserRec.isTestUser {
		lPanBackOffice, lErr := backofficecheck.BofficeCheck(pDebug, pPANData.PanNumber, "pan")
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return "E", "Something Went Wrong, Please Try again after sometime"
		}
		if lPanBackOffice {
			return "AA", "The given PAN number has an account with us"
		}
		// This method is used to check the pan number is existed or not in db
		lErr = PANNoCheck(pPANData.PanNumber, ReqId, pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return "AA", lErr.Error()
		}
	}
	// fmt.Println(len(lData.PanNumber), "***********")
	lPanError := ValidatePanNo(strings.ToUpper(pPANData.PanNumber), pDebug)
	if lPanError != "" {
		pDebug.Log(helpers.Elog, "PF05"+lPanError)
		return "PF05", lPanError
	}

	pDebug.Log(helpers.Statement, "ValidatePanReq (-)")
	return "", ""
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
func ValidatePanNo(pPanNo string, pDebug *helpers.HelperStruct) string {
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

func PANNoCheck(pPanNo, pReqId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "panNoCheck (+)")

	var lFlag, lReqId string
	lCorestring := `SELECT CASE WHEN count(*) > 0 THEN 'Yes' ELSE 'No' END AS Flag, nvl(Uid,'')Uid
		FROM ekyc_request
		WHERE Pan  = ? and isActive ='Y'`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pPanNo)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lFlag, &lReqId)
			pDebug.Log(helpers.Details, "lFlag", lFlag)
			if lErr != nil {
				// pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
			if lFlag == "Yes" && lReqId != pReqId {
				// pDebug.Log(helpers.Elog, lErr.Error())
				pDebug.Log(helpers.Elog, "The given PAN number is already registered with us")
				return errors.New(" The given PAN number is already registered with us")
			} else {
				pDebug.Log(helpers.Details, "This Pan number is continuely proceed")
			}
		}
	}

	return nil
}
