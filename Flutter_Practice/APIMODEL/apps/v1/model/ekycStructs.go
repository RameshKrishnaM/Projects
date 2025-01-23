package model

type BasicInfoStruct struct {
	GiveName      string `json:"givenname"`
	NameAsPerPan  string `json:"nameasperpan"`
	PanNo         string `json:"panno"`
	DOB           string `json:"dob"`
	MobileNo      string `json:"mobileno"`
	EmailId       string `json:"emailid"`
	LinkedAadhar  string `json:"linkedaadhar"`
	ClientCode    string `json:"clientcode"`
	SubmittedDate string `json:"submitteddate"`
	DateOfSubmit  string `json:"dateofsubmit"`
}

type AddressStruct struct {
	Source_Of_Address      string `json:"sourceofaddress"`
	AddressType1           string `json:"addresstype1"`
	PERAddress1            string `json:"peraddress1"`
	PERAddress2            string `json:"peraddress2"`
	PERAddress3            string `json:"peraddress3"`
	PERCity                string `json:"percity"`
	PERPincode             string `json:"perpincode"`
	PERState               string `json:"perstate"`
	PERCountry             string `json:"percountry"`
	ProofofAddress         string `json:"proofofaddresstype"`
	PERDateofissue         string `json:"perdate"`
	PERProofNo             string `json:"perproofno"`
	PERProofPlaceofissue   string `json:"perpalceofissue"`
	PERDocID1              string `json:"docid1"`
	PERDocID2              string `json:"docid2"`
	AddressType2           string `json:"addresstype2"`
	CORAddress1            string `json:"coraddress1"`
	CORAddress2            string `json:"coraddress2"`
	CORAddress3            string `json:"coraddress3"`
	CORCity                string `json:"corcity"`
	CORPincode             string `json:"corpincode"`
	CORState               string `json:"corstate"`
	CORCountry             string `json:"corcountry"`
	SameAsPermenentAddress string `json:"sameasperadrs"`
	PERDoc1Name            string `json:"perdoc1name"`
	PERDoc2Name            string `json:"perdoc2name"`
}

type BankDetailsStruct struct {
	AccountNo       string `json:"accountno"`
	IFSC            string `json:"ifsc"`
	MICR            string `json:"micr"`
	BankName        string `json:"bankname"`
	Bankbranch      string `json:"bankbranch"`
	BankAddress     string `json:"bankaddress"`
	BankProofDocId  string `json:"bankproofdocid"`
	BankProofType   string `json:"bankprooftype"`
	PennyDrop       string `json:"pennydrop"`
	PennyDropStatus string `json:"pennydropstatus"`
	NameAsPennyDrop string `json:"nameaspennydrop"`
}

type PersonalStruct struct {
	FatherName             string `json:"fathername"`
	MotherName             string `json:"mothername"`
	Gender                 string `json:"gender"`
	MobileNo               string `json:"mobileNo"`
	MobileNoBelongsTo      string `json:"mobileNobelongsto"`
	EmailId                string `json:"emailId"`
	EmailIdBelongsTo       string `json:"emailIdbelongsto"`
	Occupation             string `json:"occupation"`
	MaritalStatus          string `json:"maritalStatus"`
	AnnualIncome           string `json:"annualincome"`
	TradingExposed         string `json:"tradingexposed"`
	EducationQualification string `json:"educationqualification"`
	PoliticallyExposed     string `json:"politicallyexposed"`
	Nominee                string `json:"nominee"`
}

type NomineeStruct struct {
	NomineeName             string `json:"nomineeName"`
	NomineeRelationship     string `json:"nomineeRelationship"`
	NomineeShare            string `json:"nomineeShare"`
	NomineeDOB              string `json:"nomineeDOB"`
	NomineeAddress1         string `json:"nomineeAddress1"`
	NomineeAddress2         string `json:"nomineeAddress2"`
	NomineeAddress3         string `json:"nomineeAddress3"`
	NomineeCity             string `json:"nomineeCity"`
	NomineeState            string `json:"nomineeState"`
	NomineeCountry          string `json:"nomineeCountry"`
	NomineePincode          string `json:"nomineePincode"`
	NomineeMobileNo         string `json:"nomineeMobileNo"`
	NomineeEmailId          string `json:"nomineeEmailId"`
	NomineeProofOfIdentity  string `json:"nomineeProofOfIdentity"`
	NomineeProofNumber      string `json:"nomineeProofNumber"`
	NomineeFileUploadDocId  string `json:"nomineeFileUploadDocId"`
	GuardianName            string `json:"guardianName"`
	GuardianRelationship    string `json:"guardianRelationship"`
	GuardianAddress1        string `json:"guardianAddress1"`
	GuardianAddress2        string `json:"guardianAddress2"`
	GuardianAddress3        string `json:"guardianAddress3"`
	GuardianCity            string `json:"guardianCity"`
	GuardianState           string `json:"guardianState"`
	GuardianCountry         string `json:"guardianCountry"`
	GuardianPincode         string `json:"guardianPincode"`
	GuardianMobileNo        string `json:"guardianMobileNo"`
	GuardianEmailId         string `json:"guardianEmailId"`
	GuardianProofOfIdentity string `json:"guardianProofOfIdentity"`
	GuardianProofNumber     string `json:"guardianProofNumber"`
	GuardianFileUploadDocId string `json:"guardianFileUploadDocId"`
	NomineeFileName         string `json:"nomineefilename"`
	GuardianFileName        string `json:"guardianfilename"`
}

type IpvStruct struct {
	IpvOtp     string `json:"ipvotp"`
	ImageDocId string `json:"imagedocid"`
	VideoDocId string `json:"videodocid"`
	Latitude   string `json:"latitude"`
	Longitude  string `json:"longitude"`
	TimeStamp  string `json:"timestamp"`
}

type ServicesStruct struct {
	Exc     string `json:"exc"`
	Segment string `json:"segment"`
	Status  string `json:"status"`
}

type DematAndServicesStruct struct {
	Services []ServicesStruct `json:"services"`
	DpScheme string           `json:"dpscheme"`
	DIS      string           `json:"dis"`
	EDIS     string           `json:"edis"`
}

type DataStruct struct {
	ID         string `json:"id"`
	Rowhead    string `json:"rowhead"`
	Colhead    string `json:"colhead"`
	Values     string `json:"values"`
	UserSelect string `json:"userselect"`
}

type SignedDocStruct struct {
	Unsigneddocid string `json:"unsigneddocid"`
	Esigneddocid  string `json:"esigneddocid"`
}

type Stage struct {
	BasicInfoRec        BasicInfoStruct        `json:"basicinfo"`
	AdrsRec             AddressStruct          `json:"address"`
	BankRec             BankDetailsStruct      `json:"bank"`
	PersonalRec         PersonalStruct         `json:"person"`
	NomineeArr          []NomineeStruct        `json:"nominearr"`
	IpvRec              IpvStruct              `json:"ipv"`
	DematAndServicesRec DematAndServicesStruct `json:"dematandservices"`
	SignedDocRec        SignedDocStruct        `json:"SignedDoc"`
	Status              string                 `json:"status"`
	ErrMsg              string                 `json:"err"`
}
