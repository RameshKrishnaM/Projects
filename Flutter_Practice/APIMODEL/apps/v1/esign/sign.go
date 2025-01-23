package esign

import (
	"encoding/json"
	"errors"
	update "fcs23pkg/apps/v1/commonpackage"
	"fcs23pkg/common"
	"fcs23pkg/file"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/integrationsign"
	"fcs23pkg/tomlconfig"
	"fmt"
	"log"
	"net/http"
	"regexp"
	"strconv"
	"strings"
	"time"
)

type StampDocGeneration struct {
	NameToShowOnSignatureStamp     string `json:"NameToShowOnSignatureStamp"`
	LocationToShowOnSignatureStamp string `json:"LocationToShowOnSignatureStamp"`
	Reason                         string `json:"Reason"`
	DocId                          int    `json:"DocId"`
	FilePath                       string `json:"FilePath"`
	SignedXMLData                  string `json:"SignedXMLData"`
	ProcessType                    string `json:"ProcessType"`
	RequestId                      string `json:"RequestId"`
	ReqId                          string `json:"ReqId"`
}
type StampDocGenerationResp struct {
	DocId     string `json:"DocId"`
	Status    string `json:"Status"`
	StatusMsg string `json:"StatusMsg"`
}

func EsignDocument(w http.ResponseWriter, r *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	(w).Header().Set("Access-Control-Allow-Origin", "*")
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	w.WriteHeader(200)
	lDebug.Log(helpers.Statement, "EsignDocument (+) ")
	if r.Method == "POST" {
		w.WriteHeader(200)
		w.Header().Set("Content-Type", "text/html")
		_, lErr := ProcessEsignDocument(r, lDebug, w)
		lHtmlRespData := ""
		if lErr != nil {
			lDebug.Log(helpers.Elog, "SED01", lErr.Error())

			lHtmlRespData, lErr = common.HtmlFileToString("./html/StampError.html")
			if lErr != nil {
				lDebug.Log(helpers.Elog, "SED02", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("SED02", "Something went wrong please try after sometime... "))
				return
			}
		} else {
			// w.WriteHeader(200)
			// w.Header().Set("Content-Type", "text/html")
			lHtmlRespData, lErr = common.HtmlFileToString("./html/StampSuccess.html")
			if lErr != nil {
				lDebug.Log(helpers.Elog, "SED03", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("SED03", "Something went wrong please try after sometime... "))
				return

			}

		}
		fmt.Fprint(w, lHtmlRespData)

	}
	lDebug.Log(helpers.Statement, "EsignDocument (-) ")
}

func IframeLoader(w http.ResponseWriter, r *http.Request) {

	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	(w).Header().Set("Access-Control-Allow-Origin", "*")
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	w.WriteHeader(200)
	lDebug.Log(helpers.Statement, "IframeLoader (+) ")
	if r.Method == "GET" {
		htmlData, lErr := common.HtmlFileToString("./html/IframeLoader.html")
		if lErr != nil {
			fmt.Fprint(w, helpers.GetError_String("SED01", "Something went wrong please try after sometime... "))

		} else {
			w.Header().Set("Content-Type", "text/html")
			fmt.Fprint(w, htmlData)
		}
	}
	lDebug.Log(helpers.Statement, "IframeLoader (-) ")
}

// func ProcessEsignDocument(r *http.Request, pDebug *helpers.HelperStruct, w http.ResponseWriter) (string, error) {
// 	pDebug.Log(helpers.Statement, "ProcessEsignDocument (+)")

// 	lFileBody := r.FormValue("msg")
// 	// lFileBody = ReplaceRedirectURL(lFileBody, "response", pDebug)
// 	htmlData := ""
// 	lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
// 	if lErr != nil {
// 		return "", helpers.ErrReturn(lErr)
// 	} else {
// 		defer lDb.Close()

