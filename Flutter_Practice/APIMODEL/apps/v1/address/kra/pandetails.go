package kra

import (
	"encoding/xml"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/kraapi"
	"fcs23pkg/tomlconfig"
	"html"
	"net/http"
	"strings"
)

// pan full details soap process struct
/*
   Purpose : This structure is used to input of the PanfullDetailsStruct

   Author : sowmiya
   Date : 06-June-2023
*/
type PanInputXMLStruct struct {
	XMLName   xml.Name `xml:"APP_REQ_ROOT"`
	Text      string   `xml:",chardata"`
	APPPANINQ struct {
		Text         string `xml:",chardata"`
		APPPANNO     string `xml:"APP_PAN_NO"`
		APPDOBINCORP string `xml:"APP_DOB_INCORP"`
		APPPOSCODE   string `xml:"APP_POS_CODE"`
		APPRTACODE   string `xml:"APP_RTA_CODE"`
		APPKRACODE   string `xml:"APP_KRA_CODE"`
		FETCHTYPE    string `xml:"FETCH_TYPE"`
	} `xml:"APP_PAN_INQ"`
}

/*
   Purpose : This structure is used to get the user pan details

   Author : Sowmiya L
   Date : 06-June-2023
*/
type PanFullDetailsStruct struct {
	XMLName xml.Name `xml:"Envelope"`
	Text    string   `xml:",chardata"`
	Xmlns   string   `xml:"xmlns,attr"`
	Body    struct {
		Text                         string `xml:",chardata"`
		SolicitPANDetailsFetchALLKRA struct {
			Text   string `xml:",chardata"`
			Xmlns  string `xml:"xmlns,attr"`
			WebApi struct {
				Text     string `xml:",chardata"`
				InputXml string `xml:"inputXml"`
				UserName string `xml:"userName"`
				PosCode  string `xml:"posCode"`
				Password string `xml:"password"`
				PassKey  string `xml:"passKey"`
			} `xml:"webApi"`
		} `xml:"SolicitPANDetailsFetchALLKRA"`
	} `xml:"Body"`
}

/*
   Purpose : This structure is used to generate XML to pdf

   Author : Sowmiya L
   Date : 06-June-2023
*/
// generate pdf struct
type KraKycStruct struct {
	Name          string `json:"Name"`
	DOB           string `json:"DOB"`
	Gender        string `json:"Gender"`
	Address       string `json:"Address"`
	POA           string `json:"POA"` // Proof of Address (POA).
	POI           string `json:"POI"` // Proof of Identity (POI)
	Generate_Date string `json:"Generate_Date"`
	// RequestID   int    `json:"RequestId"`
	// ProcessType string `json:"ProcessType"`
}

/*
   Purpose : This structure is used to get the user address details

   Author : Sowmiya L
   Date : 06-June-2023 */

/*
   Purpose : This method is used to fetch the user pan details in KRA
   Parameter : panno,Username,pascode,Password,passkey
   Response :
    ===========
   	On Success:
	===========
			<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">
				<Body>
				  <GetPanStatus xmlns="https://pancheck.www.kracvl.com">
					<webApi>
						<pan>LVZPS0459L</pan>
						<userName>CAZAAYAN</userName>
						<posCode>1401457236</posCode>
						<password>N51wm7SwbhHd3FUCKcpB1w!3d!3d</password>
						<passKey>FLATTRADE</passKey>
					</webApi>
				  </GetPanStatus>
				</Body>
			</Envelope>
	===========
   	On Error:
	===========
			{
				"Error": "Error"
				"ErrorMsg":Check the pan number/username/pascode/password/passkey
			}
   Author : Sowmiya L
   Date : 05-June-2023
*/
// func GetPandetailsSoap(payload []byte, pDebug *helpers.HelperStruct) string {

// 	pDebug.Log(helpers.Statement, "GetPandetailsSoap(+)")
// 	//calling API
// 	lResult, lErr := kraapi.Pandetails(string(payload), pDebug)
// 	pDebug.Log(helpers.Details, "lResult", lResult)
// 	if lErr != nil {
// 		pDebug.Log(helpers.Elog, lErr.Error())
// 	}

// 	pDebug.Log(helpers.Statement, "GetPandetailsSoap(-)")
// 	//return output
// 	return lResult
// }

