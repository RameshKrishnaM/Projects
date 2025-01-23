package docpreview

import (
	"encoding/json"
	"fcs23pkg/apps/v1/commonpackage"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
	"strings"
)

type BasicInfoStruct struct {
	GiveName     string `json:"givenname"`
	NameAsPerPan string `json:"nameasperpan"`
	PanNo        string `json:"panno"`
	DOB          string `json:"dob"`
	MobileNo     string `json:"mobileno"`
	EmailId      string `json:"emailid"`
	LinkedAadhar string `json:"linkedaadhar"`
	DateOfSubmit string `json:"dateofsubmit"`
	Bo_title     string `json:"botitle"`
	AadhaarNo    string `json:"aadhaarno"`
}

type AddressStruct struct {
	Source_Of_Address    string `json:"sourceofaddress"`
	AddressType1         string `json:"addresstype1"`
	PERAddress1          string `json:"peraddress1"`
	PERAddress2          string `json:"peraddress2"`
	PERAddress3          string `json:"peraddress3"`
	PERCity              string `json:"percity"`
	PERPincode           string `json:"perpincode"`
	PERState             string `json:"perstate"`
	PERCountry           string `json:"percountry"`
	ProofofAddress       string `json:"proofofaddresstype"`
	PERDateofissue       string `json:"perdate"`
	PERProofExpriyDate   string `json:"perproofexpirydate"`
	PERProofNo           string `json:"perproofno"`
	PERProofPlaceofissue string `json:"perpalceofissue"`
	PERDoc1Name          string `json:"perdocname1"`
	PERDocID1            string `json:"docid1"`
	PERDoc2Name          string `json:"perdocname2"`
	PERDocID2            string `json:"docid2"`
	AddressType2         string `json:"addresstype2"`
	CORAddress1          string `json:"coraddress1"`
	CORAddress2          string `json:"coraddress2"`
	CORAddress3          string `json:"coraddress3"`
	CORCity              string `json:"corcity"`
	CORPincode           string `json:"corpincode"`
	CORState             string `json:"corstate"`
	CORCountry           string `json:"corcountry"`
}

type BankDetailsStruct struct {
	AccountNo          string `json:"accountno"`
	IFSC               string `json:"ifsc"`
	MICR               string `json:"micr"`
	BankName           string `json:"bankname"`
	Bankbranch         string `json:"bankbranch"`
	BankAddress        string `json:"bankaddress"`
	BankProofType      string `json:"bankprooftype"`
	Acctype            string `json:"acctype"`
	PennyDropStatus    string `json:"pennydrop"`
	PennyDropAccStatus string `json:"pennydropstatus"`
	NameAsPennyDrop    string `json:"nameaspennydrop"`
}

type PersonalStruct struct {
	FatherName              string `json:"fathername"`
	MotherName              string `json:"mothername"`
	Gender                  string `json:"gender"`
	MobileNo                string `json:"mobileno"`
	MobileNoBelongsTo       string `json:"mobilenobelongsto"`
	EmailId                 string `json:"emailid"`
	EmailIdBelongsTo        string `json:"emailidbelongsto"`
	Occupation              string `json:"occupation"`
	MaritalStatus           string `json:"maritalstatus"`
	AnnualIncome            string `json:"annualincome"`
	TradingExposed          string `json:"tradingexposed"`
	EducationQualification  string `json:"educationqualification"`
	PoliticallyExposed      string `json:"politicallyexposed"`
	EducationOthers         string `json:"educationothers"`
	OccupationOthers        string `json:"otheroccupation"`
	EmailOwnerName          string `json:"emailownername"`
	PhoneOwnerName          string `json:"phoneownername"`
	FatherTitle             string `json:"fathertitle"`
	MotherTitle             string `json:"mothertitle"`
	Nominee                 string `json:"nominee"`
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
}

type NomineeStruct struct {
	NomineeName              string `json:"nomineename"`
	NomineeTitle             string `json:"nomineetitle"`
	NomineeRelationship      string `json:"nomineerelationship"`
	NomineeShare             string `json:"nomineeshare"`
	NomineeDOB               string `json:"nomineedob"`
	NomineeAddress1          string `json:"nomineeaddress1"`
	NomineeAddress2          string `json:"nomineeaddress2"`
	NomineeAddress3          string `json:"nomineeaddress3"`
	NomineeCity              string `json:"nomineecity"`
	NomineeState             string `json:"nomineestate"`
	NomineeCountry           string `json:"nomineecountry"`
	NomineePincode           string `json:"nomineepincode"`
	NomineeMobileNo          string `json:"nomineemobileno"`
	NomineeEmailId           string `json:"nomineeemailid"`
	NomineeProofOfIdentity   string `json:"nomineeproofofidentity"`
	NomineeProofNumber       string `json:"nomineeproofnumber"`
	NomineePlaceofIssue      string `json:"nomineeplaceofissue"`
	NomineeProofDateofIssue  string `json:"nomineeproofdateofissue"`
	NomineeProofExpriyDate   string `json:"nomineeproofexpriydate"`
	NomineeFileUploadDocId   string `json:"nomineefileuploaddocids"`
	NomineeFileName          string `json:"nomineefilename"`
	GuardianTitle            string `json:"guardiantitle"`
	GuardianName             string `json:"guardianname"`
	GuardianRelationship     string `json:"guardianrelationship"`
	GuardianAddress1         string `json:"guardianaddress1"`
	GuardianAddress2         string `json:"guardianaddress2"`
	GuardianAddress3         string `json:"guardianaddress3"`
	GuardianCity             string `json:"guardiancity"`
	GuardianState            string `json:"guardianstate"`
	GuardianCountry          string `json:"guardiancountry"`
	GuardianPincode          string `json:"guardianpincode"`
	GuardianMobileNo         string `json:"guardianmobileno"`
	GuardianEmailId          string `json:"guardianemailid"`
	GuardianProofOfIdentity  string `json:"guardianproofofidentity"`
	GuardianProofNumber      string `json:"guardianproofnumber"`
	GuardianPlaceofIssue     string `json:"guardianplaceofissue"`
	GuardianProofDateofIssue string `json:"guardianproofdateofissue"`
	GuardianProofExpriyDate  string `json:"guardianproofexpriydate"`
	GuardianFileUploadDocId  string `json:"guardianfileuploaddocids"`
	GuardianFileName         string `json:"guardianfilename"`
}

