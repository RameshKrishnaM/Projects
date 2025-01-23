package main

// import (
// 	"fcs23pkg/apigate"
// 	"fcs23pkg/apps/v2/bankinfo"
// 	"fcs23pkg/apps/v2/commonpackage"
// 	appscommon "fcs23pkg/apps/v2/commonpackage"
// 	"fcs23pkg/apps/v2/demat"
// 	"fcs23pkg/apps/v2/digilocker"
// 	"fcs23pkg/apps/v2/esign"
// 	"fcs23pkg/apps/v2/fileupload"
// 	getdetailsfromdb "fcs23pkg/apps/v2/getInfoFormDb"
// 	"fcs23pkg/apps/v2/infocard"
// 	"fcs23pkg/apps/v2/ipv"
// 	"fcs23pkg/apps/v2/kra"
// 	"fcs23pkg/apps/v2/landingjs/insertdata"
// 	"fcs23pkg/apps/v2/landingjs/otprequest"
// 	"fcs23pkg/apps/v2/manualProcess"
// 	"fcs23pkg/apps/v2/nominee"
// 	"fcs23pkg/apps/v2/otp"
// 	"fcs23pkg/apps/v2/personaldetails"
// 	"fcs23pkg/apps/v2/pincode"
// 	routerinfo "fcs23pkg/apps/v2/router"
// 	"fcs23pkg/apps/v2/services"
// 	"fcs23pkg/apps/v2/servideandbrokerage"
// 	"fcs23pkg/apps/v2/sessionid"
// 	"fcs23pkg/apps/v2/sign"
// 	"fcs23pkg/apps/v2/utmset"
// 	common "fcs23pkg/common"
// 	"fcs23pkg/file"
// 	"fcs23pkg/helpers"
// 	"fmt"
// 	"log"
// 	"net/http"
// 	"os"
// 	"os/exec"
// 	"time"

// 	"github.com/gorilla/mux"
// )

// func autoRestart() {

// 	// // Get the current time
// 	// now := time.Now()

// 	// // Set the restart time to 4:00 AM
// 	// restart := time.Date(now.Year(), now.Month(), now.Day(), 4, 0, 0, 0, now.Location())

// 	// // Calculate the duration until the restart time
// 	// duration := restart.Sub(now)

// 	// // Sleep for the duration until the restart time
// 	// time.Sleep(duration)

// 	// //time.Sleep(5 * time.Second)
// 	for {
// 		now := time.Now()
// 		//resart the program everyday at 4am
// 		//at 3am, the program goes for 1 hour sleep and after that it will restart
// 		if now.Hour() == 3 {
// 			//sleep for an hour so that the hour changes to 4 and this condition
// 			//in the loop does not  continue again in next iteration
// 			time.Sleep(60 * 61 * time.Second)
// 			fmt.Println(now.Hour(), now.Minute(), now.Second())
// 			log.Println(now.Hour(), now.Minute(), now.Second())
// 			// Restart the program
// 			fmt.Println("Restarting the program...")
// 			log.Println("Restarting the program...")
// 			execPath, err := os.Executable()
// 			if err != nil {
// 				fmt.Println("Error getting executable path:", err)
// 				log.Println("Error getting executable path:", err)

// 				return
// 			}
// 			cmd := exec.Command(execPath)
// 			cmd.Stdout = os.Stdout
// 			cmd.Stderr = os.Stderr
// 			err = cmd.Start()
// 			if err != nil {
// 				fmt.Println("Error restarting program:", err)
// 				log.Println("Error restarting program:", err)
// 				return
// 			}
// 			os.Exit(0)

// 		}
// 		time.Sleep(60 * 30 * time.Second)
// 	}
// }

// func DefaultRedirect(w http.ResponseWriter, r *http.Request) {

// 	(w).Header().Set("Access-Control-Allow-Origin", "*")
// 	(w).Header().Set("Access-Control-Allow-Credentials", "true")
// 	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
// 	(w).Header().Set("Access-Control-Allow-Headers", " Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

// 	log.Println("DefaultRedirect(+) " + r.Method)

// 	htmlString := `<!DOCTYPE html>
//         <html lang="en">

//         <head>
// 			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
// 			<meta http-equiv="refresh" content="0; url=https://flattrade.in" />
//             <link rel="canonical" href="https://flattrade.in" />
//         </head>

//         <body>
//         </body>
//         </html>`

