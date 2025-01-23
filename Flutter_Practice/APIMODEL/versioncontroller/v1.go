package versioncontroller

import (
	"fcs23pkg/apps/v1/address"
	"fcs23pkg/apps/v1/address/digilocker"
	"fcs23pkg/apps/v1/address/kra"
	"fcs23pkg/apps/v1/address/manualProcess"
	"fcs23pkg/apps/v1/bankinfo"
	"fcs23pkg/apps/v1/commonpackage"
	"fcs23pkg/apps/v1/dematandservice"
	docpreview "fcs23pkg/apps/v1/docPreview"
	"fcs23pkg/apps/v1/esign"
	"fcs23pkg/apps/v1/esigndigio"
	"fcs23pkg/apps/v1/fileoperations"
	"fcs23pkg/apps/v1/ipv"
	"fcs23pkg/apps/v1/nominee"
	"fcs23pkg/apps/v1/otp"
	"fcs23pkg/apps/v1/pan"
	"fcs23pkg/apps/v1/panstatus"
	"fcs23pkg/apps/v1/personaldetails"
	routerinfo "fcs23pkg/apps/v1/router"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/appsession"
	common "fcs23pkg/common"
	"fcs23pkg/tomlconfig"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func init() {
	AddVersion("v1", Version_1_API)
}

// function to reset Toml values
func TomlReset(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", "*")
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", " Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	log.Println("TomlReset(+) " + r.Method)

	if r.Method == "GET" {
		tomlconfig.Init()
	}
	w.WriteHeader(200)
	log.Println("TomlReset(-)")

}
func Version_1_API() {

	router := mux.NewRouter()
	defer AddRouter("Default", router)

	//*****************************************************Default-URL*********************************************************
	//VersionDefaultRedirect
	router.HandleFunc(common.BasePattern+"/", DefaultRedirect).Methods("GET")
	// to reset toml values
	router.HandleFunc(common.BasePattern+"/resetToml", TomlReset).Methods("GET")
	//*****************************************************Common Api**********************************************************
	//get next router page info
	router.HandleFunc(common.BasePattern+"/routerflow", routerinfo.GetRouterChange).Methods("POST")
	//get the drop down information
	router.HandleFunc(common.BasePattern+"/dropDowndata", commonpackage.GetLookupByHeader).Methods("GET")
	//Get the Raw file
	router.HandleFunc(common.BasePattern+"/pdffile", fileoperations.FetchRawFile).Methods("GET")
	//Get the File in Base 64
	router.HandleFunc(common.BasePattern+"/downloadFile", fileoperations.DownloadFile).Methods("GET")
	//Delete the Cookie
	router.HandleFunc(common.BasePattern+"/clearCookie", appsession.DeleteCookie).Methods("GET")
	//Validate the session
	router.HandleFunc(common.BasePattern+"/validateSession", sessionid.SessionOut).Methods("GET")
	//*****************************************************mob & Email verify**************************************************
	//OTP SENDER
	router.HandleFunc(common.BasePattern+"/sendOtp", otp.GetUserData).Methods("PUT")
	//OTP VERIFICATION
	router.HandleFunc(common.BasePattern+"/OtpValidation", otp.ValidateOtp).Methods("PUT")
	//create a Request ID based on user
	router.HandleFunc(common.BasePattern+"/addUser", sessionid.NewRequestInit).Methods("PUT")
	router.HandleFunc(common.BasePattern+"/addUserMob", sessionid.NewRequestInitMobile).Methods("PUT")
	//*****************************************************PAN VERIFY**********************************************************
	//check the pan status
	router.HandleFunc(common.BasePattern+"/getpanstatus", pan.GetPanStatus).Methods("POST")

	// Ayyanar 27-04-2024
	//*****************************************************NEW PAN VERIFY**********************************************************
	//check the pan status
	router.HandleFunc(common.BasePattern+"/newpanstatus", panstatus.GetPanStatus).Methods("POST")
	router.HandleFunc(common.BasePattern+"/GetPanDetails", panstatus.GetPanDetails).Methods("GET")
	//*****************************************************ADDRESS*************************************************************
	//get address details from db
	router.HandleFunc(common.BasePattern+"/getAddress", address.GetAddress).Methods("GET")
	//*****************************************************KRA*****************************************************************
	//Check the address status
	router.HandleFunc(common.BasePattern+"/addressStatus", kra.AddressStatus).Methods("GET")
	//CVLKRA - Fetch address info
	router.HandleFunc(common.BasePattern+"/getPanAddress", kra.GetKRAPanDetails).Methods("GET")
	//insert kyc info
	router.HandleFunc(common.BasePattern+"/kycDetails", kra.Kyc).Methods("POST")
	//*****************************************************Digilocker**********************************************************
	//Redirect
	router.HandleFunc(common.BasePattern+"/constructDl_Url", digilocker.ConstructUrl).Methods("GET")
	//Digilocker- Consolidated Flow
	router.HandleFunc(common.BasePattern+"/getDlInfo", digilocker.GetDigilockerInfo).Methods("POST")
	//insert digi info in db
	router.HandleFunc(common.BasePattern+"/addDlDetails", digilocker.DigiInfoInsert).Methods("POST")
	//*****************************************************Manual Address******************************************************
	//Get pincode
	router.HandleFunc(common.BasePattern+"/pincode", manualProcess.Pincode).Methods("GET")
	//User Proof upload (Manual Entry and Proofupload)
	router.HandleFunc(common.BasePattern+"/proofUploads", fileoperations.MultiFileInsert).Methods("POST")
	//Manual Entry
	router.HandleFunc(common.BasePattern+"/manual_entry", manualProcess.Manual).Methods("POST")
	//*****************************************************personal details****************************************************
	//Get the Personal Details
	router.HandleFunc(common.BasePattern+"/getPersonalDetails", personaldetails.GetPersonalUpdate).Methods("GET")
	//Insert Personal Details
	router.HandleFunc(common.BasePattern+"/addPersonalDetails", personaldetails.InsertPersonalDetails).Methods("PUT")
	//*****************************************************nominee info********************************************************
	//get the inserted nominee information
	router.HandleFunc(common.BasePattern+"/getNomineeData", nominee.Get_Nominee_DB_Details).Methods("POST")
	//nominee proof upload
	router.HandleFunc(common.BasePattern+"/addNomineeData", nominee.PostNomineeFile).Methods("POST")
	//get the basic address information on given pincode
	router.HandleFunc(common.BasePattern+"/asClientAddress", nominee.GetAddressDetails).Methods("GET")
	//*****************************************************bank details********************************************************
	//Get user Bank Details
	router.HandleFunc(common.BasePattern+"/getBankDetails", bankinfo.GetBankDetailsUpdate).Methods("GET")
	//Ifsc Details
	router.HandleFunc(common.BasePattern+"/IfscDetails", bankinfo.GetIFSCdetails).Methods("PUT")
	//InsertBankDetails
	router.HandleFunc(common.BasePattern+"/addBankDetail", bankinfo.InsertBankDetails).Methods("PUT")
	//***************************************************** IPV ***************************************************************
	//check the IPV process status
	router.HandleFunc(common.BasePattern+"/getIpvDetails", ipv.GetIPVStatus).Methods("GET")
	//generate a request ID for IPV
	router.HandleFunc(common.BasePattern+"/ipvRequest", ipv.DigiID).Methods("POST")
	//Save the IPV Video and Image file form digio
	router.HandleFunc(common.BasePattern+"/getDigiDocs", ipv.SaveFile).Methods("POST")
	router.HandleFunc(common.BasePattern+"/setipvcookie", ipv.SetIpvRequest).Methods("GET")
	router.HandleFunc(common.BasePattern+"/getipvlink", ipv.GenerateIPVlink).Methods("GET")
	router.HandleFunc(common.BasePattern+"/sendIpvOtp", ipv.SendIpvOtp).Methods("POST")
	//*****************************************************Demat and Services details******************************************
	// DematandService single API
	router.HandleFunc(common.BasePattern+"/GetDematandService", dematandservice.GetDematandService).Methods("GET")
	router.HandleFunc(common.BasePattern+"/DematServeInsert", dematandservice.DematServeInsert).Methods("POST")

	//*****************************************************Proof upload********************************************************
	//fetch the upload files name and id in db
	router.HandleFunc(common.BasePattern+"/getProofDetails", fileoperations.GetIdName).Methods("GET")

	router.HandleFunc(common.BasePattern+"/FileUploads", fileoperations.MultiFileUpload).Methods("POST")
	//*****************************************************Document Preview****************************************************
	//get all the information related to the user
	router.HandleFunc(common.BasePattern+"/getReviewDetails", docpreview.GetUserDetails).Methods("GET")
	//get over all router info
	router.HandleFunc(common.BasePattern+"/routerinfo", routerinfo.RouterInfo).Methods("GET")
	//generate the PDF file for e-sign
	router.HandleFunc(common.BasePattern+"/GeneratePdf", docpreview.GendratePDF).Methods("POST")
	//*****************************************************E-sign *************************************************************
	//Initiate the Esign Process
	router.HandleFunc(common.BasePattern+"/sign/initEsignPro", esign.InitiateEsignProcess).Methods("GET")
	//To check the Esign Doc id is Insert or not
	router.HandleFunc(common.BasePattern+"/sign/CheckEsigneCompleted", esign.CheckEsigneCompleted).Methods("PUT")
	//Enable the Iframe Loader
	router.HandleFunc(common.BasePattern+"/sign/IframeLoader", esign.IframeLoader).Methods("GET")

	router.HandleFunc(common.BasePattern+"/sign/getEsign", esign.EsignDocument).Methods("POST")
	//insert the form submit status
	router.HandleFunc(common.BasePattern+"/formSubmission", esign.AfterEsign).Methods("POST")
	//*****************************************************Get form status****************************************************
	//Get the user Application Status
	router.HandleFunc(common.BasePattern+"/getFormStatus", esign.UserApplicationstatus).Methods("GET")

	// ************************************* Risk Disclosure Configurations ***********************************************

	router.HandleFunc(common.BasePattern+"/riskdisclosureinsert", dematandservice.RiskdisclosureInsert).Methods("POST")
	router.HandleFunc(common.BasePattern+"/getriskdisclosure", dematandservice.GetRiskDisclosureApi).Methods("GET")

	// *************************************digio eSign***********************************************
	router.HandleFunc(common.BasePattern+"/esignrequ", esigndigio.DigioSignRequ).Methods("GET")
	router.HandleFunc(common.BasePattern+"/saveesignfile", esigndigio.GetSignFile).Methods("GET")

	// Ayyanar 09-04-2024
	router.HandleFunc(common.BasePattern+"/getappversion", commonpackage.GetAppVersion).Methods("GET")

	// ***********************************************zoho crm deal update*******************************
	router.HandleFunc(common.BasePattern+"/zohocrmdealupdate", sessionid.ZohoCRMDealUpdate).Methods("POST")

}