type IpvStruct struct {
	IpvOtp     string `json:"ipvotp"`
	ImageDocId string `json:"imagedocid"`
	VideoDocId string `json:"videodocid"`
	Latitude   string `json:"latitude"`
	Longitude  string `json:"longitude"`
	TimeStamp  string `json:"timestamp"`
	Place      string `json:"place"`
	Date       string `json:"ipvdate"`
}

// type ServicesStruct struct {
// 	ExcSegment string `json:"excsegment"`
// 	Status     string `json:"status"`
// }

// type DematAndServicesStruct struct {
// 	Services []ServicesStruct `json:"services"`
// 	DpScheme string           `json:"dpscheme"`
// 	DIS      string           `json:"dis"`
// 	EDIS     string           `json:"edis"`
// }

type SignedDocStruct struct {
	SignImage               string `json:"signiid"`
	IncomeImage             string `json:"incomeid"`
	PanImage                string `json:"panid"`
	IncomeType              string `json:"incometype"`
	CheqLeafOrStatement     string `json:"checkleafid"`
	SigenImageName          string `json:"signimagename"`
	IncomeImageName         string `json:"incomeimagename"`
	PanImageName            string `json:"panimagename"`
	CheqLeafOrStatementName string `json:"checkleafname"`
}
type stage struct {
	BasicInfoRec        BasicInfoStruct        `json:"basicinfo"`
	AdrsRec             AddressStruct          `json:"address"`
	BankRec             BankDetailsStruct      `json:"bank"`
	PersonalRec         PersonalStruct         `json:"personal"`
	NomineeArr          []NomineeStruct        `json:"nominearr"`
	IpvRec              IpvStruct              `json:"ipv"`
	DematAndServicesRec DematAndServicesStruct `json:"dematandservices"`
	SignedDocRec        SignedDocStruct        `json:"signeddoc"`
	Status              string                 `json:"status"`
	ServicesFlag        []string               `json:"servicesflag"`
}
type ServicesStruct struct {
	Status      string       `json:"status"`
	ServeHead   []string     `json:"serveHead"`
	ServeData   [][]string   `json:"serveData"`
	ServeDbData []DataStruct `json:"serveDbData"`
	BrokHead    []string     `json:"brokhead"`
	BrokData    [][]string   `json:"brokdata"`
	BrokDbData  []DataStruct `json:"brokdbdata"`
}
type DataStruct struct {
	ID         string `json:"id"`
	Rowhead    string `json:"rowhead"`
	Colhead    string `json:"colhead"`
	Values     string `json:"values"`
	UserSelect string `json:"userselect"`
}
type DematAndServicesStruct struct {
	Services             ServicesStruct `json:"services"`
	DpScheme             string         `json:"dpscheme"`
	DIS                  string         `json:"dis"`
	EDIS                 string         `json:"edis"`
	RunningAccSettlement string         `json:"runningaccsettlement"`
}

func GetUserDetails(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	// (w).Header().Set("Access-Control-Allow-Origin", common.FlowPostman)
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	if strings.EqualFold(r.Method, "GET") {
		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GUD01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GUD01", "Something went wrong.Please try again later."))
			return
		}
		lDebug.SetReference(lUid)
		dbStruct, lErr := GetUserInfo(lUid, lDebug)
		lDebug.Log(helpers.Details, "dbStruct", dbStruct)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GUD02"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GUD02", "Error retrieving user information."))
			return
		}
		dbStruct.Status = common.SuccessCode
		lDatas, lErr := json.Marshal(dbStruct)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GUD03"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("GUD03", "Something went wrong.Please try again later."))
			return
		}
		lDebug.Log(helpers.Details, string(lDatas))
		fmt.Fprint(w, string(lDatas))

	}
}