// 	fmt.Fprint(w, htmlString)
// 	w.WriteHeader(200)
// 	log.Println("DefaultRedirect(-)")

// }

// func main() {
// 	log.Println("Server Started :28094 ...")
// 	f, err := os.OpenFile("./log/logfile"+time.Now().Format("02012006.15.04.05.000000000")+".txt", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
// 	if err != nil {
// 		log.Fatalf("error opening file: %v", err)
// 	}
// 	defer f.Close()
// 	log.SetOutput(f)

// 	// go autoRestart()

// 	router := createRouter()

// 	handler := apigate.LogMiddleware(router)
// 	// handler=router.
// 	srv := &http.Server{
// 		ReadTimeout:  15 * time.Second,
// 		WriteTimeout: 15 * time.Second,
// 		IdleTimeout:  120 * time.Second,
// 		Handler:      handler,
// 		Addr:         ":28094",
// 	}
// 	log.Println("Server Started :28094 ...")

// 	// certFile := "./SSLCertificate/flattrade.crt"
// 	// keyFile := "./SSLCertificate/flattrade.key"
// 	// log.Fatal(srv.ListenAndServeTLS(certFile, keyFile))
// 	log.Fatal(srv.ListenAndServe())
// }

// func createRouter() http.Handler {
// 	// Create a new router using Gorilla Mux
// 	router := mux.NewRouter()

// 	//********************************Default-URL*********************************
// 	// Flattrade
// 	router.HandleFunc(common.BasePattern+"/", DefaultRedirect).Methods("GET")

// 	//********************************Digilocker**********************************
// 	// Redirect
// 	router.HandleFunc(common.BasePattern+"/redirect_url", digilocker.RedirectUrl).Methods("GET")
// 	//Digilocker- Consolidated Flow
// 	router.HandleFunc(common.BasePattern+"/accesstocken", digilocker.GetDigilockerApi).Methods("POST")
// 	//insert digi info in db
// 	router.HandleFunc(common.BasePattern+"/digiinfo", digilocker.DigiInfoInsert).Methods("POST")

// 	//**************************************KRA*************************************
// 	// check the pan status
// 	router.HandleFunc(common.BasePattern+"/getpanstatus", kra.GetPanStatus).Methods("POST")
// 	// CVLKRA - Fetch address info
// 	router.HandleFunc(common.BasePattern+"/get_kra_pan_soap", kra.GetKraPanSoap).Methods("POST")
// 	router.HandleFunc(common.BasePattern+"/addressStatus", getdetailsfromdb.AddressStatus).Methods("GET")
// 	// insert kyc info
// 	router.HandleFunc(common.BasePattern+"/kycinfo", kra.Kyc).Methods("POST")
// 	// Check New To KRA
// 	router.HandleFunc(common.BasePattern+"/check_new_to_kra", getdetailsfromdb.NewtoKRA).Methods("GET")
// 	//**************************************mob & Email verify*************************************
// 	// OTP SENDER
// 	router.HandleFunc(common.BasePattern+"/otpcall", otp.GetUserData).Methods("PUT")
// 	// OTP VERIFICATION
// 	router.HandleFunc(common.BasePattern+"/validotp", otp.ValidateOtp).Methods("PUT")
// 	//create a Request ID based on user
// 	router.HandleFunc(common.BasePattern+"/newuser", sessionid.NewRequestInit).Methods("PUT")
// 	// Set cokkie value based on user
// 	router.HandleFunc(common.BasePattern+"/setcookie", sessionid.SetCookie).Methods("POST")

// 	//**************************************Address*************************************
// 	// Get pincode
// 	router.HandleFunc(common.BasePattern+"/pincode", pincode.Pincode).Methods("GET")
// 	//Manual Entry
// 	router.HandleFunc(common.BasePattern+"/manual_entry", manualProcess.Manual).Methods("POST")
// 	//get address details from db
// 	router.HandleFunc(common.BasePattern+"/getAddress", getdetailsfromdb.GetAddress).Methods("GET")

