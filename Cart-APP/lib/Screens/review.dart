import 'dart:collection';
import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:ekyc/Cookies/cookies.dart';
import 'package:ekyc/Custom%20Widgets/custom_button.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackbar.dart';
import 'package:ekyc/Custom%20Widgets/error_message.dart';
import 'package:ekyc/Custom%20Widgets/terms_text.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:esign_plugin/digio_config.dart';
import 'package:esign_plugin/environment.dart';
import 'package:esign_plugin/esign_plugin.dart';
import 'package:esign_plugin/gateway_event.dart';
import 'package:esign_plugin/service_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../API call/api_call.dart';
import '../Custom Widgets/Bank&Segment.dart';
import '../Custom Widgets/custom.dart';
import '../Custom Widgets/custom_check_box.dart';
import '../Custom Widgets/dematdetails.dart';
import '../Custom Widgets/fileupload.dart';
import '../Custom Widgets/ipv_page.dart';
import '../Custom Widgets/nominationpage.dart';
import '../Custom Widgets/pan_and_aadhar.dart';
import '../Custom Widgets/personal_inform.dart';
import '../Custom Widgets/stepwidget.dart';
import '../Model/route_model.dart';
import '../Model/total_api.dart';
import '../Nodifier/nodifierclass.dart';
import '../Route/route.dart' as route;
import '../Service/download_file.dart';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool isLoadingAddress = true;
  ScrollController scrollController = ScrollController();
  bool downArrowVisible = true;
  bool buttonEnable = true;
  List? proofOfAddressDropDownValue;
  Address? address;
  Personal? personalDetails;
  List<Nominearr> nomineeDetails = [];
  String cdslFlag = "";
  Bank? bankDetails;
  Dematandservices? dematandservices;
  Basicinfo? basicDetails;
  Ipv? ipv;
  Signeddoc? signedDoc;
  List<RouteModel> routerdata = [];
  List? checkImageDetails;
  List? signImageDetails;
  List? panImageDetails;
  List? incomeProofImageDetails;
  List incompletesteps = [];
  Map serviceData = {};
  List titles = [];
  List subTitles = [];
  List selectedTile = [];
  List brokerageHeading = [];
  List brokerageData = [];
  String disValue = '';
  String eDisValue = '';
  bool isLoading = true;
  String? didId;
  String? gwtId;
  String? phoneNo;
  String dpScheme = '';
  String settlement = "";
  bool downloading = false;
  bool downloadButtonClicked = false;
  bool pdfLoading = true;
  bool eSignLoading = false;
  String pdfErrorMsg = "";
  String pdfDocId = "";
  int count = 1;
  bool isTestUser = false;
  String stageName = "";
  Map bankData = {};
  bool isCheck = false;
  bool showReq = false;
  String? fileName;
  Uint8List? bytes;
  var _formKey = GlobalKey<FormState>();
  bool formIsValid = false;

  @override
  void initState() {
    getInitialData();
    super.initState();
  }

  /* 
  Purpose: This method is used to get the initail data from the api for all fields.
  */

  getInitialData() {
    ProviderClass providerData =
        Provider.of<ProviderClass>(context, listen: false);
    if (providerData.email == CustomHttpClient.testEmail &&
        providerData.mobileNo == CustomHttpClient.testMobileNo) {
      isTestUser = true;
      setState(() {});
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addressDetails();

      scrollController.addListener(() {
        downArrowVisible = scrollController.position.pixels ==
                scrollController.position.maxScrollExtent
            ? false
            : true;
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          buttonEnable = true;
        }
        if (mounted) {
          setState(() {});
        }
      });
    });
  }
  /* 
  Purpose: This method is used to get the address from the api. 6845646546
  */

  addressDetails() async {
    loadingAlertBox(context);
    !isTestUser && incompletesteps.isEmpty ? generatePDF() : null;
    var response = await getReviewDetails(context: context);
    if (response != null) {
      ReviewModel reviewModel = reviewModelFromJson(jsonEncode(response));
      basicDetails = reviewModel.basicinfo;
      address = reviewModel.address;
      personalDetails = reviewModel.personal;
      nomineeDetails = reviewModel.nominearr;
      cdslFlag = reviewModel.cdslflag;
      _tabController =
          TabController(length: nomineeDetails.length, vsync: this);
      bankDetails = reviewModel.bank;

      ipv = reviewModel.ipv;
      signedDoc = reviewModel.signeddoc;

      fetchData();
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }

    isLoadingAddress = false;
  }

  fetchFileData() async {
    if (pdfDocId.isEmpty) {
      isLoading = false;
      setState(() {});
      return;
    }
    try {
      var response =
          await fetchFile(context: context, id: pdfDocId, list: true);
      if (response != null) {
        fileName = response[0];
        bytes = response[1];
      }
    } catch (e) {}
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  checkFormValidOrNot(value) {
    if (isCheck) {
      bool formValid = _formKey.currentState!.validate();
      if (formIsValid != formValid) {
        formIsValid = formValid;
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      if (formIsValid) {
        formIsValid = false;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  /* 
  Purpose: This method is used to get the service and brokerage details from the api.
  */

  fetchData() async {
    Map? demantServeResponse = await getServeBrokerDetailsApi(context);

    if (demantServeResponse != null) {
      brokerageHeading = demantServeResponse['brokhead'];
      brokerageData = demantServeResponse['brokdata'];
      serviceData = demantServeResponse['service_map'] ?? {};
      bankData = demantServeResponse['bankinfo'] ?? {};
      titles.addAll(
          serviceData.values.map((element) => element['segement']).toList());
      List exchangeValues =
          serviceData.values.map((element) => element['exchange']).toList();

      List exchangenameLists = exchangeValues
          .map((sublist) =>
              sublist.map((exchange) => exchange['exchangename']).toList())
          .toList();
      subTitles = exchangenameLists.map((sublist) {
        return 'Trade in ${sublist.join(', ')}';
      }).toList();

      selectedTile = serviceData.values
          .map((element) =>
              element['selected'] == 'Y' ? element['segement'] : '')
          .toList();

      dpScheme = demantServeResponse['dematinfo']['dpschemedesc'];
      settlement = demantServeResponse['dematinfo']['runningAccSettlementDesc'];
      disValue = demantServeResponse['dematinfo']['dis'] == 'N' ? 'No' : 'Yes';
      eDisValue =
          demantServeResponse['dematinfo']['edis'] == 'Y' ? 'Yes' : 'No';
    }

    getRouteInfo();
  }

  /* 
  Purpose: This method is used to get the route name from the api for incomplete steps.
  */

  getRouteInfo() async {
    var response = await getRouteInfoInAPI(context: context);
    stageName = response['stagename'] ?? "";
    if (mounted) {
      Navigator.pop(context);
    }
    if (response != null) {
      routerdata = response["routerdata"] == null
          ? []
          : List.from(response["routerdata"]
              .map((routeDetails) => RouteModel.fromJson(routeDetails))
              .toList());
      incompletesteps = response["routerdata"]
          .where((element) =>
              element["routerstatus"] == 'N' &&
              element["routername"] != "ReviewDetails")
          .toList();

      personalDetails!.nominee == "Y" &&
              (nomineeDetails == null || nomineeDetails.isEmpty)
          ? incompletesteps
                  .any((element) => element["routername"] == "NomineeDetails")
              ? null
              : incompletesteps.add({"routername": "NomineeDetails"})
          : "";
      // serviceData.keys.any((element) =>
      //             serviceData[element]["selected"] == "Y" &&
      //             serviceData[element]["segement"] != "CASH AND MUTUAL FUND") &&
      //         signedDoc!.incomeid.isEmpty
      //     ? incompletesteps
      //             .any((element) => element["routername"] == "DocumentUpload")
      //         ? null
      //         : incompletesteps.add({"routername": "DocumentUpload"})
      //     : "";
      indexOfaddressRoute = routerdata.indexWhere(
          (element) => element.routername.toLowerCase().contains("address"));
      indexOfpersonalRoute = routerdata.indexWhere(
          (element) => element.routername.toLowerCase().contains("profile"));
      indexOfnomineeRoute = routerdata.indexWhere(
          (element) => element.routername.toLowerCase().contains("nominee"));
      indexOfbankRoute = routerdata.indexWhere(
          (element) => element.routername.toLowerCase().contains("bank"));
      indexOfipvRoute = routerdata.indexWhere(
          (element) => element.routername.toLowerCase().contains("ipv"));
      indexOfdematRoute = routerdata.indexWhere((element) =>
          element.routername.toLowerCase().contains("dematdetails"));
      indexOffileRoute = routerdata.indexWhere((element) =>
          element.routername.toLowerCase().contains("documentupload"));
      Map m = {};
      indexOfaddressRoute != -1 ? m[indexOfaddressRoute] = "address" : null;
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  int indexOfaddressRoute = -1;
  int indexOfpersonalRoute = -1;
  int indexOfnomineeRoute = -1;
  int indexOfbankRoute = -1;
  int indexOfipvRoute = -1;
  int indexOfdematRoute = -1;
  int indexOffileRoute = -1;

  /* 
  Purpose: This method is used for generating PDF.
  */

  generatePDF() async {
    pdfLoading = true;
    setState(() {});
    var response = await generatePdf(context: context);
    if (response is Map) {
      pdfDocId = response["docid"];
      pdfLoading = false;
      pdfErrorMsg = "";
      if (downloadButtonClicked) {
        downloadPDFFile();
      }

      setState(() {});
      if (eSignLoading) {
        getUserDetails();
      } else {}
    } else if (response is String) {
      pdfLoading = false;
      downloadButtonClicked = false;
      pdfErrorMsg = response;
      if (eSignLoading) {
        Navigator.pop(context);
      }
      if (mounted) {
        setState(() {});
      }
    }
    !isTestUser && incompletesteps.isEmpty ? fetchFileData() : null;
  }
  /* 
  Purpose: This method is used to user details from the api.
  */

  getUserDetails() async {
    eSignLoading = false;
    if (cdslFlag == "Y") {
      openPDF();
    } else {
      print("DIGIO");
      var response = await getUserDetailsForEsignInAPI(context: context);
      if (response != null) {
        didId = response["docid"];
        gwtId = response["accessToken"];
        phoneNo = response["identifier"];

        if (didId != null &&
            didId!.isNotEmpty &&
            gwtId != null &&
            gwtId!.isNotEmpty &&
            phoneNo != null &&
            phoneNo!.isNotEmpty) {
          proceedTOEsign();
          return;
        } else {
          showSnackbar(context, "Some time went wrong", Colors.red);
        }
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  openPDF() {
    Navigator.pop(context);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return PopScope(
              canPop: false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.all(16.0),
                content: Form(
                  key: _formKey,
                  onChanged: () => checkFormValidOrNot(""),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showReq = false;
                              isCheck = false;
                              setState(() {});
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Review Form",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Click Image to Open",
                              maxLines: 3,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: 145.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3.0,
                                    blurRadius: 5.0,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: pdfDocId.isEmpty
                                  ? Center(child: Text('File Not Found'))
                                  : fileName != null && bytes != null
                                      ? (fileName is String &&
                                              fileName!
                                                  .toLowerCase()
                                                  .endsWith('.pdf'))
                                          ? PdfViewerWithName(
                                              pdfPath: fileName!,
                                              id: bytes!,
                                              title: "Review Form")
                                          : const Center(child: Text(''))
                                      : LoadingWidget(
                                          id: pdfDocId,
                                          title: "Review Form",
                                        ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Declaration Text
                      CustomCheckBox(
                          isCheck: isCheck,
                          showReq: showReq,
                          onChange: () {
                            isCheck = !isCheck;
                            showReq = isCheck ? false : true;
                            setState(() {});
                          },
                          child: TermsText()),
                      // Text(
                      //   "I hereby declare that the being updated here belongs to me. I authorize Fortune Capital Services Private Limited to use this to send me any information/alert/email. I am aware this change will affect the trading and demat account that I hold with Fortune Capital Services Private Limited.",
                      //   style: Theme.of(context).textTheme.bodyMedium,
                      // ),
                      SizedBox(height: 10),
                      // Update Info Text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Text(
                              "Updating will take up to 24 hours to reflect (depending on the timeline takes to update exchanges and depositories).",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.blue[600],
                                  ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 16),
                      // Continue Button
                      Center(
                        child: CustomButton(
                          buttonFunc: () {
                            if (!showReq) {
                              showReq = true;
                              setState(() {});
                            }
                            if (isCheck) {
                              Navigator.pop(context);
                              proceedTOEsignCDSL();
                            }
                            // Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ));
        });
      },
    );
  }

  proceedTOEsignCDSL() {
    // var cdslUrl = "http://192.168.2.70:28595/api/esignFormrequestcdsl";
    var cdslUrl = "http://192.168.70.79:28595/api/esignFormrequestcdsl";
    Navigator.pushNamed(context, route.esignHtml,
        arguments: {"url": cdslUrl, "routeName": route.review}).then(
      (value) async {
        loadingAlertBox(context);
        var response = await checkCDSLEsign(context: context);
        if (response != null) {
          if (response['status'] == "S") {
            if (response["docId"] != "") {
              var response = await savecdslesign(context: context);
              print("response");
              print(response);
              if (response != null) {
                getNextRoute(context);
              } else {
                if (mounted) {
                  Navigator.pop(context);
                  showSnackbar(context, "Some time went wrong", Colors.red);
                }
              }
            } else {
              Navigator.pop(context);
            }
          }
        }
      },
    );
  }

  /* 
  Purpose: This method is used to download the pdf file.
  */

  downloadPDFFile() async {
    try {
      downloadButtonClicked = false;
      downloading = true;
      setState(() {});
      // List? pdfFileDetails = pdfDocId.isNotEmpty
      //     ? await fetchFile(context: context, id: pdfDocId, list: true)
      //     : null;
      // if (pdfFileDetails != null) {
      //   await downloadFile(pdfFileDetails[0].toString().split(".").first,
      //       pdfFileDetails[1], pdfFileDetails[0], context);
      // }
      await downloadFile(
          fileName.toString().split(".").first, bytes!, fileName, context);
      downloading = false;
      setState(() {});
    } catch (e) {
      showSnackbar(context, "Some thing went wrong", Colors.red);
      downloading = false;
      setState(() {});
    }
  }

  /* 
  Purpose: This method is used for doing esign using digio.
  */

  proceedTOEsign() async {
    WidgetsFlutterBinding.ensureInitialized();
    var digioConfig = DigioConfig();
    digioConfig.theme.primaryColor = "#32a83a";
    digioConfig.environment = Environment
        .SANDBOX; // SANDBOX is testing server, PRODUCTION is production server
    digioConfig.serviceMode = ServiceMode.OTP; // OTP, FP, IRIS
    final _esignPlugin = EsignPlugin(digioConfig);
    _esignPlugin.setGatewayEventListener((GatewayEvent? gatewayEvent) {});
    HashMap<String, String> additionalData = HashMap<String, String>();
    SharedPreferences sref = await SharedPreferences.getInstance();
    String cookies = sref.getString("cookies") ?? "";
    additionalData['unique_request_id'] =
        cookies.split(" ")[0].split("=")[1].split(";")[0];
    final esignResult =
        await _esignPlugin.start(didId!, phoneNo!, gwtId!, additionalData);

    if (!esignResult.code!.isNegative) {
      var response =
          await saveEsignInAPI(context: context, digid: esignResult.documentId);

      response != null
          ? getNextRoute(context)
          : mounted
              ? Navigator.pop(context)
              : null;
    } else {
      showSnackbar(
          context, esignResult.message ?? "Some thing went wrong", Colors.red);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /* 
  Purpose: This method is used to get the next route name from the api.
  */

  getNextRoute(context) async {
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.review],
      "routeraction": "Next"
    });

    if (mounted) {
      Navigator.pop(context);
    }

    if (response != null) {
      Navigator.pushNamed(context, response["endpoint"]);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /* 
  Purpose: This method is used to enable the download button when completion of genrating pdf.
  */

  downloadButtonFunc() {
    downloadButtonClicked = true;
    setState(() {});
    if (pdfLoading) {
      return;
    }
    if (pdfErrorMsg.isNotEmpty) {
      if (count != 2) {
        count = 2;
        setState(() {});
        generatePDF();
      } else {
        showSnackbar(context, pdfErrorMsg, Colors.red);
        downloadButtonClicked = false;
      }
      setState(() {});
      return;
    }
    downloadPDFFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StepWidget(
          endPoint: route.review,
          title: "Review",
          title1: "Review your details",
          subTitle: "Carefully review and confirm your details.",
          scrollController: scrollController,
          dowanArrow: downArrowVisible,
          isReviewPage: true,

          // arrowFunc: ,
          buttonText: 'Proceed to E-Sign',
          buttonFunc: routerdata == null || routerdata.isEmpty || !buttonEnable
              ? null
              : () {
                  if (incompletesteps.isNotEmpty) {
                    showSnackbar(context,
                        "Please complete the incomplete fields", Colors.red);
                    return;
                  }
                  loadingAlertBox(context);
                  eSignLoading = true;
                  setState(() {});

                  if (isTestUser) {
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    Navigator.pushNamedAndRemoveUntil(context,
                        route.congratulationTest, (route) => route.isFirst);
                    return;
                  }
                  if (pdfLoading) {
                    return;
                  }
                  if (pdfErrorMsg.isNotEmpty) {
                    if (count != 2) {
                      count = 2;
                      setState(() {});
                      generatePDF();
                    } else {
                      Navigator.pop(context);
                      showSnackbar(context, pdfErrorMsg, Colors.red);
                    }
                    return;
                  }
                  getUserDetails();
                },
          children: [
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: routerdata == null ||
                          routerdata.isEmpty ||
                          basicDetails == null
                      ? []
                      : [
                          Padding(
                            padding:
                                const EdgeInsets.all(12.0).copyWith(top: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15.0),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    borderRadius: BorderRadius.circular(6.52),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromRGBO(217, 217, 217, 1),
                                        spreadRadius: 3.0,
                                        blurRadius: 5.0,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0)),
                                              child: SvgPicture.asset(
                                                "assets/images/person.svg",
                                                height: 25.0,
                                                width: 25.0,
                                              )),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                        'assets/images/message.png',
                                                        height: 15.0,
                                                        width: 15.0),
                                                    const SizedBox(width: 10.5),
                                                    Expanded(
                                                      child: !isLoadingAddress &&
                                                              basicDetails !=
                                                                  null
                                                          ? Text(basicDetails!
                                                              .emailid)
                                                          : const Text(""),
                                                    ),
                                                    // const SizedBox(width: 10.0),
                                                  ],
                                                ),
                                                const SizedBox(height: 5.0),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                        'assets/images/phone.png',
                                                        height: 16.0,
                                                        width: 16.0),
                                                    const SizedBox(width: 10.0),
                                                    Expanded(
                                                        child: !isLoadingAddress &&
                                                                basicDetails !=
                                                                    null
                                                            ? Text(basicDetails!
                                                                .mobileno)
                                                            : const Text("")),
                                                    // a
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Visibility(
                                          visible: !isTestUser,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    width: 44.0,
                                                  ),
                                                  GestureDetector(
                                                    onTap:
                                                        downloadButtonClicked ||
                                                                downloading
                                                            ? null
                                                            : () {
                                                                if (incompletesteps
                                                                    .isNotEmpty) {
                                                                  showSnackbar(
                                                                      context,
                                                                      "Please complete the incomplete fields",
                                                                      Colors
                                                                          .red);
                                                                  return;
                                                                }
                                                                downloadButtonFunc();
                                                              },
                                                    child: downloadButtonClicked ||
                                                            downloading
                                                        ? Container(
                                                            height: 30.0,
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6)),
                                                            child: Row(
                                                              children: [
                                                                Transform.scale(
                                                                  scale: 0.5,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5.0,
                                                                ),
                                                                Text(
                                                                  "PDF GENERATING",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5.0,
                                                                ),
                                                              ],
                                                            ))
                                                        : Image.asset(
                                                            "assets/images/Download Form.png",
                                                            width: 150.0,
                                                          ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const DottedLine(),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Visibility(
                            visible: incompletesteps.isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: DottedBorder(
                                color: Colors.amber,
                                padding: EdgeInsets.zero,
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(6),
                                dashPattern: [5, 3],
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 60,
                                  padding: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      gradient: LinearGradient(colors: [
                                        Colors.amber,
                                        Colors.amber.withOpacity(0.15),
                                      ], stops: [
                                        0,
                                        0.02
                                      ])),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 5.0),
                                      Icon(
                                        size: 30,
                                        Icons.warning,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Flexible(
                                        child: Text(
                                          "Oops! the following stage is incomplete ${incompletesteps.map((e) => e["routername"]).toList().join(", ") ?? ""}.Please complete these stages and then proceed.",
                                          style: TextStyle(
                                              color: Colors.amber[700],
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          ...routerdata
                              .map((e) => widgets(e.routername.toLowerCase())),
                          const SizedBox(height: 10.0),
                        ],
                ),
              ],
            ),
          ]),
    );
  }

  Widget widgets(routername) {
    if (routername.toLowerCase().contains("address")) {
      return indexOfaddressRoute == -1
          ? SizedBox()
          : CustomExpansionTile(
              routeDetails: routerdata[indexOfaddressRoute],
              notShowEditButton:
                  !(address?.sourceofaddress.toLowerCase().contains("manual") ??
                      false),
              currentStatus: ApplicationStage.completed,
              text: "$indexOfaddressRoute",
              title: 'PAN & Address Details',
              children: [
                !isLoadingAddress
                    ? PanAadhaarDetail(
                        routeDetails: routerdata[indexOfaddressRoute],
                        pan: basicDetails!.panno,
                        name: basicDetails!.nameasperpan,
                        dob: basicDetails!.dob,
                        proofType: address?.proofofaddresstype ?? "",
                        sourceOfAddress: address!.sourceofaddress,
                        permanentAddress:
                            "${address!.peraddress1}, ${address!.peraddress2}, ${address!.peraddress3.isNotEmpty ? "${address!.peraddress3}, " : ""}${address!.percity}, ${address!.perstate}, ${address!.percountry}, ${address!.perpincode}",
                        correspondenceAddress:
                            "${address!.coraddress1}, ${address!.coraddress2}, ${address!.coraddress3.isNotEmpty ? "${address!.coraddress3}, " : ""}${address!.corcity}, ${address!.corstate}, ${address!.corcountry}, ${address!.corpincode}, ",
                        perproofexpirydate: address!.perproofexpirydate,
                        perproofdateofisu: address!.perdate,
                        perproofplaceofisu: address!.perpalceofissue,
                        proofNo: address!.perproofno,
                        proofFileId1: address!.docid1,
                        proofFileId2: address!.docid2,
                        addressType1: address!.addresstype1,
                        addressType2: address!.addresstype2,
                        coradrsproofisudate: address!.coradrsproofisudate,
                        coradrsproofname: address!.coradrsproofname,
                        coradrsproofno: address!.coradrsproofno,
                        coradrsproofplaceisu: address!.coradrsproofplaceisu,
                        cordocid1: address!.cordocid1,
                        cordocid2: address!.cordocid2,
                        corproofexpirydate: address!.corproofexpirydate,
                      )
                    : const PanAadhaarDetail(
                        name: "",
                        dob: "",
                        pan: "",
                        sourceOfAddress: "",
                        proofType: "",
                        permanentAddress: "",
                        correspondenceAddress: "",
                        perproofexpirydate: "",
                        perproofdateofisu: "",
                        perproofplaceofisu: "",
                        proofFileId1: "",
                        proofFileId2: "",
                        proofNo: "",
                        addressType1: "",
                        addressType2: "",
                        coradrsproofisudate: "",
                        coradrsproofname: "",
                        coradrsproofno: "",
                        coradrsproofplaceisu: "",
                        cordocid1: "",
                        cordocid2: "",
                        corproofexpirydate: "",
                      )
              ],
            );
    } else if (routername.toLowerCase().contains("profile")) {
      return indexOfpersonalRoute == -1
          ? SizedBox()
          : CustomExpansionTile(
              routeDetails: routerdata[indexOfpersonalRoute],
              currentStatus: ApplicationStage.completed,
              text: "$indexOfpersonalRoute",
              title: 'Profile Details',
              children: [
                PersonalDetails(
                  routeDetails: routerdata[indexOfpersonalRoute],
                  emailOwnerName: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.emailownername
                      : "",
                  phoneOwnerName: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.phoneownername
                      : "",
                  occuOthers: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.otheroccupation
                      : " ",
                  eduOthers: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.educationothers
                      : "",
                  mobileBelongs: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.mobilenobelongsto
                      : "",
                  mailBelongs: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.emailidbelongsto
                      : "",
                  phone: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.mobileno
                      : "",
                  motherName: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.mothername
                      : '',
                  gender: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.gender
                      : "",
                  fatherName: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.fathername
                      : '',
                  experiance: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.tradingexposed
                      : '',
                  email: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.emailid
                      : '',
                  education: !isLoadingAddress
                      ? personalDetails!.educationqualification
                      : '',
                  income: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.annualincome
                      : "",
                  maritalStatus: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.maritalstatus
                      : "",
                  occupation: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.occupation
                      : "",
                  pastActions: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.pastActions
                      : "",
                  pastActionsDesc: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.pastActionsDesc
                      : "",
                  dealSubBroker: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.dealSubBroker
                      : "",
                  dealSubBrokerDesc:
                      !isLoadingAddress && personalDetails != null
                          ? personalDetails!.dealSubBrokerDesc
                          : "",
                  fatcaDeclaration: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.fatcaDeclaration
                      : "",
                  fatcaTaxExempt: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.fatcaTaxExempt
                      : "",
                  fatcaTaxExemptReason:
                      !isLoadingAddress && personalDetails != null
                          ? personalDetails!.fatcaTaxExemptReason
                          : "",
                  taxIdendificationNumber:
                      !isLoadingAddress && personalDetails != null
                          ? personalDetails!.taxIdendificationNumber
                          : "",
                  residenceCountry: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.residenceCountry
                      : "",
                  placeofBirth: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.placeofBirth
                      : "",
                  countryofBirth: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.countryofBirth
                      : "",
                  foreignAddress1: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.foreignAddress1
                      : "",
                  foreignAddress2: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.foreignAddress2
                      : "",
                  foreignAddress3: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.foreignAddress3
                      : "",
                  foreignCity: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.foreignCity
                      : "",
                  foreignState: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.foreignState
                      : "",
                  foreignCountry: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.foreignCountry
                      : "",
                  foreignPincode: !isLoadingAddress && personalDetails != null
                      ? personalDetails!.foreignPincode
                      : "",
                )
              ],
            );
    } else if (routername.toLowerCase().contains("nominee")) {
      return indexOfnomineeRoute == -1
          ? SizedBox()
          : CustomExpansionTile(
              routeDetails: routerdata[indexOfnomineeRoute],
              currentStatus: ApplicationStage.completed,
              text: "$indexOfnomineeRoute",
              title: 'Nominee Details',
              children: isLoadingAddress
                  ? [
                      NominationPage(
                          scrollController: scrollController,
                          nominee: Nominearr(
                              guardianplaceofissue: "",
                              guardianproofdateofissue: "",
                              guardianproofexpriydate: "",
                              guardiantitle: "",
                              nomineeplaceofissue: "",
                              nomineeproofdateofissue: "",
                              nomineeproofexpriydate: "",
                              nomineetitle: "",
                              nomineename: "",
                              nomineerelationship: "",
                              nomineeshare: "",
                              nomineedob: "",
                              nomineeaddress1: "",
                              nomineeaddress2: "",
                              nomineeaddress3: "",
                              nomineecity: "",
                              nomineestate: "",
                              nomineecountry: "",
                              nomineepincode: "",
                              nomineemobileno: "",
                              nomineeemailid: "",
                              nomineeproofofidentity: "",
                              nomineeproofnumber: "",
                              nomineefileuploaddocids: "",
                              nomineefilename: "",
                              guardianname: "",
                              guardianrelationship: "",
                              guardianaddress1: "",
                              guardianaddress2: "",
                              guardianaddress3: "",
                              guardiancity: "",
                              guardianstate: "",
                              guardiancountry: "",
                              guardianpincode: "",
                              guardianmobileno: "",
                              guardianemailid: "",
                              guardianproofofidentity: "",
                              guardianproofnumber: "",
                              guardianfileuploaddocids: "",
                              guardianfilename: ""),
                          name: "",
                          dob: "",
                          proofNo: "",
                          city: "",
                          state: "",
                          pinCode: "",
                          nomineeProof: "",
                          nominRelation: "")
                    ]
                  : nomineeDetails!.isEmpty
                      ? []
                      : nomineeDetails!.length == 1
                          ? [
                              NomineeNewPage(
                                nominee: nomineeDetails![0],
                                scrollController: scrollController,
                                routeDetails: routerdata[indexOfnomineeRoute],
                              ),
                            ]
                          : [
                              Column(
                                children: [
                                  ErrorMessageContainer(
                                    routeDetails:
                                        routerdata[indexOfnomineeRoute],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: TabBar(
                                      indicatorColor:
                                          Theme.of(context).colorScheme.primary,
                                      labelColor: Colors.black,
                                      controller: _tabController,
                                      tabs: [
                                        ...nomineeDetails!
                                            .map((e) => Tab(
                                                  text:
                                                      'Nominee ${nomineeDetails!.indexOf(e) + 1}',
                                                ))
                                            .toList()
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 300.0,
                                    width:
                                        MediaQuery.of(context).size.width - 50,
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: nomineeDetails!
                                          .map((nominee) => NomineeNewPage(
                                                scrollController:
                                                    scrollController,
                                                nominee: nominee,
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
            );
    } else if (routername.toLowerCase().contains("bank")) {
      return indexOfbankRoute == -1
          ? SizedBox()
          : CustomExpansionTile(
              routeDetails: routerdata[indexOfbankRoute],
              currentStatus: ApplicationStage.completed,
              text: "$indexOfbankRoute",
              title: 'Bank Details',
              children: [
                BankSegment(
                  routeDetails: routerdata[indexOfbankRoute],
                  address: !isLoadingAddress && bankDetails != null
                      ? bankDetails!.bankaddress
                      : '',
                  accno: !isLoadingAddress && bankDetails != null
                      ? bankDetails!.accountno
                      : "",
                  bankName: !isLoadingAddress && bankDetails != null
                      ? bankDetails!.bankname
                      : "",
                  branch: !isLoadingAddress && bankDetails != null
                      ? bankDetails!.bankbranch
                      : "",
                  ifsc: !isLoadingAddress && bankDetails != null
                      ? bankDetails!.ifsc
                      : "",
                  micr: !isLoadingAddress && bankDetails != null
                      ? bankDetails!.micr
                      : "",
                  acctype: !isLoadingAddress && bankDetails != null
                      ? bankDetails!.acctype
                      : '',
                )
              ],
            );
    } else if (routername.toLowerCase().contains("dematdetails")) {
      return indexOfdematRoute == -1
          ? SizedBox()
          : CustomExpansionTile(
              routeDetails: routerdata[indexOfdematRoute],
              currentStatus: ApplicationStage.completed,
              text: "$indexOfdematRoute",
              title: 'Demat Details ',
              stageName: stageName,
              bankData: bankData,
              children: [
                DematDetails(
                  routeDetails: routerdata[indexOfdematRoute],
                  scheme: !isLoading ? dpScheme : '',
                  dis: !isLoading ? disValue : '',
                  edis: !isLoading ? eDisValue : '',
                  settlement: !isLoading ? settlement : '',
                  titles: titles,
                  subTitles: subTitles,
                  selectedTile: selectedTile,
                  scrollController: scrollController,
                  brokerageData: brokerageData,
                  brokerageHeading: brokerageHeading,
                )
              ],
            );
    } else if (routername.toLowerCase().contains("ipv")) {
      return indexOfipvRoute == -1
          ? SizedBox()
          : CustomExpansionTile(
              routeDetails: routerdata[indexOfipvRoute],
              currentStatus: ApplicationStage.completed,
              text: "$indexOfipvRoute",
              title: 'IPV',
              children: [
                IPVPage(
                  signatureId:
                      !isLoadingAddress && ipv != null ? ipv!.signatureid : "",
                  routeDetails: routerdata[indexOfipvRoute],
                  imageId:
                      !isLoadingAddress && ipv != null ? ipv!.imagedocid : "",
                  videoId:
                      !isLoadingAddress && ipv != null ? ipv!.videodocid : "",
                  otp: !isLoadingAddress && ipv != null ? ipv!.ipvotp : "",
                )
              ],
            );
    } else if (routername.toLowerCase().contains("documentupload")) {
      return indexOffileRoute == -1
          ? const SizedBox()
          : CustomExpansionTile(
              routeDetails: routerdata[indexOffileRoute],
              currentStatus: ApplicationStage.completed,
              text: "$indexOffileRoute",
              title: 'Document Upload',
              onChageExpand: (value) {
                if (!value) buttonEnable = true;
                setState(() {});
              },
              children: [
                  !isLoadingAddress
                      ? FileUploadContainer(
                          signflag: signedDoc!.signflag,
                          routeDetails: routerdata[indexOffileRoute],
                          proofType: signedDoc!.incometype,
                          chequeLeafId: signedDoc!.checkleafid,
                          incomeImageId: signedDoc!.incomeid,
                          panImageId: signedDoc!.panid,
                          signImageId: signedDoc!.signiid,
                        )
                      : FileUploadContainer()
                ]);
    } else {
      return SizedBox();
    }
  }
}
