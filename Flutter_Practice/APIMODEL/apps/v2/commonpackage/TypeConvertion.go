package commonpackage

import (
	"log"
	"strconv"
)

func StringToFloatConvert(pValue string) float64 {
	log.Println("StringToFloatConvert(+)")
	if pValue == "" {
		pValue = "0.0"
	}
	floatValue, lErr := strconv.ParseFloat(pValue, 64)
	if lErr != nil {
		log.Println("StringToFloatConvert:001", lErr)
		return floatValue
	}
	log.Println("StringToFloatConvert(-)")
	return floatValue
}

func StringToIntConvert(pValue string) int {
	log.Println("StringToFloatConvert(+)")
	if pValue == "" {
		pValue = "0"
	}
	floatValue, lErr := strconv.Atoi(pValue)
	if lErr != nil {
		log.Println("StringToFloatConvert:001", lErr)
		return floatValue
	}
	log.Println("StringToFloatConvert(-)")
	return floatValue
}
