package versioncontroller

import (
	"fcs23pkg/apigate"
	"fcs23pkg/common"
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

var (
	versionedHandlers    = make(map[string]http.Handler)
	versionInitFunctions = make(map[string]func())
)

// RouterInit initializes the router and sets up version-specific routers dynamically.
// Returns an http.Handler.

func RouterInit() http.Handler {
	r := mux.NewRouter()
	r.Use(apigate.LogMiddleware(versionedHandlers)) // Use the version middleware

	// Initialize version-specific routers dynamically
	for _, initFunc := range versionInitFunctions {
		initFunc()
	}

	for version, handler := range versionedHandlers {
		lPrefixUrl := common.BasePattern + "/"
		if version != "Default" {
			lPrefixUrl += version + "/"
		}
		r.PathPrefix(lPrefixUrl).Handler(handler)
	}

	return r
}

// AddRouter assigns the version handler to the specified version.
// versionName: the name of the version
// versionHandler: the handler for the specified version
func AddRouter(versionName string, versionHandler http.Handler) {
	versionedHandlers[versionName] = versionHandler
}

// AddVersion assigns the initialization function to the specified version.
// versionName: the name of the version
// initFunc: the initialization function for the version
func AddVersion(versionName string, initFunc func()) {
	versionInitFunctions[versionName] = initFunc
}

// DefaultRedirect writes the default method verify.
func DefaultRedirect(w http.ResponseWriter, r *http.Request) {

	(w).Header().Set("Access-Control-Allow-Origin", "*")
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", " Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	log.Println("DefaultRedirect(+) " + r.Method)

	htmlString := `<!DOCTYPE html>
        <html lang="en">

        <head>
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
			<meta http-equiv="refresh" content="0; url=https://flattrade.in" />
            <link rel="canonical" href="https://flattrade.in" />
        </head>

        <body>
        </body>
        </html>`

	fmt.Fprint(w, htmlString)
	w.WriteHeader(200)
	log.Println("DefaultRedirect(-)")

}
