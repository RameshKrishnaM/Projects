import 'dart:io';
import 'dart:typed_data';
import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/custom_button.dart';
import 'package:ekyc/Custom%20Widgets/custom_form_field.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackBar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:device_info_plus/device_info_plus.dart';

// String name = await SmsAutoFill().getAppSignature;
// List a = name.split(":");
// name1 = a[a.length - 1];

// void checkPermissions(source) async {
//   if (int.parse(version!) >= 13) {
//     if (await Permission.camera.request().isGranted
//         //awdfasd
//         &&
//         await Permission.photos.request().isGranted) {
//       PermissionStatus cameraStatus = await Permission.camera.status;
//       PermissionStatus phoneStatus = await Permission.photos.status;
//       print('Camera Permission Status: $cameraStatus');
//       print('Phone Permission Status: $phoneStatus');
//       captureImage(source);
//     } else {
//       // Permissions not granted, handle accordingly
//     }
//   } else {
//     if (await Permission.camera.request().isGranted
//             //&& await Permission.storage.request().isGranted
//             &&
//             await Permission.storage.request().isGranted
//         //afs
//         ) {
//       PermissionStatus cameraStatus = await Permission.camera.status;
//       PermissionStatus storageStatus = await Permission.storage.status;
//       print('Camera Permission Status: $cameraStatus');
//       print('Storage Permission Status: $storageStatus');
//       captureImage(source);
//     } else {
//       // Permissions not granted, handle accordingly
//     }
//   }
// }

pickFileBottomSheet(context, func, pageName, docType,
    {String proofType = "", bool noNeedPdf = false, int? pageCount}) {
  TextEditingController controller = TextEditingController();
  String? uploadFilepath = '';

  uploadFile(context, filePath) async {
    await Future.delayed(Duration(milliseconds: 300));
    loadingAlertBox(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    // await Future.delayed(Duration(seconds: 5));
    // print("uploadFilepath $filePath");
    String fileName = (filePath ?? "").split("/").last;
    Map headerMap = {
      "uploadfilearr": [
        {
          "doctype": docType,
          "haspassword": controller.text.isNotEmpty ? "Y" : "N",
          "password": controller.text,
          "prooftype": proofType,
          "filename": fileName
        }
      ],
      "PageName": pageName
    };
    print(headerMap);
    var response = await singleFileUploadAPI(
        context: context, headerMap: headerMap, files: [File(filePath ?? "")]);

    if (response != null) {
      var docIds = response["resparr"] ?? [];
      if (docIds is List && docIds.isNotEmpty) {
        // print("con ${headerMap["uploadfilearr"][0]["haspassword"]}");
        if (headerMap["uploadfilearr"][0]["haspassword"] == "Y") {
          // print("workifkjhfc ${response["resparr"][0]["docid"]}");
          // Directory dir = await getApplicationDocumentsDirectory();
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
    // TextEditingController controller = TextEditingController();
    var _formKey = GlobalKey<FormState>();
    showDialog(
      context: mainContext,
      builder: (context) {
        return AlertDialog(content: StatefulBuilder(
          builder: (context, setState) {
            return Form(
              key: _formKey,
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
                    // Center(
                    //   child: Text(
                    //     "Upload file is Protected",
                    //     textAlign: TextAlign.center,
                    //     style: Theme.of(context).textTheme.displayMedium,
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
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
                              if (_formKey.currentState!.validate()) {
                                print("uploadFilepath $filePath");
                                // Navigator.pop(context);
                                uploadFile(mainContext, filePath);
                              }
                              // if (controller.text.trim().isNotEmpty) {
                              // } else {}
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
          // print(document.pagesCount);
        }
        // File f = File(path);
        // List filename = path.split(".").toList();
        // Uint8List l = f.readAsBytesSync();
        // File n = File("/storage/emulated/0/Download/DemoFileForImage.txt");
        // n.writeAsString(l.toString());
        ScaffoldMessenger.of(context).clearSnackBars();
        File file = File(path);
        int size = await file.length();
        if (size > (5 * 1024 * 1024)) {
          showSnackbar(context, "file size must be less then 5MB", Colors.red);
        } else {
          uploadFilepath = path;
          uploadFile(context, path);
        }
        Navigator.pop(context);
      }
    } catch (e) {
      // print(e.toString());
      Navigator.pop(context);
      // print(e.toString().contains("PdfRendererException"));
      if ((e.toString().contains("PdfRendererException") ||
          e.toString().contains("PlatformException") &&
              !e.toString().toLowerCase().contains("denied"))) {
        protectedDiaLog(context, path);
        return;
      }
      // String message = e.toString().contains("PdfRendererException") ||
      //         e.toString().contains("PlatformException")
      //     ? "PDF is protected please upload another file"
      //     :
      String message = "Some thing went wrong please upload another file";
      !e.toString().contains("denied")
          ? showSnackbar(context, message, Colors.red)
          : null;
    }
    // setState(() {});
  }

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(7.0), topRight: Radius.circular(7.0))),
    builder: (context) {
      return SizedBox(
        height: 110,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 10.0),
              InkWell(
                  onTap: () {
                    captureImage("camera");
                  },
                  child: const Column(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 40.0,
                      ),
                      Text(
                        'Camera',
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ],
                  )),
              const SizedBox(width: 10.0),
              // InkWell(
              //     onTap: () {
              //       captureImage("gallery");
              //     },
              //     child: const Column(
              //       children: [
              //         Icon(
              //           Icons.photo_outlined,
              //           size: 40.0,
              //         ),
              //         Text(
              //           'gallery',
              //           style: TextStyle(fontSize: 15.0),
              //         ),
              //       ],
              //     )),
              // const SizedBox(width: 10.0),
              InkWell(
                  onTap: () {
                    captureImage("files");
                  },
                  child: const Column(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 40.0,
                      ),
                      Text(
                        'files',
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      );
    },
  );
}
