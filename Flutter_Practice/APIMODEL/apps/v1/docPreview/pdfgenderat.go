package docpreview

import (
	"encoding/json"
	"errors"
	"fcs23pkg/apps/v1/commonpackage"
	update "fcs23pkg/apps/v1/commonpackage"
	"fcs23pkg/apps/v1/fileoperations"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/pdfgenerate"
	"fcs23pkg/tomlconfig"
	"fmt"
	"net/http"
	"regexp"
	"strconv"
	"strings"
	"time"
)

type UserData struct {
	Name                    string `json:"Name"`
	Name2                   string `json:"Name2"`
	Name3                   string `json:"Name3"`
	MidName                 string `json:"MidName"`
	FatherOrSpouse          string `json:"FatherOrSpouse"`
	MotherName              string `json:"MotherName"`
	DOB                     string `json:"DOB"`
	Gender                  string `json:"Gender"`
	MaritalStat             string `json:"MaritalStat"`
	CitizeShip              string `json:"CitizeShip"`
	Residential             string `json:"Residential"`
	Occupation              string `json:"Occupation"`
	ResidenceOfTax          string `json:"ResidenceOfTax"`
	CountryOfJurisdiction   string `json:"CountryOfJurisdiction"`
	TaxIdentification       string `json:"TaxIdentification"`
	PlaceOfBirth            string `json:"PlaceOfBirth"`
	CountryOfBirth          string `json:"CountryOfBirth"`
	PAN                     string `json:"PAN"`
	PAN2                    string `json:"PAN2"`
	PAN3                    string `json:"PAN3"`
	AddressType             string `json:"AddressType"`
	ProofOfAddress          string `json:"ProofOfAddress"`
	CorAdrs1                string `json:"CorAdrs1"`
	CorAdrs2                string `json:"CorAdrs2"`
	CorAdrs3                string `json:"CorAdrs3"`
	CorPlace                string `json:"CorPlace"`
	CorState                string `json:"CorState"`
	CorCountry              string `json:"CorCountry"`
	CorPin                  string `json:"CorPin"`
	PerAdrs1                string `json:"PerAdrs1"`
	PerAdrs2                string `json:"PerAdrs2"`
	PerAdrs3                string `json:"PerAdrs3"`
	PerPlace                string `json:"PerPlace"`
	PerState                string `json:"PerState"`
	PerCountry              string `json:"PerCountry"`
	PerPin                  string `json:"PerPin"`
	TelOff                  string `json:"TelOff"`
	TelRes                  string `json:"TelRes"`
	Mobile                  string `json:"Mobile"`
	Fax                     string `json:"Fax"`
	Email                   string `json:"Email"`
	ReName                  string `json:"ReName"`
	ReType                  string `json:"ReType"`
	RePan                   string `json:"RePan"`
	Date                    string `json:"Date"`
	Place                   string `json:"Place"`
	DocRec                  string `json:"DocRec"`
	EmpName                 string `json:"EmpName"`
	SEBINumber              string `json:"SEBINumber"`
	EmpId                   string `json:"EmpId"`
	EmpDes                  string `json:"EmpDes"`
	EmpCKYCcode             string `json:"EmpCKYCcode"`
	BankName                string `json:"BankName"`
	AcNo                    string `json:"AcNo"`
	Branch                  string `json:"Branch"`
	UPI                     string `json:"UPI"`
	IFSC                    string `json:"IFSC"`
	MICR                    string `json:"MICR"`
	BankAdrs                string `json:"BankAdrs"`
	AcType                  string `json:"AcType"`
	AcPayOption             string `json:"AcPayOption"`
	DepoName                string `json:"DepoName"`
	DpId                    string `json:"DpId"`
	BoId                    string `json:"BoId"`
	DepoAccSub              string `json:"DepoAccSub"`
	NseCash                 string `json:"NseCash"`
	NseFO                   string `json:"NseFO"`
	NseCurr                 string `json:"NseCurr"`
	NseMF                   string `json:"NseMF"`
	BseCash                 string `json:"BseCash"`
	BseFO                   string `json:"BseFO"`
	BseCurr                 string `json:"BseCurr"`
	BseMF                   string `json:"BseMF"`
	MCXDate                 string `json:"MCXDate"`
	MCXFut                  string `json:"MCXFut"`
	MCXOpt                  string `json:"MCXOpt"`
	ICEXDate                string `json:"ICEXDate"`
	ICEXFut                 string `json:"ICEXFut"`
	ICEXOpt                 string `json:"ICEXOpt"`
	SMSOrEmail              string `json:"SMSOrEmail"`
	FacMode                 string `json:"FacMode"`
	FacAvil                 string `json:"FacAvil"`
	Latitude                string `json:"Latitude"`
	Longatude               string `json:"Longatude"`
	TradeExperience         string `json:"TradeExperience"`
	StockProfile            string `json:"StockProfile"`
	StockBroker             string `json:"StockBroker"`
	SubStockBroker          string `json:"SubStockBroker"`
	SubStockBroker2         string `json:"SubStockBroker2"`
	UCC                     string `json:"UCC"`
	TradeExchange           string `json:"TradeExchange"`
	TradeOtherData          string `json:"TradeOtherData"`
	Income                  string `json:"Income"`
	NetWorth                string `json:"NetWorth"`
	NetWorthDate            string `json:"NetWorthDate"`
	Education               string `json:"Education"`
	PoliticallyExposed      string `json:"PoliticallyExposed"`
	ForeignMoneyChange      string `json:"ForeignMoneyChange"`
	Gamblier                string `json:"Gamblier"`
	MoneyLending            string `json:"MoneyLending"`
	TAXResident             string `json:"TAXResident"`
	Identification1         string `json:"Identification1"`
	Identification2         string `json:"Identification2"`
	ForeignAdrs1            string `json:"ForeignAdrs1"`
	ForeignAdrs2            string `json:"ForeignAdrs2"`
	ForeignAdrs3            string `json:"ForeignAdrs3"`
	ForeignCity             string `json:"ForeignCity"`
	ForeignState            string `json:"ForeignState"`
	ForeignCountry          string `json:"ForeignCountry"`
	ForeignPin              string `json:"ForeignPin"`
	IntroducerName          string `json:"IntroducerName"`
	IntroducerCode          string `json:"IntroducerCode"`
	IntroducerPan           string `json:"IntroducerPan"`
	IntroducerPhone         string `json:"IntroducerPhone"`
	IntroducerAdrs          string `json:"IntroducerAdrs"`
	AccountStatus           string `json:"AccountStatus"`
	AccountSubStatus        string `json:"AccountSubStatus"`
	Nationality             string `json:"Nationality"`
	UID                     string `json:"UID"`
	UID2                    string `json:"UID2"`
	UID3                    string `json:"UID3"`
	CDSLGUardian            string `json:"CDSLGUardian"`
	CDSLRelationship        string `json:"CDSLRelationship"`
	CDSLPAN                 string `json:"CDSLPAN"`
	CDSLACCountStatement    string `json:"CDSLACCountStatement"`
	DPCredit                string `json:"DPCredit"`
	ECS                     string `json:"ECS"`
	EmailAlert              string `json:"EmailAlert"`
	SMSAlert                string `json:"SMSAlert"`
	DPAccept                string `json:"DPAccept"`
	RTA                     string `json:"RTA"`
	AnnualReport            string `json:"AnnualReport"`
	DepositoryServices      string `json:"DepositoryServices"`
	NSECode                 string `json:"NSECode"`
	BSECode                 string `json:"BSECode"`
	TradingID               string `json:"TradingID"`
	DPNAME                  string `json:"DPNAME"`
	ClientCode              string `json:"ClientCode"`
	MobileBelong            string `json:"MobileBelong"`
	EmailBelong             string `json:"EmailBelong"`
	DIS                     string `json:"DIS"`
	CMSegment               string `json:"CMSegment"`
	ClientID                string `json:"ClientID"`
	TMCode                  string `json:"TMCode"`
	CMCode                  string `json:"CMCode"`
	ClientIDWithSpace       string `json:"ClientIDWithSpace"`
	Nominee1Name            string `json:"Nominee1Name"`
	Nominee2Name            string `json:"Nominee2Name"`
	Nominee3Name            string `json:"Nominee3Name"`
	Nominee1Percent         string `json:"Nominee1Percent"`
	Nominee2Percent         string `json:"Nominee2Percent"`
	Nominee3Percent         string `json:"Nominee3Percent"`
	Nominee1Relationship    string `json:"Nominee1Relationship"`
	Nominee2Relationship    string `json:"Nominee2Relationship"`
	Nominee3Relationship    string `json:"Nominee3Relationship"`
	Nominee1Address         string `json:"Nominee1Address"`
	Nominee2Address         string `json:"Nominee2Address"`
	Nominee3Address         string `json:"Nominee3Address"`
	Nominee1Pincode         string `json:"Nominee1Pincode"`
	Nominee2Pincode         string `json:"Nominee2Pincode"`
	Nominee3Pincode         string `json:"Nominee3Pincode"`
	Nominee1MobileNo        string `json:"Nominee1MobileNo"`
	Nominee2MobileNo        string `json:"Nominee2MobileNo"`
	Nominee3MobileNo        string `json:"Nominee3MobileNo"`
	Nominee1Email           string `json:"Nominee1EmailID"`
	Nominee2Email           string `json:"Nominee2EmailID"`
	Nominee3Email           string `json:"Nominee3EmailID"`
	Nominee1Identification  string `json:"Nominee1Identification"`
	Nominee2Identification  string `json:"Nominee2Identification"`
	Nominee3Identification  string `json:"Nominee3Identification"`
	Nominee1Dob             string `json:"Nominee1DOB"`
	Nominee2Dob             string `json:"Nominee2DOB"`
	Nominee3Dob             string `json:"Nominee3DOB"`
	Gaurdian1Name           string `json:"Guardian1Name"`
	Gaurdian2Name           string `json:"Guardian2Name"`
	Gaurdian3Name           string `json:"Guardian3Name"`
	Gaurdian1Address        string `json:"Guardian1Address"`
	Gaurdian2Address        string `json:"Guardian2Address"`
	Gaurdian3Address        string `json:"Guardian3Address"`
	Gaurdian1Pincode        string `json:"Guardian1Pincode"`
	Gaurdian2Pincode        string `json:"Guardian2Pincode"`
	Gaurdian3Pincode        string `josn:"Guardian3Pincode"`
	Gaurdian1MobileNo       string `json:"Guardian1MobileNo"`
	Gaurdian2MobileNo       string `json:"Guardian2MobileNo"`
	Gaurdian3MobileNo       string `json:"Guardian3MobileNo"`
	Gaurdian1Email          string `json:"Guardian1EmailID"`
	Gaurdian2Email          string `json:"Guardian2EmailID"`
	Gaurdian3Email          string `josn:"Guardian3EmailID"`
	Gaurdian1Relationship   string `json:"Guardian1Relationship"`
	Gaurdian2Relationship   string `json:"Guardian2Relationship"`
	Gaurdian3Relationship   string `json:"Guardian3Relationship"`
	Gaurdian1Identification string `json:"Guardian1Identification"`
	Gaurdian2Identification string `json:"Guardian2Identification"`
	Gaurdian3Identification string `json:"Guardian3Identification"`
	NewKycCheck             string `json:"newkyc"`
	RekycCheck              string `json:"rekyc"`
	NormalKyc               string `json:"normal"`
	KycOtpCheck             string `json:"ekycotp"`
	KycBioCheck             string `json:"ekcybio"`
	OfflineKycCheck         string `json:"offlinekyc"`
	OnlineKycCheck          string `json:"onlinekyc"`
	DiglockerCheck          string `json:"diglocker"`
	QuarterlyCheck          string `json:"quarterly"`
	MonthlyCheck            string `json:"monthly"`
	AlDpId                  string `json:"AlDpId"`
	AlBoId                  string `json:"AlBoId"`
	Application_Charge      string `json:"applicationcharge"`
	// RunningAccSettlement    bool   `json:"RunAccState"`
	// Newkyc                  bool   `json:"newkyc"`
	// Kycflag                 bool   `json:"kycflag"`
	// Symbol                  string `json:"Symbol"`
}
type ResponceStruct struct {
	Status   string `json:"status"`
	DocID    string `json:"docid"`
	SignType string `json:"signtype"`
}

