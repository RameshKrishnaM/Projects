package ftdb

import (
	"fcs23pkg/tomlconfig"
	"strconv"
)

const (
	MariaFTPRD   = "MARIAFTPRD"
	MariaEKYCPRD = "MARIAEKYCPRD"
	NewKycDB     = "NKYCDB"
)

// Initializing DB Details
func (d *AllUsedDatabases) Init() {

	//setting Maria db connection details
	d.MariaDB.Server = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaDBServer")
	d.MariaDB.Port, _ = strconv.Atoi(tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaDBPort"))
	d.MariaDB.User = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaDBUser")
	d.MariaDB.Password = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaDBPassword")
	d.MariaDB.Database = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaDBDatabase")
	d.MariaDB.DBType = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaDBDBType")
	d.MariaDB.DB = MariaFTPRD
	//setting Maria KYC db connection details
	d.MariaEkyc.Server = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaEkycServer")
	d.MariaEkyc.Port, _ = strconv.Atoi(tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaEkycPort"))
	d.MariaEkyc.User = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaEkycUser")
	d.MariaEkyc.Password = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaEkycPassword")
	d.MariaEkyc.Database = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaEkycDatabase")
	d.MariaEkyc.DBType = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaEkycDBType")
	d.MariaEkyc.DB = MariaEKYCPRD

	//setting Maria New KYC db connection details
	d.NewKycDB.Server = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaNEkycServer")
	d.NewKycDB.Port, _ = strconv.Atoi(tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaNEkycPort"))
	d.NewKycDB.User = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaNEkycUser")
	d.NewKycDB.Password = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaNEkycPassword")
	d.NewKycDB.Database = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaNEkycDatabase")
	d.NewKycDB.DBType = tomlconfig.GtomlConfigLoader.GetValueString("dbconfig", "MariaNEkycDBType")
	d.NewKycDB.DB = NewKycDB
}
