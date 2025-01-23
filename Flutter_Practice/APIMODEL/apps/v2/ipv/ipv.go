package ipv

import (
	"encoding/json"
	"fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/file"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fmt"
	"net/http"
	"strings"
)

type IPVstruct struct {
	IPVtype      string  `json:"IPVtype"`
	Giolatitude  float32 `json:"latitude"`
	Giolongitude float32 `json:"longitude"`
	Giotimestamp int     `json:"timestamp"`
	Code         string  `json:"IPVotp"`
}

func GetIPV(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetIPV (+)")

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if strings.EqualFold(r.Method, "POST") {
		var lIPVRec IPVstruct

		lFileBody, lHeader, lErr := r.FormFile("ipv")
		if lErr != nil {
			lDebug.Log(helpers.Elog, "IGI01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("IGI01", "Somthing is wrong please try again later"))
			return
		}
		lFinal, lErr := file.FileStorage(lFileBody, lHeader)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "IGI02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("IGI02", "Somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "final:", lFinal)

		var lFinalArr []file.FileDataType
		lFinalArr = append(lFinalArr, *lFinal)
		lInsertArr, lErr := file.InsertIntoAttachments( lFinalArr, "EKYC")
		if lErr != nil {
			lDebug.Log(helpers.Elog, "IGI04", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("IGI04", "Somthing is wrong please try again later"))
			return
		}
		lDebug.Log(helpers.Details, "lInsertArr:", lInsertArr)

		lipvdata := r.FormValue("ipvdata")
		lDebug.Log(helpers.Details, "ipvdata:", lipvdata)
		lErr = json.Unmarshal([]byte(lipvdata), &lIPVRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "IGI05", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("IGI05", "Somthing is wrong please try again later"))
			return
		}

		lErr = IPVEntry(lDebug, r, lInsertArr[0].DocId, lIPVRec)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "IGI06", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("IGI06", "Somthing is wrong please try again later"))
			return
		}

		lDebug.Log(helpers.Details, "data :", lIPVRec)

		fmt.Fprint(w, helpers.GetMsg_String("IGI", "IPV SUCCESS"))
	}

	lDebug.Log(helpers.Statement, "GetIPV (-)")
}

func IPVEntry(pDebug *helpers.HelperStruct, r *http.Request, pDocID string, pIPVData IPVstruct) error {
	pDebug.Log(helpers.Statement, "IPVEntry (+)")



	lSid, lUid, lErr := sessionid.GetOldSessionUID(r, pDebug, common.EKYCCookieName)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	var lVideoID, lImgID string

	if strings.EqualFold(pIPVData.IPVtype, "VIDEO") {
		lVideoID = pDocID
	} else {
		lImgID = pDocID
	}

	lInsertString := `
	IF EXISTS (SELECT * FROM ekyc_ipv ei WHERE ei.Request_Uid=?)
    then
    	update ekyc_ipv set ipv_otp=?,video_Doc_Id=?,image_Doc_Id=?,latitude=?,longitude=?,time_stamp=?,Updated_Session_Id=?,UpdatedDate=unix_timestamp()
		where Request_Uid=?;
    ELSE
    	insert into ekyc_ipv(Request_Uid,ipv_otp,video_Doc_Id,image_Doc_Id,latitude,longitude,time_stamp,Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate)
    	values(?,?,?,?,?,?,?,?,?,unix_timestamp(),unix_timestamp());
    END IF;
	`

	_, lErr = ftdb.NewEkyc_GDB.Exec(lInsertString, lUid, pIPVData.Code, lVideoID, lImgID, pIPVData.Giolatitude, pIPVData.Giolongitude, pIPVData.Giotimestamp, lSid, lUid, lUid, pIPVData.Code, lVideoID, lImgID, pIPVData.Giolatitude, pIPVData.Giolongitude, pIPVData.Giotimestamp, lSid, lSid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = sessionid.UpdateZohoCrmDeals(pDebug, r, common.IPVVerified)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	lErr = router.StatusInsert(pDebug, lUid, lSid, "IPV")
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "IPVEntry (-)")
	return nil
}

