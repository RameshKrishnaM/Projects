package nominee

import (
	"encoding/json"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/model"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
)

type nomineeResp struct {
	NomineeDataColl []model.NomineeData_Model `json:"nominee"`
	Status          string                    `json:"status"`
	ErrMsg          string                    `json:"errMsg"`
}

/*
Purpose : This method is used to Get the Nominee details from database
Request : nil


Response :
===========
On Success:
===========
{
NomineeDataColl:[GuardianAddress1: ""
GuardianAddress2: ""
GuardianCity: ""
GuardianCountry: "India"
GuardianEmailId: ""
GuardianFileName: ""
GuardianFilePath: ""
GuardianFileString: ""
GuardianFileUploadDocIds: ""
GuardianMobileNo: ""
GuardianName: ""
GuardianPincode: ""
GuardianProofNumber: ""
GuardianProofOfIdentity:""
GuardianRelationship: ""
GuardianState: ""
GuardianVisible:
false
ModelState: "db "
NoimineeFileName: "Flattrade_KYC_APIs.pdf"
NoimineeFilePath: "E:\\Kamatchirajan\\go\\learning\\DocumentsUploads\\7efcaf18-905f-4957-aec4-7b3a41a6eb67.pdf"
NoimineeFileString: ""
NomineeAddress1: "jbhwd"
NomineeAddress2: "jqehfdj"
NomineeCity: "wehfg"
NomineeCountry: "India"
NomineeDOB: "1999-05-05"
NomineeEmailId: "pr@fcsonline.co.in"
NomineeFileUploadDocIds: "2932"
NomineeID: 263
NomineeMobileNo: "8798989679"
NomineeName: "Test001"
NomineePincode: "678676"
NomineeProofNumber: "yujhytgj"
NomineeProofOfIdentity: "A"
NomineeRelationship: "M"
NomineeShare: "100"
NomineeState: "hghg"]
"Status": "Success",
ErrMsg": ""
}
===========
On Error:
===========
{
"Status": "Error",
ErrMsg": error
}
Author      : Kamatchirajan
Modified By : Prabhaharan
Date        : 10-July-2023
*/

