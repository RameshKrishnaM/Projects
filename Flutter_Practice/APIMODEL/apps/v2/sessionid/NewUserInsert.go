package sessionid

import (
	"encoding/json"
	"fcs23pkg/apigate"
	"fcs23pkg/appsession"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	backofficecheck "fcs23pkg/integration/v2/backofficeCheck"
	"fcs23pkg/integration/v2/zohointegration"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

type UserStruct struct {
	Name  string `json:"clientname"`
	Phone string `json:"phone"`
	Email string `json:"email"`
	State string `json:"state"`
}

func NewRequestInit(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "PUT")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	if r.Method == "PUT" {
		lDebug.Log(helpers.Statement, "NewRequestInit (+)")

		// create an instance of the structure
		var lUserRec UserStruct
		// //read the body
		// lBody, lErr := ioutil.ReadAll(r.Body)

		// if lErr != nil {
		// 	lDebug.Log(helpers.Elog, "NNR01", lErr.Error())
		// 	fmt.Fprint(w, helpers.GetError_String("NNR01", "Somthing is wrong please try again later"))
		// 	return
		// }
		// // converting json body value to Structue
		// lDebug.Log(helpers.Details, "lBody", lBody)
		// lErr = json.Unmarshal(lBody, &lUserRec)

		lErr := r.ParseMultipartForm(10 << 20) // Set max memory allocation to 10MB
		if lErr != nil {
			lDebug.Log(helpers.Elog, "NNR01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NNR01", "Somthing is wrong please try again later"))
			return
		}

		lBody := r.Form.Get("userDetails")

		var lUtmRec zohointegration.ZohoCrmDealInsertStruct

		lUtmRec.Url_RmCode = r.Form.Get("rm_code")
		lUtmRec.Url_BrCode = r.Form.Get("br_code")
		lUtmRec.Url_EmpCode = r.Form.Get("emp_code")
		lUtmRec.Url_UtmSource = r.Form.Get("utm_source")
		lUtmRec.Url_UtmMedium = r.Form.Get("utm_medium")
		lUtmRec.Url_UtmCampaign = r.Form.Get("utm_campaign")
		lUtmRec.Url_UtmTerm = r.Form.Get("utm_term")
		lUtmRec.Url_UtmContent = r.Form.Get("utm_keyword")
		lUtmRec.Url_UtmKeyword = r.Form.Get("utm_content")
		lUtmRec.Url_Mode = r.Form.Get("mode")
		lUtmRec.Url_ReferalCode = r.Form.Get("referral_code")
		lUtmRec.Url_Gclid = r.Form.Get("gclid")
		lErr = json.Unmarshal([]byte(lBody), &lUserRec)

		lDebug.Log(helpers.Details, "lBody", lBody)

		// cheack where response will not Error
		if lErr != nil {
			lDebug.Log(helpers.Elog, "NNR02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NNR02", "Somthing is wrong please try again later"))
			return
		}

		if lUserRec.Phone == "" || lUserRec.Email == "" {
			lDebug.Log(helpers.Elog, "Page reload")
			fmt.Fprint(w, helpers.GetError_String("R", "Somthing is wrong please try again later"))
			return
		}
		// if condition only for development purpose
		if strings.ToUpper(common.BOCheck) != "N" {
			//back office check
			//get moble status
			lBofficeMobStatus, lErr := backofficecheck.BofficeCheck(lDebug, lUserRec.Phone, "mobile")
			if lErr != nil {
				lDebug.Log(helpers.Elog, "NNR03", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("NNR03", "Somthing is wrong please try again later"))
				return
			}
			//get emailstatus
			lBofficeEmailStatus, lErr := backofficecheck.BofficeCheck(lDebug, lUserRec.Email, "EMAIL")
			if lErr != nil {
				lDebug.Log(helpers.Elog, "NNR04", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("NNR04", "Somthing is wrong please try again later"))
				return
			}

			lDebug.Log(helpers.Details, "lBofficeMobStatus && lBofficeEmailStatus", lBofficeMobStatus, lBofficeEmailStatus)
			//check user backoffice status
			if lBofficeMobStatus && lBofficeEmailStatus {
				lDebug.Log(helpers.Elog, "The given Mobile number and Email ID has an account with us")
				fmt.Fprint(w, helpers.GetError_String("MEA", "The given Mobile number and Email ID has an account with us"))
				return
			}
			//check user mobile already exist
			if lBofficeMobStatus {
				lDebug.Log(helpers.Elog, "The given Mobile number has an account with us")
				fmt.Fprint(w, helpers.GetError_String("MC", "The given Mobile number has an account with us"))
				return
			}
			//check user Email already exist
			if lBofficeEmailStatus {
				lDebug.Log(helpers.Elog, "The given Email ID has an account with us")
				fmt.Fprint(w, helpers.GetError_String("EC", "The given Email ID has an account with us"))
				return
			}
		}
		//eather mobile or email not exist in DB
		lExists, lFlag, lErr := Dbcheck(lDebug, lUserRec.Phone, lUserRec.Email)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "NNR07", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NNR07", "Somthing is wrong please try again later"))
			return
		}
		if lExists != "" && lFlag == "P" {
			lDebug.Log(helpers.Elog, lExists)
			fmt.Fprint(w, helpers.GetError_String("MC", lExists))
			return
		} else if lExists != "" && lFlag == "E" {
			lDebug.Log(helpers.Elog, lExists)
			fmt.Fprint(w, helpers.GetError_String("EC", lExists))
			return
		}

		// verify the user is already existing in ekyc_request table
		lUid, lSid, lStatus, lErr := GetSessionUID(lUserRec.Phone, lUserRec.Email, lDebug, r)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "NNR09", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NNR09", "Somthing is wrong please try again later"))
			return
		}
		//insert new user requestdata table in db
		if lStatus == "new" {
			lErr = NewUserdataInsert(lDebug, lUserRec, r, lUid, lSid)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "NNR10", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("NNR10", "Somthing is wrong please try again later"))
				return
			}
		} else if lStatus == "old" {

			lErr = UpdateUserdata(lDebug, lUid, lUserRec)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "NNR12", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("NNR12", "Somthing is wrong please try again later"))
				return
			}
		}
		lErr = InsertZohoCrmDeal(r, w, &lUtmRec, lDebug, lUid, lSid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "NNR11", lErr.Error())
		}

		var lCookieeExpiry int
		lAppMode := r.Header.Get("App_mode")
		if strings.EqualFold(lAppMode, "web") {
			lCookieeExpiry = common.CookieMaxAge
		} else {
			lCookieeExpiry = common.AppCookieMaxAge
		}
		//set cokkie in browser
		lErr = appsession.KycSetcookie(w, lDebug, common.EKYCCookieName, lSid, lCookieeExpiry)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "NNR11", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NNR11", "Somthing is wrong please try again later"))
			return
		}
		fmt.Fprint(w, helpers.GetMsg_String("NNR", "insert successfully"))
		lDebug.Log(helpers.Statement, "NewRequestInit (-)")
	}
}