// 	//**************************************info card*************************************
// 	// show the basic information of the user
// 	router.HandleFunc("/CardDetails", infocard.GetCardInfo).Methods("GET")
// 	//**************************************personal details*************************************
// 	// Insert Personal Details
// 	router.HandleFunc("/InsertDetails", personaldetails.InsertPersonalDetails).Methods("PUT")
// 	// Personal Details Update
// 	router.HandleFunc("/PersonalDetails", personaldetails.GetPersonalUpdate).Methods("GET")
// 	// Educational Details
// 	router.HandleFunc("/EducationalDetails", personaldetails.GetEducationalList).Methods("GET")
// 	//**************************************bank details*************************************
// 	//Ifsc Details
// 	router.HandleFunc("/IfscDetails", bankinfo.GetIFSCdetails).Methods("PUT")
// 	//PennyDrop
// 	router.HandleFunc("/PennyDrop", bankinfo.CheckPennyDrop).Methods("PUT")
// 	//InsertBankDetails
// 	router.HandleFunc("/InsertBankDetail", bankinfo.InsertBankDetails).Methods("PUT")
// 	//Bank Details Update
// 	router.HandleFunc("/BankDetails", bankinfo.GetBankDetailsUpdate).Methods("GET")
// 	//**************************************Demat details*************************************
// 	// insert && update the Demat information
// 	router.HandleFunc(common.BasePattern+"/Insert/Demat", demat.DematInit).Methods("POST")
// 	// get the Demat info
// 	router.HandleFunc(common.BasePattern+"/Get/Demat", demat.GetDematinBD).Methods("GET")
// 	//**************************************Documnet upload*************************************
// 	//multi file upload
// 	router.HandleFunc(common.BasePattern+"/multifileupload", fileupload.MultiFileInsertDb).Methods("POST")
// 	//single file upload
// 	// router.HandleFunc(common.BasePattern+"/singlefileupload", fileupload.SingleFileInsertDb).Methods("POST")
// 	//fetch the upload files name and id in db
// 	router.HandleFunc(common.BasePattern+"/fetchIdName", getdetailsfromdb.GetIdName).Methods("GET")
// 	//Read the Raw file in Db
// 	router.HandleFunc(common.BasePattern+"/fetchfile", getdetailsfromdb.FetchFile).Methods("GET")
// 	router.HandleFunc(common.BasePattern+"/pdffile", file.FetchRawFile).Methods("GET")
// 	//**************************************nominee info*************************************
// 	// get the inserted nominee information
// 	router.HandleFunc("/getData", nominee.Get_Nominee_DB_Details).Methods("POST")
// 	// nominee proof upload
// 	router.HandleFunc("/postNomFile", nominee.PostNomineeFile).Methods("POST")
// 	// get the nominee lockup table information
// 	router.HandleFunc("/getLookUpDetails", appscommon.GetLookUpDetails).Methods("PUT")
// 	// generate the PDF file on given nominee info
// 	router.HandleFunc("/pdfGenration", sign.PdfGeneration).Methods("PUT")
// 	// get the basic address information on given pincode
// 	router.HandleFunc("/Addressinfo", nominee.GetAddressDetails).Methods("GET")
// 	// get the drop down information
// 	router.HandleFunc(common.BasePattern+"/dropDowndata", commonpackage.HttpGetDropDownListData).Methods("POST")
// 	//**************************************jQueryfor login page*************************************
// 	// send a OTP on respective way
// 	router.HandleFunc(common.BasePattern+"/jQueryOtpCall", otprequest.GetOTPdata).Methods("PUT")
// 	// verify the given OTP
// 	router.HandleFunc(common.BasePattern+"/jQueryOtpvalidate", otprequest.ValidateOtp).Methods("PUT")
// 	// insert or update the user info in DB
// 	router.HandleFunc(common.BasePattern+"/jQuerysession", insertdata.UserRequestInit).Methods("PUT")
// 	//**************************************services and brokerage info*************************************
// 	router.HandleFunc(common.BasePattern+"/getMappedDetailsExch", services.GetServiceMappedDetails).Methods("GET")
// 	router.HandleFunc(common.BasePattern+"/getMappedDetails", services.GetBrokerageTarifMappedDetails).Methods("GET")
// 	router.HandleFunc(common.BasePattern+"/selectExchange", services.SelectExchangeValue).Methods("GET")
// 	router.HandleFunc(common.BasePattern+"/getSegment", services.SelectSegmentValue).Methods("GET")
// 	router.HandleFunc(common.BasePattern+"/getSegExDetails", services.SelectSegExDetailsHandler).Methods("GET")
// 	router.HandleFunc(common.BasePattern+"/getHeaderDetails", services.SelectHeaderDetailsHandler).Methods("GET")
// 	router.HandleFunc(common.BasePattern+"/getChargeDetails", services.SelectChargesDetailsHandler).Methods("GET")
// 	// get the services and brokerage information
// 	router.HandleFunc(common.BasePattern+"/GetserveBrok", servideandbrokerage.GetServeandBroke).Methods("GET")
// 	// insert the services and brokerage information
// 	router.HandleFunc(common.BasePattern+"/ServiceBrokerage", servideandbrokerage.ServeBrokinsert).Methods("POST")
// 	//************************************** IPV *************************************
// 	// generate a request ID for IPV
// 	router.HandleFunc(common.BasePattern+"/digiid", ipv.DigiID).Methods("POST")
// 	// Save the IPV Video and Image file form digio
// 	router.HandleFunc(common.BasePattern+"/digiidfile", ipv.SaveFile).Methods("POST")
// 	// check the IPV process status
// 	router.HandleFunc(common.BasePattern+"/ipv/status", ipv.GetIPVStatus).Methods("GET")
// 	//**************************************Router info*************************************
// 	// get over all router info
// 	router.HandleFunc(common.BasePattern+"/routerinfo", routerinfo.RouterInfo).Methods("GET")
// 	// get next router page info
// 	router.HandleFunc(common.BasePattern+"/routerflow", routerinfo.GetRouterChange).Methods("POST")
// 	//************************************** before E-sign *************************************
// 	// generate the PDF file for e-sign
// 	router.HandleFunc(common.BasePattern+"/GeneratePdf", esign.GendratePDF).Methods("POST")
// 	// get all the information related to the user
// 	router.HandleFunc(common.BasePattern+"/doceditor", esign.GetUserDetails).Methods("GET")

