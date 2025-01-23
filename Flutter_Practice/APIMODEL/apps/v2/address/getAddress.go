package address

import (
	"encoding/json"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/appsession"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
	"strings"
)

type DbRespStruct struct {
	Name                 string `json:"name"`
	Source_Of_Address    string `json:"soa"`
	CORAddress1          string `json:"coradrs1"`
	CORAddress2          string `json:"coradrs2"`
	CORAddress3          string `json:"coradrs3"`
	CORCity              string `json:"corcity"`
	CORPincode           string `json:"corpincode"`
	CORState             string `json:"corstate"`
	CORCountry           string `json:"corcountry"`
	PERAddress1          string `json:"peradrs1"`
	PERAddress2          string `json:"peradrs2"`
	PERAddress3          string `json:"peradrs3"`
	PERCity              string `json:"percity"`
	PERPincode           string `json:"perpincode"`
	PERState             string `json:"perstate"`
	PERCountry           string `json:"percountry"`
	ProofofAddress       string `json:"peradrsproofname"`
	ProofofAddresscode   string `json:"peradrsproofcode"`
	PERDateofissue       string `json:"peradrsproofisudate"`
	PERProofExpriyDate   string `json:"perproofexpirydate"`
	PERProofNo           string `json:"peradrsproofno"`
	PERProofPlaceofissue string `json:"peradrsproofplaceisu"`
	PERDocID1            string `json:"docid1"`
	PERDocID2            string `json:"docid2"`
	PERFileName1         string `json:"perfilename1"`
	PERFileName2         string `json:"perfilename2"`
	Status               string `json:"status"`
	Switch               bool   `json:"aspermenantaddr"`
}

