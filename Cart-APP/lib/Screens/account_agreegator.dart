import 'dart:async';
import 'dart:io';

import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/custom_button.dart';
import 'package:ekyc/Custom%20Widgets/custom_form_field.dart';
import 'package:ekyc/Custom%20Widgets/file_upload_bottomsheet.dart';
import 'package:ekyc/Custom%20Widgets/stepwidget.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/Service/validate_func.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Custom Widgets/custom_drop_down.dart';
import '../Custom Widgets/custom_snackbar.dart';
import '../Nodifier/nodifierclass.dart';
import '../Route/route.dart' as route;

class AccountAggregator extends StatefulWidget {
  final String mobileNumber;
  final String accountNumber;
  final String bankName;
  final String? url;
  final Map demantData;

  const AccountAggregator(
      {super.key,
      required this.mobileNumber,
      required this.accountNumber,
      required this.bankName,
      required this.demantData,
      this.url});

  @override
  State<AccountAggregator> createState() => _AccountAggregatorState();
}

class _AccountAggregatorState extends State<AccountAggregator> {
  int? selectedOption = 1;
  int? isMobileNumber = 1;
  int? grpValue = 1;

  List<String> path = [];
  String docId = "";
  int docCount = 0;
  String? clientMobileNumber;
  String? clientBankName;
  int reAttempt = 0;
  String consentHandle = "";
  String errorcode = "";

  List uploadedFiles = [];
  List<String> currentProof = [];
  TextEditingController mobileNumberController = TextEditingController();
  int isShowUploadOption = 1;
  final ScrollController _scrollController = ScrollController();
  TextEditingController fileController = TextEditingController();
  FormValidateNodifier formValidateNodifier =
      FormValidateNodifier({"Account Aggregator": false});

  String selectedProof = "";

  int checkCount = 0;

  // String? errMsg = "";
  GlobalKey _form = GlobalKey<FormState>();

  List<dynamic> proofList = [];

  getProofDetails() async {
    loadingAlertBox(context);

    var json = await getDropDownValues(context: context, code: "incomeProof");

    if (json != null) {
      proofList = json["lookupvaluearr"];
      if (mounted) {
        setState(() {});
      }
    }
    getAAId();
  }

  bool isSalarySlip(value) {
    for (var i in proofList) {
      if (i["description"] == value) {
        if (i["code"] == 403 || i["code"] == "403") {
          return true;
        }
      }
    }
    return false;
  }

  getAAId() async {
    var aggregatorStatus = await checkStatementFetch(context: context) ?? {};
    String aggregatorDocID = aggregatorStatus['docid'] ?? "";

    if (aggregatorDocID.isNotEmpty) {
      uploadedFiles =
          await fetchFile(context: context, id: aggregatorDocID, list: true);

      if (uploadedFiles.isNotEmpty) {
        currentProof.add("File Uploaded");
      }

      if (mounted) {
        Navigator.pop(context);
      }

      docId = aggregatorStatus['docid'];

      fileController.text = aggregatorStatus['prooftype'].toString().isNotEmpty
          ? proofList.firstWhere((element) =>
              element["code"] == aggregatorStatus['prooftype'])["description"]
          : "";

      if (fileController.text.isNotEmpty) {
        selectedOption = 2;
        isMobileNumber = 0;
      }

      selectedProof = fileController.text;
      setState(() {});
    } else {
      Navigator.pop(context);
    }
  }

