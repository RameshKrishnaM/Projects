package file

import (
	"encoding/base64"
	"fcs23pkg/common"
	"fcs23pkg/ftdb"
	"fcs23pkg/tomlconfig"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"net/url"
	"os"
	"path/filepath"

	_ "github.com/go-sql-driver/mysql"
)

//-----------------------------------------------------
// function exposed as api to get pdf files
// stored in file server
// This method return the file data in json format
//-----------------------------------------------------
// func GetFileAsJson(w http.ResponseWriter, r *http.Request) {
// 	(w).Header().Set("Access-Control-Allow-Origin", common.WallAllowOrigin)
// 	(w).Header().Set("Access-Control-Allow-Credentials", "true")
// 	(w).Header().Set("Access-Control-Allow-Methods", "PUT, OPTIONS")
// 	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

// 	w.WriteHeader(200)
// 	log.Println("GetFileAsJson(+) " + r.Method)
// 	bodyMsg, _ := ioutil.ReadAll(r.Body)

// 	switch r.Method {
// 	case "PUT":
// 		var pdfData model.PdfDataStruct
// 		//convert the input json into a structure variable
// 		err := json.Unmarshal(bodyMsg, &pdfData)
// 		if err != nil {
// 			common.LogError("file.GetFileAsJson", "(FGFJ01)", err.Error())
// 			pdfData.Status = common.ErrorCode
// 			pdfData.ErrMsg = "Unable to Unmarshal request " + err.Error()
// 		} else {
// 			//open a db connection
// 			db, err := ftdb.LocalDbConnect(ftdb.MariaEKYCPRD)
// 			//if any error when opening db connection
// 			if err != nil {
// 				common.LogError("file.GetFileAsJson", "(FGFJ01)", err.Error())
// 				pdfData.Status = common.ErrorCode
// 				pdfData.ErrMsg = err.Error()
// 			} else {
// 				defer db.Close()
// 				//get the physical path of the file
// 				//for the given doc id
// 				pdfPath, _, err := GetFilePath(pdfData.DocId)
// 				if err != nil {
// 					common.LogError("file.GetFileAsJson", "(FGFJ01)", err.Error())
// 					pdfData.Status = common.ErrorCode
// 					pdfData.ErrMsg = err.Error()
// 				} else {
// 					//if the file path found
// 					if pdfPath != "" {
// 						//read the file data in base64 format
// 						//from the physical path
// 						pdfData.PdfFile, err = ReadFileAsBase64FromPath(pdfPath)
// 						if err != nil {
// 							common.LogError("file.GetFileAsJson", "(FGFJ01)", err.Error())
// 							pdfData.Status = common.ErrorCode
// 							pdfData.ErrMsg = err.Error()
// 						} else {
// 							pdfData.Status = common.SuccessCode
// 							log.Println("pdfdata.Status", pdfData.PdfFile)
// 						}
// 					} else {
// 						pdfData.Status = common.ErrorCode
// 						pdfData.ErrMsg = "File path is undefined"
// 					}

// 				}
// 			}
// 		}

// 		log.Println(pdfData.PdfFile)
// 		//convert the struct variable data into a json string
// 		//and return it to the api caller
// 		data, err := json.Marshal(pdfData)
// 		if err != nil {
// 			fmt.Fprintf(w, "Error taking data"+err.Error())
// 		} else {
// 			fmt.Fprintf(w, string(data))
// 		}
// 	}
// 	log.Println("GetFileAsJson(-)")
// }

//-----------------------------------------------------
// function returns the actual physical path of the
// file for the given doc id
//-----------------------------------------------------
func GetFilePath(DocId string) (string, string, error) {
	log.Println("GetFilePath+")
	log.Println(DocId)
	var filePath, fileType string

	sqlString := `select FilePath,FileType from document_attachment_details dad 
	 where id = ?`
	rows, err := ftdb.MariaEKYCPRD_GDB.Query(sqlString, DocId)
	if err != nil {
		common.LogError("file.GetFilePath", "(FGFP02)", err.Error())
		return filePath, fileType, err
	} else {
		defer rows.Close()
		for rows.Next() {
			err := rows.Scan(&filePath, &fileType)
			if err != nil {
				common.LogError("file.GetFilePath", "(FGFP03)", err.Error())
				return filePath, fileType, err
			}
		}
	}

	//filePath = `D:\test.pdf.pdf`
	log.Println(filePath)
	log.Println("GetFilePath-")
	return filePath, fileType, nil
}

