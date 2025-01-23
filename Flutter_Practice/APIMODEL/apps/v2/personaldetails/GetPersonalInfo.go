package personaldetails

import (
	"encoding/json"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io/ioutil"
	"net/http"
)

type PersonalStruct struct {
	Uid                     string `json:"uid"`
	FatherName              string `json:"fathername"`
	MotherName              string `json:"mothername"`
	AnnualIncome            string `json:"annualincome"`
	TradingExperience       string `json:"tradingexperience"`
	Occupation              string `json:"occupation"`
	Gender                  string `json:"gender"`
	EmailOwner              string `json:"emailowner"`
	PhoneOwner              string `json:"phoneowner"`
	EmailOwnerName          string `json:"emailownername"`
	PhoneOwnerName          string `json:"phoneownername"`
	PoliticalExpo           string `json:"politicalexpo"`
	MaritalStatus           string `json:"maritalstatus"`
	Education               string `json:"education"`
	EducationOthers         string `json:"educationothers"`
	OccupationOthers        string `json:"occupationothers"`
	MotherTitle             string `json:"Mothertitle"`
	FatherTitle             string `json:"fathertitle"`
	NomineeOpted            string `json:"nomineeopted"`
	EmailId                 string `json:"emailId"`
	PhoneNumber             string `json:"phoneNumber"`
	PastActions             string `json:"pastActions"`
	PastActionsDesc         string `json:"pastActionsDesc"`
	DealSubBroker           string `json:"dealSubBroker"`
	DealSubBrokerDesc       string `json:"dealSubBrokerDesc"`
	FatcaDeclaration        string `json:"fatcaDeclaration"`
	ResidenceCountry        string `json:"residenceCountry"`
	TaxIdendificationNumber string `json:"taxIdendificationNumber"`
	PlaceofBirth            string `json:"placeofBirth"`
	CountryofBirth          string `json:"countryofBirth"`
	ForeignAddress1         string `json:"foreignAddress1"`
	ForeignAddress2         string `json:"foreignAddress2"`
	ForeignAddress3         string `json:"foreignAddress3"`
	ForeignCity             string `json:"foreignCity"`
	ForeignCountry          string `json:"foreignCountry"`
	ForeignState            string `json:"foreignState"`
	ForeignPincode          string `json:"foreignPincode"`
	FatcaTaxExempt          string `json:"fatcaTaxExempt"`
	FatcaTaxExemptReason    string `json:"fatcaTaxExemptReason"`
}

// type FatcaDeclarationStruct struct {
// 	ResidenceCountry        string `json:"residenceCountry"`
// 	TaxIdendificationNumber string `json:"taxIdendificationNumber"`
// 	PlaceofBirth            string `json:"placeofBirth"`
// 	CountryofBirth          string `json:"countryofBirth"`
// 	ForeignAddress1         string `json:"foreignAddress1"`
// 	ForeignAddress2         string `json:"foreignAddress2"`
// 	ForeignAddress3         string `json:"foreignAddress3"`
// 	ForeignCity             string `json:"foreignCity"`
// 	ForeignCountry          string `json:"foreignCountry"`
// 	ForeignState            string `json:"foreignState"`
// 	ForeignPincode          string `json:"foreignPincode"`
// }

type Reponse struct {
	Status string `json:"status"`
	ErrMsg string `json:"errMsg"`
}

/*
Purpose : This method is used to insert the PersonalDetails of Client into Database
Request :
 {
	FatherFirstName
	FatherLastName
	AnnualIncome
	TradingExperience
	Occupation
	Nominee
	PoliticalExpo
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
Author : Prabhaharan
Date : 19-June-2023
Modified by : Sowmiya L
Date : 19-Jan-2024
*/

