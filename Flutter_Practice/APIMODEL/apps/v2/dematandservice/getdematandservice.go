package dematandservice

import (
	"encoding/json"
	"fcs23pkg/apps/v2/commonpackage"
	"fcs23pkg/apps/v2/sessionid"
	"fcs23pkg/common"
	"fcs23pkg/coresettings"
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fmt"
	"net/http"
	"strings"
)

type DematAndServiceStruct struct {
	Status         string                    `json:"status"`
	DematInfo      DematStruct               `json:"dematinfo"`
	BrokHead       []string                  `json:"brokhead"`
	BrokData       [][]string                `json:"brokdata"`
	BrokDbData     []DataStruct              `json:"brokdbdata"`
	ServiceMap     map[string]SegementStruct `json:"service_map"`
	BankDetail     BankDetailStruct          `json:"bankinfo"`
	AggregatorFlag string                    `json:"aggregatorFlag"`
}
type BankDetailStruct struct {
	MobileNumber  string `json:"mobileno"`
	BankName      string `json:"bankname"`
	MaskedAccount string `json:"maskaccount"`
}
type DataStruct struct {
	ID         string `json:"brokerageid"`
	Rowhead    string `json:"rowhead"`
	Colhead    string `json:"colhead"`
	Values     string `json:"values"`
	UserSelect string `json:"userselect"`
}

type SegementStruct struct {
	Segement   string           `json:"segement"`
	Exchange   []ExchangeStruct `json:"exchange"`
	UserStatus string           `json:"userstatus"`
	Selected   string           `json:"selected"`
}
type ExchangeStruct struct {
	ID   string `json:"exchangeid"`
	Name string `json:"exchangename"`
}

type DematStruct struct {
	DPscheme                 string `json:"dpscheme"`
	DPschemeDesc             string `json:"dpschemedesc"`
	TariffDetailsUrl         string `json:"tariffDetailsUrl"`
	DIS                      string `json:"dis"`
	EDIS                     string `json:"edis"`
	DISDescription           string `json:"disDescription"`
	EDISDescription          string `json:"edisDescription"`
	RunningAccSettlement     string `json:"runningAccSettlement"`
	RunningAccSettlementDesc string `json:"runningAccSettlementDesc"`
}

func GetDematandService(w http.ResponseWriter, r *http.Request) {
	lDebug := new(helpers.HelperStruct)
	lDebug.SetUid(r)
	lDebug.Log(helpers.Statement, "GetDematandService (+)")

	w.Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Access-Control-Expose-Headers", "Set-Cookie")
	w.Header().Set("Access-Control-Allow-Methods", "GET")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, credentials")

	var lDematRec DematAndServiceStruct
	lDematRec.Status = common.SuccessCode

	if strings.EqualFold("get", r.Method) {
		lSid, lUid, lErr := sessionid.GetOldSessionUID(r, lDebug, common.EKYCCookieName)
		lDebug.SetReference(lUid)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DGD01", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DGD01", "Somthing is wrong please try again later"))
			return
		}

		lDemetandServiceInfo, lErr := ServiceandBrockInfo(lDebug, lUid, lSid, r)
		if lErr != nil {
			lDebug.Log(helpers.Elog, "DGD03", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DGD03", "Somthing is wrong please try again later"))
			return
		}

		lDatas, lErr := json.Marshal(&lDemetandServiceInfo)
		lDebug.Log(helpers.Details, "lDatas", string(lDatas))

		if lErr != nil {
			lDebug.Log(helpers.Elog, "DGD04", lErr.Error())
			fmt.Fprint(w, helpers.GetError_String("DGD04", "Somthing is wrong please try again later"))
			return
		}
		fmt.Fprint(w, string(lDatas))

	}
	lDebug.Log(helpers.Statement, "GetDematandService (-)")

}

