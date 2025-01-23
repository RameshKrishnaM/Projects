package esigndigio

import (
	"encoding/json"
	"fcs23pkg/apps/v1/commonpackage"
	"fcs23pkg/apps/v1/fileoperations"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	digio "fcs23pkg/integration/v1/digioesign"
	"fcs23pkg/integration/v1/pdfgenerate"
	"fmt"
	"strconv"
	"strings"
)

type StampPositionStruct struct {
	LLX float64 `json:"llx"`
	LLY float64 `json:"lly"`
	URX float64 `json:"urx"`
	URY float64 `json:"ury"`
}

type UserStruct struct {
	Name     string `json:"name"`
	Identify string `json:"identifier"`
	Reason   string `json:"reason"`
	SignType string `json:"sign_type"`
}

type ESignParentStruct struct {
	UserInfo            []UserStruct                                `json:"signers"`
	ExpInDates          int                                         `json:"expire_in_days"`
	Sequential          bool                                        `json:"sequential"`
	DisplayOnPage       string                                      `json:"display_on_page"` // [first/last/all/custom     (default is first)]
	NotifySign          bool                                        `json:"notify_signers"`
	GenerateAccessToken bool                                        `json:"generate_access_token"`
	SendLink            bool                                        `json:"send_sign_link"`
	FileName            string                                      `json:"file_name"`
	File                string                                      `json:"file_data"`
	SignCoordinate      map[string]map[string][]StampPositionStruct `json:"sign_coordinates"`
}

type ESignInfoStruct struct {
	UserName    string `json:"user_name"`
	Mobile      string `json:"mobile"`
	Reason      string `json:"reason"`
	SignType    string `json:"sign_type"`
	ProcessType string `json:"process_type"`
	PDFID       string `json:"docid"`
	// Emain       string `json:"email"`
}
type respStruct struct {
	Status     string `json:"status"`
	DocID      string `json:"docid"`
	Identifier string `json:"identifier"`
	AccessID   string `json:"accessToken"`
}

func InsertDigioStatus(pDebug *helpers.HelperStruct, pIPVReqID, pAccessToken, pValiditiy, pUid, pSid string) error {
	pDebug.Log(helpers.Statement, "InsertDigioStatus (+)")

	lInsertString := `
    	insert into ekyc_digioesign_request_status(Request_Uid,esign_requestid,accessToken,validity,req_status,Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate)
    	values(?,?,?,?,?,?,?,unix_timestamp(),unix_timestamp());
	`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lInsertString, pUid, pIPVReqID, pAccessToken, pValiditiy, "E", pSid, pSid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "InsertDigioStatus (-)")

	return nil

}