func InsertPersonalDetails(w http.ResponseWriter, req *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(req)
	lDebug.Log(helpers.Statement, "InsertPersonalDetails (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "PUT,OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")
	(w).Header().Set("Content-Type", "application/json")

	if req.Method == "PUT" {
		var lPersonalInfo PersonalStruct
		var lresponse Reponse
		var lIsExistRcd, lIsFatcaExistRcd string
		lresponse.Status = common.ErrorCode
		body, lerr := ioutil.ReadAll(req.Body)
		lDebug.Log(helpers.Details, "body", string(body))
		if lerr != nil {

			lresponse.Status = common.ErrorCode
			lresponse.ErrMsg = helpers.GetError_String("Error Reading body", lerr.Error())
		} else {
			lerr = json.Unmarshal(body, &lPersonalInfo)
			lDebug.SetReference(lPersonalInfo.FatherName)
			if lerr != nil {

				lresponse.Status = common.ErrorCode
				lresponse.ErrMsg = helpers.GetError_String("Error during Unmarshal", lerr.Error())
			} else {

				SessionId, Uid, lErr := sessionid.GetOldSessionUID(req, lDebug, common.EKYCCookieName)
				if lErr != nil {
					lresponse.Status = common.ErrorCode
					lresponse.ErrMsg = helpers.GetError_String("Error in Getting Request Id", lErr.Error())
				} else {

					corestring := `SELECT CASE WHEN count(*) > 0 THEN 'Yes' ELSE 'No' END AS Flag
					FROM ekyc_personal ep 
					WHERE ep.Request_Uid  = ?`
					rows, lerr := ftdb.NewEkyc_GDB.Query(corestring, Uid)
					if lerr != nil {

						lresponse.Status = common.ErrorCode
						lresponse.ErrMsg = helpers.GetError_String("Error in Db 01", lerr.Error())
					} else {
						defer rows.Close()
						for rows.Next() {
							lerr := rows.Scan(&lIsExistRcd)
							lDebug.Log(helpers.Details, "lFlag", lIsExistRcd)
							if lerr != nil {
								lresponse.ErrMsg = helpers.GetError_String("Error in Db 02", lerr.Error())
							}
						}
						if lPersonalInfo.Occupation != "" || lPersonalInfo.Education != "" {
							if lPersonalInfo.Occupation != "711" {
								lPersonalInfo.OccupationOthers = ""
							}
							if lPersonalInfo.Education != "808" {
								lPersonalInfo.EducationOthers = ""
							}
						}
						if lPersonalInfo.PastActions == "N" {
							lPersonalInfo.PastActionsDesc = ""
						}
						if lPersonalInfo.DealSubBroker == "N" {
							lPersonalInfo.DealSubBrokerDesc = ""
						}
						if lPersonalInfo.FatcaTaxExempt == "N" {
							lPersonalInfo.FatcaTaxExemptReason = ""
						}
						if lPersonalInfo.FatcaDeclaration == "N" {
							lErr := RemoveFatcaRecords(Uid, lDebug)
							if lErr != nil {
								lresponse.Status = common.ErrorCode
								lresponse.ErrMsg = helpers.GetError_String("Error in Query Execution 03", lerr.Error())
							}
						}

						var BoTitle string
						if lPersonalInfo.Gender == "111" {
							BoTitle = "Mr"
						} else if lPersonalInfo.Gender == "112" && lPersonalInfo.MaritalStatus == "902" {
							BoTitle = "Miss"
						} else if lPersonalInfo.Gender == "112" && lPersonalInfo.MaritalStatus != "902" {
							BoTitle = "Mrs"
						}

						if lIsExistRcd == "Yes" {
							corestring := `update ekyc_personal set Father_SpouceName=?,Mother_Name=?,Gender=?,Occupation=?,Occupation_Others =?,Annual_Income=?,
						   Politically_Exposed=?,Trading_Experience=?,Edu_Qualification=?,Education_Others=?,Phone_Owner=?,Phone_Owner_Name=?,Email_Owner=?,Email_Owner_Name=?,
						   Marital_Status=?,Nominee=?,PastActionStatus =?,PastActionDesc =?,Subroker_Status =?,Subroker_Desc =?,Updated_Session_Id=?,CreatedDate=unix_timestamp(now()),UpdatedDate=unix_timestamp(now()),Father_Title=?,Mother_Title=?,FatcaDeclaration=?
						  where Request_Uid=?`
							_, lerr = ftdb.NewEkyc_GDB.Exec(corestring, lPersonalInfo.FatherName, lPersonalInfo.MotherName, lPersonalInfo.Gender, lPersonalInfo.Occupation, lPersonalInfo.OccupationOthers, lPersonalInfo.AnnualIncome, lPersonalInfo.PoliticalExpo, lPersonalInfo.TradingExperience, lPersonalInfo.Education, lPersonalInfo.EducationOthers, lPersonalInfo.PhoneOwner, lPersonalInfo.PhoneOwnerName, lPersonalInfo.EmailOwner, lPersonalInfo.EmailOwnerName, lPersonalInfo.MaritalStatus, lPersonalInfo.NomineeOpted, lPersonalInfo.PastActions, lPersonalInfo.PastActionsDesc, lPersonalInfo.DealSubBroker, lPersonalInfo.DealSubBrokerDesc, SessionId, lPersonalInfo.FatherTitle, lPersonalInfo.MotherTitle, lPersonalInfo.FatcaDeclaration, Uid)
							if lerr != nil {
								lresponse.Status = common.ErrorCode
								lresponse.ErrMsg = helpers.GetError_String("Error in Query Execution 04", lerr.Error())
							} else {
								corestring := `SELECT CASE WHEN count(*) > 0 THEN 'Yes' ELSE 'No' END AS Flag
					FROM ekyc_fatcadeclaration_details 
					WHERE Request_Uid  = ?`
								rows, lerr := ftdb.NewEkyc_GDB.Query(corestring, Uid)
								if lerr != nil {
									lresponse.Status = common.ErrorCode
									lresponse.ErrMsg = helpers.GetError_String("Error in Db 01", lerr.Error())
								} else {
									defer rows.Close()
									for rows.Next() {
										lerr := rows.Scan(&lIsFatcaExistRcd)
										lDebug.Log(helpers.Details, "lFlag", lIsFatcaExistRcd)
										if lerr != nil {
											lresponse.ErrMsg = helpers.GetError_String("Error in Db 02", lerr.Error())
										}
									}
								}
								if lIsFatcaExistRcd == "Yes" {
									lerr := UpdateFatcaDetails(Uid, SessionId, lPersonalInfo, lDebug)
									if lerr != nil {
										lresponse.Status = common.ErrorCode
										lresponse.ErrMsg = helpers.GetError_String("Error in Query Execution 05", lerr.Error())
									}
								} else {
									if lPersonalInfo.FatcaDeclaration == "Y" {
										lerr := InsertFatcaDetails(Uid, SessionId, lPersonalInfo, lDebug)
										if lerr != nil {
											lresponse.Status = common.ErrorCode
											lresponse.ErrMsg = helpers.GetError_String("Error in Query Execution 06", lerr.Error())
										}
									}
								}

								lErr = router.StatusInsert(lDebug, Uid, SessionId, "ProfileDetails")
								if lErr != nil {
									lresponse.Status = common.ErrorCode
									lresponse.ErrMsg = helpers.GetError_String("Error in Query Execution 07", lErr.Error())
								} else {
									lresponse.Status = common.SuccessCode
								}

							}
						} else if lIsExistRcd == "No" {
							coreString := `insert into ekyc_personal (Request_Uid, Father_SpouceName,Mother_Name,Gender,Occupation,Occupation_Others,Annual_Income,Politically_Exposed,Trading_Experience,Edu_Qualification,Education_Others,Phone_Owner,Phone_Owner_Name,Email_Owner,Email_Owner_Name,Marital_Status,Nominee,PastActionStatus,PastActionDesc,Subroker_Status,Subroker_Desc,Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate,Father_Title,Mother_Title,FatcaDeclaration)
								 values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,unix_timestamp(now()),unix_timestamp(now()),?,?,?)`
							_, lerr = ftdb.NewEkyc_GDB.Exec(coreString, Uid, lPersonalInfo.FatherName, lPersonalInfo.MotherName, lPersonalInfo.Gender, lPersonalInfo.Occupation, lPersonalInfo.OccupationOthers, lPersonalInfo.AnnualIncome, lPersonalInfo.PoliticalExpo, lPersonalInfo.TradingExperience, lPersonalInfo.Education, lPersonalInfo.EducationOthers, lPersonalInfo.PhoneOwner, lPersonalInfo.PhoneOwnerName, lPersonalInfo.EmailOwner, lPersonalInfo.EmailOwnerName, lPersonalInfo.MaritalStatus, lPersonalInfo.NomineeOpted, lPersonalInfo.PastActions, lPersonalInfo.PastActionsDesc, lPersonalInfo.DealSubBroker, lPersonalInfo.DealSubBrokerDesc, SessionId, SessionId, lPersonalInfo.FatherTitle, lPersonalInfo.MotherTitle, lPersonalInfo.FatcaDeclaration)

							if lerr != nil {
								lresponse.Status = common.ErrorCode
								lresponse.ErrMsg = helpers.GetError_String("Error in Query Execution 08", lerr.Error())
							} else {
								if lPersonalInfo.FatcaDeclaration == "Y" {
									lerr := InsertFatcaDetails(Uid, SessionId, lPersonalInfo, lDebug)
									if lerr != nil {
										lresponse.Status = common.ErrorCode
										lresponse.ErrMsg = helpers.GetError_String("Error in Query Execution 09", lerr.Error())
									}
								}

								// 	coreString := `update ekyc_request set Personal_Status='S'
								// where Uid =?`

								// _, lerr = db.Exec(coreString, Uid)
								// if lerr != nil {
								// 	lresponse.Status = common.ErrorCode
								// 	lresponse.ErrMsg = helpers.GetError_String("Error in Query Execution 02", lerr.Error())
								// } else {
								lErr = router.StatusInsert(lDebug, Uid, SessionId, "ProfileDetails")
								if lErr != nil {
									lresponse.Status = common.ErrorCode
									lresponse.ErrMsg = helpers.GetError_String("Error in Query Execution 10", lErr.Error())
								} else {
									lresponse.Status = common.SuccessCode
								}
							}
						}
						corestring := `UPDATE ekyc_request
							SET bo_title=? where Uid= ?`
						_, lerr = ftdb.NewEkyc_GDB.Exec(corestring, BoTitle, Uid)
						if lerr != nil {
							lresponse.Status = common.ErrorCode
							lresponse.ErrMsg = helpers.GetError_String("Error in Query Execution 11", lerr.Error())
						} else {
							if lPersonalInfo.NomineeOpted == "N" {
								lErr := RemoveNomineeRecords(Uid, lDebug)
								if lErr != nil {
									lresponse.Status = common.ErrorCode
									lresponse.ErrMsg = helpers.GetError_String("Error in Query Execution 12", lErr.Error())
								} else {
									lresponse.Status = common.SuccessCode
								}
							} else {
								lresponse.Status = common.SuccessCode
							}
						}
					}
				}
			}

		}
		data, lerr := json.Marshal(lresponse)
		if lerr != nil {
			lDebug.Log(helpers.Elog, lerr.Error())
			fmt.Fprint(w, helpers.GetError_String("Error taking data", lerr.Error()))
		} else {
			fmt.Fprint(w, string(data))
			// fmt.Fprintf(w, helpers.GetMsg_String("S", data))
		}
		lDebug.Log(helpers.Details, "lresponse", lresponse)
		lDebug.Log(helpers.Statement, "InsertPersonalDetails (-)")
	}
}
func RemoveFatcaRecords(RequestId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "RemoveFatcaRecords (+)", RequestId)
	DeleteString := `delete from ekyc_fatcadeclaration_details 
	where Request_uid =?`
	_, lErr := ftdb.NewEkyc_GDB.Exec(DeleteString, RequestId)

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		//return helpers.ErrReturn(errors.New(lErr))
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "RemoveFatcaRecords (-)")
	return nil

}
func RemoveNomineeRecords(RequestId string, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "RemoveNomineeRecords (+)")
	DeleteString := `delete from ekyc_nominee_details 
	where RequestId =?`
	_, lErr := ftdb.NewEkyc_GDB.Exec(DeleteString, RequestId)

	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "RemoveNomineeRecords (-)")
	return nil

}

