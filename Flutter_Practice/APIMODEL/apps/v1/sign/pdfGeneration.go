package sign

import (
	"encoding/json"
	"fcs23pkg/apps/v1/nominee"
	"fcs23pkg/apps/v1/sessionid"

	//"fcs23pkg/apps/v1/wall/myaccount/request"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

type PdfResp struct {
	RequestId string `json:"requestId"`
	DocId     string `json:"docId"`
	ErrMsg    string `json:"errMsg"`
	Status    string `json:"status"`
}

type KycApiResponse struct {
	DocId     string `json:"DocId"`
	Status    string `json:"Status"`
	StatusMsg string `json:"StatusMsg"`
}

// Api to generate nominee pdf
func PdfGeneration(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "PostNomineeFile (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "  PUT, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
	w.WriteHeader(200)

	log.Println("PdfGeneration+", r.Method)

	if r.Method == "PUT" {

		//var nomineeReq nomineePdfRequest
		var pdfResp PdfResp

		pdfResp.Status = common.SuccessCode

		//client, err := appsso.ValidateAndGetClientDetails2(r, common.WallAppName, common.WallCookieName)
		_, Uid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			common.LogError("sign.PdfGeneration", Uid+":(SPG01)", lErr.Error())
			//log.Println(err)
			pdfResp.Status = common.LoginFailure
		} else {
			if Uid != "" {

				//clientId := common.GetSetClient(Uid)
				//LoggedBy := common.GetLoggedBy(client)

				//log.Println("ClientId", clientId)
				//log.Println("LoggedBy", LoggedBy)

				pdfResp.DocId, pdfResp.RequestId, lErr = ProcessToGetPdf(r, Uid, lDebug)
				if lErr != nil {
					common.LogError("sign.PdfGeneration", Uid+":(SPG02)", lErr.Error())
					//log.Println(err)
					pdfResp.Status = common.ErrorCode
					pdfResp.ErrMsg = "UnExpectedError:" + lErr.Error() + "(SPG02)"

				} else {
					if pdfResp.DocId == "" || pdfResp.RequestId == "" {
						common.LogError("sign.PdfGeneration", Uid+":(SPG03)", "ERROR")
						pdfResp.Status = common.ErrorCode
						pdfResp.ErrMsg = "UnExpectedError:(SPG03)"
					}
				}
			}

			data, err := json.Marshal(pdfResp)
			if err != nil {
				fmt.Fprint(w, "Error taking data"+err.Error())
			} else {
				fmt.Fprint(w, string(data))
			}

		}
		//log.Println("PdfGeneration-", r.Method)
		lDebug.Log(helpers.Statement, "PostNomineeFile (-)")

	}
}

func ProcessToGetPdf(r *http.Request, clientId string, pDebug *helpers.HelperStruct) (string, string, error) {
	log.Println("ProcessToGetPdf+")

	var docId string
	var requestId string

	var KycApiResponse KycApiResponse

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		common.LogError("sign.ProcessToGetPdf", "(SPGF01)", err.Error())
		return docId, requestId, err
	} else {
		//log.Println(string(body))
		//log.Println(string(body))
		ProcessTypeCode := string(body)[1:2]
		//log.Println("ProcessTypeCode: ", ProcessTypeCode)
		requestId = string(body)[2 : len(string(body))-1]
		log.Println("requestId: ", requestId)

		//convert the input json into a structure variable
		processType, KYC_Json_Str, err := ContDataForPdfGeneration(requestId, ProcessTypeCode, clientId, pDebug)
		if err != nil {
			common.LogError("sign.ProcessToGetPdf", "(SPGF02)", err.Error())
			return docId, requestId, err
		} else {
			log.Println("Pdf Generation Req Json: ", KYC_Json_Str)
			KycApiResponseBody, err := Api_call_processed_data(processType, KYC_Json_Str, pDebug)
			if err != nil {
				common.LogError("sign.ProcessToGetPdf", "(SPGF03)", err.Error())
				return docId, requestId, err
			} else {
				log.Println("KycApiResponseBody", KycApiResponseBody)
				err := json.Unmarshal([]byte(KycApiResponseBody), &KycApiResponse)
				if err != nil {
					common.LogError("sign.ProcessToGetPdf", "(SPGF04)", err.Error())
					return docId, requestId, err
				} else {
					log.Println("Pdf Generation Response Json: ", KycApiResponse)
					if KycApiResponse.Status == "Success" {
						docId = KycApiResponse.DocId
						log.Println("Generated pdf DocId: ", docId)
						// err := request.UpdateRequestwithDocId("S", docId, requestId)
						// if err != nil {
						// 	common.LogError("sign.ProcessToGetPdf", "(SPGF05)", err.Error())
						// 	return docId, requestId, err
						// }

					} else {
						return docId, requestId, fmt.Errorf(KycApiResponse.StatusMsg)
					}
				}

			}

		}
	}
	//}

	//}
	//}
	//}
	log.Println("ProcessToGetPdf-")
	return docId, requestId, nil
}

