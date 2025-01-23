import 'dart:io';
import 'package:ekyc/Custom%20Widgets/custom_form_field.dart';
import 'package:ekyc/Custom%20Widgets/custom_radio_button.dart';
import 'package:ekyc/Custom%20Widgets/custom_radio_tile.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackBar.dart';
import 'package:ekyc/Service/validate_func.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../Custom%20Widgets/file_upload_bottomsheet.dart';
import '../Screens/signup.dart';
import 'package:flutter/material.dart';

import '../API call/api_call.dart';
import '../Cookies/cookies.dart';
import '../Custom Widgets/StepWidget.dart';
import '../Custom Widgets/custom_button.dart';
import '../Custom Widgets/custom_drop_down.dart';
import '../Custom Widgets/custom_upload.dart';
import '../Nodifier/nodifierCLass.dart';
import '../Route/route.dart' as route;

class FileUpload extends StatefulWidget {
  const FileUpload({super.key});

  @override
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDropdownValues();
    });
    // frtchImg();
  }

  // Future<Uint8List> frtchImg() async {
  //   var response = await fetchImg(context);
  //   return response;
  //   // if (response != null) {
  //   //   return response;
  //   //   // img = response.bodyBytes;
  //   //   // setState(() {});
  //   // } else {
  //   //   throw Exception('Failed to load image');
  //   // }
  // }

  TextEditingController incomeproofController = TextEditingController(text: "");
  FormValidateNodifier formValidateNodifierIncomProof = FormValidateNodifier(
    {'Income Proof Type': false},
  );
  bool buttonIsEnable = false;
  String? selectedProofType;
  String proofCode = "";

  List incomeProofTypeOptions = [];
  // File?
  List incomeProofTypes = [];
  List? fileUploadDetails;
  String oldProofCode = "";
  String oldAadhaarNo = "";
  bool aadhaarVisible = false;
  ScrollController scrollController = ScrollController();
  TextEditingController aadhaar = TextEditingController();
  bool countinueButtonIsTriggered = false;
  bool routerflag = false;
  final _formKey = GlobalKey<FormState>();
  var img;
  fetchDropdownValues() async {
    loadingAlertBox(context);
    var dropDownResponse =
        await getDropDownValues(context: context, code: "IncomeProof");
    print("dropdownResponse===================$dropDownResponse");
    if (dropDownResponse != null) {
      incomeProofTypes = dropDownResponse['lookupvaluearr'];

      incomeProofTypeOptions =
          incomeProofTypes.map((element) => element['description']).toList();
      fetchFileId();
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  fetchFileId() async {
    var response = await fetchFileIdAPI(context: context);
    print(response);
    if (response != null) {
      proofCode = response["proofCode"] ?? "";
      routerflag = response['routerflag'] ?? false;
      oldProofCode = response["prooftype"];
      oldAadhaarNo = response["aadhaarNo"] ?? "";
      aadhaar.text = response["aadhaarNo"] ?? "";
      oldCashOnlyFlag = response["cashOnlyFlag"] == ""
          ? "N"
          : response["cashOnlyFlag"] ?? "N";
      aadhaarVisible = response["aadhaarFlag"] == "Y" ? true : false;
      if (response["idarr"] != null && response["idarr"].isNotEmpty) {
        incomeproofController.text = response["prooftype"] == null ||
                response["prooftype"].toString().isEmpty
            ? ""
            : incomeProofTypes.firstWhere((element) =>
                element["code"] == response["prooftype"])["description"];
        selectedProofType = incomeproofController.text;
        // List files = response["idarr"];
        fileUploadDetails = response["idarr"];
        newCashOnlyFlag = response["cashOnlyFlag"] == ""
            ? "N"
            : response["cashOnlyFlag"] ?? "N";
        print("fileupload ---------------$response");
        // fileUploadDetails![0]["fileType"] = fileUploadDetails![0]["id"] != ""
        //     ? await CustomHttpClient.getFileType(
        //         fileUploadDetails![0]["id"], context)
        //     : "";
        // fileUploadDetails![1]["fileType"] = fileUploadDetails![1]["id"] != ""
        //     ? await CustomHttpClient.getFileType(
        //         fileUploadDetails![1]["id"], context)
        //     : "";
        // fileUploadDetails![2]["fileType"] = fileUploadDetails![2]["id"] != ""
        //     ? await CustomHttpClient.getFileType(
        //         fileUploadDetails![2]["id"], context)
        //     : "";
        // fileUploadDetails![3]["fileType"] = fileUploadDetails![3]["id"] != ""
        //     ? await CustomHttpClient.getFileType(
        //         fileUploadDetails![3]["id"], context)
        //     : "";
        // fileUploadDetails![1]["flag"] = "Y";
        if (mounted) {
          setState(() {});
        }
        checkButtonEnable();
      }
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  uploadFile() async {
    String? incomeProofCode = incomeproofController.text.isEmpty
        ? null
        : incomeProofTypes.firstWhere((element) =>
            element["description"] == incomeproofController.text)["code"];
    Map fileUploadRec = {
      "aadhaarNo": aadhaar.text,
      "cashOnlyFlag": newCashOnlyFlag,
      "aadhaarFlag": aadhaarVisible ? "Y" : "N",
      "prooftype": incomeProofCode ?? "",
      "bankProof": "12345",
      "incomeProof": "12234",
      "signature": "45678",
      "panProof": "78978"
    };
    Map files = {};

    List l = fileUploadDetails!.map((fileDetails) {
      Map newFileDetails = {...fileDetails};
      if (newFileDetails["file"] != null) {
        files[newFileDetails["doctype"]] = newFileDetails["file"];
      }
      if (newFileDetails["doctype"] == "Bank_proof") {
        fileUploadRec["bankProof"] = newFileDetails["id"] ?? "";
      } else if (newFileDetails["doctype"] == "Income_proof") {
        fileUploadRec["incomeProof"] = newFileDetails["id"] ?? "";
      } else if (newFileDetails["doctype"] == "Signature") {
        fileUploadRec["signature"] = newFileDetails["id"] ?? "";
      } else if (newFileDetails["doctype"] == "Pan_proof") {
        fileUploadRec["panProof"] = newFileDetails["id"] ?? "";
      }
      newFileDetails["file"] = null;
      // newFileDetails.remove("file");
      newFileDetails.remove("fileType");

      return newFileDetails;
    }).toList();

    // print(files);
    loadingAlertBox(context);

    var response = files.isNotEmpty ||
            incomeProofCode != oldProofCode ||
            oldAadhaarNo != aadhaar.text ||
            oldCashOnlyFlag != newCashOnlyFlag ||
            routerflag
        ? await fileUploadPostAPI(context: context, json: fileUploadRec)
        // await fileUploadAPI(
        //     context: context,
        //     headerMap: {
        //       "prooftype": incomeProofCode ?? "",
        //       "aadhaarFlag": aadhaarVisible ? "Y" : "N",
        //       "aadhaarNo": aadhaar.text,
        //       "idarr": l,
        //       "cashOnlyFlag": newCashOnlyFlag
        //     },
        //     files: files)
        : "";
    print("res------ $newCashOnlyFlag");
    response != null
        ? getNextRoute(context)
        : mounted
            ? Navigator.pop(context)
            : null;
    // loadingAlertBox(context);
    // // print(
    // //     "file ids ${fileId1!.isEmpty ? "a" : fileId1} ${fileId2!.isEmpty ? "a" : fileId2} ${fileId3!.isEmpty ? "a" : fileId3} ${fileId4!.isEmpty ? "a" : fileId4}");
    // // print("files $fileKey1 $fileKey2 $fileKey3 $fileKey4");
    // // print("File names $fileName1 $fileName2 $fileName3 $fileName4");
    // // print("${incomeproofController.text}");
    // List ids = [fileId1, fileId2, fileId3, fileId4];
    // List keys = [fileKey1, fileKey2, fileKey3, fileKey4];
    // Map fileStruct = {
    //   "id": ids,
    //   "key": keys,
    //   "prooftype": incomeProofTypes.firstWhere((element) =>
    //       element["description"] == incomeproofController.text)["code"]
    // };
    // List<File> files = [];

    // file1 != null ? files.add(file1 ?? File("")) : null;
    // file2 != null ? files.add(file2 ?? File("")) : null;
    // file3 != null ? files.add(file3 ?? File("")) : null;
    // file4 != null ? files.add(file4 ?? File("")) : null;
    // // print(files);
    // var response =
    //     await fileUpload(context: context, headerMap: fileStruct, files: files);
    // Navigator.pop(context);
    // if (response != null) {
    //   Navigator.pushNamed(context, route.review);
    // }
  }

  getNextRoute(context) async {
    //  response != null ? getNextRoute(context) : Navigator.pop(context);
    loadingAlertBox(context);
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.fileUpload],
      "routeraction": "Next"
    });
    if (mounted) {
      Navigator.pop(context);
    }

    if (response != null) {
      Navigator.pushNamed(context, response["endpoint"]);
    }
  }

  checkButtonEnable() {
    buttonIsEnable = (aadhaar.text.length == 4 || !aadhaarVisible) &&
        (
            // fileUploadDetails![0]["file"] != null ||
            fileUploadDetails![0]["id"].toString().isNotEmpty ||
                fileUploadDetails![0]["flag"] != "Y") &&
        ((((
                        // fileUploadDetails![1]["file"] != null ||
                        fileUploadDetails![1]["id"].toString().isNotEmpty) &&
                    incomeproofController.text.isNotEmpty) ||
                fileUploadDetails![1]["flag"] != "Y") ||
            newCashOnlyFlag == "Y") &&
        (
            // fileUploadDetails![2]["file"] != null ||
            fileUploadDetails![2]["id"].toString().isNotEmpty ||
                fileUploadDetails![2]["flag"] != "Y") &&
        (
            // fileUploadDetails![3]["file"] != null ||
            fileUploadDetails![3]["id"].toString().isNotEmpty ||
                fileUploadDetails![3]["flag"] != "Y");
    // buttonIsEnable = (file1 != null || flag1 != "Y") &&
    //     ((file2 != null && incomeproofController.text.isNotEmpty) ||
    //         flag2 != "Y") &&
    //     (file3 != null || flag3 != "Y") &&
    //     (file4 != null || flag4 != "Y");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  singlefileupload(int index) async {
    print("entered");
    Map fileDeatils = {...fileUploadDetails![index]};

    Map file = {};
    file[fileDeatils["doctype"]] = fileDeatils["file"];
    fileDeatils
      ..remove("FileType")
      ..["file"] = null;
    var res = await singleFileUploadAPI(
        context: context,
        headerMap: {
          "uploadfilearr": [fileDeatils]
        },
        files: file);
    print(res);
  }

  String newCashOnlyFlag = "N";
  String oldCashOnlyFlag = "N";

  @override
  Widget build(BuildContext context) {
    return StepWidget(
      endPoint: route.fileUpload,
      step: 5,
      title: 'Proof Upload',
      title1: 'Upload Documents',
      subTitle: 'For scan, a photo taken on your phone is sufficient',
      scrollController: scrollController,
      buttonFunc: //buttonIsEnable ? uploadFile : null,
          () {
        _formKey.currentState?.validate();
        if (!countinueButtonIsTriggered) {
          countinueButtonIsTriggered = true;
          setState(() {});
        }
        checkButtonEnable();
        print(buttonIsEnable);
        buttonIsEnable ? uploadFile() : null;
      },
      children: [
        Column(
          children: fileUploadDetails == null || fileUploadDetails!.isEmpty
              ? [
                  // ...getTitleANdSubTitleWidget(
                  //     'Upload Documents',
                  //     'For scan, a photo taken on your phone is sufficient',
                  //     context),
                ]
              : [
                  // ...getTitleANdSubTitleWidget(
                  //     'Upload Documents',
                  //     'For scan, a photo taken on your phone is sufficient',
                  //     context),
                  Form(
                    key: _formKey,
                    child: Visibility(
                      visible: aadhaarVisible,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...customFormField(
                              controller: aadhaar,
                              labelText: "Aadhaar Number",
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(4),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "XXXX - XXXX - ",
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color),
                                      ),
                                      const SizedBox(
                                        height: 4.0,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onChange: (value) => checkButtonEnable(),
                              validator: (value) =>
                                  validateName(value, "Aadhaar Number", 4)),
                          Text(
                              " Enter only the last 4 digits of the Aadaar number"),
                          const SizedBox(height: 20.0)
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: fileUploadDetails![0]["flag"] == "Y",
                    child: CustomUpload(
                      showError: countinueButtonIsTriggered &&
                          !(fileUploadDetails![0]["file"] != null ||
                              fileUploadDetails![0]["id"]
                                  .toString()
                                  .isNotEmpty),
                      title:
                          'Latest Statement/Cancelled copy of cheque/ Passbook front page',
                      subTitle:
                          'Copy of Statement/ Cancelled cheque/ Passbook front page which has your Name, Full bank account number (unmasked) and IFSC code ',
                      // fileType: fileUploadDetails![0]["fileType"] ?? "",
                      fileName: fileUploadDetails![0]["doctype"],
                      file: fileUploadDetails![0]["file"] ??
                          fileUploadDetails![0]["id"],
                      onTap: () => pickFileBottomSheet(
                          context,
                          (path, docId) => pickFile(context, 0, path, docId),
                          "ProofUpload",
                          fileUploadDetails![0]["doctype"],
                          proofType: proofCode),
                      ontap2: () => singlefileupload(0),
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Visibility(
                    visible: fileUploadDetails![1]["flag"] == "Y",
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.0,
                          color: const Color.fromRGBO(9, 101, 218, 1),
                        ),
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 15,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 15.0,
                          ),
                          Text(
                              " Don't have Income Proof for Derivatives? open only Cash Segment"),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: [
                              CustomRadioTile(
                                  label: "Yes",
                                  value: "Y",
                                  groupValue: newCashOnlyFlag,
                                  onChanged: (value) {
                                    setState(() {
                                      newCashOnlyFlag = value!;
                                    });
                                  }),
                              const SizedBox(
                                width: 10.0,
                              ),
                              CustomRadioTile(
                                  label: "No",
                                  value: "N",
                                  groupValue: newCashOnlyFlag,
                                  onChanged: (value) {
                                    setState(() {
                                      newCashOnlyFlag = value!;
                                    });
                                  })
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Visibility(
                            visible: newCashOnlyFlag == 'N',
                            child: CustomUpload(
                              showError: countinueButtonIsTriggered &&
                                  !(fileUploadDetails![1]["file"] != null ||
                                      fileUploadDetails![1]["id"]
                                          .toString()
                                          .isNotEmpty),
                              title: 'Income Proof',
                              subTitle:
                                  'Income proof is required for F&O,Currency and MCX trading segments',
                              // fileType: fileUploadDetails![1]["fileType"],
                              fileName: fileUploadDetails![1]["doctype"],
                              file: fileUploadDetails![1]["file"] ??
                                  fileUploadDetails![1]["id"],
                              dropDown: CustomDropDown(
                                hint: "Income Proof Type",
                                showError: countinueButtonIsTriggered &&
                                    incomeproofController.text.isEmpty,
                                // buttonSizeIsSmall: true,
                                textSizeSmall: true,
                                isIcon: true,
                                label: 'Income Proof Type',
                                controller: incomeproofController,
                                values: incomeProofTypeOptions,
                                formValidateNodifier:
                                    formValidateNodifierIncomProof,
                                onChange: (value) {
                                  // print("old $selectedProofType");
                                  // print("new $value");
                                  if (selectedProofType != value &&
                                      selectedProofType != null &&
                                      selectedProofType != "") {
                                    fileUploadDetails![1]["file"] = null;
                                    fileUploadDetails![1]["id"] = "";
                                  }
                                  proofCode = incomeProofTypes.firstWhere(
                                      (element) =>
                                          element["description"] ==
                                          value)["code"];
                                  checkButtonEnable();
                                  selectedProofType = value;
                                },
                              ),
                              onTap: () {
                                if (incomeproofController.text.isEmpty) {
                                  showSnackbar(
                                      context,
                                      "Please select Income proof type",
                                      Colors.red);
                                  return;
                                }
                                // proofCode = incomeProofTypes.firstWhere(
                                //     (element) =>
                                //         element["description"] ==
                                //         incomeproofController.text)["code"];

                                return pickFileBottomSheet(
                                    context,
                                    (path, docId) =>
                                        pickFile(context, 1, path, docId),
                                    "ProofUpload",
                                    fileUploadDetails![1]["doctype"],
                                    proofType: proofCode);
                              },
                              ontap2: () => singlefileupload(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Visibility(
                    visible: fileUploadDetails![2]["flag"] == "Y",
                    child: CustomUpload(
                      showError: countinueButtonIsTriggered &&
                          !(fileUploadDetails![2]["file"] != null ||
                              fileUploadDetails![2]["id"]
                                  .toString()
                                  .isNotEmpty),
                      title: 'Signature',
                      subTitle:
                          'Sign on a blank white paper with a pen (blue/black) is only accepted.',
                      // fileType: fileUploadDetails![2]["fileType"],
                      fileName: fileUploadDetails![2]["doctype"],
                      file: fileUploadDetails![2]["file"] ??
                          fileUploadDetails![2]["id"],
                      onTap: () => pickFileBottomSheet(
                          context,
                          (path, docId) => pickFile(context, 2, path, docId),
                          "ProofUpload",
                          fileUploadDetails![2]["doctype"],
                          noNeedPdf: true,
                          proofType: proofCode),
                      ontap2: () => singlefileupload(2),
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Visibility(
                    visible: fileUploadDetails![3]["flag"] == "Y",
                    child: CustomUpload(
                      showError: countinueButtonIsTriggered &&
                          !(fileUploadDetails![3]["file"] != null ||
                              fileUploadDetails![3]["id"]
                                  .toString()
                                  .isNotEmpty),
                      title: 'Copy of PAN',
                      subTitle: 'Upload a scan or photo copy of your PAN Card',
                      // fileType: fileUploadDetails![3]["fileType"],
                      fileName: fileUploadDetails![3]["doctype"],
                      file: fileUploadDetails![3]["file"] ??
                          fileUploadDetails![3]["id"],
                      onTap: () => pickFileBottomSheet(
                          context,
                          (path, docId) => pickFile(context, 3, path, docId),
                          "ProofUpload",
                          fileUploadDetails![3]["doctype"],
                          proofType: proofCode),
                      ontap2: () => singlefileupload(3),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                ],
        ),
      ],
    );
  }

  pickFile(BuildContext context, int index, path, docId) async {
    File file = File(path!);
    // List l = file.path.split("/");
    fileUploadDetails![index]["file"] = file;
    fileUploadDetails![index]["id"] = docId;
    fileUploadDetails![index]["uploadflag"] = "Y";
    // switch (position) {
    //   case 1:
    //     fileKey1 = "file0";
    //     fileId1 = "";
    //     fileName1 = l[l.length - 1];
    //     file1 = file;
    //     updatedFlag1 = "Y";
    //     break;
    //   case 2:
    //     fileKey2 = "file1";
    //     fileId2 = "";
    //     fileName2 = l[l.length - 1];
    //     file2 = file;
    //     updatedFlag2 = "Y";
    //     break;
    //   case 3:
    //     fileKey3 = "file2";
    //     fileId3 = "";
    //     fileName3 = l[l.length - 1];
    //     file3 = file;
    //     updatedFlag3 = "Y";
    //     break;
    //   case 4:
    //     fileKey4 = "file3";
    //     fileId4 = "";
    //     fileName4 = l[l.length - 1];
    //     file4 = file;
    //     updatedFlag4 = "Y";
    //     break;
    //   default:
    // }

    checkButtonEnable();
  }
}