// 	router.HandleFunc("/sign/getEsign", esign.EsignDocument).Methods("POST")
// 	router.HandleFunc("/sign/initEsignPro", esign.InitiateEsignProcess).Methods("GET")
// 	router.HandleFunc("/sign/CheckEsigneCompleted", esign.CheckEsigneCompleted).Methods("PUT")

// 	router.HandleFunc(common.BasePattern+"/Esign", esign.AfterEsign).Methods("POST")
// 	//**************************************Get form status **************************
// 	router.HandleFunc(common.BasePattern+"/Get_Form_Status", esign.GetFileStatus).Methods("GET")

// 	//*****************************non-use******************************

// 	router.HandleFunc(common.BasePattern+"/utmSet", utmset.SetUtm).Methods("PUT")
// 	//*****************************************************************************************************
// 	return router
// }

// // --------------------------------------------------------------------
// // main function executed from command
// // --------------------------------------------------------------------
// func main2() {
// 	debug := new(helpers.HelperStruct)
// 	debug.Init()
// 	fmt.Println("Server Started.... ")

// 	f, err := os.OpenFile("./log/logfile"+time.Now().Format("02012006.15.04.05.000000000")+".txt", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
// 	if err != nil {
// 		log.Fatalf("error opening file: %v", err)
// 	}
// 	defer f.Close()

// 	log.SetOutput(f)

// 	debug.Log(helpers.Statement, "Server Started... ")

// 	//Redirect
// 	http.HandleFunc(common.BasePattern+"/redirect_url", digilocker.RedirectUrl)

// 	//Digilocker- Consolidated Flow
// 	http.HandleFunc(common.BasePattern+"/accesstocken", digilocker.GetDigilockerApi)

// 	// check the pan status
// 	http.HandleFunc(common.BasePattern+"/getpanstatus", kra.GetPanStatus)

// 	// CVLKRA - Fetch address info
// 	http.HandleFunc(common.BasePattern+"/get_kra_pan_soap", kra.GetKraPanSoap)
// 	http.HandleFunc(common.BasePattern+"/addressStatus", getdetailsfromdb.AddressStatus)

// 	// Get pincode
// 	http.HandleFunc(common.BasePattern+"/pincode", pincode.Pincode)

// 	//Manual Entry
// 	http.HandleFunc(common.BasePattern+"/manual_entry", manualProcess.Manual)

// 	//insert kyc info
// 	http.HandleFunc(common.BasePattern+"/kycinfo", kra.Kyc)

// 	//insert digi info in db
// 	http.HandleFunc(common.BasePattern+"/digiinfo", digilocker.DigiInfoInsert)

// 	//get address details from db
// 	http.HandleFunc(common.BasePattern+"/getAddress", getdetailsfromdb.GetAddress)

// 	//OTP SENDER
// 	http.HandleFunc(common.BasePattern+"/otpcall", otp.GetUserData)

// 	//OTP VERIFICATION
// 	http.HandleFunc(common.BasePattern+"/validotp", otp.ValidateOtp)

