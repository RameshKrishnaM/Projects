package sendalertmail

import (
	"database/sql"
	"fcs23pkg/ftdb"
	"fcs23pkg/tomlconfig"
	"strconv"

	"log"
	"time"
)

type TooManyConnStruct struct {
	ToMail            string
	Subject           string
	lContent1         string
	lContent2         string
	lAlertMailContent AlertStruct
}

func LogDBStats() {
	var lTooManyConn TooManyConnStruct

	lTooManyConn.lAlertMailContent.Header = tomlconfig.GtomlConfigLoader.GetValueString("alertconfig", "ToomanyDBConnAlertHeader")
	lTooManyConn.lContent1 = tomlconfig.GtomlConfigLoader.GetValueString("alertconfig", "ToomanyDBConnAlertContent")
	lTooManyConn.lContent2 = tomlconfig.GtomlConfigLoader.GetValueString("alertconfig", "ToomanyDBConnAlertContent1")

	lTooManyConn.Subject = tomlconfig.GtomlConfigLoader.GetValueString("alertconfig", "ToomanyDBConnAlertSub")
	lTooManyConn.ToMail = tomlconfig.GtomlConfigLoader.GetValueString("alertconfig", "ToMail")
	// lTooManyConn.ToMail = coresettings.GetCoreSettingValue(ftdb.NewEkyc_GDB, lToMail)
	for {
		lTooManyConn.lAlertMailContent.Content = lTooManyConn.lContent1 + ftdb.MariaEKYCPRD + lTooManyConn.lContent2
		lTooManyConn.LogConnectionStatus(ftdb.MariaEKYCPRD_GDB, ftdb.MariaEKYCPRD)

		lTooManyConn.lAlertMailContent.Content = lTooManyConn.lContent1 + ftdb.MariaFTPRD + lTooManyConn.lContent2
		lTooManyConn.LogConnectionStatus(ftdb.MariaFTPRD_GDB, ftdb.MariaFTPRD)

		lTooManyConn.lAlertMailContent.Content = lTooManyConn.lContent1 + ftdb.NewKycDB + lTooManyConn.lContent2
		lTooManyConn.LogConnectionStatus(ftdb.NewEkyc_GDB, ftdb.NewKycDB)
		time.Sleep(30 * time.Second)
	}
}

func (t *TooManyConnStruct) LogConnectionStatus(lDb *sql.DB, lDbType string) {

	lStats := lDb.Stats()
	log.Printf(lDbType+" >> Open connections: %d, In use: %d, Idle: %d, Wait count: %d, Wait duration: %s",
		lStats.OpenConnections, lStats.InUse, lStats.Idle, lStats.WaitCount, lStats.WaitDuration)
	// lMaxConnection := tomlconfig.GtomlConfigLoader.GetValueString("globalDbAndHttpClientLimit", "DbMaxOpenConns")
	lMaxConnection := tomlconfig.GtomlConfigLoader.GetValueString("alertconfig", "DbMaxOpenConns")

	if intValue, lErr := strconv.Atoi(lMaxConnection); lStats.Idle == intValue {
		if lErr != nil {
			log.Println("DBConnAlert.LCS001", lErr.Error())
		}
		lErr := CommonAlertMail(nil, lDbType, t.lAlertMailContent, t.Subject, t.ToMail)
		if lErr != nil {
			log.Println("DBConnAlert.LCS002", lErr.Error())
		}
	}
}
