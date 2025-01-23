package tomlconfig

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"

	"github.com/BurntSushi/toml"
)

var GtomlConfigLoader *TomlConfigLoader

func Init() {
	log.Println("tomlconfig.Init (+)")
	var lErr error
	GtomlConfigLoader, lErr = NewConfigLoader()
	if lErr != nil {
		log.Println("TCI01 " + lErr.Error())
	}
	// log.Println("GtomlConfigLoader", GtomlConfigLoader)
	log.Println("tomlconfig.Init (-)")
}

// TomlConfigLoader loads configuration files and provides methods to access values
type TomlConfigLoader struct {
	TomlConfigMap map[string]interface{}
}

// NewConfigLoader creates a new instance of ConfigLoader and loads configuration files
func NewConfigLoader() (*TomlConfigLoader, error) {
	log.Println("tomlconfig.NewConfigLoader (+)")

	TomlDirectory := []string{"./toml", "../commonconfig/", "../"}

	lConfidLoader := &TomlConfigLoader{
		TomlConfigMap: make(map[string]interface{}),
	}
	for _, lDirect := range TomlDirectory {

		// Read all TOML files in the directory
		lFileInfos, lErr := ioutil.ReadDir(lDirect)
		if lErr != nil {
			log.Println("TCNCL01 ", lErr.Error())
			return nil, lErr
		}
		// log.Println("lFileInfos ---->", lFileInfos)

		// Iterate over each file
		for _, lFileInfo := range lFileInfos {

			// log.Println("lFileInfo ---->", lFileInfo)
			// Skip directories
			if lFileInfo.IsDir() {
				continue
			}

			// Check if the file has a .toml extension
			if filepath.Ext(lFileInfo.Name()) != ".toml" {
				continue
			}

			// Construct the file path
			lFilePath := filepath.Join(lDirect, lFileInfo.Name())

			// log.Println("lFilePath ---->", lFilePath)

			// Read the lFile
			lFile, lErr := os.Open(lFilePath)
			if lErr != nil {
				log.Println("TCNCL02 ", lErr.Error())
				continue
			}
			defer lFile.Close()

			// Decode the TOML data into a map
			var lTempConfigMap map[string]interface{}
			lDecoder := toml.NewDecoder(lFile)
			if _, lErr := lDecoder.Decode(&lTempConfigMap); lErr != nil {
				log.Println("TCNCL03 ", lErr.Error())
				continue
			}

			// Store the decoded map with the lFilename (without extension) as the key
			lFilename := fileBaseNameWithoutExtension(lFileInfo.Name())
			lConfidLoader.TomlConfigMap[lFilename] = lTempConfigMap
		}
	}
	// log.Println("lConfidLoader ---->", lConfidLoader)

	log.Println("tomlconfig.NewConfigLoader (-)")
	return lConfidLoader, nil
}

// GetValueString returns the value for the given filename and keyname
func (cl *TomlConfigLoader) GetValueString(pFilename, pKeyname string) string {
	// log.Println("tomlconfig.GetValueString (+)")

	// log.Println("pFilename ---->", pFilename)
	// log.Println("pKeyname ---->", pKeyname)

	lConfig, lOk := cl.TomlConfigMap[pFilename]
	if !lOk {
		log.Println("TCGVS01 " + pFilename + " toml file not found")
		return ""
	}
	// log.Println("config ---->", lConfig)
	lValue, lOk := lConfig.(map[string]interface{})[pKeyname]
	if !lOk {
		log.Println("TCGVS02 " + pKeyname + " toml value not found")
		return ""
	}

	// log.Println("value ---->", lValue)
	// log.Println("tomlconfig.GetValueString (-)")
	return fmt.Sprintf("%v", lValue)
}

// GetValue returns the value for the given filename and keyname
func (cl *TomlConfigLoader) GetValueWithErr(pFilename, pKeyname string) (interface{}, error) {
	log.Println("tomlconfig.GetValueWithErr (+)")

	// log.Println("pFilename ---->", pFilename)
	// log.Println("pKeyname ---->", pKeyname)

	lConfig, lOk := cl.TomlConfigMap[pFilename]
	if !lOk {
		log.Println("TCGVWE01 Inside Not OK")
		return nil, fmt.Errorf("file %s not found", pFilename)
	}

	// log.Println("config ---->", lConfig)
	lValue, lOk := lConfig.(map[string]interface{})[pKeyname]
	if !lOk {
		log.Println("TCGVWE02 Inside Not OK")
		return nil, fmt.Errorf("key %s not found in file %s", pKeyname, pFilename)
	}

	// log.Println("value ---->", lValue)
	log.Println("tomlconfig.GetValueWithErr (-)")
	return lValue, nil
}

// fileBaseNameWithoutExtension returns the base name of a file without the extension
func fileBaseNameWithoutExtension(fileName string) string {
	// log.Println("tomlconfig.fileBaseNameWithoutExtension (+)")
	lValue := fileName[:len(fileName)-len(filepath.Ext(fileName))]
	// log.Println("lValue ---->", lValue)
	// log.Println("tomlconfig.fileBaseNameWithoutExtension (-)")
	return lValue
}
func GetTomlValFrm2DArr(pTomlVariableData interface{}, pReference string) (string, string, error) {
	log.Println("tomlconfig.GetTomlValFrm2DArr (+)")

	// log.Println("pTomlVariableData ---->", pTomlVariableData)
	// log.Println("pReference ---->", pReference)

	lData, lOk := pTomlVariableData.([]interface{})
	if !lOk {
		log.Println("TCGVWE02 Inside Not OK")
		return "", "", fmt.Errorf("error: '%s' key has unexpected type", pTomlVariableData)
	}
	var lCode, Description string
	var lKeyOk, valueOk bool

	for _, lEntry := range lData {
		lEntryArr, lOk := lEntry.([]interface{})
		if !lOk || len(lEntryArr) != 2 {
			log.Println("TCGVWE02 Inside Not OK")
			continue
		}
		lCode, lKeyOk = lEntryArr[0].(string)
		Description, valueOk = lEntryArr[1].(string)
		// log.Println("lCode ---->", lCode)
		// log.Println("Description ---->", Description)
		if pReference == lCode {
			// log.Println("lCode ---->", lCode)
			// log.Println("Description ---->", Description)
			if lKeyOk && valueOk {
				return lCode, Description, nil
			}
		}
	}
	log.Println("tomlconfig.GetTomlValFrm2DArr (+)")
	return "", "", nil
}
