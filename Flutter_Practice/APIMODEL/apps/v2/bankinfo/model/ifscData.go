package model

// =================================================================================

// ==============================  Get IFSC Data ===================================

// ========================= Request Struct for Service ============================

// IfscDataReqStruct represent the request structure for Get Bank Detials Using Ifsc
type IfscDataReqStruct struct {
	ClientId string `json:"clientId"`
	Token    string `json:"token"`
	IFSCCode string `json:"ifscCode"`
	Source   string `json:"source"`
}

// ========================= Response Struct for Service ===========================

// IfscDataReqStruct represent the request structure for Get Bank Detials Using Ifsc
type IfscResponseStruct struct {
	Status string   `json:"status"`
	Data   IfscData `json:"data"`
	ErrMsg string   `json:"errMsg"`
}

type IfscData struct {
	MICR    string `json:"micr"`
	BRANCH  string `json:"branch"`
	ADDRESS string `json:"address"`
	STATE   string `json:"state"`
	BANK    string `json:"bank"`
	Status  string `json:"status"`
	Success string `json:"success"`
	ErrMsg  string `json:"errmsg"`
}

// =================================================================================