// 	// Set cokkie value based on user
// 	http.HandleFunc(common.BasePattern+"/setcookie", sessionid.SetCookie)

// 	//create a Request ID based on user
// 	http.HandleFunc(common.BasePattern+"/newuser", sessionid.NewRequestInit)

// 	// Set UTM Cookie in Browser
// 	http.HandleFunc(common.BasePattern+"/utmSet", utmset.SetUtm)

// 	//Multi file upload
// 	http.HandleFunc(common.BasePattern+"/multifileupload", fileupload.MultiFileInsertDb)

// 	//Multi file upload
// 	http.HandleFunc(common.BasePattern+"/singlefileupload", fileupload.SingleFileInsertDb)

// 	//test purpose
// 	// http.HandleFunc(common.BasePattern+"/getpassword", api.Password_Soap)
// 	// http.HandleFunc(common.BasePattern+"/pandetails", api.Get_Pan_Details_Soap)
// 	// http.HandleFunc(common.BasePattern+"/panfulldetails",api.Get_Pan_Full_Details_Soap)

// 	//Insert Personal Details
// 	http.HandleFunc("/InsertDetails", personaldetails.InsertPersonalDetails)

// 	//Ifsc Details
// 	http.HandleFunc("/IfscDetails", bankinfo.GetIFSCdetails)

// 	//PennyDrop
// 	http.HandleFunc("/PennyDrop", bankinfo.CheckPennyDrop)

// 	// //IncomeRange
// 	// http.HandleFunc("/IncomeRange", personaldetails.GetIncomeRangeList)

// 	// //TradingExperience
// 	// http.HandleFunc("/TradingExperienceList", personaldetails.GetTradingExperienceList)

// 	// //Occupation
// 	// http.HandleFunc("/OccupationList", personaldetails.GetOccupationList)

// 	// //MarritalStatus
// 	// http.HandleFunc("/MarritalStatusList", personaldetails.GetMarritalStausList)

// 	//InsertBankDetails
// 	http.HandleFunc("/InsertBankDetail", bankinfo.InsertBankDetails)

// 	//IPV
// 	// http.HandleFunc(common.BasePattern+"/ipv", ipv.IPVInsertDb)

// 	// //Educational Details
// 	// http.HandleFunc("/EducationalDetails", personaldetails.GetEducationalList)

// 	//Educational Details
// 	http.HandleFunc("/EducationalDetails", personaldetails.GetEducationalList)

// 	// //Gender Details
// 	// http.HandleFunc("/GenderList", personaldetails.GetGenderList)

// 	// //Owner Details
// 	// http.HandleFunc("/OwnerList", personaldetails.GetOwnerList)

// 	//Info Card Deatils
// 	http.HandleFunc("/CardDetails", infocard.GetCardInfo)

// 	//Personal Details Update
// 	http.HandleFunc("/PersonalDetails", personaldetails.GetPersonalUpdate)

// 	//Bank Details Update
// 	http.HandleFunc("/BankDetails", bankinfo.GetBankDetailsUpdate)

// 	// insert Demat Details
// 	http.HandleFunc(common.BasePattern+"/Insert/Demat", demat.DematInit)

// 	//get demat data in DB
// 	http.HandleFunc(common.BasePattern+"/Get/Demat", demat.GetDematinBD)

// 	//get router data in DB
// 	// http.HandleFunc(common.BasePattern+"/router", sessionid.RouterChange)

// 	//fetch the upload files name and id in db
// 	http.HandleFunc(common.BasePattern+"/fetchIdName", getdetailsfromdb.GetIdName)

// 	//fetch the upload files in db
// 	http.HandleFunc(common.BasePattern+"/fetchfile", getdetailsfromdb.FetchFile)
// 	http.HandleFunc(common.BasePattern+"/pdffile", file.FetchRawFile)

// 	// // //fetch the manual upload file in db
// 	// http.HandleFunc(common.BasePattern+"/manualFile", getdetailsfromdb.AddressProofFile)

// 	//Nominee

// 	http.HandleFunc("/getData", nominee.Get_Nominee_DB_Details)
// 	http.HandleFunc("/postNomFile", nominee.PostNomineeFile)
// 	http.HandleFunc("/getLookUpDetails", appscommon.GetLookUpDetails)
// 	http.HandleFunc("/pdfGenration", sign.PdfGeneration)
// 	http.HandleFunc("/Addressinfo", nominee.GetAddressDetails)

