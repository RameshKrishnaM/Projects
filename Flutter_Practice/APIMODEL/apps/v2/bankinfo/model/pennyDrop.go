package model

var (
	ContactType = "customer"
	AccountType = "bank_account"
)

type BankDetails struct {
	ClientId      string
	LoggedBy      string
	Name          string
	Email         string
	Phone         string
	IFSC          string
	AccountNo     string
	BankName      string
	OriginalSysId int
	OriginalSys   string
}

// ============================= Create Contact ===================================

// ========================= Request Struct for Service ===========================

// CreateContactReqStruct holds the value of req structure for a Create contact API.
type CreateContactReqStruct struct {
	ClientId     string `json:"clientId"`
	Token        string `json:"token"`
	Name         string `json:"name"`
	Email        string `json:"email"`
	Phone        string `json:"phone"`
	Type         string `json:"type"`
	Reference_Id string `json:"referenceId"`
	Source       string `json:"source"`
}

// ========================= Response Struct for Service ===========================

// CreateContactResp represents the response structure for a Create Contact Request.
type CreateContactResp struct {
	Status string          `json:"status"`
	Data   ContactResponse `json:"data"`
	ErrMsg string          `json:"errMsg"`
}

// ContactResponse represents the response structure for a Create contact .
type ContactResponse struct {
	Id           string   `json:"id"`
	Entity       string   `json:"entity"`
	Name         string   `json:"name"`
	Contact      string   `json:"contact"`
	Email        string   `json:"email"`
	Type         string   `json:"type"`
	Reference_Id string   `json:"reference_id"`
	Batch_Id     string   `json:"batch_id"`
	Active       bool     `json:"active"`
	Notes        NotesKey `json:"notes"`
	Created_At   int      `json:"created_at"`
}

// =================================================================================

// ============================== Create Fund ======================================

// ========================= Request Struct for Service ============================

// FundAccountReqStruct represent the request structure for Create Fund Account
type FundAccountReqStruct struct {
	ClientId   string                `json:"clientId"`
	Token      string                `json:"token"`
	BankData   FundBankDataReqStruct `json:"bank_account"`
	Contact_Id string                `json:"contact_id"`
	Source     string                `json:"source"`
}

type FundBankDataReqStruct struct {
	Name      string `json:"name" validate:"required"`
	IFSC      string `json:"ifsc" validate:"required"`
	AccountNo string `json:"account_number" validate:"required"`
}

// ========================= Response Struct for Service ===========================

// CreateFundAccResp represents the response structure for a Create Fund Account Request.
type CreateFundAccResp struct {
	Status string          `json:"status"`
	Data   FundAccountResp `json:"data"`
	ErrMsg string          `json:"errMsg"`
}

// FundAccountResp represents the response structure for a Create Fund Account .
type FundAccountResp struct {
	Id           string          `json:"id"`
	Entity       string          `json:"entity"`
	Contact_Id   string          `json:"contact_id"`
	Account_Type string          `json:"account_type"`
	Bank_Account FundBankAccount `json:"bank_account"`
	Active       bool            `json:"active"`
	Batch_Id     string          `json:"batch_id"`
	Created_At   int             `json:"created_at"`
}

type FundBankAccount struct {
	Ifsc           string     `json:"ifsc"`
	Bank_Name      string     `json:"bank_name"`
	Name           string     `json:"name"`
	Account_Number string     `json:"account_number"`
	Notes          []NotesKey `json:"notes"`
}

// =================================================================================

// =========================== Valdation Request ===================================

// ========================= Request Struct for Service ============================

// ValidationReqStruct represents the request structure for a Validation Bank Account.
type ValidationReqStruct struct {
	ClientId              string `json:"clientId"`
	Token                 string `json:"token"`
	LastInsertedContactId string `json:"lastInsertedContactId"`
	FundAccountId         string `json:"fundAccountId"`
	Source                string `json:"source"`
}

// ========================= Response Struct for Service ===========================

// ValidationResp represents the response structure for a Penny Drop Validation request.
type ValidationResp struct {
	Status string             `json:"status"`
	Data   BankValidationResp `json:"data"`
	ErrMsg string             `json:"errMsg"`
}

// BankValidationResp represents the response structure for a Validate Bank Account .
type BankValidationResp struct {
	Id           string                      `json:"id"`
	Entity       string                      `json:"entity"`
	Fund_Account FundAccountValidationStruct `json:"fund_account"`
	Status       string                      `json:"status"`
	Amount       int                         `json:"amount"`
	Currency     string                      `json:"currency"`
	Notes        NotesKey                    `json:"notes"`
	Results      ResultStruct                `json:"results"`
	Created_At   int                         `json:"created_at"`
	Utr          string                      `json:"utr"`
}

type FundAccountValidationStruct struct {
	Id           string                      `json:"id"`
	Entity       string                      `json:"entity"`
	Contact_Id   string                      `json:"contact_id"`
	Account_Type string                      `json:"account_type"`
	Bank_Account BankAccountValidationStruct `json:"bank_account"`
	Batch_Id     string                      `json:"batch_id"`
	Active       bool                        `json:"active"`
	Created_At   int                         `json:"created_at"`
}

type BankAccountValidationStruct struct {
	Name           string `json:"name"`
	Bank_Name      string `json:"bank_name"`
	Ifsc           string `json:"ifsc"`
	Account_Number string `json:"account_number"`
}

type ResultStruct struct {
	Account_Status string `json:"account_status"`
	Register_Name  string `json:"registered_name"`
}

// =================================================================================

// ========================= Valdation Status Request ==============================

// ========================= Request Struct for Service ============================

// ValidateStatusReqStruct represents the request structure for a validation Status.
type ValidateStatusReqStruct struct {
	ClientId   string `json:"clientId"`
	Token      string `json:"token"`
	ValidateId string `json:"validateId"`
	Source     string `json:"source"`
}

// ========================= Response Struct for Service ===========================

// =========================== Request Struct for API ==============================

// =================================================================================

// ================ Create Contact / Create Fund / Bank Validation Resp & Req =================
type NotesKey struct {
	Notes_Key_1 string `json:"notes_key_1"`
	Notes_Key_2 string `json:"notes_key_2"`
}

// =================================================================================

// PennyDropResp represents the response structure for a Penny Drop Validation request.
type PennyDropRespStruct struct {
	Status  string            `json:"status"`
	Data    PennyDropRespData `json:"data"`
	ErrCode string            `json:"errorCode"`
	ErrMsg  string            `json:"errorMsg"`
}

type PennyDropRespData struct {
	IsCompleted     string
	ValidateId      string
	PennyDropStatus string
	RegisterName    string
	AccountStatus   string
}