/*
   Purpose : This method is used to fetch the user pan address details in KRA
   Parameter : panno,Username,pascode,Password,passkey
   Response :
    ===========
   	On Success:
	===========
			<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">
			<Body>
				<SolicitPANDetailsFetchALLKRA xmlns="https://pancheck.www.kracvl.com">
				<webApi>
					<inputXml><![CDATA[ <APP_REQ_ROOT>
			<APP_PAN_INQ>
				<APP_PAN_NO>LVZPS0459L</APP_PAN_NO>
				<APP_DOB_INCORP>06/11/2001</APP_DOB_INCORP>
				<APP_POS_CODE>1401457236</APP_POS_CODE>
				<APP_RTA_CODE>1401457236</APP_RTA_CODE>
				<APP_KRA_CODE>CVLKRA</APP_KRA_CODE>
				<FETCH_TYPE>I</FETCH_TYPE>
			</APP_PAN_INQ>
			</APP_REQ_ROOT>]]></inputXml>
					<userName>CAZAAYAN</userName>
					<posCode>1401457236</posCode>
					<password>N51wm7SwbhHd3FUCKcpB1w!3d!3d</password>
					<passKey>FLATTRADE</passKey>
				</webApi>
			</Body>
			</Envelope>
	===========
   	On Error:
	===========
			{
				"Error": "Error"
				"ErrorMsg":Check the pan number/username/pascode/password/passkey
			}
   Author : Sowmiya L
   Date : 06-June-2023
*/
func GetPanAddressDetails(pPanNo string, pDOB string, pAgencyCode string, pPassword string, pDebug *helpers.HelperStruct, req *http.Request) (string, error) {
	pDebug.Log(helpers.Statement, "GetPanFullDetails(+)")
	// read toml

	//  create an instance of the structure
	var lInputXMLRec PanInputXMLStruct
	var lPanConfigRec PanFullDetailsStruct
	//constructing details for the API
	lInputXMLRec.APPPANINQ.APPPANNO = pPanNo
	lInputXMLRec.APPPANINQ.APPDOBINCORP = pDOB
	lInputXMLRec.APPPANINQ.APPPOSCODE = tomlconfig.GtomlConfigLoader.GetValueString("kra", "APP_PAS_CODE")
	lInputXMLRec.APPPANINQ.APPRTACODE = tomlconfig.GtomlConfigLoader.GetValueString("kra", "APP_RTA_CODE")
	lInputXMLRec.APPPANINQ.APPKRACODE = pAgencyCode // get_APP_Status
	lInputXMLRec.APPPANINQ.FETCHTYPE = tomlconfig.GtomlConfigLoader.GetValueString("kra", "APP_TYPE")
	//converting the struct to XML
	lInput_xml_Data, lErr := xml.MarshalIndent(lInputXMLRec, " ", "  ")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GPAD01"+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	lPanConfigRec.Body.SolicitPANDetailsFetchALLKRA.WebApi.InputXml = "<![CDATA[" + string(lInput_xml_Data) + "]]>"
	lPanConfigRec.Body.SolicitPANDetailsFetchALLKRA.WebApi.UserName = tomlconfig.GtomlConfigLoader.GetValueString("kra", "UserName")
	lPanConfigRec.Body.SolicitPANDetailsFetchALLKRA.WebApi.PosCode = tomlconfig.GtomlConfigLoader.GetValueString("kra", "PosCode")
	lPanConfigRec.Body.SolicitPANDetailsFetchALLKRA.WebApi.Password = pPassword
	lPanConfigRec.Body.SolicitPANDetailsFetchALLKRA.WebApi.PassKey = tomlconfig.GtomlConfigLoader.GetValueString("kra", "passkey")
	lPanConfigRec.Xmlns = tomlconfig.GtomlConfigLoader.GetValueString("kra", "Xmlns")
	lPanConfigRec.Body.SolicitPANDetailsFetchALLKRA.Xmlns = tomlconfig.GtomlConfigLoader.GetValueString("kra", "GetPanStatus_Xmlns")
	//converting the struct to xml
	lPayload, lErr := xml.MarshalIndent(lPanConfigRec, " ", "  ")
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GPAD02"+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	var lInput_data string = html.UnescapeString(string(lPayload))
	//calling Api
	lResult, lErr := kraapi.Panfulldetails((lInput_data), pDebug, req)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GPAD03"+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "lResult", lResult)
	// common.LogEntry("GetPanFullDetails_result", lResult)
	pDebug.Log(helpers.Statement, "GetPanFullDetails(-)")
	//return output
	return lResult, nil

}

