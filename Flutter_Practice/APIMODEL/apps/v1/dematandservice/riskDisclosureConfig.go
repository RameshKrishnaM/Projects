package dematandservice

import (
	"encoding/json"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

type RiskDisclosureInsReqStruct struct {
	ContentId   string `json:"contentid"`
	ContentType string `json:"contenttype"`
}

/*
Pupose: The Purpose of this Api is for to insert the details in riskdisclosure_master table
Parameters: nil

Response:
    On Sucess
    =========
	Get the success response as this
	{"status":"S","title":"S","description":"Inserted successfully"}

	On Error
	    ========
	Get the Error response as this
	{"msg":"based on error","status":"E","statusCode":"E"}

Author: thameem ansari k
Date: 13-Feb-2024
Modify Author: Sowmiya L
Modify Date: 09-04-2024
*/

func RiskdisclosureInsert(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "RiskdisclosureInsert(+)")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	if r.Method == "POST" {
		var lRequestRec RiskDisclosureInsReqStruct
		lBody, lErr := ioutil.ReadAll(r.Body)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "Error : RDCI01 ", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("E", "Error : RDCI01 "+helpers.ErrPrint(lErr)))
			return
		} else {
			lErr = json.Unmarshal(lBody, &lRequestRec)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "Error : RDCI02 ", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("E", "Error : RDCI02 "+helpers.ErrPrint(lErr)))
				return
			} else {
				lDeviceIp := r.RemoteAddr
				lDevicetype := r.Header.Get("User-Agent")
				lDevicetype = sessionid.GetOSFromUserAgent(lDebug, lDevicetype)
				_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "SSB04", lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("RDCI04", "Somthing is wrong please try again later"))
					return
				}
				lMsg, lErr := RiskDisclosureInsertImplement(lRequestRec, lDebug, lUid, lDevicetype, lDeviceIp)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "Error : RDCI03 ", lErr.Error())
					fmt.Fprint(w, helpers.GetError_String("E", "Error : RDCI03 "+helpers.ErrPrint(lErr)))
					return
				} else {
					if lMsg != "" {
						lDebug.Log(helpers.Elog, lMsg)
						fmt.Fprint(w, helpers.GetError_String("E", lMsg))
						return
					} else {
						fmt.Fprint(w, helpers.GetMsg_String("S", "Inserted successfully"))
					}
				}
			}

		}

	}
	lDebug.Log(helpers.Statement, "RiskdisclosureInsert(-)")
}

/*
Pupose: The Purpose of this Method is for to check the data already present , if data not present then
it will insert the details
Parameters:  RiskDisclosureReqStruct, helpers.HelperStruct

Response:
    On Sucess
    =========
	string , nil



    On Error
    ========
	"", error


Author: thameem ansari k
Date: 13-Feb-2024
Modify Author: Sowmiya L
Modify Date: 09-04-2024
*/

func RiskDisclosureInsertImplement(pRequestRec RiskDisclosureInsReqStruct, pDebug *helpers.HelperStruct, pReqeustid, pDevicetype, pDeviceIp string) (string, error) {
	pDebug.Log(helpers.Statement, "RiskDisclosureInsertImplement(+)")
	var lMsg string

	lErr := InsertInRiskDisclosure(pRequestRec, pDebug, pReqeustid, pDevicetype, pDeviceIp)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "Error : RDCII04 ", lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "RiskDisclosureInsertImplement(-)")
	return lMsg, nil
}

/*
Pupose: The Purpose of this Method is for to insert the data in riskdisclosure_master table
Parameters:  *sql.DB, RiskDisclosureReqStruct, helpers.HelperStruct

Response:
    On Sucess
    =========
	return error as nil

    On Error
    ========
	return error message


Author: thameem ansari
Date: 13-Feb-2024
Modify Author: Sowmiya L
Modify Date: 09-04-2024
*/

func InsertInRiskDisclosure(pRequestRec RiskDisclosureInsReqStruct, pDebug *helpers.HelperStruct, pRequestid, pDevicetype, pDeviceIp string) error {
	pDebug.Log(helpers.Statement, "InsertInRiskDisclosure(+)")
	lCoreString := `INSERT INTO acceptence_history
		(Request_Uid, deviceType, deviceIp, contentId, acceptDateTime, acceptenceType, CreatedBy, CreatedDate, updatedBy, updatedDate)
		VALUES(?, ?, ?, ?, now(), ?, 'Autobot', now(), 'Autobot', now());`

	_, lErr := ftdb.NewEkyc_GDB.Exec(lCoreString, pRequestid, pDevicetype, pDeviceIp, pRequestRec.ContentId, pRequestRec.ContentType)
	if lErr != nil {
		log.Println("Error : IIRD01 ", lErr.Error())
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Statement, "InsertInRiskdisClosure(-)")
	return nil
}

