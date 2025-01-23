package main

import (
	"crypto/tls"
	"fcs23pkg/apps/v1/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"fcs23pkg/util/sendalertmail"
	"fcs23pkg/versioncontroller"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"time"
)

func autoRestart() {

	////Get the current time
	//now := time.Now()

	////Set the restart time to 4:00 AM
	//restart := time.Date(now.Year(), now.Month(), now.Day(), 4, 0, 0, 0, now.Location())

	////Calculate the duration until the restart time
	//duration := restart.Sub(now)

	////Sleep for the duration until the restart time
	//time.Sleep(duration)

	////time.Sleep(5 * time.Second)
	for {
		now := time.Now()
		//resart the program everyday at 4am
		//at 3am, the program goes for 1 hour sleep and after that it will restart
		if now.Hour() == 3 {
			//sleep for an hour so that the hour changes to 4 and this condition
			//in the loop does not  continue again in next iteration
			time.Sleep(60 * 61 * time.Second)
			fmt.Println(now.Hour(), now.Minute(), now.Second())
			log.Println(now.Hour(), now.Minute(), now.Second())
			//Restart the program
			fmt.Println("Restarting the program...")
			log.Println("Restarting the program...")
			execPath, err := os.Executable()
			if err != nil {
				fmt.Println("Error getting executable path:", err)
				log.Println("Error getting executable path:", err)

				return
			}
			cmd := exec.Command(execPath)
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
			err = cmd.Start()
			if err != nil {
				fmt.Println("Error restarting program:", err)
				log.Println("Error restarting program:", err)
				return
			}
			os.Exit(0)

		}
		time.Sleep(60 * 30 * time.Second)
	}
}

func main() {

	PortNo := ":28595"
	ProgramName := "FCS_263_InstaKYC_API"
	var lErr error

	// Global toml Values Read
	tomlconfig.Init()
	//Global http Client Read
	apiUtil.Init()

	log.SetFlags(log.Ldate | log.Ltime)
	f, lErr := os.OpenFile("./log/logfile"+time.Now().Format("02012006.15.04.05.000000000")+".txt", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)

	if lErr != nil {
		log.Panic("Error in Log File Opening (M01)", lErr.Error())
	}
	defer f.Close()
	mw := io.MultiWriter(os.Stdout, f)

	log.SetOutput(mw)

	// if strings.EqualFold(tomlconfig.GtomlConfigLoader.GetValueString("debug", "LogFileCreate"), "1") {
	// 	fmt.Println(ProgramName + " Server Started in " + common.AppRunMode + PortNo + " ...")
	// 	f, err := os.OpenFile("./log/logfile"+time.Now().Format("02012006.15.04.05.000000000")+".txt", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	// 	if err != nil {
	// 		log.Fatalf("error opening file: %v", err)
	// 	}
	// 	defer f.Close()
	// 	log.SetOutput(f)
	// }
	log.Println(ProgramName + " Server Started in " + common.AppRunMode + PortNo + " ...")

	SetEnvironment()
	go autoRestart()

	pDBName1 := ftdb.NewKycDB
	ftdb.NewEkyc_GDB, lErr = ftdb.LocalDbConnect(pDBName1)
	if lErr != nil {
		log.Fatalf("error opening connection: %v", lErr)
	}

	pDBName2 := ftdb.MariaFTPRD
	ftdb.MariaFTPRD_GDB, lErr = ftdb.LocalDbConnect(pDBName2)
	if lErr != nil {
		log.Fatalf("error opening connection: %v", lErr)
	}

	pDBName3 := ftdb.MariaEKYCPRD
	ftdb.MariaEKYCPRD_GDB, lErr = ftdb.LocalDbConnect(pDBName3)
	if lErr != nil {
		log.Fatalf("error opening connection: %v", lErr)
	}
	go sendalertmail.LogDBStats()
	lHandlers := versioncontroller.RouterInit()

	srv := &http.Server{
		ReadTimeout:  120 * time.Second,
		WriteTimeout: 120 * time.Second,
		IdleTimeout:  120 * time.Second,
		Handler:      lHandlers,
		Addr:         PortNo,
	}

	if common.AppRunMode == "uat" {
		certFile := "./SSLCertificate/flattrade.crt"
		keyFile := "./SSLCertificate/flattrade.key"

		tlsConfig := &tls.Config{
			// Causes servers to use Go's default ciphersuite preferences,
			// which are tuned to avoid attacks. Does nothing on clients.
			PreferServerCipherSuites: true,
			// Only use curves which have assembly implementations
			CurvePreferences: []tls.CurveID{
				tls.CurveP256,
				tls.X25519, // Go 1.8 only
			},
			MinVersion: tls.VersionTLS12,
			CipherSuites: []uint16{
				tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
				tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
				tls.TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305, // Go 1.8 only
				tls.TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,   // Go 1.8 only
				tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
				tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,

				// Best disabled, as they don't provide Forward Secrecy,
				// but might be necessary for some clients
				// tls.TLS_RSA_WITH_AES_256_GCM_SHA384,
				// tls.TLS_RSA_WITH_AES_128_GCM_SHA256,
			},
			//GetCertificate: m.GetCertificate,
		}

		pemCert, err := ioutil.ReadFile(certFile)
		log.Println(err)
		pemKey, err := ioutil.ReadFile(keyFile)
		log.Println(err)
		tlsConfig.Certificates = make([]tls.Certificate, 1)
		tlsConfig.Certificates[0], err = tls.X509KeyPair(pemCert, pemKey)
		log.Println(err)

		srv = &http.Server{
			ReadTimeout:  120 * time.Second,
			WriteTimeout: 120 * time.Second,
			IdleTimeout:  120 * time.Second,
			Handler:      lHandlers,
			TLSConfig:    tlsConfig,
			Addr:         PortNo,
		}

		log.Fatal(srv.ListenAndServeTLS("", ""))
	} else {
		log.Fatal(srv.ListenAndServe())
	}

}

func SetEnvironment() {
	sessionid.SetCrmStages()

	common.EKYCDomain = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "EKYCDomain")
	common.EKYCAllowedOrigin = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "EKYCAllowedOrigin")
	common.EKYCAppName = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "EKYCAppName")
	common.AppRunMode = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "AppRunMode")
	//fmt.Println("Domain :", common.EKYCDomain)
	//Development & Testing Purpose
	common.MobileOtpSend = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "MobileOtpSend")
	common.EmailOtpSend = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "EmailOtpSend")
	common.BOCheck = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "BOCheck")

	common.TestAllow = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestAllow")
	common.TestEmail = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestEmail")
	common.TestMobile = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestMobile")
	common.TestOTP = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestOTP")
	common.TestPan = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestPan")
	common.TestDOB = tomlconfig.GtomlConfigLoader.GetValueString("envconfig", "TestDOB")

}
