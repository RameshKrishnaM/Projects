import 'package:ekyc/Cookies/cookies.dart';
import 'package:ekyc/Custom%20Widgets/alertbox.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackBar.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../API%20call/api_call.dart';
import '../Custom%20Widgets/StepWidget.dart';
import '../Screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Custom Widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../Custom Widgets/custom_radio_button.dart';
import '../Route/route.dart' as route;

class Address extends StatefulWidget {
  const Address({super.key});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  // FormValidateNodifier buttonEnableNodifier =
  //     FormValidateNodifier({"addressType": null});
  // RadioButtonNodifier radioButtonNodifier = RadioButtonNodifier();
  String? addressType = "digiLocker";
  String? kraName = "";
  String? digilockerame = "";
  String? kraPerAaddress;
  String? digiLockerAadress;
  Map? address;
  Map? digiLockerAddress;
  String? kraProof = "";
  String? digiLockerProof = "";
  bool getKRADataBase = false;
  bool manualOption = false;
  bool allowModification = false;
  bool getDIgiLockerDatabase = false;
  ScrollController scrollController = ScrollController();
  bool isLoading = true;

  getAddressStatus() async {
    loadingAlertBox(context);
    var response = await getAddressStatusAPI(context: context);
    print("address status $response");
    if (response != null) {
      // print("adresss_screen response-----$response");
      manualOption = response["manualoption"] == "Y" ? true : false;
      allowModification = response["allowmodification"] == "Y" ? true : false;
      Provider.of<Postmap>(context, listen: false)
          .changeAllowModification(allowModification);

      if (response["addrstatus"] == "U" || response["addrstatus"] == "I") {
        getAddress();
      } else if (response["addrstatus"] == "") {
        getKraPanSoap();
      }
      return;
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
      if (mounted) {
        isLoading = false;
        setState(() {});
      }
    }
  }

  getAddress() async {
    var response = await getAddressAPI(context: context);
    // print("get address $response");

    if (mounted) {
      Navigator.pop(context);
    }
    // print("response----------$response");

    if (response != null) {
      // print("response----------$response");
      // print(response);
      if (response["soa"].toString().toLowerCase().contains("manual")) {
        Navigator.pushReplacementNamed(context, route.manualEntry,
            arguments: response);
      } else if (response["soa"]
          .toString()
          .toLowerCase()
          .contains("digilocker")) {
        Navigator.pushReplacementNamed(context, route.digiLocker,
            arguments: {"address": response});
      } else if (response["soa"].toString().toLowerCase().contains("kra")) {
        address = response;
        kraName = response["name"] ?? "";
        kraPerAaddress =
            "${response["peradrs1"] + ", " + response["peradrs2"] + ", " + response["peradrs3"] + ", " + response["percity"] + ", " + response["perpincode"] + ", " + response["perstate"] + ", " + response["percountry"]}";
        kraProof = response["peradrsproofname"];
        addressType = "kyc";
      }
    }
    isLoading = false;
    setState(() {});
  }

  getKraPanSoap() async {
    var response = await getPanAddressAPI(context: context);
    print("kranljdh $response");

    // print("kra $response");
    if (mounted) {
      Navigator.pop(context);
    }
    isLoading = false;
    if (response is Map) {
      address = response;
      kraName = response["name"] ?? "";
      kraPerAaddress =
          "${response["peradrs1"] + ", " + response["peradrs2"] + ", " + response["peradrs3"] + ", " + response["percity"] + ", " + response["perpincode"] + ", " + response["perstate"] + ", " + response["percountry"]}";
      kraProof = response["peradrsproofname"];
      // kraProof = "PAN";
      addressType = "kyc";
      if (kraProof!.trim().toLowerCase() != "aadhaar") {
        getdigiLockerAddress();
      }
      getKRADataBase = true;
    } else if (response == "") {
      getdigiLockerAddress();
    }

    if (mounted) {
      setState(() {});
    }
  }

  getdigiLockerAddress() async {
    loadingAlertBox(context);
    var response = await getDigiLockerAddressAPI(context: context);
    print("digilocker $response");

    // print("kra $response");
    if (mounted) {
      Navigator.pop(context);
    }
    if (response is Map) {
      digiLockerAddress = response;
      digilockerame = response["name"] ?? "";
      digiLockerAadress =
          "${response["peradrs1"] + ", " + response["peradrs2"] + ", " + response["peradrs3"] + ", " + response["percity"] + ", " + response["perpincode"] + ", " + response["perstate"] + ", " + response["percountry"]}";
      digiLockerProof = response["peradrsproofname"];
      print(response["peradrsproofname"]);
      if (response["peradrs1"] != null &&
          response["peradrs1"].toString().trim().isNotEmpty) {
        getDIgiLockerDatabase = true;
      }
    } else if (response != null) {}

    if (mounted) {
      setState(() {});
    }
  }

  postKycInfo() async {
    loadingAlertBox(context);
    address!.remove("status");
    var response = await insertKycInfoAPI(json: address, context: context);
    if (mounted) {
      Navigator.pop(context);
    }
    if (response != null) {
      getNextRoute(context);
    }
  }