// INSERT the Facta declaration information in the ekyc_fatcadeclaration_details table from db
func InsertFatcaDetails(Uid string, SessionId string, lPersonalInfo PersonalStruct, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "InsertFatcaDetails (+)")

	coreString := `INSERT INTO ekyc_fatcadeclaration_details
	(Request_uid,Residence_Country, Tax_Idendification_Number,Place_of_Birth, Country_of_Birth, Foreign_Address1, Foreign_Address2, Foreign_Address3, Foreign_City, Foreign_Country, Foreign_State, Foreign_Pincode,Tax_Exempt, Tax_Exempt_Reason,  Session_Id, Updated_Session_Id, CreatedDate, UpdatedDate)
	VALUES(?,?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?, unix_timestamp(now()),unix_timestamp(now()))`
	_, lerr := ftdb.NewEkyc_GDB.Exec(coreString, Uid, lPersonalInfo.ResidenceCountry, lPersonalInfo.TaxIdendificationNumber, lPersonalInfo.PlaceofBirth, lPersonalInfo.CountryofBirth, lPersonalInfo.ForeignAddress1, lPersonalInfo.ForeignAddress2, lPersonalInfo.ForeignAddress3, lPersonalInfo.ForeignCity, lPersonalInfo.ForeignCountry, lPersonalInfo.ForeignState, lPersonalInfo.ForeignPincode, lPersonalInfo.FatcaTaxExempt, lPersonalInfo.FatcaTaxExemptReason, SessionId, SessionId)
	if lerr != nil {
		pDebug.Log(helpers.Elog, lerr.Error())
		return helpers.ErrReturn(lerr)
	}
	pDebug.Log(helpers.Statement, "InsertFatcaDetails (-)")
	return nil
}

