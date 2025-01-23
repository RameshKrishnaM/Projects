package pennydrop

import (
	"encoding/json"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"fmt"
	"log"
	"strconv"
	"time"
)

var (
	ContactType = "customer"
	ContactURL  = "https://api.razorpay.com/v1/contacts"
	// ContactURL  = "https://api.razorpay20.com/v1/contacts"
	AccountType = "bank_account"
	FundURL     = "https://api.razorpay.com/v1/fund_accounts"
	ValidateURL = "https://api.razorpay.com/v1/fund_accounts/validations/"

	// ValidateURL = "https://api.razorpay20.com/v1/fund_accounts/validations/"
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

type ValidationResp struct {
	IsCompleted     string
	ValidateId      string
	PennyDropStatus string
	RegisterName    string
	AccountStatus   string
}

// func PennyDrop(w http.ResponseWriter, r *http.Request) {
// 	log.Println("SmsMessage call received")
// 	(w).Header().Set("Access-Control-Allow-Origin", "*")
// 	(w).Header().Set("Access-Control-Allow-Methods", "PUT")
// 	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

// 	w.WriteHeader(200)

// 	var input BankDetails

// 	input.Name = "Sowmya"
// 	input.ClientId = "FT000069"
// 	input.Email = "sowmya@flattrade.in"
// 	input.Phone = "9840985445"
// 	input.IFSC = "UTIB0000622"
// 	input.AccountNo = "910010029856643"
// 	input.BankName = "AXIS Bank"

// 	resp, err := PennyDropValidation(input)
// 	log.Println(err)

// 	data, err := json.Marshal(resp)
// 	if err != nil {
// 		fmt.Fprintf(w, "Error taking data"+err.Error())
// 	} else {
// 		fmt.Fprintf(w, string(data))
// 	}

// }

func PennyDropValidation(bankInput BankDetails) (ValidationResp, error) {
	log.Println("PennyDropValidation+")

	var resp ValidationResp

	LastInsertedContactId, ContactId, err := CreateContact(bankInput)
	if err != nil {
		common.LogError("pennydrop.PennyDropValidation", "(PPDV02)", err.Error())
		return resp, err
	} else {
		log.Println("LastInsertedContactId: ", LastInsertedContactId)
		log.Println("ContactId: ", ContactId)
		LastInsertedFundId, fundAccountId, err := CreateFundAccount(LastInsertedContactId, ContactId, bankInput)
		if err != nil {
			common.LogError("pennydrop.PennyDropValidation", "(PPDV03)", err.Error())
			return resp, err
		} else {
			log.Println("LastInsertedFundId: ", LastInsertedFundId)
			log.Println("fundAccountId: ", fundAccountId)
			validation, isCompleted, err := ValidateBankAccount(bankInput, fundAccountId, LastInsertedFundId, LastInsertedContactId)
			if err != nil {
				common.LogError("pennydrop.PennyDropValidation", "(PPDV04)", err.Error())
				return resp, err
			} else {
				log.Println("validation", validation)
				log.Println("validation.Results.Account_Status", validation.Results.Account_Status)
				log.Println("validation.Status", validation.Status)
				resp.PennyDropStatus = validation.Status
				resp.RegisterName = validation.Results.Register_Name
				resp.ValidateId = validation.Id
				resp.IsCompleted = isCompleted
				resp.AccountStatus = validation.Results.Account_Status
			}
		}

	}

	log.Println("PennyDropValidation-")
	return resp, nil

}

type ContactInput struct {
	Name         string   `json:"name"`
	Email        string   `json:"email"`
	Contact      string   `json:"contact"`
	Type         string   `json:"type"`
	Reference_Id string   `json:"reference_id"`
	Notes        NotesKey `json:"notes"`
}

type NotesKey struct {
	Notes_Key_1 string `json:"notes_key_1"`
	Notes_Key_2 string `json:"notes_key_2"`
}

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

func CreateContact(bankInput BankDetails) (string, string, error) {
	log.Println("CreateContact+")
	lDebug := new(helpers.HelperStruct)
	lDebug.Init()
	var contactRec ContactInput
	var ContactResp ContactResponse

	var header apiUtil.HeaderDetails
	var headerArr []apiUtil.HeaderDetails

	var LastInsertedContactId string
	var contactId string

	contactRec.Name = bankInput.Name
	contactRec.Email = bankInput.Email
	contactRec.Contact = bankInput.Phone
	contactRec.Type = ContactType
	contactRec.Reference_Id = bankInput.ClientId
	// contactRec.OriginalSys = bankInput.OriginalSys
	// contactRec.OriginalSysId = bankInput.OriginalSysId

	reqJson, err := json.Marshal(contactRec)
	if err != nil {
		common.LogError("pennydrop.CreateContact", "(PCC01)", err.Error())
		return LastInsertedContactId, contactId, err
	} else {
		reqJson_Str := string(reqJson)
		LastInsertedContactId, err = InsertContactLog(contactRec, reqJson_Str, bankInput)
		if err != nil {
			common.LogError("pennydrop.CreateContact", "(PCC02)", err.Error())
			return LastInsertedContactId, contactId, err
		} else {

			header.Key = "Content-Type"
			header.Value = "application/json; charset=UTF-8"
			headerArr = append(headerArr, header)
			header.Key = "Authorization"
			header.Value = tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "HeaderAuthoKey")
			headerArr = append(headerArr, header)

			contactResp_Json_Str, err := apiUtil.Api_call(lDebug, ContactURL, "POST", reqJson_Str, headerArr, "pennydrop.CreateContact")
			if err != nil {
				common.LogError("pennydrop.CreateContact", "(PCC03)", err.Error())
				return LastInsertedContactId, contactId, err
			} else {
				err := json.Unmarshal([]byte(contactResp_Json_Str), &ContactResp)
				if err != nil {
					common.LogError("pennydrop.CreateContact", "(PCC04)", err.Error())
					return LastInsertedContactId, contactId, err
				} else {
					log.Println("Contact Api Response: ", contactResp_Json_Str)
					err := UpdateContactLog(ContactResp, LastInsertedContactId, contactResp_Json_Str, bankInput.LoggedBy)
					if err != nil {
						common.LogError("pennydrop.CreateContact", "(PCC05)", err.Error())
						return LastInsertedContactId, contactId, err
					} else {
						if ContactResp.Active {
							contactId = ContactResp.Id
						} else {
							return LastInsertedContactId, contactId, fmt.Errorf("Error in contact creation")
						}
					}

				}
			}
		}
	}
	log.Println("CreateContact-")
	return LastInsertedContactId, contactId, nil

}

