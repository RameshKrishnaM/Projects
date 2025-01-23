import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/custom_button.dart';
import 'package:ekyc/Custom%20Widgets/custom_form_field.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackbar.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:permission_handler/permission_handler.dart';

pickFileBottomSheet(context, func, pageName, docType,
    {String proofType = "",
    bool noNeedPdf = false,
    int? pageCount,
    bool isGroupUpload = false,
    bool ssDocs = false,
    List<String>? pathList,
    isSkipSheet = false}) {
  TextEditingController controller = TextEditingController();
  String? uploadFilepath = '';

  uploadFile(context, filePath) async {
    List files = [];
    var fileName;
    await Future.delayed(Duration(milliseconds: 300));
    loadingAlertBox(context);
    ScaffoldMessenger.of(context).clearSnackBars();

    Map headerMap = {
      "uploadfilearr": [],
      "PageName": pageName,
      "mergefile": proofType == "403"
          ? {
              "merge": "Y",
              "prooftype": proofType,
              "filename": "Income_proof",
            }
          : {}
    };

    if (filePath is List) {
      fileName = [];
      for (int i = 0; i < filePath.length; i++) {
        var element = filePath[i];
        headerMap["uploadfilearr"].add({
          "doctype": "salary_slip${i + 1}",
          "haspassword": controller.text.isNotEmpty ? "Y" : "N",
          "password": controller.text,
          "prooftype": proofType,
        });
        String extension = ((element ?? "").split("/").last).split(".").last;
        if (extension.isEmpty ||
            extension == "" ||
            !(extension == "jpg" ||
                extension == "jpeg" ||
                extension == "png" ||
                extension == "pdf")) {
          showSnackbar(
              context, "Please Select the valid File Format", Colors.red);
          Navigator.pop(context);
          return;
        }
        fileName!.add((element ?? "").split("/").last);
        files.add(File(element ?? ""));
      }
    } else {
      fileName = (filePath ?? "").split("/").last;
      headerMap["uploadfilearr"].add({
        "doctype": docType,
        "haspassword": controller.text.isNotEmpty ? "Y" : "N",
        "password": controller.text,
        "prooftype": proofType,
      });
      String extension = ((filePath ?? "").split("/").last).split(".").last;
      if (extension.isEmpty ||
          extension == "" ||
          !(extension == "jpg" ||
              extension == "jpeg" ||
              extension == "png" ||
              extension == "pdf")) {
        showSnackbar(
            context, "Please Select the valid File Format", Colors.red);
        Navigator.pop(context);
        return;
      }
      files.add(File(filePath ?? ""));
    }

    var response = await singleFileUploadAPI(
        context: context, headerMap: headerMap, files: files);
    if (response != null) {
      var docIds = response["resparr"] ?? [];
      if (docIds is List && docIds.isNotEmpty) {
        if (headerMap["uploadfilearr"][0]["haspassword"] == "Y") {
          Directory dir = await getTemporaryDirectory();
          File f = File("${dir.path}/$fileName");
          var fileInBytes =
              await fetchFile(context: context, id: docIds[0]["docid"]);
          f.writeAsBytesSync(fileInBytes);
          filePath = f.path;
          Navigator.pop(context);
        }
        func(filePath, docIds[0]["docid"]);
      }
    }
    Navigator.pop(context);
  }

  protectedDiaLog(mainContext, filePath) {
    var formKey = GlobalKey<FormState>();
    showDialog(
      context: mainContext,
      builder: (context) {
        return AlertDialog(content: StatefulBuilder(
          builder: (context, setState) {
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 20.0),
                        Expanded(
                          child: Text("Your File is Password Protected",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ),
                        InkWell(
                          child: Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                          onTap: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Enter The Password To Unlock*",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(fontSize: 13.0),
                    ),
                    const SizedBox(height: 5),
                    CustomFormField(
                        controller: controller, labelText: 'Password'),
                    const SizedBox(height: 10),
                    Center(
                      child: SizedBox(
                        width: 100.0,
                        height: 40.0,
                        child: CustomButton(
                            isSmall: true,
                            buttonText: "Unlock",
                            color: Colors.green,
                            buttonFunc: () {
                              if (formKey.currentState!.validate()) {
                                uploadFile(mainContext, filePath);
                              }
                            }),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ));
      },
    ).then((value) {
      controller.text = '';
    });
  }

  Future<void> captureImage(source) async {
    String? path;
    try {
      switch (source) {
        case "camera":
          var image = await ImagePicker().pickImage(source: ImageSource.camera);
          image != null ? path = image.path : null;
          break;
        case "gallery":
          final androidinfo = await DeviceInfoPlugin().androidInfo;
          PermissionStatus status =
              Platform.isIOS || androidinfo.version.sdkInt > 30
                  ? await Permission.photos.request()
                  : await Permission.storage.request();
          if (status.isGranted) {
            var image =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            image != null ? path = image.path : null;
          }

          break;
        case "files":
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: noNeedPdf
                ? ['jpg', 'jpeg', 'png']
                : ['jpg', 'jpeg', 'png', 'pdf'],
            allowMultiple: false,
          );
          result != null ? path = result.files.single.path : null;
          break;
      }
      if (path != null) {
        if (path.endsWith(".pdf")) {
          var document = await PdfDocument.openFile(path);
          if (pageCount != null) {
            if (document.pagesCount > pageCount) {
              showSnackbar(context,
                  "page count must be less than ${pageCount + 1}", Colors.red);
              Navigator.pop(context);
              return;
            }
          }
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        File file = File(path);
        int size = await file.length();
        if (size > (5 * 1024 * 1024)) {
          showSnackbar(context, "file size must be less then 5MB", Colors.red);
        } else {
          uploadFilepath = path;
          if (ssDocs) {
            func(path, "SSDocs");
            if (isGroupUpload) {
              uploadFile(context, pathList);
            }
          } else {
            uploadFile(context, path);
          }
        }
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      if ((e.toString().contains("PdfRendererException") ||
          e.toString().contains("PlatformException") &&
              !e.toString().toLowerCase().contains("denied"))) {
        protectedDiaLog(context, path);
        return;
      }

      String message = "Some thing went wrong please upload another file";
      !e.toString().contains("denied")
          ? showSnackbar(context, message, Colors.red)
          : null;
    }
  }

  GestureDetector bottomSheetBtns(
      String iconName, String imgPath, captureName) {
    return GestureDetector(
        child: Column(
          children: [
            Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(imgPath), fit: BoxFit.contain)),
            ),
            Text(iconName)
          ],
        ),
        onTap: () => captureImage(captureName));
  }

  if (!isSkipSheet) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(
              bottom: 15.0, left: 20.0, right: 20.0, top: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20.0)),
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    bottomSheetBtns(
                        "Camera", "assets/images/google-camera.png", "camera"),
                    const SizedBox(
                      width: 30.0,
                    ),
                    bottomSheetBtns(
                        "Files", "assets/images/googleFile.png", "files"),
                    const SizedBox(width: 15.0),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  } else {
    uploadFile(context, pathList);
  }
}