func GendratePDF(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold("POST", r.Method) {
		lDebug.Log(helpers.Statement, "GendratePDF (+)")
		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "PGP01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("PGP01", "Somthing is wrong please try again later"))
			return
		}

		lDocID, lErr := CheckChangesInForm(lDebug, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "PGP05"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("PGP05", "Somthing is wrong please try again later"))
			return
		}
		var lRespRec ResponceStruct
		var lBoidRec BoidMappingStruct

		lRespRec.Status = common.SuccessCode
		lRespRec.SignType = tomlconfig.GtomlConfigLoader.GetValueString("digioesign", "EsingType")
		lRespRec.DocID = lDocID
		if strings.EqualFold(lDocID, "") {
			lNewID, lErr := CreateClientId(lUid, lDebug)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "PGP02"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("PGP02", "Somthing is wrong please try again later"))
				return
			}
			lBoId, lErr := GetBoid(lDebug, lUid)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "PGP06"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("PGP06", "Somthing is wrong please try again later"))
				return
			}
			lBoidRec.BoId = lBoId
			lBoidRec.ClientId = lNewID
			lBoidRec.RequestId = lUid
			lBoidRec.Indicator = "Mapping"
			lBoidRec.User = "INSTAKYC"
			lBoidRec.Flag = "Y"

			lErr = UpdateBoIdStatus(lDebug, lBoidRec)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "PGP01"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("PGP01", "Somthing is wrong please try again later"))
				return
			}
			lDebug.SetReference(lUid)
			lRespRec.DocID, lErr = CreatePDF(lDebug, lUid, lSid, lNewID, lBoId)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "PGP03"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("PGP03", "Somthing is wrong please try again later"))
				return
			}
			lErr = update.UpdateDocID(lDebug, "SignedDocId", lRespRec.DocID, lUid, lSid)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "PGP04"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("PGP04", "Somthing is wrong please try again later"))
				return
			}
			lErr = update.AttachmentlogFile(lUid, "unSigned PDF", lRespRec.DocID, lDebug)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "PGP05"+lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("PGP05", "Somthing is wrong please try again later"))
				return
			}
		}
		lResp, lErr := json.Marshal(&lRespRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "PGP06"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("PGP06", "Somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "string(lResp)", string(lResp))
		fmt.Fprint(w, string(lResp))
		lDebug.Log(helpers.Statement, "GendratePDF (-)")
	}
}