func InsertContactLog(contactRec ContactInput, reqJson string, bankInput BankDetails) (string, error) {
	log.Println("InsertContactLog+")

	var contactId string

	coreString := `insert into xx_contact_log(ReqJson,ReferenceId,Name,Email,PhoneNo,OriginalSys, OriginalSysId,
		           CreatedBy,CreatedDate,updatedBy,updatedDate)
	               values(?,?,?,?,?,?,?,?,now(),?,now())`

	insertRes, err := ftdb.MariaEKYCPRD_GDB.Exec(coreString, reqJson, contactRec.Reference_Id, contactRec.Name, contactRec.Email, contactRec.Contact,
		bankInput.OriginalSys, bankInput.OriginalSysId, bankInput.LoggedBy, bankInput.LoggedBy)

	if err != nil {
		common.LogError("pennydrop.InsertContactLog", "(PICL01)", err.Error())
		return contactId, err
	} else {

		returnId, _ := insertRes.LastInsertId()

		contactId = strconv.FormatInt(returnId, 10)

		log.Println("Contact Id: ", contactId)

		log.Println("inserted successfully")

	}

	log.Println("InsertContactLog-")
	// return insertedID, nil
	return contactId, nil
}

func UpdateContactLog(contactRec ContactResponse, contactId string, RespJson string, LoggedBy string) error {
	log.Println("UpdateContactLog+")

	coreString := `update xx_contact_log set RespJson=?, ContactId=?, CreatedAt=?, updatedBy=?, updatedDate=now()
	                where id = ?`

	_, err := ftdb.MariaEKYCPRD_GDB.Exec(coreString, RespJson, contactRec.Id, contactRec.Created_At, LoggedBy, contactId)

	if err != nil {
		common.LogError("pennydrop.UpdateContactLog", "(PUCL01)", err.Error())
		return err
	} else {

		log.Println("Updated successfully")

	}

	log.Println("UpdateContactLog-")
	// return insertedID, nil
	return nil
}

