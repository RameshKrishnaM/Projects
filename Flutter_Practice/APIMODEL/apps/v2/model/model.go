package model

type PdfDataStruct struct {
	DocId   string `json:"DocId"`
	PdfFile string `json:"pdfFile"`
	ErrMsg  string `json:"errMsg"`
	Status  string `json:"status"`
}

type Attachments_Model struct {
	File  string `json:"file"`
	Title string `json:"title"`
}

// type GenerateBankPdfAtttachment struct {
// 	File  string `json:"file"`
// 	Title string `json:"title"`
// }

type GenerateBankPdfApiInput struct {
	CompanyName    string              `json:"CompanyName"`
	CompanyAddress string              `json:"CompanyAddress"`
	TradingCode    string              `json:"TradingCode"`
	Segment        string              `json:"Segment"`
	ClientName     string              `json:"ClientName"`
	Date           string              `json:"Date"`
	Particulars    string              `json:"Particulars"`
	Add_or_Modify  string              `json:"Add_or_Modify"`
	Existing_Bank  string              `json:"Existing_Bank"`
	New_Bank       string              `json:"New_Bank"`
	RequestId      string              `json:"RequestId"`
	ProcessType    string              `json:"ProcessType"`
	Attachments    []Attachments_Model `json:"Attachments"`
}

// type GenerateBankPdfApiInput struct {
// 	CompanyName    string                       `json:"CompanyName"`
// 	CompanyAddress string                       `json:"CompanyAddress"`
// 	TradingCode    string                       `json:"TradingCode"`
// 	Segment        string                       `json:"Segment"`
// 	ClientName     string                       `json:"ClientName"`
// 	Date           string                       `json:"Date"`
// 	Particulars    string                       `json:"Particulars"`
// 	Add_or_Modify  string                       `json:"Add_or_Modify"`
// 	Existing_Bank  string                       `json:"Existing_Bank"`
// 	New_Bank       string                       `json:"New_Bank"`
// 	RequestId      string                       `json:"RequestId"`
// 	ProcessType    string                       `json:"ProcessType"`
// 	Attachments    []GenerateBankPdfAtttachment `json:"Attachments"`
// }
type GenerateBankPdfUserInput struct {
	AccountNo string `json:"AccountNo"`
	Ifsc      string `json:"Ifsc"`
	Micr      string `json:"Micr"`
	Address   string `json:"Address"`
	RequestId string `json:"RequestId"`
	ClientId  string `json:"ClientId"`
}

type GenerateBankPdfApiResp struct {
	DocId     string `json:"DocId"`
	Status    string `json:"Status"`
	StatusMsg string `json:"StatusMsg"`
}

type GenerateBankPdfResp struct {
	DocId  string `json:"DocId"`
	Status string `json:"Status"`
	ErrMsg string `json:"ErrMsg"`
}

type XmlGeneration struct {
	NameToShowOnSignatureStamp     string `json:"NameToShowOnSignatureStamp"`
	LocationToShowOnSignatureStamp string `json:"LocationToShowOnSignatureStamp"`
	Reason                         string `json:"Reason"`
	DocId                          string `json:"DocId"`
	FilePath                       string `json:"FilePath"`
	HTMLEnabled                    bool   `json:"HTMLEnabled"`
	ProcessType                    string `json:"ProcessType"`
	RequestId                      string `json:"RequestId"`
	ClientId                       string `json:"Clientid"`
}
type XmlGenerationResp struct {
	XmlData string `json:"XmlData"`
	Status  string `json:"StatusMsg"`
	ErrMsg  string `json:"ErrMsg"`
}

// type FileDataType struct {
// 	DocId          string `json:"DocId"`
// 	FullFilePath   string `json:"FullFilePath"`
// 	ActualfileName string `json:"ActualfileName"`
// 	ParamName      string `json:"ParamName"`
// 	FileString     string `json:"FileString"`
// }

type PennydropInputstruct struct {
	AccountNo    string `json:"accountNo"`
	Ifsc         string `json:"ifsc"`
	BankName     string `json:"bankName"`
	ClientName   string `json:"name"`
	EmailId      string `json:"email"`
	ClientId     string `json:"clientId"`
	MobileNumber string `json:"mobileNumber"`
}