/*
Purpose : This method is used to fetch the user addres details in db
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
"Error": "Something went wrong"
Author : Sowmiya L
Date : 05-July-2023
*/
func GetAddress(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetAddress (+)")

	if r.Method == "GET" {
		var lResp DbRespStruct
		var id int
		var lDocIdArr []string
		lResp.Status = common.SuccessCode
		var lSignal, lkraId, lDigilockerId string
		// lSessionId, lErr := appsession.Kycreadcokkie(r, debug, common.EKYCCookieName)
		// if lErr != nil {
		// 	debug.Log(helpers.Elog, lErr.Error())
		// }
		lUid, lErr := appsession.Getuid(r, lDebug)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GA01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GA01", "Something went wrong. Please try agin later."))
			return
		}
		lDebug.SetReference(lUid)

		lSessionId, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(r, lDebug, common.EKYCCookieName, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GA011"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GA011", "Something went wrong.Please try again later."))
			return
		}

		// fmt.Println("lDb", lDb)
		lCorestring := `select nvl(id,""),nvl(Source_Of_Address,""),nvl(CorAddress1,""),nvl(CorAddress2,""),nvl(CorAddress3,""),nvl(CorCity,""),nvl(CorState,""),nvl(CorPincode,""),nvl(CorCountry,""),nvl(PerAddress1,""),nvl(PerAddress2,""),nvl(PerAddress3,""),nvl(PerCity,""),nvl(PerState,""),nvl(PerPincode,""),nvl(PerCountry,""),nvl(proofType,""),nvl(dateofProofIssue,""),nvl(Proof_No,""),nvl(ProofOfIssue,""),nvl(ProofExpriyDate,""),nvl(Proof_Doc_Id1,""),nvl(Proof_Doc_Id2,""),nvl(Kra_docid,""),nvl(Digilocker_docid,""),nvl(SameAsPermenentAddress,"") 
			from ekyc_address 
			where Request_Uid = ?
			and ( ? or Updated_Session_Id  = ?)`

		lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid, lTestUserFlag, lSessionId)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GA03"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GA03", "Something went wrong. Please try agin later."))
			return
		} else {
			defer lRows.Close()
			for lRows.Next() {
				lErr := lRows.Scan(&id, &lResp.Source_Of_Address, &lResp.CORAddress1, &lResp.CORAddress2, &lResp.CORAddress3, &lResp.CORCity, &lResp.CORState, &lResp.CORPincode, &lResp.CORCountry, &lResp.PERAddress1, &lResp.PERAddress2, &lResp.PERAddress3, &lResp.PERCity, &lResp.PERState, &lResp.PERPincode, &lResp.PERCountry, &lResp.ProofofAddresscode, &lResp.PERDateofissue, &lResp.PERProofNo, &lResp.PERProofPlaceofissue, &lResp.PERProofExpriyDate, &lResp.PERDocID1, &lResp.PERDocID2, &lkraId, &lDigilockerId, &lSignal)

				lDebug.Log(helpers.Details, "proofType", lResp.ProofofAddress)
				lDebug.Log(helpers.Details, "Date", lResp.PERDateofissue)
				lDebug.Log(helpers.Details, "PERProofNo", lResp.PERProofNo)
				lDebug.Log(helpers.Details, "PERProofPlaceofissue", lResp.PERProofPlaceofissue)
				lDebug.Log(helpers.Details, "id", id)
				// lDebug.Log(helpers.Details, "-------------------------------", lResp.ProofofAddress)
				if lSignal == "Y" {
					lResp.Switch = true
				} else {
					lResp.Switch = false
				}
				if lErr != nil {
					lDebug.Log(helpers.Elog, "GA05"+lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("GA05", "Something went wrong. Please try agin later."))
					return
				} else {

					lDebug.Log(helpers.Details, "DocId", lResp.PERDocID1, lResp.PERDocID2)
					lDocIdArr = append(lDocIdArr, lResp.PERDocID1)
					lDocIdArr = append(lDocIdArr, lResp.PERDocID2)
					for _, docID := range lDocIdArr {

						lCorestring := `SELECT nvl(FileName,"")
												FROM document_attachment_details dad
												WHERE id = ?`

						// Execute the query for each docid
						lRows, lErr := ftdb.MariaEKYCPRD_GDB.Query(lCorestring, docID)
						if lErr != nil {
							lDebug.Log(helpers.Elog, "GA07"+lErr.Error())
							fmt.Fprint(w, helpers.GetError_String("GA07", "Something went wrong. Please try agin later."))
							return
						} else {
							// Create slices to store filenames for each docid
							var filenames []string
							defer lRows.Close()
							for lRows.Next() {
								var filename string
								lErr := lRows.Scan(&filename)
								if lErr != nil {
									lDebug.Log(helpers.Elog, "GA08"+lErr.Error())
									fmt.Fprint(w, helpers.GetError_String("GA08", "Something went wrong. Please try agin later."))
									return
								} else {
									filenames = append(filenames, filename)
									if docID == lResp.PERDocID1 {
										lResp.PERFileName1 = filenames[0]
									} else if docID == lResp.PERDocID2 {
										lResp.PERFileName2 = filenames[0]
									}
								}
							}

						}
					}

				}
				var lColumnName string
				if strings.Contains(lResp.Source_Of_Address, "KRA") {
					lColumnName = "Name_As_Per_Pan"
				} else if strings.Contains(lResp.Source_Of_Address, "Digilocker") {
					lColumnName = "Name_As_Per_Aadhar"
				}
				if strings.EqualFold(lResp.Source_Of_Address, "KRA") {
					lResp.PERDocID1 = lkraId
				} else if strings.EqualFold(lResp.Source_Of_Address, "Digilocker") {
					lResp.PERDocID1 = lDigilockerId
				}
				if lColumnName != "" {
					lCorestring := `SELECT ` + lColumnName + `
												FROM ekyc_request
												WHERE Uid = ?`

					// Execute the query for each docid
					lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lUid)
					if lErr != nil {
						lDebug.Log(helpers.Elog, "GA17"+lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("GA17", "Something went wrong. Please try agin later."))
						return
					} else {
						defer lRows.Close()
						for lRows.Next() {
							lErr := lRows.Scan(&lResp.Name)
							if lErr != nil {
								lDebug.Log(helpers.Elog, "GA16"+lErr.Error())
								fmt.Fprint(w, helpers.GetError_String("GA16", "Something went wrong. Please try agin later."))
								return
							}
						}
					}
				}

				var lResponse commonpackage.DescriptionResp

				// if lResp.Source_Of_Address == "KRA" || lResp.Source_Of_Address == "Digilcoker" {
				if lResp.ProofofAddresscode != "" {
					lResponse, lErr = commonpackage.GetLookUpDescription(lDebug, "AddressProof", lResp.ProofofAddresscode, "Code")
					if lErr != nil {
						lDebug.Log(helpers.Elog, "GA10 "+lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("GA10 ", lErr.Error()))
						return
					}
					lResp.ProofofAddress = lResponse.Descirption
				}
				// } else {
				// 	lResp.ProofofAddresscode = lResp.ProofofAddress
				// }
				if lResp.CORState != "" {
					lResponse, lErr = commonpackage.GetLookUpDescription(lDebug, "state", lResp.CORState, "Code")
					if lErr != nil {
						lDebug.Log(helpers.Elog, "GA11 "+lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("GA11 ", "Something went wrong. Please try again later."))
						return
					}
					lResp.CORState = lResponse.Descirption
				}
				if lResp.PERState != "" {
					lResponse, lErr = commonpackage.GetLookUpDescription(lDebug, "state", lResp.PERState, "Code")
					if lErr != nil {
						lDebug.Log(helpers.Elog, "GA12 "+lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("GA12 ", "Something went wrong. Please try again later."))
						return
					}
					lResp.PERState = lResponse.Descirption
				}
				if lResp.CORCountry != "" {
					lResponse, lErr = commonpackage.GetLookUpDescription(lDebug, "country", lResp.CORCountry, "Code")
					if lErr != nil {
						lDebug.Log(helpers.Elog, "GA13 "+lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("GA13 ", "Something went wrong. Please try again later."))
						return
					}
					lResp.CORCountry = lResponse.Descirption
				}
				if lResp.PERCountry != "" {
					lResponse, lErr = commonpackage.GetLookUpDescription(lDebug, "country", lResp.PERCountry, "Code")
					if lErr != nil {
						lDebug.Log(helpers.Elog, "GA14 "+lErr.Error())
						fmt.Fprint(w, helpers.GetError_String("GA14 ", "Something went wrong. Please try again later."))
						return
					}
					lResp.PERCountry = lResponse.Descirption
				}

				// if lResp.Source_Of_Address == "KRA" || lResp.Source_Of_Address == "Digilocker" {
				// 	lDropdownHeader := "PanAddressProof"
				// 	lDropdownDescription := "PanAddressProofType"
				// 	lDropDropdownValueCode := lResp.ProofofAddress
				// 	lResp.ProofofAddress, lResp.ProofofAddresscode, lErr = commonpackage.ReadDropDownData(lDropdownHeader, lDropdownDescription, lDropDropdownValueCode, lDebug)
				// 	if lErr != nil {
				// 		lDebug.Log(helpers.Elog, "GA09"+lErr.Error())
				// 		fmt.Fprint(w, helpers.GetError_String("GA09", "Something went wrong. Please try agin later."))
				// 		return
				// 	}
				// } else {
				// 	lDropdownHeader := "AddressProof"
				// 	lDropdownDescription := "AddressProofType"
				// 	lDropDropdownValueCode := lResp.ProofofAddress
				// 	lResp.ProofofAddress, lResp.ProofofAddresscode, lErr = commonpackage.ReadDropDownData(lDropdownHeader, lDropdownDescription, lDropDropdownValueCode, lDebug)
				// 	if lErr != nil {
				// 		lDebug.Log(helpers.Elog, "GA10"+lErr.Error())
				// 		fmt.Fprint(w, helpers.GetError_String("GA10", "Something went wrong. Please try agin later."))
				// 		return
				// 	}
				// }
			}
		}

		lDatas, lErr := json.Marshal(lResp)
		lDebug.Log(helpers.Details, "lDatas", string(lDatas))

		if lErr != nil {
			lDebug.Log(helpers.Elog, "GA15"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GA15", "Something went wrong. Please try agin later."))
			return
		} else {
			fmt.Fprint(w, string(lDatas))
		}
		lDebug.RemoveReference()
		lDebug.Log(helpers.Statement, "GetAddress (-)")
	}
}