type fundAccountInput struct {
	Contact_Id   string `json:"contact_id"`
	Account_Type string `json:"account_type"`
	BankAccount  struct {
		Name           string `json:"name"`
		Ifsc           string `json:"ifsc"`
		Account_Number string `json:"account_number"`
	} `json:"bank_account"`
}

type fundAccountResp struct {
	Id           string `json:"id"`
	Entity       string `json:"entity"`
	Contact_Id   string `json:"contact_id"`
	Account_Type string `json:"account_type"`
	Bank_Account struct {
		Ifsc           string     `json:"ifsc"`
		Bank_Name      string     `json:"bank_name"`
		Name           string     `json:"name"`
		Account_Number string     `json:"account_number"`
		Notes          []NotesKey `json:"notes"`
	} `json:"bank_account"`
	Active     bool   `json:"active"`
	Batch_Id   string `json:"batch_id"`
	Created_At int    `json:"created_at"`
}

func CreateFundAccount(LastInsertedContactId string, ContactId string, bankInput BankDetails) (string, string, error) {
	log.Println("CreateFundAccount+")
	lDebug := new(helpers.HelperStruct)
	lDebug.Init()
	var fundRec fundAccountInput
	var fundResp fundAccountResp

	var header apiUtil.HeaderDetails
	var headerArr []apiUtil.HeaderDetails

	var LastInsertedFundId string
	var FundAccountId string

	fundRec.Contact_Id = ContactId
	fundRec.Account_Type = AccountType
	fundRec.BankAccount.Name = bankInput.Name
	fundRec.BankAccount.Ifsc = bankInput.IFSC
	fundRec.BankAccount.Account_Number = bankInput.AccountNo

	reqJson, err := json.Marshal(fundRec)
	if err != nil {
		common.LogError("pennydrop.CreateFundAccount", "(PCFA01)", err.Error())
		return LastInsertedFundId, FundAccountId, err
	} else {
		reqJson_Str := string(reqJson)
		LastInsertedFundId, err = InsertFundAccountLog(fundRec, reqJson_Str, bankInput.LoggedBy, LastInsertedContactId)
		if err != nil {
			common.LogError("pennydrop.CreateFundAccount", "(PCFA02)", err.Error())
			return LastInsertedFundId, FundAccountId, err
		} else {

			header.Key = "Content-Type"
			header.Value = "application/json; charset=UTF-8"
			headerArr = append(headerArr, header)
			header.Key = "Authorization"
			header.Value = tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "HeaderAuthoKey")
			headerArr = append(headerArr, header)

			log.Println("Fund Account Req Json: ", reqJson_Str)
			FundResp_Json_Str, err := apiUtil.Api_call(lDebug, FundURL, "POST", reqJson_Str, headerArr, "pennydrop.CreateFundAccount")
			if err != nil {
				common.LogError("pennydrop.CreateFundAccount", "(PCFA03)", err.Error())
				return LastInsertedFundId, FundAccountId, err
			} else {
				err := json.Unmarshal([]byte(FundResp_Json_Str), &fundResp)
				if err != nil {
					common.LogError("pennydrop.CreateFundAccount", "(PCFA04)", err.Error())
					return LastInsertedFundId, FundAccountId, err
				} else {
					log.Println("Fund Account Api Response: ", FundResp_Json_Str)
					err := UpdateFundAccountLog(fundResp, LastInsertedFundId, FundResp_Json_Str, bankInput.LoggedBy)
					if err != nil {
						common.LogError("pennydrop.CreateFundAccount", "(PCFA05)", err.Error())
						return LastInsertedFundId, FundAccountId, err
					} else {
						if fundResp.Active {
							FundAccountId = fundResp.Id
						} else {
							return LastInsertedFundId, FundAccountId, fmt.Errorf("error in Api response")
						}
					}
				}
			}

		}

	}
	log.Println("CreateFundAccount-")
	return LastInsertedFundId, FundAccountId, nil
}