/*
Purpose : This method is used to get the country code
Parameter : pcode
Response :
 ===========
	On Success:
 ===========

 ===========
	On Error:
 ===========

Author : Sowmiya L
Date : 06-June-2023
*/

func GetCountryCode(pCountrycode string, pDebug *helpers.HelperStruct) (string, error) {

	pDebug.Log(helpers.Statement, "GetCountryCode(+)")
	var lCountryName string

	lCorestring := `select nvl(description,"") from ekyc_lookup_details where code = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pCountrycode)
	pDebug.Log(helpers.Details, "code", pCountrycode)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GCC02"+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lCountryName)
			pDebug.Log(helpers.Details, "lCountryName", lCountryName)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "GCC03"+lErr.Error())
				return "", helpers.ErrReturn(lErr)
			}
		}
	}

	pDebug.Log(helpers.Statement, "GetCountryCode(-)")
	//return output
	return strings.ToUpper(lCountryName), nil
}

/*
Purpose : This method is used to get the state name
Parameter : pcode
Response :
 ===========
	On Success:
 ===========

 ===========
	On Error:
 ===========

Author : Sowmiya L
Date : 06-June-2023
*/
func GetStateName(pStatecode string, pDebug *helpers.HelperStruct) (string, error) {

	pDebug.Log(helpers.Statement, "GetStateName(+)")
	var lStateName string

	lCorestring := `select nvl(description,"") from ekyc_lookup_details where code = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pStatecode)
	// lRows, lErr := lDb.Query(lCorestring)
	pDebug.Log(helpers.Details, "code", pStatecode)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GSN02"+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lStateName)
			pDebug.Log(helpers.Details, "statename", lStateName)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "GSN03"+lErr.Error())
				return "", helpers.ErrReturn(lErr)
			}
		}
	}

	pDebug.Log(helpers.Statement, "GetStateName(-)")
	//return output
	return strings.ToUpper(lStateName), nil
}

/*
Purpose : This method is used to get the address proof type
Parameter : pAddressCode


Author : Sowmiya L
Date : 06-June-2023
*/
func GetProofType(pAddressCode string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "GetProofType (+)")
	var lAddressProoftype string

	// var Uid string
	lCorestring := `select nvl(Description,"") from ekyc_address_proof_type eapt where eapt.code = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pAddressCode)
	pDebug.Log(helpers.Details, "code", pAddressCode)
	if lErr != nil {
		return "", helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lAddressProoftype)
			pDebug.Log(helpers.Details, "lAddressProoftype", lAddressProoftype)
			if lErr != nil {
				return "", helpers.ErrReturn(lErr)
			}

		}
	}
	pDebug.Log(helpers.Statement, "GetProofType (-)")
	return lAddressProoftype, nil
}

/*
Purpose : This method is used to get the status Descritpion
Parameter : pStatus_Code,pHeaderCode,pDebug


Author : Sowmiya L
Date : 27-March-2023
*/
func GetAgencyname(pStatusCode, pHeaderCode string, pDebug *helpers.HelperStruct) (string, error) {
	pDebug.Log(helpers.Statement, "GetAgencyname (+)")

	var lHeaderID, lDescription string

	lCorestring := `SELECT id FROM lookup_header WHERE Code = ?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pHeaderCode)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GS02"+lErr.Error())
		return "", helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr := lRows.Scan(&lHeaderID)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "GS03"+lErr.Error())
				return "", helpers.ErrReturn(lErr)
			}
		}
		// Query the database to retrieve the description based on the provided status code
		lCorestring := `SELECT description FROM lookup_details WHERE headerid = ? and code like '%` + pStatusCode + `%'`
		lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, lHeaderID)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "GS04"+lErr.Error())
			return "", helpers.ErrReturn(lErr)
		}
		defer lRows.Close()
		// Iterate over the result set
		for lRows.Next() {
			// Scan the retrieved description
			lErr := lRows.Scan(&lDescription)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "GS05"+lErr.Error())
				return "", helpers.ErrReturn(lErr)
			}
		}
	}

	pDebug.Log(helpers.Statement, "GetAgencyname (-)")
	return lDescription, nil
}