func CreatePDF(pDebug *helpers.HelperStruct, pUid, pSid, pNewClientcode, pBoID string) (string, error) {
	pDebug.Log(helpers.Statement, "CreatePDF (+)")
	stages, lErr := GetUserInfo(pUid, pDebug)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	var lUserDataStruct UserData
	lUserDataStruct.Name = stages.BasicInfoRec.NameAsPerPan
	lUserDataStruct.FatherOrSpouse = stages.PersonalRec.FatherName
	lUserDataStruct.MotherName = stages.PersonalRec.MotherName
	lUserDataStruct.DOB = stages.BasicInfoRec.DOB
	lUserDataStruct.Gender = stages.PersonalRec.Gender
	lUserDataStruct.MaritalStat = stages.PersonalRec.MaritalStatus
	lUserDataStruct.Occupation = stages.PersonalRec.Occupation
	lUserDataStruct.PAN = stages.BasicInfoRec.PanNo
	lUserDataStruct.AddressType = stages.AdrsRec.AddressType1
	lUserDataStruct.ProofOfAddress = stages.AdrsRec.ProofofAddress
	lUserDataStruct.CorAdrs1 = stages.AdrsRec.CORAddress1
	lUserDataStruct.CorAdrs2 = stages.AdrsRec.CORAddress2
	lUserDataStruct.CorAdrs3 = stages.AdrsRec.CORAddress3
	lUserDataStruct.CorPlace = stages.AdrsRec.CORCity
	lUserDataStruct.CorState = stages.AdrsRec.CORState
	lUserDataStruct.CorCountry = stages.AdrsRec.CORCountry
	lUserDataStruct.CorPin = stages.AdrsRec.CORPincode
	lUserDataStruct.PerAdrs1 = stages.AdrsRec.PERAddress1
	lUserDataStruct.PerAdrs2 = stages.AdrsRec.PERAddress2
	lUserDataStruct.PerAdrs3 = stages.AdrsRec.PERAddress3
	lUserDataStruct.PerPlace = stages.AdrsRec.PERCity
	lUserDataStruct.PerState = stages.AdrsRec.PERState
	lUserDataStruct.PerCountry = stages.AdrsRec.CORCountry
	lUserDataStruct.PerPin = stages.AdrsRec.CORPincode
	lUserDataStruct.Mobile = stages.BasicInfoRec.MobileNo
	lUserDataStruct.Email = stages.BasicInfoRec.EmailId
	lUserDataStruct.SEBINumber = ""
	lUserDataStruct.Date = stages.BasicInfoRec.DateOfSubmit
	lUserDataStruct.BankName = stages.BankRec.BankName
	lUserDataStruct.AcNo = stages.BankRec.AccountNo
	lUserDataStruct.Branch = stages.BankRec.Bankbranch
	lUserDataStruct.IFSC = stages.BankRec.IFSC
	lUserDataStruct.MICR = stages.BankRec.MICR
	lUserDataStruct.BankAdrs = stages.BankRec.BankAddress
	lUserDataStruct.AcType = stages.BankRec.Acctype
	lUserDataStruct.AcPayOption = ""
	lUserDataStruct.NseCash = ""
	lUserDataStruct.BseCash = ""
	lUserDataStruct.BseFO = ""
	lUserDataStruct.NseFO = ""
	lUserDataStruct.MCXOpt = ""
	lUserDataStruct.BseCurr = ""
	lUserDataStruct.NseCurr = ""
	lUserDataStruct.BseMF = ""
	lUserDataStruct.NseMF = ""
	if len(pBoID) != 16 {
		return "", helpers.ErrReturn(fmt.Errorf("BOID length is not 16 characters"))
	}
	lUserDataStruct.BoId = pBoID
	lBoIdArr := strings.Split(pBoID, "")
	lUserDataStruct.DpId = strings.Join(lBoIdArr[:8], "")
	lUserDataStruct.ClientID = strings.Join(lBoIdArr[8:], "")
	lUserDataStruct.ClientCode = pNewClientcode
	// fmt.Println(stages.ServicesFlag, "\n\n", stages.DematAndServicesRec.Services)

	// for _, value := range stages.ServicesFlag {
	// 	switch value {
	// 	case "NSE_CASH":
	// 		lUserDataStruct.NseCash = "Y"
	// 	case "BSE_CASH":
	// 		lUserDataStruct.BseCash = "Y"
	// 	case "BSE_FNO":
	// 		lUserDataStruct.BseFO = "Y"
	// 	case "NSE_FNO":
	// 		lUserDataStruct.NseFO = "Y"
	// 	case "MCX":
	// 		lUserDataStruct.MCXOpt = "Y"
	// 	case "CD_BSE":
	// 		lUserDataStruct.BseCurr = "Y"
	// 	case "CD_NSE":
	// 		lUserDataStruct.NseCurr = "Y"
	// 	// case "ICEX":
	// 	case "MF_BSE":
	// 		lUserDataStruct.BseMF = "Y"
	// 	case "MF_NSE":
	// 		lUserDataStruct.NseMF = "Y"
	// 	}
	// }
	if strings.Contains(strings.Join(stages.ServicesFlag, ","), "MCX") {
		lUserDataStruct.MCXDate = stages.BasicInfoRec.DateOfSubmit
	}
	// lUserDataStruct.MCXDate = ""
	lUserDataStruct.ICEXDate = ""
	lUserDataStruct.ICEXFut = ""
	lUserDataStruct.ICEXOpt = ""
	lUserDataStruct.Latitude = stages.IpvRec.Latitude
	lUserDataStruct.Longatude = stages.IpvRec.Longitude
	lUserDataStruct.TradeExperience = stages.PersonalRec.TradingExposed
	lUserDataStruct.Income = stages.PersonalRec.AnnualIncome
	lUserDataStruct.Education = stages.PersonalRec.EducationQualification
	lUserDataStruct.PoliticallyExposed = "Yes"
	if strings.EqualFold(stages.PersonalRec.PoliticallyExposed, "N") {

		lUserDataStruct.PoliticallyExposed = "No"
	}
	lUserDataStruct.MobileBelong = stages.PersonalRec.MobileNoBelongsTo
	lUserDataStruct.EmailBelong = stages.PersonalRec.EmailIdBelongsTo
	if !strings.EqualFold(stages.PersonalRec.MobileNoBelongsTo, "Self") {
		lUserDataStruct.MobileBelong = fmt.Sprintf(" %s (%s)", stages.PersonalRec.PhoneOwnerName, stages.PersonalRec.MobileNoBelongsTo)
	}
	if !strings.EqualFold(stages.PersonalRec.EmailIdBelongsTo, "Self") {
		lUserDataStruct.EmailBelong = fmt.Sprintf(" %s (%s)", stages.PersonalRec.EmailOwnerName, stages.PersonalRec.EmailIdBelongsTo)
	}
	lUserDataStruct.DIS = "Yes"
	if strings.EqualFold(stages.DematAndServicesRec.DIS, "N") {
		lUserDataStruct.DIS = "No"
	}
	lUserDataStruct.IntroducerName = ""
	lUserDataStruct.IntroducerCode = ""
	lUserDataStruct.IntroducerPan = ""
	lUserDataStruct.IntroducerPhone = ""
	lUserDataStruct.IntroducerAdrs = ""
	lUserDataStruct.Place = stages.IpvRec.Place
	// lUserDataStruct.RunningAccSettlement = !strings.EqualFold(stages.DematAndServicesRec.RunningAccSettlement, "0")

	if strings.EqualFold(stages.PersonalRec.Nominee, "Y") {
		lUserDataStruct.AccountSubStatus = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "AccountSubStatusWithNominee")
	} else {
		lUserDataStruct.AccountSubStatus = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "AccountSubStatusWithOutNominee")
	}
	// if strings.EqualFold(stages.PersonalRec.DealingDesc, "") {
	// 	lUserDataStruct.StockBroker = "Not Available"
	// } else {
	// 	lUserDataStruct.StockBroker = stages.PersonalRec.DealingDesc
	// }
	// if strings.EqualFold(stages.PersonalRec.PastActionDesc, "") {
	// 	lUserDataStruct.TradeOtherData = "Not Available"
	// } else {
	// 	lUserDataStruct.TradeOtherData = stages.PersonalRec.PastActionDesc
	// }
	lUserDataStruct.UID = stages.BasicInfoRec.AadhaarNo

	lUserDataStruct.StockBroker = stages.PersonalRec.DealSubBrokerDesc
	lUserDataStruct.TradeOtherData = stages.PersonalRec.PastActionsDesc
	//fatco

	lUserDataStruct.TAXResident = "No"
	if !strings.EqualFold(stages.PersonalRec.FatcaDeclaration, "N") {
		lUserDataStruct.TAXResident = "Yes"
		lUserDataStruct.CountryOfJurisdiction = stages.PersonalRec.ResidenceCountry
		lUserDataStruct.TaxIdentification = stages.PersonalRec.TaxIdendificationNumber
		lUserDataStruct.PlaceOfBirth = stages.PersonalRec.PlaceofBirth
		lUserDataStruct.CountryOfBirth = stages.PersonalRec.CountryofBirth
		lUserDataStruct.ForeignAdrs1 = stages.PersonalRec.ForeignAddress1
		lUserDataStruct.ForeignAdrs2 = stages.PersonalRec.ForeignAddress2
		lUserDataStruct.ForeignAdrs3 = stages.PersonalRec.ForeignAddress3
		lUserDataStruct.ForeignCity = stages.PersonalRec.ForeignCity
		lUserDataStruct.ForeignState = stages.PersonalRec.ForeignState
		lUserDataStruct.ForeignCountry = stages.PersonalRec.ForeignCountry
		lUserDataStruct.ForeignPin = stages.PersonalRec.ForeignPincode
	}

	// Default Values
	lUserDataStruct.DepoName = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DepoName")
	lUserDataStruct.DepoAccSub = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DepoAccSub")
	lUserDataStruct.AlBoId = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "AlBoId")
	lUserDataStruct.AlDpId = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "AlDpId")
	lUserDataStruct.UID2 = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DefaultUID")
	lUserDataStruct.UID3 = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DefaultUID")
	lUserDataStruct.PAN2 = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DefaultPan")
	lUserDataStruct.PAN3 = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DefaultPan")
	lUserDataStruct.Name2 = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DefaultName")
	lUserDataStruct.Name3 = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DefaultName")
	lUserDataStruct.CDSLGUardian = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "CDSLGUardian")
	lUserDataStruct.CDSLRelationship = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "CDSLRelationship")
	lUserDataStruct.CDSLPAN = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "CDSLPAN")
	lUserDataStruct.ReName = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ReName")
	lUserDataStruct.ReType = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ReType")
	lUserDataStruct.RePan = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "RePan")
	lUserDataStruct.UPI = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "UPI")
	lUserDataStruct.CitizeShip = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "CitizeShip")
	lUserDataStruct.Residential = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "Residential")
	lUserDataStruct.EmpName = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "EmpName")
	lUserDataStruct.EmpCKYCcode = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "EmpCKYCcode")
	lUserDataStruct.EmpId = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "EmpId")
	lUserDataStruct.EmpDes = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "EmpDes")
	lUserDataStruct.SMSOrEmail = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "SMSOrEmail")
	lUserDataStruct.FacMode = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "FacMode")
	lUserDataStruct.FacAvil = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "FacAvil")
	lUserDataStruct.StockProfile = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "StockProfile")
	// lUserDataStruct.StockBrokertomlconfig.GtomlConfigLoader.GetValueString("dpscheme",e{})["StockBroker")
	lUserDataStruct.SubStockBroker = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "SubStockBroker")
	lUserDataStruct.SubStockBroker2 = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "SubStockBroker2")
	lUserDataStruct.UCC = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "UCC")
	lUserDataStruct.TradeExchange = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "TradeExchange")
	// lUserDataStruct.TradeOtherDatatomlconfig.GtomlConfigLoader.GetValueString("dpscheme",e{})["TradeOtherData")
	lUserDataStruct.NetWorth = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "NetWorth")
	lUserDataStruct.NetWorthDate = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "NetWorthDate")
	lUserDataStruct.ForeignMoneyChange = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ForeignMoneyChange")
	lUserDataStruct.Gamblier = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "Gamblier")
	lUserDataStruct.MoneyLending = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "MoneyLending")
	lUserDataStruct.Identification1 = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "Identification1")
	lUserDataStruct.Identification2 = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "Identification2")
	lUserDataStruct.AccountStatus = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "AccountStatus")
	lUserDataStruct.Nationality = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "Nationality")
	lUserDataStruct.CDSLACCountStatement = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "CDSLACCountStatement")
	lUserDataStruct.DPCredit = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DPCredit")
	lUserDataStruct.ECS = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ECS")
	lUserDataStruct.EmailAlert = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "EmailAlert")
	lUserDataStruct.SMSAlert = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "SMSAlert")
	lUserDataStruct.DPAccept = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DPAccept")
	lUserDataStruct.RTA = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "RTA")
	lUserDataStruct.AnnualReport = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "AnnualReport")
	lUserDataStruct.DepositoryServices = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DepositoryServices")
	lUserDataStruct.NSECode = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "NSECode")
	lUserDataStruct.BSECode = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "BSECode")
	lUserDataStruct.DPNAME = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DPNAME")
	lUserDataStruct.TMCode = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "TMCode")
	lUserDataStruct.CMCode = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "CMCode")
	lUserDataStruct.CMSegment = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "CMSegment")

	lUserDataStruct.NormalKyc = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxUnCheck")
	lUserDataStruct.KycOtpCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxUnCheck")
	lUserDataStruct.KycBioCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxUnCheck")
	lUserDataStruct.OfflineKycCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxUnCheck")
	lUserDataStruct.Application_Charge = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "application_Charge")

	if strings.EqualFold(tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "AccountType"), "newkyc") {
		lUserDataStruct.NewKycCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxCheck")
		lUserDataStruct.RekycCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxUnCheck")
	} else {
		lUserDataStruct.NewKycCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxUnCheck")
		lUserDataStruct.RekycCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxCheck")
	}

	if strings.EqualFold(stages.AdrsRec.Source_Of_Address, "Digilocker") {
		lUserDataStruct.DiglockerCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxCheck")
		lUserDataStruct.OnlineKycCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxUnCheck")
	} else {
		lUserDataStruct.OnlineKycCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxCheck")
		lUserDataStruct.DiglockerCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxUnCheck")
	}
	if strings.EqualFold(stages.DematAndServicesRec.RunningAccSettlement, "0") {
		lUserDataStruct.MonthlyCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxCheck")
		lUserDataStruct.QuarterlyCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxUnCheck")

	} else {
		lUserDataStruct.MonthlyCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxUnCheck")
		lUserDataStruct.QuarterlyCheck = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "ballotBoxCheck")

	}

	lRmsignDocID := tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "RmsignDocID")

	lAddressProofdocId, lErr := fileoperations.GetAdrsProofDocID(pDebug, pUid)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	lAttachArr1 := Attachment(pDebug, stages.SignedDocRec.PanImage, lAddressProofdocId, stages.SignedDocRec.SignImage)

	lAttachArr2 := Attachment(pDebug, stages.SignedDocRec.CheqLeafOrStatement, stages.SignedDocRec.IncomeImage)

	var lImageArr []pdfgenerate.ImgStruct

	GenerareImage(pDebug, &lImageArr, stages.IpvRec.ImageDocId, "Image", 60, 70)
	GenerareImage(pDebug, &lImageArr, lRmsignDocID, "RmSign", 50, 30)
	GenerareImage(pDebug, &lImageArr, stages.SignedDocRec.SignImage, "Signimage", 50, 30)

	if strings.EqualFold(stages.PersonalRec.Nominee, "Y") {

		for lIDX, lNomineeInfo := range stages.NomineeArr {
			lNomineeAddress, lGuardianAddress := "", ""
			if lNomineeInfo.GuardianAddress1 != "" {
				lGuardianAddress = lNomineeInfo.GuardianAddress1
			}
			if lNomineeInfo.GuardianAddress2 != "" {
				lGuardianAddress += "," + lNomineeInfo.GuardianAddress2
			}
			if lNomineeInfo.GuardianAddress3 != "" {
				lGuardianAddress += "," + lNomineeInfo.GuardianAddress3
			}
			if lNomineeInfo.NomineeAddress1 != "" {
				lNomineeAddress = lNomineeInfo.NomineeAddress1
			}
			if lNomineeInfo.NomineeAddress2 != "" {
				lNomineeAddress += "," + lNomineeInfo.NomineeAddress2
			}
			if lNomineeInfo.NomineeAddress3 != "" {
				lNomineeAddress += "," + lNomineeInfo.NomineeAddress3
			}
			if lIDX == 0 {
				lUserDataStruct.Nominee1Name = lNomineeInfo.NomineeName
				lUserDataStruct.Nominee1Percent = lNomineeInfo.NomineeShare
				lUserDataStruct.Nominee1Relationship = lNomineeInfo.NomineeRelationship
				lUserDataStruct.Nominee1Address = lNomineeAddress
				lUserDataStruct.Nominee1Pincode = lNomineeInfo.NomineePincode
				lUserDataStruct.Nominee1MobileNo = lNomineeInfo.NomineeMobileNo
				lUserDataStruct.Nominee1Email = lNomineeInfo.NomineeEmailId
				lUserDataStruct.Nominee1Identification = lNomineeInfo.NomineeProofOfIdentity
				lUserDataStruct.Nominee1Dob = lNomineeInfo.NomineeDOB
				lUserDataStruct.Gaurdian1Name = lNomineeInfo.GuardianName
				lUserDataStruct.Gaurdian1Address = lGuardianAddress
				lUserDataStruct.Gaurdian1Pincode = lNomineeInfo.GuardianPincode
				lUserDataStruct.Gaurdian1MobileNo = lNomineeInfo.GuardianMobileNo
				lUserDataStruct.Gaurdian1Email = lNomineeInfo.GuardianEmailId
				lUserDataStruct.Gaurdian1Relationship = lNomineeInfo.GuardianRelationship
				lUserDataStruct.Gaurdian1Identification = lNomineeInfo.GuardianProofOfIdentity
			} else if lIDX == 1 {
				lUserDataStruct.Nominee2Name = lNomineeInfo.NomineeName
				lUserDataStruct.Nominee2Percent = lNomineeInfo.NomineeShare
				lUserDataStruct.Nominee2Relationship = lNomineeInfo.NomineeRelationship
				lUserDataStruct.Nominee2Address = lNomineeAddress
				lUserDataStruct.Nominee2Pincode = lNomineeInfo.NomineePincode
				lUserDataStruct.Nominee2MobileNo = lNomineeInfo.NomineeMobileNo
				lUserDataStruct.Nominee2Email = lNomineeInfo.NomineeEmailId
				lUserDataStruct.Nominee2Identification = lNomineeInfo.NomineeProofOfIdentity
				lUserDataStruct.Nominee2Dob = lNomineeInfo.NomineeDOB
				lUserDataStruct.Gaurdian2Name = lNomineeInfo.GuardianName
				lUserDataStruct.Gaurdian2Address = lGuardianAddress
				lUserDataStruct.Gaurdian2Pincode = lNomineeInfo.GuardianPincode
				lUserDataStruct.Gaurdian2MobileNo = lNomineeInfo.GuardianMobileNo
				lUserDataStruct.Gaurdian2Email = lNomineeInfo.GuardianEmailId
				lUserDataStruct.Gaurdian2Relationship = lNomineeInfo.GuardianRelationship
				lUserDataStruct.Gaurdian2Identification = lNomineeInfo.GuardianProofOfIdentity
			} else if lIDX == 2 {
				lUserDataStruct.Nominee3Name = lNomineeInfo.NomineeName
				lUserDataStruct.Nominee3Percent = lNomineeInfo.NomineeShare
				lUserDataStruct.Nominee3Relationship = lNomineeInfo.NomineeRelationship
				lUserDataStruct.Nominee3Address = lNomineeAddress
				lUserDataStruct.Nominee3Pincode = lNomineeInfo.NomineePincode
				lUserDataStruct.Nominee3MobileNo = lNomineeInfo.NomineeMobileNo
				lUserDataStruct.Nominee3Email = lNomineeInfo.NomineeEmailId
				lUserDataStruct.Nominee3Identification = lNomineeInfo.NomineeProofOfIdentity
				lUserDataStruct.Nominee3Dob = lNomineeInfo.NomineeDOB
				lUserDataStruct.Gaurdian3Name = lNomineeInfo.GuardianName
				lUserDataStruct.Gaurdian3Address = lGuardianAddress
				lUserDataStruct.Gaurdian3Pincode = lNomineeInfo.GuardianPincode
				lUserDataStruct.Gaurdian3MobileNo = lNomineeInfo.GuardianMobileNo
				lUserDataStruct.Gaurdian3Email = lNomineeInfo.GuardianEmailId
				lUserDataStruct.Gaurdian3Relationship = lNomineeInfo.GuardianRelationship
				lUserDataStruct.Gaurdian3Identification = lNomineeInfo.GuardianProofOfIdentity
			}
		}
	}

	lTemplateData, lErr := json.Marshal(&lUserDataStruct)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	lDocID, lErr := EKYCPDFGenerate(pDebug, string(lTemplateData), pUid, pSid, lImageArr, lAttachArr1, lAttachArr2, stages)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "CreatePDF (-)")

	return lDocID, nil
}

