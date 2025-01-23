package apiUtil

import (
	"bytes"
	"errors"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"strings"
)

type HeaderDetails struct {
	Key   string
	Value string
}

func Api_call(pDebug *helpers.HelperStruct, url string, methodType string, jsonData string, header []HeaderDetails, Source string) (string, error) {
	pDebug.Log(helpers.Statement, "Api_call (+)")

	//	var resp HeaderDetails
	var body []byte
	var err error
	var request *http.Request
	var response *http.Response
	var lApiCallLogRec ApiCallLog

	lApiCallLogRec.Request_Json = jsonData
	lApiCallLogRec.URL = url
	lApiCallLogRec.Flag = common.INSERT
	lApiCallLogRec.Source = Source
	lApiCallLogRec.Method = methodType
	// LogEntry method is used to store the Request in Database
	lApiCallLogRec.LastId, err = ApiLogEntry(pDebug, lApiCallLogRec)
	if err != nil {
		pDebug.Log(helpers.Elog, err)
		return "", helpers.ErrReturn(err)
	}
	//Call API
	pDebug.Log(helpers.Details, "APIUTIL url", url)
	pDebug.Log(helpers.Details, "APIUTIL jsonData", jsonData)
	pDebug.Log(helpers.Details, "APIUTIL methodType", methodType)
	pDebug.Log(helpers.Details, "APIUTIL header", header)
	if methodType != "GET" {
		request, err = http.NewRequest(strings.ToUpper(methodType), url, bytes.NewBuffer([]byte(jsonData)))
	} else {
		request, err = http.NewRequest(strings.ToUpper(methodType), url, nil)
	}
	if err != nil {
		lApiCallLogRec.ErrorType = err.Error()
		pDebug.Log(helpers.Elog, err)
	} else {
		if len(header) > 0 {
			for i := 0; i < len(header); i++ {
				request.Header.Set(header[i].Key, header[i].Value)
			}
		}
		response, body, err = ReqAndRespHandle(pDebug, request, Source)
		if err != nil {
			pDebug.Log(helpers.Elog, err)
			lApiCallLogRec.ErrorType = err.Error()
		}
		if response != nil {
			defer response.Body.Close()
			if CheckContentType(response) {
				lApiCallLogRec.Response_Json = "File Content"
			} else {
				lApiCallLogRec.Response_Json = string(body)
			}
		} else {
			lApiCallLogRec.Response_Json = "API Error"
		}
		lApiCallLogRec.Flag = common.UPDATE

	}
	_, err = ApiLogEntry(pDebug, lApiCallLogRec)
	if err != nil {
		pDebug.Log(helpers.Elog, err)
		return "", helpers.ErrReturn(err)
	}

	if !strings.EqualFold(lApiCallLogRec.ErrorType, "") {
		pDebug.Log(helpers.Elog, lApiCallLogRec.ErrorType)
		return "", helpers.ErrReturn(errors.New(lApiCallLogRec.ErrorType))
	}

	pDebug.Log(helpers.Statement, "Api_call (-)")

	return string(body), nil

}

type FileInfo struct {
	FileName, ContentType string
}

func Api_call2(pDebug *helpers.HelperStruct, url string, methodType string, jsonData string, header []HeaderDetails, Source string) (string, FileInfo, error) {
	pDebug.Log(helpers.Statement, "Api_call2 (+)")

	//var resp KycApiResponse
	var lBody []byte
	var lErr error
	var request *http.Request
	var lResponse *http.Response
	var lApiCallLogRec ApiCallLog
	var lFileInfoRec FileInfo

	lApiCallLogRec.Request_Json = jsonData
	lApiCallLogRec.URL = url
	lApiCallLogRec.Flag = common.INSERT
	lApiCallLogRec.Source = Source
	lApiCallLogRec.Method = methodType
	// LogEntry method is used to store the Request in Database
	lApiCallLogRec.LastId, lErr = ApiLogEntry(pDebug, lApiCallLogRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr)
		return "", lFileInfoRec, helpers.ErrReturn(lErr)
	}
	//Call API
	pDebug.Log(helpers.Details, "JsonData: ", jsonData)
	if methodType != "GET" {
		request, lErr = http.NewRequest(strings.ToUpper(methodType), url, bytes.NewBuffer([]byte(jsonData)))
	} else {
		request, lErr = http.NewRequest(strings.ToUpper(methodType), url, nil)
	}
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr)
		lApiCallLogRec.ErrorType = lErr.Error()
	} else {
		if len(header) > 0 {
			for i := 0; i < len(header); i++ {
				request.Header.Set(header[i].Key, header[i].Value)
			}
		}
		lResponse, lBody, lErr = ReqAndRespHandle(pDebug, request, Source)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr)
			lApiCallLogRec.ErrorType = lErr.Error()
		}
		if lResponse != nil {
			defer lResponse.Body.Close()
			if CheckContentType(lResponse) {
				lApiCallLogRec.Response_Json = "File Content"
			} else {
				lApiCallLogRec.Response_Json = string(lBody)
			}
		} else {
			lApiCallLogRec.Response_Json = "API Error"
		}
		lApiCallLogRec.Flag = common.UPDATE

	}

	lFileInfoRec.ContentType = lResponse.Header.Get("Content-Type")
	lFileInfoRec.FileName = getFilenameFromHeader(lResponse.Header.Get("Content-Disposition"))

	_, lErr = ApiLogEntry(pDebug, lApiCallLogRec)
	if lErr != nil {
		pDebug.Log(helpers.Elog, lErr)
		return "", lFileInfoRec, helpers.ErrReturn(lErr)
	}
	if !strings.EqualFold(lApiCallLogRec.ErrorType, "") {
		pDebug.Log(helpers.Elog, lApiCallLogRec.ErrorType)
		return "", lFileInfoRec, helpers.ErrReturn(errors.New(lApiCallLogRec.ErrorType))
	}
	pDebug.Log(helpers.Statement, "Api_call2 (-)")
	return string(lBody), lFileInfoRec, nil

}

