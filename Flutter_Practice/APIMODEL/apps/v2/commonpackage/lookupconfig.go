package commonpackage

import (
	"encoding/json"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"

	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

// LookupValStruct represents the structure for individual lookup values.
type LookupValStruct struct {
	Code          string `json:"code"`          // Name of the header for the lookup value
	ReferenceVal  string `json:"referenceval"`  // Detail associated with the lookup value
	RequestedAttr string `json:"requestedattr"` // Type of detail for the lookup value like user wants all the data or if he wants any particular data
	Description   string `json:"description"`
}

// KeyPairStruct represents a key-value pair structure, typically used in lookup values.
type KeyPairStruct struct {
	Key     string `json:"key"`     // Key of the key-value pair
	Value   string `json:"value"`   // Value of the key-value pair
	ColName string `json:"colname"` // Name of the associated column
}

// KeyPairStruct represents a key-value pair structure, typically used in lookup values.
type KeyPairLookupStruct struct {
	Code        string `json:"code"`        // Key of the key-value pair
	Description string `json:"description"` // Value of the key-value pair
}

// LookupValRespStruct represents the structure for the response of a lookup values request.
type LookupValRespStruct struct {
	Code           string            `json:"code"`
	ReferenceVal   string            `json:"referenceval"`
	RequestedAttr  string            `json:"requestedattr"`
	Description    string            `json:"description"`
	LookupValueArr map[string]string `json:"lookupvaluearr"`
	Status         string            `json:"status"`
	ErrMsg         string            `json:"errmsg"`
}

type LookupHeaderRespStruct struct {
	LookupValueArr []KeyPairLookupStruct `json:"lookupvaluearr"`
	Status         string                `json:"status"`
	ErrMsg         string                `json:"errmsg"`
}

type DescriptionResp struct {
	Code        string `json:"code"`
	Descirption string `json:"descirption"`
	Status      string `json:"status"`
	ErrMsg      string `json:"errmsg"`
}

/*
   Purpose: This API is used to get the Requested Lookup headers Details that falls under the given header
   Request: {
				"Code" : "MARITAL STATUS",
				"givendetail" : "M",
				"detailtype" : "All"
			}
   ========
   Header: N/A
   Response:
   On success
   ==========
   {
    "Code": "MARITAL STATUS",
    "givendetail": "M",
    "detailtype": "All",
    "keypairarr": [
        {
            "key": "KRA",
            "value": "",
            "colname": "Attr1"
        },
        {
            "key": "NSE",
            "value": "M",
            "colname": "Attr2"
        },
        {
            "key": "TECHEXCEL",
            "value": "M",
            "colname": "Attr3"
        }
    ],
    "status": "",
    "errmsg": ""
}
	On Error
   =========
{
    "status": "E",
    "statusCode": "EGLBD04 ",
    "msg": "Something went wrong. Please try again later."
}
   Authorization: Ayyanar
   Date: '31-01-2024'
*/

func GetLookupByRef(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "PUT, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
	lDebug.Log(helpers.Statement, "GetLookupByRef (+)")
	if strings.EqualFold(r.Method, "PUT") {
		var lGivenData LookupValStruct
		var lResponse LookupValRespStruct

		// Read the request body using ioutil.ReadAll() function
		lBody, lErr := ioutil.ReadAll(r.Body)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "EGLVR01 "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("EGLVR01 ", "Something went wrong. Please try again later."))
			return
		}

		// Unmarshal the JSON data from the request body into the lGivenData struct
		lErr = json.Unmarshal(lBody, &lGivenData)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "EGLVR02 "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("EGLVR02 ", "Something went wrong. Please try again later."))
			return
		}

		lResponse, lErr = GetAttributes(lDebug, lGivenData, "")
		if lErr != nil {
			lDebug.Log(helpers.Elog, "EGLVR04 "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("EGLVR04 ", "Something went wrong. Please try again later."))
			return
		}

		// Marshal the lResponse data into JSON format
		lData, lErr := json.Marshal(lResponse)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("E", lErr.Error()))
			return
		} else {
			fmt.Fprint(w, string(lData))
		}

		lDebug.Log(helpers.Statement, "GetLookupByRef (-)")

	}
}