func GetUserInfo(pRequestId string, pDebug *helpers.HelperStruct) (stage, error) {
	pDebug.Log(helpers.Statement, "getUserInfo (+)")
	var ReturnStruct stage
	var lLookUpRec commonpackage.DescriptionResp

	ReturnStruct, lErr := BasicInfo(pRequestId, ReturnStruct, pDebug, lLookUpRec)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	}
	ReturnStruct, lErr = AddressInfo(pRequestId, ReturnStruct, pDebug, lLookUpRec)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	}
	ReturnStruct, lErr = BankInfo(pRequestId, ReturnStruct, pDebug, lLookUpRec)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	}
	ReturnStruct, lErr = PersonalInfo(pRequestId, ReturnStruct, pDebug, lLookUpRec)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	}
	ReturnStruct, lErr = NomineeInfo(pRequestId, ReturnStruct, pDebug, lLookUpRec)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	}
	ReturnStruct, lErr = IPVInfo(pRequestId, ReturnStruct, pDebug, lLookUpRec)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	}
	ReturnStruct, lErr = DematAndServicesInfo(pRequestId, ReturnStruct, pDebug, lLookUpRec)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	}
	ReturnStruct, lErr = FileUpload(pRequestId, ReturnStruct, pDebug, lLookUpRec)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	}
	ReturnStruct, lErr = GetServicesFlag(pRequestId, ReturnStruct, pDebug)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "getUserInfo (-)")
	return ReturnStruct, nil

}
func BasicInfo(pRequestId string, ReturnStruct stage, pDebug *helpers.HelperStruct, pLookUpRec commonpackage.DescriptionResp) (stage, error) {
	pDebug.Log(helpers.Statement, "BasicInfo (+)")
	lCorestring := `select nvl(Given_Name,""),nvl(Name_As_Per_Pan,""),nvl(Pan,""),nvl(DOB,""),nvl(Phone,""),nvl(Email,""),nvl(Aadhar_Linked,'N'),nvl(from_unixtime(submitted_date),""),nvl(AadhraNo,""),nvl(bo_title,"") from ekyc_request where Uid = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&ReturnStruct.BasicInfoRec.GiveName,
			&ReturnStruct.BasicInfoRec.NameAsPerPan,
			&ReturnStruct.BasicInfoRec.PanNo,
			&ReturnStruct.BasicInfoRec.DOB,
			&ReturnStruct.BasicInfoRec.MobileNo,
			&ReturnStruct.BasicInfoRec.EmailId,
			&ReturnStruct.BasicInfoRec.LinkedAadhar,
			&ReturnStruct.BasicInfoRec.DateOfSubmit,
			&ReturnStruct.BasicInfoRec.AadhaarNo,
			&ReturnStruct.BasicInfoRec.Bo_title)
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)

		}
	}

	pDebug.Log(helpers.Statement, "BasicInfo (-)")
	return ReturnStruct, nil
}
func AddressInfo(pRequestId string, ReturnStruct stage, pDebug *helpers.HelperStruct, pLookUpRec commonpackage.DescriptionResp) (stage, error) {
	pDebug.Log(helpers.Statement, "AddressInfo (+)")
	var lKraId, lDigilockerId string
	lCorestring := `select nvl(Source_Of_Address,""),nvl(CorAddress1,""),nvl(CorAddress2,""),nvl(CorAddress3,""),nvl(CorCity,""),nvl(CorState,""),nvl(CorPincode,""),nvl(CorCountry,""),nvl(PerAddress1,""),nvl(PerAddress2,""),nvl(PerAddress3,""),nvl(PerCity,""),nvl(PerState,""),nvl(PerPincode,""),nvl(PerCountry,""),nvl(proofType,""),nvl(dateofProofIssue,""),nvl(Proof_No,""),nvl(ProofOfIssue,""),nvl(ProofExpriyDate,""),nvl(Proof_Doc_Id1,""),nvl(Proof_Doc_Id2,""),nvl(Kra_docid,""),nvl(Digilocker_docid,"") from ekyc_address where Request_Uid = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&ReturnStruct.AdrsRec.Source_Of_Address,
			&ReturnStruct.AdrsRec.CORAddress1,
			&ReturnStruct.AdrsRec.CORAddress2,
			&ReturnStruct.AdrsRec.CORAddress3,
			&ReturnStruct.AdrsRec.CORCity,
			&ReturnStruct.AdrsRec.CORState,
			&ReturnStruct.AdrsRec.CORPincode,
			&ReturnStruct.AdrsRec.CORCountry,
			&ReturnStruct.AdrsRec.PERAddress1,
			&ReturnStruct.AdrsRec.PERAddress2,
			&ReturnStruct.AdrsRec.PERAddress3,
			&ReturnStruct.AdrsRec.PERCity,
			&ReturnStruct.AdrsRec.PERState,
			&ReturnStruct.AdrsRec.PERPincode,
			&ReturnStruct.AdrsRec.PERCountry,
			&ReturnStruct.AdrsRec.ProofofAddress,
			&ReturnStruct.AdrsRec.PERDateofissue,
			&ReturnStruct.AdrsRec.PERProofNo,
			&ReturnStruct.AdrsRec.PERProofPlaceofissue,
			&ReturnStruct.AdrsRec.PERProofExpriyDate,
			&ReturnStruct.AdrsRec.PERDocID1,
			&ReturnStruct.AdrsRec.PERDocID2,
			&lKraId, &lDigilockerId)
		ReturnStruct.AdrsRec.AddressType1 = "Permanent Address"
		ReturnStruct.AdrsRec.AddressType2 = "Correspondence Address"
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)

		}
		if strings.EqualFold(ReturnStruct.AdrsRec.Source_Of_Address, "KRA") {
			ReturnStruct.AdrsRec.PERDocID1 = lKraId
		} else if strings.EqualFold(ReturnStruct.AdrsRec.Source_Of_Address, "Digilocker") {
			ReturnStruct.AdrsRec.PERDocID1 = lDigilockerId
		}
		if ReturnStruct.AdrsRec.CORState != "" {
			pLookUpRec, lErr := commonpackage.GetLookUpDescription(pDebug, "state", ReturnStruct.AdrsRec.CORState, "code")
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			ReturnStruct.AdrsRec.CORState = pLookUpRec.Descirption
		}
		if ReturnStruct.AdrsRec.CORCountry != "" {
			pLookUpRec, lErr := commonpackage.GetLookUpDescription(pDebug, "country", ReturnStruct.AdrsRec.CORCountry, "code")
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			ReturnStruct.AdrsRec.CORCountry = pLookUpRec.Descirption
		}
		if ReturnStruct.AdrsRec.PERState != "" {
			pLookUpRec, lErr := commonpackage.GetLookUpDescription(pDebug, "state", ReturnStruct.AdrsRec.PERState, "code")
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			ReturnStruct.AdrsRec.PERState = pLookUpRec.Descirption
		}
		if ReturnStruct.AdrsRec.PERCountry != "" {
			pLookUpRec, lErr := commonpackage.GetLookUpDescription(pDebug, "country", ReturnStruct.AdrsRec.PERCountry, "code")
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			ReturnStruct.AdrsRec.PERCountry = pLookUpRec.Descirption
		}

		if ReturnStruct.AdrsRec.ProofofAddress != "" {
			pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "AddressProof", ReturnStruct.AdrsRec.ProofofAddress, "code")
			if lErr != nil {
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			ReturnStruct.AdrsRec.ProofofAddress = pLookUpRec.Descirption
		}

	}

	pDebug.Log(helpers.Statement, "AddressInfo (-)")
	return ReturnStruct, nil
}
func BankInfo(pRequestId string, ReturnStruct stage, pDebug *helpers.HelperStruct, pLookUpRec commonpackage.DescriptionResp) (stage, error) {
	pDebug.Log(helpers.Statement, "BankInfo (+)")
	lCorestring := `select nvl(Acc_Number,""),nvl(IFSC,""),nvl(MICR,""),nvl(Bank_Name,""),nvl(Bank_Branch,""),nvl(Bank_Address,""),nvl(Bank_Proof_Type,""),nvl(Penny_Drop_Status,""),nvl(Penny_Drop_Acc_Status,""),nvl(Name_As_Per_PennyDrop,""),nvl(Acctype,"") from ekyc_bank where Request_Uid = ? and isPrimaryAcc='Y'`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&ReturnStruct.BankRec.AccountNo,
			&ReturnStruct.BankRec.IFSC,
			&ReturnStruct.BankRec.MICR,
			&ReturnStruct.BankRec.BankName,
			&ReturnStruct.BankRec.Bankbranch,
			&ReturnStruct.BankRec.BankAddress,
			&ReturnStruct.BankRec.BankProofType,
			&ReturnStruct.BankRec.PennyDropStatus,
			&ReturnStruct.BankRec.PennyDropAccStatus,
			&ReturnStruct.BankRec.NameAsPennyDrop,
			&ReturnStruct.BankRec.Acctype)
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)
		} else {

			if ReturnStruct.BankRec.Acctype != "" {
				pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "Bank Account Type", ReturnStruct.BankRec.Acctype, "code")
				if lErr != nil {
					return ReturnStruct, helpers.ErrReturn(lErr)
				}
				ReturnStruct.BankRec.Acctype = pLookUpRec.Descirption
			}
		}
	}

	pDebug.Log(helpers.Statement, "BankInfo (-)")
	return ReturnStruct, nil
}
func PersonalInfo(pRequestId string, ReturnStruct stage, pDebug *helpers.HelperStruct, pLookUpRec commonpackage.DescriptionResp) (stage, error) {
	pDebug.Log(helpers.Statement, "PersonalInfo (+)")
	lCorestring := `select nvl(Father_SpouceName,""),nvl(Mother_Name,""),nvl(Gender,""),nvl(Occupation,""),nvl(Annual_Income,""),
	nvl(Politically_Exposed,""),nvl(Trading_Experience,""),nvl(Edu_Qualification,""),nvl(Phone_Owner,"")
	,nvl(Email_Owner,""),nvl(Marital_Status,""),nvl(Nominee,""),nvl(Education_Others,""),nvl(Occupation_Others,""),nvl(Phone_Owner_Name,"")
	,nvl(Email_Owner_Name,""),nvl(Father_Title,''),nvl(Mother_Title,''),nvl(PastActionStatus,''),nvl(PastActionDesc,'')
	,nvl(Subroker_Status,''),nvl(Subroker_Desc,''),nvl(FatcaDeclaration,'') from ekyc_personal where Request_Uid = ?`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&ReturnStruct.PersonalRec.FatherName,
			&ReturnStruct.PersonalRec.MotherName,
			&ReturnStruct.PersonalRec.Gender,
			&ReturnStruct.PersonalRec.Occupation,
			&ReturnStruct.PersonalRec.AnnualIncome,
			&ReturnStruct.PersonalRec.PoliticallyExposed,
			&ReturnStruct.PersonalRec.TradingExposed,
			&ReturnStruct.PersonalRec.EducationQualification,
			&ReturnStruct.PersonalRec.MobileNoBelongsTo,
			&ReturnStruct.PersonalRec.EmailIdBelongsTo,
			&ReturnStruct.PersonalRec.MaritalStatus,
			&ReturnStruct.PersonalRec.Nominee,
			&ReturnStruct.PersonalRec.EducationOthers,
			&ReturnStruct.PersonalRec.OccupationOthers,
			&ReturnStruct.PersonalRec.PhoneOwnerName,
			&ReturnStruct.PersonalRec.EmailOwnerName,
			&ReturnStruct.PersonalRec.FatherTitle,
			&ReturnStruct.PersonalRec.MotherTitle,
			&ReturnStruct.PersonalRec.PastActions,
			&ReturnStruct.PersonalRec.PastActionsDesc,
			&ReturnStruct.PersonalRec.DealSubBroker,
			&ReturnStruct.PersonalRec.DealSubBrokerDesc,
			&ReturnStruct.PersonalRec.FatcaDeclaration)
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)

		}
	}
	lCorestring = `select nvl(Email,""),nvl(Phone,"") from ekyc_request where Uid = ?`
	lRows, lErr = ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&ReturnStruct.PersonalRec.EmailId, &ReturnStruct.PersonalRec.MobileNo)
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)
		}
	}

	if ReturnStruct.PersonalRec.FatcaDeclaration == "Y" {
		ReturnStruct, lErr = FetchFatcaDetails(pRequestId, ReturnStruct, pDebug)
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)
		}
	}

	if ReturnStruct.PersonalRec.Gender != "" {
		pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "Gender", ReturnStruct.PersonalRec.Gender, "code")
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)
		}
		ReturnStruct.PersonalRec.Gender = pLookUpRec.Descirption
	}

	if ReturnStruct.PersonalRec.Occupation != "" {
		pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "Occupation", ReturnStruct.PersonalRec.Occupation, "code")
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)
		}
		ReturnStruct.PersonalRec.Occupation = pLookUpRec.Descirption
	}

	if ReturnStruct.PersonalRec.AnnualIncome != "" {
		pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "AnnualIncome", ReturnStruct.PersonalRec.AnnualIncome, "code")
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)
		}
		ReturnStruct.PersonalRec.AnnualIncome = pLookUpRec.Descirption
	}

	if ReturnStruct.PersonalRec.EducationQualification != "" {
		pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "Eduaction", ReturnStruct.PersonalRec.EducationQualification, "code")
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)
		}
		ReturnStruct.PersonalRec.EducationQualification = pLookUpRec.Descirption
	}

	if ReturnStruct.PersonalRec.MaritalStatus != "" {
		pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "MarritalStatus", ReturnStruct.PersonalRec.MaritalStatus, "code")
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)
		}
		ReturnStruct.PersonalRec.MaritalStatus = pLookUpRec.Descirption
	}

	if ReturnStruct.PersonalRec.MobileNoBelongsTo != "" {
		pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "MobileEmailOwner", ReturnStruct.PersonalRec.MobileNoBelongsTo, "code")
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)
		}
		ReturnStruct.PersonalRec.MobileNoBelongsTo = pLookUpRec.Descirption
	}

	if ReturnStruct.PersonalRec.EmailIdBelongsTo != "" {
		pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "MobileEmailOwner", ReturnStruct.PersonalRec.EmailIdBelongsTo, "code")
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)
		}
		ReturnStruct.PersonalRec.EmailIdBelongsTo = pLookUpRec.Descirption
	}

	if ReturnStruct.PersonalRec.TradingExposed != "" {
		pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "TradingExp", ReturnStruct.PersonalRec.TradingExposed, "code")
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)
		}
		ReturnStruct.PersonalRec.TradingExposed = pLookUpRec.Descirption
	}

	if !strings.EqualFold(ReturnStruct.PersonalRec.PastActions, "Y") {
		ReturnStruct.PersonalRec.PastActionsDesc = ""
	}
	if !strings.EqualFold(ReturnStruct.PersonalRec.DealSubBroker, "Y") {
		ReturnStruct.PersonalRec.DealSubBrokerDesc = ""
	}

	pDebug.Log(helpers.Statement, "PersonalInfo (-)")
	return ReturnStruct, nil
}
func NomineeInfo(pRequestId string, ReturnStruct stage, pDebug *helpers.HelperStruct, pLookUpRec commonpackage.DescriptionResp) (stage, error) {
	pDebug.Log(helpers.Statement, "NomineeInfo (+)")
	var NomineeRec NomineeStruct
	lCorestring := `SELECT
    NVL(NomineeName, ""),    NVL(NomineeRelationship, ""),    NVL(NomineeShare, ""),    NVL(NomineeDOB, ""),    NVL(NomineeAddress1, ""),    NVL(NomineeAddress2, ""),    NVL(NomineeAddress3, ""),    NVL(NomineeCity, ""),    NVL(NomineeState, ""),    NVL(NomineeCountry, ""),    NVL(NomineePincode, ""),    NVL(NomineeMobileNo, ""),    NVL(NomineeEmailId, ""),    NVL(NomineeProofOfIdentity, ""),    NVL(NomineeProofNumber, ""), nvl(NomineeProofPlaceOfIssue,""),nvl(NomineeProofDateOfIssue,""),nvl(NomineeProofExpriyDate,""),   NVL(NomineeFileUploadDocIds, ""),  NVL(GuardianName, ""),
    NVL(GuardianRelationship, ""),    NVL(GuardianAddress1, ""),    NVL(GuardianAddress2, ""),    NVL(GuardianAddress3, ""),    NVL(GuardianCity, ""),    NVL(GuardianState, ""),    NVL(GuardianCountry, ""),    NVL(GuardianPincode, ""),    NVL(GuardianMobileNo, ""),    NVL(GuardianEmailId, ""),    NVL(GuardianProofOfIdentity, ""),    NVL(GuardianProofNumber, ""),nvl(GuardianProofPlaceOfIssue,""),nvl(GuardianProofDateOfIssue,""),nvl(GuardianProofExpriyDate,""),  NVL(GuardianFileUploadDocIds, ""),nvl(Nominee_Title,''),nvl(Guardian_Title,'') FROM ekyc_nominee_details WHERE RequestId = ?
	and Active = 1 order by CreatedDate asc;`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&NomineeRec.NomineeName,
			&NomineeRec.NomineeRelationship,
			&NomineeRec.NomineeShare,
			&NomineeRec.NomineeDOB,
			&NomineeRec.NomineeAddress1,
			&NomineeRec.NomineeAddress2,
			&NomineeRec.NomineeAddress3,
			&NomineeRec.NomineeCity,
			&NomineeRec.NomineeState,
			&NomineeRec.NomineeCountry,
			&NomineeRec.NomineePincode,
			&NomineeRec.NomineeMobileNo,
			&NomineeRec.NomineeEmailId,
			&NomineeRec.NomineeProofOfIdentity,
			&NomineeRec.NomineeProofNumber,
			&NomineeRec.NomineePlaceofIssue,
			&NomineeRec.NomineeProofDateofIssue,
			&NomineeRec.NomineeProofExpriyDate,
			&NomineeRec.NomineeFileUploadDocId,
			&NomineeRec.GuardianName,
			&NomineeRec.GuardianRelationship,
			&NomineeRec.GuardianAddress1,
			&NomineeRec.GuardianAddress2,
			&NomineeRec.GuardianAddress3,
			&NomineeRec.GuardianCity,
			&NomineeRec.GuardianState,
			&NomineeRec.GuardianCountry,
			&NomineeRec.GuardianPincode,
			&NomineeRec.GuardianMobileNo,
			&NomineeRec.GuardianEmailId,
			&NomineeRec.GuardianProofOfIdentity,
			&NomineeRec.GuardianProofNumber,
			&NomineeRec.GuardianPlaceofIssue,
			&NomineeRec.GuardianProofDateofIssue,
			&NomineeRec.GuardianProofExpriyDate,
			&NomineeRec.GuardianFileUploadDocId,
			&NomineeRec.NomineeTitle,
			&NomineeRec.GuardianTitle)
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)

		}

		if NomineeRec.NomineeProofOfIdentity != "" {
			pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "Proof of Identity", NomineeRec.NomineeProofOfIdentity, "code")
			if lErr != nil {
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			NomineeRec.NomineeProofOfIdentity = pLookUpRec.Descirption
		}
		if NomineeRec.NomineeRelationship != "" {
			pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "Nominee Relationship", NomineeRec.NomineeRelationship, "code")
			if lErr != nil {
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			NomineeRec.NomineeRelationship = pLookUpRec.Descirption
		}

		if NomineeRec.NomineeCountry != "" {
			pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "country", NomineeRec.NomineeCountry, "code")
			if lErr != nil {
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			NomineeRec.NomineeCountry = pLookUpRec.Descirption
		}
		if NomineeRec.NomineeState != "" {
			pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "state", NomineeRec.NomineeState, "code")
			if lErr != nil {
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			NomineeRec.NomineeState = pLookUpRec.Descirption
		}

		if NomineeRec.GuardianName != "" {
			pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "nomineeGuardianRelationship", NomineeRec.GuardianRelationship, "code")
			if lErr != nil {
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			NomineeRec.GuardianRelationship = pLookUpRec.Descirption
			pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "Proof of Identity", NomineeRec.GuardianProofOfIdentity, "code")
			if lErr != nil {
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			NomineeRec.GuardianProofOfIdentity = pLookUpRec.Descirption
			pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "country", NomineeRec.GuardianCountry, "code")
			NomineeRec.GuardianCountry = pLookUpRec.Descirption
			if lErr != nil {
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "state", NomineeRec.GuardianState, "code")
			NomineeRec.GuardianState = pLookUpRec.Descirption
			if lErr != nil {
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
		}

		ReturnStruct.NomineeArr = append(ReturnStruct.NomineeArr, NomineeRec)

	}

	pDebug.Log(helpers.Statement, "NomineeInfo (-)")
	return ReturnStruct, nil
}