// UPDATE the Facta declaration information in the ekyc_fatcadeclaration_details table from db
func UpdateFatcaDetails(Uid string, SessionId string, lPersonalInfo PersonalStruct, pDebug *helpers.HelperStruct) error {
	pDebug.Log(helpers.Statement, "UpdateFatcaDetails (+)")

	coreString := `UPDATE ekyc_fatcadeclaration_details
	SET Residence_Country=?, Tax_Idendification_Number=?, Place_of_Birth=?, Country_of_Birth=?, Foreign_Address1=?, Foreign_Address2=?, Foreign_Address3=?, Foreign_City=?, Foreign_Country=?, Foreign_State=?, Foreign_Pincode=?,Tax_Exempt=?, Tax_Exempt_Reason =?, Session_Id=?, Updated_Session_Id=?, CreatedDate=unix_timestamp(now()), UpdatedDate=unix_timestamp(now())
	WHERE Request_uid=?`
	_, lerr := ftdb.NewEkyc_GDB.Exec(coreString, lPersonalInfo.ResidenceCountry, lPersonalInfo.TaxIdendificationNumber, lPersonalInfo.PlaceofBirth, lPersonalInfo.CountryofBirth, lPersonalInfo.ForeignAddress1, lPersonalInfo.ForeignAddress2, lPersonalInfo.ForeignAddress3, lPersonalInfo.ForeignCity, lPersonalInfo.ForeignCountry, lPersonalInfo.ForeignState, lPersonalInfo.ForeignPincode, lPersonalInfo.FatcaTaxExempt, lPersonalInfo.FatcaTaxExemptReason, SessionId, SessionId, Uid)
	if lerr != nil {
		pDebug.Log(helpers.Elog, lerr.Error())
		return helpers.ErrReturn(lerr)
	}
	pDebug.Log(helpers.Statement, "UpdateFatcaDetails (-)")
	return nil
}