/*
   Purpose: This API is used to get the Requested Lookup headers Details that falls under the given header
   Request: {
				"Code" : "MARITAL STATUS",
				"givendetail" : "M",
				"detailtype" : "All"
			}
   ========
   Header: N/A
   Response:
   On success
   ==========
   {
    "Code": "MARITAL STATUS",
    "givendetail": "M",
    "detailtype": "All",
    "keypairarr": [
        {
            "key": "KRA",
            "value": "",
            "colname": "Attr1"
        },
        {
            "key": "NSE",
            "value": "M",
            "colname": "Attr2"
        },
        {
            "key": "TECHEXCEL",
            "value": "M",
            "colname": "Attr3"
        }
    ],
    "status": "",
    "errmsg": ""
}
	On Error
   =========
{
    "status": "E",
    "statusCode": "EGLBD04 ",
    "msg": "Something went wrong. Please try again later."
}
   Authorization: Ayyanar
   Date: '31-01-2024'
*/

func GetLookupByDesc(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "PUT, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
	lDebug.Log(helpers.Statement, "GetLookupByDesc (+)")
	if strings.EqualFold(r.Method, "PUT") {
		var lGivenData LookupValStruct
		var lResponse LookupValRespStruct

		// Read the request body using ioutil.ReadAll() function
		lBody, lErr := ioutil.ReadAll(r.Body)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "EGLBD01 "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("EGLBD01 ", "Something went wrong. Please try again later."))
			return
		}

		// Unmarshal the JSON data from the request body into the lGivenData struct
		lErr = json.Unmarshal(lBody, &lGivenData)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "EGLBD02 "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("EGLBD02 ", "Something went wrong. Please try again later."))
			return
		}

		lResponse, lErr = GetAttributes(lDebug, lGivenData, "")
		if lErr != nil {
			lDebug.Log(helpers.Elog, "EGLBD04 "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("EGLBD04 ", "Something went wrong. Please try again later."))
			return
		}

		// Marshal the lResponse data into JSON format
		lData, lErr := json.Marshal(lResponse)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("E", lErr.Error()))
			return
		} else {
			fmt.Fprint(w, string(lData))
		}

		lDebug.Log(helpers.Statement, "GetLookupByDesc (-)")

	}
}

/*
   Purpose: This method is used to get Lookup header Details
   Parameters: *sql.DB , *helpers.HelperStruct ,LookupValStruct
   Response:
   On success
   ==========
   lResponse : {"Code":"MARITAL STATUS","givendetail":"M","detailtype":"All","keypairarr":[{"key":"KRA","value":"","colname":"Attr1"},{"key":"NSE","value":"M","colname":"Attr2"},{"key":"TECHEXCEL","value":"M","colname":"Attr3"}],"status":"","errmsg":""}
   lErr : nil
   On error
   ========
   lResponse : null,
   lErr : "Syntax Error"
   Authorization: Ayyanar
   Date: '31-01-2024'
*/

func GetAttributes(pDebug *helpers.HelperStruct, pData LookupValStruct, pIndicator string) (LookupValRespStruct, error) {
	pDebug.Log(helpers.Statement, "GetAttributes (+)")
	var lResponse LookupValRespStruct
	var lKeyRec KeyPairStruct
	var lKeyArr []KeyPairStruct

	// Set initial values for response struct
	lResponse.RequestedAttr = pData.RequestedAttr
	lResponse.Code = pData.Code
	lResponse.ReferenceVal = pData.ReferenceVal
	lResponse.Description = pData.Description

	// Construct the SQL query based on the provided data
	lPromptCondition := ""
	if pData.RequestedAttr != "All" {
		lPromptCondition = "and Prompt = '" + pData.RequestedAttr + "'"
	} else {
		lPromptCondition = ""
	}
	CoreString := `select Prompt , fieldname
					from lookup_additional_setup_details lasd ,lookup_additional_setup las
					where SetupId = las.id
					and lookup_header_id = (select id from lookup_header lh where lh.code = ? )` + lPromptCondition

	// Execute the SQL query to retrieve attributes
	lRows, lErr := ftdb.NewEkyc_GDB.Query(CoreString, pData.Code)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lResponse, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lKeyRec.Key, &lKeyRec.ColName)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return lResponse, helpers.ErrReturn(lErr)
		}
		// Append the key pair to the response's KeyPairArr
		lKeyArr = append(lKeyArr, lKeyRec)
	}

	// Call the GetAttributes function to further process the response
	lResponse, lErr = GetLookupVal(pDebug, lResponse, lKeyArr, pIndicator)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lResponse, helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "GetAttributes (-)")
	return lResponse, nil
}