func FileSaveApicall(pDebug *helpers.HelperStruct, url string, methodType string, jsonData string, header []HeaderDetails, lJsonLogData, Source string) (string, error) {
	pDebug.Log(helpers.Statement, "Api_call (+)")

	//	var resp HeaderDetails
	var body []byte
	var err error
	var request *http.Request
	var response *http.Response
	var lApiCallLogRec ApiCallLog

	lApiCallLogRec.Request_Json = lJsonLogData
	lApiCallLogRec.URL = url
	lApiCallLogRec.Flag = common.INSERT
	lApiCallLogRec.Source = Source
	lApiCallLogRec.Method = methodType
	// LogEntry method is used to store the Request in Database
	lApiCallLogRec.LastId, err = ApiLogEntry(pDebug, lApiCallLogRec)
	if err != nil {
		pDebug.Log(helpers.Elog, err)
		return "", helpers.ErrReturn(err)
	}
	//Call API
	pDebug.Log(helpers.Details, "APIUTIL url", url)
	pDebug.Log(helpers.Details, "APIUTIL jsonData", jsonData)
	pDebug.Log(helpers.Details, "APIUTIL methodType", methodType)
	pDebug.Log(helpers.Details, "APIUTIL header", header)
	if methodType != "GET" {
		request, err = http.NewRequest(strings.ToUpper(methodType), url, bytes.NewBuffer([]byte(jsonData)))
	} else {
		request, err = http.NewRequest(strings.ToUpper(methodType), url, nil)
	}
	if err != nil {
		lApiCallLogRec.ErrorType = err.Error()
		pDebug.Log(helpers.Elog, err)
	} else {
		if len(header) > 0 {
			for i := 0; i < len(header); i++ {
				request.Header.Set(header[i].Key, header[i].Value)
			}
		}
		response, body, err = ReqAndRespHandle(pDebug, request, Source)
		if err != nil {
			pDebug.Log(helpers.Elog, err)
			lApiCallLogRec.ErrorType = err.Error()
		}
		if response != nil {
			defer response.Body.Close()
			if CheckContentType(response) {
				lApiCallLogRec.Response_Json = "File Content"
			} else {
				lApiCallLogRec.Response_Json = string(body)
			}
		} else {
			lApiCallLogRec.Response_Json = "API Error"
		}

		lApiCallLogRec.Flag = common.UPDATE

	}
	_, err = ApiLogEntry(pDebug, lApiCallLogRec)
	if err != nil {
		pDebug.Log(helpers.Elog, err)
		return "", helpers.ErrReturn(err)
	}

	if !strings.EqualFold(lApiCallLogRec.ErrorType, "") {
		pDebug.Log(helpers.Elog, lApiCallLogRec.ErrorType)
		return "", helpers.ErrReturn(errors.New(lApiCallLogRec.ErrorType))
	}

	pDebug.Log(helpers.Statement, "Api_call (-)")

	return string(body), nil

}

func ReqAndRespHandle(pDebug *helpers.HelperStruct, pRequest *http.Request, pSource string) (lResponse *http.Response, lBodyInfo []byte, lErr error) {
	pDebug.Log(helpers.Statement, "ReqAndRespHandle (+)")
	lResponse, lErr = GClient.Do(pRequest)
	if lErr != nil {
		var lReturnErr error
		switch lErrType := lErr.(type) {
		case *url.Error:
			// URL-related error
			if lErrType.Timeout() {
				lReturnErr = errors.New("request timed out")
			} else {
				lReturnErr = errors.New("URL Error: " + lErr.Error())
			}
		case *net.OpError:
			// Network operation error
			lReturnErr = errors.New("Network Operation Error: " + lErr.Error())
		default:
			// Other general error
			lReturnErr = errors.New("Error: " + lErr.Error())
		}

		lEmailInfo := AdminEmailAlertStruct{
			ErrorCode: lReturnErr.Error(), EndPoint: fmt.Sprintf("%v", pRequest.URL), Source: pSource,
		}

		lErr = AdminEmailAlert(pDebug, lEmailInfo, pSource)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr)
		}
		return lResponse, lBodyInfo, lReturnErr
	} else {
		lBodyInfo, lErr = io.ReadAll(lResponse.Body)
		if lErr != nil {
			return lResponse, lBodyInfo, lErr
		}
		if len(lBodyInfo) == 0 {
			return lResponse, lBodyInfo, errors.New("responce Data is Empty")
		}
		if !(lResponse.StatusCode >= 200 && lResponse.StatusCode < 300) {
			// not-Successful response (2xx)
			return lResponse, lBodyInfo, errors.New(string(lBodyInfo))
		}

	}
	pDebug.Log(helpers.Statement, "ReqAndRespHandle (-)")
	return lResponse, lBodyInfo, nil
}

func CheckContentType(pResponse *http.Response) bool {

	//get URL from toml
	bodyContentType := tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "bodyContentType")

	for _, contenttype := range strings.Split(bodyContentType, ",") {
		if strings.Contains(strings.ToLower(pResponse.Header.Get("Content-Type")), strings.ToLower(contenttype)) {
			return false
		}
	}
	return true
}

func getFilenameFromHeader(header string) string {
	parts := strings.Split(header, "filename=")
	if len(parts) > 1 {
		return strings.Trim(parts[1], "\" ")
	}
	return "default_filename"
}