//-----------------------------------------------------
// function fetches the file data from the physical
// path and return the raw file data
//-----------------------------------------------------
func ReadRawFileFromPath(filePath string) ([]byte, error) {
	log.Println("ReadRawFileFromPath+")
	log.Println("filePathfilePath", filePath)
	//Read file from the physical path
	dat, err := os.ReadFile(filePath)
	if err != nil {
		common.LogError("file.ReadRawFileFromPath", "(FRFF01)", err.Error())
		return dat, err
	}
	log.Println("ReadRawFileFromPath-")
	return dat, nil
}

//-----------------------------------------------------
// function fetches the file data from the physical
// path and return the file data in base64 format
//-----------------------------------------------------
func ReadFileAsBase64FromPath(filePath string) (string, error) {
	log.Println("ReadFileAsBase64FromPath+")
	var encryptedFile string
	dat, err := ReadRawFileFromPath(filePath)
	if err != nil {
		common.LogError("file.ReadFileAsBase64FromPath", "(FRBF01)", err.Error())
		return encryptedFile, err
	} else {
		//convert the raw file data into a base64 format data
		encryptedFile = base64.StdEncoding.EncodeToString(dat)
	}
	log.Println("ReadFileAsBase64FromPath-")
	return encryptedFile, nil
}

//-----------------------------------------------------
// function exposed as api to  fetch
// the file data from the physical
// path and return the file data as it is
//-----------------------------------------------------
func FetchRawFile(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", common.EKYCAllowedOrigin)
	(w).Header().Set("Access-Control-Allow-Credentials", "true")
	(w).Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	w.WriteHeader(200)
	log.Println("FetchRawFile(+) " + r.Method)
	switch r.Method {
	case "GET":
		var docId string
		var file []byte
		var filePath, fileType string
		var err error
		//parse the query paraemters sent in the api end point
		fullpath := r.URL.Path + "?" + r.URL.RawQuery
		log.Println(fullpath)
		u, err := url.Parse(fullpath)
		if err != nil {
			common.LogError("file.FetchRawFile", "(FFRF01)", err.Error())
		} else {
			//get parameter values
			q := u.Query()
			//if id query parameter value is passed
			if q.Get("id") != "undefined" && q.Get("id") != "" {
				docId = q.Get("id")

				//get the physical path of the document
				filePath, fileType, err = GetFilePath(docId)
				log.Println("pdfPathpdfPath", filePath)
				if err != nil {
					common.LogError("file.FetchRawFile", "(FFRF03)", err.Error())
				} else {
					//read the raw data of the file
					file, err = ReadRawFileFromPath(filePath)
					if err != nil {
						common.LogError("file.FetchRawFile", "(FFRF04)", err.Error())
					}
				}

			}
		}
		log.Println(file)
		//w.Header().Set("Content-Type", "application/pdf")
		w.Header().Set("Content-Type", fileType)
		w.Write(file)

		log.Println("w.Header()", w.Header())
		log.Println("FetchRawFile(-)")
	}
}

func FileStorage(f multipart.File, h *multipart.FileHeader) (*FileDataType, error) {
	log.Println("FileStorage+")

	var fileData FileDataType

	// path := "E:\\Kamatchirajan\\go\\learning\\DocumentsUploads"

	path := tomlconfig.GtomlConfigLoader.GetValueString("fileconfig", "Path")
	err := os.MkdirAll(path, os.ModePerm)
	if err != nil {
		common.LogError("file.FileStorage", "(FFS01)", err.Error())
		return nil, err
	} else {
		fullPath := path + "\\" + common.GetFileName_UUID_String() + filepath.Ext(h.Filename)

		file, err := os.OpenFile(fullPath, os.O_WRONLY|os.O_CREATE, os.ModePerm)
		if err != nil {
			common.LogError("file.FileStorage", "(FFS02)", err.Error())
			return nil, err
		} else {
			defer file.Close()

			// Copy the file to the destination path

			_, err = io.Copy(file, f)
			if err != nil {
				common.LogError("file.FileStorage", "(FFS03)", err.Error())
				return nil, err
			} else {
				fileData = FileDataType{DocId: "1", ActualfileName: h.Filename, FullFilePath: fullPath}

			}

		}

	}
	//Store the file path in db
	//func for db operations
	// return fullPath, nil
	log.Println("FileStorage-")
	return &fileData, nil

}
