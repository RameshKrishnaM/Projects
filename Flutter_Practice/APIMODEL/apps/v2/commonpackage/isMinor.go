package commonpackage

import (
	"fcs23pkg/helpers"
	"fmt"
	"time"
)

func IsMinor(pDebug *helpers.HelperStruct, pPanDob string) (bool, error) {
	pDebug.Log(helpers.Statement, "isMinor (+)")

	var lIsMinor bool
	var lBirtDate time.Time
	var lErr error

	fmt.Println(pPanDob, "PanDob**")
	lFormats := []string{
			"02/01/2006",
			"02-01-2006",
	}
	for _, lFormat := range lFormats {
		lBirtDate, lErr = time.Parse(lFormat, pPanDob)
		if lErr == nil {
			break
		}
	}

	if lErr != nil {
		pDebug.Log(helpers.Elog, "IsMinor001 ", lErr.Error())
		return lIsMinor, lErr
	}
	lEighteenthBirthDay := lBirtDate.AddDate(18, 0, 0)
	lIsMinor = time.Now().Before(lEighteenthBirthDay)

	pDebug.Log(helpers.Statement, "isMinor (-)")
	return lIsMinor, nil
}