func ServiceandBrockInfo(pDebug *helpers.HelperStruct, pUid, pSid string, pReq *http.Request) (lDematAndServiceRec DematAndServiceStruct, lErr error) {
	pDebug.Log(helpers.Statement, "ServiceandBrockInfo (+)")

	lDematAndServiceRec.Status = common.SuccessCode

	lErr = DeleteBrokerage(pDebug, pUid)
	if lErr != nil {
		return lDematAndServiceRec, helpers.ErrReturn(lErr)
	}

	lErr = DeleteService(pDebug, pUid)
	if lErr != nil {
		return lDematAndServiceRec, helpers.ErrReturn(lErr)
	}
	lSessionId, lTestUserFlag, lErr := sessionid.VerifyTestUserSession(pReq, pDebug, common.EKYCCookieName, pUid)
	if lErr != nil {
		return lDematAndServiceRec, helpers.ErrReturn(lErr)
	}
	lErr = BrokInsert(pDebug, pUid, pSid, lTestUserFlag, lSessionId)
	if lErr != nil {
		return lDematAndServiceRec, helpers.ErrReturn(lErr)
	}

	lErr = ServeInsert(pDebug, pUid, pSid, lTestUserFlag, lSessionId)
	if lErr != nil {
		return lDematAndServiceRec, helpers.ErrReturn(lErr)
	}
	lDematAndServiceRec.BankDetail, lErr = GetBankInfo(pDebug, pUid)
	if lErr != nil {
		return lDematAndServiceRec, helpers.ErrReturn(lErr)
	}
	lDematAndServiceRec.DematInfo, lErr = GetDematInfo(pDebug, pUid, lTestUserFlag, lSessionId)
	if lErr != nil {
		return lDematAndServiceRec, helpers.ErrReturn(lErr)
	}
	lTariffDetailUrl := tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "TariffDetailUrl")
	AggregatorFlag := tomlconfig.GtomlConfigLoader.GetValueString("accountaggregator", "AggregatorFlag")
	lDematAndServiceRec.AggregatorFlag = AggregatorFlag
	
	lDematAndServiceRec.DematInfo.TariffDetailsUrl = coresettings.GetCoreSettingValue(ftdb.MariaEKYCPRD_GDB, lTariffDetailUrl)

	lDematAndServiceRec.BrokHead, lDematAndServiceRec.BrokData, lDematAndServiceRec.BrokDbData, lErr = GetBrokerage(pDebug, pUid, "Segment")
	if lErr != nil {
		return lDematAndServiceRec, helpers.ErrReturn(lErr)
	}

	lDematAndServiceRec.ServiceMap, _, lErr = GetServiceMap(pDebug, pUid, lTestUserFlag, lSessionId)
	if lErr != nil {
		return lDematAndServiceRec, helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "ServiceandBrockInfo (+)")
	return lDematAndServiceRec, nil
}
func GetBankInfo(pDebug *helpers.HelperStruct, pUid string) (lDematBankData BankDetailStruct, lErr error) {
	pDebug.Log(helpers.Statement, "GetDematInfo (+)")

	lCorestring := `
	select NVL( er.Phone,''),NVL(eb.Bank_Name,''),NVL(eb.Acc_Number,'') from ekyc_request er , ekyc_bank eb where er.Uid =eb.Request_Uid and er.Uid =?
	`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pUid)
	if lErr != nil {
		return lDematBankData, helpers.ErrReturn(lErr)
	}
	for lRows.Next() {
		lErr := lRows.Scan(&lDematBankData.MobileNumber, &lDematBankData.BankName, &lDematBankData.MaskedAccount)
		if lErr != nil {
			return lDematBankData, helpers.ErrReturn(lErr)
		}
	}
	lSize := len(lDematBankData.MaskedAccount)
	lLastFourDigit := lDematBankData.MaskedAccount[lSize-4:]

	// Create a masked string with 'X' characters

	lDematBankData.MaskedAccount = strings.Repeat("X", lSize-4) + lLastFourDigit
	pDebug.Log(helpers.Statement, "GetDematInfo (-)")
	return lDematBankData, nil
}
func GetDematInfo(pDebug *helpers.HelperStruct, pUid, pTestUserFlag, pSessionId string) (lDematData DematStruct, lErr error) {
	pDebug.Log(helpers.Statement, "GetDematInfo (+)")

	lCorestring := `
	select nvl(DP_scheme,"") ,nvl(DIS,""),nvl(EDIS ,""),nvl(RunningAccSettlement,"")
	from ekyc_demat_details
	where requestuid =?
	and ( ? or Updated_Session_Id  = ?)`
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCorestring, pUid, pTestUserFlag, pSessionId)
	if lErr != nil {
		return lDematData, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lDematData.DPscheme, &lDematData.DIS, &lDematData.EDIS, &lDematData.RunningAccSettlement)
		if lErr != nil {
			return lDematData, helpers.ErrReturn(lErr)
		}
	}

	if lDematData.DISDescription == "" {
		lDematData.DISDescription = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "DISDescription")
	}

	if lDematData.EDISDescription == "" {
		lDematData.EDISDescription = tomlconfig.GtomlConfigLoader.GetValueString("dpscheme", "EDISDescription")
	}

	if lDematData.DPscheme != "" && lDematData.DIS != "" && lDematData.EDIS != "" {
		lLookupdataRespRec, lErr := commonpackage.GetLookUpDescription(pDebug, "DematData", lDematData.DPscheme, "code")
		if lErr != nil {
			return lDematData, helpers.ErrReturn(lErr)
		}
		lDematData.DPschemeDesc = lLookupdataRespRec.Descirption
		lLookupdataRespRec, lErr = commonpackage.GetLookUpDescription(pDebug, "Settlement_Type", lDematData.RunningAccSettlement, "code")
		if lErr != nil {
			return lDematData, helpers.ErrReturn(lErr)
		}
		lDematData.RunningAccSettlementDesc = lLookupdataRespRec.Descirption
	}
	pDebug.Log(helpers.Statement, "GetDematInfo (-)")
	return lDematData, nil
}