// -------------GET API--------------
type ContentStruct struct {
}

type GetRiskDisclosureRespStruct struct {
	Title          string `json:"title"`
	TitleRGBColor  string `json:"titlerbgcolor"`
	Content        string `json:"content"`
	ContentId      string `json:"contentid"`
	EndDateTime    string `json:"enddatetime"`
	StartDateTime  string `json:"startdatetime"`
	ButtonText     string `json:"buttontext"`
	Mandatory      string `json:"mandatory"`
	DisplayStyle   string `json:"displaystyle"`
	ButtonRGBColor string `json:"buttonrbgcolor"`
	ContentType    string `json:"contenttype"`
	CreatedBy      string `json:"createdby"`
}

type RiskDisclousreArr struct {
	RiskDisclosureRec GetRiskDisclosureRespStruct `json:"riskDisclosure"`
	ErrMsg            string                      `json:"errMsg"`
	Status            string                      `json:"status"`
}

/*
Pupose: The Purpose of this Api is used to select the existing records from riskdisclosure_master table
Parameters: nil

Response:
    On Sucess
    =========
	Get the success response as this
	{"status":"S","errmsg":"","ContentArr":""}

	On Error
	    ========
	Get the Error response as this
	{"msg":"based on error","status":"E","statusCode":"E"}

Author: thameem ansari k
Date: 16-Feb-2024
Modify Author: Sowmiya L
Modify Date: 09-04-2024
*/
func GetRiskDisclosureApi(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetRiskDisclosureDataApi(+)")
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "contenttype,Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
	if r.Method == "GET" {
		var lRequestRec GetRiskDisclosureRespStruct
		var lResponseRec RiskDisclousreArr
		lResponseRec.Status = "S"
		var lErr error
		lContentType := r.Header.Get("contenttype")
		lResponseRec.RiskDisclosureRec, lErr = GetRiskDisclosureData(lDebug, lRequestRec, lContentType)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GRDA01 ERROR : ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "GRDA01 ERROR : "+lErr.Error()))
			return
		}
		// marshal
		lData, lErr := json.Marshal(lResponseRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "GRDA02 ERROR : ", lErr)
			fmt.Fprint(w, helpers.GetError_String("E", "GRDA02 ERROR : "+lErr.Error()))
			return
		}
		fmt.Fprint(w, string(lData))

	}
	lDebug.Log(helpers.Statement, "GetRiskDisclosureDataApi(-)")
}

/*
Pupose: The Purpose of this Method is for to Change the hex formatted color into RGBA color Format
Parameters: helpers.HelperStruct, []ContentStruct

Response:
    On Sucess
    =========
	Return the []ContentStruct, nil

    On Error
    ========
	Retrun []ContentStruct, error

Author: Thameem ansari k
Date: 16-Feb-2024
Modify Author: Sowmiya L
Modify Date: 09-04-2024
*/
func GetRiskDisclosureData(pDebug *helpers.HelperStruct, lRequestRec GetRiskDisclosureRespStruct, pContentType string) (GetRiskDisclosureRespStruct, error) {
	pDebug.Log(helpers.Statement, "GetRiskDisclosureData(+)")

	lSqlString := `select nvl(id,0) id,nvl(Title,'') Title,nvl(TitleRGBColor,'') TitleRGBColor,nvl(Content,'') Content, nvl(startDateTime,'') startDateTime ,
		nvl(endDateTime ,'') endDateTime,nvl(mandatory,'') mandatory,nvl(buttonRGBColor,'') buttonRGBColor
		,nvl(buttonText,'') buttonText,nvl(DisplayStyle,'') DisplayStyle,nvl(contentType,'')contentType,nvl(createdBy,'') createdBy from riskdisclosure_master 
		where contentType=?`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lSqlString, pContentType)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GRDD02 ERROR : ", lErr)
		return lRequestRec, helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			err := lRows.Scan(&lRequestRec.ContentId, &lRequestRec.Title, &lRequestRec.TitleRGBColor, &lRequestRec.Content, &lRequestRec.StartDateTime,
				&lRequestRec.EndDateTime, &lRequestRec.Mandatory, &lRequestRec.ButtonRGBColor, &lRequestRec.ButtonText, &lRequestRec.DisplayStyle, &lRequestRec.ContentType, &lRequestRec.CreatedBy)
			if err != nil {
				log.Println(err.Error() + "(FPC04)")
				return lRequestRec, err
			}
		}
	}

	pDebug.Log(helpers.Statement, "GetRiskDisclosureData(-)")
	return lRequestRec, nil
}
