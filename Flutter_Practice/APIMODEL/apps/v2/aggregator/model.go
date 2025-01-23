package aggregator

// UserInfoReqStruct is used to hold user information for making a consent request.
type UserInfoReqStruct struct {
	MobileNumber      string `json:"mobileno"`
	BankName          string `json:"bankname"`
	AccountID         string `json:"accountId"`
	MaskAccount       string `json:"maskaccount"`
	AlterMobileNumber string `json:"altermobileno"`
	ConsentHandle     string `json:"consenthandle"`
}

// ReqConsentRespStruct represents the response structure for a consent request.
type ReqConsentRespStruct struct {
	Status  string     `json:"status"`
	Data    DataStruct `json:"data"`
	ErrCode string     `json:"errorCode"`
	ErrMsg  string     `json:"errorMsg"`
}

// DataStruct holds the data of the consent request response.
type DataStruct struct {
	ConsentHandleId string `json:"consent_handle"`
	Status          string `json:"status"`
}

// PDFDownloadReqStruct is used for downloading a statement in PDF format.
type PDFDownloadReqStruct struct {
	ConsentID     string   `json:"consentID"`
	LinkRefNumber []string `json:"linkRefNumber"`
}

// ResponseConsentList represents the response structure for the decrypted URL list.
type ResponseConsentList struct {
	Status  string          `json:"status"`
	Ver     string          `json:"ver"`
	DataArr []ConsentStruct `json:"data"`
	ErrCode string          `json:"errorCode"`
	ErrMsg  string          `json:"errorMsg"`
}

// ConsentStruct represents the details of a consent in the response list.
type ConsentStruct struct {
	ConsentID           string              `json:"consentID"`
	ConsentHandle       string              `json:"consentHandle"`
	Status              string              `json:"status"`
	ProductID           string              `json:"productID"`
	AccountID           string              `json:"accountID"`
	AaID                string              `json:"aaID"`
	Vua                 string              `json:"vua"`
	ConsentCreationDate string              `json:"consentCreationDate"`
	AccountsArr         []BankAccountStruct `json:"accounts"`
}

// BankAccountStruct represents the bank account details associated with a consent.
type BankAccountStruct struct {
	FipName             string `json:"fipName"`
	FipID               string `json:"fipID"`
	AccountType         string `json:"accountType"`
	LinkReferenceNumber string `json:"linkReferenceNumber"`
	MaskedAccount       string `json:"maskedAccountNumber"`
}

// DecryptUrlRequest is used to get the consent status via a decrypted URL.
type DecryptUrlRequest struct {
	WebRedirectionURL WebRedirectionURLStruct `json:"webRedirectionURL"`
}

// WebRedirectionURLStruct holds the details of the web redirection URL.
type WebRedirectionURLStruct struct {
	Ecres   string `json:"ecres"`
	Resdate string `json:"resdate"`
	Fi      string `json:"fi"`
}

// AAStatementRespStruct represents the response structure for the statement request.
type AAStatementRespStruct struct {
	ErrCode string `json:"errorCode"`
	ErrMsg  string `json:"errorMsg"`
	Status  string `json:"status"`
	Msg     string `json:"msg"`
}

// GetAllLatestFiDataStruct is used to retrieve all latest financial information based on the consent ID.
type GetAllLatestFiDataStruct struct {
	ConsentID string `json:"consentID"`
	// UniqueRecord  []MatchFields `json:"matchFields"`
	// ReturnAllData bool          `json:"returnAllData"`
}
type MatchFields struct {
	FieldName  string `json:"fieldName"`
	FieldValue string `json:"fieldValue"`
	Criteria   string `json:"criteria"`
}

// DecryptUrlRespStruct represents the response structure for the decrypted URL.

type DecryptUrlRespStruct struct {
	Ver     string      `json:"ver"`
	Status  string      `json:"status"`
	Data    DecryptData `json:"data"`
	Message string      `json:"message"`
	ErrCode string      `json:"errorCode"`
	ErrMsg  string      `json:"errorMsg"`
}

// DecryptData represents the data field within the decrypted URL response.
type DecryptData struct {
	Status    string `json:"status"`
	ErrorCode string `json:"errorcode"`
	TxnID     string `json:"txnid"`
	SessionID string `json:"sessionid"`
	SrcRef    string `json:"srcref"`
	UserID    string `json:"userid"`
	Redirect  string `json:"redirect"`
}
type WebRedirectUrlRespStruct struct {
	Status  string `json:"status"`
	WebUrl  string `json:"weburl"`
	ErrCode string `json:"errorCode"`
	ErrMsg  string `json:"errorMsg"`
}

// WebRedirectUrlRespStruct represents the response structure for a web redirection request.
type WebRedirectStruct struct {
	Ver     string          `json:"ver"`
	Status  string          `json:"status"`
	Data    EncrptUrlStruct `json:"data"`
	Message string          `json:"message"`
	ErrCode string          `json:"errorCode"`
	ErrMsg  string          `json:"errorMsg"`
}

// Define the FIP structure representing each FIP in the response
type FIPStruct struct {
	FIPID   string `json:"fipId"`
	FIPName string `json:"fipName"`
	// FiTypes []string `json:"FiTypes"`
}

// Define the Data structure representing the nested data in the response
type ListFipDataStruct struct {
	FIPNewListArr []FIPStruct `json:"fip_newlist"`
}

// Define the GetListFipIDResponse structure representing the entire response
type GetListFipIDRespStruct struct {
	Ver     string            `json:"ver"`
	Status  string            `json:"status"`
	Data    ListFipDataStruct `json:"data"`
	Message string            `json:"message"`
}