func Get_Nominee_DB_Details(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "Get_Nominee_DB_Details (+)")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", " POST, PUT, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	//log.Println("Get_Nominee_DB_Details+")
	w.WriteHeader(200)
	if r.Method == "POST" {

		var resp nomineeResp
		var NomineeData, lEmptyData model.NomineeData_Model
		var Guardian string
		var lLookUpRec commonpackage.DescriptionResp
		resp.Status = common.SuccessCode
		_, RequestId, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		lDebug.SetReference(RequestId)
		if lErr != nil {
			resp.Status = common.LoginFailure
			resp.ErrMsg = "Error in Getting Request Id" + lErr.Error()
		} else {

			

				lSessionId, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(r, lDebug, common.EKYCCookieName, RequestId)
				if lErr != nil {
					resp.Status = common.ErrorCode
					resp.ErrMsg = "UnExpectedError:(NNDD02)" + lErr.Error()
				}

				//DataBase Table Name Changed---------------------------------------------------------------------------------

				//Guardian Visible changed by Prabhaharan

				coreString := `select nvl(Id,"") as NomineeID,nvl(NomineeName,""),nvl(NomineeRelationship,""),nvl(NomineeShare,""),nvl(NomineeDOB,""),nvl(NomineeAddress1,""),nvl(NomineeAddress2,""),nvl(NomineeAddress3,""),nvl(NomineeCity,""),nvl(NomineeState,""),nvl(NomineeCountry,""),nvl(NomineePincode,""),nvl(NomineeMobileNo,""),nvl(NomineeEmailId,""),nvl(NomineeProofOfIdentity,""),nvl(NomineeProofNumber,""),nvl(NomineeProofPlaceOfIssue,""),nvl(NomineeProofDateOfIssue,""),nvl(NomineeProofExpriyDate,""),nvl(NomineeFileUploadDocIds,""),nvl(GuardianVisible,""),nvl(GuardianName,""),nvl(GuardianRelationship,""),nvl(GuardianAddress1,""),nvl(GuardianAddress2,""),nvl(GuardianAddress3,""),nvl(GuardianCity,""),nvl(GuardianState,""),nvl(GuardianCountry,""),nvl(GuardianPincode,""),nvl(GuardianMobileNo,""),nvl(GuardianEmailId,""),nvl(GuardianProofOfIdentity,""),nvl(GuardianProofNumber,""),nvl(GuardianProofPlaceOfIssue,""),nvl(GuardianProofDateOfIssue,""),nvl(GuardianProofExpriyDate,""),nvl(GuardianFileUploadDocIds,""),'db' as ModelState,nvl(Nominee_Title,''),nvl(Guardian_Title,'')
					from ekyc_nominee_details
					where RequestId = ?
					and ( ? or ModifiedBy = ?)
					`

				rows, lErr := ftdb.NewEkyc_GDB.Query(coreString, RequestId, lTestUserFlag, lSessionId)
				if lErr != nil {

					resp.Status = common.ErrorCode
					resp.ErrMsg = "UnExpectedError:(NNDD03)" + lErr.Error()
				} else {

					//data := DB_Rows_To_JSON(rows)
					defer rows.Close()
					for rows.Next() {
						lErr := rows.Scan(&NomineeData.NomineeID, &NomineeData.NomineeName, &NomineeData.NomineeRelationship, &NomineeData.NomineeShare,
							&NomineeData.NomineeDOB, &NomineeData.NomineeAddress1, &NomineeData.NomineeAddress2, &NomineeData.NomineeAddress3, &NomineeData.NomineeCity, &NomineeData.NomineeState,
							&NomineeData.NomineeCountry, &NomineeData.NomineePincode, &NomineeData.NomineeMobileNo, &NomineeData.NomineeEmailId, &NomineeData.NomineeProofOfIdentity,
							&NomineeData.NomineeProofNumber, &NomineeData.NomineePlaceofIssue, &NomineeData.NomineeProofDateofIssue, &NomineeData.NomineeProofExpriyDate, &NomineeData.NomineeFileUploadDocIds, &Guardian, &NomineeData.GuardianName, &NomineeData.GuardianRelationship,
							&NomineeData.GuardianAddress1, &NomineeData.GuardianAddress2, &NomineeData.GuardianAddress3, &NomineeData.GuardianCity, &NomineeData.GuardianState, &NomineeData.GuardianCountry,
							&NomineeData.GuardianPincode, &NomineeData.GuardianMobileNo, &NomineeData.GuardianEmailId, &NomineeData.GuardianProofOfIdentity, &NomineeData.GuardianProofNumber, &NomineeData.GuardianPlaceofIssue, &NomineeData.GuardianProofDateofIssue, &NomineeData.GuardianProofExpriyDate,
							&NomineeData.GuardianFileUploadDocIds, &NomineeData.ModelState, &NomineeData.NomineeTitle, &NomineeData.GuardianTitle)
						if lErr != nil {

							resp.Status = common.ErrorCode
							resp.ErrMsg = "UnExpectedError:(NNDD04)" + lErr.Error()
						}

						if NomineeData.NomineeProofOfIdentity != "" {
							lLookUpRec, lErr = commonpackage.GetLookUpDescription(lDebug, "Proof of Identity", NomineeData.NomineeProofOfIdentity, "code")
							if lErr != nil {

								resp.Status = common.ErrorCode
								resp.ErrMsg = "UnExpectedError:(NNDD05)" + lErr.Error()
							}
							NomineeData.NomineeProofOfIdentitydesc = lLookUpRec.Descirption
						}

						if NomineeData.NomineeRelationship != "" {
							lLookUpRec, lErr = commonpackage.GetLookUpDescription(lDebug, "Nominee Relationship", NomineeData.NomineeRelationship, "code")
							if lErr != nil {

								resp.Status = common.ErrorCode
								resp.ErrMsg = "UnExpectedError:(NNDD07)" + lErr.Error()
							}
							NomineeData.NomineeRelationshipdesc = lLookUpRec.Descirption
						}

						if NomineeData.GuardianRelationship != "" {
							lLookUpRec, lErr = commonpackage.GetLookUpDescription(lDebug, "nomineeGuardianRelationship", NomineeData.GuardianRelationship, "code")
							if lErr != nil {

								resp.Status = common.ErrorCode
								resp.ErrMsg = "UnExpectedError:(NNDD08)" + lErr.Error()
							}
							NomineeData.GuardianRelationshipdesc = lLookUpRec.Descirption
						}

						if NomineeData.NomineeCountry != "" {
							lLookUpRec, lErr = commonpackage.GetLookUpDescription(lDebug, "country", NomineeData.NomineeCountry, "code")
							if lErr != nil {
								resp.Status = common.ErrorCode
								resp.ErrMsg = "UnExpectedError:(NNDD14)" + lErr.Error()
							}
							NomineeData.NomineeCountry = lLookUpRec.Descirption
						}
						if NomineeData.NomineeState != "" {
							lLookUpRec, lErr = commonpackage.GetLookUpDescription(lDebug, "state", NomineeData.NomineeState, "code")
							if lErr != nil {
								resp.Status = common.ErrorCode
								resp.ErrMsg = "UnExpectedError:(NNDD15)" + lErr.Error()
							}
							NomineeData.NomineeState = lLookUpRec.Descirption
						}
						if NomineeData.GuardianName != "" {
							lLookUpRec, lErr = commonpackage.GetLookUpDescription(lDebug, "Proof of Identity", NomineeData.GuardianProofOfIdentity, "code")
							if lErr != nil {

								resp.Status = common.ErrorCode
								resp.ErrMsg = "UnExpectedError:(NNDD06)" + lErr.Error()
							}
							NomineeData.GuardianProofOfIdentitydesc = lLookUpRec.Descirption
							lLookUpRec, lErr = commonpackage.GetLookUpDescription(lDebug, "country", NomineeData.GuardianCountry, "code")
							NomineeData.GuardianCountry = lLookUpRec.Descirption
							if lErr != nil {
								resp.Status = common.ErrorCode
								resp.ErrMsg = "UnExpectedError:(NNDD16)" + lErr.Error()
							}
							lLookUpRec, lErr = commonpackage.GetLookUpDescription(lDebug, "state", NomineeData.GuardianState, "code")
							NomineeData.GuardianState = lLookUpRec.Descirption
							if lErr != nil {
								resp.Status = common.ErrorCode
								resp.ErrMsg = "UnExpectedError:(NNDD17)" + lErr.Error()
							}
						}

						lDebug.Log(helpers.Details, "NomineeData.GuardianFileUploadDocIds", NomineeData.GuardianFileUploadDocIds)

						// if NomineeData.NomineeFileUploadDocIds != "" {
						// 	coreString := `select nvl(dad.FileName,"") ,nvl(dad.FilePath,"")
						// 	from ekyc.document_attachment_details dad
						// 	where dad.id =?`
						// 	rows, lErr := lDb.Query(coreString, NomineeData.NomineeFileUploadDocIds)
						// 	if lErr != nil {
						// 		resp.Status = common.ErrorCode
						// 		resp.ErrMsg = "UnExpectedError:(NNDD10)" + lErr.Error()
						// 	} else {

						// 		for rows.Next() {
						// 			lErr := rows.Scan(&NomineeData.NoimineeFileName, &NomineeData.NoimineeFilePath)
						// 			if lErr != nil {
						// 				resp.Status = common.ErrorCode
						// 				resp.ErrMsg = "UnExpectedError:(NNDD11)" + lErr.Error()
						// 			}
						// 		}
						// 	}
						// }
						// if NomineeData.GuardianFileUploadDocIds != "" {
						// 	lDebug.Log(helpers.Details, "Get Guardian Doc Id")
						// 	coreString := `select nvl(dad.FileName,"") ,nvl(dad.FilePath,"")
						// from ekyc.document_attachment_details dad
						// where dad.id =?`
						// 	rows, lErr := lDb.Query(coreString, NomineeData.GuardianFileUploadDocIds)
						// 	if lErr != nil {
						// 		resp.Status = common.ErrorCode
						// 		resp.ErrMsg = "UnExpectedError:(NNDD12)" + lErr.Error()
						// 	} else {

						// 		for rows.Next() {
						// 			lErr := rows.Scan(&NomineeData.GuardianFileName, &NomineeData.GuardianFilePath)
						// 			if lErr != nil {
						// 				resp.Status = common.ErrorCode
						// 				resp.ErrMsg = "UnExpectedError:(NNDD13)" + lErr.Error()
						// 			}
						// 		}
						// 	}
						// }

						if Guardian == "1" {
							NomineeData.GuardianVisible = true
						} else {
							NomineeData.GuardianVisible = false
						}
						resp.NomineeDataColl = append(resp.NomineeDataColl, NomineeData)
						NomineeData = lEmptyData
						lDebug.Log(helpers.Details, "resp.NomineeDataColl", resp.NomineeDataColl)
					}
				}
			
			data, err := json.Marshal(resp)
			if err != nil {
				fmt.Fprintf(w, "Error taking data"+err.Error())
			} else {
				fmt.Fprint(w, string(data))
				lDebug.Log(helpers.Details, string(data))
			}
		}
		lDebug.RemoveReference()
		lDebug.Log(helpers.Statement, "Get_Nominee_DB_Details (-)")

	}

}

