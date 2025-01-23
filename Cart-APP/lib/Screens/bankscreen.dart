import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:ekyc/Cookies/cookies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyc_workflow/digio_config.dart';
import 'package:kyc_workflow/environment.dart';
import 'package:kyc_workflow/gateway_event.dart';
import 'package:kyc_workflow/kyc_workflow.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../API%20call/api_call.dart';
import '../Custom Widgets/acctype.dart';
import '../Custom Widgets/custom_button.dart';
import '../Custom Widgets/custom_form_field.dart';
import '../Custom Widgets/custom_snackbar.dart';
import '../Custom Widgets/stepwidget.dart';
import '../Custom%20Widgets/custom_radio_button.dart';
import '../Model/get_bank_detail_ifsc_model.dart';
import '../Nodifier/nodifierclass.dart';
import '../Route/route.dart' as route;
import '../Screens/signup.dart';
import '../Service/validate_func.dart';

class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> with WidgetsBindingObserver {
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
  bool isIFSCValid = false;
  List images = [
    'gpay.png',
    'phonepe.png',
    'paytm.png',
    'amazonpay.png',
  ];

  String linkType = 'UPI';

  String upiBankType = '';
  final _formKey = GlobalKey<FormState>();
  bool isFormValid = false;
  ScrollController scrollController = ScrollController();
  Map accountDetail = {};

  String serviceType = "";
  Map seturpd = {};
  Map digiorpd = {};
  Map bankDetailsViaRPD = {};
  Map previousBankDetails = {};

  bool isRPDget = false;

  /* 
  Purpose: This method is used for change the linkType as UPI or IFSC.
  */

  changeLinkType(String newLinkType) {
    linkType = newLinkType;
    if (mounted) {
      setState(() {});
    }
  }
  /* 
  Purpose: This method is used for change the upiBankType as current or saving
  */

  changeUpiBankType(String newUpiBankType) {
    upiBankType = newUpiBankType;
    if (mounted) {
      setState(() {});
    }
  }

  List accountTypes = [];

  /* 
  Purpose: This method is used get the bank Details for IFSC
  */

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

  /* 
  Purpose: This method is used validate the Form
  */

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

  /* 
  Purpose: This method is used insert the Bank details to the API
  */