func GenerareImage(pDebug *helpers.HelperStruct, lImageArr *[]pdfgenerate.ImgStruct, lDocID, lKey string, lWeight, lHeight float64) {
	pDebug.Log(helpers.Statement, "GenerareImage (+)")
	if strings.EqualFold(lDocID, "") {
		return
	}
	var lImageRec pdfgenerate.ImgStruct

	lImageRec.ImgDocID = lDocID
	lImageRec.ImgKey = lKey
	lImageRec.ImgHeight = lHeight
	lImageRec.ImgWeigth = lWeight
	*lImageArr = append(*lImageArr, lImageRec)
	pDebug.Log(helpers.Statement, "GenerareImage (-)")

}

func ImgConfigData(pDebug *helpers.HelperStruct, pUserImgDocId, pUserSignDocId string) ([]pdfgenerate.ImageDataStruct, error) {
	pDebug.Log(helpers.Statement, "ImageMetaDataInfo (+)")

	var PdfImgDataArr []pdfgenerate.ImageDataStruct
	var imgConfigArr = []string{"Logo", "UserImg", "UserSign1", "UserSign2", "IpvEmpSign"}

	for _, imgConfig := range imgConfigArr {

		lWidth, lErr := strconv.Atoi(tomlconfig.GtomlConfigLoader.GetValueString("krapdfconfig", imgConfig+"_Width"))
		if lErr != nil {
			return PdfImgDataArr, helpers.ErrReturn(lErr)
		}
		lHeight, lErr := strconv.Atoi(tomlconfig.GtomlConfigLoader.GetValueString("krapdfconfig", imgConfig+"_Height"))
		if lErr != nil {
			return PdfImgDataArr, helpers.ErrReturn(lErr)
		}
		lDX, lErr := strconv.Atoi(tomlconfig.GtomlConfigLoader.GetValueString("krapdfconfig", imgConfig+"_DX"))
		if lErr != nil {
			return PdfImgDataArr, helpers.ErrReturn(lErr)
		}
		lDY, lErr := strconv.Atoi(tomlconfig.GtomlConfigLoader.GetValueString("krapdfconfig", imgConfig+"_DY"))
		if lErr != nil {
			return PdfImgDataArr, helpers.ErrReturn(lErr)
		}
		var lDocId string
		if imgConfig == "UserSign1" || imgConfig == "UserSign2" {
			lDocId = pUserSignDocId
		} else if imgConfig == "UserImg" {
			lDocId = pUserImgDocId
		} else {
			lDocId = tomlconfig.GtomlConfigLoader.GetValueString("krapdfconfig", imgConfig+"_DocID")
		}

		lScale, lErr := strconv.ParseFloat(tomlconfig.GtomlConfigLoader.GetValueString("krapdfconfig", imgConfig+"_Scale"), 64)
		if lErr != nil {
			return PdfImgDataArr, helpers.ErrReturn(lErr)
		}

		PdfImgData := pdfgenerate.ImageDataStruct{
			DocID:    lDocId,
			Imagepos: tomlconfig.GtomlConfigLoader.GetValueString("krapdfconfig", imgConfig+"_Imagepos"),
			PageNo:   tomlconfig.GtomlConfigLoader.GetValueString("krapdfconfig", imgConfig+"_PageNo"),
			Width:    lWidth,
			Height:   lHeight,
			DX:       lDX,
			DY:       lDY,
			Scale:    lScale,
		}
		PdfImgDataArr = append(PdfImgDataArr, PdfImgData)
	}

	pDebug.Log(helpers.Details, "PdfImgDataArr", PdfImgDataArr)

	pDebug.Log(helpers.Statement, "ImageMetaDataInfo (-)")
	return PdfImgDataArr, nil
}