// Fetch the Facta declaration information in the ekyc_fatcadeclaration_details table from db
func FetchFatcaDetails(Uid string, ReturnStruct stage, pDebug *helpers.HelperStruct) (stage, error) {
	pDebug.Log(helpers.Statement, "FetchFatcaDetails (+)")

	lCoreString := `SELECT nvl(Residence_Country,''), nvl(Tax_Idendification_Number,''), nvl(Place_of_Birth,''), nvl(Country_of_Birth,''), nvl(Foreign_Address1,''), nvl(Foreign_Address2,''), nvl(Foreign_Address3,''), nvl(Foreign_City,''), nvl(Foreign_Country,''), nvl(Foreign_State,''),
	nvl(Foreign_Pincode,'')
	FROM ekyc_fatcadeclaration_details where Request_Uid = ?`
	rows, lerr := ftdb.NewEkyc_GDB.Query(lCoreString, Uid)
	if lerr != nil {
		return ReturnStruct, helpers.ErrReturn(lerr)
	} else {
		defer rows.Close()
		for rows.Next() {
			lErr := rows.Scan(&ReturnStruct.PersonalRec.ResidenceCountry, &ReturnStruct.PersonalRec.TaxIdendificationNumber, &ReturnStruct.PersonalRec.PlaceofBirth, &ReturnStruct.PersonalRec.CountryofBirth, &ReturnStruct.PersonalRec.ForeignAddress1, &ReturnStruct.PersonalRec.ForeignAddress2, &ReturnStruct.PersonalRec.ForeignAddress3, &ReturnStruct.PersonalRec.ForeignCity, &ReturnStruct.PersonalRec.ForeignCountry, &ReturnStruct.PersonalRec.ForeignState, &ReturnStruct.PersonalRec.ForeignPincode)
			if lErr != nil {
				return ReturnStruct, helpers.ErrReturn(lerr)
			}
		}
	}
	pDebug.Log(helpers.Statement, "FetchFatcaDetails (-)")
	return ReturnStruct, nil
}

