package versioncontroller

import (
	"fcs23pkg/apps/v2/address"
	"fcs23pkg/apps/v2/address/digilocker"
	getaddressnew "fcs23pkg/apps/v2/address/getAddressNew"
	"fcs23pkg/apps/v2/address/kra"
	"fcs23pkg/apps/v2/address/manualProcess"
	"fcs23pkg/apps/v2/address/manualentryNew"
	"fcs23pkg/apps/v2/aggregator"
	"fcs23pkg/apps/v2/bankinfo"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/dematandservice"
	docpreview "fcs23pkg/apps/v2/docPreview"
	"fcs23pkg/apps/v2/docPreview/userdetailsmodify"
	"fcs23pkg/apps/v2/esign"
	"fcs23pkg/apps/v2/esigndigio"
	"fcs23pkg/apps/v2/fileoperations"
	"fcs23pkg/apps/v2/ipv"
	"fcs23pkg/apps/v2/newsignup"
	"fcs23pkg/apps/v2/nominee"
	"fcs23pkg/apps/v2/otp"
	"fcs23pkg/apps/v2/pan"
	"fcs23pkg/apps/v2/panstatus"
	"fcs23pkg/apps/v2/personaldetails"
	routerinfo "fcs23pkg/apps/v2/router"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/apps/v2/uploadDocument"
	"fcs23pkg/appsession"
	common "fcs23pkg/common"
	"net/http"

	"github.com/gorilla/mux"
)

func DefaultRedirect2(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("v2 working"))
}
func init() {	
	AddVersion("v2", Version_2_API)
}