func BrokInsert(pDebug *helpers.HelperStruct, pUid, pSid, pTestUserFlag, pSessionId string) error {
	pDebug.Log(helpers.Details, "BrokInsert(+)")

	lInsertQuery := `INSERT INTO ekyc_brokerage (Mapping, Enabled, Request_Uid, Session_Id, Updated_Session_Id, CreatedDate, UpdatedDate)
	SELECT sub_table.id, 'Y', ?, ?, ?, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()
	FROM (
		select ebschm.id 
					from ekyc_brok_seg_charge_head_map ebschm ,ekyc_brok_charge_master ebcm, ekyc_brok_head_master ebhm,ekyc_brok_seg_master ebsm 
					where ebschm.Enabled ='Y'
					and ebschm.Charge_Id =ebcm.id 
					and ebcm.Enabled ='Y'
					and ebschm.Head_Id=ebhm.id 
					and ebhm.Enabled ='Y'
					and ebschm.Segment_Id=ebsm.id 
					and ebsm.Enabled ='Y'
	) sub_table
	LEFT JOIN (select *
	from ekyc_brokerage
	where Request_Uid=?
	and (? or Updated_Session_Id = ? )) table_2 ON sub_table.id = table_2.Mapping
	WHERE table_2.Mapping IS null ;`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lInsertQuery, pUid, pSid, pSid, pUid, pTestUserFlag, pSessionId)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "BrokInsert(-)")
	return nil
}