func IPVInfo(pRequestId string, ReturnStruct stage, pDebug *helpers.HelperStruct, pLookUpRec commonpackage.DescriptionResp) (stage, error) {
	pDebug.Log(helpers.Statement, "IPVInfo (+)")
	lCorestring := `SELECT
    NVL(ipv_otp, ''),    NVL(video_Doc_Id, ''),    NVL(image_Doc_Id, ''),    NVL(latitude, ''),    NVL(longitude, ''),    NVL(time_stamp, ''),    NVL(Current_Address, ''),nvl(from_unixtime(UpdatedDate),"")  FROM    ekyc_ipv WHERE    Request_Uid = ? and isActive = 1;`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&ReturnStruct.IpvRec.IpvOtp,
			&ReturnStruct.IpvRec.VideoDocId,
			&ReturnStruct.IpvRec.ImageDocId,
			&ReturnStruct.IpvRec.Latitude,
			&ReturnStruct.IpvRec.Longitude,
			&ReturnStruct.IpvRec.TimeStamp,
			&ReturnStruct.IpvRec.Place,
			&ReturnStruct.IpvRec.Date)
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)

		}
	}

	pDebug.Log(helpers.Statement, "IPVInfo (-)")
	return ReturnStruct, nil
}

func DematAndServicesInfo(pRequestId string, ReturnStruct stage, pDebug *helpers.HelperStruct, pLookUpRec commonpackage.DescriptionResp) (stage, error) {
	pDebug.Log(helpers.Statement, "DematAndServicesInfo (+)")

	lServicesQuery := `select nvl(eesm.id,"") ,nvl(eem.Exchange,"")  ,nvl(esm.Segment,"") ,nvl(eesm .User_status,"") ,nvl(es.Selected,"")  
		from ekyc_exchange_segment_mapping eesm ,ekyc_segment_master esm ,ekyc_exchange_master eem,ekyc_services es 
		where eesm .Enabled ='Y'
				and eesm.Segment_Id =esm.id 
				and esm.Enabled ='Y' 
				and eesm.Exchange_Id =eem.id 
				and eem.Enabled ='Y'
				and es.Mapping =eesm.id 
				and es.Request_Uid ='` + pRequestId + `'
				order by eesm.id;`

	lFirstCell := "Trading Segment"

	lServeHead, lServeData, lServeDbData, lErr := GetServices(lServicesQuery, lFirstCell, pDebug)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	}
	ReturnStruct.DematAndServicesRec.Services.ServeHead = lServeHead
	ReturnStruct.DematAndServicesRec.Services.ServeData = lServeData
	ReturnStruct.DematAndServicesRec.Services.ServeDbData = lServeDbData

	lBrokerageQuery := `
		select nvl(ebschm.id,""),nvl(ebsm.Segment_Name,"") , REPLACE(ebhm.Head_name, '%', '%%'), REPLACE(ebcm.Charge_value, '%', '%%'),nvl(eb.Enabled,"")
		from ekyc_brok_seg_charge_head_map ebschm ,ekyc_brok_charge_master ebcm, ekyc_brok_head_master ebhm,ekyc_brok_seg_master ebsm,ekyc_brokerage eb
		where ebschm.Enabled ='Y'
		and ebcm.Enabled ='Y'
		and ebschm.Charge_Id =ebcm.id 
		and ebhm.Enabled ='Y'
		and ebschm.Head_Id=ebhm.id 
		and ebsm.Enabled ='Y'
		and ebschm.Segment_Id=ebsm.id 
		and eb.Mapping =ebschm.id 
		and eb.Request_Uid ='` + pRequestId + `'
		order by ebschm.id;`

	lFirstCell = "Segement/Extchange"

	lBrokHead, lBrokerageData, lBrokDbdata, lErr := GetServices(lBrokerageQuery, lFirstCell, pDebug)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	}

	ReturnStruct.DematAndServicesRec.Services.BrokHead = lBrokHead
	ReturnStruct.DematAndServicesRec.Services.BrokData = lBrokerageData
	ReturnStruct.DematAndServicesRec.Services.BrokDbData = lBrokDbdata

	lCorestring := `select nvl(DP_scheme,""),nvl(DIS,""),nvl(EDIS,""), nvl(RunningAccSettlement,'') from ekyc_demat_details edd where edd.requestuid = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&ReturnStruct.DematAndServicesRec.DpScheme, &ReturnStruct.DematAndServicesRec.DIS, &ReturnStruct.DematAndServicesRec.EDIS, &ReturnStruct.DematAndServicesRec.RunningAccSettlement)
			if lErr != nil {
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
		}

		if ReturnStruct.DematAndServicesRec.DpScheme != "" {
			pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "DematData", ReturnStruct.DematAndServicesRec.DpScheme, "code")
			if lErr != nil {
				return ReturnStruct, helpers.ErrReturn(lErr)
			}
			ReturnStruct.DematAndServicesRec.DpScheme = pLookUpRec.Descirption
		}
	}
	pDebug.Log(helpers.Statement, "DematAndServicesInfo (-)")
	return ReturnStruct, nil
}

func GetServices(pQuery, pFirstcell string, pDebug *helpers.HelperStruct) ([]string, [][]string, []DataStruct, error) {
	pDebug.Log(helpers.Statement, "GetServices (+)")

	var lDataArr []DataStruct
	var lDataRec DataStruct

	lRowRec := []string{pFirstcell}
	var lColRec []string
	var lFinalArr [][]string
	lMapData := make(map[string][]string)

	lRows, lErr := ftdb.NewEkyc_GDB.Query(pQuery)
	if lErr != nil {
		return nil, nil, nil, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lDataRec.ID, &lDataRec.Colhead, &lDataRec.Rowhead, &lDataRec.Values, &lDataRec.UserSelect)
		pDebug.Log(helpers.Details, "lRows", lRows)
		if lErr != nil {
			return nil, nil, nil, helpers.ErrReturn(lErr)
		}

		if !Member(lDataRec.Rowhead, lRowRec) {
			lRowRec = append(lRowRec, lDataRec.Rowhead)
		}
		if !Member(lDataRec.Colhead, lColRec) {
			lColRec = append(lColRec, lDataRec.Colhead)
		}
		lMapData[lDataRec.Colhead] = []string{lDataRec.Colhead}
		lDataArr = append(lDataArr, lDataRec)
	}

	for _, lData := range lDataArr {
		for lHeadIdx := 1; lHeadIdx < len(lRowRec); lHeadIdx++ {
			if len(lMapData[lData.Colhead]) < len(lRowRec) {
				if lData.Rowhead == lRowRec[lHeadIdx] {
					lMapData[lData.Colhead] = append(lMapData[lData.Colhead], lData.Values+",ID:"+lData.ID)
				} else {
					lMapData[lData.Colhead] = append(lMapData[lData.Colhead], "N/A")
				}
			} else if lData.Rowhead == lRowRec[lHeadIdx] {
				lMapData[lData.Colhead][lHeadIdx] = lData.Values + ",ID:" + lData.ID
			}
		}
	}
	// for _, lMapData := range lMapData {
	// 	lFinalArr = append(lFinalArr, lMapData)
	// }
	for _, lRowVal := range lColRec {
		lFinalArr = append(lFinalArr, lMapData[lRowVal])
	}

	// pDebug.Log(helpers.Details, "\nlRowRec:", lRowRec, "\nlColRec:", lMapData, "\nlDataArr:", lDataArr)
	pDebug.Log(helpers.Statement, "GetServices (-)")
	return lRowRec, lFinalArr, lDataArr, nil
}
func Member(pValue string, pColectionArr []string) bool {
	for _, collection := range pColectionArr {
		if strings.EqualFold(pValue, collection) {
			return true
		}
	}
	return false
}

func FileUpload(pRequestId string, ReturnStruct stage, pDebug *helpers.HelperStruct, pLookUpRec commonpackage.DescriptionResp) (stage, error) {
	pDebug.Log(helpers.Statement, "GetSignImage (+)")
	lCorestring := `
	select nvl(Bank_proof,""),nvl(Income_proof,""),nvl(Signature,""),nvl(Pan_proof,""),nvl(Income_prooftype,"") 
	from ekyc_attachments 
	where Request_id = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return ReturnStruct, helpers.ErrReturn(lErr)

	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&ReturnStruct.SignedDocRec.CheqLeafOrStatement, &ReturnStruct.SignedDocRec.IncomeImage, &ReturnStruct.SignedDocRec.SignImage, &ReturnStruct.SignedDocRec.PanImage, &ReturnStruct.SignedDocRec.IncomeType)
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)

		}
	}
	if ReturnStruct.SignedDocRec.IncomeType != "" {
		pLookUpRec, lErr = commonpackage.GetLookUpDescription(pDebug, "IncomeProof", ReturnStruct.SignedDocRec.IncomeType, "code")
		if lErr != nil {
			return ReturnStruct, helpers.ErrReturn(lErr)
		}
		ReturnStruct.SignedDocRec.IncomeType = pLookUpRec.Descirption
	}
	// if ReturnStruct.SignedDocRec.SigenImageName, lErr = GetFileName(pDebug, ReturnStruct.SignedDocRec.SigenImage); lErr != nil {
	// 	return ReturnStruct, helpers.ErrReturn(lErr)
	// }
	// if ReturnStruct.SignedDocRec.PanImageName, lErr = GetFileName(pDebug, ReturnStruct.SignedDocRec.PanImage); lErr != nil {
	// 	return ReturnStruct, helpers.ErrReturn(lErr)
	// }
	// if ReturnStruct.SignedDocRec.IncomeImageName, lErr = GetFileName(pDebug, ReturnStruct.SignedDocRec.IncomeImage); lErr != nil {
	// 	return ReturnStruct, helpers.ErrReturn(lErr)
	// }
	// if ReturnStruct.SignedDocRec.CheqLeafOrStatementName, lErr = GetFileName(pDebug, ReturnStruct.SignedDocRec.CheqLeafOrStatement); lErr != nil {
	// 	return ReturnStruct, helpers.ErrReturn(lErr)
	// }

	pDebug.Log(helpers.Statement, "GetSignImage (-)")
	return ReturnStruct, nil
}