/*
   Purpose: This method is used to get Lookup Values
   Parameters: *sql.DB , *helpers.HelperStruct ,LookupValRespStruct
   Response:
   On success
   ==========
   lResponse : {"Code":"MARITAL STATUS","ReferenceVal":"M","detailtype":"All","keypairarr":[{"key":"KRA","value":"","colname":"Attr1"},{"key":"NSE","value":"M","colname":"Attr2"},{"key":"TECHEXCEL","value":"M","colname":"Attr3"}],"status":"","errmsg":""}
   lErr : nil
   On error
   ========
   lResponse : null,
   lErr : "Syntax Error"
   Authorization: Ayyanar
   Date: '31-01-2024'
*/

func GetLookupVal(pDebug *helpers.HelperStruct, pData LookupValRespStruct, pKeyArr []KeyPairStruct, pIndicator string) (LookupValRespStruct, error) {
	pDebug.Log(helpers.Statement, "GetLookupVal (+)")

	pData.LookupValueArr = make(map[string]string)
	var lCondition string
	var lField string
	var lErr error
	if pData.ReferenceVal == "" {
		lCondition = "and ld.description = '" + pData.Description + "'"
	} else {
		if strings.EqualFold(pIndicator, "code") {
			lCondition = `and (ld.Code = '` + pData.ReferenceVal + `')`
		} else {
			lField, lErr = GetPromptValue(pDebug, pData.Code, pData.RequestedAttr)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return pData, helpers.ErrReturn(lErr)
			}
			// 	lCondition = `and (ld.Code = '` + pData.ReferenceVal + `' or ld.Attr1 = '` + pData.ReferenceVal + `' or  ld.Attr2= '` + pData.ReferenceVal + `' or  ld.Attr3 = '` + pData.ReferenceVal + `' or  ld.Attr4= '` + pData.ReferenceVal + `' or
			// ld.Attr5= '` + pData.ReferenceVal + `' or  ld.Attr6= '` + pData.ReferenceVal + `' or  ld.Attr7= '` + pData.ReferenceVal + `' or ld.Attr8= '` + pData.ReferenceVal + `' or  ld.Attr9= '` + pData.ReferenceVal + `' or  ld.Attr10 = '` + pData.ReferenceVal + `') `
			lCondition = `and (ld.Code = '` + pData.ReferenceVal + `' or ld.` + lField + `= '` + pData.ReferenceVal + `')`
		}
	}

	// Iterate through the KeyPairArr in the provided data
	for i := 0; i < len(pKeyArr); i++ {

		// Construct the SQL query based on the current key
		CoreString := `select ` + pKeyArr[i].ColName + ` from lookup_details ld
						where headerid in (select id from lookup_header lh where lh.code = ?) ` + lCondition

		pDebug.Log(helpers.Details, "Corestring ", i, " ->", CoreString)

		// Execute the SQL query to retrieve additional values for the current key
		lRows, lErr := ftdb.NewEkyc_GDB.Query(CoreString, pData.Code)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return pData, helpers.ErrReturn(lErr)
		}
		defer lRows.Close()
		// Iterate through the query result rows
		for lRows.Next() {
			lErr = lRows.Scan(&pKeyArr[i].Value)
			if lErr != nil {
				pDebug.Log(helpers.Elog, lErr.Error())
				return pData, helpers.ErrReturn(lErr)
			}
		}
		pData.LookupValueArr[pKeyArr[i].Key] = pKeyArr[i].Value
	}
	pDebug.Log(helpers.Statement, "GetLookupVal (-)")
	return pData, nil
}

/*
   Purpose: This API is used to get the Requested Lookup headers Details that falls under the given header
   Request: {
				"Code" : "MARITAL STATUS",
				"givendetail" : "M",
				"detailtype" : "All"
			}
   ========
   Header: N/A
   Response:
   On success
   ==========
   {
    "Code": "MARITAL STATUS",
    "givendetail": "M",
    "detailtype": "All",
    "keypairarr": [
        {
            "key": "KRA",
            "value": "",
            "colname": "Attr1"
        },
        {
            "key": "NSE",
            "value": "M",
            "colname": "Attr2"
        },
        {
            "key": "TECHEXCEL",
            "value": "M",
            "colname": "Attr3"
        }
    ],
    "status": "",
    "errmsg": ""
}
	On Error
   =========
{
    "status": "E",
    "statusCode": "EGLBD04 ",
    "msg": "Something went wrong. Please try again later."
}
   Authorization: Ayyanar
   Date: '31-01-2024'
*/