// 	//fetch the drop down data in db
// 	http.HandleFunc(common.BasePattern+"/dropDowndata", commonpackage.HttpGetDropDownListData)

// 	// http.Handle("getData", middleware(http.HandlerFunc(nominee.Get_Nominee_DB_Details)))
// 	// http.Handle("postNomFile", middleware(http.HandlerFunc(nominee.PostNomineeFile)))
// 	// http.Handle("getLookUpDetails", middleware(http.HandlerFunc(common.GetLookUpDetails)))

// 	//jQuary OTP send
// 	http.HandleFunc(common.BasePattern+"/jQueryOtpCall", otprequest.GetOTPdata)
// 	//jQuery OTP validate
// 	http.HandleFunc(common.BasePattern+"/jQueryOtpvalidate", otprequest.ValidateOtp)
// 	//jQuary session
// 	http.HandleFunc(common.BasePattern+"/jQuerysession", insertdata.UserRequestInit)

// 	//sessions
// 	//DYNAMIC TABLE ENDPOINT FOR (ServicesSubscriptionConfiguration)
// 	http.HandleFunc(common.BasePattern+"/getMappedDetailsExch", services.GetServiceMappedDetails)

// 	//DYNAMIC TABLE ENDPOINT FOR (BrokerageTarifConfiguration)
// 	http.HandleFunc(common.BasePattern+"/getMappedDetails", services.GetBrokerageTarifMappedDetails)

// 	http.HandleFunc(common.BasePattern+"/selectExchange", services.SelectExchangeValue)
// 	http.HandleFunc(common.BasePattern+"/getSegment", services.SelectSegmentValue)

// 	http.HandleFunc(common.BasePattern+"/getSegExDetails", services.SelectSegExDetailsHandler)
// 	http.HandleFunc(common.BasePattern+"/getHeaderDetails", services.SelectHeaderDetailsHandler)
// 	http.HandleFunc(common.BasePattern+"/getChargeDetails", services.SelectChargesDetailsHandler)

// 	// ipv
// 	// http.HandleFunc(common.BasePattern+"/ipvdata", ipv.GetIPV)
// 	// http.HandleFunc(common.BasePattern+"/ipvtype", ipv.GetIPVType)

// 	// digi id _______________________++++++++++++++++++++++++++++++++++++++++++
// 	http.HandleFunc(common.BasePattern+"/digiid", ipv.DigiID)
// 	http.HandleFunc(common.BasePattern+"/digiidfile", ipv.SaveFile)
// 	http.HandleFunc(common.BasePattern+"/ipv/status", ipv.GetIPVStatus)

// 	//#################################################################################

// 	//Router Data
// 	http.HandleFunc(common.BasePattern+"/routerinfo", routerinfo.RouterInfo)

// 	//RouterChange
// 	http.HandleFunc(common.BasePattern+"/routerflow", routerinfo.GetRouterChange)

// 	// http.HandleFunc(common.BasePattern+"/pdffile", file.FetchRawFile)

// 	// services and brokerage call
// 	http.HandleFunc(common.BasePattern+"/GetserveBrok", servideandbrokerage.GetServeandBroke)
// 	// service and brokerage insert
// 	http.HandleFunc(common.BasePattern+"/ServiceBrokerage", servideandbrokerage.ServeBrokinsert)
// 	http.HandleFunc(common.BasePattern+"/doceditor", esign.GetUserDetails)
// 	// sowmiya.l Esign
// 	http.HandleFunc("/sign/getEsign", esign.EsignDocument)
// 	http.HandleFunc("/sign/initEsignPro", esign.InitiateEsignProcess)
// 	http.HandleFunc("/sign/CheckEsigneCompleted", esign.CheckEsigneCompleted)
// 	http.HandleFunc(common.BasePattern+"/Esign", esign.AfterEsign)
// 	//esign
// 	http.HandleFunc(common.BasePattern+"/getPDF", esign.GendratePDF)
// 	//server port
// 	// http.ListenAndServe(":29094", nil)

// 	// certFile := "./cert/cert.pem"
// 	// keyFile := "./cert/key.pem"

// 	certFile := "./SSLCertificate/flattrade.crt"
// 	keyFile := "./SSLCertificate/flattrade.key"

// 	err = http.ListenAndServeTLS(":29094", certFile, keyFile, nil)
// 	if err != nil {
// 		log.Println(err.Error())
// 	}

// }