func GetCoorrdinate(pDebug *helpers.HelperStruct, pProcessType, pUid string, pFirstParthCount int) (lCoordinateMap map[string][]StampPositionStruct, lPagNo int, lErr error) {
	pDebug.Log(helpers.Statement, "GetCoorrdinate (+)")
	lCoordinateMap = make(map[string][]StampPositionStruct)
	var lStampPositionRec StampPositionStruct
	// var lPagNo int
	// var lLastPgNo string
	// lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
	// if lErr != nil {
	// 	return nil, lPagNo, helpers.ErrReturn(lErr)
	// }
	// defer lDb.Close()
	_, lNonselectidArr, lErr := GetServicesInfo(pDebug, pUid)
	if lErr != nil {
		return nil, lPagNo, helpers.ErrReturn(lErr)
	}
	lQry := fmt.Sprintf("SELECT PageNo, llx, lly, urx, ury FROM document_sign_coordinates WHERE DocType =? and PageNo <>'0'and (reference not in ('%s') or reference is null or reference='') order by CAST(PageNo AS UNSIGNED)", strings.Join(lNonselectidArr, "','"))
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lQry, pProcessType)
	if lErr != nil {
		return nil, lPagNo, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lPagNo, &lStampPositionRec.LLX, &lStampPositionRec.LLY, &lStampPositionRec.URX, &lStampPositionRec.URY)
		if lErr != nil {
			return nil, lPagNo, helpers.ErrReturn(lErr)
		}
		if lPagNo <= 2 {
			lCoordinateMap[strconv.Itoa(lPagNo)] = append(lCoordinateMap[strconv.Itoa(lPagNo)], lStampPositionRec)
		} else {
			lCoordinateMap[strconv.Itoa(lPagNo+pFirstParthCount)] = append(lCoordinateMap[strconv.Itoa(lPagNo+pFirstParthCount)], lStampPositionRec)
		}
	}

	// log.Println("****************lCoordinateMap******************\n", lCoordinateMap, "**********************************\n")
	// os.Exit(1)
	pDebug.Log(helpers.Statement, "GetCoorrdinate (-)")
	return lCoordinateMap, lPagNo + pFirstParthCount, nil
}
func GenerateSignReq(pDebug *helpers.HelperStruct, pEsignInfoRec ESignInfoStruct, pUid, pSid string) (lRespRec respStruct, lErr error) {
	pDebug.Log(helpers.Statement, "GenerateSignReq (+)")
	// var lStampPositionRec StampPositionStruct
	// var lStampPositionArr []StampPositionStruct
	lRespRec.Status = common.SuccessCode
	lPageValues := make(map[string]map[string][]StampPositionStruct)
	var lUserRec UserStruct
	var lUserArr []UserStruct
	var lEsignRec ESignParentStruct

	lUserRec.Name = pEsignInfoRec.UserName
	lUserRec.Identify = pEsignInfoRec.Mobile
	lUserRec.Reason = pEsignInfoRec.Reason
	lUserRec.SignType = pEsignInfoRec.SignType //"aadhaar"
	lUserArr = append(lUserArr, lUserRec)
	lEsignRec.UserInfo = lUserArr
	lEsignRec.ExpInDates = 10
	lEsignRec.Sequential = false
	lEsignRec.DisplayOnPage = "custom"
	lEsignRec.NotifySign = true
	lEsignRec.GenerateAccessToken = true
	lEsignRec.SendLink = false

	lTotalPgcount, lDefaultPgCoordinates, lErr := getDefaultPageCoordinates(pDebug, pEsignInfoRec.PDFID, pEsignInfoRec.ProcessType)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}

	lDocIDMap, lErr := GetDocID(pDebug, pUid)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}

	lAddressProofdocId, lErr := fileoperations.GetAdrsProofDocID(pDebug, pUid)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}
	var lPageCount pdfgenerate.PageCount

	lPageCount, lErr = pdfgenerate.GetPageCount(pDebug, lDocIDMap["PanDocid"], lDocIDMap["SignDocid"], lAddressProofdocId)

	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}

	lCount := 0

	for _, lTotalPage := range lPageCount.PageCount {
		lCount += lTotalPage
	}
	pDebug.Log(helpers.Details, "lCount :", lCount)

	lCoordinateInfo, lLastPgNo, lErr := GetCoorrdinate(pDebug, pEsignInfoRec.ProcessType, pUid, lCount)

	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}

	if lTotalPgcount != 0 {

		lDefaultCoordinate := make(map[string][]StampPositionStruct)
		for i := 1; i <= lTotalPgcount; i++ {
			_, lFlag := lCoordinateInfo[strconv.Itoa(i)]

			if !lFlag && (i <= lCount+2 || i > lLastPgNo) {
				lDefaultCoordinate[strconv.Itoa(i)] = append(lDefaultCoordinate[strconv.Itoa(i)], lDefaultPgCoordinates)
			}
		}

		lCoordinateInfo = mergeMaps(lCoordinateInfo, lDefaultCoordinate)
	}
	lPageValues[pEsignInfoRec.Mobile] = lCoordinateInfo
	lEsignRec.SignCoordinate = lPageValues

	lFileInfo, lErr := pdfgenerate.Read_file(pDebug, pEsignInfoRec.PDFID)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}
	if !strings.Contains(strings.ToLower(lFileInfo.FileType), "pdf") {
		return lRespRec, helpers.ErrReturn(fmt.Errorf("the given [ %s ] is not a PDF file", pEsignInfoRec.PDFID))
	}
	lEsignRec.FileName = lFileInfo.FileName

	lEsignRec.File = lFileInfo.File

	lJsonData, lErr := json.Marshal(lEsignRec)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}

	lResp, lErr := digio.GenerateSignRequest(pDebug, string(lJsonData))
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}
	var lEsignRespRec EsignRespStruct

	lErr = json.Unmarshal([]byte(lResp), &lEsignRespRec)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}

	lErr = InsertDigioStatus(pDebug, lEsignRespRec.ID, lEsignRespRec.AccessToken.ID, lEsignRespRec.AccessToken.ValidTill, pUid, pSid)
	if lErr != nil {
		return lRespRec, helpers.ErrReturn(lErr)
	}

	lRespRec.DocID = lEsignRespRec.ID
	lRespRec.Identifier = pEsignInfoRec.Mobile
	lRespRec.AccessID = lEsignRespRec.AccessToken.ID

	pDebug.Log(helpers.Statement, "GenerateSignReq (-)")
	return lRespRec, nil
}