type nomineePdfResp struct {
	RequestId string `json:"requestid"`
	DocId     string `json:"docid"`
	ErrMsg    string `json:"errmsg"`
	Status    string `json:"status"`
}

/*
Purpose : This method is used to Insert the Nominee details in database
Request : {
NomineeDataColl:[GuardianAddress1: ""
GuardianAddress2: ""
GuardianCity: ""
GuardianCountry: "India"
GuardianEmailId: ""
GuardianFileName: ""
GuardianFilePath: ""
GuardianFileString: ""
GuardianFileUploadDocIds: ""
GuardianMobileNo: ""
GuardianName: ""
GuardianPincode: ""
GuardianProofNumber: ""
GuardianProofOfIdentity:""
GuardianRelationship: ""
GuardianState: ""
GuardianVisible:
false
ModelState: "db "
NoimineeFileName: ""
NoimineeFilePath: ""
NoimineeFileString: ""
NomineeAddress1: "jbhwd"
NomineeAddress2: "jqehfdj"
NomineeCity: "wehfg"
NomineeCountry: "India"
NomineeDOB: "1999-05-05"
NomineeEmailId: "pr@fcsonline.co.in"
NomineeFileUploadDocIds: ""
NomineeID: 263
NomineeMobileNo: "8798989679"
NomineeName: "Test001"
NomineePincode: "678676"
NomineeProofNumber: "yujhytgj"
NomineeProofOfIdentity: "A"
NomineeRelationship: "M"
NomineeShare: "100"
NomineeState: "hghg"]
}
Response :
===========
On Success:
===========
{
"Status": "Success",
ErrMsg": ""
}
===========
On Error:
===========
{
"Status": "Error",
ErrMsg": error
}
Author      : Kamatchirajan
Modified By : Prabhaharan
Date        : 10-July-2023
*/
// PostNomineeFile posts new file
func PostNomineeFile(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "PostNomineeFile (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "  POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	//log.Println("PostNomineeFile+")
	if r.Method == "POST" {

		var nomineeResp nomineePdfResp

		nomineeResp.Status = common.SuccessCode

		//client, err := appsso.ValidateAndGetClientDetails2(r, common.EKYCAppName, common.EKYCCookieName)
		SessionId, Uid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		lDebug.SetReference(Uid)
		if lErr != nil {
			//common.LogError("nominee.PostNomineeFile", Uid+":(NPNF01)", lErr.Error())
			nomineeResp.Status = common.LoginFailure
			nomineeResp.ErrMsg = "UnExpectedError:(NPNF01)" + lErr.Error()

		} else {
			if Uid != "" {
				nomineeResp.RequestId, lErr = NomineeFileSave(r, Uid, SessionId, lDebug)
				if lErr != nil {
					//common.LogError("nominee.PostNomineeFile", Uid+":(NPNF02)", lErr.Error())
					nomineeResp.Status = common.ErrorCode
					nomineeResp.ErrMsg = "UnExpectedError:(NPNF02)" + lErr.Error()
				}

			}
		}

		data, err := json.Marshal(nomineeResp)
		lDebug.Log(helpers.Details, "nominee_endpoint", string(data))
		if err != nil {
			fmt.Fprintf(w, "Error taking data"+err.Error())
		} else {
			fmt.Fprint(w, string(data))
		}

	}
	lDebug.RemoveReference()
	lDebug.Log(helpers.Statement, "PostNomineeFile (-)")

}

