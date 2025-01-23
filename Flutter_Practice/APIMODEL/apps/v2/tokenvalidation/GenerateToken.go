package tokenvalidation

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fcs23pkg/helpers"
	tokengen "fcs23pkg/integration/v2/tokenvalidation"
	"fcs23pkg/tomlconfig"
	"log"
)

type ClientId struct {
	Client_id string `json:"client_id"`
}

type Secret struct {
	Secret string `json:"secret"`
}

type KubeCreateCodeResp struct {
	Code       string `json:"code"`
	Status     string `json:"status"`
	Msg        string `json:"msg"`
	StatusCode string `json:"statusCode"`
}

type KubeGenerateTokenResp struct {
	Token      string `json:"token"`
	Status     string `json:"status"`
	Msg        string `json:"msg"`
	StatusCode string `json:"statusCode"`
	Requ_time  string `json:"requ_time"`
}

/*
Purpose :
The purpose of this method is used to
 1. Validate the registerd clientId, secret and created code.
 2. If both are validated then generate the token.

Parameters : pDebug,pUrl,pClientID,pSource
Response :

	On success
	==========
	{
		"client_id" : "ABCD"
		"code"      : ""
		"token"     : "3eadfvb78mbxgktdredfcv78ndlopwa"
		"requ_time" : "2024-10-03 11.15.44"
		"status"    : "S"
		"msg"       : ""
		"statusCode": ""
	}
	On error
	========
	{
		"client_id" : "ABCD"
		"code"      : ""
		"token"     : ""
		"requ_time" : "2024-10-03 11.15.44"
		"status"    : "E"
		"msg"       : "Error Message"
		"statusCode": "ESCU38"
	}

Authorization : Logeshkumar P
Date : 20 Nov 2024
*/
func GenerateToken(pDebug *helpers.HelperStruct) (string, string, error) {
	pDebug.Log(helpers.Statement, "GenerateToken (-)")
	var lKubeGenerateTokenResp KubeGenerateTokenResp // Struct to store the API response
	var lSecret Secret                               // Struct to hold the secret for the token request
	var lCode string                                 // To hold the generated code from KubeCreateCode
	// Read specific configurations from the file
	// Token generation URL
	lSecKey := tomlconfig.GtomlConfigLoader.GetValueString("serviceconfig", "RegisterSecret") // App secret code
	lClientCode := tomlconfig.GtomlConfigLoader.GetValueString("serviceconfig", "RegisterClientID")
	// Step 1: Generate a code using the CreateCode function
	lCode, lErr := CreateCode(pDebug, lClientCode)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "GT001", lErr.Error())
		return "", "", helpers.ErrReturn(lErr)
	}
	pDebug.Log(helpers.Details, "lCode", lCode)

	// Step 2: Concatenate client ID, generated code, and secret key to create a unique string
	lConCad := lClientCode + lCode + lSecKey

	// Step 3: Encode the concatenated string using SHA-256 and assign it to the secret field
	lSecret.Secret = EncodeSecret(lConCad)
	lBody, lErr := json.Marshal(lSecret)
	if lErr != nil { // Handle any errors during marshalling
		pDebug.Log(helpers.Elog, "GT002", lErr.Error())
		return "", "", helpers.ErrReturn(lErr) // Return error if marshalling fails
	}

	lResp, lErr := tokengen.KubeGenerateToken(pDebug, string(lBody))
	if lErr != nil { // Handle any errors during marshalling
		pDebug.Log(helpers.Elog, "GT003", lErr.Error())
		return "", "", helpers.ErrReturn(lErr) // Return error if marshalling fails
	}
	pDebug.Log(helpers.Details, "lResp", lResp, "lSecret.Secret", lSecret.Secret)
	// Step 4: Unmarshal the API response into the lKubeGenerateTokenResp struct
	lErr = json.Unmarshal([]byte(lResp), &lKubeGenerateTokenResp)
	if lErr != nil { // Handle any errors during unmarshalling
		pDebug.Log(helpers.Elog, "GT004", lErr.Error())
		return "", "", helpers.ErrReturn(lErr) // Return error if unmarshalling fails
	} else {
		// Step 5: Check if the response indicates an error (Status == "E")
		if lKubeGenerateTokenResp.Status == "E" {
			lErr = errors.New(lKubeGenerateTokenResp.StatusCode + lKubeGenerateTokenResp.Msg) // Combine status code and message into an error
			return lClientCode, lKubeGenerateTokenResp.Token, lErr                            // Return error if the API returns an error status
		}
	}
	pDebug.Log(helpers.Statement, "GenerateToken (-)")
	return lClientCode, lKubeGenerateTokenResp.Token, nil
}

/*
Purpose :
The purpose of this method is used to
 1. Create code for the registered clientId via createcode service.

Parameters : pDebug,pUrl,pClientID,pSource
Response :

	On success
	==========
	{
		"client_id" : "ABCD"
		"code"      : "3eadfvb78mbxgktdredfcv78ndlopwa"
		"token"     : ""
		"requ_time" : "2024-10-03 11.15.44"
		"status"    : "S"
		"msg"       : ""
		"statusCode": ""
	}
	On error
	========
	{
		"client_id" : "ABCD"
		"code"      : ""
		"token"     : ""
		"requ_time" : "2024-10-03 11.15.44"
		"status"    : "E"
		"msg"       : "Error Message"
		"statusCode": "ESCU38"
	}

Authorization : Logeshkumar P
Date : 20 Nov 2024
*/
func CreateCode(pDebug *helpers.HelperStruct, Client_id string) (string, error) {
	pDebug.Log(helpers.Statement, "CreateToken (+)")
	var lClientId ClientId
	var lErr error
	var lKubeCreateCodeResp KubeCreateCodeResp

	// Read configuration from the TOML file for client ID and API URL.
	lClientId.Client_id = Client_id

	// Marshal client ID to JSON and send it in the request body.
	lBody, lErr := json.Marshal(lClientId)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CT001", lErr.Error())
		return lKubeCreateCodeResp.Code, lErr
	}
	lResp, lErr := tokengen.KubeCreateCode(pDebug, string(lBody))
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CT002", lErr.Error())
		return lKubeCreateCodeResp.Code, lErr
	}
	lErr = json.Unmarshal([]byte(lResp), &lKubeCreateCodeResp)
	if lErr != nil {
		pDebug.Log(helpers.Elog, "CT003", lErr.Error())
		return lKubeCreateCodeResp.Code, lErr
	} else {
		// Check if the response status is an error ("E").
		if lKubeCreateCodeResp.Status == "E" {
			pDebug.Log(helpers.Elog, "CT004", lErr.Error())
			lErr = errors.New(lKubeCreateCodeResp.StatusCode + lKubeCreateCodeResp.Msg)
			return lKubeCreateCodeResp.Code, lErr
		}
	}
	pDebug.Log(helpers.Statement, "CreateToken (-)")
	return lKubeCreateCodeResp.Code, nil

}
func EncodeSecret(pSecret string) string {
	log.Println("EncodeSecret(+)")
	apiSecretsha256 := sha256.Sum256([]byte(pSecret))
	log.Println("EncodeSecret(-)")
	return hex.EncodeToString(apiSecretsha256[:])
}