func ServeInsert(pDebug *helpers.HelperStruct, pUid, pSid, pTestUserFlag, pSessionId string) error {
	pDebug.Log(helpers.Details, "ServeInsert(+)")

	lInsertQuery := `INSERT INTO ekyc_services (Mapping, Selected,u_selected, Request_Uid, Session_Id, Updated_Session_Id, CreatedDate, UpdatedDate,segement_id,exchange_id)
	SELECT sub_table.map_id, 'Y','Y', ?, ?, ?, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(),sub_table.segment_id,sub_table.exchange_id
	FROM (
		SELECT eesm.id as map_id,esm.id as segment_id,eem.id as exchange_id
		FROM ekyc_exchange_segment_mapping eesm
		JOIN ekyc_segment_master esm ON eesm.Segment_Id = esm.id AND esm.Enabled = 'Y'
		JOIN ekyc_exchange_master eem ON eesm.Exchange_Id = eem.id AND eem.Enabled = 'Y'
		WHERE eesm.Enabled = 'Y'
	) sub_table
	LEFT JOIN (select *
	from ekyc_services
	where Request_Uid=? 
	and (? or Updated_Session_Id = ? )) table_2 ON sub_table.map_id = table_2.Mapping
	WHERE table_2.Mapping IS null ;`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lInsertQuery, pUid, pSid, pSid, pUid, pTestUserFlag, pSessionId)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "ServeInsert(-)")
	return nil
}

func DeleteService(pDebug *helpers.HelperStruct, pUid string) error {
	pDebug.Log(helpers.Details, "DeleteService(+)")
	lServiceDelete := `DELETE FROM ekyc_services
		WHERE Mapping not IN (
		select distinct sub_table.id
		from ( SELECT eesm.id
				FROM ekyc_exchange_segment_mapping eesm, ekyc_segment_master esm, ekyc_exchange_master eem 
				WHERE eesm.Enabled = 'Y'
				  AND eesm.Segment_Id = esm.id
				  AND esm.Enabled = 'Y'
				  AND eesm.Exchange_Id = eem.id
				  AND eem.Enabled = 'Y') sub_table)and Request_Uid='` + pUid + `';`

	_, lErr := ftdb.NewEkyc_GDB.Exec(lServiceDelete)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "DeleteService(-)")
	return nil
}

func DeleteBrokerage(pDebug *helpers.HelperStruct, pUid string) error {
	pDebug.Log(helpers.Details, "DeleteBrokerage(+)")
	lBrokDelete := `DELETE FROM ekyc_brokerage
		WHERE Mapping not IN (
		select distinct sub_table.id
		from ( select ebschm.id 
				from ekyc_brok_seg_charge_head_map ebschm ,ekyc_brok_charge_master ebcm, ekyc_brok_head_master ebhm,ekyc_brok_seg_master ebsm 
				where ebschm.Enabled ='Y'
				and ebschm.Charge_Id =ebcm.id 
				and ebcm.Enabled ='Y'
				and ebschm.Head_Id=ebhm.id 
				and ebhm.Enabled ='Y'
				and ebschm.Segment_Id=ebsm.id 
				and ebsm.Enabled ='Y') sub_table)and Request_Uid='` + pUid + `';`
	_, lErr := ftdb.NewEkyc_GDB.Exec(lBrokDelete)
	if lErr != nil {
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Details, "DeleteBrokerage(-)")
	return nil
}