func EKYCPDFGenerate(pDebug *helpers.HelperStruct, pJsonData, pUid, pSid string, pImageInfo []pdfgenerate.ImgStruct, pAttacMent1, pAttacMent2 []pdfgenerate.AttachStruct, stages stage) (string, error) {
	pDebug.Log(helpers.Statement, "EKYCPDFGenerate (+)")

	var lTemplateRec pdfgenerate.TemplateStruct
	var lPDFRormRec pdfgenerate.PDFFormStruct
	var lErr error

	lPDFRormRec.DocID = tomlconfig.GtomlConfigLoader.GetValueString("krapdfconfig", "KRATemplateDocId")
	lPDFRormRec.ImageDataArr, lErr = ImgConfigData(pDebug, stages.IpvRec.ImageDocId, stages.SignedDocRec.SignImage)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	lPDFRormRec.ProcessType = tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "PDFProcessType1")
	lJsonMap, lErr := PDFformFill(pDebug, stages)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	//get URL from toml

	lPDFRormRec.JsonMapData = lJsonMap
	lPDFRormRec.Attachment = pAttacMent1

	lDocID1, lErr := pdfgenerate.FillPDFFile(pDebug, lPDFRormRec, pUid, pSid)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	lTemplateRec.JsonData = pJsonData
	lTemplateRec.ProcessType = tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "PDFProcessType2")
	lTemplateRec.Attachment = pAttacMent2
	lTemplateRec.ImageData = pImageInfo
	// lTemplateRec.ImageData = nil

	lDocID2, lErr := pdfgenerate.PDFGenerate(pDebug, lTemplateRec, pUid, pSid)

	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	ProcessType := tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "PDFProcessType")

	lPDFInfo, lErr := pdfgenerate.MergePDFFile(pDebug, ProcessType, pUid, pSid, lDocID1, lDocID2)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "EKYCPDFGenerate (-)")
	return lPDFInfo.Docid, nil
}

