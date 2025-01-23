import 'dart:convert';

import '../API%20call/api_call.dart';
import '../Custom Widgets/custom_snackBar.dart';
import '../Custom%20Widgets/custom_radio_button.dart';
import '../Custom%20Widgets/scrollable_widget.dart';
import '../Model/get_bank_detail_ifsc_model.dart';
import '../Screens/signup.dart';
import '../Service/validate_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Custom Widgets/StepWidget.dart';
import '../Custom Widgets/acctype.dart';
import '../Custom Widgets/custom_button.dart';
import '../Custom Widgets/custom_form_field.dart';
import '../Nodifier/nodifierCLass.dart';
// import '../Ramesh/CustomWidget/custom_radio_button.dart';
import 'package:dotted_border/dotted_border.dart';
import '../Route/route.dart' as route;

class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  bool isLoadingDetails = true;
  FetchBankDetailByIfsc? fetchBankDetails;
  TextEditingController ifscController = TextEditingController(text: "");
  TextEditingController accNumController = TextEditingController(text: "");
  TextEditingController confirmaccnumController =
      TextEditingController(text: "");
  FormValidateNodifier formValidateNodifierifsc = FormValidateNodifier(
    {
      'IFSC Number': false,
      'Account Number': false,
      'Re-Enter Account Number': false,
    },
  );
  bool isifscloading = false;
  bool isIFSCFinished = false;
  bool isINCorrectIFSc = false;
  // BankScreenNotifier bankScreenNotifier = BankScreenNotifier();
  List images = [
    'gpay.png',
    'phonepe.png',
    'paytm.png',
    'amazonpay.png',
  ];

  String linkType = 'IFSC';
  String upiType = '';
  String upiBankType = '';
  final _formKey = GlobalKey<FormState>();
  bool isFormValid = false;
  ScrollController scrollController = ScrollController();
  Map accountDetail = {};
  changeLinkType(String newLinkType) {
    linkType = newLinkType;
    if (mounted) {
      setState(() {});
    }
  }

  changeUpiType(String newUpiType) {
    upiType = newUpiType;
    if (mounted) {
      setState(() {});
    }
  }

  changeUpiBankType(String newUpiBankType) {
    upiBankType = newUpiBankType;
    if (mounted) {
      setState(() {});
    }
  }

  List accountTypes = [];

  fetchBankDtlFromIfsc() async {
    isifscloading = true;
    isINCorrectIFSc = false;
    if (accountDetail["ifsc"] == ifscController.text) {
      fetchBankDetails = FetchBankDetailByIfsc(
          micr: accountDetail["micr"],
          branch: accountDetail["branch"],
          address: accountDetail["address"],
          state: "",
          bank: accountDetail["bank"],
          status: "",
          success: "",
          // acctype: accountDetail["acctype"],
          errMsg: "");
    } else {
      FetchBankDetailByIfsc? fetchBankDetailByIfsc = await getBankDetailsAPI(
          context: context, ifscCode: ifscController.text);
      if (fetchBankDetailByIfsc != null) {
        fetchBankDetails = fetchBankDetailByIfsc;
        isINCorrectIFSc = false;
        setState(() {});
      } else {
        fetchBankDetails = FetchBankDetailByIfsc(
            micr: "",
            branch: "",
            address: "",
            state: "",
            bank: "",
            status: "",
            success: "",
            // acctype: accountDetail["acctype"],
            errMsg: "");
        isIFSCFinished = false;
        isINCorrectIFSc = true;
      }
    }
    isLoadingDetails = false;
    isifscloading = false;
    if (mounted) {
      setState(() {});
    }
  }

  formValidation(value) {
    if (ifscController.text.isNotEmpty &&
        accNumController.text.isNotEmpty &&
        confirmaccnumController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_formKey.currentState?.validate() ?? false) {
          isFormValid = true;
        }
      });
    }
    isFormValid = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  insertBankDetails() async {
    // if (fetchBankDetails == null || fetchBankDetails!.bank.isEmpty) {
    //   showSnackbar(context, "Some thing went wrong", Colors.red);
    // }
    Map bankDetailsMap = {
      "accno": accNumController.text,
      "ifsc": ifscController.text,
      "micr": fetchBankDetails!.micr,
      "bank": fetchBankDetails!.bank,
      "branch": fetchBankDetails!.branch,
      "address": fetchBankDetails!.address,
      // "account": "", // upiBankType.toString().substring(0, 1),
      "acctype": accountTypes.firstWhere(
          (element) => element["description"] == upiBankType)["code"]
    };
    if (!jsonIsModified(accountDetail, bankDetailsMap)) {
      getNextRoute(context);
      return;
    }
    loadingAlertBox(context);
    var response =
        await insertBankDetailsAPI(context: context, json: bankDetailsMap);
    if (mounted) {
      Navigator.pop(context);
    }
    if (response != null) {
      showbottomsheet(context);
    }
  }

  getNextRoute(context) async {
    loadingAlertBox(context);
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.bankScreen],
      "routeraction": "Next"
    });

    if (mounted) {
      Navigator.pop(context);
    }

    if (response != null) {
      Navigator.pushNamed(context, response["endpoint"]);
    }
  }

  getBankDetails() async {
    loadingAlertBox(context);
    var response =
        await getDropDownValues(context: context, code: " Bank Account type");
    if (response != null) {
      accountTypes = response["lookupvaluearr"] ?? [];
      int indexOfaccType =
          accountTypes.indexWhere((element) => element["code"] == "10");
      upiBankType = indexOfaccType != -1
          ? accountTypes[indexOfaccType]["description"]
          : "";
    }

    var response1 = await getBankWithAccountDetailsAPI(context: context);

    if (mounted) {
      Navigator.pop(context);
    }

    if (response1 != null) {
      accountDetail = response1["bankstruct"] ?? {};
      accNumController.text = accountDetail["accno"];
      confirmaccnumController.text = accountDetail["accno"];
      ifscController.text = accountDetail["ifsc"];
      int indexOfaccType = accountTypes
          .indexWhere((element) => element["code"] == accountDetail["acctype"]);
      indexOfaccType != -1
          ? upiBankType = accountTypes[indexOfaccType]["description"]
          : null;

      ifscController.text.isNotEmpty ? await fetchBankDtlFromIfsc() : null;
      fetchBankDetails = FetchBankDetailByIfsc(
          micr: accountDetail["micr"],
          branch: accountDetail["branch"],
          address: accountDetail["address"],
          state: "",
          bank: accountDetail["bank"],
          status: "",
          success: "",
          // acctype: accountDetail["acctype"],
          errMsg: "");
      formValidation("");
    }
    isIFSCFinished = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getBankDetails();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StepWidget(
      endPoint: route.bankScreen,
      step: 4,
      title: 'Bank and Segments',
      subTitle: 'Enter your bank details',
      scrollController: scrollController,
      buttonFunc:
          // isFormValid
          //     ?
          () {
        if (!_formKey.currentState!.validate()) {
          return;
        }
        if (fetchBankDetails == null || fetchBankDetails!.bank.isEmpty) {
          showSnackbar(context, "Some thing went wrong", Colors.red);
          return;
        }
        // showbottomsheet();
        insertBankDetails();
      },
      // : null,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              // ...getTitleANdSubTitleWidget(
              //     'Bank and Segments',
              //     'Enter your bank details and select your preferred segments',
              //     context),
              // GestureDetector(
              //   onTap: () {
              //     bankScreenNotifier.changeLinkType('UPI');
              //   },
              //   child: bankScreenNotifier.linkType == 'UPI'
              //       ? Container(
              //           padding: const EdgeInsets.all(20.0),
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(7.0),
              //             border: Border.all(
              //                 width: 1.0,
              //                 color: const Color.fromRGBO(9, 101, 218, 1)),
              //             color: Colors.white,
              //           ),
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               const Row(
              //                 mainAxisAlignment:
              //                     MainAxisAlignment.spaceBetween,
              //                 children: [
              //                   Text(
              //                     "Link Using UPI",
              //                   ),
              //                   CustomRadioButton(
              //                       color: Color.fromRGBO(9, 101, 218, 1)),
              //                 ],
              //               ),
              //               const SizedBox(height: 10.0),
              //               const DottedLine(),
              //               const SizedBox(
              //                 height: 10.0,
              //               ),
              //               bankScreenNotifier.upiType.isEmpty
              //                   ? Row(
              //                       children: [
              //                         for (int index = 0;
              //                             index < 4;
              //                             index++)
              //                           InkWell(
              //                             onTap: () {
              //                               bankScreenNotifier
              //                                   .changeUpiType(
              //                                       '${images[index]}');
              //                             },
              //                             child: Container(
              //                               width: 23,
              //                               height: 23,
              //                               margin: const EdgeInsets.only(
              //                                   right: 8.0),
              //                               decoration: BoxDecoration(
              //                                 borderRadius:
              //                                     BorderRadius.circular(6),
              //                                 border: Border.all(
              //                                   width: 2.0,
              //                                   color: const Color.fromRGBO(
              //                                       195, 195, 195, 1),
              //                                 ),
              //                               ),
              //                               child: Image.asset(
              //                                 'assets/images/${images[index]}',
              //                                 fit: BoxFit.cover,
              //                               ),
              //                             ),
              //                           ),
              //                         const SizedBox(width: 8.0),
              //                         const Text(
              //                           'and more',
              //                         ),
              //                       ],
              //                     )
              //                   : Column(
              //                       children: [
              //                         const Text(
              //                           "Bank account details fetched through UPI transaction.",
              //                         ),
              //                         const SizedBox(
              //                           height: 10.0,
              //                         ),
              //                         Container(
              //                           padding: const EdgeInsets.only(
              //                               top: 15.0, left: 30.0),
              //                           decoration: BoxDecoration(
              //                             borderRadius:
              //                                 BorderRadius.circular(10),
              //                             gradient: const LinearGradient(
              //                               begin: Alignment.topCenter,
              //                               end: Alignment.bottomCenter,
              //                               colors: [
              //                                 Color(0X4cff656e),
              //                                 Color(0X00d9d9d9),
              //                               ],
              //                             ),
              //                           ),
              //                           child: Column(
              //                             crossAxisAlignment:
              //                                 CrossAxisAlignment.start,
              //                             children: [
              //                               Image.asset(
              //                                 'assets/images/hdfc.png',
              //                                 width: 29,
              //                                 height: 29,
              //                               ),
              //                               const SizedBox(
              //                                 height: 10,
              //                               ),
              //                               const Text(
              //                                 "HDFC Bank",
              //                                 style: TextStyle(
              //                                   fontSize: 10,
              //                                   fontWeight: FontWeight.w600,
              //                                 ),
              //                               ),
              //                               const SizedBox(
              //                                 height: 10,
              //                               ),
              //                               const Row(
              //                                 children: [
              //                                   Column(
              //                                     crossAxisAlignment:
              //                                         CrossAxisAlignment
              //                                             .start,
              //                                     children: [
              //                                       Text(
              //                                         "Account No:",
              //                                         style: TextStyle(
              //                                           fontSize: 8,
              //                                           fontWeight:
              //                                               FontWeight.w500,
              //                                         ),
              //                                       ),
              //                                       SizedBox(
              //                                         height: 5,
              //                                       ),
              //                                       Text(
              //                                         "3197XXXXXXXX",
              //                                         style: TextStyle(
              //                                           fontSize: 7,
              //                                           fontWeight:
              //                                               FontWeight.w400,
              //                                         ),
              //                                       ),
              //                                       SizedBox(
              //                                         height: 15,
              //                                       ),
              //                                       Text(
              //                                         "MICR Code",
              //                                         style: TextStyle(
              //                                           fontSize: 8,
              //                                           fontWeight:
              //                                               FontWeight.w500,
              //                                         ),
              //                                       ),
              //                                       SizedBox(
              //                                         height: 5,
              //                                       ),
              //                                       Text(
              //                                         "65897421246",
              //                                         style: TextStyle(
              //                                           fontSize: 7,
              //                                           fontWeight:
              //                                               FontWeight.w400,
              //                                         ),
              //                                       ),
              //                                     ],
              //                                   ),
              //                                   Expanded(
              //                                     child: Text(''),
              //                                   ),
              //                                   Column(
              //                                     crossAxisAlignment:
              //                                         CrossAxisAlignment
              //                                             .start,
              //                                     children: [
              //                                       Text(
              //                                         "IFSC Code",
              //                                         style: TextStyle(
              //                                           fontSize: 8,
              //                                           fontWeight:
              //                                               FontWeight.w500,
              //                                         ),
              //                                       ),
              //                                       SizedBox(
              //                                         height: 5,
              //                                       ),
              //                                       Text(
              //                                         "FPWP1127",
              //                                         style: TextStyle(
              //                                           fontSize: 7,
              //                                           fontWeight:
              //                                               FontWeight.w400,
              //                                         ),
              //                                       ),
              //                                       SizedBox(
              //                                         height: 15,
              //                                       ),
              //                                       Text(
              //                                         "Branch",
              //                                         style: TextStyle(
              //                                           fontSize: 8,
              //                                           fontWeight:
              //                                               FontWeight.w500,
              //                                         ),
              //                                         textAlign:
              //                                             TextAlign.start,
              //                                       ),
              //                                       SizedBox(
              //                                         height: 5,
              //                                       ),
              //                                       Text(
              //                                         "Chennai, Tamilnadu, Chennai ",
              //                                         style: TextStyle(
              //                                           fontSize: 7,
              //                                           fontWeight:
              //                                               FontWeight.w400,
              //                                         ),
              //                                       ),
              //                                     ],
              //                                   ),
              //                                   Expanded(
              //                                     child: Text(''),
              //                                   ),
              //                                 ],
              //                               ),
              //                             ],
              //                           ),
              //                         ),
              //                         const SizedBox(
              //                           height: 10,
              //                         ),
              //                       ],
              //                     )
              //             ],
              //           ),
              //         )
              //       : Container(
              //           padding: const EdgeInsets.all(20.0),
              //           decoration: BoxDecoration(
              //             border: Border.all(
              //               width: 1.0,
              //               color: const Color.fromRGBO(179, 177, 177, 1),
              //             ),
              //             borderRadius: BorderRadius.circular(7.0),
              //             color: Colors.white,
              //           ),
              //           child: const Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Text(
              //                 "Link Using UPI",
              //               ),
              //               CustomRadioButton(
              //                 color: Colors.white,
              //               ),
              //             ],
              //           ),
              //         ),
              // ),
              Visibility(
                visible: linkType == 'UPI' && upiType.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      "Account Type *",
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        InkWell(
                            onTap: () {
                              changeUpiBankType('Savings');
                            },
                            child: AccountType(
                              txt: 'Savings',
                              accType: upiBankType,
                            )),
                        const SizedBox(width: 50.0),
                        InkWell(
                          onTap: () {
                            changeUpiBankType('Current');
                          },
                          child: AccountType(
                            txt: 'Current',
                            accType: upiBankType,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  changeLinkType('IFSC');
                },
                child: linkType == 'IFSC'
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.0,
                              color: const Color.fromRGBO(9, 101, 218, 1)),
                          borderRadius: BorderRadius.circular(7.0),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Link Using IFSC',
                                ),
                                CustomRadioButton(
                                  color: Color.fromRGBO(9, 101, 218, 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            ...customFormField(
                              suffixIcon: !isifscloading
                                  ? null
                                  : Transform.scale(
                                      scale: 0.5,
                                      child: CircularProgressIndicator()),
                              onChange: (value) {
                                if (ifscController.text.length == 11 &&
                                    RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$')
                                        .hasMatch(value.toUpperCase())) {
                                  isIFSCFinished = true;
                                  fetchBankDtlFromIfsc();
                                } else {
                                  isIFSCFinished = false;
                                }
                                formValidation(value);
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              controller: ifscController,
                              formValidateNodifier: formValidateNodifierifsc,
                              labelText: 'IFSC Number',
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                                LengthLimitingTextInputFormatter(11),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9]')),
                              ],
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'IFSC code is required';
                                }
                                if (value.length == 11) {
                                  if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$')
                                          .hasMatch(value.toUpperCase()) ||
                                      isINCorrectIFSc) {
                                    return 'Enter valid IFSC code';
                                  }
                                } else {
                                  return 'Enter valid IFSC Code';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            !isLoadingDetails
                                ? Visibility(
                                    visible: isIFSCFinished,
                                    child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(10),
                                      dashPattern: [5, 3],
                                      child: Container(
                                        padding: const EdgeInsets.all(15),
                                        // width: 284,
                                        // height: 115,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: const Color(0x7fc9f4e7),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Bank : ",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        fetchBankDetails!.bank,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      // const SizedBox(height: 10),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "MICR : ",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        fetchBankDetails!.micr,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      // const SizedBox(height: 10),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Branch:  : ",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        fetchBankDetails!
                                                            .branch,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      // const SizedBox(height: 10),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Address:  : ",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        fetchBankDetails!
                                                            .address,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 10),
                            ...customFormField(
                              controller: accNumController,
                              formValidateNodifier: formValidateNodifierifsc,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(20)
                              ],
                              labelText: 'Account Number',
                              obscure: true,
                              onChange: formValidation,
                              restrictCopyAndPaste: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Account Number can't be empty";
                                } else if (value.length < 5) {
                                  return "Enter valid Account Number";
                                } else if (value.length > 35) {
                                  return "Enter valid Account Number";
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            ...customFormField(
                              controller: confirmaccnumController,
                              formValidateNodifier: formValidateNodifierifsc,
                              labelText: 'Re-Enter Account Number',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(20)
                              ],
                              restrictCopyAndPaste: true,
                              onChange: formValidation,
                              validator: (value) {
                                if (value.isNotEmpty) {
                                  if (accNumController.text != value) {
                                    return 'Account Number Mismatch';
                                  } else {
                                    return null;
                                  }
                                } else {
                                  return "Account Number can't be empty ";
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Account Type *',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(102, 98, 98, 1.0),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: accountTypes
                                    .map((accType) => Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: InkWell(
                                            onTap: () => changeUpiBankType(
                                                accType["description"]),
                                            child: AccountType(
                                                txt: accType["description"],
                                                accType: upiBankType),
                                          ),
                                        ))
                                    .toList()
                                //  [
                                //   InkWell(
                                //       onTap: () {
                                //         changeUpiBankType('Savings');
                                //       },
                                //       child: AccountType(
                                //         txt: 'Savings',
                                //         accType: upiBankType,
                                //       )),
                                //   const SizedBox(width: 50.0),
                                //   InkWell(
                                //     onTap: () {
                                //       changeUpiBankType('Current');
                                //     },
                                //     child: AccountType(
                                //       txt: 'Current',
                                //       accType: upiBankType,
                                //     ),
                                //   ),
                                // ],
                                )
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: const Color.fromRGBO(179, 177, 177, 1),
                          ),
                          borderRadius: BorderRadius.circular(7.0),
                          color: Colors.white,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Link Using IFSC',
                            ),
                            CustomRadioButton(
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(
                height: 15.0,
              ),
            ],
          ),
        ),
        // ValueListenableBuilder(
        //     // listenable: ,
        //     valueListenable: formValidateNodifierifsc,
        //     builder: (context, value, child) {
        //       return CustomButton(
        //         onPressed: (bankScreenNotifier.linkType == 'UPI' &&
        //                     bankScreenNotifier.upiType.isNotEmpty) ||
        //                 (bankScreenNotifier.linkType == 'IFSC' &&
        //                     formValidateNodifierifsc.getValue.keys.every(
        //                         (element) => formValidateNodifierifsc
        //                             .getValue[element]))
        //             ? () {
        //                 showbottomsheet();
        //               }
        //             : null,
        //       );
        //     }),
      ],
    );
  }

  showbottomsheet(context1) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
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
                      "We Verified Your Bank!",
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
                      " We have successfully verified your bank via penny drop",
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
                  getNextRoute(context1);
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
}

class BankScreenNotifier extends ChangeNotifier {
  // String linkType = 'IFSC';
}
