package ftdb

import (
	"database/sql"
	"fcs23pkg/tomlconfig"
	"fmt"
	"log"
	"strconv"
	"time"

	_ "github.com/denisenkom/go-mssqldb"
	_ "github.com/go-sql-driver/mysql"
)

// Structure to hold database connection details
type DatabaseType struct {
	Server   string
	Port     int
	User     string
	Password string
	Database string
	DBType   string
	DB       string
}

// structure to hold all db connection details used in this program
type AllUsedDatabases struct {
	TechExcelUAT  DatabaseType
	Kyc           DatabaseType
	MariaDB       DatabaseType
	KamabalaDB    DatabaseType
	KamabalaApiDB DatabaseType
	MariaEkyc     DatabaseType
	NewKycDB      DatabaseType
}

var NewEkyc_GDB, MariaFTPRD_GDB, MariaEKYCPRD_GDB, MainDB_GDB *sql.DB

// ---------------------------------------------------------------------------------
// function opens the db connection and return connection variable
// ---------------------------------------------------------------------------------
func LocalDbConnect(DBtype string) (*sql.DB, error) {
	DbDetails := new(AllUsedDatabases)
	DbDetails.Init()

	connString := ""
	localDBtype := ""

	var db *sql.DB
	var err error
	var dataBaseConnection DatabaseType
	// get connection details
	if DBtype == DbDetails.TechExcelUAT.DB {
		dataBaseConnection = DbDetails.TechExcelUAT
		localDBtype = DbDetails.TechExcelUAT.DBType
	} else if DBtype == DbDetails.KamabalaDB.DB {
		dataBaseConnection = DbDetails.KamabalaDB
		localDBtype = DbDetails.KamabalaDB.DBType
	} else if DBtype == DbDetails.MariaDB.DB {
		dataBaseConnection = DbDetails.MariaDB
		localDBtype = DbDetails.MariaDB.DBType
	} else if DBtype == DbDetails.Kyc.DB {
		dataBaseConnection = DbDetails.Kyc
		localDBtype = DbDetails.Kyc.DBType
	} else if DBtype == DbDetails.KamabalaApiDB.DB {
		dataBaseConnection = DbDetails.KamabalaApiDB
		localDBtype = DbDetails.KamabalaApiDB.DBType
	} else if DBtype == DbDetails.MariaEkyc.DB {
		dataBaseConnection = DbDetails.MariaEkyc
		localDBtype = DbDetails.MariaEkyc.DBType
	} else if DBtype == DbDetails.NewKycDB.DB {
		dataBaseConnection = DbDetails.NewKycDB
		localDBtype = DbDetails.NewKycDB.DBType
	}
	// Prepare connection string
	if localDBtype == "mssql" {
		connString = fmt.Sprintf("server=%s;user id=%s;password=%s;port=%d;database=%s;", dataBaseConnection.Server, dataBaseConnection.User, dataBaseConnection.Password, dataBaseConnection.Port, dataBaseConnection.Database)
	} else if localDBtype == "mysql" {
		connString = fmt.Sprintf("%s:%s@tcp(%s:%d)/%s", dataBaseConnection.User, dataBaseConnection.Password, dataBaseConnection.Server, dataBaseConnection.Port, dataBaseConnection.Database)
	}

	DbMaxIdleConnsStr := tomlconfig.GtomlConfigLoader.GetValueString("globalDbAndHttpClientLimit", "DbMaxIdleConns")
	DbMaxOpenConnsStr := tomlconfig.GtomlConfigLoader.GetValueString("globalDbAndHttpClientLimit", "DbMaxOpenConns")
	DbConMaxIdleTimeStr := tomlconfig.GtomlConfigLoader.GetValueString("globalDbAndHttpClientLimit", "DbConMaxIdleTime")

	DbMaxIdleConns, err := strconv.Atoi(DbMaxIdleConnsStr)
	if err != nil {
		log.Println("error in while converting the DbMaxIdleConns")
	}

	DbMaxOpenConns, err := strconv.Atoi(DbMaxOpenConnsStr)
	if err != nil {
		log.Println("error in while converting the DbMaxOpenConns")

	}

	DbConMaxIdleTime, err := strconv.Atoi(DbConMaxIdleTimeStr)
	if err != nil {
		log.Println("error in while converting the DbConMaxIdleTime")

	}

	//make a connection to db
	if localDBtype != "" {
		db, err = sql.Open(localDBtype, connString)
		//db, err := util.Getdb(localDBtype, connString)
		if err != nil {
			log.Println("Open connection failed:", err.Error())
		} else {
			// Set the maximum number of open connections (max pool size)
			db.SetMaxOpenConns(DbMaxOpenConns) // Adjust this value as needed
			// Set the maximum number of idle connections in the pool
			db.SetMaxIdleConns(DbMaxIdleConns)
			db.SetConnMaxIdleTime(time.Second * time.Duration(DbConMaxIdleTime))

		}
	} else {
		return db, fmt.Errorf("Invalid DB Details")
	}

	return db, err
}

// --------------------------------------------------------------------
//
//	execute bulk inserts
//
// --------------------------------------------------------------------
func ExecuteBulkStatement(db *sql.DB, sqlStringValues string, sqlString string) error {
	log.Println("ExecuteBulkStatement+")
	//trim the last ,
	sqlStringValues = sqlStringValues[0 : len(sqlStringValues)-1]
	_, err := db.Exec(sqlString + sqlStringValues)
	if err != nil {
		log.Println(err)
		log.Println("ExecuteBulkStatement-")
		return err
	} else {
		log.Println("inserted Sucessfully")
	}
	log.Println("ExecuteBulkStatement-")
	return nil
}