func Attachment(pDebug *helpers.HelperStruct, pAttachMent ...string) []pdfgenerate.AttachStruct {
	pDebug.Log(helpers.Statement, "Attachment (+)")

	var lAttachRec pdfgenerate.AttachStruct
	var lAttachArr []pdfgenerate.AttachStruct
	for _, lDocID := range pAttachMent {
		if !strings.EqualFold(lDocID, "") {
			lAttachRec.AttachDocID = lDocID
			lAttachArr = append(lAttachArr, lAttachRec)
		}
	}

	pDebug.Log(helpers.Statement, "Attachment (-)")
	return lAttachArr
}

func CreateClientId(pReqid string, pDebug *helpers.HelperStruct) (string, error) {

	pDebug.Log(helpers.Statement, "CreateClientId (+)")
	var lLastClientId, lNewClientId, lLastAppNo, lNewAppNo, lFlag string

	lSelectString := `
	IF EXISTS (SELECT * FROM ekyc_request er WHERE er.Uid = ? and er.Client_Id IS NOT NULL and er.applicationNo IS NOT NULL) THEN
    SELECT  nvl(er.Client_Id,""),nvl(applicationNo,""), 'N' as Change_Value FROM ekyc_request er WHERE er.Uid = ?;
ELSE
	SELECT nvl(max(er.Client_Id),""),nvl(max(applicationNo),""), 'Y' as Change_Value
	FROM ekyc_request er;
END IF;
	`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lSelectString, pReqid, pReqid)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lLastClientId, &lLastAppNo, &lFlag)
		pDebug.Log(helpers.Details, "lRows", lRows)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
	}
	if strings.EqualFold(lFlag, "Y") {

		if !strings.EqualFold(lLastClientId, "") {
			lNewClientId, lErr = ChangeNo(pDebug, lLastClientId)
			if lErr != nil {
				return "", helpers.ErrReturn(lErr)
			}
		} else {
			lNewClientId = tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "ClientID")
		}
		if !strings.EqualFold(lLastAppNo, "") {
			lNewAppNo, lErr = ChangeNo(pDebug, lLastAppNo)
			if lErr != nil {
				return "", helpers.ErrReturn(lErr)
			}
		} else {
			lNewAppNo = tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "ApplicationNo")
		}

		lCoreString := `update ekyc_request set Client_Id = ? ,applicationNo=?
					  where Uid=?`
		_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, lNewClientId, lNewAppNo, pReqid)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
		pDebug.Log(helpers.Details, "Last ID => New ID :", lLastClientId, " => ", lNewClientId)
		lLastClientId = lNewClientId
	}
	pDebug.Log(helpers.Statement, "CreateClientId (-)")
	return lLastClientId, nil
}

