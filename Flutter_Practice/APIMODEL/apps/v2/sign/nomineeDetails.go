package sign

import (
	"fcs23pkg/apps/v2/model"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/tomlconfig"
	"strconv"

	"encoding/json"
	"log"
	"time"
)

func GetNomineeDataForPdf(requestId string) ([]model.NomineeData_Model, error) {
	log.Println("GetNomineeDataForPdf+")

	var NomineeData model.NomineeData_Model
	var NomineeCollection []model.NomineeData_Model

	coreString := `select nd.Id,nd.NomineeName,
	(
	select nrd.description 
	from ekyc.xx_lookup_header nrh, ekyc.xx_lookup_details nrd
	where nrh.id = nrd.headerid 
	and nrd.Code = nd.NomineeRelationship 
	and nrh.Code = 'Relationship'
	) NomineeRelationship,
nd.NomineeShare,nd.NomineeDOB,nd.NomineeAddress1,nd.NomineeAddress2,nd.NomineeCity,nd.NomineeState,
nd.NomineeCountry,nd.NomineePincode, nd.NomineeMobileNo,nd.NomineeEmailId,
	(
	select nrd.description 
	from ekyc.xx_lookup_header nrh, ekyc.xx_lookup_details nrd
	where nrh.id = nrd.headerid 
	and nrd.Code = nd.NomineeProofOfIdentity 
	and nrh.Code = 'Proof_Type'
	) NomineeProofOfIdentity,nd.NomineeProofNumber,nd.GuardianName,
	nvl((
	select nrd.description 
	from ekyc.xx_lookup_header nrh, ekyc.xx_lookup_details nrd
	where nrh.id = nrd.headerid 
	and nrd.Code = nd.GuardianRelationship 
	and nrh.Code = 'G_Relationship'
	), '') GuardianRelationship,nd.GuardianAddress1, nd.GuardianAddress2,nd.GuardianCity,nd.GuardianState,nd.GuardianCountry,nd.GuardianPincode,
nd.GuardianMobileNo,nd.GuardianEmailId,
nvl((
	select nrd.description 
	from ekyc.xx_lookup_header nrh, ekyc.xx_lookup_details nrd
	where nrh.id = nrd.headerid 
	and nrd.Code = nd.GuardianProofOfIdentity 
	and nrh.Code = 'Proof_Type'
), '') GuardianProofOfIdentity,nd.GuardianProofNumber, nd.ActionState
from ekyc_nominee_details nd
where nd.RequestId = ?`

	rows, err := ftdb.NewEkyc_GDB.Query(coreString, requestId)
	if err != nil {
		common.LogError("sign.GetNomineeDataForPdf", "(SGNP01)", err.Error())
		return NomineeCollection, err
	} else {

		//data := DB_Rows_To_JSON(rows)
		defer rows.Close()
		for rows.Next() {
			err := rows.Scan(&NomineeData.NomineeID, &NomineeData.NomineeName, &NomineeData.NomineeRelationship, &NomineeData.NomineeShare,
				&NomineeData.NomineeDOB, &NomineeData.NomineeAddress1, &NomineeData.NomineeAddress2, &NomineeData.NomineeCity, &NomineeData.NomineeState,
				&NomineeData.NomineeCountry, &NomineeData.NomineePincode, &NomineeData.NomineeMobileNo, &NomineeData.NomineeEmailId, &NomineeData.NomineeProofOfIdentity,
				&NomineeData.NomineeProofNumber, &NomineeData.GuardianName, &NomineeData.GuardianRelationship,
				&NomineeData.GuardianAddress1, &NomineeData.GuardianAddress2, &NomineeData.GuardianCity, &NomineeData.GuardianState, &NomineeData.GuardianCountry,
				&NomineeData.GuardianPincode, &NomineeData.GuardianMobileNo, &NomineeData.GuardianEmailId, &NomineeData.GuardianProofOfIdentity, &NomineeData.GuardianProofNumber,
				&NomineeData.ModelState)

			if err != nil {
				common.LogError("sign.GetNomineeDataForPdf", "(SGNP02)", err.Error())
				return NomineeCollection, err
			} else {
				NomineeCollection = append(NomineeCollection, NomineeData)
			}

		}

	}
	log.Println("GetNomineeDataForPdf-")
	return NomineeCollection, nil
}