type EncrptUrlStruct struct {
	WebRedirectionUrl string `json:"webRedirectionUrl"`
}

type AAJsonResponseStruct struct {
	Ver     string             `json:"ver"`
	Status  string             `json:"status"`
	Data    []AAJsonDataStruct `json:"data"`
	Message string             `json:"message"`
}

type AAJsonDataStruct struct {
	LinkReferenceNumber string               `json:"linkReferenceNumber"`
	MaskedAccountNumber string               `json:"maskedAccountNumber"`
	FiType              string               `json:"fiType"`
	Bank                string               `json:"bank"`
	Summary             AASummaryStruct      `json:"Summary"`
	Profile             AAProfileStruct      `json:"Profile"`
	Transactions        AATransactionsStruct `json:"Transactions"`
}

type AASummaryStruct struct {
	CurrentBalance  string            `json:"currentBalance"`
	Currency        string            `json:"currency"`
	ExchangeRate    string            `json:"exchgeRate"`
	BalanceDateTime string            `json:"balanceDateTime"`
	Type            string            `json:"type"`
	Branch          string            `json:"branch"`
	Facility        string            `json:"facility"`
	IfscCode        string            `json:"ifscCode"`
	MicrCode        string            `json:"micrCode"`
	OpeningDate     string            `json:"openingDate"`
	CurrentODLimit  string            `json:"currentODLimit"`
	DrawingLimit    string            `json:"drawingLimit"`
	Status          string            `json:"status"`
	Pending         []AAPendingStruct `json:"Pending"`
}

type AAPendingStruct struct {
	Amount          float64 `json:"amount"`
	TransactionType string  `json:"transactionType"`
}

// AAProfileStruct represents the profile information of the account holder.
type AAProfileStruct struct {
	Holders AAHolderStruct `json:"Holders"`
}

type AAHolderStruct struct {
	Type   string                  `json:"type"`
	Holder []AAHolderDetailsStruct `json:"Holder"`
}

type AAHolderDetailsStruct struct {
	Name           string `json:"name"`
	Dob            string `json:"dob"`
	Mobile         string `json:"mobile"`
	Nominee        string `json:"nominee"`
	Landline       string `json:"landline"`
	Address        string `json:"address"`
	Email          string `json:"email"`
	Pan            string `json:"pan"`
	CkycCompliance string `json:"ckycCompliance"`
}

type AATransactionsStruct struct {
	StartDate   string                `json:"startDate"`
	EndDate     string                `json:"endDate"`
	Transaction []AATransactionStruct `json:"Transaction"`
}

type AATransactionStruct struct {
	Type                 string `json:"type"`
	Mode                 string `json:"mode"`
	Amount               string `json:"amount"`
	CurrentBalance       string `json:"currentBalance"`
	TransactionTimestamp string `json:"transactionTimestamp"`
	ValueDate            string `json:"valueDate"`
	TxnId                string `json:"txnId"`
	Narration            string `json:"narration"`
	Reference            string `json:"reference"`
}
type AAUserBankInfoStruct struct {
	UserName            string
	MobileNumber        string
	Bank                string
	DOB                 string
	Email               string
	Pan                 string
	Address             string
	BankCkycStatus      string
	BankAccountStatus   string
	AccountType         string
	TransStartDate      string
	TransEndDate        string
	StatementStatus     string
	PdfDocID            string
	JsonDocID           string
	TransError          string
	TransErrorStatus    string
	LinkReferenceNumber string
}
type AAValidationStruct struct {
	ConsentID       string `json:"consentid"`
	DocID           string `json:"docid"`
	ProofType       string `json:"prooftype"`
	Status          string `json:"status"`
	ConsentHandleID string `json:"consenthandle"`
	TestUser        string `json:"testuser"`
}

//Account Aggregator Service Request and Response Structure

//consent Request structure
type UserConsentReqStruct struct {
	MobileNumber      string `json:"mobileno"`
	BankName          string `json:"bankname"`
	AlterMobileNumber string `json:"altermobileno"`
	UID               string `json:"uid"`
	ClientId          string `json:"client_Id"`
	Token             string `json:"token"`
	Source            string `json:"source"`
	RedirectURL       string `json:"redirectURL"`
}

//consent request return response structure
type ConsentUrlRespStruct struct {
	Status        string `json:"status"`
	WebUrl        string `json:"weburl"`
	ConsentHandle string `json:"consenthandle"`
	ErrCode       string `json:"errorCode"`
	ErrMsg        string `json:"errorMsg"`
	FipID         string `json:"fipid"`
}

//Check Status in consent when approved or reject based on return url request structure
type ConsentStatusRequest struct {
	WebRedirectionURL WebRedirectionURLStruct `json:"webRedirectionURL"` // Validate nested struct
	ClientId          string                  `json:"client_Id"`
	Token             string                  `json:"token"`
	Source            string                  `json:"source"`
}

//Fetch Statement request strcutrue in service
type UserFiFetchReqStruct struct {
	MobileNumber  string `json:"mobileno"`
	BankName      string `json:"bankname"`
	MaskAccount   string `json:"maskaccount"`
	ConsentHandle string `json:"consenthandle"`
	UID           string `json:"uid"`
	ClientId      string `json:"client_Id"`
	Token         string `json:"token"`
	Source        string `json:"source"`
}

//Fetch statement service Response Struct
type StatementRespStruct struct {
	PDFEncode  string `json:"pdfencode"`
	JSONEncode string `json:"jsonencode"`
	ConsentID  string `json:"consentid"`
	ErrCode    string `json:"errorCode"`
	ErrMsg     string `json:"errorMsg"`
	Status     string `json:"status"`
}