func ChangeNo(pDebug *helpers.HelperStruct, pID string) (string, error) {
	pDebug.Log(helpers.Statement, "ChangeNo (+)")
	pattern := regexp.MustCompile(`(\d+)`)
	Clientmatch := pattern.FindStringSubmatch(pID)
	if len(Clientmatch) < 1 {
		return "", errors.New("No numeric part found in the given id :" + pID)
	}
	BaseString := pID[:len(pID)-len(Clientmatch[1])]

	num, lErr := strconv.Atoi(Clientmatch[1])
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	num++

	// Use sprintf to generate the padded numeric part
	paddedNumber := fmt.Sprintf("%0*d", len(Clientmatch[1]), num)

	lNewClientId := fmt.Sprintf("%s%s", BaseString, paddedNumber)

	pDebug.Log(helpers.Statement, "ChangeNo (-)")
	return lNewClientId, nil
}

type PDFDocStruct struct {
	Status string `json:"status"`
	DocID  string `json:"docid"`
}

func GetPDFDocId(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "GET")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold("GET", r.Method) {
		lDebug.Log(helpers.Statement, "GetPDFDocId (+)")
		var PDFDocRec PDFDocStruct
		PDFDocRec.Status = common.SuccessCode
		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NEKYC", "Somthing is wrong please try again later"))
			return
		}

		lSelectString := `select nvl(unsignedDocid,"") from ekyc_request where Uid=?;`
		lRows, lErr := ftdb.NewEkyc_GDB.Query(lSelectString, lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NEKYC", "Somthing is wrong please try again later"))
			return
		}
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&PDFDocRec.DocID)
			if lErr != nil {
				lDebug.Log(helpers.Elog, lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("NEKYC", "Somthing is wrong please try again later"))
				return
			}
		}
		if strings.EqualFold("", PDFDocRec.DocID) {
			lDebug.Log(helpers.Elog, "unsigned PDF DOCID is missing")
			fmt.Fprint(w, helpers.GetError_String("NEKYC", "Somthing is wrong please try again later"))
			return
		}

		lData, lErr := json.Marshal(PDFDocRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NEKYC", "Somthing is wrong please try again later"))
			return
		}

		fmt.Fprint(w, string(lData))
		lDebug.Log(helpers.Statement, "GetPDFDocId (-)")
	}
}

func CheckChangesInForm(pDebug *helpers.HelperStruct, pUid string) (lDocID string, lErr error) {
	pDebug.Log(helpers.Statement, "CheckChangesInForm (+)")

	lQry := `select er.unsignedDocid
	from ekyc_onboarding_status eos ,ekyc_attachmentlog_history eah,ekyc_request er
	where eos.Request_id =er.Uid 
	and eah.Reqid =eos.Request_id
	and eos.CreatedDate < eah.CreatedDate
	and eos.id =(select max(id) from ekyc_onboarding_status eos2 where eos2.Request_id= ? and eos2.Page_Name <> 'signup')
	and eah.id =(select max(id) from ekyc_attachmentlog_history eah2 where eah2.Reqid= ? and eah2.Filetype ='unSigned PDF')
	and er.Uid= ?`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lQry, pUid, pUid, pUid)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lDocID)
		// pDebug.Log(helpers.Details, "lRows", lRows)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "CheckChangesInForm (-)")
	return lDocID, nil
}