func GetLookupByHeader(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetLookupByHeader (+)")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Cache-Control", "no-cache, no-store, must-revalidate")
	(w).Header().Set("Access-Control-Allow-Headers", "code, type, Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
	if strings.EqualFold(r.Method, "GET") {

		lHeaderVal := r.Header.Get("code")
		lIndicator := r.Header.Get("type")

		lResponse, lErr := GetHeaderVal(lDebug, lHeaderVal, lIndicator)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "EGLBH02 "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("EGLBH02 ", "Something went wrong. Please try again later."))
			return
		}
		lResponse.Status = common.SuccessCode
		// Marshal the lResponse data into JSON format
		lData, lErr := json.Marshal(lResponse)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("E", lErr.Error()))
			return
		} else {
			fmt.Fprint(w, string(lData))
		}

		lDebug.Log(helpers.Statement, "GetLookupByHeader (-)")

	}
}

func GetHeaderVal(pDebug *helpers.HelperStruct, pHeaderCode, pIndicator string) (LookupHeaderRespStruct, error) {
	pDebug.Log(helpers.Statement, "GetHeaderVal (+)")
	var lResponse LookupHeaderRespStruct
	var lKeyPairRec KeyPairLookupStruct
	var lSelect string
	var lCondition string

	if pIndicator == "" || strings.EqualFold(pIndicator, "Default") {
		lSelect = " ld.code "
		// lCondition = "and nvl(ld.code,'') != ''"
		lCondition = "and isScreenVisible ='Y'"
	} else {
		lAttribute, lErr := GetPromptValue(pDebug, pHeaderCode, pIndicator)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return lResponse, helpers.ErrReturn(lErr)
		}
		lSelect = " ld." + lAttribute
		lCondition = " and nvl(ld." + lAttribute + ",'') != ''"
	}

	// visibleCondition := ` and ld.isScreenVisible ='Y' order by ld.DisplayOrder asc`

	lCoreString := `select ` + lSelect + `, ld.description 
					from lookup_header lh ,lookup_details ld
					WHERE lh.id = ld.headerid
					and lh.code = ? ` + lCondition
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pHeaderCode)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lResponse, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lKeyPairRec.Code, &lKeyPairRec.Description)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return lResponse, helpers.ErrReturn(lErr)
		}
		// Append the key pair to the response's LookupValueArr Map
		lResponse.LookupValueArr = append(lResponse.LookupValueArr, lKeyPairRec)
	}
	pDebug.Log(helpers.Statement, "GetHeaderVal (-)")
	return lResponse, nil
}

func GetPromptValue(pDebug *helpers.HelperStruct, pHeaderCode, pIndicator string) (string, error) {
	pDebug.Log(helpers.Statement, "GetPromptValue (-)")
	lFieldName := ""

	lCoreString := `select fieldname
	from lookup_additional_setup_details lasd ,lookup_additional_setup las
	where SetupId = las.id
	and lookup_header_id = (select id from lookup_header lh where lh.code = ? ) 
	and prompt = ? `

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pHeaderCode, pIndicator)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lFieldName)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return "", helpers.ErrReturn(lErr)
		}
	}

	if lFieldName == "" {
		pDebug.Log(helpers.Elog, "invalid attribute name")
		return "", fmt.Errorf("invalid attribute name")
	}

	pDebug.Log(helpers.Statement, "GetPromptValue (-)")
	return lFieldName, nil
}

func GetDescriptionByRef(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "CODE, REFERENCE , PROMPT , Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
	lDebug.Log(helpers.Statement, "GetDescriptionByRef (+)")
	if strings.EqualFold(r.Method, "GET") {

		lHeaderVal := r.Header.Get("CODE")
		lReference := r.Header.Get("REFERENCE")
		lPrompt := r.Header.Get("PROMPT")

		lResponse, lErr := GetLookUpDescription(lDebug, lHeaderVal, lReference, lPrompt)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "EGDBR02 "+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("EGDBR02 ", "Something went wrong. Please try again later."))
			return
		}

		// Marshal the lResponse data into JSON format
		lData, lErr := json.Marshal(lResponse)
		if lErr != nil {
			lDebug.Log(helpers.Elog, lErr.Error())
			// fmt.Fprint(w, helpers.GetError_String("E", lErr.Error()))
			fmt.Fprint(w, helpers.GetError_String("E", "Something went wrong. Please try again later."))
			return
		} else {
			fmt.Fprint(w, string(lData))
		}

		lDebug.Log(helpers.Statement, "GetDescriptionByRef (-)")

	}
}