func ConstructNomineeDetails(NomineeCollection_API []model.NomineeData_Model, clientId string, RequestTableId int) (string, error) {
	log.Println("ConstructNomineeDetails+")

	var NomineeKYC model.NomineeKYC_Model
	//var FileAttachment Attachments_Model
	var err error

	var NomineeKYC_Json_str string

	log.Println("RequestTableId", RequestTableId)

	if len(NomineeCollection_API) >= 1 {
		log.Println("Inside First")


		currentTime := time.Now()

		// NomineeKYC, err = getCompanyDetails(db, NomineeKYC)
		// if err != nil {
		// 	common.LogError("sign.ConstructNomineeDetails", "(SCND01)", err.Error())
		// 	return NomineeKYC_Json_str, err
		// } else {
		//Basic Details - Company, Client
		NomineeKYC.CompanyName = tomlconfig.GtomlConfigLoader.GetValueString("kycintegrationconfig", "CompanyName")
		NomineeKYC.CompanyAddress = tomlconfig.GtomlConfigLoader.GetValueString("kycintegrationconfig", "CompanyAddress")
		NomineeKYC.Date = currentTime.Format("02-01-2006")
		NomineeKYC.DPID = "123456"
		NomineeKYC.ClientID = clientId
		NomineeKYC.ProcessType = common.NomineeProcessType
		str := strconv.Itoa(RequestTableId)
		NomineeKYC.RequestID = str

		//Nominees Details
		NomineeKYC.NomineeName1 = NomineeCollection_API[0].NomineeName

		NomineeKYC.NomineeAddress1 = NomineeCollection_API[0].NomineeAddress1 + ",<br/>" + NomineeCollection_API[0].NomineeAddress2 + ",<br/>" +
			NomineeCollection_API[0].NomineeCity + ",<br/>" + NomineeCollection_API[0].NomineeState + ",<br/>" + NomineeCollection_API[0].NomineeCountry

		NomineeKYC.NomineeShare1 = NomineeCollection_API[0].NomineeShare
		NomineeKYC.NomineeRelationship1 = NomineeCollection_API[0].NomineeRelationship
		NomineeKYC.NomineePincode1 = NomineeCollection_API[0].NomineePincode
		NomineeKYC.NomineeMobileNo1 = NomineeCollection_API[0].NomineeMobileNo
		NomineeKYC.NomineeEmailID1 = NomineeCollection_API[0].NomineeEmailId
		NomineeKYC.NomineeDOB1 = NomineeCollection_API[0].NomineeDOB
		NomineeKYC.NomineeIdentificationDocs1 = NomineeCollection_API[0].NomineeProofOfIdentity + " - " + NomineeCollection_API[0].NomineeProofNumber

		//Guardians Details
		NomineeKYC.NomineeGuardiansName1 = NomineeCollection_API[0].GuardianName

		NomineeKYC.NomineeGuardiansAddress1 = NomineeCollection_API[0].GuardianAddress1 + ",<br/>" + NomineeCollection_API[0].GuardianAddress2 + ",<br/>" +
			NomineeCollection_API[0].GuardianCity + ",<br/>" + NomineeCollection_API[0].GuardianState + ",<br/>" + NomineeCollection_API[0].GuardianCountry

		NomineeKYC.NomineeGuardianReleationship1 = NomineeCollection_API[0].GuardianRelationship
		NomineeKYC.NomineeGuardianMobile1 = NomineeCollection_API[0].GuardianMobileNo
		NomineeKYC.NomineeGuardianEmailID1 = NomineeCollection_API[0].GuardianEmailId
		NomineeKYC.NomineeGuardianPincode1 = NomineeCollection_API[0].GuardianPincode
		NomineeKYC.NomineeGuardianIdentificationDocs1 = NomineeCollection_API[0].GuardianProofOfIdentity + " - " + NomineeCollection_API[0].GuardianProofNumber

		// FileAttachment.File = NomineeCollection_API[0].NoimineeFilePath
		// FileAttachment.Title = NomineeCollection_API[0].NomineeName + "(" + NomineeCollection_API[0].NomineeShare + "%)"
		// NomineeKYC.Attachments = append(NomineeKYC.Attachments, FileAttachment)
		//log.Println("First Before Attachment: ", NomineeKYC)
		if NomineeCollection_API[0].ModelState == "added" {
			//log.Println("First inside if: ", NomineeKYC)
			NomineeKYC.Attachments, err = GetNomineeAttachments(NomineeCollection_API[0].NomineeID)
			//log.Println("First After Attachment: ", NomineeKYC)
			if err != nil {
				common.LogError("sign.ConstructNomineeDetails", "(SCND02)", err.Error())
				return NomineeKYC_Json_str, err
			}
		}

		//log.Println("First After if: ", NomineeKYC)
	}
	//log.Println("First After else: ", NomineeKYC)
	//}
	//log.Println("First: ", NomineeKYC)

	if len(NomineeCollection_API) >= 2 {
		log.Println("Inside Second")
		//Nominees Details
		NomineeKYC.NomineeName2 = NomineeCollection_API[1].NomineeName

		NomineeKYC.NomineeAddress2 = NomineeCollection_API[1].NomineeAddress1 + ",<br/>" + NomineeCollection_API[1].NomineeAddress2 + ",<br/>" +
			NomineeCollection_API[1].NomineeCity + ",<br/>" + NomineeCollection_API[1].NomineeState + ",<br/>" + NomineeCollection_API[1].NomineeCountry

		NomineeKYC.NomineeShare2 = NomineeCollection_API[1].NomineeShare
		NomineeKYC.NomineeRelationship2 = NomineeCollection_API[1].NomineeRelationship
		NomineeKYC.NomineePincode2 = NomineeCollection_API[1].NomineePincode
		NomineeKYC.NomineeMobileNo2 = NomineeCollection_API[1].NomineeMobileNo
		NomineeKYC.NomineeEmailID2 = NomineeCollection_API[1].NomineeEmailId
		NomineeKYC.NomineeDOB2 = NomineeCollection_API[1].NomineeDOB
		NomineeKYC.NomineeIdentificationDocs2 = NomineeCollection_API[1].NomineeProofOfIdentity + " - " + NomineeCollection_API[1].NomineeProofNumber

		//Guardians Details
		NomineeKYC.NomineeGuardiansName2 = NomineeCollection_API[1].GuardianName

		NomineeKYC.NomineeGuardiansAddress2 = NomineeCollection_API[1].GuardianAddress1 + ",<br/>" + NomineeCollection_API[1].GuardianAddress2 + ",<br/>" +
			NomineeCollection_API[1].GuardianCity + ",<br/>" + NomineeCollection_API[1].GuardianState + ",<br/>" + NomineeCollection_API[1].GuardianCountry

		NomineeKYC.NomineeGuardianReleationship2 = NomineeCollection_API[1].GuardianRelationship
		NomineeKYC.NomineeGuardianMobile2 = NomineeCollection_API[1].GuardianMobileNo
		NomineeKYC.NomineeGuardianEmailID2 = NomineeCollection_API[1].GuardianEmailId
		NomineeKYC.NomineeGuardianPincode2 = NomineeCollection_API[1].GuardianPincode
		NomineeKYC.NomineeGuardianIdentificationDocs2 = NomineeCollection_API[1].GuardianProofOfIdentity + " - " + NomineeCollection_API[1].GuardianProofNumber

		// FileAttachment.File = NomineeCollection_API[1].NoimineeFilePath
		// FileAttachment.Title = NomineeCollection_API[1].NomineeName + "(" + NomineeCollection_API[1].NomineeShare + "%)"
		// NomineeKYC.Attachments = append(NomineeKYC.Attachments, FileAttachment)

		// if NomineeCollection_API[1].GuardianFilePath != "" {
		// 	FileAttachment.File = NomineeCollection_API[1].GuardianFilePath
		// 	FileAttachment.Title = NomineeCollection_API[1].GuardianName + "(Guardian) for " +
		// 		NomineeCollection_API[1].NomineeName + "(" + NomineeCollection_API[0].NomineeShare + "%)"
		// 	NomineeKYC.Attachments = append(NomineeKYC.Attachments, FileAttachment)
		// }

		if NomineeCollection_API[1].ModelState == "added" {

			NomineeKYC.Attachments, err = GetNomineeAttachments(NomineeCollection_API[1].NomineeID)
			if err != nil {
				common.LogError("sign.ConstructNomineeDetails", "(SCND03)", err.Error())
				return NomineeKYC_Json_str, err
			}
		}
	}
	log.Println("Second: ", NomineeKYC)
	if len(NomineeCollection_API) == 3 {
		log.Println("Inside Third")

		//Nominees Details
		NomineeKYC.NomineeName3 = NomineeCollection_API[2].NomineeName

		NomineeKYC.NomineeAddress3 = NomineeCollection_API[2].NomineeAddress1 + ",<br/>" + NomineeCollection_API[2].NomineeAddress2 + ",<br/>" +
			NomineeCollection_API[2].NomineeCity + ",<br/>" + NomineeCollection_API[2].NomineeState + ",<br/>" + NomineeCollection_API[2].NomineeCountry

		NomineeKYC.NomineeShare3 = NomineeCollection_API[2].NomineeShare
		NomineeKYC.NomineeRelationship3 = NomineeCollection_API[2].NomineeRelationship
		NomineeKYC.NomineePincode3 = NomineeCollection_API[2].NomineePincode
		NomineeKYC.NomineeMobileNo3 = NomineeCollection_API[2].NomineeMobileNo
		NomineeKYC.NomineeEmailID3 = NomineeCollection_API[2].NomineeEmailId
		NomineeKYC.NomineeDOB3 = NomineeCollection_API[2].NomineeDOB
		NomineeKYC.NomineeIdentificationDocs3 = NomineeCollection_API[2].NomineeProofOfIdentity + " - " + NomineeCollection_API[2].NomineeProofNumber

		//Guardians Details
		NomineeKYC.NomineeGuardiansName3 = NomineeCollection_API[2].GuardianName

		NomineeKYC.NomineeGuardiansAddress3 = NomineeCollection_API[2].GuardianAddress1 + ",<br/>" + NomineeCollection_API[2].GuardianAddress2 + ",<br/>" +
			NomineeCollection_API[2].GuardianCity + ",<br/>" + NomineeCollection_API[2].GuardianState + ",<br/>" + NomineeCollection_API[2].GuardianCountry

		NomineeKYC.NomineeGuardianReleationship3 = NomineeCollection_API[2].GuardianRelationship
		NomineeKYC.NomineeGuardianMobile3 = NomineeCollection_API[2].GuardianMobileNo
		NomineeKYC.NomineeGuardianEmailID3 = NomineeCollection_API[2].GuardianEmailId
		NomineeKYC.NomineeGuardianPincode3 = NomineeCollection_API[2].GuardianPincode
		NomineeKYC.NomineeGuardianIdentificationDocs3 = NomineeCollection_API[2].GuardianProofOfIdentity + " - " + NomineeCollection_API[2].GuardianProofNumber

		// FileAttachment.File = NomineeCollection_API[2].NoimineeFilePath
		// FileAttachment.Title = NomineeCollection_API[2].NomineeName + "(" + NomineeCollection_API[2].NomineeShare + "%)"
		// NomineeKYC.Attachments = append(NomineeKYC.Attachments, FileAttachment)

		// if NomineeCollection_API[2].GuardianFilePath != "" {
		// 	FileAttachment.File = NomineeCollection_API[2].GuardianFilePath
		// 	FileAttachment.Title = NomineeCollection_API[2].GuardianName + "(Guardian) for " +
		// 		NomineeCollection_API[2].NomineeName + "(" + NomineeCollection_API[0].NomineeShare + "%)"
		// 	NomineeKYC.Attachments = append(NomineeKYC.Attachments, FileAttachment)
		// }

		if NomineeCollection_API[2].ModelState == "added" {

			NomineeKYC.Attachments, err = GetNomineeAttachments(NomineeCollection_API[2].NomineeID)
			if err != nil {
				common.LogError("sign.ConstructNomineeDetails", "(SCND04)", err.Error())
				return NomineeKYC_Json_str, err
			}
		}
	}

	log.Println("Third: ", NomineeKYC)

	NomineeKYC_Json, err := json.Marshal(NomineeKYC)
	if err != nil {
		common.LogError("sign.ConstructNomineeDetails", "(SCND05)", err.Error())
		return NomineeKYC_Json_str, err
	} else {
		NomineeKYC_Json_str = string(NomineeKYC_Json)
	}

	log.Println("ConstructNomineeDetails-")
	return NomineeKYC_Json_str, nil

}

