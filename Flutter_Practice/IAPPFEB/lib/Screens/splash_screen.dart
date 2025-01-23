import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:version/version.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ekyc/Cookies/cookies.dart';
import 'package:ekyc/Custom%20Widgets/alertbox.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackBar.dart';
import 'package:ekyc/Firebase_and_Facebook/event_capure.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../API call/api_call.dart';
import '../Custom Widgets/custom_button.dart';

import '../Route/route.dart' as route;

import 'package:package_info_plus/package_info_plus.dart';

import '../shared_preferences/shared_preference_func.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
// with WidgetsBindingObserver
{
  int pageIndex = 0;
  static List images = [
    'assets/images/facelock.png',
    'assets/images/security.png',
    'assets/images/fingerprint.png',
    'assets/images/sebi.png',
  ];
  static List titles = [
    'Address Verification - ',
    'Address Proof - ',
    'Bank Proof - ',
    '',
  ];
  static List subTitiles = [
    'PAN number, Aadhaar number, Aadhaar registered mobile number',
    'Driving License/ Voter ID/ Passport/ Ration Card',
    'Six month bank statement/ Cancelled cheque/ Passbook front page',
    'Ensure your Pan is linked with Aadhar to open your account as mandated by SEBI',
  ];

  List pages = List.generate(
    images.length,
    (index) => Pages(
      img: images[index],
      title: titles[index],
      txt: subTitiles[index],
    ),
  );
  bool splashscreenShow = true;
  var result;
  var subscription;
  Postmap? postmap;
  String networkStatusText = "";
  bool appVersionVerified = false;
  PageController? pageController;

  @override
  void initState() {
    pageController = PageController(initialPage: pageIndex);
    initialData();

    super.initState();
  }

  check() {
    if (result is List<ConnectivityResult>) {
      result = result[0];
    }

    // for (var element in result as List<ConnectivityResult>) {
    //   if(element is ConnectivityResult.wifi)
    // }
    switch (result) {
      case ConnectivityResult.none:
        networkStatusText = "No Network";
        break;
      case ConnectivityResult.wifi:
        // cookieVerify();
        networkStatusText = "Connected to WiFi";
        break;
      case ConnectivityResult.mobile:
        // cookieVerify();
        networkStatusText = "Connected to Mobile Data";
        break;
      case ConnectivityResult.ethernet:
        // cookieVerify();
        networkStatusText = "Connected to ethernet";
        break;
      default:
        networkStatusText = "Unknown";
        break;
    }
    // print("res $result");
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!networkStatusText.contains("Connected")) {
      // print("network not connected");
      postmap!.changeIsNetworkConnected(false);
      showSnackbar(context, "No internet", Colors.red);
    } else {
      // print("network connected");
      postmap!.changeIsNetworkConnected(true);
      ScaffoldMessenger.of(context).clearSnackBars();
      // showSnackbar(context, "Internet connected", Colors.green);
    }
    // });
  }

  getConnectivityInstance() async {
    try {
      result = await Connectivity().checkConnectivity();
      check();
    } catch (e) {}
  }

  netWorkVerify() async {
    await getConnectivityInstance();
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      this.result = result.first;

      check();
    });
  }

  bool? cookie;
  initialData() async {
    postmap = Provider.of<Postmap>(context, listen: false);

    // netWorkVerify();
    // WidgetsBinding.instance.addObserver(this);
    CustomHttpClient.addTrustedCertificate(context);
    cookie = await CustomHttpClient.verifyCookies();

    String platform = Platform.isAndroid
        ? 'Android'
        : Platform.isIOS
            ? 'iOS'
            : 'Unknown';
    CustomHttpClient.headers["User-Agent"] =
        'InstaKYC/${CustomHttpClient.appCurrentVersion} ($platform)';
    CustomHttpClient.headers["app_mode"] = "app";
    CustomHttpClient.headers["api-version"] = "v2";
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent));
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    await Future.delayed(const Duration(seconds: 2), () {});

    if (mounted) {
      loadingAlertBox(context);
      // showSnackbar(context, await SmsAutoFill().getAppSignature, Colors.red);
      setState(() {
        splashscreenShow = false;
        // getPermission();
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Color.fromRGBO(0, 71, 255, 0.81)));
        // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        //     overlays: SystemUiOverlay.values);
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (!Provider.of<Postmap>(context, listen: false)
        //       .isNetworkConnected) {
        //     showSnackbar(context, "No internet", Colors.red);
        //   }
        // });
      });
      // if (cookie == true) {
      //   Navigator.pushNamed(context, route.signup);
      // }

      await netWorkVerify();
      print("status ${networkStatusText.contains("Connected")}");
      if (networkStatusText.contains("Connected")) {
        await getAppVersion();
      } else if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  getNextRoute(context) async {
    String mobileNo = await getMobileNo();
    String email = await getEmail();
    String status = await getStatus();
    Provider.of<Postmap>(context, listen: false).changeMobileNo(mobileNo);
    Provider.of<Postmap>(context, listen: false).changeEmail(email);
    //  response != null ? getNextRoute(context) : Navigator.pop(context);
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.signup],
      "routeraction": "Next"
    });
    // print("resp $response");
    if (response != null) {
      // print("i am if");
      if (mounted) {
        Navigator.pop(context);
      }
      if (mobileNo == CustomHttpClient.testMobileNo &&
          email == CustomHttpClient.testEmail) {
        await clearCookies();
        cookie = false;
        if (mounted) {
          setState(() {});
        }
        return;
      }
      // if (mobileNo == CustomHttpClient.testMobileNo &&
      //     email == CustomHttpClient.testEmail) {
      //   if (status == "c") {
      //     Navigator.pushNamedAndRemoveUntil(
      //         context, route.congratulationTest, (route) => route.isFirst);
      //   } else {
      //     Navigator.pushNamedAndRemoveUntil(
      //         context, route.panCard, (route) => route.isFirst);
      //   }
      // } else {
      Navigator.pushNamedAndRemoveUntil(
          context, response["endpoint"], (route) => route.isFirst);
      // Navigator.pushNamedAndRemoveUntil(
      //     context, route.panCard, (route) => route.isFirst);
      // }
    } else {
      // print("i am else");
      await clearCookies();
      cookie = false;
      if (mounted) {
        Navigator.pop(context);
        setState(() {});
      }
    }
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   print(state);
  //   if (state == AppLifecycleState.resumed) {
  //     print("resumed");
  //     getPermission(false); // Re-check permission when app regains focus
  //   }
  // }

  getAppVersion([onclick = false]) async {
    // print("cokie $cookie");
    if (onclick == true) {
      loadingAlertBox(context);
    }
    var response = await getAppVersionInAPI(context: context);
    // Map response = {"version": "1.0.0", "forceUpdate": "Y", "url": ""};
    if (response != null) {
      // if (!Provider.of<Postmap>(context, listen: false).isNetworkConnected) {
      //   return;
      // }
      String newVersion = response["version"];
      bool isFocedUpdate = response["forceUpdate"] == "Y" ? true : false;
      String url = response["url"];
      // Version.parse("");
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = CustomHttpClient.appCurrentVersion;
      // Version.parse(newVersion) > Version.parse(currentVersion)
      // newVersion.compareTo(currentVersion) > 0
      if (Version.parse(newVersion) > Version.parse(currentVersion)) {
        openAlertBox(
          context: context,
          content:
              'A new version $newVersion is available. Update for better experience!',
          button1Content: "UPDATE",
          onpressedButton1: () async {
            // Navigator.pop(context);
            // Navigator.pop(context);
            launchUrlString(url);
            // if (Platform.isAndroid) {
            //   launchUrlString("https://www.google.com/");
            // } else if (Platform.isIOS) {
            //   launchUrlString("https://www.youtube.com/");
            // } else {
            //   // Navigator.pop(context);
            // }
          },
          button2Content: "LATER",
          onpressedButton2: () {
            Navigator.pop(context);
            if (cookie == true) {
              getNextRoute(context);
            } else if (mounted) {
              Navigator.pop(context);
              if (onclick) {
                Navigator.pushNamedAndRemoveUntil(
                    context, route.signup, (route) => route.isFirst);
              }
            }
          },
          needButton2: !isFocedUpdate,
          barrierDismissible: false,
          canPop: !isFocedUpdate,
        );
      } else {
        if (cookie == true) {
          getNextRoute(context);
        } else if (mounted) {
          if (!onclick) {
            Navigator.pop(context);
          }
          if (onclick) {
            Navigator.pushNamedAndRemoveUntil(
                context, route.signup, (route) => route.isFirst);
          }
        }
      }
      appVersionVerified = true;
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: splashscreenShow ? Colors.white : null,
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          exit(0);
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: AssetImage("assets/images/background_image.png"))),
          child: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: AssetImage("assets/images/background_image.png"))),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: splashscreenShow
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 0.5,
                            child: Image.asset(
                              "assets/images/InstaKYCName.png",
                              // width: 250.0,
                            ),
                          ),
                          // const SizedBox(
                          //   height: 10.0,
                          // ),
                          // Text(
                          //   "InstaKYC Flattrade",
                          //   style: TextStyle(
                          //       color: Colors.black,
                          //       fontWeight: FontWeight.w900,
                          //       fontSize: 20.0),
                          // )
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50.0),
                          // Transform.scale(
                          //     scale: 1.5,
                          //     child: Image.asset("assets/images/flattrade.png")),
                          // const SizedBox(
                          //   height: 3.0,
                          // ),
                          // const Text(
                          //   "Absolute Zero Brokerage",
                          //   style: TextStyle(
                          //       fontSize: 12.5,
                          //       fontWeight: FontWeight.w400,
                          //       color: Color.fromRGBO(171, 171, 171, 1)),
                          // ),
                          Image.network(
                            "https://flattrade.s3.ap-south-1.amazonaws.com/instakyc/Insta_kyc_logo2.png",
                            width: 170.0,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                height: 43.0,
                                width: 100.0,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return const SizedBox(
                                  height: 43.0,
                                  width: 100.0,
                                );
                              }
                            },
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            'Open Zero Brokerage',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Demat & Trading Account',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontSize: 22,
                                    color:
                                        const Color.fromRGBO(9, 101, 218, 1)),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          // ElevatedButton(
                          //     onPressed: () async {
                          //       insertEvents(
                          //           context, "event_in_device_june_10_android");
                          //       // String? token =
                          //       //     await FirebaseMessaging.instance.getToken();
                          //       // var firebaseFirestoreInstance =
                          //       //     FirebaseFirestore.instance;
                          //       // firebaseFirestoreInstance
                          //       //     .collection("u")
                          //       //     .doc("987")
                          //       //     .set({
                          //       //   "name": "nameController.text.trim()",
                          //       //   "phone": "mobileNumberController.text.trim()",
                          //       //   "email": "",
                          //       //   "token": token,
                          //       //   "stage": "routeNames[route.signup]"
                          //       // });
                          //     },
                          //     child: Text("data")),
                          Text(
                            'In Just 5 Minutes',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color:
                                        const Color.fromRGBO(60, 95, 140, 1)),
                          ),
                          Expanded(
                              child:
                                  //  PageView.builder(
                                  //   itemCount: pages.length,
                                  //   onPageChanged: (value) {
                                  //     pageIndex = value;
                                  //     setState(() {});
                                  //   },
                                  //   itemBuilder: (context, index) {
                                  //     return pages[index];
                                  //   },
                                  // ),
                                  PageView(
                            controller: pageController,
                            onPageChanged: (value) {
                              pageIndex = value;
                              setState(() {});
                            },
                            children: [...pages],
                          )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              pages.length,
                              (index) => Container(
                                margin: const EdgeInsets.only(right: 5),
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  shape: BoxShape.circle,
                                  color: pageIndex == index
                                      ? const Color.fromRGBO(9, 101, 218, 1)
                                      : Colors.transparent,
                                ),
                                child: const Text(''),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomButton(
                            buttonText: pageIndex == pages.length - 1
                                ? 'Lets Start!'
                                : 'Next',
                            buttonFunc: pageIndex == pages.length - 1
                                ? () async {
                                    // netWorkVerify();
                                    // await getPermission() == true
                                    //     ?
                                    PermissionStatus notificationStatus =
                                        await Permission.notification.request();
                                    // PermissionStatus smsStatus =
                                    //     await Permission.sms.request();
                                    // if (!networkStatusText
                                    //     .contains("Connected")) {
                                    //   showSnackbar(
                                    //       context, "No internet", Colors.red);
                                    //   return;
                                    // }

                                    if (!appVersionVerified) {
                                      // print("app vers");
                                      await getAppVersion(true);
                                      // if (!appVersionVerified) {
                                      //   return;
                                      // }
                                    } else {
                                      if (!networkStatusText
                                          .contains("Connected")) {
                                        showSnackbar(
                                            context, "No internet", Colors.red);
                                        return;
                                      }
                                      if (cookie == true) {
                                        // print("cookie");
                                        loadingAlertBox(context);
                                        getNextRoute(context);
                                      } else {
                                        // print("route");
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            route.signup,
                                            (route) => route.isFirst);
                                      }
                                    }

                                    // Navigator.pushNamedAndRemoveUntil(context,
                                    //     route.signup, (route) => route.isFirst);
                                    // : null;
                                  }
                                : () {
                                    pageController!.animateToPage(++pageIndex,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.linear);
                                  },
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Pages extends StatelessWidget {
  final String img;
  final String title;
  final String txt;
  const Pages({
    super.key,
    required this.img,
    required this.txt,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          // border: Border.all(),
          borderRadius: BorderRadius.circular(17),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Color.fromRGBO(9, 101, 218, 0.25),
            ),
          ],
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Keep the following Documents handy for seamless account opening',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(60, 95, 140, 1),
                  ),
                ),
                const SizedBox(height: 10.0),
                Image.asset(img),
                const SizedBox(height: 10.0),
                Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(children: [
                      TextSpan(
                        text: title,
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      TextSpan(
                        text: txt,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(69, 90, 100, 1),
                        ),
                      )
                    ])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
