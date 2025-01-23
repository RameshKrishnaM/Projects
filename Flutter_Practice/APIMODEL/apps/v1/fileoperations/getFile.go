package fileoperations

import (
	"encoding/base64"
	"encoding/json"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fcs23pkg/integration/v1/pdfgenerate"
	"fmt"
	"net/http"
	"net/url"
)

/*
Purpose : This method is used to fetch the files in db
Request : N/A
Response :
===========
On Success:
===========
{
"Status": "Success",
}
===========
On Error:
===========
"Error": "Something went wrong"
Author : Sowmiya L
Date : 14-July-2023
*/
func DownloadFile(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	// w.WriteHeader(200)
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "DownloadFile (+)")

	if r.Method == "GET" {
		//parse the query paraemters sent in the api end point
		lFullpath := r.URL.Path + "?" + r.URL.RawQuery
		lDebug.Log(helpers.Details, "lFullpath", lFullpath)
		lUrl, lErr := url.Parse(lFullpath)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DF01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DF01", "Something went wrong. Please try agin later."))
			return
		}
		//get parameter values
		q := lUrl.Query()
		//if id query parameter value is passed
		if q.Get("id") == "undefined" && q.Get("id") == "" {
			lDebug.Log(helpers.Elog, "DF02 id value is undefined")
			fmt.Fprint(w, helpers.GetError_String("DF02", "Something went wrong. Please try agin later."))
			return
		}
		lFileInfo, lErr := pdfgenerate.Read_file(lDebug, q.Get("id"))
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DF03"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DF03", "Something went wrong. Please try agin later."))
			return
		}

		lDatas, lErr := json.Marshal(lFileInfo)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DF04"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DF04", "Something went wrong. Please try agin later."))
			return
		}
		fmt.Fprint(w, string(lDatas))
		lDebug.Log(helpers.Statement, "DownloadFile (-)")
	}
}

func FetchRawFile(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	// w.WriteHeader(200)
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "FetchRawFile (+)")

	if r.Method == "GET" {
		//parse the query paraemters sent in the api end point
		lFullpath := r.URL.Path + "?" + r.URL.RawQuery
		lDebug.Log(helpers.Details, "lFullpath", lFullpath)
		lUrl, lErr := url.Parse(lFullpath)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "FF01"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("FF01", "Something went wrong. Please try agin later."))
			return
		}
		//get parameter values
		q := lUrl.Query()
		//if id query parameter value is passed
		if q.Get("id") == "undefined" && q.Get("id") == "" {
			lDebug.Log(helpers.Elog, "DF02 id value is undefined")
			fmt.Fprint(w, helpers.GetError_String("FF02", "Something went wrong. Please try agin later."))
			return
		}
		lFileInfo, lErr := pdfgenerate.Read_file(lDebug, q.Get("id"))
		if lErr != nil {
			lDebug.Log(helpers.Elog, "FF03"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("FF03", "Something went wrong. Please try agin later."))
			return
		}

		lDecodedFile, lErr := base64.StdEncoding.DecodeString(lFileInfo.File)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "FF04"+lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("FF04", "Something went wrong. Please try agin later."))
			return
		}
		// w.Header().Set("Content-Disposition", "attachment; filename="+lFileInfo.FileName)
		w.Header().Set("filename", lFileInfo.FileName)
		// w.Header().Set("X-DOCID", q.Get("id"))
		w.Header().Set("Content-Type", lFileInfo.FileType)
		w.Write(lDecodedFile)

		lDebug.Log(helpers.Statement, "FetchRawFile (-)")
	}
}