type NomineeData_Model struct {
	//DB Details
	NomineeID int64 `json:"NomineeID"`

	//For Show the File to Client------------
	//NomineeFileUploads multipart.File `json:"NomineeFileUploads"`
	//-------------------------------
	//Nominee Form Data
	NomineeTitle               string `json:"nomineetitle"`
	NomineeName                string `json:"nomineename"`
	NomineeRelationship        string `json:"nomineerelationship"`
	NomineeRelationshipdesc    string `json:"nomineerelationshipdesc"`
	NomineeShare               string `json:"nomineeshare"`
	NomineeDOB                 string `json:"nomineedob"`
	NomineeAddress1            string `json:"nomineeaddress1"`
	NomineeAddress2            string `json:"nomineeaddress2"`
	NomineeAddress3            string `json:"nomineeaddress3"`
	NomineeCity                string `json:"nomineecity"`
	NomineeState               string `json:"nomineestate"`
	NomineeCountry             string `json:"nomineecountry"`
	NomineePincode             string `json:"nomineepincode"`
	NomineeMobileNo            string `json:"nomineemobileno"`
	NomineeEmailId             string `json:"nomineeemailid"`
	NomineeProofOfIdentity     string `json:"nomineeproofofidentity"`
	NomineeProofOfIdentitydesc string `json:"nomineeproofofidentitydesc"`
	NomineeProofNumber         string `json:"nomineeproofnumber"`
	NomineePlaceofIssue        string `json:"nomineeplaceofissue"`
	NomineeProofDateofIssue    string `json:"nomineeproofdateofissue"`
	NomineeProofExpriyDate     string `json:"nomineeproofexpriydate"`
	NomineeFileUploadDocIds    string `json:"nomineefileuploaddocids"`
	NoimineeFilePath           string `json:"nomineefilepath"`
	NoimineeFileName           string `json:"nomineefilename"`
	NoimineeFileString         string `json:"nomineefilestring"`
	//Guardian Form Data
	GuardianVisible             bool   `json:"guardianvisible"`
	GuardianTitle               string `json:"guardiantitle"`
	GuardianName                string `json:"guardianname"`
	GuardianRelationship        string `json:"guardianrelationship"`
	GuardianRelationshipdesc    string `json:"guardianrelationshipdesc"`
	GuardianAddress1            string `json:"guardianaddress1"`
	GuardianAddress2            string `json:"guardianaddress2"`
	GuardianAddress3            string `json:"guardianaddress3"`
	GuardianCity                string `json:"guardiancity"`
	GuardianState               string `json:"guardianstate"`
	GuardianCountry             string `json:"guardiancountry"`
	GuardianPincode             string `json:"guardianpincode"`
	GuardianMobileNo            string `json:"guardianmobileno"`
	GuardianEmailId             string `json:"guardianemailid"`
	GuardianProofOfIdentity     string `json:"guardianproofofidentity"`
	GuardianProofOfIdentitydesc string `json:"guardianproofofidentitydesc"`
	GuardianProofNumber         string `json:"guardianproofnumber"`
	GuardianPlaceofIssue        string `json:"guardianplaceofissue"`
	GuardianProofDateofIssue    string `json:"guardianproofdateofissue"`
	GuardianProofExpriyDate     string `json:"guardianproofexpriydate"`
	GuardianFileUploadDocIds    string `json:"guardianfileuploaddocids"`
	GuardianFilePath            string `json:"guardianfilepath"`
	GuardianFileName            string `json:"guardianfilename"`
	GuardianFileString          string `json:"guardianfilestring"`
	//For Show the File to Client------------
	//GuardianFileUploads multipart.File `json:"GuardianFileUploads"`
	//-------------------------------

	//Common
	ModelState string `json:"ModelState"`
}
type KeyPairStruct struct {
	Key      string `json:"key"`
	FileType string `json:"filetype"`
	Value    string `json:"value"`
}

