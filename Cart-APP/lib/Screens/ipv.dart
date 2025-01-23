import 'dart:collection';
import 'dart:io';

import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackbar.dart';
import 'package:ekyc/Custom%20Widgets/stepwidget.dart';
import 'package:ekyc/Custom%20Widgets/video_player.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kyc_workflow/digio_config.dart';
import 'package:kyc_workflow/environment.dart';
import 'package:kyc_workflow/gateway_event.dart';
import 'package:kyc_workflow/kyc_workflow.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Custom Widgets/alertbox.dart';
import '../Custom Widgets/loadimage.dart';
import '../Route/route.dart' as route;

class IPV extends StatefulWidget {
  const IPV({super.key});

  @override
  State<IPV> createState() => _IPVState();
}

class _IPVState extends State<IPV> {
  String isVideoApplicable = "N";
  String isSignApplicable = "N";
  Map? ipvDetails;
  String? image;
  String? signature;
  String? otp;
  String? video;
  String? kidId;
  String? gwtId;
  String? email;
  ScrollController scrollController = ScrollController();
  var key;

  @override
  void initState() {
    key = UniqueKey();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIPVDetails();
    });
  }

  /* 
  Purpose: This method is used to get the user details from the api.
  */

  getUserDetails({bool singleRecapture = false, String actiontype = ""}) async {
    if (!Platform.isIOS) {
      if (await getPermission() != true) return;
    }
    loadingAlertBox(context);
    var response = singleRecapture
        ? await ipvRecapture(context: context, actiontype: actiontype)
        : await getUserDetailsForIPVInAPI(context: context);
    if (mounted) {
      Navigator.pop(context);
    }
    print(" ****response**** ");
    print(response);
    if (response != null) {
      kidId = response["id"];
      gwtId = response["access_token"]["id"];
      email = response["customer_identifier"];
      if (kidId != null &&
          kidId!.isNotEmpty &&
          gwtId != null &&
          gwtId!.isNotEmpty &&
          email != null &&
          email!.isNotEmpty) {
        singleRecapture ? function(actiontype: "ReCapture") : function();
      } else {
        showSnackbar(context, "Some thing went wrong", Colors.red);
      }
    }
  }

  /* 
  Purpose: This method is used for doing digio.
  */

  function({String actiontype = ''}) async {
    WidgetsFlutterBinding.ensureInitialized();

    var digioConfig = DigioConfig();

    digioConfig.theme.primaryColor = "#32a83a";
    digioConfig.environment = Environment
        .SANDBOX; // SANDBOX is testing server, PRODUCTION is production server

    final _kycWorkflowPlugin = KycWorkflow(digioConfig);
    _kycWorkflowPlugin.setGatewayEventListener((GatewayEvent? gatewayEvent) {});
    // kid KID240206133931111HCXK2U1WA79ZGA
    // gwt GWT2402061339312233SFZGUEDZ3U34E
    // diwananifa@gmail.com
    HashMap<String, String> additionalData = HashMap<String, String>();
    SharedPreferences sref = await SharedPreferences.getInstance();
    String cookies = sref.getString("cookies") ?? "";
    additionalData['unique_request_id'] =
        cookies.split(" ")[0].split("=")[1].split(";")[0];
    var workflowResult =
        await _kycWorkflowPlugin.start(kidId!, email!, gwtId!, additionalData);

    if (!workflowResult.code!.isNegative) {
      loadingAlertBox(context);
      var response = await saveIPVDetailsInAPI(
          context: context,
          json: {
            "digio_doc_id": workflowResult.documentId,
            "message": workflowResult.message,
            "txn_id": workflowResult.code.toString()
          },
          actiontype: actiontype);
      if (mounted) {
        Navigator.pop(context);
      }
      if (response != null) {
        getIPVDetails();
      }
    } else {
      showSnackbar(context, workflowResult.message ?? "Some thing went wrong",
          Colors.red);
    }
  }

  /* 
  Purpose: This method is used to get the next route name
  */

  getNextRoute(context) async {
    loadingAlertBox(context);
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.ipv],
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
  Purpose: This method is used to get the permission for camera, mic,location for digio
  */

  Future<bool?> getPermission() async {
    List<Permission> permissions = [
      Permission.location,
      Permission.camera,
      Permission.microphone,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    List<String> notPermit = [];

    for (var element in permissions) {
      PermissionStatus? permissionStatus = statuses[element];
      String name = element.toString().split(".")[1];
      !permissionStatus!.isGranted
          ? notPermit
              .add("${name.substring(0, 1).toUpperCase()}${name.substring(1)}")
          : null;
    }
    if (!statuses.keys.every((element) => statuses[element]!.isGranted)) {
      openAlertBox(
          barrierDismissible: false,
          context: context,
          content:
              "${notPermit.join(", ")} permission required to complete IPV for account opening.",
          button1Content: "Accept permission",
          onpressedButton1: () async {
            Navigator.pop(context);
            var a = await openAppSettings();
          },
          needButton2: false);
      return false;
    } else {
      return true;
    }
  }

  /* 
  Purpose: This method is used to get the ipv details from the api
  */

  getIPVDetails() async {
    loadingAlertBox(context);

    try {
      var response = await getIPVDetailsAPI(context: context);
      if (response != null) {
        ipvDetails = response;
        isVideoApplicable = response["isVideoApplicable"];

        isSignApplicable = response["isSignApplicable"];

        image = response["imgid"];
        signature = response["signatureId"] ?? "";
        otp = response["code"];
        video = response["videoid"];
        key = UniqueKey();
      }
    } catch (e) {
      showSnackbar(
          context, exceptionShowSnackBarContent(e.toString()), Colors.red);
    }
    if (mounted) {
      Navigator.pop(context);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepWidget(
        step: 6,
        endPoint: route.ipv,
        title: isSignApplicable == "N"
            ? "In-Person Verification "
            : "In-Person Verification & Signature",
        subTitle: (isSignApplicable == "Y" && isVideoApplicable == "Y")
            ? "Take a Live Photo , Video and Signature "
            : isVideoApplicable == "Y"
                ? "Take a Live Photo and Video "
                : "Take a Live Photo ",
        scrollController: scrollController,
        buttonText: image == null || image!.isEmpty ? "Capture" : null,
        buttonFunc: image == null || image!.isEmpty
            ? getUserDetails
            : () => getNextRoute(context),
        children: [
          Column(
            children: [
              image == null || image!.isEmpty
                  ? InkWell(
                      onTap: getUserDetails,
                      child: Container(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Colors.white,
                            border: Border.all(
                                width: 1.0,
                                color: const Color.fromRGBO(9, 101, 218, 1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  height: 50.0,
                                  width: 50.0,
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                      "assets/images/selfie.svg")),
                              const SizedBox(
                                width: 20.0,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        (isSignApplicable == "Y" &&
                                                isVideoApplicable == "Y")
                                            ? "Your Selfie , Video and Signature "
                                            : isVideoApplicable == "Y"
                                                ? "Your Selfie and Video "
                                                : "Your Selfie ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: const Color.fromRGBO(
                                                    0, 0, 0, 1),
                                                fontWeight: FontWeight.w700)),
                                    const SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                        (isSignApplicable == "Y" &&
                                                isVideoApplicable == "Y")
                                            ? "Take a Live Photo , Video and Signature "
                                            : isVideoApplicable == "Y"
                                                ? "Take a Live Photo and Video "
                                                : "Take a Live Photo ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall)
                                  ],
                                ),
                              ),
                            ],
                          )),
                    )
                  : Column(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 10.0, 10.0, 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Colors.white,
                                border: Border.all(
                                    width: 1.0,
                                    color:
                                        const Color.fromRGBO(9, 101, 218, 1)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: const BoxDecoration(),
                                    child: LoadImage(
                                      key: key,
                                      data: image,
                                      fileTitle: "IPVImage",
                                      fileName: "",
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20.0,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Selfie captured",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: const Color.fromRGBO(
                                                        0, 0, 0, 1))),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              child: Row(children: [
                                                SizedBox(
                                                  height: 15,
                                                  width: 15,
                                                  child: SvgPicture.asset(
                                                      "assets/images/selfie.svg"),
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                Text("Recapture Selfie",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            color:
                                                                Color.fromRGBO(
                                                                    9,
                                                                    101,
                                                                    218,
                                                                    1))),
                                              ]),
                                              onTap: () {
                                                getUserDetails(
                                                    singleRecapture: true,
                                                    actiontype: "digi_selfie");
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Visibility(
                          visible: video != null && video!.isNotEmpty,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 10.0, 10.0, 10.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: Colors.white,
                                    border: Border.all(
                                        width: 1.0,
                                        color: const Color.fromRGBO(
                                            9, 101, 218, 1))),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: VideoPlayerInReview(
                                        key: key,
                                        data: video,
                                        otp: otp ?? "",
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Selfie Video captured",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color:
                                                          const Color.fromRGBO(
                                                              0, 0, 0, 1))),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                child: Row(children: [
                                                  SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child: SvgPicture.asset(
                                                        "assets/images/selfie.svg"),
                                                  ),
                                                  const SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text("Recapture video",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      9,
                                                                      101,
                                                                      218,
                                                                      1))),
                                                ]),
                                                onTap: () {
                                                  getUserDetails(
                                                      singleRecapture: true,
                                                      actiontype: "digi_video");
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Visibility(
                          visible: signature != null && signature!.isNotEmpty,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 10.0, 10.0, 10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 1.0,
                                      color:
                                          const Color.fromRGBO(9, 101, 218, 1)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: const BoxDecoration(),
                                      child: LoadImage(
                                        key: key,
                                        data: signature,
                                        fileTitle: "SIGNATUREImage",
                                        fileName: "",
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Signature captured",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color:
                                                          const Color.fromRGBO(
                                                              0, 0, 0, 1))),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                child: Row(children: [
                                                  SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child: SvgPicture.asset(
                                                        "assets/images/signature.svg"),
                                                  ),
                                                  const SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text("Recapture Signature",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      9,
                                                                      101,
                                                                      218,
                                                                      1))),
                                                ]),
                                                onTap: () {
                                                  getUserDetails(
                                                      singleRecapture: true,
                                                      actiontype: "digi_Sign");
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
              if (image != null &&
                  image!.isNotEmpty &&
                  (isVideoApplicable == "Y" || isSignApplicable == "Y")) ...[
                const SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Row(children: [
                        SvgPicture.asset("assets/images/selfie.svg"),
                        const SizedBox(
                          width: 10.0,
                        ),
                        const Text("Recapture All",
                            style: TextStyle(
                              color: Color.fromRGBO(9, 101, 218, 1),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ))
                      ]),
                      onTap: () => getUserDetails(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ]);
  }
}