// 		lTxnId := GetTxnIdFromBody(lFileBody, pDebug)
// 		_, lRequestId, lErr := GenerateReqIDandTxnID(lTxnId, "Uid", pDebug)
// 		if lErr != nil {
// 			return "", helpers.ErrReturn(lErr)
// 		} else {
// 			if lRequestId != "" {
// 				if lErr != nil {
// 					return "", helpers.ErrReturn(lErr)
// 				} else {
// 					lIsSigned, lErr := checkIsDocumentSigned(lDb, lRequestId, pDebug)
// 					if lErr != nil {
// 						return "", helpers.ErrReturn(lErr)
// 					} else {
// 						if lIsSigned == "N" {
// 							StampResp, lErr := InitiateStampingProcess(lRequestId, lFileBody, pDebug, r)
// 							// fmt.Println(StampResp.DocId, "StampResp.DocId")
// 							if lErr != nil {
// 								return "", helpers.ErrReturn(lErr)
// 							} else {
// 								if StampResp.DocId != "" {
// 									StampResp.Status = common.SuccessCode
// 									if StampResp.Status == "S" {
// 										// Sid, _, lErr := sessionid.GetOldSessionUID(r, pDebug, common.EKYCCookieName)
// 										// if lErr != nil {
// 										// 	pDebug.Log(helpers.Elog, lErr.Error())
// 										// }
// 										lErr = update.UpdateDocID(pDebug, "ESignedDocId", StampResp.DocId, lRequestId, "")
// 										if lErr != nil {
// 											return "", helpers.ErrReturn(lErr)
// 											// } else { // var emailDetails emailUtil.clientdetails
// 											// 	// emailDetails.
// 											// 	// 	SendEmail()

// 											// 	lErr := clientCom.ClientIntimation(db, RequestId, r)
// 											// 	if lErr != nil {
// 											// 		helpers.ErrReturn(lErr)
// 											// 	} else {
// 											// 		//  returns success html when the Signing document Api is success
// 											// 		htmlData, lErr = common.HtmlFileToString("./html/StampSucess.html")
// 											// 		if lErr != nil {
// 											// 			helpers.ErrReturn(lErr)
// 											// 		}

// 											// 	}

// 											// }else{

// 										}
// 									}
// 								} else {
// 									//  returns error html when the document id is empty
// 									htmlData, lErr = common.HtmlFileToString("./html/StampError.html")
// 									if lErr != nil {
// 										return "", helpers.ErrReturn(lErr)
// 									}
// 								}
// 							}
// 						} else {
// 							// fmt.Fprint(w, helpers.GetError_String("E", "File already existed"))
// 							htmlData, lErr = common.HtmlFileToString("./html/StampSuccess.html")
// 							if lErr != nil {
// 								return "", helpers.ErrReturn(lErr)
// 							}
// 						}
// 					}
// 				}
// 			}
// 		}
// 	}
// 	return htmlData, nil
// }

func ProcessEsignDocument(r *http.Request, pDebug *helpers.HelperStruct, w http.ResponseWriter) (string, error) {
	pDebug.Log(helpers.Statement, "ProcessEsignDocument (+)")

	lFileBody := r.FormValue("msg")
	// lFileBody = ReplaceRedirectURL(lFileBody, "response", pDebug)
	// htmlData := ""e

	lTxnId := GetTxnIdFromBody(lFileBody, pDebug)
	_, lRequestId, lErr := GenerateReqIDandTxnID(lTxnId, "Uid", pDebug)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	}
	if lRequestId != "" {
		lIsSigned, lErr := checkIsDocumentSigned(lRequestId, pDebug)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
		if lIsSigned == "N" {
			StampResp, lErr := InitiateStampingProcess(lRequestId, lFileBody, pDebug, r)
			// fmt.Println(StampResp.DocId, "StampResp.DocId")
			if lErr != nil {
				return "", helpers.ErrReturn(lErr)
			}
			pDebug.Log(helpers.Details, StampResp, "StampResp")
			if StampResp.DocId != "" && StampResp.Status == "Success" {
				StampResp.Status = common.SuccessCode

				lErr = update.UpdateDocID(pDebug, "ESignedDocId", StampResp.DocId, lRequestId, "")
				if lErr != nil {
					return "", helpers.ErrReturn(lErr)
				}

			} else {
				//  returns error html when the document id is empty
				return "", helpers.ErrReturn(errors.New(StampResp.StatusMsg))
				// htmlData, lErr = common.HtmlFileToString("./html/StampError.html")
				// if lErr != nil {
				// 	return "", helpers.ErrReturn(lErr)
				// }
			}
		} else {
			return "", nil
		}
		// 	} else {
		// 		// fmt.Fprint(w, helpers.GetError_String("E", "File already existed"))
		// 		htmlData, lErr = common.HtmlFileToString("./html/StampSuccess.html")
		// 		if lErr != nil {
		// 			return "", helpers.ErrReturn(lErr)
		// 		}
		// 	}

		// }

	}
	pDebug.Log(helpers.Statement, "ProcessEsignDocument(-)")
	return "", nil
}