// FETCH the Facta declaration information in the ekyc_fatcadeclaration_details table from db
func FetchFatcaDetails(Uid string, lFetchFatca response, pDebug *helpers.HelperStruct) (response, error) {
	pDebug.Log(helpers.Statement, "FetchFatcaDetails (+)")

	lCoreString := `SELECT nvl(Residence_Country,''), nvl(Tax_Idendification_Number,''), nvl(Place_of_Birth,''), nvl(Country_of_Birth,''), nvl(Foreign_Address1,''), nvl(Foreign_Address2,''), nvl(Foreign_Address3,''), nvl(Foreign_City,''), nvl(Foreign_Country,''), nvl(Foreign_State,''),
	nvl(Foreign_Pincode,''),nvl(Tax_Exempt,""),nvl(Tax_Exempt_Reason,"")
	FROM ekyc_fatcadeclaration_details where Request_uid = ?`
	rows, lerr := ftdb.NewEkyc_GDB.Query(lCoreString, Uid)
	if lerr != nil {
		lFetchFatca.Status = common.ErrorCode
		lFetchFatca.ErrMsg = helpers.GetError_String("pGPU003", lerr.Error())
	} else {
		lFetchFatca.Status = common.SuccessCode
		defer rows.Close()

		for rows.Next() {
			lErr := rows.Scan(&lFetchFatca.PersonalStruct.ResidenceCountry, &lFetchFatca.PersonalStruct.TaxIdendificationNumber, &lFetchFatca.PersonalStruct.PlaceofBirth, &lFetchFatca.PersonalStruct.CountryofBirth, &lFetchFatca.PersonalStruct.ForeignAddress1, &lFetchFatca.PersonalStruct.ForeignAddress2, &lFetchFatca.PersonalStruct.ForeignAddress3, &lFetchFatca.PersonalStruct.ForeignCity, &lFetchFatca.PersonalStruct.ForeignCountry, &lFetchFatca.PersonalStruct.ForeignState, &lFetchFatca.PersonalStruct.ForeignPincode, &lFetchFatca.PersonalStruct.FatcaTaxExempt, &lFetchFatca.PersonalStruct.FatcaTaxExemptReason)
			if lErr != nil {
				lFetchFatca.Status = common.ErrorCode
				lFetchFatca.ErrMsg = helpers.GetError_String("pGPU006", lErr.Error())
			}
		}
	}
	pDebug.Log(helpers.Statement, "FetchFatcaDetails (-)")
	return lFetchFatca, nil
}

