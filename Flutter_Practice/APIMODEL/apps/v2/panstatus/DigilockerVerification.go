package panstatus

import (
	"encoding/base64"
	"encoding/xml"
	"fcs23pkg/apps/v2/address"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/nominee"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v2/digilockerapicall"
	"fcs23pkg/integration/v2/pdfgenerate"
	"fcs23pkg/tomlconfig"
	"net/http"
	"net/url"
	"strings"
)

type PanXmlStruct struct {
	XMLName       xml.Name `xml:"Certificate"`
	Language      string   `xml:"language,attr"`
	Name          string   `xml:"name,attr"`
	Type          string   `xml:"type,attr"`
	Number        string   `xml:"number,attr"`
	IssuedAt      string   `xml:"issuedAt,attr"`
	IssueDate     string   `xml:"issueDate,attr"`
	ValidFromDate string   `xml:"validFromDate,attr"`
	Status        string   `xml:"status,attr"`
	Script        string   `xml:"script"`
	IssuedBy      struct {
		Name    string `xml:"name,attr"`
		Code    string `xml:"code,attr"`
		Tin     string `xml:"tin,attr"`
		Uid     string `xml:"uid,attr"`
		Type    string `xml:"type,attr"`
		Address struct {
			Type     string `xml:"type,attr"`
			Line1    string `xml:"line1,attr"`
			Line2    string `xml:"line2,attr"`
			House    string `xml:"house,attr"`
			Landmark string `xml:"landmark,attr"`
			Locality string `xml:"locality,attr"`
			Vtc      string `xml:"vtc,attr"`
			District string `xml:"district,attr"`
			Pin      string `xml:"pin,attr"`
			State    string `xml:"state,attr"`
			Country  string `xml:"country,attr"`
		} `xml:"Address"`
	} `xml:"IssuedBy>Organization"`
	IssuedTo struct {
		Uid           string `xml:"uid,attr"`
		Title         string `xml:"title,attr"`
		Name          string `xml:"name,attr"`
		Dob           string `xml:"dob,attr"`
		Swd           string `xml:"swd,attr"`
		SwdIndicator  string `xml:"swdIndicator,attr"`
		Gender        string `xml:"gender,attr"`
		MaritalStatus string `xml:"maritalStatus,attr"`
		Religion      string `xml:"religion,attr"`
		Phone         string `xml:"phone,attr"`
		Email         string `xml:"email,attr"`
		Address       struct {
			Type     string `xml:"type,attr"`
			Line1    string `xml:"line1,attr"`
			Line2    string `xml:"line2,attr"`
			House    string `xml:"house,attr"`
			Landmark string `xml:"landmark,attr"`
			Locality string `xml:"locality,attr"`
			Vtc      string `xml:"vtc,attr"`
			District string `xml:"district,attr"`
			Pin      string `xml:"pin,attr"`
			State    string `xml:"state,attr"`
			Country  string `xml:"country,attr"`
		} `xml:"Address"`
		Photo struct {
			Format string `xml:"format,attr"`
		} `xml:"Photo"`
	} `xml:"IssuedTo>Person"`
	CertificateData struct {
		PAN struct {
			VerifiedOn string `xml:"verifiedOn,attr"`
		} `xml:"PAN"`
	} `xml:"CertificateData"`
	Signature struct {
		XMLName    xml.Name `xml:"Signature"`
		SignedInfo struct {
			CanonicalizationMethod struct {
				Algorithm string `xml:"Algorithm,attr"`
			} `xml:"CanonicalizationMethod"`
			SignatureMethod struct {
				Algorithm string `xml:"Algorithm,attr"`
			} `xml:"SignatureMethod"`
			Reference struct {
				URI        string `xml:"URI,attr"`
				Transforms struct {
					Transform []Transform `xml:"Transform"`
				} `xml:"Transforms"`
				DigestMethod struct {
					Algorithm string `xml:"Algorithm,attr"`
				} `xml:"DigestMethod"`
				DigestValue string `xml:"DigestValue"`
			} `xml:"Reference"`
		} `xml:"SignedInfo"`
		SignatureValue string `xml:"SignatureValue"`
		KeyInfo        struct {
			X509Data struct {
				X509SubjectName string `xml:"X509SubjectName"`
				X509Certificate string `xml:"X509Certificate"`
			} `xml:"X509Data"`
		} `xml:"KeyInfo"`
	} `xml:"Signature"`
}
type Transform struct {
	Algorithm string `xml:"Algorithm,attr"`
}

type KeyPairStruct struct {
	Key      string `json:"key"`
	FileType string `json:"filetype"`
	Value    string `json:"value"`
}

