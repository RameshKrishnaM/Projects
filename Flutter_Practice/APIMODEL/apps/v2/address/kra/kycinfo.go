package kra

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v2/address"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"regexp"
	"strconv"
	"strings"
)

type insertStruct struct {
	CORAddress1           string `json:"coradrs1"`
	CORAddress2           string `json:"coradrs2"`
	CORAddress3           string `json:"coradrs3"`
	CORCity               string `json:"corcity"`
	CORState              string `json:"corstate"`
	CORCountry            string `json:"corcountry"`
	CORPincode            string `json:"corpincode"`
	PERAddress1           string `json:"peradrs1"`
	PERAddress2           string `json:"peradrs2"`
	PERAddress3           string `json:"peradrs3"`
	PERCity               string `json:"percity"`
	PERState              string `json:"perstate"`
	PERCountry            string `json:"percountry"`
	PERPincode            string `json:"perpincode"`
	ProofofAddress        string `json:"peradrsproofname"`
	PERAdrsProofNo        string `json:"peradrsproofno"`
	PERProofofAddressDate string `json:"perproofofaddressdate"`
	CORProofofAddressType string `json:"coradrsproofname"`
	CORProofofAddressno   string `json:"corproofofaddressno"`
	CORProofofAddressDate string `json:"corproofofaddressdate"`
	ProofId               string `json:"docid1"`
}

/*
Purpose : This method is used to insert the user kyc info in db
Request : N/A
Response :
===========
On Success:
===========
{
"Status": "S",
“StatusMsg": "Inserted Successfuly”
}
===========
On Error:
===========
"Error":
Author : Sowmiya L
Date : 28-June-2023
*/
func Kyc(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "kycinfo (+)")

	if r.Method == "POST" {
		lErr := kraInsertDb(w, r, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "KYC01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("KYC01", "Something went wrong. Please try again later."))
			return
		}
	}
	lDebug.Log(helpers.Statement, "kycinfo (-)")
}