func NewRequestInitMobile(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)

	if r.Method == "PUT" {
		lDebug.Log(helpers.Statement, "NewRequestInitMobile (+)")

		// create an instance of the structure
		var lUserRec UserStruct
		//read the body
		lBody, lErr := ioutil.ReadAll(r.Body)

		if lErr != nil {
			lDebug.Log(helpers.Elog, "NNR01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NNR01", "Somthing is wrong please try again later"))
			return
		}
		// converting json body value to Structue
		lDebug.Log(helpers.Details, "lBody", lBody)
		lErr = json.Unmarshal(lBody, &lUserRec)
		var lUtmRec zohointegration.ZohoCrmDealInsertStruct

		// lErr := r.ParseMultipartForm(10 << 20) // Set max memory allocation to 10MB
		// if lErr != nil {
		// 	lDebug.Log(helpers.Elog, "NNR01", lErr.Error())
		// 	fmt.Fprint(w, helpers.GetError_String("NNR01", "Somthing is wrong please try again later"))
		// 	return
		// }

		// lBody := r.Form.Get("userDetails")

		// lUtmRec.Url_RmCode = r.Form.Get("rm_code")
		// lUtmRec.Url_BrCode = r.Form.Get("br_code")
		// lUtmRec.Url_EmpCode = r.Form.Get("emp_code")
		// lUtmRec.Url_UtmSource = r.Form.Get("utm_source")
		// lUtmRec.Url_UtmMedium = r.Form.Get("utm_medium")
		// lUtmRec.Url_UtmCampaign = r.Form.Get("utm_campaign")
		// lUtmRec.Url_UtmTerm = r.Form.Get("utm_term")
		// lUtmRec.Url_UtmContent = r.Form.Get("utm_keyword")
		// lUtmRec.Url_UtmKeyword = r.Form.Get("utm_content")
		// lUtmRec.Url_Mode = r.Form.Get("mode")
		// lUtmRec.Url_ReferalCode = r.Form.Get("referral_code")
		// lUtmRec.Url_Gclid = r.Form.Get("gclid")
		// lErr = json.Unmarshal([]byte(lBody), &lUserRec)

		lDebug.Log(helpers.Details, "lBody", lBody)

		// cheack where response will not Error
		if lErr != nil {
			lDebug.Log(helpers.Elog, "NNR02", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NNR02", "Somthing is wrong please try again later"))
			return
		}

		if lUserRec.Phone == "" || lUserRec.Email == "" {
			lDebug.Log(helpers.Elog, "Page reload")
			fmt.Fprint(w, helpers.GetError_String("R", "Somthing is wrong please try again later"))
			return
		}
		// if condition only for development purpose
		if strings.ToUpper(common.BOCheck) != "N" {
			//back office check
			//get moble status
			lBofficeMobStatus, lErr := backofficecheck.BofficeCheck(lDebug, lUserRec.Phone, "mobile")
			if lErr != nil {
				lDebug.Log(helpers.Elog, "NNR03", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("NNR03", "Somthing is wrong please try again later"))
				return
			}
			//get emailstatus
			lBofficeEmailStatus, lErr := backofficecheck.BofficeCheck(lDebug, lUserRec.Email, "EMAIL")
			if lErr != nil {
				lDebug.Log(helpers.Elog, "NNR04", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("NNR04", "Somthing is wrong please try again later"))
				return
			}

			lDebug.Log(helpers.Details, "lBofficeMobStatus && lBofficeEmailStatus", lBofficeMobStatus, lBofficeEmailStatus)
			//check user backoffice status
			if lBofficeMobStatus && lBofficeEmailStatus {
				lDebug.Log(helpers.Elog, "The given Mobile number and Email ID has an account with us")
				fmt.Fprint(w, helpers.GetError_String("MEA", "The given Mobile number and Email ID has an account with us"))
				return
			}
			//check user mobile already exist
			if lBofficeMobStatus {
				lDebug.Log(helpers.Elog, "The given Mobile number has an account with us")
				fmt.Fprint(w, helpers.GetError_String("MC", "The given Mobile number has an account with us"))
				return
			}
			//check user Email already exist
			if lBofficeEmailStatus {
				lDebug.Log(helpers.Elog, "The given Email ID has an account with us")
				fmt.Fprint(w, helpers.GetError_String("EC", "The given Email ID has an account with us"))
				return
			}
		}
		//eather mobile or email not exist in DB
		lExists, lFlag, lErr := Dbcheck(lDebug, lUserRec.Phone, lUserRec.Email)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "NNR07", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NNR07", "Somthing is wrong please try again later"))
			return
		}
		if lExists != "" && lFlag == "P" {
			lDebug.Log(helpers.Elog, lExists)
			fmt.Fprint(w, helpers.GetError_String("MC", lExists))
			return
		} else if lExists != "" && lFlag == "E" {
			lDebug.Log(helpers.Elog, lExists)
			fmt.Fprint(w, helpers.GetError_String("EC", lExists))
			return
		}

		// verify the user is already existing in ekyc_request table
		lUid, lSid, lStatus, lErr := GetSessionUID(lUserRec.Phone, lUserRec.Email, lDebug, r)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "NNR09", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NNR09", "Somthing is wrong please try again later"))
			return
		}
		//insert new user requestdata table in db
		if lStatus == "new" {
			lErr = NewUserdataInsert(lDebug, lUserRec, r, lUid, lSid)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "NNR10", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("NNR10", "Somthing is wrong please try again later"))
				return
			}
		} else if lStatus == "old" {
			lErr = UpdateUserdata(lDebug, lUid, lUserRec)
			if lErr != nil {
				lDebug.Log(helpers.Elog, "NNR12", lErr.Error())
				fmt.Fprint(w, helpers.GetError_String("NNR12", "Somthing is wrong please try again later"))
				return
			}
		}

		lErr = InsertZohoCrmDeal(r, w, &lUtmRec, lDebug, lUid, lSid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "NNR13", lErr.Error())
		}
		var lCookieeExpiry int
		lAppMode := r.Header.Get("App_mode")
		if strings.EqualFold(lAppMode, "web") {
			lCookieeExpiry = common.CookieMaxAge
		} else {
			lCookieeExpiry = common.AppCookieMaxAge
		}
		//set cokkie in browser
		lErr = appsession.KycSetcookie(w, lDebug, common.EKYCCookieName, lSid, lCookieeExpiry)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "NNR14", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("NNR14", "Somthing is wrong please try again later"))
			return
		}
		fmt.Fprint(w, helpers.GetMsg_String("NNR", "insert successfully"))
		lDebug.Log(helpers.Statement, "NewRequestInitMobile (-)")
	}
}
func NewUserdataInsert(pDebug *helpers.HelperStruct, pUserRec UserStruct, pReq *http.Request, pUid, pSid string) error {
	pDebug.Log(helpers.Statement, "NewUserdataInsert (+)")

	lDeviceName := pReq.Header.Get("App_mode")
	pDebug.Log(helpers.Details, "lDeviceName", lDeviceName)

	insertString := `
	if not exists (select * from ekyc_request where Uid=? and isActive='Y')
	then
	insert into ekyc_request (uid,Given_Name,Phone,Email,Given_State,Created_Session_Id,Updated_Session_Id,CreatedDate,UpdatedDate,Form_Status,app,isActive)
	values(?,?,?,?,?,?,?,unix_timestamp(),unix_timestamp(),'OB',?,'Y');
	end if;`

	_, lErr := ftdb.NewEkyc_GDB.Exec(insertString, pUid, pUid, pUserRec.Name, pUserRec.Phone, pUserRec.Email, pUserRec.State, pSid, pSid, lDeviceName)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "NewUserdataInsert (-)")

	return nil
}
func GetOSFromUserAgent(pDebug *helpers.HelperStruct, lUserAgent string) string {
	pDebug.Log(helpers.Statement, "getOSFromUserAgent (+)")

	// Convert user agent string to lowercase for case-insensitive comparison
	lUserAgent = strings.ToLower(lUserAgent)
	pDebug.Log(helpers.Details, lUserAgent, "lUserAgent")
	if strings.Contains(lUserAgent, "android") {
		return "Android"
	} else if strings.Contains(lUserAgent, "iphone") || strings.Contains(lUserAgent, "ipad") || strings.Contains(lUserAgent, "ios") {
		return "iOS"
	} else if strings.Contains(lUserAgent, "Windows NT") {
		return "PC"
	} else if strings.Contains(lUserAgent, "Macintosh") {
		return "Mac"
	} else if strings.Contains(lUserAgent, "X11") {
		return "Desktop (Linux)"
	}
	pDebug.Log(helpers.Statement, "getOSFromUserAgent (-)")
	return "Unknown"
}

