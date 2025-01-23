import 'dart:io';

import 'package:ekyc/Custom%20Widgets/custom_form_field.dart';
import 'package:ekyc/Custom%20Widgets/custom_radio_tile.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackbar.dart';
import 'package:ekyc/Service/validate_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../API call/api_call.dart';
import '../Custom Widgets/custom_drop_down.dart';
import '../Custom Widgets/custom_upload.dart';
import '../Custom Widgets/stepwidget.dart';
import '../Custom%20Widgets/file_upload_bottomsheet.dart';
import '../Nodifier/nodifierclass.dart';
import '../Route/route.dart' as route;
import '../Screens/signup.dart';

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
  }

  TextEditingController incomeproofController = TextEditingController(text: "");
  FormValidateNodifier formValidateNodifierIncomProof = FormValidateNodifier(
    {'Income Proof Type': false},
  );
  bool buttonIsEnable = false;
  String? selectedProofType;
  String proofCode = "";
  String aggregatorFlag = "";

  List incomeProofTypeOptions = [];
  List incomeProofTypes = [];
  List? fileUploadDetails;
  String oldProofCode = "";
  String oldAadhaarNo = "";
  bool aadhaarVisible = false;
  ScrollController scrollController = ScrollController();
  TextEditingController aadhaar = TextEditingController();
  bool countinueButtonIsTriggered = false;
  bool routerflag = false;
  String bankProofFlag = "";
  final _formKey = GlobalKey<FormState>();
  var img;

  /* 
  Purpose: This method is used to fetch the drop Down values from the api.
  */

  fetchDropdownValues() async {
    loadingAlertBox(context);
    var dropDownResponse =
        await getDropDownValues(context: context, code: "IncomeProof");
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

  /* 
  Purpose: This method is used to fetch the files which are already present from the api.
  */

  fetchFileId() async {
    var response = await fetchFileIdAPI(context: context);
    if (response != null) {
      proofCode = response["proofCode"] ?? "";
      routerflag = response['routerflag'] ?? false;
      oldProofCode = response["prooftype"];
      oldAadhaarNo = response["aadhaarNo"] ?? "";
      aadhaar.text = response["aadhaarNo"] ?? "";
      oldCashOnlyFlag = response["cashOnlyFlag"] == ""
          ? "N"
          : response["cashOnlyFlag"] ?? "N";
      aggregatorFlag = response["aggregatorFlag"] ?? "";
      bankProofFlag = response["bankProofFlag"] ?? "";
      aadhaarVisible = response["aadhaarFlag"] == "Y" ? true : false;
      if (response["idarr"] != null && response["idarr"].isNotEmpty) {
        incomeproofController.text = response["prooftype"] == null ||
                response["prooftype"].toString().isEmpty
            ? ""
            : incomeProofTypes.firstWhere((element) =>
                element["code"] == response["prooftype"])["description"];
        selectedProofType = incomeproofController.text;
        fileUploadDetails = response["idarr"];
        newCashOnlyFlag = response["cashOnlyFlag"] == ""
            ? "N"
            : response["cashOnlyFlag"] ?? "N";
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

  /* 
  Purpose: This method is used to upload the Files to the DB.
  */

  uploadFile() async {
    String? incomeProofCode = incomeproofController.text.isEmpty
        ? aggregatorFlag != "N"
            ? ""
            : null
        : incomeProofTypes.firstWhere((element) =>
            element["description"] == incomeproofController.text)["code"];
    Map fileUploadRec = {
      "aadhaarNo": aadhaar.text,
      "cashOnlyFlag": newCashOnlyFlag,
      "aadhaarFlag": aadhaarVisible ? "Y" : "N",
      "prooftype": incomeProofCode ?? "",
      "bankProof": "",
      "incomeProof": "",
      "signature": "",
      "panProof": ""
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
      newFileDetails.remove("fileType");

      return newFileDetails;
    }).toList();

    loadingAlertBox(context);

    var response = files.isNotEmpty ||
            incomeProofCode != oldProofCode ||
            oldAadhaarNo != aadhaar.text ||
            oldCashOnlyFlag != newCashOnlyFlag ||
            routerflag
        ? await fileUploadPostAPI(context: context, json: fileUploadRec)
        : "";
    response != null
        ? getNextRoute(context)
        : mounted
            ? Navigator.pop(context)
            : null;
  }

  /* 
  Purpose: This method is used to get the next route name from the api.
  */

  getNextRoute(context) async {
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

  /* 
  Purpose: This method is used to enable the continue button only the required fields are filled
  */

  checkButtonEnable() {
    buttonIsEnable = (aadhaar.text.length == 4 || !aadhaarVisible) &&
        (fileUploadDetails![0]["id"].toString().isNotEmpty ||
            fileUploadDetails![0]["flag"] != "Y" ||
            bankProofFlag == "N") &&
        ((((fileUploadDetails![1]["id"].toString().isNotEmpty) &&
                    incomeproofController.text.isNotEmpty) ||
                fileUploadDetails![1]["flag"] != "Y") ||
            newCashOnlyFlag == "Y" ||
            aggregatorFlag != "N") &&
        (fileUploadDetails![2]["id"].toString().isNotEmpty ||
            fileUploadDetails![2]["flag"] != "Y") &&
        (fileUploadDetails![3]["id"].toString().isNotEmpty ||
            fileUploadDetails![3]["flag"] != "Y");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
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
        buttonIsEnable ? uploadFile() : null;
      },
      children: [
        Column(
          children: fileUploadDetails == null || fileUploadDetails!.isEmpty
              ? []
              : [
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
                    visible: fileUploadDetails![0]["flag"] == "Y" &&
                        bankProofFlag == "Y",
                    child: CustomUpload(
                      showError: countinueButtonIsTriggered &&
                          !(fileUploadDetails![0]["file"] != null ||
                              fileUploadDetails![0]["id"]
                                  .toString()
                                  .isNotEmpty) &&
                          bankProofFlag == "Y",
                      title:
                          'Latest Statement/Cancelled copy of cheque/ Passbook front page',
                      subTitle:
                          'Copy of Statement/ Cancelled cheque/ Passbook front page which has your Name, Full bank account number (unmasked) and IFSC code ',
                      fileName: fileUploadDetails![0]["doctype"],
                      file: fileUploadDetails![0]["file"] ??
                          fileUploadDetails![0]["id"],
                      onTap: () => pickFileBottomSheet(
                          context,
                          (path, docId) => pickFile(context, 0, path, docId),
                          "ProofUpload",
                          fileUploadDetails![0]["doctype"],
                          proofType: proofCode),
                    ),
                  ),
                  SizedBox(
                    height: fileUploadDetails![1]["flag"] == "Y" &&
                            aggregatorFlag == "N"
                        ? 15.0
                        : 0,
                  ),
                  Visibility(
                    visible: fileUploadDetails![1]["flag"] == "Y" &&
                        aggregatorFlag == "N",
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
                                          .isNotEmpty) &&
                                  aggregatorFlag == "N",
                              title: 'Income Proof',
                              subTitle:
                                  'Income proof is required for F&O,Currency and MCX trading segments',
                              fileName: fileUploadDetails![1]["doctype"],
                              file: fileUploadDetails![1]["file"] ??
                                  fileUploadDetails![1]["id"],
                              dropDown: CustomDropDown(
                                hint: "Income Proof Type",
                                showError: countinueButtonIsTriggered &&
                                    incomeproofController.text.isEmpty &&
                                    aggregatorFlag == "N",
                                textSizeSmall: true,
                                isIcon: true,
                                label: 'Income Proof Type',
                                controller: incomeproofController,
                                values: incomeProofTypeOptions,
                                formValidateNodifier:
                                    formValidateNodifierIncomProof,
                                onChange: (value) {
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

                                return pickFileBottomSheet(
                                    context,
                                    (path, docId) =>
                                        pickFile(context, 1, path, docId),
                                    "ProofUpload",
                                    fileUploadDetails![1]["doctype"],
                                    proofType: proofCode);
                              },
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
                      fileName: fileUploadDetails![3]["doctype"],
                      file: fileUploadDetails![3]["file"] ??
                          fileUploadDetails![3]["id"],
                      onTap: () => pickFileBottomSheet(
                          context,
                          (path, docId) => pickFile(context, 3, path, docId),
                          "ProofUpload",
                          fileUploadDetails![3]["doctype"],
                          proofType: proofCode),
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

  /* 
  Purpose: This method is used to pick the file.
  */

  pickFile(BuildContext context, int index, path, docId) async {
    File file = File(path!);
    fileUploadDetails![index]["file"] = file;
    fileUploadDetails![index]["id"] = docId;
    fileUploadDetails![index]["uploadflag"] = "Y";

    checkButtonEnable();
  }
}