func GetLookUpDescription(pDebug *helpers.HelperStruct, pHeaderCode, pIndicator, pPrompt string) (DescriptionResp, error) {
	pDebug.Log(helpers.Statement, "GetLookUpDescription (+)")
	var lResponse DescriptionResp
	var lCondition string
	var lField string
	var lErr error
	// fmt.Println("zdfhxfgndxfghn", pHeaderCode, pIndicator)

	if pHeaderCode == "" || pIndicator == "" {
		return lResponse, fmt.Errorf("pHeaderCode and pIndicator should have some value ")
	}

	if strings.EqualFold(pPrompt, "code") {
		lCondition = "and ld.code = '" + pIndicator + "'"
	} else {
		lField, lErr = GetPromptValue(pDebug, pHeaderCode, pPrompt)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return lResponse, helpers.ErrReturn(lErr)
		}
		// lCondition = `and lasd.Prompt = '` + pPrompt + `'
		// and (ld.Attr1 = '` + pIndicator + `'  or  ld.Attr2= '` + pIndicator + `'  or  ld.Attr3 = '` + pIndicator + `'  or  ld.Attr4= '` + pIndicator + `'  or ld.Attr5= '` + pIndicator + `'  or  ld.Attr6= '` + pIndicator + `'  or  ld.Attr7= '` + pIndicator + `'  or ld.Attr8= '` + pPrompt + `'  or  ld.Attr9= '` + pPrompt + `'  or  ld.Attr10 = '` + pPrompt + `' )`
		lCondition = `and lasd.Prompt = '` + pPrompt + `' 
		and ld.` + lField + ` = '` + pIndicator + `'`
	}
	lResponse.Status = "S"
	lCoreString := `select ld.description , lasd.prompt 
	from lookup_header lh ,lookup_details ld , lookup_additional_setup las ,lookup_additional_setup_details lasd 
	where lh.Code = ?
	and lh.id =ld.headerid 
	and las.lookup_header_id = lh.id 
	and lasd.SetupId =las.id
	` + lCondition

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pHeaderCode)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return lResponse, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lResponse.Descirption, &lResponse.Code)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return lResponse, helpers.ErrReturn(lErr)
		}
	}

	if lResponse.Code == "" || lResponse.Descirption == "" {
		lResponse.ErrMsg = "DATA NOT FOUND"
		lResponse.Status = "E"
	}

	pDebug.Log(helpers.Statement, "GetLookUpDescription (-)")
	return lResponse, nil
}

func GetDefaultCode(pDebug *helpers.HelperStruct, pHeaderCode, pDescription string) (string, error) {
	pDebug.Log(helpers.Statement, "GetDefaultCode (+)")
	var lDescirption string
	lCoreString := `select ld.code
					from lookup_header lh ,lookup_details ld 
					where lh.id = ld.headerid 
					and  lh.Code = ?
					and ld.description = ?`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pHeaderCode, pDescription)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lDescirption)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return "", helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "GetDefaultCode (-)")
	return lDescirption, nil
}
func GetDefaultCodeFromPrompt(pDebug *helpers.HelperStruct, pHeaderCode, pPrompt, pCode string) (string, error) {
	pDebug.Log(helpers.Statement, "GetDefaultCodeFromPrompt (+)")

	var lDefaultCode, lPromtValue string
	lCoreString := `select fieldname from lookup_additional_setup_details lasd ,lookup_additional_setup las
	where SetupId = las.id
	and lookup_header_id = (select id from lookup_header lh where lh.code = ? )
	and prompt = ?`

	pDebug.Log(helpers.Details, "lCoreString1111", lCoreString)
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pHeaderCode, pPrompt)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	for lRows.Next() {
		lErr = lRows.Scan(&lPromtValue)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return "", helpers.ErrReturn(lErr)
		}
	}

	lCoreString = `select code from lookup_details where ` + lPromtValue + `=? and headerid = (select id from lookup_header lh where lh.code = ? ) `

	lRows, lErr = ftdb.NewEkyc_GDB.Query(lCoreString, pCode, pHeaderCode)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	for lRows.Next() {
		lErr = lRows.Scan(&lDefaultCode)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return "", helpers.ErrReturn(lErr)
		}
	}
	pDebug.Log(helpers.Statement, "GetDefaultCodeFromPrompt (-)", lDefaultCode)
	return lDefaultCode, nil
}