func InsertFundAccountLog(fundRec fundAccountInput, reqJson string, LoggedBy string, LastInsertedContactId string) (string, error) {
	log.Println("InsertFundAccountLog+")

	var fundId string

	coreString := `insert into xx_fundAccount_log(ReqJson,ContactId,ifsc,accountNo,bankName,CreatedBy,CreatedDate,updatedBy,updatedDate)
	values(?,?,?,?,?,?,now(),?,now())`

	insertRes, err := ftdb.MariaEKYCPRD_GDB.Exec(coreString, reqJson, LastInsertedContactId, fundRec.BankAccount.Ifsc, fundRec.BankAccount.Account_Number,
		fundRec.BankAccount.Name, LoggedBy, LoggedBy)

	if err != nil {
		common.LogError("pennydrop.InsertFundAccountLog", "(PIFL01)", err.Error())
		return fundId, err
	} else {
		returnId, _ := insertRes.LastInsertId()

		fundId = strconv.FormatInt(returnId, 10)

		log.Println("inserted successfully")

	}

	log.Println("InsertFundAccountLog-")
	// return insertedID, nil
	return fundId, nil
}

func UpdateFundAccountLog(fundRec fundAccountResp, LastInsertedFundId string, RespJson string, LoggedBy string) error {
	log.Println("UpdateFundAccountLog+")

	coreString := `update xx_fundAccount_log set RespJson=?, fundAccountId=?, CreatedAt=?, updatedBy=?, updatedDate=now()
	                where id = ?`

	_, err := ftdb.MariaEKYCPRD_GDB.Exec(coreString, RespJson, fundRec.Id, fundRec.Created_At, LoggedBy, LastInsertedFundId)

	if err != nil {
		common.LogError("pennydrop.UpdateFundAccountLog", "(PUFL01)", err.Error())
		return err
	} else {

		log.Println("Updated successfully")

	}

	log.Println("UpdateFundAccountLog-")
	// return insertedID, nil
	return nil
}

type bankValidationInput struct {
	Account_Number string `json:"account_number"`
	Fund_Account   struct {
		Id string `json:"id"`
	} `json:"fund_account"`
	Amount  int      `json:"amount"`
	Curency string   `json:"currency"`
	Notes   NotesKey `json:"notes"`
}

type bankValidationResp struct {
	Id           string `json:"id"`
	Entity       string `json:"entity"`
	Fund_Account struct {
		Id           string `json:"id"`
		Entity       string `json:"entity"`
		Contact_Id   string `json:"contact_id"`
		Account_Type string `json:"account_type"`
		Bank_Account struct {
			Name           string `json:"name"`
			Bank_Name      string `json:"bank_name"`
			Ifsc           string `json:"ifsc"`
			Account_Number string `json:"account_number"`
		} `json:"bank_account"`
		Batch_Id   string `json:"batch_id"`
		Active     bool   `json:"active"`
		Created_At int    `json:"created_at"`
	} `json:"fund_account"`
	Status   string   `json:"status"`
	Amount   int      `json:"amount"`
	Currency string   `json:"currency"`
	Notes    NotesKey `json:"notes"`
	Results  struct {
		Account_Status string `json:"account_status"`
		Register_Name  string `json:"registered_name"`
	} `json:"results"`
	Created_At int    `json:"created_at"`
	Utr        string `json:"utr"`
}

