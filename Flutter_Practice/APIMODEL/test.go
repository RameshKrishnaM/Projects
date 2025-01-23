package main

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"fcs23pkg/util/sendalertmail"
	"log"
	"os"
	"time"
)

func main() {
	log.Println("EsignFile Save (+)")
	tomlconfig.Init()
	lDebug := new(helpers.HelperStruct)
	lDebug.Init()
	var lErr error
	apiUtil.Init()
	f, err := os.OpenFile("./log/logfile"+time.Now().Format("02012006.15.04.05.000000000")+".txt", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	if err != nil {
		log.Fatalf("error opening file: %v", err)
	}
	defer f.Close()
	log.SetOutput(f)

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

	sendalertmail.LogDBStats()

}
