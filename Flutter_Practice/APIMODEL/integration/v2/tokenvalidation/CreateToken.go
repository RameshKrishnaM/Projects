package tokengen

import (
	"fcs23pkg/helpers"
	"fcs23pkg/tomlconfig"
	"fcs23pkg/util/apiUtil"
	"log"
	"net/http"
)

func KubeCreateCode(pDebug *helpers.HelperStruct, pJsonBody string) (string, error) {
	pDebug.Log(helpers.Statement, "KubeCreateCode (+)")
	var lErr error
	var lResp string
	var lHeaderArr []apiUtil.HeaderDetails

	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("serviceconfig", "CreateCode")

	// Make the API call to create the code.
	lResp, lErr = apiUtil.Api_call(pDebug, lUrl, http.MethodPost, pJsonBody, lHeaderArr, "Kubernates Token")
	if lErr != nil {
		log.Println("KubeCreateCode:Error02", lErr)
		return lResp, lErr
	}
	pDebug.Log(helpers.Statement, "KubeCreateCode (-)")
	return lResp, lErr
}

func KubeGenerateToken(pDebug *helpers.HelperStruct, pJsonBody string) (string, error) {
	pDebug.Log(helpers.Statement, "KubeGenerateToken (+)")
	var lResp string
	var lHeaderArr []apiUtil.HeaderDetails

	// Read specific configurations from the file
	lUrl := tomlconfig.GtomlConfigLoader.GetValueString("serviceconfig", "GenerateToken")

	// Step 1: Make an API call to request a token
	lResp, lErr := apiUtil.Api_call(pDebug, lUrl, http.MethodPost, pJsonBody, lHeaderArr, "Kubernates Token")
	if lErr != nil { // Handle any errors during the API call
		log.Println("KubeGenerateToken:Error03", lErr)
		return lResp, lErr // Return error if API call fails
	}
	// Step 2: send resp return of the method
	pDebug.Log(helpers.Statement, "KubeGenerateToken (-)")
	return lResp, nil // Return the client code and generated token
}