func UserSessionInsert(pDebug *helpers.HelperStruct, r *http.Request, pUid, pSid string) (lErr error) {
	pDebug.Log(helpers.Statement, "UserSessionInsert (+)")
	// geting the response details
	lReqDtl := apigate.GetRequestorDetail(pDebug, r)

	lDevicetype := GetOSFromUserAgent(pDebug, r.Header.Get("User-Agent"))

	insertString := `
			insert into ekyc_session(requestuid,sessionid,createdtime,expiretime,realip,forwardedip,method,path,host,remoteaddr,devicetype)
			values (?,?,unix_timestamp() ,unix_timestamp(ADDDATE(now(), INTERVAL 5 HOUR) ),?,?,?,?,?,?,?)`
	_, lErr = ftdb.NewEkyc_GDB.Exec(insertString, pUid, pSid, lReqDtl.RealIP, lReqDtl.ForwardedIP, lReqDtl.Method, lReqDtl.Path, lReqDtl.Host, lReqDtl.RemoteAddr, lDevicetype)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "session Cookie :", pSid)

	lErr = StatusInsert(pDebug, pUid, pSid, "signup")
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "UserSessionInsert (-)")

	return nil
}
func StatusInsert(pDebug *helpers.HelperStruct, pUid, pSid, pPage_Name string) error {
	pDebug.Log(helpers.Statement, "StatusInsert (+)")

	insertString := `
		IF EXISTS (select * from ekyc_onboarding_status eos where Page_Name =? and Request_id =?)
		then
		 INSERT INTO ekyc_onboarding_status (Request_id, Page_Name, Status, Created_Session_Id, CreatedDate)
		 values(?,?,'U',?,unix_timestamp());
		ELSE
		 INSERT INTO ekyc_onboarding_status (Request_id, Page_Name, Status, Created_Session_Id, CreatedDate)
		 values(?,?,'I',?,unix_timestamp());
		END IF;`

	_, lErr := ftdb.NewEkyc_GDB.Exec(insertString, pPage_Name, pUid, pUid, pPage_Name, pSid, pUid, pPage_Name, pSid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "StatusInsert (-)")
	return nil
}

func UpdateUserdata(pDebug *helpers.HelperStruct, pUid string, pUserRec UserStruct) error {
	pDebug.Log(helpers.Statement, "UpdateUserdata (+)")
	lTestUserUpd := ""

	if common.TestEmail == pUserRec.Email && common.TestMobile == pUserRec.Phone {
		lTestUserUpd = `, Aadhar_Linked = '' , ValidPan_Status = ''`
	}

	insertString := `  update ekyc_request 
						set Given_Name = ? ` + lTestUserUpd + `
						where Uid = ? `

	_, lErr := ftdb.NewEkyc_GDB.Exec(insertString, pUserRec.Name, pUid)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "UpdateUserdata (-)")
	return nil
}