func DigilockerVerify(pDebug *helpers.HelperStruct, lUid, lSessionId, Digi_id string, pReq *http.Request, pPanRespRec RespStruct, pTestUserRec TestuserStruct) (RespStruct, string, string) {
	pDebug.Log(helpers.Statement, "DigilockerVerify(+)")

	var lNameAsPerPANXML, lStatusCode, lErrmsg, lDOBAsPerPANXML, lPanNoAsPerPANXML string
	var lPanRecAPI PanDataInfo

	lColumnName := tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "DigilockerColName")

	lResponse, lErr := digilockerapicall.GetDigilockerInfo(pDebug, Digi_id)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	pDebug.Log(helpers.Details, lResponse, "lResponse")

	lResponse.DOB = "14/01/2025"
	lIsMinor, lErr := commonpackage.IsMinor(pDebug, lResponse.DOB)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "DLVIM01", lErr.Error())

		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	if lIsMinor {
		pDebug.Log(helpers.Elog, "DigilockerVerify.IsMinor02", "You must be 18 or older to proceed with the account creation")
		lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "MINORDOB_ERR")
		return pPanRespRec, "MINORDIGIDOB", lERROR
		// return pPanRespRec, "DLVIM02", helpers.ErrPrint(errors.New("you must be 18 or older to proceed with the account creation"))
	}
	lErr = address.RefIdInsert(Digi_id, lUid, lSessionId, lColumnName, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}

	lSqlString := `update ekyc_request er
					set er.Name_As_Per_Aadhar  = ?,er.AadhraNo = ?
					where er.Uid  =?`
	_, lErr = ftdb.NewEkyc_GDB.Exec(lSqlString, lResponse.Name, lResponse.MaskedAatharNo, lUid)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	for _, lDocInfo := range lResponse.DocIDArr {
		if lDocInfo.FileKey == "PANCR_xml" {
			lNameAsPerPANXML, lDOBAsPerPANXML, lPanNoAsPerPANXML, lErr = ReadProdFile(pDebug, lDocInfo.DocID)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return pPanRespRec, "", helpers.ErrPrint(lErr)
			}
		}
	}
	lPanNo, _, lErr := getPanNumber(lUid, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	lPanRecAPI.PanNumber = lPanNo

	if lNameAsPerPANXML != "" {
		if lPanRecAPI.PanNumber == lPanNoAsPerPANXML {
			pPanRespRec, lStatusCode, lErrmsg = verifyUsingPanXML(pDebug, lPanRecAPI, pPanRespRec, lSessionId, lUid, lNameAsPerPANXML, lDOBAsPerPANXML, lResponse)
			return pPanRespRec, lStatusCode, lErrmsg
		} else {
			lPanRecAPI.PanNumber = lPanNoAsPerPANXML
			lPanVerifyStatus, lPanVerifyError := ValidatePanReq(pDebug, lPanRecAPI, pTestUserRec, lUid)
			if lPanVerifyError != "" {
				pDebug.Log(helpers.Elog, "PSPPV19 ", lPanVerifyError)
				return pPanRespRec, lPanVerifyStatus, lPanVerifyError
			}

			lErr = HandlePanNo(pDebug, lPanNoAsPerPANXML, lDOBAsPerPANXML, lUid, lSessionId, pReq)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return pPanRespRec, "", helpers.ErrPrint(lErr)
			}
			// lPanRecAPI.PanNumber = "AAAAA9512R"
			pPanRespRec, lStatusCode, lErrmsg = verifyUsingPanXML(pDebug, lPanRecAPI, pPanRespRec, lSessionId, lUid, lNameAsPerPANXML, lDOBAsPerPANXML, lResponse)
			if lStatusCode == "" && lErrmsg == "" {
				pPanRespRec.PanData[0].PanXmlPanNO = lPanNoAsPerPANXML
				pPanRespRec.PanData[0].Pan = lPanNo
			}
			return pPanRespRec, lStatusCode, lErrmsg
		}
	} else {
		pPanRespRec, lStatusCode, lErrmsg = verifyUsingAadharXML(pDebug, lPanRecAPI, pPanRespRec, lSessionId, lUid, lResponse)
	}
	pDebug.Log(helpers.Statement, "DigilockerVerify(-)")
	return pPanRespRec, lStatusCode, lErrmsg
}

