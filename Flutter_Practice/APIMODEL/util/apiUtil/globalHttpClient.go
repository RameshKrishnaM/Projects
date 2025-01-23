package apiUtil

import (
	"errors"
	"fcs23pkg/tomlconfig"
	"log"
	"net/http"
	"strconv"
	"time"
)

// Global http Client
var GClient *http.Client

// Initialize the http.Client with a custom Transport
func Init() error {
	lMaxIdleConns := tomlconfig.GtomlConfigLoader.GetValueString("globalDbAndHttpClientLimit", "MaxIdleConns")
	lIdleConnTimeout := tomlconfig.GtomlConfigLoader.GetValueString("globalDbAndHttpClientLimit", "IdleConnTimeout")
	lMaxIdleConnsPerHost := tomlconfig.GtomlConfigLoader.GetValueString("globalDbAndHttpClientLimit", "MaxIdleConnsPerHost")
	lTimeout := tomlconfig.GtomlConfigLoader.GetValueString("globalDbAndHttpClientLimit", "Timeout")

	// Convert string to int
	lMaxIdleConnsInt, lErr := strconv.Atoi(lMaxIdleConns)
	if lErr != nil {
		log.Println("Error(AUINIT001):", lErr)
		return errors.New(" Error(AUINIT001) :" + lErr.Error())
	}

	// Convert string to int
	lIdleConnTimeoutInt, lErr := strconv.Atoi(lIdleConnTimeout)
	if lErr != nil {
		log.Println("Error(AUINIT002):", lErr)
		return errors.New(" Error(AUINIT002) :" + lErr.Error())
	}

	// Convert string to int
	lMaxIdleConnsPerHostInt, lErr := strconv.Atoi(lMaxIdleConnsPerHost)
	if lErr != nil {
		log.Println("Error(AUINIT003):", lErr)
		return errors.New(" Error(AUINIT003) :" + lErr.Error())
	}

	// Convert string to int
	lTimeoutInt, lErr := strconv.Atoi(lTimeout)
	if lErr != nil {
		log.Println("Error(AUINIT004):", lErr)
		return errors.New(" Error(AUINIT004) :" + lErr.Error())
	}

	transport := &http.Transport{
		MaxIdleConns:        lMaxIdleConnsInt,                                 // Total number of idle connections
		IdleConnTimeout:     time.Duration(lIdleConnTimeoutInt) * time.Second, // Timeout for idle connections
		MaxIdleConnsPerHost: lMaxIdleConnsPerHostInt,                          // Max idle connections per host
	}

	GClient = &http.Client{
		Transport: transport,
		Timeout:   time.Duration(lTimeoutInt) * time.Second, // Timeout for HTTP requests
	}

	return nil

}