func kraInsertDb(w http.ResponseWriter, r *http.Request, pDebug *helpers.HelperStruct) error {

	pDebug.Log(helpers.Statement, "kraInsertDb (+)")

	var lAddressInsert insertStruct
	var lFlag, lPerFlag string
	lBody, lErr := ioutil.ReadAll(r.Body)
	pDebug.Log(helpers.Details, "lBody---kraInsertDb", string(lBody))

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lErr = json.Unmarshal(lBody, &lAddressInsert)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	lFiletype := tomlconfig.GtomlConfigLoader.GetValueString("kra", "Filetype")

	lSessionId, lUid, lErr := sessionid.GetOldSessionUID(r, pDebug, common.EKYCCookieName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	pDebug.SetReference(lUid)

	lAddressInsert.ProofofAddress, lErr = commonpackage.GetDefaultCode(pDebug, "AddressProof", lAddressInsert.ProofofAddress)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lAddressInsert.CORProofofAddressType, lErr = commonpackage.GetDefaultCode(pDebug, "AddressProof", lAddressInsert.CORProofofAddressType)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lAddressInsert.CORCountry, lErr = commonpackage.GetDefaultCode(pDebug, "country", lAddressInsert.CORCountry)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lAddressInsert.CORState, lErr = commonpackage.GetDefaultCode(pDebug, "state", lAddressInsert.CORState)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lAddressInsert.PERCountry, lErr = commonpackage.GetDefaultCode(pDebug, "country", lAddressInsert.PERCountry)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	lAddressInsert.PERState, lErr = commonpackage.GetDefaultCode(pDebug, "state", lAddressInsert.PERState)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	// lCorestring := `select nvl(code,"") from ekyc_lookup_details eld where eld.description = ?`
	// lRows, lErr := lDb.Query(lCorestring, lAddressInsert.ProofofAddress)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return helpers.ErrReturn(lErr)
	// } else {
	// for lRows.Next() {
	// lErr := lRows.Scan(&lAddressInsert.ProofofAddress)
	// // fmt.Println("code", lAddressInsert.ProofofAddress)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return helpers.ErrReturn(lErr)
	// } else {

	lCorestring := `SELECT CASE WHEN count(*) > 0 THEN 'Y' ELSE 'N' END AS Flag
			FROM ekyc_address
			WHERE Request_Uid  = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lFlag)
			pDebug.Log(helpers.Details, "lFlag", lFlag)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		}
		if lAddressInsert.ProofofAddress == "12" {
			if len(lAddressInsert.PERAdrsProofNo) == 4 && !validateAadhar(lAddressInsert.PERAdrsProofNo) {
				lAddressInsert.PERAdrsProofNo = "XXXXXXXX" + lAddressInsert.PERAdrsProofNo
			} else if validateAadhar(lAddressInsert.PERAdrsProofNo) {
				lAddressInsert.PERAdrsProofNo = ""
			}
		}
		if lAddressInsert.CORProofofAddressType == "12" {
			if len(lAddressInsert.CORProofofAddressno) == 4 && !validateAadhar(lAddressInsert.CORProofofAddressno) {
				lAddressInsert.CORProofofAddressno = "XXXXXXXX" + lAddressInsert.CORProofofAddressno
			} else if validateAadhar(lAddressInsert.CORProofofAddressno) {
				lAddressInsert.CORProofofAddressno = ""
			}
		}
		pDebug.Log(helpers.Details, lAddressInsert.CORProofofAddressno, "lAddressInsert.CORProofofAddressno")
		pDebug.Log(helpers.Details, lAddressInsert.PERAdrsProofNo, "lAddressInsert.PERAdrsProofNo")
		// lRegex := regexp.MustCompile(`^\d+$`)
		// lIsOnlyNumbers := lRegex.MatchString(lAddressInsert.PERAdrsProofNo)
		// if lIsOnlyNumbers {
		// 	lAddressInsert.PERAdrsProofNo = ""
		// }
		// lAddressInsert.PERAdrsProofNo = strings.ToUpper(lAddressInsert.PERAdrsProofNo)
		// if lAddressInsert.ProofofAddress == "12" && len(lAddressInsert.PERAdrsProofNo) == 4 {
		// 	lAddressInsert.PERAdrsProofNo = "XXXXXXXX" + lAddressInsert.PERAdrsProofNo
		// }
		// if len(lAddressInsert.PERAdrsProofNo) < 4 || (len(lAddressInsert.PERAdrsProofNo) > 4 && len(lAddressInsert.PERAdrsProofNo) < 12) {
		// 	lAddressInsert.PERAdrsProofNo = ""
		// }
		// if len(lAddressInsert.PERAdrsProofNo) > 12 {
		// 	lAddressInsert.PERAdrsProofNo = ""
		// }

		// lAddressInsert.CORProofofAddressno = strings.ToUpper(lAddressInsert.CORProofofAddressno)
		// if lAddressInsert.CORProofofAddressType == "12" && len(lAddressInsert.CORProofofAddressno) == 4 {
		// 	lAddressInsert.CORProofofAddressno = "XXXXXXXX" + lAddressInsert.CORProofofAddressno
		// }
		// if len(lAddressInsert.CORProofofAddressno) < 4 || (len(lAddressInsert.CORProofofAddressno) > 4 && len(lAddressInsert.CORProofofAddressno) < 12) {
		// 	lAddressInsert.CORProofofAddressno = ""
		// }
		// if len(lAddressInsert.CORProofofAddressno) > 12 {
		// 	lAddressInsert.CORProofofAddressno = ""
		// }
		if strings.EqualFold(lAddressInsert.CORAddress1, lAddressInsert.PERAddress1) &&
			strings.EqualFold(lAddressInsert.CORAddress2, lAddressInsert.PERAddress2) &&
			strings.EqualFold(lAddressInsert.CORAddress3, lAddressInsert.PERAddress3) &&
			strings.EqualFold(lAddressInsert.CORCity, lAddressInsert.PERCity) &&
			strings.EqualFold(lAddressInsert.CORState, lAddressInsert.PERState) &&
			strings.EqualFold(lAddressInsert.CORPincode, lAddressInsert.PERPincode) &&
			strings.EqualFold(lAddressInsert.CORCountry, lAddressInsert.PERCountry) {
			lPerFlag = "Y"
		} else {
			lPerFlag = "N"
		}
		lUpdatedPerAddr1 := address.ReplaceContainsString(pDebug, lAddressInsert.PERAddress1)
		lUpdatedPerAddr2 := address.ReplaceContainsString(pDebug, lAddressInsert.PERAddress2)
		lUpdatedPerAddr3 := address.ReplaceContainsString(pDebug, lAddressInsert.PERAddress3)
		lUpdatedCorAddr1 := address.ReplaceContainsString(pDebug, lAddressInsert.CORAddress1)
		lUpdatedCorAddr2 := address.ReplaceContainsString(pDebug, lAddressInsert.CORAddress2)
		lUpdatedCorAddr3 := address.ReplaceContainsString(pDebug, lAddressInsert.CORAddress3)

		lPerCity := address.ReplaceContainsString(pDebug, lAddressInsert.PERCity)
		lCorCity := address.ReplaceContainsString(pDebug, lAddressInsert.CORCity)

		if lFlag == "Y" {
			lCoreString := `update ekyc_address set 
						Source_Of_Address="KRA",
						CorAddress1=?,CorAddress2=?,CorAddress3=?,
						CorCity=?,CorState=?,CorPincode=?,CorCountry=?,
						PerAddress1=?,PerAddress2=?,PerAddress3=?,
						PerCity=?,PerState=?,PerPincode=?,PerCountry=?,
						U_PerAddress1 = ?,U_PerAddress2 = ?,U_PerAddress3 = ?,
						U_CorAddress1 = ?,U_CorAddress2 = ?,U_CorAddress3 = ?,
						proofType=?,dateofProofIssue=?,ProofOfIssue="",Proof_No=?,
						Proof_Doc_Id1="",Proof_Doc_Id2="",
						Cor_Address_DocId1="",Cor_Address_DocId2="",
						ProofExpriyDate="",
						Updated_Session_Id=?,UpdatedDate=unix_timestamp(),
						SameAsPermenentAddress=?,Kra_docid=?,
						COR_ProofNo=?, COR_ProofType=?, COR_ProofDateIssue=?
				  where Request_Uid=?`
			_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString,
				lAddressInsert.CORAddress1, lAddressInsert.CORAddress2, lAddressInsert.CORAddress3,
				lCorCity, lAddressInsert.CORState, lAddressInsert.CORPincode, lAddressInsert.CORCountry,
				lAddressInsert.PERAddress1, lAddressInsert.PERAddress2, lAddressInsert.PERAddress3,
				lPerCity, lAddressInsert.PERState, lAddressInsert.PERPincode, lAddressInsert.PERCountry,
				lUpdatedPerAddr1, lUpdatedPerAddr2, lUpdatedPerAddr3,
				lUpdatedCorAddr1, lUpdatedCorAddr2, lUpdatedCorAddr3,
				lAddressInsert.ProofofAddress, lAddressInsert.PERProofofAddressDate, lAddressInsert.PERAdrsProofNo, lSessionId, lPerFlag, lAddressInsert.ProofId,
				lAddressInsert.CORProofofAddressno, lAddressInsert.CORProofofAddressType, lAddressInsert.CORProofofAddressDate,
				lUid)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
			if lAddressInsert.ProofofAddress == "12" && len(lAddressInsert.PERAdrsProofNo) == 12 {
				lSqlString := `update ekyc_request 
				set AadhraNo = ?
				where  Uid  = ?`
				_, lErr = ftdb.NewEkyc_GDB.Exec(lSqlString, lAddressInsert.PERAdrsProofNo, lUid)
				if lErr != nil {
					return helpers.ErrReturn(lErr)
				}
			}
			lErr = commonpackage.AttachmentlogFile(lUid, lFiletype, lAddressInsert.ProofId, pDebug)
			if lErr != nil {
				return helpers.ErrReturn(lErr)
			}
			lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.AddressVerified)
			if lErr != nil {
				return helpers.ErrReturn(lErr)
			}
			lErr = router.StatusInsert(pDebug, lUid, lSessionId, "AddressVerification")
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			}
		} else if lFlag == "N" {
			lCoreString := `insert into ekyc_address (
							Request_Uid,Source_Of_Address,
							CorAddress1,CorAddress2,CorAddress3,
							CorCity,CorState,CorPincode,CorCountry,
							PerAddress1,PerAddress2,PerAddress3,
							PerCity,PerState,PerPincode,PerCountry,
							U_PerAddress1,U_PerAddress2,U_PerAddress3,
							U_CorAddress1,U_CorAddress2,U_CorAddress3,
							proofType,dateofProofIssue,ProofOfIssue,Proof_No,
							Proof_Doc_Id1,Proof_Doc_Id2,ProofExpriyDate,
							Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate,
							SameAsPermenentAddress,Kra_docid,
							COR_ProofNo, COR_ProofType, COR_ProofDateIssue)
							values(?,"KRA",
							?,?,?,
							?,?,?,?,
							?,?,?,
							?,?,?,?,
							?,?,?,
							?,?,?,
							?,?,"",?,"","","",?,?,unix_timestamp(),unix_timestamp(),?,?,?,?,?)`
			_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, lUid, lAddressInsert.CORAddress1, lAddressInsert.CORAddress2, lAddressInsert.CORAddress3, lCorCity, lAddressInsert.CORState, lAddressInsert.CORPincode, lAddressInsert.CORCountry, lAddressInsert.PERAddress1, lAddressInsert.PERAddress2, lAddressInsert.PERAddress3, lPerCity, lAddressInsert.PERState, lAddressInsert.PERPincode, lAddressInsert.PERCountry, lUpdatedPerAddr1, lUpdatedPerAddr2, lUpdatedPerAddr3, lUpdatedCorAddr1, lUpdatedCorAddr2, lUpdatedCorAddr3, lAddressInsert.ProofofAddress, lAddressInsert.PERProofofAddressDate, lAddressInsert.PERAdrsProofNo, lAddressInsert.ProofId,
				lSessionId, lSessionId, lPerFlag, lAddressInsert.ProofId, lAddressInsert.CORProofofAddressno, lAddressInsert.CORProofofAddressType, lAddressInsert.CORProofofAddressDate)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return helpers.ErrReturn(lErr)
			} else {
				pDebug.Log(helpers.Statement, "Inserted successfully")
				lErr = commonpackage.AttachmentlogFile(lUid, lFiletype, lAddressInsert.ProofId, pDebug)
				if lErr != nil {
					return helpers.ErrReturn(lErr)
				}
				if lAddressInsert.ProofofAddress == "12" && len(lAddressInsert.PERAdrsProofNo) == 12 {
					lSqlString := `update ekyc_request 
					set AadhraNo = ?
					where  Uid  = ?`
					_, lErr = ftdb.NewEkyc_GDB.Exec(lSqlString, lAddressInsert.PERAdrsProofNo, lUid)
					if lErr != nil {
						return helpers.ErrReturn(lErr)
					}
				}
				lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.AddressVerified)
				if lErr != nil {
					return helpers.ErrReturn(lErr)
				}
				lErr = router.StatusInsert(pDebug, lUid, lSessionId, "AddressVerification")
				if lErr != nil {
					pDebug.Log(helpers.Elog, lErr.Error())
					return helpers.ErrReturn(lErr)
				}

			}
		} else {
			pDebug.Log(helpers.Elog, errors.New(" Something went wrong, please try again later"))
		}
	}
	lDatas, lErr := json.Marshal(lAddressInsert)
	pDebug.Log(helpers.Details, "lDatas", string(lDatas))

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		fmt.Fprint(w, helpers.GetError_String("", "Something went wrong"))
	} else {
		fmt.Fprint(w, helpers.GetMsg_String("S", "Inserted Successfully"))
	}
	pDebug.RemoveReference()
	pDebug.Log(helpers.Statement, "kraInsertDb (-)")
	return nil
}

func ExtractAadharnumber(pDebug *helpers.HelperStruct, pInputData string) (string, error) {
	re := regexp.MustCompile(`\d+`) // Match one or more digits
	match := re.FindString(pInputData)

	lAadharNumber := ""
	if match != "" {
		number, lErr := strconv.Atoi(match)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "Error converting to integer:", lErr.Error())
			return "", helpers.ErrReturn(lErr)
		}
		lAadharNumber = strconv.Itoa(number)
		pDebug.Log(helpers.Details, "input Params =>", pInputData, " Output Params => ", lAadharNumber)
	} else {
		pDebug.Log(helpers.Details, "input Params =>", pInputData, "Integer not found", " Output Params => ", lAadharNumber)
	}
	return "XXXXXXXX" + lAadharNumber, nil
}
func validateAadhar(pAadhar string) bool {

	log.Println(pAadhar, "pAadhar")

	if len(pAadhar) == 4 {
		lPattern := `^[a-zA-Z0-9]{4}$`

		re := regexp.MustCompile(lPattern)
		lFlag := re.MatchString(pAadhar)
		if !lFlag {
			return true
		}
	} else if len(pAadhar) == 12 {
		lPattern := `^[a-zA-Z0-9]{12}$`

		re := regexp.MustCompile(lPattern)
		lFlag := re.MatchString(pAadhar)
		if !lFlag {
			return true
		}
	}

	if len(pAadhar) > 0 {
		// Check for the first eight characters being the same
		lFirstChar := pAadhar[0]
		if len(pAadhar) == 4 {
			log.Println("If 1")
			if strings.Count(pAadhar, string(lFirstChar)) == 4 {
				log.Println("If 2")
				return true
			} else {
				log.Println("If 3")
				return false
			}
		} else if len(pAadhar) != 12 {
			log.Println("If 4")
			return true
		}

		if strings.Count(pAadhar, string(lFirstChar)) == 12 {
			log.Println("If 5")
			return true
		}

		pSliceAadharNumber := pAadhar[8:]
		log.Println(strings.Count(pAadhar[:8], string(lFirstChar)) != 8, "strings.Count(pAadhar[:8], string(lFirstChar)) != 8")
		log.Println(strings.Count(pAadhar[8:], string(pSliceAadharNumber[0])), "strings.Count(pAadhar[8:], string(pSliceAadharNumber[0]))")
		log.Println((strings.Count(pAadhar[:8], string(lFirstChar)) != 8 || (strings.Count(pAadhar[8:], string(pSliceAadharNumber[0])) == 4)), "-----Aadhar-----")
		return (strings.Count(pAadhar[:8], string(lFirstChar)) != 8 || (strings.Count(pAadhar[8:], string(pSliceAadharNumber[0])) == 4))

	} else {
		return true
	}
}
