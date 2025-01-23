package bankinfo

import (
	"fcs23pkg/apps/v2/bankinfo/model"
	pennydrop "fcs23pkg/apps/v2/bankinfo/pennyDrop"
	"fcs23pkg/helpers"
)

func PennyDropValidation(pDebug *helpers.HelperStruct, pReqData model.BankDetails) (model.PennyDropRespStruct, error) {
	// Log the entry point of the function
	pDebug.Log(helpers.Statement, "PennyDropValidation (+)")
	var lRespData model.PennyDropRespStruct // Structure to store the response data
	// Validate Penny Drop
	lLastInsertedContactId, lContactId, lErr := pennydrop.CreateContact(pDebug, pReqData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PennyDropValidation:003: "+lErr.Error()) // Log error
		return lRespData, helpers.ErrReturn(lErr)
	}
	lLastInsertedFundId, lFundAccountId, lErr := pennydrop.CreateFundAccount(pDebug, lLastInsertedContactId, lContactId, pReqData)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "PennyDropValidation:003: "+lErr.Error()) // Log error
		return lRespData, helpers.ErrReturn(lErr)
	} else {
		lValidation, lIsCompleted, lErr := pennydrop.ValidateBankAccount(pDebug, pReqData.LoggedBy, lFundAccountId, lLastInsertedFundId, lLastInsertedContactId)
		if lErr != nil {
			pDebug.Log(helpers.Elog, "PennyDropValidation:004: "+lErr.Error()) // Log error
			return lRespData, helpers.ErrReturn(lErr)
		} else {
			lRespData.Data.PennyDropStatus = lValidation.Data.Status
			lRespData.Data.RegisterName = lValidation.Data.Results.Register_Name
			lRespData.Data.ValidateId = lValidation.Data.Id
			lRespData.Data.IsCompleted = lIsCompleted
			lRespData.Data.AccountStatus = lValidation.Data.Results.Account_Status
		}
	}
	// Log the successful completion of the function
	pDebug.Log(helpers.Statement, "PennyDropValidation (-)")
	return lRespData, nil
}
