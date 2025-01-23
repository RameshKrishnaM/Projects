package apigate

import (
	"bytes"
	"context"
	"fcs23pkg/common"
	"fcs23pkg/helpers"
	"io"
	"net/http"
	"strconv"
	"strings"
)

type ResponseCaptureWriter struct {
	http.ResponseWriter
	status int
	body   []byte
}

func (rw *ResponseCaptureWriter) WriteHeader(statusCode int) {
	rw.status = statusCode
	rw.ResponseWriter.WriteHeader(statusCode)
}

func (rw *ResponseCaptureWriter) Write(body []byte) (int, error) {
	rw.body = append(rw.body, body...)
	return rw.ResponseWriter.Write(body)
}

func (rw *ResponseCaptureWriter) Status() int {
	if rw.status == 0 {
		return http.StatusOK
	}
	return rw.status
}

func (rw *ResponseCaptureWriter) Body() []byte {
	return rw.body
}

// Middleware to log requests and route based on API version
func LogMiddleware(versionHandlers map[string]http.Handler) func(http.Handler) http.Handler {

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

			// Initialize the logger
			lDebug := new(helpers.HelperStruct)
			lDebug.Init()
			lDebug.Log(helpers.Statement, "LogMiddleware (+)")

			(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
			(w).Header().Set("Access-Control-Allow-Credentials", "true")
			(w).Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			(w).Header().Set("Access-Control-Allow-Headers", "api-version,ActionType,App_mode,digid,ipvsid,ipvurl,pincode,otpflag,appname,code,contenttype,Content-Type, Authorization")

			// Check if it is an OPTIONS request
			if strings.EqualFold("OPTIONS", r.Method) {
				w.WriteHeader(http.StatusOK)
				return
			}

			// Get the API version from the request
			version := r.Header.Get("api-version")
			if version == "" {
				version = "Default"
			}

			var lSessionId string
			lCookie, lErr := r.Cookie(common.EKYCCookieName)
			if lErr != nil {
				if lErr == http.ErrNoCookie {
					lSessionId = "Not Set"
				}
				lDebug.Log(helpers.Elog, lErr)
			}
			if lSessionId != "Not Set" {
				lDebug.Sid = lCookie.Value
			}
			// Get the API version from the URL Path
			// version = getVersionFromPath(r.URL.Path)

			ctx := context.WithValue(r.Context(), helpers.RequestIDKey, lDebug.Sid)
			r = r.WithContext(ctx)

			body, lErr := io.ReadAll(r.Body)
			if lErr != nil {
				lDebug.Log(helpers.Elog, lErr)
			}
			requestorDetail := GetRequestorDetail(lDebug, r)
			requestorDetail.Body = string(body)
			r.Body = io.NopCloser(bytes.NewBuffer(body))

			contentLength := r.Header.Get("Content-Length")
			if contentLength != "" {
				length, lErr := strconv.Atoi(contentLength)
				if lErr != nil {
					lDebug.Log(helpers.Elog, "Invalid Content-Length header", lErr)
				}

				// if length >= 2<<20 { // 2 MB = 2 * 1024 * 1024 bytes
				if length >= 25<<20 { // 25 MB = 25 * 1024 * 1024 bytes
					lDebug.Log(helpers.Elog, "Request body too large", lErr)
					requestorDetail.Body = "File Data"
				}
			}
			LogRequest(lDebug, "", requestorDetail, lDebug.Sid)

			// Move the logging of request after setting the context
			captureWriter := &ResponseCaptureWriter{ResponseWriter: w}

			// Route to the appropriate version handler
			if handler, exists := versionHandlers[version]; exists {
				handler.ServeHTTP(captureWriter, r)
			} else {
				http.Error(w, "Unsupported API version", http.StatusBadRequest)
			}
			LogResponse(lDebug, r, captureWriter.Status(), captureWriter.Body(), r.Context().Value(helpers.RequestIDKey).(string))
			lDebug.Log(helpers.Statement, "LogMiddleware (-)")
		})
	}
}

// getVersionFromPath retrieves the version from the provided path.
//
// path: a string representing the path from which the version is extracted.
// string: returns a string representing the extracted version.
func getVersionFromPath(path string) string {
	parts := strings.Split(path, "/")
	if len(parts) >= 3 && parts[1] == common.BasePattern {
		return parts[2]
	}
	return "v1"
}