func ValidateBankAccount(bankInput BankDetails, fundAccountId string, LastInsertedFundId string, LastInsertedContactId string) (bankValidationResp, string, error) {
	log.Println("ValidateBankAccount+")
	lDebug := new(helpers.HelperStruct)
	lDebug.Init()
	var validationRec bankValidationInput
	var ValidationResp bankValidationResp
	var IsCompleted string

	var header apiUtil.HeaderDetails
	var headerArr []apiUtil.HeaderDetails

	validationRec.Account_Number = tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "ValidateAccNo")
	validationRec.Fund_Account.Id = fundAccountId
	validationRec.Amount, _ = strconv.Atoi(tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "ValidateAmt"))
	validationRec.Curency = tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "ValidateCurrency")
	validationRec.Notes.Notes_Key_1 = LastInsertedContactId
	validationRec.Notes.Notes_Key_2 = ""

	reqJson, err := json.Marshal(validationRec)
	if err != nil {
		common.LogError("pennydrop.ValidateBankAccount", "(PVBA01)", err.Error())
		return ValidationResp, IsCompleted, err
	} else {
		reqJson_Str := string(reqJson)
		validateBankAccountId, err := InsertValidationLog(LastInsertedFundId, reqJson_Str, bankInput.LoggedBy)
		if err != nil {
			common.LogError("pennydrop.ValidateBankAccount", "(PVBA02)", err.Error())
			return ValidationResp, IsCompleted, err
		} else {
			header.Key = "Content-Type"
			header.Value = "application/json; charset=UTF-8"
			headerArr = append(headerArr, header)
			header.Key = "Authorization"
			header.Value = tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "HeaderAuthoKey")
			headerArr = append(headerArr, header)

			ValidationResp_Json_Str, err := apiUtil.Api_call(lDebug, ValidateURL, "POST", reqJson_Str, headerArr, "pennydrop.ValidateBankAccount")
			if err != nil {
				common.LogError("pennydrop.ValidateBankAccount", "(PVBA03)", err.Error())
				return ValidationResp, IsCompleted, err
			} else {
				log.Println("Validation Api Response: ", ValidationResp_Json_Str)
				err := json.Unmarshal([]byte(ValidationResp_Json_Str), &ValidationResp)
				if err != nil {
					common.LogError("pennydrop.ValidateBankAccount", "(PVBA04)", err.Error())
					return ValidationResp, IsCompleted, err
				} else {
					err := UpdateValidationLog(ValidationResp, validateBankAccountId, ValidationResp_Json_Str, bankInput.LoggedBy)
					if err != nil {
						common.LogError("pennydrop.ValidateBankAccount", "(PVBA05)", err.Error())
						return ValidationResp, IsCompleted, err
					} else {
						if ValidationResp.Status != "failed" {
							IsCompleted, err = ChkValidationCmpt(ValidationResp.Notes.Notes_Key_1)
							if err != nil {
								common.LogError("pennydrop.ValidateBankAccount", "(PVBA06)", err.Error())
								return ValidationResp, IsCompleted, err
							} else {

							}
							//

						} else {
							return ValidationResp, IsCompleted, fmt.Errorf("Error in validation")
						}
					}
				}

			}
		}
	}
	log.Println("ValidateBankAccount-")
	return ValidationResp, IsCompleted, nil

}

func InsertValidationLog(LastInsertedFundId string, reqJson_Str string, LoggedBy string) (string, error) {
	log.Println("InsertValidationLog+")

	log.Println(LastInsertedFundId)

	var validateBankAccountId string

	coreString := `insert into xx_validateBankAccount_log(ReqJson,fundAccountId,CreatedBy,CreatedDate,updatedBy,updatedDate)
	values(?,?,?,now(),?,now())`

	insertRes, err := ftdb.MariaEKYCPRD_GDB.Exec(coreString, reqJson_Str, LastInsertedFundId, LoggedBy, LoggedBy)

	if err != nil {
		common.LogError("pennydrop.InsertValidationLog", "(PIVL01)", err.Error())
		return validateBankAccountId, err
	} else {

		returnId, _ := insertRes.LastInsertId()

		validateBankAccountId = strconv.FormatInt(returnId, 10)

		log.Println("validateBankAccountId Id: ", validateBankAccountId)

		log.Println("inserted successfully")

	}

	log.Println("InsertValidationLog-")
	// return insertedID, nil
	return validateBankAccountId, nil
}