  postDigiInfo() async {
    loadingAlertBox(context);
    digiLockerAddress!.remove("status");
    var response =
        await insertDigiInfoAPI(json: digiLockerAddress, context: context);

    if (mounted) {
      Navigator.pop(context);
    }
    if (response != null) {
      getNextRoute(context);
    }
  }

  getNextRoute(context) async {
    loadingAlertBox(context);
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.address],
      "routeraction": "Next"
    });
    if (mounted) {
      Navigator.pop(context);
    }

    if (response != null) {
      Navigator.pushNamed(context, response["endpoint"]);
    }
  }

  getDigiLockerUrl() async {
    // DTCPB2501R
    loadingAlertBox(context);
    var response = await getDigiLockerUrlAPI(context: context);
    if (mounted) {
      Navigator.pop(context);
    }
    if (response != null) {
      // https: //digilocker.flattrade.in/rd/digilocker
      // var url = response["redirecturl"];
      // // print(response["redirecturl"]);

      // // );
      // // var url = Uri.parse("ekyc:");
      // // print(url1.toString());

      // // print("url = $url");

      // if (await canLaunchUrlString(url)) {
      //   launchUrlString(
      //     url,
      //   );
      // }
      // await Future.delayed(Duration(seconds: 3));
      // print("aaaaa");
      // launchUrlString("ekyc://bankScreen");
      // await closeInAppWebView();
      // print(response);
      // print(response["url"]);
      Navigator.pushNamed(context, route.esignHtml,
          arguments: {"url": response["redirecturl"]});
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAddressStatus();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print("addressType $addressType");
    // print("con1 ${kraName != null}");
    // print("co2 ${kraPerAaddress != null}");
    return StepWidget(
        endPoint: route.address,
        step: 1,
        title: "PAN & Address",
        title1: "Address Verification",
        subTitle: "Verify address using KRA, DigiLocker",
        scrollController: scrollController,
        buttonFunc: () async {
          // print(
          //     "mobile ${Provider.of<Postmap>(context, listen: false).mobileNo}");
          // print("email ${Provider.of<Postmap>(context, listen: false).email}");
          if (addressType == "manual") {
            Navigator.pushNamed(context, route.manualEntry);
          } else if (addressType == "kyc") {
            getKRADataBase ? postKycInfo() : getNextRoute(context);
          } else if (addressType == "digiLocker" &&
              Provider.of<Postmap>(context, listen: false).mobileNo ==
                  CustomHttpClient.testMobileNo &&
              Provider.of<Postmap>(context, listen: false).email ==
                  CustomHttpClient.testEmail) {
            showSnackbar(context, "Select the Address type", Colors.red);
          } else if (addressType == "digiLocker" && getDIgiLockerDatabase) {
            getDIgiLockerDatabase ? postDigiInfo() : getNextRoute(context);
          } else {
            getDigiLockerUrl();
          }
        },
        children: isLoading
            ? []
            : [
                // ...getTitleANdSubTitleWidget("PAN & Address",
                //     "Address verification using KRA,DigiLocker  ", context),
                Visibility(
                    visible: kraName != null && kraPerAaddress != null,
                    child: Column(
                      children: [
                        GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                    width: 1.5,
                                    color: addressType == "kyc"
                                        ? Color.fromRGBO(50, 186, 124, 1)
                                        : const Color.fromRGBO(
                                            217, 217, 217, 1))),
                            child: Column(children: [
                              Row(
                                children: [
                                  SizedBox(width: 18.0),
                                  Expanded(
                                    child: Text(
                                      "We Found Your KYC",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  CustomRadioButton(
                                    color: addressType == "kyc"
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                ],
                              ),
                              Visibility(
                                  visible: addressType == "kyc",
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(
                                        kraName!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w700,
                                            color: Color.fromRGBO(
                                                111, 105, 105, 1)),
                                        // style: TextStyle(
                                        //     fontSize: 14.0,
                                        //     fontWeight: FontWeight.w500,
                                        //     color:
                                        //         Color.fromRGBO(111, 105, 105, 1)),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Text.rich(
                                          textAlign: TextAlign.center,
                                          TextSpan(children: <InlineSpan>[
                                            TextSpan(
                                                text: kraPerAaddress ?? ""),
                                            WidgetSpan(
                                                child: SizedBox(
                                              width: 10.0,
                                            )),
                                            WidgetSpan(
                                                child: allowModification
                                                    ? GestureDetector(
                                                        child: SvgPicture.asset(
                                                          "assets/images/VectorEdit.svg",
                                                          color: Colors.blue,
                                                        ),
                                                        onTap: () =>
                                                            openAlertBox(
                                                                context:
                                                                    context,
                                                                title:
                                                                    "Confirmation Required!",
                                                                content:
                                                                    "If you edit the address, it will be a manual entry process. Would you like to continue?",
                                                                button1color:
                                                                    Colors
                                                                        .green,
                                                                button2color:
                                                                    Colors.red,
                                                                onpressedButton1: () => Navigator.pushNamed(
                                                                    context,
                                                                    route
                                                                        .manualEntry,
                                                                    arguments:
                                                                        address!
                                                                          ..remove(
                                                                              "peradrsproofcode")
                                                                          ..["soa"] =
                                                                              "KRA")),
                                                      )
                                                    : SizedBox())
                                          ])),
                                      const SizedBox(height: 20.0),
                                      Text(
                                        "Proof of Address : $kraProof",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Color.fromRGBO(68, 67, 67, 1)),
                                      ),
                                      const SizedBox(height: 20.0),
                                    ],
                                  ))
                            ]),
                          ),
                          onTap: () => setState(() {
                            addressType = "kyc";
                          }),
                        ),
                        const SizedBox(height: 30.0),
                      ],
                    )),
                Visibility(
                  visible: (!((Provider.of<Postmap>(context).email ==
                              CustomHttpClient.testEmail &&
                          Provider.of<Postmap>(context).mobileNo ==
                              CustomHttpClient.testMobileNo) ||
                      kraProof!.trim().toLowerCase() == "aadhaar")),
                  child: GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                              width: 1.5,
                              color: addressType == "digiLocker"
                                  ? Theme.of(context).colorScheme.primary
                                  : const Color.fromRGBO(217, 217, 217, 1))),
                      child: Visibility(
                        visible: addressType == "digiLocker",
                        replacement: Row(
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              child: Image.asset(
                                "assets/images/digilocker.png",
                                width: 45,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "DIGILOCKER",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            CustomRadioButton(
                              color: addressType == "digiLocker"
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                        child: Column(children: [
                          Row(
                            children: [
                              SizedBox(width: 18.0),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    "assets/images/digilocker.png",
                                    width: 50,
                                  ),
                                ),
                              ),
                              CustomRadioButton(
                                color: addressType == "digiLocker"
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            "AADHAAR KYC DOCUMENTS (DIGILOCKER)",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10.0),
                          Visibility(
                            visible: getDIgiLockerDatabase,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  digilockerame!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700,
                                      color: Color.fromRGBO(111, 105, 105, 1)),
                                  // style: TextStyle(
                                  //     fontSize: 14.0,
                                  //     fontWeight: FontWeight.w500,
                                  //     color:
                                  //         Color.fromRGBO(111, 105, 105, 1)),
                                ),
                                const SizedBox(height: 10.0),
                                Text.rich(
                                    textAlign: TextAlign.center,
                                    TextSpan(children: <InlineSpan>[
                                      TextSpan(text: digiLockerAadress ?? ""),
                                      WidgetSpan(
                                          child: SizedBox(
                                        width: 10.0,
                                      )),
                                      WidgetSpan(
                                          child: allowModification
                                              ? GestureDetector(
                                                  child: SvgPicture.asset(
                                                    "assets/images/VectorEdit.svg",
                                                    color: Colors.blue,
                                                  ),
                                                  onTap: () => openAlertBox(
                                                      context: context,
                                                      title:
                                                          "Confirmation Required!",
                                                      content:
                                                          "If you edit the address, it will be a manual entry process. Would you like to continue?",
                                                      button1color:
                                                          Colors.green,
                                                      button2color: Colors.red,
                                                      onpressedButton1: () =>
                                                          Navigator.pushNamed(
                                                              context,
                                                              route.manualEntry,
                                                              arguments:
                                                                  address!
                                                                    ..remove(
                                                                        "peradrsproofcode")
                                                                    ..["soa"] =
                                                                        "Digilocker")),
                                                )
                                              : SizedBox())
                                    ])),
                                // const SizedBox(height: 20.0),
                                // Text(
                                //   "Proof of Address : $digiLockerProof",
                                //   textAlign: TextAlign.center,
                                //   style: TextStyle(
                                //       fontWeight: FontWeight.w500,
                                //       color: Color.fromRGBO(68, 67, 67, 1)),
                                // ),
                                // const SizedBox(height: 20.0),
                              ],
                            ),
                            replacement: Text(
                              "Digilocker automatically verifies your documents needed for account opening with FLATTRADE",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(111, 105, 105, 1)),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                        ]),
                      ),
                    ),
                    onTap: () => setState(() {
                      addressType = "digiLocker";
                    }),
                  ),
                ),
                const SizedBox(height: 30.0),
                Visibility(
                  visible: manualOption,
                  child: GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width - 60.0,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                                width: 1.5,
                                color: addressType == "manual"
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color.fromRGBO(217, 217, 217, 1))),
                        child: Column(children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 16.0,
                              ),
                              Expanded(
                                child: Text(
                                  "Manual Entry",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Row(
                                children: [
                                  CustomRadioButton(
                                    color: addressType == "manual"
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            "Fill the Form manually yourself",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(111, 105, 105, 1)),
                          ),
                        ]),
                      ),
                      onTap: () => setState(() {
                            addressType = "manual";
                          })),
                ),

                // Expanded(
                //   child: InAppWebView(
                //     initialUrlRequest: URLRequest(
                //       url: WebUri("https://flutter.dev"),
                //     ),
                //   ),
                // )
              ]);
  }
}