type PersonalUpdt struct {
	FatherName              string `json:"fathername"`
	MotherName              string `json:"mothername"`
	AnnualIncome            string `json:"annualincome"`
	TradingExperience       string `json:"tradingexperience"`
	Occupation              string `json:"occupation"`
	Gender                  string `json:"gender"`
	EmailOwner              string `json:"emailowner"`
	EmailOwnerName          string `json:"emailownername"`
	EmailId                 string `json:"emailId"`
	PhoneNumber             string `json:"phoneNumber"`
	PhoneOwner              string `json:"phoneowner"`
	PhoneOwnername          string `json:"phoneownername"`
	PoliticalExpo           string `json:"politicalexpo"`
	MaritalStatus           string `json:"maritalstatus"`
	Education               string `json:"education"`
	OccupationOthers        string `json:"occupationothers"`
	EducationOthers         string `json:"educationothers"`
	FatherTitle             string `json:"fathertitle"`
	MotherTitle             string `json:"mothertitle"`
	NomineeOpted            string `json:"nomineeopted"`
	SourceOfAddress         string `json:"soa"`
	PastActions             string `json:"pastActions"`
	PastActionsDesc         string `json:"pastActionsDesc"`
	DealSubBroker           string `json:"dealSubBroker"`
	DealSubBrokerDesc       string `json:"dealSubBrokerDesc"`
	FatcaDeclaration        string `json:"fatcaDeclaration"`
	ResidenceCountry        string `json:"residenceCountry"`
	TaxIdendificationNumber string `json:"taxIdendificationNumber"`
	PlaceofBirth            string `json:"placeofBirth"`
	CountryofBirth          string `json:"countryofBirth"`
	ForeignAddress1         string `json:"foreignAddress1"`
	ForeignAddress2         string `json:"foreignAddress2"`
	ForeignAddress3         string `json:"foreignAddress3"`
	ForeignCity             string `json:"foreignCity"`
	ForeignCountry          string `json:"foreignCountry"`
	ForeignState            string `json:"foreignState"`
	ForeignPincode          string `json:"foreignPincode"`
	FatcaTaxExempt          string `json:"fatcaTaxExempt"`
	FatcaTaxExemptReason    string `json:"fatcaTaxExemptReason"`
}
type response struct {
	PersonalStruct PersonalUpdt `json:"personalStruct"`
	Status         string       `json:"status"`
	ErrMsg         string       `json:"ErrMsg"`
}

