package creditsmanage

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
)

type CreditStruct struct {
	RequestId      string
	Vendor         string
	Service        string
	InwardCredits  string
	OutwardCredits string
	VendorSrvKey   string
}

func LogVendorCredit(pDebug *helpers.HelperStruct, pVendorKey, pServiceKey, pUid string) {
	pDebug.Log(helpers.Statement, "LogVendorCredit (+)")
	lVendor := tomlconfig.GtomlConfigLoader.GetValueString("credits", pVendorKey)
	lService := tomlconfig.GtomlConfigLoader.GetValueString("credits", pServiceKey)

	pDebug.Log(helpers.Details, "Vendor >> ", lVendor, "_Service >> ", lService)

	lCreditDetails := CreditStruct{
		RequestId:    pUid,
		VendorSrvKey: lVendor + "_" + lService,
		Vendor:       lVendor,
		Service:      lService,
	}
	lErr := InsertCreditLog(pDebug, lCreditDetails)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "LVC001 : ", lErr)
	}
	pDebug.Log(helpers.Statement, "LogVendorCredit (-)")
}

func InsertCreditLog(pDebug *helpers.HelperStruct, pCreditDetails CreditStruct) (lErr error) {
	pDebug.Log(helpers.Statement, "InsertCreditLog (+)")

	var (
		lSource           = tomlconfig.GtomlConfigLoader.GetValueString("credits", "Source")
		lAutoBot          = "Autobot"
		lTransaction_Type = tomlconfig.GtomlConfigLoader.GetValueString("credits", "OutwardTrnx")
		lMasterId         string
		lCreditFlag       = tomlconfig.GtomlConfigLoader.GetValueString("credits", "CreditsLogFlag")
	)

	//Check for Credit Flag
	if lCreditFlag == "Y" {
		lMasterMap, lErr := FetchOverallService(pDebug)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}

		lMasterId = lMasterMap[pCreditDetails.VendorSrvKey]
		lCoreString := `
		INSERT INTO credits_mgmt_log
		(Request_Uid,Credit_Master_Id, Vendor, Service, TransactionDate,Source,Credits,Transaction_Type, Created_by, Created_date, Updated_by, Updated_date)
		VALUES(?,?,?,?,now(),?,1,?,?,unix_timestamp(),?,unix_timestamp());
		`

		_, lErr = ftdb.MariaEKYCPRD_GDB.Exec(lCoreString, pCreditDetails.RequestId, lMasterId, pCreditDetails.Vendor, pCreditDetails.Service, lSource, lTransaction_Type, lAutoBot, lAutoBot)
		if lErr != nil {
			pDebug.Log(helpers.Elog, lErr.Error())
			return helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "InsertCreditLog (-)")
	return nil
}

func FetchOverallService(pDebug *helpers.HelperStruct) (map[string]string, error) {
	pDebug.Log(helpers.Statement, "FetchOverallService (+)")

	var (
		lMasterRec      = make(map[string]string)
		lVendor_Service string
		lId             string
	)

	lCoreString := `
	SELECT 
	coalesce(id,''),
    concat(coalesce(Vendor,''),'_',coalesce(Service,'')) service 
    FROM 
    credits_mgmt_master cmm
	`

	lRows, lErr := ftdb.MariaEKYCPRD_GDB.Query(lCoreString)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "FOS001 : ", lErr.Error())
		return lMasterRec, helpers.ErrReturn(lErr)
	} else {
		defer lRows.Close()
		for lRows.Next() {
			lErr = lRows.Scan(&lId, &lVendor_Service)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "FOS002 : ", lErr.Error())
				return lMasterRec, helpers.ErrReturn(lErr)
			} else {
				lMasterRec[lVendor_Service] = lId
			}
		}

	}

	pDebug.Log(helpers.Statement, "FetchOverallService (-)")
	return lMasterRec, nil
}