  late FocusNode _focusNode;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getProofDetails();
    });
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    bool isBtnEnable = (isMobileNumber == 1 ||
            (isMobileNumber == 2 &&
                mobileNumberController.text.length == 10 &&
                int.parse(mobileNumberController.text[0]) > 5)) ||
        ((isSalarySlip(fileController.text) && currentProof.isNotEmpty) ||
            (currentProof.isNotEmpty && !(isSalarySlip(fileController.text))));

    return StepWidget(
        title: "Bank & Segments",
        title1: "Derivatives-Financial Proof",
        step: 4,
        subTitle:
            "Income proof is required for F&O,Currency and MCX trading segments ",
        scrollController: _scrollController,
        buttonFunc: isBtnEnable
            ? () => {
                  if (docId == "SSDocs")
                    {
                      pickFileBottomSheet(
                          context,
                          (path, id) => fileDetails(path, id),
                          "ProofUpload",
                          pathList: path,
                          isSkipSheet: true,
                          "Income_proof",
                          proofType: proofList.firstWhere(
                            (element) =>
                                element["description"] == fileController.text,
                          )['code'])
                    },
                  insertIncomeProof(),
                }
            : null,
        children: [
          Text(
            "Activating Derivatives",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
              "Need minimum 6 month bank statement / ITR Statement / Holding Statement for activating F&O segments"),
          const SizedBox(
            height: 20.0,
          ),
          GestureDetector(
            child: Container(
                width: screenSize.width,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedOption == 1
                          ? const Color(0xff0965DA)
                          : Colors.black,
                      style: BorderStyle.solid,
                      width: selectedOption == 1 ? 2.0 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8.0)),
                child: Stack(
                  children: [
                    Positioned(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6.0),
                        ),
                        child: Image(
                          image: AssetImage('assets/images/flash_b5.png'),
                          // image: AssetImage('assets/images/flash_p.png'),
                          height: 25,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 16.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customRadioBtn(
                                  selectedOption == 1 ? true : false),
                              const SizedBox(width: 8),
                              Text(
                                "Fetch Bank Statement with AA",
                                style: TextStyle(
                                    height: 0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 14.0),
                              )
                            ],
                          ),
                          AnimatedCrossFade(
                            duration: Duration(milliseconds: 300),
                            firstChild: const SizedBox(),
                            sizeCurve: Curves.ease,
                            secondChild: AnimatedOpacity(
                              opacity: selectedOption == 1 ? 1.0 : 0.0,
                              curve: Curves.linear,
                              duration: Duration(milliseconds: 300),
                              child: selectedOption == 1
                                  ? bankInfo(screenSize)
                                  : const SizedBox(),
                            ),
                            crossFadeState: selectedOption == 1
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                          )
                        ],
                      ),
                    ),
                  ],
                )),
            onTap: () {
              setState(() {
                selectedOption = 1;
                isShowUploadOption = 1;
                docId = "";
                path = [];
                uploadedFiles = [];
                currentProof = [];
                selectedProof = "";
                fileController.clear();
                isMobileNumber = isMobileNumber == 2 ? 2 : 1;
              });
            },
          ),
          const SizedBox(height: 20.0),
          GestureDetector(
            child: Container(
              width: screenSize.width,
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: selectedOption == 2
                          ? const Color(0xff0965DA)
                          : Colors.black,
                      style: BorderStyle.solid,
                      width: selectedOption == 2 ? 2.0 : 1),
                  borderRadius: BorderRadius.circular(8.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      customRadioBtn(selectedOption == 2 ? true : false),
                      const SizedBox(
                        width: 8.0,
                      ),
                      const Text(
                        "Upload Financial Proof",
                        style: TextStyle(
                            height: 0.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 14.0),
                      )
                    ],
                  ),
                  AnimatedCrossFade(
                    duration: Duration(milliseconds: 300),
                    firstChild: const SizedBox(),
                    sizeCurve: Curves.ease,
                    secondChild: AnimatedOpacity(
                      opacity: selectedOption == 2 ? 1.0 : 0.0,
                      curve: Curves.linear,
                      duration: Duration(milliseconds: 300),
                      child: selectedOption == 2
                          ? uploadProofInfo(screenSize, context)
                          : const SizedBox(),
                    ),
                    crossFadeState: selectedOption == 2
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                  ),
                  Container()
                ],
              ),
            ),
            onTap: () {
              setState(() {
                isMobileNumber = 0;
                selectedOption = 2;
              });
            },
          )
        ]);
  }

  Column uploadProofInfo(Size screenSize, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20.0,
        ),
        Text("Upload Statement (Jpg, Png, Pdf )"),
        const SizedBox(
          height: 22.0,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: CustomDropDown(
            hint: "Income Proof Type",
            showError: false,
            textSizeSmall: true,
            isIcon: true,
            label: 'Income Proof Type',
            controller: fileController,
            values: proofList.map((i) => i["description"]).toList(),
            formValidateNodifier: formValidateNodifier,
            onChange: (value) {
              if ((selectedProof != value && value != null)) {
                checkCount++;
                path = [];
                docId = uploadedFiles.isNotEmpty &&
                        checkCount < 1 &&
                        selectedProof == value
                    ? docId
                    : "";
                currentProof = uploadedFiles.isNotEmpty &&
                        checkCount < 1 &&
                        selectedProof == value
                    ? currentProof
                    : [];
                uploadedFiles = uploadedFiles.isNotEmpty &&
                        checkCount < 1 &&
                        selectedProof == value
                    ? uploadedFiles
                    : [];
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                selectedProof = value;
                setState(() {});
              });
            },
          ),
        ),
        Visibility(
            visible: path.isNotEmpty,
            child: SizedBox(
              height: 10.0,
            )),
        Visibility(
            visible: docId.isNotEmpty,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < currentProof.length; i++) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentProof[i],
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .fontWeight),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            if (uploadedFiles.isNotEmpty) {
                              Navigator.pushNamed(
                                  context,
                                  uploadedFiles[0].toString().endsWith(".pdf")
                                      ? route.previewPdf
                                      : route.previewImage,
                                  arguments: {
                                    "title": "AA Upload proof",
                                    "data": uploadedFiles[1],
                                    "fileName": fileController.text
                                  });
                            } else {
                              Navigator.pushNamed(
                                  context,
                                  currentProof[i].endsWith(".pdf")
                                      ? route.previewPdf
                                      : route.previewImage,
                                  arguments: {
                                    "title": "AA Upload proof",
                                    "data": File(path[i]).readAsBytesSync(),
                                    "fileName": fileController.text
                                  });
                            }
                          },
                          icon: Icon(Icons.preview,
                              color: const Color.fromARGB(255, 99, 97, 97)))
                    ],
                  ),
                  SizedBox(
                    height: i == currentProof.length - 1 ? 0 : 5.0,
                  )
                ]
              ],
            )),
        Visibility(
            visible: (isSalarySlip(fileController.text) &&
                    !(currentProof.length == 3) &&
                    (uploadedFiles.isEmpty || checkCount > 1)) ||
                (!(isSalarySlip(fileController.text)) &&
                    fileController.text.isNotEmpty &&
                    !(currentProof.length == 1)),
            child: SizedBox(
              height: 10.0,
            )),
        Visibility(
            visible: (isSalarySlip(fileController.text) &&
                    currentProof.length == 3) ||
                (currentProof.isNotEmpty &&
                    !(isSalarySlip(fileController.text))),
            child: SizedBox(
              height: 10.0,
            )),
        Visibility(
            visible: (isSalarySlip(fileController.text) &&
                    currentProof.length == 3) ||
                (currentProof.isNotEmpty &&
                    !(isSalarySlip(fileController.text))) ||
                (uploadedFiles.isNotEmpty && checkCount < 1),
            child: customBtn(
                screenSize,
                "Re upload",
                () => {
                      (isSalarySlip(fileController.text))
                          ? pickFileBottomSheet(
                              context,
                              (path, id) => fileDetails(path, id, true),
                              "ProofUpload",
                              ssDocs: true,
                              isGroupUpload: path.length > 1 ? true : false,
                              pathList: path,
                              "Income_proof",
                              proofType: proofList.firstWhere(
                                (element) =>
                                    element["description"] ==
                                    fileController.text,
                              )['code'])
                          : pickFileBottomSheet(
                              context,
                              (path, id) => fileDetails(path, id, true),
                              "ProofUpload",
                              "Income_proof",
                              proofType: proofList.firstWhere(
                                (element) =>
                                    element["description"] ==
                                    fileController.text,
                              )['code'])
                    },
                false)),
        Visibility(
            visible: (isSalarySlip(fileController.text) &&
                    !(currentProof.length == 3) &&
                    (uploadedFiles.isEmpty || checkCount >= 1)) ||
                (!(isSalarySlip(fileController.text)) &&
                    fileController.text.isNotEmpty &&
                    !(currentProof.length == 1)),
            child: customBtn(
                screenSize,
                (currentProof.isNotEmpty &&
                        (isSalarySlip(fileController.text)) &&
                        (uploadedFiles.isEmpty))
                    ? "Add more.."
                    : "Upload",
                () => {
                      (isSalarySlip(fileController.text))
                          ? pickFileBottomSheet(context, (path, id) {
                              return fileDetails(path, id);
                            },
                              "ProofUpload",
                              ssDocs: true,
                              isGroupUpload: path.length > 1 ? true : false,
                              pathList: path,
                              "Income_proof",
                              proofType: proofList.firstWhere(
                                (element) =>
                                    element["description"] ==
                                    fileController.text,
                              )['code'])
                          : pickFileBottomSheet(
                              context,
                              (path, id) => fileDetails(path, id),
                              "ProofUpload",
                              proofType: proofList.firstWhere(
                                (element) =>
                                    element["description"] ==
                                    fileController.text,
                              )['code'],
                              "Income_proof",
                            )
                    })),
      ],
    );
  }

  Widget customBtn(Size screenSize, String txt, Function func, [color = true]) {
    return SizedBox(
      height: 35.0,
      child: ElevatedButton(
          onPressed: () {
            func();
          },
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(color
                  ? Theme.of(context)
                      .inputDecorationTheme
                      .copyWith()
                      .enabledBorder!
                      .borderSide
                      .color
                  : Colors.green),
              padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 20.0))),
          child: Text(txt)),
    );
  }

  Widget customRadioBtn(bool isCheck) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      height: 18.0,
      width: 18.0,
      decoration: BoxDecoration(
          border: Border.all(style: BorderStyle.solid, width: 1.7),
          shape: BoxShape.circle),
      child: Container(
        decoration: BoxDecoration(
            color: isCheck ? const Color(0xff0965da) : Colors.transparent,
            shape: BoxShape.circle),
      ),
    );
  }

  Column bankInfo(Size screenSize, [String errMsg = "ddd"]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 15.0,
        ),
        const Text("Bank Name"),
        const SizedBox(
          height: 5.0,
        ),
        Container(
            height: 30.0,
            width: screenSize.width,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
                border: Border.all(
                  style: BorderStyle.solid,
                  width: 1,
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8.0)),
            child: Center(
                child: Text('${widget.bankName}-${widget.accountNumber}'))),
        const SizedBox(
          height: 10.0,
        ),
        Text("Mobile Number"),
        const SizedBox(
          height: 5.0,
        ),
        Container(
            width: screenSize.width,
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 15.0),
            decoration: BoxDecoration(
                border: Border.all(
                  style: BorderStyle.solid,
                  width: 1,
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8.0)),
            child: Text(widget.mobileNumber)),
        const SizedBox(
          height: 30.0,
        ),
        const Center(
          child: Text("Is this your bank registered mobile number ?",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Radio(
                    activeColor: const Color(0xff0965DA),
                    value: 1,
                    groupValue: isMobileNumber,
                    onChanged: (int? val) => {
                          setState(() {
                            isMobileNumber = val;
                          })
                        }),
                InkWell(
                  onTap: () => {
                    setState(() {
                      isMobileNumber = 1;
                    })
                  },
                  child: Text(
                    "Yes",
                    style: TextStyle(
                        height: 0.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 50.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Radio(
                    activeColor: const Color(0xff0965DA),
                    value: 2,
                    groupValue: isMobileNumber,
                    onChanged: (int? val) => {
                          setState(() {
                            isMobileNumber = val;
                          })
                        }),
                InkWell(
                  onTap: () => {
                    setState(() {
                      isMobileNumber = 2;
                    })
                  },
                  child: Text(
                    "No",
                    style: TextStyle(
                        height: 0.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
        AnimatedOpacity(
          opacity: isMobileNumber == 2 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: isMobileNumber == 2
              ? Form(
                  key: _form,
                  child: CustomFormField(
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    // readOnly: docId.isNotEmpty ? true : false,
                    controller: mobileNumberController,
                    hintText: "Enter Mobile Number",
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10)
                    ],
                    onChange: (value) {
                      setState(() {});
                    },
                    validator: mobileNumberValidation,
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  fileDetails(path, id, [isReload = false]) {
    if (isReload) {
      docId = "";
      this.path = [];
      uploadedFiles = [];
      currentProof = [];
    }
    try {
      if (this.path.length < 3) {
        if (path is List) {
          print(docId);
        } else {
          this.path.add(path);
        }
      }
      docId = id;

      if (docId.isNotEmpty) {
        List<String> formatProof = [];

        for (var i in this.path) {
          formatProof.add("${fileController.text} ${i.split("/").last}");
        }
        currentProof = formatProof;
        isShowUploadOption = 1;

        // this.path = this.path.length <= 2 ? path : this.path;
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("error $e");
    }
  }

  insertIncomeProof() {
    if (selectedOption == 2) {
      if (docId.isNotEmpty) {
        insertSegmentDetails();
      } else {
        showSnackbar(context, "Please select the proof file", Colors.red);
      }
    } else {
      createConcentRequest(context);
    }
  }

  createConcentRequest(context) async {
    loadingAlertBox(context);
    String? alterMobileNo;

    if (isMobileNumber == 2) {
      if (mobileNumberController.text.length == 10) {
        alterMobileNo = mobileNumberController.text;
      } else {
        showSnackbar(context, "Please enter mobile number", Colors.red);
        Navigator.pop(context);
        return;
      }
    }
    var response = await createConcentRequestAPI(context: context, data: {
      "mobileno": widget.mobileNumber,
      "bankname": widget.bankName,
      // "mobileno": "6382480112",
      // "bankname": "FinShareBankServer",
      "altermobileno": alterMobileNo
    });
    Navigator.pop(context);
    String url = Provider.of<ProviderClass>(context, listen: false).url;
    if (url.isEmpty || !url.contains("ecres")) {
      if (response != null) {
        String webUrl = response['weburl'] ?? '';
        if (webUrl.isNotEmpty) {
          Navigator.pushNamed(context, route.esignHtml,
                  arguments: {"url": webUrl, "routeName": route.aggregator})
              .then((value) {
            url = Provider.of<ProviderClass>(context, listen: false).url;
            if (url.isNotEmpty) {
              getConsentStatus(url);
            }
          });
        }
      }
    } else {
      reAttempt = 0;
      loadingAlertBox(context);
      await getStatement(consentHandle);
    }
  }

  concentStatus(ecres, resdate, fi) async {
    try {
      // if (mounted) {
      //   setState(() {});
      // }
      WebRedirectionURL web =
          WebRedirectionURL(ecres: ecres, resdate: resdate, fi: fi);
      DecryptUrlRequest request = DecryptUrlRequest(webRedirectionURL: web);
      var response =
          await getConcentStatus(context: context, data: request.toJson());
      if (response == null) {
        Navigator.pop(context);
        return;
      }
      errorcode = response['errorcode'];
      if (response['errorcode'] == '0') {
        consentHandle = response['srcref'] ?? "";
        Future.delayed(
          Duration(seconds: 10),
          () async {
            await getStatement(consentHandle);
          },
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      print("error $e");
    }
  }

  // reAttemptFetch(String consentHandle) async {
  //   var statement = await fetchStatement(context: context, data: {
  //     "maskaccount": widget.accountNumber,
  //     "consenthandle": consentHandle
  //   });
  //   if (statement["response"] == "S") {
  //     insertSegmentDetails();
  //   } else {
  //     if (reAttement <= 1) {
  //       Future.delayed(
  //         Duration(seconds: 5),
  //         () async {
  //           await reAttemptFetch(consentHandle);
  //         },
  //       );
  //     } else {
  //       Navigator.pop(context);
  //       showSnackbar(
  //           context, statement["msg"] ?? "Some thing went wrong", Colors.red);
  //     }
  //   }
  // }

  getStatement(consentHandle) async {
    var statement = await fetchStatement(context: context, data: {
      "maskaccount": widget.accountNumber,
      "consenthandle": consentHandle
    });
    reAttempt++;
    if (statement['status'] == "S") {
      Navigator.pop(context);
      showbottomsheet(context);
    } else {
      if (reAttempt <= 10) {
        Future.delayed(
          Duration(seconds: 5),
          () async {
            String url = Provider.of<ProviderClass>(context, listen: false).url;
            if (url.isNotEmpty) {
              Navigator.pop(context);
              getConsentStatus(url);
            } else {
              Navigator.pop(context);
            }
          },
        );
      } else {
        Navigator.pop(context);
        showSnackbar(
            context, statement["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  }

  showbottomsheet(context1) {
    return showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context1,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 335,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xffedf8fd),
                ),
                child: const Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Fetched Sucessfully!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromRGBO(0, 192, 100, 1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      " We have successfully fetched your six month bank statement.",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              //
              CustomButton(
                buttonFunc: () {
                  Navigator.pop(context);
                  insertSegmentDetails();
                },
              ),
              const SizedBox(
                height: 20.0,
              )
            ],
          ),
        );
      },
    );
  }

  insertSegmentDetails() async {
    loadingAlertBox(context);
    ProviderClass provider = Provider.of<ProviderClass>(context, listen: false);
    if (provider.isEditPage) {
      if (mounted) {
        Navigator.pop(context);
      }
      getNextRoute(context);
      return;
    }
    Map newDemantServ = widget.demantData;
    var json = await insertDemantserveApi(context, newDemantServ);
    if (mounted) {
      Navigator.pop(context);
    }
    if (json != null) {
      getNextRoute(context);
    }
  }

  getNextRoute(context) async {
    loadingAlertBox(context);
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.segmentSelection],
      "routeraction": "Next"
    });

    if (mounted) {
      Navigator.pop(context);
    }

    if (response != null) {
      Navigator.pushNamed(context, response["endpoint"]);
    }
  }

  getConsentStatus(url) async {
    loadingAlertBox(context);

    var uri = Uri.parse(url ?? "");
    Map queryParameters = uri.queryParameters;
    String ecres = queryParameters["ecres"] ?? "";
    String resdate = queryParameters["resdate"] ?? "";
    String fi = queryParameters["fi"] ?? "";
    if (errorcode == "0" && consentHandle != "") {
      await getStatement(consentHandle);
    } else if (ecres != "" && resdate != "" && fi != "") {
      concentStatus(ecres, resdate, fi);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> setData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('username', 'JohnDoe');
  }
}

class DecryptUrlRequest {
  WebRedirectionURL webRedirectionURL;

  DecryptUrlRequest({required this.webRedirectionURL});

  // Convert the object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'webRedirectionURL': webRedirectionURL.toJson(),
    };
  }
}

class WebRedirectionURL {
  String ecres;
  String resdate;
  String fi;

  WebRedirectionURL({
    required this.ecres,
    required this.resdate,
    required this.fi,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ecres': ecres,
      'resdate': resdate,
      'fi': fi,
    };
  }
}