  insertBankDetails() async {
    Map bankDetailsMap = {};
    switch (linkType) {
      case "UPI":
        bankDetailsMap = {
          "accno": bankDetailsViaRPD['accno'],
          "acctype": accountTypes.firstWhere(
              (element) => element["description"] == upiBankType)["code"],
          "address": bankDetailsViaRPD['address'],
          "bank": bankDetailsViaRPD['bank'],
          "branch": bankDetailsViaRPD['branch'],
          "ifsc": bankDetailsViaRPD['ifsc'],
          "micr": bankDetailsViaRPD['micr'],
          "rpdaccstatus": bankDetailsViaRPD['rpdaccstatus:'],
          "rpdstatus": bankDetailsViaRPD['rpdstatus'],
          "rpdusername": bankDetailsViaRPD['rpdusername'],
          "verifytype": serviceType == "DIGIO" ? 'DRPD' : "SRPD",
        };
        break;
      case "IFSC":
        bankDetailsMap = {
          "accno": accNumController.text,
          "acctype": accountTypes.firstWhere(
              (element) => element["description"] == upiBankType)["code"],
          "address": fetchBankDetails!.address,
          "bank": fetchBankDetails!.bank,
          "branch": fetchBankDetails!.branch,
          "ifsc": ifscController.text,
          "micr": fetchBankDetails!.micr,
          "rpdaccstatus": null,
          "rpdstatus": null,
          "rpdusername": null,
          "verifytype": "PD",
        };
        isIFSCValid = true;
        break;
      default:
        bankDetailsMap = {
          "accno": previousBankDetails['accno'],
          "acctype": accountTypes.firstWhere(
              (element) => element["description"] == upiBankType)["code"],
          "address": previousBankDetails['address'],
          "bank": previousBankDetails['bank'],
          "branch": previousBankDetails['branch'],
          "ifsc": previousBankDetails['ifsc'],
          "micr": previousBankDetails['micr'],
          "rpdaccstatus": previousBankDetails['rpdaccstatus:'],
          "rpdstatus": previousBankDetails['rpdstatus'],
          "rpdusername": null,
          "verifytype": serviceType == "DIGIO" ? 'DRPD' : "SRPD",
        };
    }

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

  /* 
  Purpose: This method is used get the next route name
  */

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

  /* 
  Purpose: This method is used get the dropDown for bank accouct types and also get the bank details from the DB
  */

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
      // linkType = accountDetail['verifytype'] == "PD" ? "IFSC" : "UPI";
      linkType = "IFSC";
      if (accountDetail['verifytype'] == "DRPD" ||
          accountDetail['verifytype'] == "SRPD") {
        bankDetailsViaRPD['bank'] = accountDetail["bank"];
        bankDetailsViaRPD['accno'] = accountDetail["accno"];
        bankDetailsViaRPD['micr'] = accountDetail["micr"];
        bankDetailsViaRPD['ifsc'] = accountDetail["ifsc"];
        bankDetailsViaRPD['branch'] = accountDetail["branch"];
        bankDetailsViaRPD['address'] = accountDetail["address"];
        isRPDget = true;
      } else if (/* accountDetail['verifytype'] == "PD" */ linkType == "IFSC") {
        accNumController.text = accountDetail["accno"];
        confirmaccnumController.text = accountDetail["accno"];
        ifscController.text = accountDetail["ifsc"];
        ifscController.text.isNotEmpty ? await fetchBankDtlFromIfsc() : null;
        fetchBankDetails = FetchBankDetailByIfsc(
            micr: accountDetail["micr"],
            branch: accountDetail["branch"],
            address: accountDetail["address"],
            state: "",
            bank: accountDetail["bank"],
            status: "",
            success: "",
            errMsg: "");
        formValidation("");
        isIFSCValid = true;
      }
      int indexOfaccType = accountTypes
          .indexWhere((element) => element["code"] == accountDetail["acctype"]);
      indexOfaccType != -1
          ? upiBankType = accountTypes[indexOfaccType]["description"]
          : null;
    }
    // var response2 = await getRPDPayApi(context: context);
    // print("response2");
    // print(response2);
    // seturpd = response2['seturpd'];
    // digiorpd = response2['digiorpd'];
    // serviceType = response2['service'];
    if (mounted) {
      setState(() {});
    }
  }

  /* 
  Purpose: This method is used get the rpd details before using RPD
  */

  getRPDPayApi({required context}) async {
    try {
      var response = await CustomHttpClient.get("initrpdpay", context);
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        if (json["status"] == "S") {
          return json;
        } else {
          showSnackbar(
              context, json["errmsg"] ?? "some thing went wrong", Colors.red);
        }
      }
    } catch (e) {
      showSnackbar(
          context, exceptionShowSnackBarContent(e.toString()), Colors.red);
    }
  }

  /* 
  Purpose: This method is used for doing RPD
  */

  rpdAPI() async {
    try {
      if (serviceType == 'SETU') {
        if (seturpd['rpdstatus'] == 'RPD_Created') {
          if (await canLaunchUrlString(seturpd['upilink'])) {
            await launchUrlString(seturpd['upilink']);
            var resRPDMockPay = await getRPDMockPayApi(context: context);
            Future.delayed(
              Duration(seconds: 10),
              () async {
                if (resRPDMockPay['success']) {
                  bankDetailsViaRPD = await validateRPDAPI(context: context);
                  isRPDget = true;
                }
              },
            );
          }
        }
      } else if (serviceType == 'DIGIO') {
        var kidId = digiorpd['clientid'];
        var gwtId = digiorpd['clienttoken'];
        var id = digiorpd['identify'];

        function(kidId, gwtId, id);
      }
    } catch (e) {
      showSnackbar(
          context, exceptionShowSnackBarContent(e.toString()), Colors.red);
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  String transactionId = "";

  /* 
  Purpose: This method is used for doing digio RPD
  */

  function(kidId, gwtId, email, {String actiontype = ''}) async {
    WidgetsFlutterBinding.ensureInitialized();

    var digioConfig = DigioConfig();

    digioConfig.theme.primaryColor = "#32a83a";
    digioConfig.environment = Environment
        .SANDBOX; // SANDBOX is testing server, PRODUCTION is production server

    final kycWorkflowPlugin = KycWorkflow(digioConfig);
    kycWorkflowPlugin.setGatewayEventListener((GatewayEvent? gatewayEvent) {
      transactionId = gatewayEvent!.txnId.toString();
    });
    // kid KID240206133931111HCXK2U1WA79ZGA
    // gwt GWT2402061339312233SFZGUEDZ3U34E
    // diwananifa@gmail.com
    var workflowResult =
        await kycWorkflowPlugin.start(kidId!, email!, gwtId!, null);

    if (!workflowResult.code!.isNegative) {
      loadingAlertBox(context);

      var response = await getRPDInfoApi(
        context: context,
        json: {
          "digio_doc_id": workflowResult.documentId,
          "message": workflowResult.message,
          "txn_id": transactionId
        },
      );
      if (mounted) {
        Navigator.pop(context);
      }
      if (response != null) {
        // BankDetailsViaRPD['bank'] = response['details']['bank_name'] ?? "";
        // BankDetailsViaRPD['accno'] =
        //     response['details']['beneficiary_account_no'] ?? "";
        // BankDetailsViaRPD['micr'] = response['details']['micr'] ?? "";
        // BankDetailsViaRPD['ifsc'] = response['details']['ifsc'] ?? "";
        // BankDetailsViaRPD['branch'] = response['details']['branch'] ?? "";
        // BankDetailsViaRPD['address'] =
        //     response['details']['branch_address'] ?? "";
        // BankDetailsViaRPD['rpdaccstatus:'] =
        //     response['details']['status'] ?? "";
        // BankDetailsViaRPD['rpdstatus'] = response['rpdstatus'] ?? "";
        bankDetailsViaRPD = response;
        isRPDget = true;
      }
    } else {
      showSnackbar(context, workflowResult.message ?? "Some thing went wrong",
          Colors.red);
    }
    setState(() {});
  }

  /* 
  Purpose: This method is used get the bankdetails for DIGI RPD
  */

  getRPDInfoApi({required context, required json}) async {
    try {
      (json);
      var response = await CustomHttpClient.post("GetRPDinfo", json, context);

      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);

        if (json["status"] == "S") {
          return json;
        } else {
          showSnackbar(
              context, json["msg"] ?? "Some thing went wrong", Colors.red);
        }
      }
    } catch (e) {
      showSnackbar(
          context, exceptionShowSnackBarContent(e.toString()), Colors.red);
    }
  }

  /* 
  Purpose: This method is used for getting the response for mock Pay
  */

  getRPDMockPayApi({required context}) async {
    try {
      var response = await CustomHttpClient.get("rpdmockpay", context);
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        return json;
      }
    } catch (e) {
      showSnackbar(
          context, exceptionShowSnackBarContent(e.toString()), Colors.red);
    }
  }

  /* 
  Purpose: This method is used for validate the RPD get the Bank details for SETU RPD
  */

  validateRPDAPI({required context}) async {
    try {
      var response = await CustomHttpClient.get("valrpdreq", context);
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        if (json["status"] == "S") {
          return json;
        } else {
          showSnackbar(
              context, json["errmsg"] ?? "some thing went wrong", Colors.red);
        }
      }
    } catch (e) {
      showSnackbar(
          context, exceptionShowSnackBarContent(e.toString()), Colors.red);
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
      buttonFunc: () {
        if (linkType == "IFSC" && !_formKey.currentState!.validate()) {
          return;
        }

        if ((fetchBankDetails == null || fetchBankDetails!.bank.isEmpty) &&
            linkType == "IFSC") {
          showSnackbar(context, "Some thing went wrong", Colors.red);
          return;
        }
        insertBankDetails();
      },
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              previousBankDetails['bank'] != null
                  ? Visibility(
                      visible: linkType == "PREVIOUS" &&
                          previousBankDetails['bank'] != null,
                      replacement: GestureDetector(
                        onTap: () {
                          changeLinkType('PREVIOUS');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.0,
                              color: const Color.fromRGBO(179, 177, 177, 1),
                            ),
                            borderRadius: BorderRadius.circular(7.0),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Previous Data',
                              ),
                              CustomRadioButton(
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: const Color.fromRGBO(179, 177, 177, 1),
                          ),
                          borderRadius: BorderRadius.circular(7.0),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Previous Data",
                                ),
                                CustomRadioButton(
                                  color: Color(0xFF0965DA),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              dashPattern: [5, 3],
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0x7fc9f4e7),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_rounded,
                                          size: 29,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          previousBankDetails['bank'] ?? "",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        RichText(
                                          text: WidgetSpan(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.verified,
                                                  size: 15,
                                                  color: Colors.green,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text('Verified')
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Account Number : ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                previousBankDetails['accno'] ??
                                                    "",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "MICR : ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                previousBankDetails['micr'] ??
                                                    "",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
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
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Branch:  : ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                previousBankDetails['branch'] ??
                                                    "",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Address:  : ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                previousBankDetails[
                                                        'address'] ??
                                                    "",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400,
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
                          ],
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              // SizedBox(
              //   height: 10,
              // ),
              // GestureDetector(
              //     onTap: () {
              //       changeLinkType('UPI');
              //     },
              //     child: Container(
              //       padding: EdgeInsets.zero,
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(7.0),
              //         border: Border.all(
              //             width: 1.0,
              //             color: const Color.fromRGBO(9, 101, 218, 1)),
              //         color: Colors.white,
              //       ),
              //       child: Stack(
              //         children: [
              //           Positioned(
              //             child: ClipRRect(
              //               borderRadius: BorderRadius.only(
              //                 topLeft: Radius.circular(6.0),
              //               ),
              //               child: Image(
              //                 image: AssetImage('assets/images/flash_b5.png'),
              //                 // image: AssetImage('assets/images/flash_p.png'),
              //                 height: 20,
              //                 fit: BoxFit.cover,
              //               ),
              //             ),
              //           ),
              //           Container(
              //             padding: const EdgeInsets.all(20.0),
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Row(
              //                   mainAxisAlignment:
              //                       MainAxisAlignment.spaceBetween,
              //                   children: [
              //                     Text(
              //                       "Link Using UPI",
              //                       style:
              //                           TextStyle(fontWeight: FontWeight.bold),
              //                     ),
              //                     Row(
              //                       children: [
              //                         isRPDget && linkType == "UPI"
              //                             ? InkWell(
              //                                 onTap: () {
              //                                   changeLinkType("PREVIOUS");
              //                                   isRPDget = false;
              //                                   previousBankDetails =
              //                                       bankDetailsViaRPD;
              //                                   setState(() {});
              //                                 },
              //                                 child: Text(
              //                                   "Change Bank",
              //                                   style: TextStyle(
              //                                       color: Colors.blue),
              //                                 ))
              //                             : Text(''),
              //                         SizedBox(
              //                           width: 20,
              //                         ),
              //                         CustomRadioButton(
              //                           color: linkType == "UPI"
              //                               ? Color(0xFF0965DA)
              //                               : Colors.white,
              //                         )
              //                       ],
              //                     )
              //                   ],
              //                 ),
              //                 if (linkType == 'UPI') ...[
              //                   const SizedBox(height: 10.0),
              //                   const DottedLine(),
              //                   const SizedBox(
              //                     height: 10.0,
              //                   ),
              //                   !isRPDget
              //                       ? Row(
              //                           children: [
              //                             for (int index = 0;
              //                                 index < 4;
              //                                 index++)
              //                               InkWell(
              //                                 onTap: () {
              //                                   rpdAPI();
              //                                 },
              //                                 child: Container(
              //                                   width: 23,
              //                                   height: 23,
              //                                   margin: const EdgeInsets.only(
              //                                       right: 8.0),
              //                                   decoration: BoxDecoration(
              //                                     borderRadius:
              //                                         BorderRadius.circular(6),
              //                                     border: Border.all(
              //                                       width: 2.0,
              //                                       color: const Color.fromRGBO(
              //                                           195, 195, 195, 1),
              //                                     ),
              //                                   ),
              //                                   child: Image.asset(
              //                                     'assets/images/${images[index]}',
              //                                     fit: BoxFit.cover,
              //                                   ),
              //                                 ),
              //                               ),
              //                             const SizedBox(width: 8.0),
              //                             const Text(
              //                               'and more',
              //                             ),
              //                           ],
              //                         )
              //                       : isRPDget
              //                           ? Column(
              //                               children: [
              //                                 const Text(
              //                                   "Bank account details fetched through UPI transaction.",
              //                                 ),
              //                                 const SizedBox(
              //                                   height: 10.0,
              //                                 ),
              //                                 Container(
              //                                   padding: const EdgeInsets.only(
              //                                       top: 15.0, left: 30.0),
              //                                   decoration: BoxDecoration(
              //                                     borderRadius:
              //                                         BorderRadius.circular(10),
              //                                     gradient:
              //                                         const LinearGradient(
              //                                       begin: Alignment.topCenter,
              //                                       end: Alignment.bottomCenter,
              //                                       colors: [
              //                                         Color(0x4B2EEE9B),
              //                                         Color(0x00D9D9D9),
              //                                       ],
              //                                     ),
              //                                   ),
              //                                   child: Column(
              //                                     crossAxisAlignment:
              //                                         CrossAxisAlignment.start,
              //                                     children: [
              //                                       Icon(
              //                                         Icons
              //                                             .account_balance_rounded,
              //                                         size: 29,
              //                                       ),
              //                                       const SizedBox(
              //                                         height: 10,
              //                                       ),
              //                                       Text(
              //                                         bankDetailsViaRPD['bank'],
              //                                         style: TextStyle(
              //                                           fontSize: 12,
              //                                           fontWeight:
              //                                               FontWeight.w600,
              //                                         ),
              //                                       ),
              //                                       const SizedBox(
              //                                         height: 10,
              //                                       ),
              //                                       Row(
              //                                         children: [
              //                                           Column(
              //                                             crossAxisAlignment:
              //                                                 CrossAxisAlignment
              //                                                     .start,
              //                                             children: [
              //                                               Text(
              //                                                 "Account No:",
              //                                                 style: TextStyle(
              //                                                   fontSize: 10,
              //                                                   fontWeight:
              //                                                       FontWeight
              //                                                           .w500,
              //                                                 ),
              //                                               ),
              //                                               SizedBox(
              //                                                 height: 5,
              //                                               ),
              //                                               Text(
              //                                                 bankDetailsViaRPD[
              //                                                     'accno'],
              //                                                 style: TextStyle(
              //                                                   fontSize: 9,
              //                                                   fontWeight:
              //                                                       FontWeight
              //                                                           .w400,
              //                                                 ),
              //                                               ),
              //                                               SizedBox(
              //                                                 height: 15,
              //                                               ),
              //                                               Text(
              //                                                 "MICR Code",
              //                                                 style: TextStyle(
              //                                                   fontSize: 10,
              //                                                   fontWeight:
              //                                                       FontWeight
              //                                                           .w500,
              //                                                 ),
              //                                               ),
              //                                               SizedBox(
              //                                                 height: 5,
              //                                               ),
              //                                               Text(
              //                                                 bankDetailsViaRPD[
              //                                                     'micr'],
              //                                                 style: TextStyle(
              //                                                   fontSize: 9,
              //                                                   fontWeight:
              //                                                       FontWeight
              //                                                           .w400,
              //                                                 ),
              //                                               ),
              //                                             ],
              //                                           ),
              //                                           Expanded(
              //                                             child: Text(''),
              //                                           ),
              //                                           Column(
              //                                             crossAxisAlignment:
              //                                                 CrossAxisAlignment
              //                                                     .start,
              //                                             children: [
              //                                               Text(
              //                                                 "IFSC Code",
              //                                                 style: TextStyle(
              //                                                   fontSize: 10,
              //                                                   fontWeight:
              //                                                       FontWeight
              //                                                           .w500,
              //                                                 ),
              //                                               ),
              //                                               SizedBox(
              //                                                 height: 5,
              //                                               ),
              //                                               Text(
              //                                                 bankDetailsViaRPD[
              //                                                     'ifsc'],
              //                                                 style: TextStyle(
              //                                                   fontSize: 9,
              //                                                   fontWeight:
              //                                                       FontWeight
              //                                                           .w400,
              //                                                 ),
              //                                               ),
              //                                               SizedBox(
              //                                                 height: 15,
              //                                               ),
              //                                               Text(
              //                                                 "Branch",
              //                                                 style: TextStyle(
              //                                                   fontSize: 10,
              //                                                   fontWeight:
              //                                                       FontWeight
              //                                                           .w500,
              //                                                 ),
              //                                                 textAlign:
              //                                                     TextAlign
              //                                                         .start,
              //                                               ),
              //                                               SizedBox(
              //                                                 height: 5,
              //                                               ),
              //                                               Text(
              //                                                 bankDetailsViaRPD[
              //                                                     'branch'],
              //                                                 style: TextStyle(
              //                                                   fontSize: 9,
              //                                                   fontWeight:
              //                                                       FontWeight
              //                                                           .w400,
              //                                                 ),
              //                                               ),
              //                                             ],
              //                                           ),
              //                                           Expanded(
              //                                             child: Text(''),
              //                                           ),
              //                                         ],
              //                                       ),
              //                                     ],
              //                                   ),
              //                                 ),
              //                                 const SizedBox(
              //                                   height: 10,
              //                                 ),
              //                               ],
              //                             )
              //                           : Center(
              //                               child: CircularProgressIndicator(),
              //                             )
              //                 ]
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),),
              // Visibility(
              //   visible: linkType == 'UPI' && isRPDget,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const SizedBox(
              //         height: 10.0,
              //       ),
              //       const Text(
              //         "Account Type *",
              //       ),
              //       const SizedBox(
              //         height: 10.0,
              //       ),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         children: accountTypes
              //             .map(
              //               (accType) => Padding(
              //                 padding: const EdgeInsets.only(right: 10.0),
              //                 child: InkWell(
              //                   onTap: () =>
              //                       changeUpiBankType(accType["description"]),
              //                   child: AccountType(
              //                       txt: accType["description"],
              //                       accType: upiBankType),
              //                 ),
              //               ),
              //             )
              //             .toList(),
              //       )
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 15),
              GestureDetector(
                  onTap: () {
                    changeLinkType('IFSC');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Link Using IFSC',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                CustomRadioButton(
                                  color: linkType == "IFSC"
                                      ? Color(0xFF0965DA)
                                      : Colors.white,
                                )
                              ],
                            )
                          ],
                        ),
                        if (linkType == 'IFSC') ...[
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
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
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
                                                      CrossAxisAlignment.start,
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
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                      CrossAxisAlignment.start,
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
                                                      fetchBankDetails!.branch,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                      fetchBankDetails!.address,
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
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
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
                                    .toList()),
                          )
                        ],
                      ],
                    ),
                  )),
              const SizedBox(
                height: 15.0,
              ),
            ],
          ),
        ),
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