// func getCompanyDetails(db *sql.DB, NomineeKYC model.NomineeKYC_Model) (model.NomineeKYC_Model, error) {
// 	log.Println("getCompanyDetails+")

// 	var err error
// 	NomineeKYC.CompanyName, err = common.GetCoreSettingValue("FCS_23_KYC_CompanyName")
// 	if err != nil {
// 		common.LogError("sign.getCompanyDetails", "(SGCD01)", err.Error())
// 		return NomineeKYC, err
// 	} else {
// 		NomineeKYC.CompanyAddress, err = common.GetCoreSettingValue("FCS_23_KYC_CompanyAddress")
// 		if err != nil {
// 			common.LogError("sign.getCompanyDetails", "(SGCD02)", err.Error())
// 			return NomineeKYC, err
// 		}
// 	}
// 	log.Println("getCompanyDetails-")
// 	return NomineeKYC, nil
// }

func GetNomineeAttachments(nomineeId int64) ([]model.Attachments_Model, error) {
	log.Println("GetNomineeAttachments+")

	var attachRec model.Attachments_Model
	var attachmentArr []model.Attachments_Model

	coreString := `
	select  dad1.FilePath, concat( nd.NomineeName , '( ',nd.NomineeShare,'% )') title
	from  ekyc_nominee_details nd, ekyc.document_attachment_details dad1
	where nd.NomineeFileUploadDocIds = dad1.id 
	and nd.Id = ?
	union
	select dad2.FilePath, concat(nd.GuardianName , '(Guardian) for ' , nd.NomineeName, '( ', nd.NomineeShare  , '% )') title
	from  ekyc_nominee_details nd, ekyc.document_attachment_details dad2
	where nd.GuardianFileUploadDocIds = dad2.id 
	and nd.Id = ?`

	rows, err := ftdb.NewEkyc_GDB.Query(coreString, nomineeId, nomineeId)
	if err != nil {
		common.LogError("sign.GetNomineeAttachments", "(SGNA01)", err.Error())
		return attachmentArr, err
	} else {

		//data := DB_Rows_To_JSON(rows)
		defer rows.Close()

		for rows.Next() {
			err := rows.Scan(&attachRec.File, &attachRec.Title)

			if err != nil {
				common.LogError("sign.GetNomineeAttachments", "(SGNA01)", err.Error())
				return attachmentArr, err
			} else {
				attachmentArr = append(attachmentArr, attachRec)
			}

		}

	}
	log.Println("GetNomineeAttachments-")
	return attachmentArr, nil

}