func GetBrokerage(pDebug *helpers.HelperStruct, pUid, pFirstcell string) ([]string, [][]string, []DataStruct, error) {
	pDebug.Log(helpers.Statement, "GetBrokerage (+)")
	var lDataArr []DataStruct
	var lDataRec DataStruct

	lRowRec := []string{pFirstcell}
	var lColRec []string
	var lFinalArr [][]string
	lMapData := make(map[string][]string)

	lBrokerageQuery := `
		select nvl(ebschm.id,""),nvl(ebsm.Segment_Name,"") , REPLACE(ebhm.Head_name, '%', '%%'), REPLACE(ebcm.Charge_value, '%', '%%'),nvl(eb.Enabled,"")
		from ekyc_brok_seg_charge_head_map ebschm ,ekyc_brok_charge_master ebcm, ekyc_brok_head_master ebhm,ekyc_brok_seg_master ebsm,ekyc_brokerage eb
		where ebschm.Enabled ='Y'
		and ebcm.Enabled ='Y'
		and ebschm.Charge_Id =ebcm.id 
		and ebhm.Enabled ='Y'
		and ebschm.Head_Id=ebhm.id 
		and ebsm.Enabled ='Y'
		and ebschm.Segment_Id=ebsm.id 
		and eb.Mapping =ebschm.id 
		and eb.Request_Uid ='` + pUid + `'
		order by ebschm.id;`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lBrokerageQuery)
	if lErr != nil {
		return nil, nil, nil, helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lDataRec.ID, &lDataRec.Colhead, &lDataRec.Rowhead, &lDataRec.Values, &lDataRec.UserSelect)
		pDebug.Log(helpers.Details, "lRows", lRows)
		if lErr != nil {
			return nil, nil, nil, helpers.ErrReturn(lErr)
		}

		if !Member(lDataRec.Rowhead, lRowRec) {
			lRowRec = append(lRowRec, lDataRec.Rowhead)
		}
		if !Member(lDataRec.Colhead, lColRec) {
			lColRec = append(lColRec, lDataRec.Colhead)
		}
		lMapData[lDataRec.Colhead] = []string{lDataRec.Colhead}
		lDataArr = append(lDataArr, lDataRec)
	}

	for _, lData := range lDataArr {
		for lHeadIdx := 1; lHeadIdx < len(lRowRec); lHeadIdx++ {
			if len(lMapData[lData.Colhead]) < len(lRowRec) {
				if lData.Rowhead == lRowRec[lHeadIdx] {
					lMapData[lData.Colhead] = append(lMapData[lData.Colhead], lData.Values+",ID:"+lData.ID)
				} else {
					lMapData[lData.Colhead] = append(lMapData[lData.Colhead], "N/A")
				}
			} else if lData.Rowhead == lRowRec[lHeadIdx] {
				lMapData[lData.Colhead][lHeadIdx] = lData.Values + ",ID:" + lData.ID
			}
		}
	}

	for _, lRowVal := range lColRec {
		lFinalArr = append(lFinalArr, lMapData[lRowVal])
	}

	pDebug.Log(helpers.Details, "\nlRowRec:", lRowRec, "\nlColRec:", lMapData, "\nlDataArr:", lDataArr)
	pDebug.Log(helpers.Statement, "GetBrokerage (-)")
	return lRowRec, lFinalArr, lDataArr, nil
}