func getDefaultPageCoordinates(pDebug *helpers.HelperStruct, DocId, pProcessType string) (int, StampPositionStruct, error) {
	pDebug.Log(helpers.Statement, "getDefaultPageCoordinates (+)")

	var lStampPositionRec StampPositionStruct
	pageCount := 0

	lResp, lErr := pdfgenerate.GetPageCount(pDebug, DocId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "DF03"+lErr.Error())
		return pageCount, lStampPositionRec, helpers.ErrReturn(lErr)
	}
	pageCount = lResp.PageCount[0]

	// lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
	// if lErr != nil {
	// 	return pageCount, lStampPositionRec, helpers.ErrReturn(lErr)
	// }
	// defer lDb.Close()

	lQry := `SELECT llx, lly, urx, ury FROM document_sign_coordinates WHERE DocType=? and PageNo='0';`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lQry, pProcessType)
	if lErr != nil {
		return pageCount, lStampPositionRec, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lStampPositionRec.LLX, &lStampPositionRec.LLY, &lStampPositionRec.URX, &lStampPositionRec.URY)
		if lErr != nil {
			return pageCount, lStampPositionRec, helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "getDefaultPageCoordinates (-)")

	return pageCount, lStampPositionRec, nil
}

func mergeMaps(map1, map2 map[string][]StampPositionStruct) map[string][]StampPositionStruct {
	mergedMap := make(map[string][]StampPositionStruct)

	// Merge map1 into mergedMap
	for key, value := range map1 {
		mergedMap[key] = append(mergedMap[key], value...)
	}

	// Merge map2 into mergedMap
	for key, value := range map2 {
		mergedMap[key] = append(mergedMap[key], value...)
	}

	return mergedMap
}

