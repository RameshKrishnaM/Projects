package helpers

import (
	"encoding/json"
	"fcs23pkg/common"
	"log"
)

type Error_Response struct {
	Status       string `json:"status"`
	ErrorCode    string `json:"statusCode"`
	ErrorMessage string `json:"msg"`
}

type Msg_Response struct {
	Status      string `json:"status"`
	Title       string `json:"title"`
	Description string `json:"description"`
}

func GetMsg_String(Msg_Title string, Msg_Description string) string {

	var Msg_Res Msg_Response

	Msg_Res.Status = common.SuccessCode
	Msg_Res.Title = Msg_Title
	Msg_Res.Description = Msg_Description

	result, err := json.Marshal(Msg_Res)

	if err != nil {
		log.Println(err)
	}

	return string(result)

}

func GetError_String(Err_Title string, Err_Description string) string {

	var Err_Response Error_Response

	Err_Response.Status = common.ErrorCode
	Err_Response.ErrorCode = Err_Title
	Err_Response.ErrorMessage = Err_Description

	lResult, err := json.Marshal(Err_Response)

	if err != nil {
		log.Println(err)
	}

	return string(lResult)

}