func GetTxnIdFromBody(pFileBody string, pDebug *helpers.HelperStruct) string {
	pDebug.Log(helpers.Statement, "GetTxnIdFromBody (+)")
	STR1 := strings.Split(pFileBody, "txn=")
	//log.Println(STR1[0])
	STR2 := strings.Split(STR1[1], ">")
	//log.Println(STR2[0])
	STR3 := strings.Split(STR2[0], ":")
	//log.Println(STR3)
	// STR4 := STR3[2]
	// STR5 := (STR4[0 : len(STR4)-1])
	var STR5 string
	if len(STR3) >= 3 {
		STR4 := STR3[2]
		STR5 = STR4[0 : len(STR4)-1]
		// Rest of your code
	} else {
		// Handle the case where STR3 doesn't have enough elements
		pDebug.Log(helpers.Elog, "Not enough elements in STR3")
		// You might want to return an error or handle it accordingly
	}

	STR6 := strings.Split(STR5, "_")[0]
	pDebug.Log(helpers.Statement, "GetTxnIdFromBody (-)")
	return STR6
}

func checkIsDocumentSigned(pRequestId string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "checkIsDocumentSigned (+)")

	var lSignedStatus string

	coreString := `select (case when nvl(er.eSignedDocid, '') = '' then 'N' else 'Y' end) SignedStatus 
	from ekyc_request er 
	where er.Uid = ?`

	rows, lErr := ftdb.NewEkyc_GDB.Query(coreString, pRequestId)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	} else {
		defer rows.Close()
		for rows.Next() {
			lErr := rows.Scan(&lSignedStatus)

			if lErr != nil {
				return "", helpers.ErrReturn(lErr)
			}

		}

	}
	pDebug.Log(helpers.Statement, "checkIsDocumentSigned (-)")
	return lSignedStatus, nil

}
func InitiateStampingProcess(pRequestId string, pFileBody string, pDebug *helpers.HelperStruct, r *http.Request) (StampDocGenerationResp, error) {
	pDebug.Log(helpers.Statement, "InitiateStampingProcess (+)")
	var StampResp StampDocGenerationResp

	stampDetails_Json_str, lErr := ConstructStampReq(pRequestId, pFileBody, pDebug)
	if lErr != nil {
		return StampResp, helpers.ErrReturn(lErr)
	} else {
		pDebug.Log(helpers.Details, "stampDetails_Json_str: ", stampDetails_Json_str)
		EsignStampProcessType := tomlconfig.GtomlConfigLoader.GetValueString("kycintegrationconfig", "EsignStampProcessType")
		respBody, lErr := integrationsign.Api_call_processed_data(EsignStampProcessType, stampDetails_Json_str, pDebug, r)
		if lErr != nil {
			return StampResp, helpers.ErrReturn(lErr)
		} else {
			pDebug.Log(helpers.Details, "StampApiResp: ", respBody)
			lErr := json.Unmarshal([]byte(respBody), &StampResp)
			if lErr != nil {
				return StampResp, helpers.ErrReturn(lErr)
			}

		}

	}
	pDebug.Log(helpers.Statement, "InitiateStampingProcess (-)")
	return StampResp, nil
}
func ConstructStampReq(pRequestId string, pFileBody string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "ConstructStampReq (+)")
	var stampDetails StampDocGeneration
	var stampDetails_Json_str, lUsername string

	lAddress, lErr := GetAddress(pRequestId, pDebug)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	} else {
		if lAddress == "" {
			return "", helpers.ErrReturn(errors.New("address missing"))
		}
	}
	_, unsigndocid, lUsername, lErr := GetRequestInfo(pRequestId, pDebug)

	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	} else {
		stampDetails.NameToShowOnSignatureStamp = lUsername
		stampDetails.LocationToShowOnSignatureStamp = lAddress
		stampDetails.FilePath, _, lErr = file.GetFilePath(unsigndocid)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		} else {
			stampDetails.DocId, _ = strconv.Atoi(unsigndocid)
			txnId, _, lErr := GenerateReqIDandTxnID(pRequestId, "txnid", pDebug)
			if lErr != nil {
				return "", helpers.ErrReturn(lErr)
			}
			stampDetails.RequestId = "flattrade:esign:" + txnId
			// stampDetails.ReqId = "7293"
			stampDetails.SignedXMLData = common.EncodeToString(pFileBody)
			stampDetails.Reason = tomlconfig.GtomlConfigLoader.GetValueString("kycintegrationconfig", "EsignXMLReason")
			stampDetails.ProcessType = tomlconfig.GtomlConfigLoader.GetValueString("kycintegrationconfig", "ESIGNProcessType")
			//stampDetails.SignedXMLData = ""
			stampDetails_Json, lErr := json.Marshal(stampDetails)
			if lErr != nil {
				return "", helpers.ErrReturn(lErr)
			} else {
				stampDetails_Json_str = string(stampDetails_Json)
			}
		}
	}
	pDebug.Log(helpers.Statement, "ConstructStampReq (-)")
	return stampDetails_Json_str, nil

}
func GetRequestInfo(pRequestId string, pDebug *helpers.HelperStruct) (string, string, string, error) {
	pDebug.Log(helpers.Statement, "GetRequestInfo (+)")
	var lClientId, lUnsigndocid, lUserName string

	// var Uid string
	lCorestring := `select nvl(er.Client_Id,""),nvl(er.unsignedDocid,""),nvl(Name_As_Per_Pan,"")
	from ekyc_request er where er.Uid =?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return "", "", "", helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lClientId, &lUnsigndocid, &lUserName)
			if lErr != nil {
				return "", "", "", helpers.ErrReturn(lErr)
			}
		}
	}

	pDebug.Log(helpers.Statement, "GetRequestInfo(-)")
	return lClientId, lUnsigndocid, lUserName, nil
}
func GetAddress(pRequestId string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "GetAddress (+)")

	var lCurrentAddress string

	lCorestring := `select nvl(Current_Address,"")
	from ekyc_ipv where Request_Uid =?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lCurrentAddress)
			if lErr != nil {
				return "", helpers.ErrReturn(lErr)
			}
		}
	}
	pDebug.Log(helpers.Statement, "GetAddress (-)")
	return lCurrentAddress, nil
}
func GenerateReqIDandTxnID(pInput, ptype string, pDebug *helpers.HelperStruct) (string, string, error) {
	pDebug.Log(helpers.Statement, "GetRequestInfo (+)")
	var lTxnID, lUid string

	// var Uid string
	if strings.ToLower(ptype) == "txnid" {
		lCorestring := `select nvl(er.id,"") from ekyc_request er where er.Uid =?`
		lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pInput)
		if lErr != nil {
			return "", "", helpers.ErrReturn(lErr)
		} else {
			defer lRows.Close()
			for lRows.Next() {
				lErr := lRows.Scan(&lTxnID)
				if lErr != nil {
					return "", "", helpers.ErrReturn(lErr)
				}

			}
			unixTime := time.Now().Unix()
			lTxnID = lTxnID + "_" + strconv.FormatInt(unixTime, 10)

		}
	} else {
		lCorestring := `select nvl(er.Uid,"") from ekyc_request er where er.id =?`
		lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pInput)
		if lErr != nil {
			return "", "", helpers.ErrReturn(lErr)
		} else {
			defer lRows.Close()
			for lRows.Next() {
				lErr := lRows.Scan(&lUid)
				if lErr != nil {
					return "", "", helpers.ErrReturn(lErr)
				}

			}
		}
	}

	pDebug.Log(helpers.Statement, "GetRequestInfo(-)")
	return lTxnID, lUid, nil
}

func ReplaceRedirectURL(pFileBody, pType string, pDebug *helpers.HelperStruct) string {
	pDebug.Log(helpers.Statement, "ReplaceRedirectURL (+)")
	var localRedirectURL string

	if strings.ToLower(pType) == "request" {
		localRedirectURL = tomlconfig.GtomlConfigLoader.GetValueString("kycutilconfig", "localRedirectURL")
	} else {
		localRedirectURL = tomlconfig.GtomlConfigLoader.GetValueString("kycutilconfig", "serverRedirectURL")
	}
	re := regexp.MustCompile(`responseUrl="([^"]+)"`)
	pFileBody = re.ReplaceAllString(pFileBody, `responseUrl="`+localRedirectURL+`"`)
	log.Println("filebody", pFileBody)
	pDebug.Log(helpers.Statement, "ReplaceRedirectURL (-)")
	return pFileBody
}