func GetDocID(pDebug *helpers.HelperStruct, pRequestId string) (map[string]string, error) {
	pDebug.Log(helpers.Statement, "GetDocID(+)")
	lIdMapInfo := make(map[string]string)

	// lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)
	// if lErr != nil {
	// 	return nil, helpers.ErrReturn(lErr)
	// }
	// defer lDb.Close()

	lCorestring := `select nvl(Source_Of_Address,""),nvl(Proof_Doc_Id1,""),nvl(Proof_Doc_Id2,""),nvl(Kra_docid,""),nvl(Digilocker_docid,"") from ekyc_address where Request_Uid = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return nil, helpers.ErrReturn(lErr)
	}
	var lSoa, lDocid1, lDocid2, lKraId, lDigilockerId, lBankid, lIncomeid, lSignid, lPanid string
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lSoa, &lDocid1, &lDocid2, &lKraId, &lDigilockerId)
		if lErr != nil {
			return nil, helpers.ErrReturn(lErr)
		}
	}
	if strings.EqualFold(lSoa, "KRA") {
		lDocid1 = lKraId
	} else if strings.EqualFold(lSoa, "Digilocker") {
		lDocid1 = lDigilockerId
	} else {
		if !strings.EqualFold(lDocid2, "") {
			lIdMapInfo["AddressDocid2"] = lDocid2
		}
	}

	lCorestring = `
	select nvl(Bank_proof,""),nvl(Income_proof,""),nvl(Signature,""),nvl(Pan_proof,"")
	from ekyc_attachments 
	where Request_id = ?`
	lRows, lErr = ftdb.NewEkyc_GDB.Query(lCorestring, pRequestId)
	if lErr != nil {
		return nil, helpers.ErrReturn(lErr)

	}
	defer lRows.Close()

	for lRows.Next() {
		lErr := lRows.Scan(&lBankid, &lIncomeid, &lSignid, &lPanid)
		if lErr != nil {
			return nil, helpers.ErrReturn(lErr)

		}
	}
	lIdMapInfo["AddressDocid1"] = lDocid1
	lIdMapInfo["BankDocid"] = lBankid
	lIdMapInfo["IncomeDocid"] = lIncomeid
	lIdMapInfo["SignDocid"] = lSignid
	lIdMapInfo["PanDocid"] = lPanid

	pDebug.Log(helpers.Statement, "GetDocID (-)")
	return lIdMapInfo, nil
}

// // getLastKey returns the last key name of a map
// func getLastKey(m map[string][]StampPositionStruct) string {
// 	var lastKey string
// 	for key := range m {
// 		lastKey = key
// 	}
// 	return lastKey
// }

type SigningParty struct {
	Name           string               `json:"name"`
	Identifier     string               `json:"identifier"`
	Status         string               `json:"status"`
	Reason         string               `json:"reason"`
	Type           string               `json:"type"`
	SignatureType  string               `json:"signature_type"`
	ExpireOn       string               `json:"expire_on"`
	UserAadhatinfo SignAadharInfoStruct `json:"pki_signature_details"`
}

type AccessToken struct {
	CreatedAt string `json:"created_at"`
	ID        string `json:"id"`
	EntityID  string `json:"entity_id"`
	ValidTill string `json:"valid_till"`
}

type SignRequestDetails struct {
	Name          string `json:"name"`
	Identifier    string `json:"identifier"`
	RequestedOn   string `json:"requested_on"`
	ExpireOn      string `json:"expire_on"`
	RequesterType string `json:"requester_type"`
}

type OtherDocDetails struct {
	WebHookAvailable bool `json:"web_hook_available"`
}

type EsignRespStruct struct {
	ID                    string                 `json:"id"`
	IsAgreement           bool                   `json:"is_agreement"`
	AgreementType         string                 `json:"agreement_type"`
	AgreementStatus       string                 `json:"agreement_status"`
	FileName              string                 `json:"file_name"`
	SelfSigned            bool                   `json:"self_signed"`
	SelfSignType          string                 `json:"self_sign_type"`
	NoOfPages             int                    `json:"no_of_pages"`
	CreatedAt             string                 `json:"created_at"`
	UpdatedAt             string                 `json:"updated_at"`
	SigningParties        []SignerStruct         `json:"signing_parties"`
	SignRequestDetails    SignRequestStruct      `json:"sign_request_details"`
	Channel               string                 `json:"channel"`
	OtherDocDetails       OtherDocDetails        `json:"other_doc_details"`
	AccessToken           AccessToken            `json:"access_token"`
	AttachedEstampDetails map[string]interface{} `json:"attached_estamp_details"`
	ErrDetails            string                 `json:"details"`
	ErrCode               string                 `json:"code"`
	ErrMessage            string                 `json:"message"`
}

type SignAadharInfoStruct struct {
	Name             string `json:"name"`
	AadhaarLast4Degi string `json:"aadhaar_suffix"`
	HashOfPhotograph string `json:"hash_of_photograph"`
	Gender           string `json:"gender"`
	YearOfBirth      string `json:"year_of_birth"`
	PostalCode       string `json:"postal_code"`
}

type PKISignatureStruct struct {
	Name             string `json:"name"`
	AadhaarSuffix    string `json:"aadhaar_suffix"`
	HashOfPhotograph string `json:"hash_of_photograph"`
	Gender           string `json:"gender"`
	YearOfBirth      string `json:"year_of_birth"`
	PostalCode       string `json:"postal_code"`
	DisplayName      string `json:"display_name"`
}

type SignerStruct struct {
	Name                string             `json:"name"`
	Status              string             `json:"status"`
	UpdatedAt           string             `json:"updated_at"`
	Type                string             `json:"type"`
	SignatureType       string             `json:"signature_type"`
	Identifier          string             `json:"identifier"`
	Reason              string             `json:"reason"`
	ExpireOn            string             `json:"expire_on"`
	PKISignatureDetails PKISignatureStruct `json:"pki_signature_details"`
}

type SignRequestStruct struct {
	Name          string `json:"name"`
	RequestedOn   string `json:"requested_on"`
	ExpireOn      string `json:"expire_on"`
	Identifier    string `json:"identifier"`
	RequesterType string `json:"requester_type"`
}

type AgreementStruct struct {
	ID                    string                 `json:"id"`
	IsAgreement           bool                   `json:"is_agreement"`
	AgreementType         string                 `json:"agreement_type"`
	AgreementStatus       string                 `json:"agreement_status"`
	FileName              string                 `json:"file_name"`
	UpdatedAt             string                 `json:"updated_at"`
	CreatedAt             string                 `json:"created_at"`
	SelfSigned            bool                   `json:"self_signed"`
	SelfSignType          string                 `json:"self_sign_type"`
	NoOfPages             int                    `json:"no_of_pages"`
	SigningParties        []SignerStruct         `json:"signing_parties"`
	SignRequestDetails    SignRequestStruct      `json:"sign_request_details"`
	Channel               string                 `json:"channel"`
	OtherDocDetails       map[string]interface{} `json:"other_doc_details"`
	AttachedEstampDetails map[string]interface{} `json:"attached_estamp_details"`
}

func GetServicesInfo(pDebug *helpers.HelperStruct, pRequestId string) (lSelectSegmantArr, lNonSelectSegmantArr []string, lErr error) {
	pDebug.Log(helpers.Statement, "GetServicesInfo (+)")

	// var dematandservice DematAndService
	var lExchange, lSegment, lUserStatus, lNomineeStatus string
	// lSegmentInfo = make(map[string][]string)
	// var lSelectSegmantArr, lNonSelectSegmantArr []string
	var lookupRec commonpackage.LookupValStruct
	lPrompt := "TechExcel"
	var lookupResp commonpackage.LookupValRespStruct

	sqlString := `	select eem.Exchange,esm.Segment ,es.u_selected
					from ekyc_services es ,ekyc_segment_master esm ,ekyc_exchange_master eem
					where es.segement_id = esm.id
					and es.exchange_id =eem.id
					and Request_Uid = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(sqlString, pRequestId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lSelectSegmantArr, lNonSelectSegmantArr, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lExchange, &lSegment, &lUserStatus)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return lSelectSegmantArr, lNonSelectSegmantArr, helpers.ErrReturn(lErr)
		}
		// exchanges = lExchange + " " + lSegment
		lookupRec.Code = "Techexcel exchange id"
		lookupRec.ReferenceVal = lExchange + " " + lSegment
		lookupRec.RequestedAttr = lPrompt
		lookupResp, lErr = commonpackage.GetAttributes(pDebug, lookupRec, "code")
		pDebug.Log(helpers.Details, "exchanges", lookupRec)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "DematAndService", lErr)
			return lSelectSegmantArr, lNonSelectSegmantArr, helpers.ErrReturn(lErr)
		}
		TechexcelExchanges := lookupResp.LookupValueArr[lPrompt]
		if TechexcelExchanges != "" {
			if strings.EqualFold(lUserStatus, "N") {
				lNonSelectSegmantArr = append(lNonSelectSegmantArr, TechexcelExchanges)
			} else {
				lSelectSegmantArr = append(lSelectSegmantArr, TechexcelExchanges)

			}
		}

	}
	sqlString = `select nvl(ep.Nominee,"N") from ekyc_personal ep where ep.Request_Uid =?`
	lRows, lErr = ftdb.NewEkyc_GDB.Query(sqlString, pRequestId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lSelectSegmantArr, lNonSelectSegmantArr, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lNomineeStatus)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return lSelectSegmantArr, lNonSelectSegmantArr, helpers.ErrReturn(lErr)
		}
	}
	if strings.EqualFold(lNomineeStatus, "N") {
		lNonSelectSegmantArr = append(lNonSelectSegmantArr, "withoutNominee")
	} else {
		lNonSelectSegmantArr = append(lNonSelectSegmantArr, "withNominee")
	}

	pDebug.Log(helpers.Details, "lSelectSegmantArr", lSelectSegmantArr)
	pDebug.Log(helpers.Details, "lNonSelectSegmantArr", lNonSelectSegmantArr)

	pDebug.Log(helpers.Statement, "GetServicesInfo (-)")

	return lSelectSegmantArr, lNonSelectSegmantArr, nil
}
