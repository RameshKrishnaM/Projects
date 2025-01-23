import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ekyc/Cookies/cookies.dart';
import 'package:ekyc/Custom%20Widgets/alertbox.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackbar.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:version/version.dart';

import '../API call/api_call.dart';
import '../Custom Widgets/custom_button.dart';
import '../Route/route.dart' as route;
import '../shared_preferences/shared_preference_func.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
  ProviderClass? postmap;
  String networkStatusText = "";
  bool appVersionVerified = false;
  PageController? pageController;
  String appCurrentVersion = "";

  @override
  void initState() {
    pageController = PageController(initialPage: pageIndex);
    initialData();

    super.initState();
  }

  /* 
  Purpose : This method is used to check the connectivity status (Internet Connection)
   */

  check() {
    if (result is List<ConnectivityResult>) {
      result = result[0];
    }

    switch (result) {
      case ConnectivityResult.none:
        networkStatusText = "No Network";
        break;
      case ConnectivityResult.wifi:
        networkStatusText = "Connected to WiFi";
        break;
      case ConnectivityResult.mobile:
        networkStatusText = "Connected to Mobile Data";
        break;
      case ConnectivityResult.ethernet:
        networkStatusText = "Connected to ethernet";
        break;
      default:
        networkStatusText = "Unknown";
        break;
    }

    if (!networkStatusText.contains("Connected")) {
      postmap!.changeIsNetworkConnected(false);
      showSnackbar(context, "No internet", Colors.red);
    } else {
      postmap!.changeIsNetworkConnected(true);
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  /* 
  Purpose : This method is used to Get the connectivity status (Internet Connection)
   */

  getConnectivityInstance() async {
    try {
      result = await Connectivity().checkConnectivity();
      check();
    } catch (e) {}
  }

  /* 
  Purpose : This method is used to Listen the connectivity status (Internet Connection)
   */

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

  /* 
  Purpose : This method is used to initilize SSL certificate and  check the app version , Network status
   */

  initialData() async {
    postmap = Provider.of<ProviderClass>(context, listen: false);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appCurrentVersion = packageInfo.version;
    CustomHttpClient.addTrustedCertificate(context);
    cookie = await CustomHttpClient.verifyCookies();

    String platform = Platform.isAndroid
        ? 'Android'
        : Platform.isIOS
            ? 'iOS'
            : 'Unknown';
    CustomHttpClient.headers["User-Agent"] =
        'InstaKYC/$appCurrentVersion ($platform)';
    CustomHttpClient.headers["app_mode"] = "app";
    CustomHttpClient.headers["api-version"] = "v2";
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent));
    await Future.delayed(const Duration(seconds: 2), () {});
    if (mounted) {
      loadingAlertBox(context);
      setState(() {
        splashscreenShow = false;
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Color.fromRGBO(0, 71, 255, 0.81)));
      });

      await netWorkVerify();
      if (networkStatusText.contains("Connected")) {
        await getAppVersion();
      } else if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /* 
  Purpose : This method is used to get the next route name from the api
   */

  getNextRoute(context) async {
    String mobileNo = await getMobileNo();
    String email = await getEmail();
    Provider.of<ProviderClass>(context, listen: false).changeMobileNo(mobileNo);
    Provider.of<ProviderClass>(context, listen: false).changeEmail(email);
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.signup],
      "routeraction": "Next"
    });
    if (response != null) {
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

      Navigator.pushNamedAndRemoveUntil(
          context, response["endpoint"], (route) => route.isFirst);
    } else {
      await clearCookies();
      cookie = false;
      if (mounted) {
        Navigator.pop(context);
        setState(() {});
      }
    }
  }

  /* 
  Purpose : This method is used to check the app version
   */

  getAppVersion([onclick = false]) async {
    if (onclick == true) {
      loadingAlertBox(context);
    }
    var response = await getAppVersionInAPI(context: context);
    if (response != null) {
      String newVersion = response["version"];
      bool isFocedUpdate = response["forceUpdate"] == "Y" ? true : false;
      String url = response["url"];
      String currentVersion = appCurrentVersion;
      if (Version.parse(newVersion) > Version.parse(currentVersion)) {
        openAlertBox(
          context: context,
          content:
              'A new version $newVersion is available. Update for better experience!',
          button1Content: "UPDATE",
          onpressedButton1: () async {
            launchUrlString(url);
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
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50.0),
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
                              child: PageView(
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
                                    PermissionStatus notificationStatus =
                                        await Permission.notification.request();

                                    if (!appVersionVerified) {
                                      await getAppVersion(true);
                                    } else {
                                      if (!networkStatusText
                                          .contains("Connected")) {
                                        showSnackbar(
                                            context, "No internet", Colors.red);
                                        return;
                                      }
                                      if (cookie == true) {
                                        loadingAlertBox(context);
                                        getNextRoute(context);
                                      } else {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            route.signup,
                                            (route) => route.isFirst);
                                      }
                                    }
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