func UpdateValidationLog(resp bankValidationResp, Id string, respJson string, LoggedBy string) error {
	log.Println("UpdateValidationLog+")

	coreString := `update xx_validateBankAccount_log set RespJson=?, status=?, Account_status=?, registered_name=?,
	 CreatedAt=?, validate_Id=?, utr=?, updatedBy=?, updatedDate=now()
	                where id = ?`

	_, err := ftdb.MariaEKYCPRD_GDB.Exec(coreString, respJson, resp.Status, resp.Results.Account_Status, resp.Results.Register_Name,
		resp.Created_At, resp.Id, resp.Utr, LoggedBy, Id)

	if err != nil {
		common.LogError("pennydrop.UpdateValidationLog", "(PUVL01)", err.Error())
		return err
	} else {

		log.Println("Updated successfully")

	}

	log.Println("UpdateValidationLog-")
	// return insertedID, nil
	return nil
}

func ChkValidationCmpt(ContactId string) (string, error) {
	log.Println("ChkValidationCmpt+")

	time.Sleep(5 * time.Second)
	isCompleted, err := checkStatusIsCompleted(ContactId)
	if err != nil {
		common.LogError("pennydrop.ChkValidationCmpt", "(PGVS01)", err.Error())
		return isCompleted, err
	} else {
		if isCompleted == "N" {
			time.Sleep(5 * time.Second)
			isCompleted, err := checkStatusIsCompleted(ContactId)
			if err != nil {
				common.LogError("pennydrop.ChkValidationCmpt", "(PGVS02)", err.Error())
				return isCompleted, err
			}
		}

	}
	log.Println("ChkValidationCmpt-")

	return isCompleted, nil

}

func checkStatusIsCompleted(ContactId string) (string, error) {
	log.Println("checkStatusIsCompleted+")

	var isCompleted string

	coreString := `
	select  (case when vl.status = 'completed' then 'Y' else 'N' end ) isCompleted
from xx_contact_log cl, xx_fundAccount_log fl, xx_validateBankAccount_log vl
where cl.id  = fl.ContactId
and fl.id = vl.fundAccountId
and cl.id = ?`

	rows, err := ftdb.MariaEKYCPRD_GDB.Query(coreString, ContactId)
	if err != nil {
		common.LogError("pennydrop.checkStatusIsCompleted", "(PCSC01)", err.Error())
		return isCompleted, err
	} else {
		defer rows.Close()
		for rows.Next() {
			err := rows.Scan(&isCompleted)

			if err != nil {
				common.LogError("pennydrop.checkStatusIsCompleted", "(PCSC02)", err.Error())
				return isCompleted, err
			}
		}

	}
	log.Println("checkStatusIsCompleted-")
	return isCompleted, nil
}

type ValidateStatusResp struct {
	ID          string `json:"id"`
	Entity      string `json:"entity"`
	FundAccount struct {
		ID          string `json:"id"`
		Entity      string `json:"entity"`
		ContactID   string `json:"contact_id"`
		AccountType string `json:"account_type"`
		BankAccount struct {
			Name          string `json:"name"`
			BankName      string `json:"bank_name"`
			Ifsc          string `json:"ifsc"`
			AccountNumber string `json:"account_number"`
		} `json:"bank_account"`
		BatchID   interface{} `json:"batch_id"`
		Active    bool        `json:"active"`
		CreatedAt int         `json:"created_at"`
	} `json:"fund_account"`
	Status   string `json:"status"`
	Amount   int    `json:"amount"`
	Currency string `json:"currency"`
	Notes    struct {
		RandomKey1 string `json:"random_key_1"`
		RandomKey2 string `json:"random_key_2"`
	} `json:"notes"`
	Results struct {
		AccountStatus  string `json:"account_status"`
		RegisteredName string `json:"registered_name"`
	} `json:"results"`
	CreatedAt int    `json:"created_at"`
	Utr       string `json:"utr"`
}