func GetFileName(pDebug *helpers.HelperStruct, DocId string) (string, error) {
	pDebug.Log(helpers.Statement, "GetFileName (+)")

	var lFileName string

	if strings.EqualFold(DocId, "") {
		return "", nil
	}

	sqlString := `select nvl(FileName,"") from document_attachment_details dad 
	 where id = ?`
	lRows, lErr := ftdb.MariaEKYCPRD_GDB.Query(sqlString, DocId)
	if lErr != nil {

		return lFileName, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lFileName)
		if lErr != nil {
			return lFileName, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "GetFileName (-)")

	return lFileName, nil
}

type DematAndService struct {
	Exchange string `json:"exchange"`
	Segment  string `json:"segment"`
}

func GetServicesFlag(pRequestId string, ReturnStruct stage, pDebug *helpers.HelperStruct) (stage, error) {
	pDebug.Log(helpers.Statement, "GetServicesFlag (+)")

	var dematandservice DematAndService
	var exchanges string
	var lookupRec commonpackage.LookupValStruct
	lPrompt := "TechExcel"
	var lookupResp commonpackage.LookupValRespStruct

	sqlString := `	select eem.Exchange,esm.Segment 
					from ekyc_services es ,ekyc_segment_master esm ,ekyc_exchange_master eem
					where es.segement_id = esm.id 
					and es.exchange_id =eem.id 
					and es.u_selected='Y'
					and Request_Uid = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(sqlString, pRequestId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return ReturnStruct, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&dematandservice.Exchange, &dematandservice.Segment)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return ReturnStruct, helpers.ErrReturn(lErr)
		} else {
			exchanges = dematandservice.Exchange + " " + dematandservice.Segment
			lookupRec.Code = "Techexcel exchange id"
			pDebug.Log(helpers.Details, "exchanges", exchanges)
			lookupRec.ReferenceVal = exchanges
			lookupRec.RequestedAttr = lPrompt
			lookupResp, lErr = commonpackage.GetAttributes(pDebug, lookupRec, "code")
			if lErr != nil {
				pDebug.Log(helpers.Elog, "DematAndService", lErr)
				return ReturnStruct, lErr
			} else {
				TechexcelExchanges := lookupResp.LookupValueArr[lPrompt]
				if TechexcelExchanges != "" {
					ReturnStruct.ServicesFlag = append(ReturnStruct.ServicesFlag, TechexcelExchanges)
				}
			}
		}

	}
	pDebug.Log(helpers.Details, "ReturnStruct.ServicesFlag", ReturnStruct.ServicesFlag)

	pDebug.Log(helpers.Statement, "GetServicesFlag (-)")

	return ReturnStruct, nil
}