type AddressStruct struct {
	Address1 string `json:"address1"`
	Address2 string `json:"address2"`
	Address3 string `json:"address3"`
	PinCode  string `json:"pincode"`
	State    string `json:"state"`
	City     string `json:"city"`
	Country  string `json:"country"`
	Status   string `json:"status"`
	ErrMsg   string `json:"errmsg"`
}

func GetAddressDetails(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)

	lDebug.Log(helpers.Statement, "GetAddressDetails (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	if r.Method == "GET" {
		var lResponse AddressStruct
		var lLookUpRec commonpackage.DescriptionResp

		lResponse.Status = common.SuccessCode
		_, Uid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		lDebug.SetReference(Uid)
		if lErr != nil {
			lResponse.Status = common.ErrorCode
			lResponse.ErrMsg = helpers.GetError_String("UnExpectedError:(NGAD01)", lErr.Error())

		} else {
		
				lCoreString := `select nvl(ea.PerAddress1,"") ,nvl(ea.PerAddress2,"") ,nvl(ea.PerAddress3,"") ,nvl(ea.PerCity,"") ,nvl(ea.PerState,"") ,nvl(ea.PerPincode,""),nvl(ea.PerCountry,"")
			from ekyc_address ea
			where ea.Request_Uid =?`
				lRows, lEerr := ftdb.NewEkyc_GDB.Query(lCoreString, Uid)
				if lEerr != nil {
					lResponse.Status = common.ErrorCode
					lResponse.ErrMsg = ""
					// response.ErrMsg = helpers.GetError_String("UnExpectedError:(NGAD03)", lErr.Error())
				} else {
					defer lRows.Close()
					for lRows.Next() {
						lErr := lRows.Scan(&lResponse.Address1, &lResponse.Address2, &lResponse.Address3, &lResponse.City, &lResponse.State, &lResponse.PinCode, &lResponse.Country)
						if lErr != nil {
							lResponse.Status = common.ErrorCode
							lResponse.ErrMsg = helpers.GetError_String("UnExpectedError:(NGAD04)", lErr.Error())
						}
					}
				}
				lLookUpRec, lErr = commonpackage.GetLookUpDescription(lDebug, "state", lResponse.State, "code")
				if lErr != nil {

					lResponse.Status = common.ErrorCode
					lResponse.ErrMsg = helpers.GetError_String("UnExpectedError:(NNDD08)", lErr.Error())
				}
				lResponse.State = lLookUpRec.Descirption
				lLookUpRec, lErr = commonpackage.GetLookUpDescription(lDebug, "country", lResponse.Country, "code")
				if lErr != nil {

					lResponse.Status = common.ErrorCode
					lResponse.ErrMsg = helpers.GetError_String("UnExpectedError:(NNDD08)", lErr.Error())
				}
				lResponse.Country = lLookUpRec.Descirption
				// fmt.Println(lResponse.State)
			
		}
		data, err := json.Marshal(lResponse)
		if err != nil {
			fmt.Fprintf(w, "Error taking data"+err.Error())
		} else {
			fmt.Fprint(w, string(data))
		}
	}
	lDebug.RemoveReference()
	lDebug.Log(helpers.Statement, "GetAddressDetails (-)")

}