func GetValidationStatus(LoggedBy string, ValidateId string, LastInsertedFundId string, ReqId string) (ValidateStatusResp, error) {
	log.Println("GetValidationStatus+")
	lDebug := new(helpers.HelperStruct)
	lDebug.Init()
	var ValidationResp ValidateStatusResp

	var header apiUtil.HeaderDetails
	var headerArr []apiUtil.HeaderDetails

	validateBankAccountId, err := InsertValidationLog(LastInsertedFundId, "", LoggedBy)
	if err != nil {
		common.LogError("pennydrop.GetValidationStatus", "(PGVS01)", err.Error())
		return ValidationResp, err
	} else {
		header.Key = "Content-Type"
		header.Value = "application/json; charset=UTF-8"
		headerArr = append(headerArr, header)
		header.Key = "Authorization"
		header.Value = tomlconfig.GtomlConfigLoader.GetValueString("pennydropconfig", "HeaderAuthoKey")
		headerArr = append(headerArr, header)

		URL := ValidateURL + ValidateId
		log.Println("URL: ", ValidateURL)
		ValidationResp_Json_Str, err := apiUtil.Api_call(lDebug, URL, "GET", "", headerArr, "pennydrop.GetValidationStatus")
		if err != nil {
			common.LogError("pennydrop.GetValidationStatus", "(PGVS02)", err.Error())
			return ValidationResp, err
		} else {
			log.Println("Validation Api Response: ", ValidationResp_Json_Str)
			err := json.Unmarshal([]byte(ValidationResp_Json_Str), &ValidationResp)
			if err != nil {
				common.LogError("pennydrop.GetValidationStatus", "(PGVS03)", err.Error())
				return ValidationResp, err
			} else {
				err := UpdateValidationLog2(ValidationResp, validateBankAccountId, ValidationResp_Json_Str, LoggedBy)
				if err != nil {
					common.LogError("pennydrop.GetValidationStatus", "(PGVS04)", err.Error())
					return ValidationResp, err
				} else {
					err := UptNewBankAddition(ValidationResp, LoggedBy, ReqId)
					if err != nil {
						common.LogError("pennydrop.UpdateValidationLog2", "(PUVL2_02)", err.Error())
						return ValidationResp, err
					}
				}
			}

		}
	}

	log.Println("GetValidationStatus-")
	return ValidationResp, nil

}

func UpdateValidationLog2(resp ValidateStatusResp, Id string, respJson string, LoggedBy string) error {
	log.Println("UpdateValidationLog2+")

	coreString := `update xx_validateBankAccount_log set RespJson=?, status=?, Account_status=?, registered_name=?,
	 CreatedAt=?, validate_Id=?, utr=?, updatedBy=?, updatedDate=now()
	                where id = ?`

	_, err := ftdb.MariaEKYCPRD_GDB.Exec(coreString, respJson, resp.Status, resp.Results.AccountStatus, resp.Results.RegisteredName,
		resp.CreatedAt, resp.ID, resp.Utr, LoggedBy, Id)

	if err != nil {
		common.LogError("pennydrop.UpdateValidationLog2", "(PUVL2_01)", err.Error())
		return err
	} else {

		log.Println("Updated successfully")

	}

	log.Println("UpdateValidationLog2-")
	// return insertedID, nil
	return nil
}

func UptNewBankAddition(resp ValidateStatusResp, LoggedBy string, reqId string) error {
	log.Println("UptNewBankAddition+")

	coreString := `update new_bank_addition set PennyDropAccountHolderName=?, PennyDropStatus=?, PennyDropAccStatus=?, updatedBy=?, updatedDate=now()
	                where RequestId = ?`

	_, err := ftdb.MariaEKYCPRD_GDB.Exec(coreString, resp.Results.RegisteredName, resp.Status, resp.Results.AccountStatus, LoggedBy, reqId)

	if err != nil {
		common.LogError("pennydrop.UptNewBankAddition", "(PNBA2_01)", err.Error())
		return err
	} else {

		log.Println("Updated successfully")

	}

	log.Println("UptNewBankAddition-")
	// return insertedID, nil
	return nil
}