type AdrsStatusStruct struct {
	Status  string `json:"status"`
	IPVtype string `json:"IPVtype"`
	Code    string `json:"code"`
	DocId   string `json:"DocId"`
}

// func GetIPVType(w http.ResponseWriter, r *http.Request) {
// 	lDebug := new(helpers.HelperStruct)
// 	lDebug.SetUid(r)
// 	lDebug.Log(helpers.Statement, "GetIPVType (+)")

// 	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
// 	w.Header().Set("Access-Control-Allow-Credentials", "true")
// 	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
// 	w.Header().Set("Access-Control-Allow-Methods", "GET")
// 	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

// 	var lAdrsComRec AdrsStatusStruct
// 	lAdrsComRec.Status = common.SuccessCode
// 	var lDocId, lOTP string

// 	if strings.EqualFold("get", r.Method) {
// 		_, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
// 		if lErr != nil {
// 			lDebug.Log(helpers.Elog, "GIT01", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("GIT01", "Somthing is wrong please try again later"))
// 			return
// 		}
// 		lDb, lErr := ftdb.LocalDbConnect(ftdb.NewKycDB)

// 		if lErr != nil {
// 			lDebug.Log(helpers.Elog, "GIT02", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("GIT02", "Somthing is wrong please try again later"))
// 			return
// 		}
// 		defer lDb.Close()

// 		lAdrsComeFrom := ""
// 		lCorestring := `
// 		select ea.Source_Of_Address
// 		from ekyc_address ea
// 		where ea.Request_Uid =?`
// 		lRows, lErr := lDb.Query(lCorestring, lUid)
// 		if lErr != nil {
// 			lDebug.Log(helpers.Elog, "GIT03", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("GIT03", "Somthing is wrong please try again later"))
// 			return
// 		}
// 		for lRows.Next() {
// 			lErr := lRows.Scan(&lAdrsComeFrom)
// 			lDebug.Log(helpers.Details, "lRows", lRows)
// 			if lErr != nil {
// 				lDebug.Log(helpers.Elog, "GIT04", lErr.Error())
// 				fmt.Fprint(w, helpers.GetError_String("GIT04", "Somthing is wrong please try again later"))
// 				return
// 			}
// 		}

// 		if strings.EqualFold(lAdrsComeFrom, "Digilocker") {
// 			lAdrsComRec.IPVtype = "PHOTO"
// 		} else {
// 			lAdrsComRec.IPVtype = "VIDEO"
// 		}

// 		lCorestring = `select if(video_Doc_Id ="",image_Doc_Id,video_Doc_Id) as docid,ipv_otp
// 		from ekyc_ipv
// 		where Request_Uid=?  `

// 		lRows, lErr = lDb.Query(lCorestring, lUid)
// 		if lErr != nil {
// 			lDebug.Log(helpers.Elog, "GIT05", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("GIT05", "Somthing is wrong please try again later"))
// 			return
// 		}
// 		for lRows.Next() {
// 			lErr := lRows.Scan(&lDocId, &lOTP)
// 			lDebug.Log(helpers.Details, "lRows", lRows)
// 			if lErr != nil {
// 				lDebug.Log(helpers.Elog, "GIT06", lErr.Error())
// 				fmt.Fprint(w, helpers.GetError_String("GIT06", "Somthing is wrong please try again later"))
// 				return
// 			}
// 		}

// 		lAdrsComRec.DocId = lDocId

// 		lAdrsComRec.Code = common.GenerateOTP()

// 		lDatas, lErr := json.Marshal(&lAdrsComRec)
// 		lDebug.Log(helpers.Details, "lDatas", string(lDatas))

// 		if lErr != nil {
// 			lDebug.Log(helpers.Elog, "GIT07", lErr.Error())
// 			fmt.Fprint(w, helpers.GetError_String("GIT07", "Somthing is wrong please try again later"))
// 			return
// 		}
// 		fmt.Fprint(w, string(lDatas))

// 	}
// 	lDebug.Log(helpers.Statement, "GetIPVType (-)")

// }