func Version_2_API() {
	router := mux.NewRouter()
	defer AddRouter("v2", router)
	//thinesh******************************

	router.HandleFunc(common.BasePattern+"/newsendotp", newsignup.SendOtp).Methods(http.MethodPost)

	router.HandleFunc(common.BasePattern+"/newOtpValidation", newsignup.OtpValidation).Methods(http.MethodPost)

	//*****************************************************Default-URL*********************************************************
	//Flattrade
	router.HandleFunc(common.BasePattern+"/", DefaultRedirect2).Methods(http.MethodGet)
	// to reset toml values
	router.HandleFunc(common.BasePattern+"/resetToml", TomlReset).Methods(http.MethodGet)
	//*****************************************************Common Api**********************************************************
	//get next router page info
	router.HandleFunc(common.BasePattern+"/routerflow", routerinfo.GetRouterChange).Methods(http.MethodPost)
	//get the drop down information
	router.HandleFunc(common.BasePattern+"/dropDowndata", commonpackage.GetLookupByHeader).Methods(http.MethodGet)
	//Get the Raw file
	router.HandleFunc(common.BasePattern+"/pdffile", fileoperations.FetchRawFile).Methods(http.MethodGet)
	//Get the File in Base 64
	router.HandleFunc(common.BasePattern+"/downloadFile", fileoperations.DownloadFile).Methods(http.MethodGet)
	//Delete the Cookie
	router.HandleFunc(common.BasePattern+"/clearCookie", appsession.DeleteCookie).Methods(http.MethodGet)
	//Validate the session
	router.HandleFunc(common.BasePattern+"/validateSession", sessionid.SessionOut).Methods(http.MethodGet)
	//*****************************************************mob & Email verify**************************************************
	//OTP SENDER
	router.HandleFunc(common.BasePattern+"/sendOtp", otp.GetUserData).Methods(http.MethodPut)
	//OTP VERIFICATION
	router.HandleFunc(common.BasePattern+"/OtpValidation", otp.ValidateOtp).Methods(http.MethodPut)
	//create a Request ID based on user
	router.HandleFunc(common.BasePattern+"/addUser", sessionid.NewRequestInit).Methods(http.MethodPut)
	router.HandleFunc(common.BasePattern+"/addUserMob", sessionid.NewRequestInitMobile).Methods(http.MethodPut)
	//*****************************************************PAN VERIFY**********************************************************
	//check the pan status
	router.HandleFunc(common.BasePattern+"/getpanstatus", pan.GetPanStatus).Methods(http.MethodPost)

	// Ayyanar 27-04-2024
	//*****************************************************NEW PAN VERIFY**********************************************************
	//check the pan status
	router.HandleFunc(common.BasePattern+"/newpanstatus", panstatus.GetPanStatus).Methods(http.MethodPost)
	router.HandleFunc(common.BasePattern+"/GetPanDetails", panstatus.GetPanDetails).Methods(http.MethodGet)
	//*****************************************************ADDRESS*************************************************************

	// Newly added
	router.HandleFunc(common.BasePattern+"/getAddressNew", getaddressnew.GetAddressNew).Methods(http.MethodGet)
	//*****************************************************KRA*****************************************************************
	//Check the address status
	router.HandleFunc(common.BasePattern+"/addressStatus", kra.AddressStatus).Methods(http.MethodGet)
	//CVLKRA - Fetch address info
	router.HandleFunc(common.BasePattern+"/getPanAddress", kra.GetKRAPanDetails).Methods(http.MethodGet)
	//insert kyc info
	router.HandleFunc(common.BasePattern+"/kycDetails", kra.Kyc).Methods(http.MethodPost)
	//*****************************************************Digilocker**********************************************************
	//Redirect
	router.HandleFunc(common.BasePattern+"/constructDl_Url", digilocker.ConstructUrl).Methods(http.MethodGet)
	//Digilocker- Consolidated Flow
	router.HandleFunc(common.BasePattern+"/getDlInfo", digilocker.GetDigilockerInfo).Methods(http.MethodPost)
	//insert digi info in db
	router.HandleFunc(common.BasePattern+"/addDlDetails", digilocker.DigiInfoInsert).Methods(http.MethodPost)
	//*****************************************************Manual Address******************************************************
	//Get pincode
	router.HandleFunc(common.BasePattern+"/pincode", manualProcess.Pincode).Methods(http.MethodGet)

	// Newly Added
	router.HandleFunc(common.BasePattern+"/manual_entry_process", manualentryNew.ManualEntryProcess).Methods(http.MethodPost)
	//*****************************************************personal details****************************************************
	//Get the Personal Details
	router.HandleFunc(common.BasePattern+"/getPersonalDetails", personaldetails.GetPersonalUpdate).Methods(http.MethodGet)
	//Insert Personal Details
	router.HandleFunc(common.BasePattern+"/addPersonalDetails", personaldetails.InsertPersonalDetails).Methods(http.MethodPut)
	//*****************************************************nominee info********************************************************
	//get the inserted nominee information
	router.HandleFunc(common.BasePattern+"/getNomineeData", nominee.Get_Nominee_DB_Details).Methods(http.MethodPost)
	//nominee proof upload
	router.HandleFunc(common.BasePattern+"/addNomineeData", nominee.PostNomineeFile).Methods(http.MethodPost)
	//get the basic address information on given pincode
	router.HandleFunc(common.BasePattern+"/asClientAddress", nominee.GetAddressDetails).Methods(http.MethodGet)
	//*****************************************************bank details********************************************************
	//Get user Bank Details
	router.HandleFunc(common.BasePattern+"/getBankDetails", bankinfo.GetBankDetailsUpdate).Methods(http.MethodGet)
	//Ifsc Details
	router.HandleFunc(common.BasePattern+"/IfscDetails", bankinfo.GetIFSCdetails).Methods(http.MethodPut)
	//InsertBankDetails
	router.HandleFunc(common.BasePattern+"/addBankDetail", bankinfo.InsertBankDetails).Methods(http.MethodPut)
	//***************************************************** IPV ***************************************************************
	//check the IPV process status
	router.HandleFunc(common.BasePattern+"/getIpvDetails", ipv.GetIPVStatus).Methods(http.MethodGet)
	//generate a request ID for IPV
	router.HandleFunc(common.BasePattern+"/ipvRequest", ipv.DigiID).Methods(http.MethodPost)
	router.HandleFunc(common.BasePattern+"/ipvRecapture", ipv.GetActionRequ).Methods(http.MethodGet)
	//Save the IPV Video and Image file form digio
	router.HandleFunc(common.BasePattern+"/getDigiDocs", ipv.SaveFile).Methods(http.MethodPost)
	router.HandleFunc(common.BasePattern+"/setipvcookie", ipv.SetIpvRequest).Methods(http.MethodGet)
	router.HandleFunc(common.BasePattern+"/getipvlink", ipv.GenerateIPVlink).Methods(http.MethodGet)
	router.HandleFunc(common.BasePattern+"/sendIpvOtp", ipv.SendIpvOtp).Methods(http.MethodPost)
	//*****************************************************Demat and Services details******************************************
	// DematandService single API
	router.HandleFunc(common.BasePattern+"/GetDematandService", dematandservice.GetDematandService).Methods(http.MethodGet)
	router.HandleFunc(common.BasePattern+"/DematServeInsert", dematandservice.DematServeInsert).Methods(http.MethodPost)

	//*****************************************************Proof upload********************************************************
	//fetch the upload files name and id in db
	router.HandleFunc(common.BasePattern+"/getProofDetails", uploadDocument.GetIdName).Methods(http.MethodGet)

	router.HandleFunc(common.BasePattern+"/FileUploads", fileoperations.MultiFileUpload).Methods(http.MethodPost)
	//*****************************************************Document Preview****************************************************
	// Newly Added
	router.HandleFunc(common.BasePattern+"/getReviewDetailsNew", userdetailsmodify.GetUserDetails).Methods(http.MethodGet)
	//get over all router info
	router.HandleFunc(common.BasePattern+"/routerinfo", routerinfo.RouterInfo).Methods(http.MethodGet)
	//generate the PDF file for e-sign
	router.HandleFunc(common.BasePattern+"/GeneratePdf", docpreview.GendratePDF).Methods(http.MethodPost)
	//*****************************************************E-sign *************************************************************
	//Initiate the Esign Process
	router.HandleFunc(common.BasePattern+"/sign/initEsignPro", esign.InitiateEsignProcess).Methods(http.MethodGet)
	//To check the Esign Doc id is Insert or not
	router.HandleFunc(common.BasePattern+"/sign/CheckEsigneCompleted", esign.CheckEsigneCompleted).Methods(http.MethodPut)
	//Enable the Iframe Loader
	router.HandleFunc(common.BasePattern+"/sign/IframeLoader", esign.IframeLoader).Methods(http.MethodGet)

	router.HandleFunc(common.BasePattern+"/sign/getEsign", esign.EsignDocument).Methods(http.MethodPost)
	//insert the form submit status
	router.HandleFunc(common.BasePattern+"/formSubmission", esign.AfterEsign).Methods(http.MethodPost)
	//*****************************************************Get form status****************************************************
	//Get the user Application Status
	router.HandleFunc(common.BasePattern+"/getFormStatus", esign.UserApplicationstatus).Methods(http.MethodGet)

	// ************************************* Risk Disclosure Configurations ***********************************************

	router.HandleFunc(common.BasePattern+"/riskdisclosureinsert", dematandservice.RiskdisclosureInsert).Methods(http.MethodPost)
	router.HandleFunc(common.BasePattern+"/getriskdisclosure", dematandservice.GetRiskDisclosureApi).Methods(http.MethodGet)

	// *************************************digio eSign***********************************************
	router.HandleFunc(common.BasePattern+"/esignrequ", esigndigio.DigioSignRequ).Methods(http.MethodGet)
	router.HandleFunc(common.BasePattern+"/saveesignfile", esigndigio.GetSignFile).Methods(http.MethodGet)

	// Ayyanar 09-04-2024
	router.HandleFunc(common.BasePattern+"/getappversion", commonpackage.GetAppVersion).Methods(http.MethodGet)

	// ***********************************************zoho crm deal update*******************************
	router.HandleFunc(common.BasePattern+"/zohocrmdealupdate", sessionid.ZohoCRMDealUpdate).Methods(http.MethodPost)

	// ***********************************************Digilocker*******************************
	// router.HandleFunc(common.BasePattern+"/ReDirectPantoDigilocker", panstatus.ReDirectToDigilocker).Methods(http.MethodPost)
	//For address screen purpose
	router.HandleFunc(common.BasePattern+"/GetDigilockerInfoFromDb", digilocker.GetDigilockerInfoFromDb).Methods(http.MethodGet)
	router.HandleFunc(common.BasePattern+"/insertpandetails", panstatus.InsertPanStatusDetails).Methods(http.MethodPost)

	//Logeshkumar P Jul-11-2024
	// ***********************************************upload document*******************************
	router.HandleFunc(common.BasePattern+"/SingleFileUploads", fileoperations.SingleFileUpload).Methods(http.MethodPost)

	router.HandleFunc(common.BasePattern+"/ProofFileInsert", uploadDocument.InsertProofDetails).Methods(http.MethodPost)

	//****************************************************Removed endpoint******************************
	//get all the information related to the user
	router.HandleFunc(common.BasePattern+"/getReviewDetails", docpreview.GetUserDetails).Methods(http.MethodGet)

	//User Proof upload (Manual Entry and Proofupload)
	router.HandleFunc(common.BasePattern+"/proofUploads", fileoperations.MultiFileInsert).Methods(http.MethodPost)
	//Manual Entry
	router.HandleFunc(common.BasePattern+"/manual_entry", manualProcess.Manual).Methods(http.MethodPost)

	//get address details from db
	router.HandleFunc(common.BasePattern+"/getAddress", address.GetAddress).Methods(http.MethodGet)

	//******************************************Nominee New *******************************************
	//nominee proof upload
	router.HandleFunc(common.BasePattern+"/addNewNomineeData", nominee.NewPostNomineeFile).Methods(http.MethodPost)

	// ***********************************************Personal Details Fatca Tin Validation*******************************

	router.HandleFunc(common.BasePattern+"/GetTinValidateData", personaldetails.TinValidatePattern).Methods(http.MethodPost)

	//*****************************************************Account Aggregator Services Details****************************************************
	//Get the Account Aggregatpr Status
	router.HandleFunc(common.BasePattern+"/AAconsentRequest", aggregator.AAConsentRequest).Methods(http.MethodPost)
	router.HandleFunc(common.BasePattern+"/AAconsentStatus", aggregator.AAConsentStatus).Methods(http.MethodPost)
	router.HandleFunc(common.BasePattern+"/getAAStatement", aggregator.AAFetchStatement).Methods(http.MethodPost)
	router.HandleFunc(common.BasePattern+"/AAValidationCheck", aggregator.AAValidationCheck).Methods(http.MethodPost)

	router.HandleFunc(common.BasePattern+"/getApplink", commonpackage.GetAppLink).Methods(http.MethodGet)

}
