package docpreview

import (
	"fcs23pkg/ftdb"
	"fcs23pkg/helpers"
	"strings"
)

type BoidMappingStruct struct {
	BoId      string
	ClientId  string
	RequestId string
	Indicator string
	User      string
	Flag      string
}

func GetBoid(pDebug *helpers.HelperStruct, pReqId string) (string, error) {
	pDebug.Log(helpers.Statement, "GetBoid (+)")
	var lBoid string

	lCoreString := `select nvl(bo_id ,'0') boid 
					from ekyc_request
					where Uid = ? `
	lRows, lErr := ftdb.NewEkyc_GDB.Query(lCoreString, pReqId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CGPD02 :", lErr.Error())
		return "", helpers.ErrReturn(lErr)
	}
	defer lRows.Close()
	for lRows.Next() {
		lErr = lRows.Scan(&lBoid)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CGPD03 :", lErr.Error())
			return "", helpers.ErrReturn(lErr)
		}
	}

	if lBoid == "0" {
		lSqlStrings := `select bo_id 
					from boid_data_collection 
					where mapping_flag <> 'Y' limit 1  `

		lRows, lErr = ftdb.NewEkyc_GDB.Query(lSqlStrings)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "CGPD02 :", lErr.Error())
			return "", helpers.ErrReturn(lErr)
		}
		defer lRows.Close()
		for lRows.Next() {
			lErr = lRows.Scan(&lBoid)
			if lErr != nil {
				pDebug.Log(helpers.Elog, "CGPD03 :", lErr.Error())
				return "", helpers.ErrReturn(lErr)
			}
		}
		lCoreString := `update ekyc_request set bo_id=?
					  where Uid=?`
		_, lErr = ftdb.NewEkyc_GDB.Exec(lCoreString, lBoid, pReqId)
		if lErr != nil {
			return "", helpers.ErrReturn(lErr)
		}
	}

	pDebug.Log(helpers.Statement, "GetBoid (-)")
	return lBoid, nil
}
func UpdateBoIdStatus(pDebug *helpers.HelperStruct, pData BoidMappingStruct) error {
	pDebug.Log(helpers.Statement, "UpdateBoIdStatus (+)")

	var lSqlStrings, lSqlSubStrings, lCondition string

	if strings.EqualFold("Mapping", pData.Indicator) {
		lSqlSubStrings = "request_uid = '" + pData.RequestId + "', client_id = '" + pData.ClientId + "', mapping_flag = ?, mapping_date = unix_timestamp(now()),"
		lCondition = "where bo_id = ?"
	} else if strings.EqualFold("Success", pData.Indicator) {
		lSqlSubStrings = "success_flag = ?, success_date = unix_timestamp(now()),"
		lCondition = "where request_uid = ?"
	}

	lSqlStrings = `update boid_data_collection
	set ` + lSqlSubStrings + `updatedBy = ?, updatedDate = unix_timestamp(now())` + lCondition

	_, lErr := ftdb.NewEkyc_GDB.Exec(lSqlStrings, pData.Flag, pData.User, pData.BoId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CGPD02 :", lErr.Error())
		return helpers.ErrReturn(lErr)
	}

	pDebug.Log(helpers.Statement, "UpdateBoIdStatus (-)")
	return nil
}