//------------------------------------------
// fetch the bankdetails from table
// for a given Requestid.
//-------------------------------------------
func ContDataForPdfGeneration(requestId string, ProcessTypeCode string, clientId string, pDebug *helpers.HelperStruct) (string, string, error) {
	log.Println("ContDataForPdfGeneration(+)")
	var KYC_Json_Str string
	var processType string

	lRequestTableId, err := nominee.GetRequestTableId(requestId, pDebug)
	if err != nil {
		common.LogError("sign.ContDataForPdfGeneration", "(CDPG02)", err.Error())
		return processType, KYC_Json_Str, err
	} else {

		if ProcessTypeCode == "N" {
			NomineeCollection, err := GetNomineeDataForPdf(requestId)
			log.Println("NomineeCollection", NomineeCollection)
			if err != nil {
				common.LogError("sign.ContDataForPdfGeneration", "(CDPG03)", err.Error())
				return processType, KYC_Json_Str, err
			} else {
				if len(NomineeCollection) > 0 {
					log.Println("if len(NomineeCollection) > 0")
					processType = common.NomineeProcessType
					log.Println(processType)
					KYC_Json_Str, err = ConstructNomineeDetails(NomineeCollection, clientId, lRequestTableId)
					if err != nil {
						common.LogError("sign.ContDataForPdfGeneration", "(CDPG04)", err.Error())
						return processType, KYC_Json_Str, err
					}
					//  else {
					// 	//log.Println("NomineeKYC_Json_Str(NJS): ", KYC_Json_Str)
					// }
				}
				//}
			}
			// } else if ProcessTypeCode == "B" {
			// 	BankCollection, err := GetBankDataForPdf(requestId)
			// 	if err != nil {
			// 		common.LogError("sign.ContDataForPdfGeneration", "(CDPG04)", err.Error())
			// 		return processType, KYC_Json_Str, err
			// 	} else {
			// 		// if len(BankCollection) > 0 {
			// 		processType = common.BankProcessType
			// 		BankCollection.ClientId = clientId
			// 		KYC_Json_Str, err = ConstructBankDetails(BankCollection)
			// 		if err != nil {
			// 			common.LogError("sign.ContDataForPdfGeneration", "(CDPG05)", err.Error())
			// 			return processType, KYC_Json_Str, err
			// 		} else {
			// 			//log.Println("ProcessToGetPdf(CDPG): ", KYC_Json_Str)
			// 		}
			// 		//}
			// 		//}
			// 	}
		}
	}

	log.Println("ContDataForPdfGeneration(-)")
	return processType, KYC_Json_Str, nil
}

type checkEsignResp struct {
	DocId  string `json:"docId"`
	Status string `json:"status"`
	ErrMsg string `json:"errMsg"`
}

func CheckEsigneCompleted(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "PostNomineeFile (+)")

	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "  PUT, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	w.WriteHeader(200)

	log.Println("CheckEsigneCompleted+", r.Method)

	if r.Method == "PUT" {

		var resp checkEsignResp
		resp.Status = "S"

		//clientId, err := appsso.ValidateAndGetClientDetails2(r, common.WallAppName, common.WallCookieName)
		_, Uid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		if lErr != nil {
			common.LogError("sign.CheckEsigneCompleted", "(SCEC01)", lErr.Error())
			resp.Status = common.LoginFailure
			resp.ErrMsg = "UnExpectedError:(SCEC01)"
			return
		} else {
			if Uid != "" {
				body, err := ioutil.ReadAll(r.Body)
				if err != nil {
					common.LogError("sign.CheckEsigneCompleted", "(SCEC02)", err.Error())
					resp.Status = common.ErrorCode
					resp.ErrMsg = "UnExpectedError:(SCEC02)"
				} else {
					//log.Println(string(body))
					requestId := string(body)
					//log.Println(requestId)
					if requestId != "" {
						resp.DocId, err = ChkEsignCompleted(requestId)
						if err != nil {
							common.LogError("sign.CheckEsigneCompleted", "(SCEC03)", err.Error())
							resp.Status = common.ErrorCode
							resp.ErrMsg = "UnExpectedError:(SCEC03)"
						}
					}

				}
			}

		}

		data, err := json.Marshal(resp)
		if err != nil {
			fmt.Fprint(w, "Error taking data"+err.Error())
		} else {
			fmt.Fprint(w, string(data))
		}
	}
	log.Println("CheckEsigneCompleted-")
}

func ChkEsignCompleted(requestId string) (string, error) {
	log.Println("ChkEsignCompleted+")

	var docId string

	coreString := `	select nvl(eSignedDocumentID, '')  eSignedDocumentID
						from requests r 
						where id = ? `

	rows, err := ftdb.MariaEKYCPRD_GDB.Query(coreString, requestId)
	if err != nil {
		common.LogError("sign.ChkEsignCompleted", "(CECS02)", err.Error())
		return docId, err
	} else {
		defer rows.Close()
		//data := DB_Rows_To_JSON(rows)

		for rows.Next() {
			err := rows.Scan(&docId)

			if err != nil {
				common.LogError("sign.ChkEsignCompleted", "(CECS03)", err.Error())
				return docId, err
			}

		}
	}
	log.Println("ChkEsignCompleted-")
	return docId, nil
}
