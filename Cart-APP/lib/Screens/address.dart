import 'package:ekyc/Cookies/cookies.dart';
import 'package:ekyc/Custom%20Widgets/alertbox.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackbar.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:provider/provider.dart';

import '../API%20call/api_call.dart';
import '../Custom Widgets/stepwidget.dart';
import '../Screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Custom Widgets/custom_radio_button.dart';
import '../Route/route.dart' as route;

class Address extends StatefulWidget {
  const Address({super.key});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
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

  /* 
  Purpose: This method is used to get the address status whether to show the manual and edit button or not and also get the address based on address status 
  */

  getAddressStatus() async {
    loadingAlertBox(context);
    var response = await getAddressStatusAPI(context: context);
    if (response != null) {
      manualOption = response["manualoption"] == "Y" ? true : false;
      allowModification = response["allowmodification"] == "Y" ? true : false;
      Provider.of<ProviderClass>(context, listen: false)
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

  /* 
  Purpose: This method is used to get the address  from the api  if the user comes from edit
  */

  getAddress() async {
    var response = await getAddressAPI(context: context);

    if (mounted) {
      Navigator.pop(context);
    }

    if (response != null) {
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

  /* 
  Purpose: This method is used to get the address from the kra  if the user not comes from edit
  */

  getKraPanSoap() async {
    var response = await getPanAddressAPI(context: context);
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

  /* 
  Purpose: This method is used to get the adddress from the digilockerDB
  */

  getdigiLockerAddress() async {
    loadingAlertBox(context);
    var response = await getDigiLockerAddressAPI(context: context);
    if (mounted) {
      Navigator.pop(context);
    }
    address = response;
    if (response is Map) {
      digiLockerAddress = response;
      digilockerame = response["name"] ?? "";
      digiLockerAadress =
          "${response["peradrs1"] + ", " + response["peradrs2"] + ", " + response["peradrs3"] + ", " + response["percity"] + ", " + response["perpincode"] + ", " + response["perstate"] + ", " + response["percountry"]}";
      digiLockerProof = response["peradrsproofname"];
      if (response["peradrs1"] != null &&
          response["peradrs1"].toString().trim().isNotEmpty) {
        getDIgiLockerDatabase = true;
      }
    } else if (response != null) {}

    if (mounted) {
      setState(() {});
    }
  }

  /* 
  Purpose: This method is used to insert the kra details to the db
  */

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

  /* 
  Purpose: This method is used to insert the digilocker details to the DB
  */

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

  /* 
  Purpose: This method is used to get the next route name from the Api
  */

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

  /* 
  Purpose: This method is used to get the digilocker Url
  */

  getDigiLockerUrl() async {
    loadingAlertBox(context);
    var response = await getDigiLockerUrlAPI(context: context);
    if (mounted) {
      Navigator.pop(context);
    }
    if (response != null) {
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
    return StepWidget(
        endPoint: route.address,
        step: 1,
        title: "PAN & Address",
        title1: "Address Verification",
        subTitle: "Verify address using KRA, DigiLocker",
        scrollController: scrollController,
        buttonFunc: () async {
          if (addressType == "manual") {
            Navigator.pushNamed(context, route.manualEntry);
          } else if (addressType == "kyc") {
            getKRADataBase ? postKycInfo() : getNextRoute(context);
          } else if (addressType == "digiLocker" &&
              Provider.of<ProviderClass>(context, listen: false).mobileNo ==
                  CustomHttpClient.testMobileNo &&
              Provider.of<ProviderClass>(context, listen: false).email ==
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
                  visible: (!((Provider.of<ProviderClass>(context).email ==
                              CustomHttpClient.testEmail &&
                          Provider.of<ProviderClass>(context).mobileNo ==
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
                            replacement: Text(
                              "Digilocker automatically verifies your documents needed for account opening with FLATTRADE",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(111, 105, 105, 1)),
                            ),
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
                                                  onTap: () => {
                                                    openAlertBox(
                                                        context: context,
                                                        title:
                                                            "Confirmation Required!",
                                                        content:
                                                            "If you edit the address, it will be a manual entry process. Would you like to continue?",
                                                        button1color:
                                                            Colors.green,
                                                        button2color:
                                                            Colors.red,
                                                        onpressedButton1: () =>
                                                            Navigator.pushNamed(
                                                                context,
                                                                route
                                                                    .manualEntry,
                                                                arguments: digiLockerAddress !=
                                                                        null
                                                                    ? (digiLockerAddress!
                                                                      ..["soa"] =
                                                                          "Digilocker")
                                                                    : {}))
                                                  },
                                                )
                                              : SizedBox())
                                    ])),
                              ],
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
                const SizedBox(height: 15.0),
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
              ]);
  }
}