//Nominee API
type NomineeKYC_Model struct {
	CompanyName                        string `json:"CompanyName"`
	CompanyAddress                     string `json:"CompanyAddress"`
	Date                               string `json:"Date"`
	DPID                               string `json:"DPID"`
	ClientID                           string `json:"ClientId"`
	NomineeName1                       string `json:"NomineeName1"`
	NomineeAddress1                    string `json:"NomineeAddress1"`
	NomineeShare1                      string `json:"NomineeShare1"`
	NomineeRelationship1               string `json:"NomineeRelationship1"`
	NomineePincode1                    string `json:"NomineePincode1"`
	NomineeMobileNo1                   string `json:"NomineeMobileNo1"`
	NomineeEmailID1                    string `json:"NomineeEmailId1"`
	NomineeIdentificationDocs1         string `json:"NomineeIdentificationDocs1"`
	NomineeDOB1                        string `json:"NomineeDOB1"`
	NomineeGuardiansName1              string `json:"NomineeGuardiansName1"`
	NomineeGuardiansAddress1           string `json:"NomineeGuardiansAddress1"`
	NomineeGuardianMobile1             string `json:"NomineeGuardianMobile1"`
	NomineeGuardianEmailID1            string `json:"NomineeGuardianEmailId1"`
	NomineeGuardianReleationship1      string `json:"NomineeGuardianReleationship1"`
	NomineeGuardianIdentificationDocs1 string `json:"NomineeGuardianIdentificationDocs1"`
	NomineeName2                       string `json:"NomineeName2"`
	NomineeAddress2                    string `json:"NomineeAddress2"`
	NomineeShare2                      string `json:"NomineeShare2"`
	NomineeRelationship2               string `json:"NomineeRelationship2"`
	NomineePincode2                    string `json:"NomineePincode2"`
	NomineeMobileNo2                   string `json:"NomineeMobileNo2"`
	NomineeEmailID2                    string `json:"NomineeEmailId2"`
	NomineeIdentificationDocs2         string `json:"NomineeIdentificationDocs2"`
	NomineeDOB2                        string `json:"NomineeDOB2"`
	NomineeGuardiansName2              string `json:"NomineeGuardiansName2"`
	NomineeGuardiansAddress2           string `json:"NomineeGuardiansAddress2"`
	NomineeGuardianMobile2             string `json:"NomineeGuardianMobile2"`
	NomineeGuardianEmailID2            string `json:"NomineeGuardianEmailId2"`
	NomineeGuardianReleationship2      string `json:"NomineeGuardianReleationship2"`
	NomineeGuardianIdentificationDocs2 string `json:"NomineeGuardianIdentificationDocs2"`
	NomineeName3                       string `json:"NomineeName3"`
	NomineeAddress3                    string `json:"NomineeAddress3"`
	NomineeShare3                      string `json:"NomineeShare3"`
	NomineeRelationship3               string `json:"NomineeRelationship3"`
	NomineePincode3                    string `json:"NomineePincode3"`
	NomineeMobileNo3                   string `json:"NomineeMobileNo3"`
	NomineeEmailID3                    string `json:"NomineeEmailId3"`
	NomineeIdentificationDocs3         string `json:"NomineeIdentificationDocs3"`
	NomineeDOB3                        string `json:"NomineeDOB3"`
	NomineeGuardiansName3              string `json:"NomineeGuardiansName3"`
	NomineeGuardiansAddress3           string `json:"NomineeGuardiansAddress3"`
	NomineeGuardianMobile3             string `json:"NomineeGuardianMobile3"`
	NomineeGuardianEmailID3            string `json:"NomineeGuardianEmailId3"`
	NomineeGuardianReleationship3      string `json:"NomineeGuardianReleationship3"`
	NomineeGuardianIdentificationDocs3 string `json:"NomineeGuardianIdentificationDocs3"`
	NomineeGuardianPincode1            string `json:"NomineeGuardianPincode1"`
	NomineeGuardianPincode2            string `json:"NomineeGuardianPincode2"`
	NomineeGuardianPincode3            string `json:"NomineeGuardianPincode3"`
	FirstHolder                        string `json:"FirstHolder"`
	SecondHolder                       string `json:"SecondHolder"`
	ThirdHolder                        string `json:"ThirdHolder"`
	RequestID                          string `json:"RequestId"`
	ProcessType                        string `json:"ProcessType"`

	Attachments []Attachments_Model `json:"Attachments"`
	//Attachments []Attachments_Model `json:"Attachments"`
}

type HtmlModel struct {
	Otp      string
	HtmlPath string
	Subject  string
	EmailId  string
}