func GetPersonalUpdate(w http.ResponseWriter, req *http.Request) {
	debug := new(helpers.HelperStruct)
	debug.SetUid(req)

	debug.Log(helpers.Statement, "GetPersonalUpdate (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	//(w).Header().Set("Access-Control-Allow-Origin", "*")
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")
	// (w).Header().Set("Content-Type", "application/json")

	if req.Method == "GET" {
		var lSessionId, lTestUserFlag string
		//var details staffList
		var response response

		response.Status = common.ErrorCode
		_, Uid, lErr := sessionid.GetOldSessionUID(req, debug, common.EKYCCookieName)
		if lErr != nil {
			response.Status = common.ErrorCode
			response.ErrMsg = "pGPU002 " + lErr.Error()
		} else {

			lSessionId, lTestUserFlag, lErr = sessionid.VerifyTestUserSession(req, debug, common.EKYCCookieName, Uid)
			if lErr != nil {
				response.Status = common.ErrorCode
				response.ErrMsg = "pGPU004 " + lErr.Error()
			}
			lCoreString := `select Source_Of_Address from ekyc_address where Request_Uid = ?`
			rows, lerr := ftdb.NewEkyc_GDB.Query(lCoreString, Uid)
			if lerr != nil {

				response.Status = common.ErrorCode
				response.ErrMsg = "pGPU006 " + lerr.Error()
			} else {
				response.Status = common.SuccessCode
				defer rows.Close()

				for rows.Next() {
					lErr := rows.Scan(&response.PersonalStruct.SourceOfAddress)
					if lErr != nil {

						response.Status = common.ErrorCode
						response.ErrMsg = "pGPU006 " + lErr.Error()
					}
				}
			}
			coreString := `select nvl(ep.Father_SpouceName,'') ,nvl(ep.Mother_Name,'') ,nvl(ep.Gender,'') ,nvl(ep.Occupation,'') ,nvl(ep.Occupation_Others,'') ,nvl(ep.Annual_Income,'') ,nvl(ep.Politically_Exposed,'') ,nvl(ep.Trading_Experience,'') ,nvl(ep.Edu_Qualification,'') ,nvl(ep.Phone_Owner,'') ,nvl(ep.Phone_Owner_Name,''),nvl(ep.Email_Owner,''),nvl(ep.Email_Owner_Name,'') ,nvl(ep.Marital_Status,''),nvl(ep.Nominee,''),nvl(ep.Education_Others,''),nvl(Father_Title,''),nvl(Mother_Title,''),nvl(ep.PastActionStatus,''),nvl(ep.PastActionDesc,''),nvl(ep.Subroker_Status,''),nvl(ep.Subroker_Desc,''),nvl(ep.FatcaDeclaration,'')
				from ekyc_personal ep 
				where ep.Request_Uid =? 
				and ( ? or ep.Updated_Session_Id  = ?)
				`
			// coreString := ` select nvl(ep.Father_SpouceName,'') ,nvl(ep.Mother_Name,'') ,nvl(ep.Gender,'') ,nvl(ep.Occupation,'') ,nvl(ep.Occupation_Others,'') ,nvl(ep.Annual_Income,'') ,nvl(ep.Politically_Exposed,'') ,nvl(ep.Trading_Experience,'') ,nvl(ep.Edu_Qualification,'') ,nvl(ep.Phone_Owner,'') ,nvl(ep.Phone_Owner_Name,''),nvl(ep.Email_Owner,''),nvl(ep.Email_Owner_Name,'') ,nvl(ep.Marital_Status,''),nvl(ep.Nominee,''),nvl(ep.Education_Others,''),nvl(Father_Title,''),nvl(Mother_Title,''),nvl(er.Email,''),nvl(er.Phone,''), nvl(ep.PastActionStatus,''),nvl(ep.PastActionDesc,''),nvl(ep.Subroker_Status,''),nvl(ep.Subroker_Desc,''),nvl(ep.FatcaDeclaration,'')
			// 				from ekyc_personal ep ,ekyc_request er
			// 				where ep.Request_Uid=er.Uid and ep.Request_Uid =?
			// 				and ( ? or ep.Updated_Session_Id  = ?)
			// 				`
			rows, lerr = ftdb.NewEkyc_GDB.Query(coreString, Uid, lTestUserFlag, lSessionId)
			if lerr != nil {
				response.Status = common.ErrorCode
				response.ErrMsg = "pGPU003 " + lerr.Error()
			} else {
				defer rows.Close()
				response.Status = common.SuccessCode
				for rows.Next() {
					lerr := rows.Scan(&response.PersonalStruct.FatherName, &response.PersonalStruct.MotherName, &response.PersonalStruct.Gender, &response.PersonalStruct.Occupation, &response.PersonalStruct.OccupationOthers, &response.PersonalStruct.AnnualIncome, &response.PersonalStruct.PoliticalExpo, &response.PersonalStruct.TradingExperience, &response.PersonalStruct.Education, &response.PersonalStruct.PhoneOwner, &response.PersonalStruct.PhoneOwnername, &response.PersonalStruct.EmailOwner, &response.PersonalStruct.EmailOwnerName, &response.PersonalStruct.MaritalStatus, &response.PersonalStruct.NomineeOpted, &response.PersonalStruct.EducationOthers, &response.PersonalStruct.FatherTitle, &response.PersonalStruct.MotherTitle, &response.PersonalStruct.PastActions, &response.PersonalStruct.PastActionsDesc, &response.PersonalStruct.DealSubBroker, &response.PersonalStruct.DealSubBrokerDesc, &response.PersonalStruct.FatcaDeclaration)
					if lerr != nil {
						response.Status = common.ErrorCode
						response.ErrMsg = "pGPU004 " + lerr.Error()
					} else {
						response.Status = common.SuccessCode
					}
				}
				if response.PersonalStruct.FatherName != "" && response.PersonalStruct.TradingExperience == "" {
					response.PersonalStruct.FatherTitle = "Mr"
				}
				if response.PersonalStruct.NomineeOpted == "" {

					response.PersonalStruct.NomineeOpted = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "NomineeOpted")
				}
				response, lerr = FetchFatcaDetails(Uid, response, debug)

				if lerr != nil {
					response.Status = common.ErrorCode
					response.ErrMsg = "pGPU005 " + lerr.Error()
				}
				lCoreString := `select nvl(er.Phone,''),nvl(er.Email,'') from ekyc_request er where er.Uid =  ?`
				rows, lerr := ftdb.NewEkyc_GDB.Query(lCoreString, Uid)
				if lerr != nil {

					response.Status = common.ErrorCode
					response.ErrMsg = "pGPU006 " + lerr.Error()
				} else {
					defer rows.Close()
					response.Status = common.SuccessCode
					for rows.Next() {
						lErr := rows.Scan(&response.PersonalStruct.PhoneNumber, &response.PersonalStruct.EmailId)
						if lErr != nil {

							response.Status = common.ErrorCode
							response.ErrMsg = "pGPU006 " + lErr.Error()
						}
					}
				}
			}
		}

		if lTestUserFlag == "0" {
			response.Status = common.SuccessCode
		}
		data, lerr := json.Marshal(response)
		debug.Log(helpers.Details, "data--", string(data))
		if lerr != nil {
			debug.Log(helpers.Elog, lerr.Error())
			fmt.Fprint(w, "pGPU005 "+lerr.Error())
		} else {
			fmt.Fprint(w, string(data))
		}
		debug.Log(helpers.Statement, "GetPersonalUpdate (-)")
	}
}

//192.168.2.5:9999/#/profile