func GetServiceMap(pDebug *helpers.HelperStruct, pUid, pTestUserFlag, pSessionId string) (map[string]SegementStruct, []DataStruct, error) {
	pDebug.Log(helpers.Statement, "GetServiceInfo (+)")
	var lDataArr []DataStruct
	var lDataRec DataStruct

	lMapData := make(map[string]SegementStruct)
	// var lSegmentRec SegementStruct
	var lExchangeRec ExchangeStruct

	lServicesQuery := `select nvl(eesm.id,"") ,nvl(eem.Exchange,"")  ,nvl(esm.Segment,"") ,nvl(eesm.User_status,"") ,nvl(es.Selected,""), ld.DisplayOrder   
		from ekyc_exchange_segment_mapping eesm ,ekyc_segment_master esm ,ekyc_exchange_master eem,ekyc_services es ,lookup_details ld 
		where eesm .Enabled ='Y'
				and eesm.Segment_Id =esm.id 
				and esm.Enabled ='Y' 
				and eesm.Exchange_Id =eem.id 
				and eem.Enabled ='Y'
				and es.Mapping =eesm.id 
				and es.Request_Uid ='` + pUid + `'
				and (? or Updated_Session_Id  = ? )
				and ld.code=esm.Segment
				group by eesm.id
				order by ld.DisplayOrder;`

	lRows, lErr := ftdb.NewEkyc_GDB.Query(lServicesQuery, pTestUserFlag, pSessionId)
	if lErr != nil {
		return nil, nil, helpers.ErrReturn(lErr)
	}
	lSegmentHeader := "Segment Name"
	// lSegmentDescription := "Segment Name"
	lExchangeHeader := "Exchange Name"
	// lExchangeDescription := "Exchange Name"
	lDisplayPosition := ""
	defer lRows.Close()
	for lRows.Next() {
		lErr := lRows.Scan(&lDataRec.ID, &lDataRec.Colhead, &lDataRec.Rowhead, &lDataRec.Values, &lDataRec.UserSelect, &lDisplayPosition)
		pDebug.Log(helpers.Details, "lRows", lRows)
		if lErr != nil {
			return nil, nil, helpers.ErrReturn(lErr)
		}
		// lRowHeader, _, lErr := commonpackage.ReadDropDownData(lSegmentHeader, lSegmentDescription, lDataRec.Rowhead, pDebug)
		// if lErr != nil {
		// 	return nil, nil, helpers.ErrReturn(lErr)
		// }
		lLookupdataRespRec, lErr := commonpackage.GetLookUpDescription(pDebug, lSegmentHeader, lDataRec.Rowhead, "code")
		if lErr != nil {
			return nil, nil, helpers.ErrReturn(lErr)
		}
		lRowHeader := lLookupdataRespRec.Descirption
		// lExchange, _, lErr := commonpackage.ReadDropDownData(lExchangeHeader, lExchangeDescription, lDataRec.Colhead, pDebug)
		// if lErr != nil {
		// 	return nil, nil, helpers.ErrReturn(lErr)
		// }
		lLookupdataRespRec, lErr = commonpackage.GetLookUpDescription(pDebug, lExchangeHeader, lDataRec.Colhead, "code")
		if lErr != nil {
			return nil, nil, helpers.ErrReturn(lErr)
		}
		lExchange := lLookupdataRespRec.Descirption
		lSegmentRec, LFlag := lMapData[lDisplayPosition]
		lExchangeRec.ID = lDataRec.ID
		if lRowHeader == "CURRENCY" && lExchange == "NSE" {
			lExchangeRec.Name = "CDS"
		} else if lRowHeader == "CURRENCY" && lExchange == "BSE" {
			lExchangeRec.Name = "BCD"
		} else if lRowHeader == "FUTURE AND OPTIONS" && lExchange == "NSE" {
			lExchangeRec.Name = "NFO"
		} else if lRowHeader == "FUTURE AND OPTIONS" && lExchange == "BSE" {
			lExchangeRec.Name = "BFO"
		} else {
			lExchangeRec.Name = lExchange
		}
		if !LFlag {
			lSegmentRec.Segement = lRowHeader
			lSegmentRec.Exchange = []ExchangeStruct{lExchangeRec}
			lSegmentRec.UserStatus = lDataRec.Values
			lSegmentRec.Selected = lDataRec.UserSelect
			lMapData[lDisplayPosition] = lSegmentRec
		} else {
			if strings.EqualFold(lSegmentRec.UserStatus, "N") {
				lSegmentRec.UserStatus = lDataRec.Values
			}
			lSegmentRec.Exchange = append(lSegmentRec.Exchange, lExchangeRec)
			lMapData[lDisplayPosition] = lSegmentRec
		}
		lDataArr = append(lDataArr, lDataRec)
	}

	pDebug.Log(helpers.Details, "\nlColRec:", lMapData, "\nlDataArr:", lDataArr)
	pDebug.Log(helpers.Statement, "GetServiceInfo (-)")
	return lMapData, lDataArr, nil
}

func Member(pValue, pColectionArr interface{}) bool {
	return strings.Contains(fmt.Sprintf("%v", pColectionArr), fmt.Sprintf("%v", pValue))
}