func ReadProdFile(pDebug *helpers.HelperStruct, pDocId string) (string, string, string, error) {
	pDebug.Log(helpers.Statement, "ReadProdFile(+)")
	if pDocId == "" {
		return "", "", "", nil
	}
	var lFileInfo pdfgenerate.FileReadStruct
	var lPanXmlRec PanXmlStruct
	var lErr error
	if !strings.EqualFold(common.AppRunMode, "prod") {
		lFileInfo, lErr = pdfgenerate.Read_filefromPROD(pDebug, pDocId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return "", "", "", helpers.ErrReturn(lErr)
		}
	} else {
		lFileInfo, lErr = pdfgenerate.Read_file(pDebug, pDocId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return "", "", "", helpers.ErrReturn(lErr)
		}
	}
	lErr = xml.Unmarshal(lFileInfo.FileByte, &lPanXmlRec)
	pDebug.Log(helpers.Details, lPanXmlRec, "lPanXmlRec")
	if lErr != nil {
		return "", "", "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "ReadProdFile(-)")
	return lPanXmlRec.IssuedTo.Name, lPanXmlRec.IssuedTo.Dob, lPanXmlRec.Number, nil
}

func handleDigilockerVerification(pDebug *helpers.HelperStruct, pReq *http.Request, pTestUserRec TestuserStruct, lSessionId, lUid string, lPanRecAPI PanDataInfo, lDigilockerRefID string) (RespStruct, string, string) {
	pDebug.Log(helpers.Statement, "handleDigilockerVerification(+)")
	var pPanRespRec RespStruct
	var lStatusCode, lErrmsg string

	lResponse, lErr := digilockerapicall.GetDigilockerInfo(pDebug, lDigilockerRefID)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	lResponse.DOB = "14/01/2025"
	lIsMinor, lErr := commonpackage.IsMinor(pDebug, lResponse.DOB)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "HDLVIM01", lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	if lIsMinor {
		pDebug.Log(helpers.Elog, "HDLVIM02", "You must be 18 or older to proceed with the account creation")
		lERROR := tomlconfig.GtomlConfigLoader.GetValueString("panstatus", "MINORDOB_ERR")
		return pPanRespRec, "MINORDIGIDOB", lERROR
		// return pPanRespRec, "HDLVIM02", helpers.ErrPrint(errors.New("you must be 18 or older to proceed with the account creation"))
	}

	var lNameAsPerPANXML, lDOBAsPerPANXML, lPanNoAsPerPANXML string
	for _, lDocInfo := range lResponse.DocIDArr {
		if lDocInfo.FileKey == "PANCR_xml" {
			lNameAsPerPANXML, lDOBAsPerPANXML, lPanNoAsPerPANXML, lErr = ReadProdFile(pDebug, lDocInfo.DocID)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return pPanRespRec, "", helpers.ErrPrint(lErr)
			}
		}
	}

	lPanNo, _, lErr := getPanNumber(lUid, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return pPanRespRec, "", helpers.ErrPrint(lErr)
	}
	lPanRecAPI.PanNumber = lPanNo

	if lNameAsPerPANXML != "" {
		if lPanRecAPI.PanNumber == lPanNoAsPerPANXML {
			pPanRespRec, lStatusCode, lErrmsg = verifyUsingPanXML(pDebug, lPanRecAPI, pPanRespRec, lSessionId, lUid, lNameAsPerPANXML, lDOBAsPerPANXML, lResponse)
			return pPanRespRec, lStatusCode, lErrmsg
		} else {
			// -------------------------------------Backoffice check
			lPanVerifyStatus, lPanVerifyError := ValidatePanReq(pDebug, lPanRecAPI, pTestUserRec, lUid)
			if lPanVerifyError != "" {
				pDebug.Log(helpers.Elog, "PSPPV19 ", lPanVerifyError)
				return pPanRespRec, lPanVerifyStatus, lPanVerifyError
			}
			lPanRecAPI.PanNumber = lPanNoAsPerPANXML
			lErr = HandlePanNo(pDebug, lPanNoAsPerPANXML, lDOBAsPerPANXML, lUid, lSessionId, pReq)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return pPanRespRec, "", helpers.ErrPrint(lErr)
			}
			pPanRespRec, lStatusCode, lErrmsg = verifyUsingPanXML(pDebug, lPanRecAPI, pPanRespRec, lSessionId, lUid, lNameAsPerPANXML, lDOBAsPerPANXML, lResponse)
			return pPanRespRec, lStatusCode, lErrmsg
		}
	} else {
		pPanRespRec, lStatusCode, lErrmsg = verifyUsingAadharXML(pDebug, lPanRecAPI, pPanRespRec, lSessionId, lUid, lResponse)
	}
	pDebug.Log(helpers.Statement, "handleDigilockerVerification(-)")
	return pPanRespRec, lStatusCode, lErrmsg
}

func RedirectUrl(pDebug *helpers.HelperStruct, lDevName, lUid string) (string, error) {
	pDebug.Log(helpers.Statement, "RedirectUrl(+)")
	var lAppName, lreDirectUrl string

	if strings.EqualFold(lDevName, "web") {
		lAppName = tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "webPanAppName")
	} else if strings.EqualFold(lDevName, "mobile") {
		lAppName = tomlconfig.GtomlConfigLoader.GetValueString("digilockerapicall", "mobileAppName")
	}

	lReqID, lErr := nominee.GetRequestTableId(lUid, pDebug)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "RDU002 ", lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	lreDirectUrl, lErr = digilockerapicall.GetRedirectUrl(pDebug, lAppName, lReqID)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "RDU003 ", lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, lreDirectUrl, "lreDirectUrl")

	lreDirectUrl = url.QueryEscape(base64.StdEncoding.EncodeToString([]byte(lreDirectUrl)))

	pDebug.Log(helpers.Statement, "RedirectUrl(-)")
	return lreDirectUrl, nil
}