func PDFformFill(pDebug *helpers.HelperStruct, pStageInfo stage) (lFormInfo string, lErr error) {
	pDebug.Log(helpers.Statement, "CheckChangesInForm (-)")
	lMapInfo := make(map[string]interface{})
	// textfield
	lMapInfo["PanNo"] = pStageInfo.BasicInfoRec.PanNo

	lClientName := pStageInfo.BasicInfoRec.NameAsPerPan

	lMapInfo["C_Title"] = pStageInfo.BasicInfoRec.Bo_title
	lMapInfo["C_FirstName"], lMapInfo["C_MiddleName"], lMapInfo["C_LastName"], lErr = commonpackage.SplitFullName(pDebug, lClientName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lFormInfo, helpers.ErrReturn(lErr)
	}

	lMapInfo["M_Title"] = ""
	lMapInfo["M_FirstName"] = ""
	lMapInfo["M_MiddleName"] = ""
	lMapInfo["M_LastName"] = ""

	lFatherName := pStageInfo.PersonalRec.FatherName

	lMapInfo["F_Title"] = pStageInfo.PersonalRec.FatherTitle
	lMapInfo["F_FirstName"], lMapInfo["F_MiddleName"], lMapInfo["F_LastName"], lErr = commonpackage.SplitFullName(pDebug, lFatherName)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lFormInfo, helpers.ErrReturn(lErr)
	}

	lMapInfo["Dob"] = pStageInfo.BasicInfoRec.DOB
	lMapInfo["EmailId"] = pStageInfo.BasicInfoRec.EmailId
	lMapInfo["MobileNo"] = pStageInfo.BasicInfoRec.MobileNo
	// fmt.Println(pStageInfo.BasicInfoRec.DateOfSubmit)
	// lParsedDate, lErr := time.Parse("2006-01-02 15:04:05.000", pStageInfo.BasicInfoRec.DateOfSubmit)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return lFormInfo, helpers.ErrReturn(lErr)
	// }
	// lDeclarationDate := lParsedDate.Format("02/01/2006")

	lFormSubmissionDate := time.Now().Format("02/01/2006")
	lMapInfo["DeclarationDate"] = lFormSubmissionDate
	lMapInfo["IpvDate"] = lFormSubmissionDate

	// lParsedDate, lErr := time.Parse("2006-01-02 15:04:05", pStageInfo.IpvRec.Date)
	// if lErr != nil {
	// 	pDebug.Log(helpers.Elog, lErr.Error())
	// 	return lFormInfo, helpers.ErrReturn(lErr)
	// }
	// lIpvDate := lParsedDate.Format("02/01/2006")

	lMapInfo["DeclarationPlace"] = pStageInfo.IpvRec.Place
	lMapInfo["C_City"] = pStageInfo.AdrsRec.CORCity
	lMapInfo["C_State"] = pStageInfo.AdrsRec.CORState
	lMapInfo["C_AddressLine1"] = pStageInfo.AdrsRec.CORAddress1
	lMapInfo["C_AddressLine2"] = pStageInfo.AdrsRec.CORAddress2
	lMapInfo["C_AddressLine3"] = pStageInfo.AdrsRec.CORAddress3
	lMapInfo["C_Pincode"] = pStageInfo.AdrsRec.CORPincode
	lMapInfo["C_District"] = pStageInfo.AdrsRec.CORCity
	lMapInfo["C_Country"] = pStageInfo.AdrsRec.CORCountry
	lMapInfo["P_AddressLine1"] = pStageInfo.AdrsRec.PERAddress1
	lMapInfo["P_AddressLine2"] = pStageInfo.AdrsRec.PERAddress2
	lMapInfo["P_AddressLine3"] = pStageInfo.AdrsRec.PERAddress3
	lMapInfo["P_District"] = pStageInfo.AdrsRec.PERCity
	lMapInfo["P_City"] = pStageInfo.AdrsRec.PERCity
	lMapInfo["P_Pincode"] = pStageInfo.AdrsRec.PERPincode
	lMapInfo["P_State"] = pStageInfo.AdrsRec.PERState
	lMapInfo["P_Country"] = pStageInfo.AdrsRec.PERCountry
	lMapInfo["Nationality_others"] = ""
	lMapInfo["ApplicationNo"] = ""
	lMapInfo["ResTelNo"] = ""
	lMapInfo["OffTelCode"] = ""
	lMapInfo["OffTelNo"] = ""
	lMapInfo["ResTelCode"] = ""
	lMapInfo["POI_AadharUid"] = strings.ReplaceAll(strings.ToUpper(pStageInfo.BasicInfoRec.AadhaarNo), "X", "")
	lMapInfo["POI_NregaNo"] = ""
	lMapInfo["POI_OthersNo"] = ""
	lMapInfo["POI_DLicenceNo"] = ""
	lMapInfo["POI_PassportNo"] = ""
	lMapInfo["POI_DLicenceExpiry"] = ""
	lMapInfo["POI_VoterIdNo"] = ""
	lMapInfo["POI_NprNo"] = ""
	lMapInfo["POI_PassportExpiry"] = ""
	lMapInfo["POI_Others"] = ""

	if strings.EqualFold(pStageInfo.AdrsRec.ProofofAddress, "AADHAAR") {
		lMapInfo["POA_AadharUid"] = strings.ReplaceAll(strings.ToUpper(pStageInfo.BasicInfoRec.AadhaarNo), "X", "")
		lMapInfo["POA_Aadhar"] = true
	} else if strings.EqualFold(pStageInfo.AdrsRec.ProofofAddress, "Voter Identity Card") {
		lMapInfo["POA_VoterIdNo"] = pStageInfo.AdrsRec.PERProofNo
		lMapInfo["POA_Voter_CB"] = true
	} else if strings.EqualFold(pStageInfo.AdrsRec.ProofofAddress, "Passport") {
		lMapInfo["POA_PassportNo"] = pStageInfo.AdrsRec.PERProofNo
		lMapInfo["POA_Passport_CB"] = true
		lMapInfo["POA_PassportExpiry"] = pStageInfo.AdrsRec.PERProofExpriyDate
	} else if strings.EqualFold(pStageInfo.AdrsRec.ProofofAddress, "Driving License") {
		lMapInfo["POA_DLicenceExpiry"] = pStageInfo.AdrsRec.PERProofExpriyDate
		lMapInfo["POA_DLicenceNo"] = pStageInfo.AdrsRec.PERProofNo
		lMapInfo["POA_DLicence_CB"] = false
	} else {
		lMapInfo["POA_Others"] = pStageInfo.AdrsRec.ProofofAddress
		lMapInfo["POA_OthersNo"] = pStageInfo.AdrsRec.PERProofNo
		lMapInfo["POA_Others_CB"] = true
	}

	// lMapInfo["POA_NprNo"] = ""
	// lMapInfo["POA_Npr_CB"] = false
	// lMapInfo["POA_NregaNo"] = ""
	// lMapInfo["POA_Nrega_CB"] = false

	// checkbox
	lMapInfo["Nationality_Indian"] = true
	lMapInfo["Nationality_Other"] = false

	lMapInfo["POI_Others_CB"] = false
	lMapInfo["POI_Nrega_CB"] = false
	lMapInfo["POI_Aadhar"] = false
	lMapInfo["POI_Voter_CB"] = false
	lMapInfo["POI_Passport_CB"] = false
	lMapInfo["POI_Npr_CB"] = false
	lMapInfo["POI_DLicence_CB"] = false

	if strings.EqualFold(pStageInfo.PersonalRec.Gender, "Male") {
		lMapInfo["Gender_Male"] = true
	} else if strings.EqualFold(pStageInfo.PersonalRec.Gender, "Female") {
		lMapInfo["Gender_Female"] = true
	} else if strings.EqualFold(pStageInfo.PersonalRec.Gender, "Transgender") {
		lMapInfo["Gender_TG"] = true
	}
	if strings.EqualFold(pStageInfo.PersonalRec.MaritalStatus, "Single") {
		lMapInfo["Marital_Single"] = true
	} else if strings.EqualFold(pStageInfo.PersonalRec.MaritalStatus, "Married") {
		lMapInfo["Marital_Married"] = true
	}

	lMapInfo["Resident_IndianOrgin"] = false
	lMapInfo["Resident_Foreign"] = false
	lMapInfo["Resident_Nri"] = false

	lMapInfo["IntermediatryType_Attested_CB"] = false
	lMapInfo["IntermediatryType_OVD_CB"] = true

	lMapInfo["C_AddrsType_ResiBusi_CB"] = true
	lMapInfo["C_AddrsType_OfficeAddr_CB"] = false
	lMapInfo["C_AddrsType_UnSpecify_CB"] = false

	lMapInfo["P_AddrsType_ResiBusi_CB"] = true
	lMapInfo["P_AddrsType_UnSpecify_CB"] = false
	lMapInfo["P_AddrsType_Busi_CB"] = false
	lMapInfo["P_AddrsType_Resi_CB"] = false
	lMapInfo["P_AddrsType_OfficeAddr_CB"] = false

	//radiobtn
	lMapInfo["Resident_Individual"] = "Yes"
	lMapInfo["C_AddrsType_Resi_CB"] = ""
	lMapInfo["C_AddrsType_Busi_CB"] = ""

	// toml values

	//testField
	lMapInfo["IpvEmpCode"] = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "EmpCKYCcode")
	lMapInfo["IpvEmpName"] = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "EmpName")
	lMapInfo["IpvEmpDesignation"] = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "EmpDes")
	lMapInfo["MobCode"] = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "MobCode")
	lMapInfo["IntermediatryName"] = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "IntermediatryName")
	//Checkbox
	lMapInfo["KycMode_Offline"] = false
	lMapInfo["KycMode_Otp"] = false
	lMapInfo["KycMode_Biometric"] = false
	lMapInfo["KycMode_Normal"] = false

	if strings.EqualFold(tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "AccountType"), "newkyc") {
		lMapInfo["AppType_New"] = true
	} else {
		lMapInfo["AppType_Mod"] = true
	}

	if strings.EqualFold(pStageInfo.AdrsRec.Source_Of_Address, "Digilocker") {
		lMapInfo["KycMode_Digilocker"] = true
	} else {
		lMapInfo["KycMode_Online"] = true
	}

	lMapInfoByte, lErr := json.Marshal(lMapInfo)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "CheckChangesInForm (-)")
	return string(lMapInfoByte), nil
}
