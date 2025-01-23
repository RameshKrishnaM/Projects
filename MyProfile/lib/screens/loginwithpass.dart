// ignore_for_file: unused_field, prefer_final_fields, no_leading_underscores_for_local_identifiers, unused_local_variable, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:novo/API/APICall.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/cookies/cookies.dart';
import 'package:novo/services/biometricuserAuth.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/utils/colors.dart';
import 'package:novo/widgets/LogIn%20Widgets/getotpForgetPassword.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Roating/route.dart' as route;
import 'package:http/http.dart' as http;
import 'package:version/version.dart';
import '../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../widgets/NOVO Widgets/snackbar.dart';
import '../widgets/NOVO Widgets/textFieldWidget.dart';
import '../widgets/NOVO Widgets/textbutton.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  bool isLoading = true;
  DateTime goBackApp = DateTime.now();
  var formKey = GlobalKey<FormState>();
  bool recheck = false;
  bool isLoaded = false;
  bool buttonIsLoading = false;
  TextEditingController userIdController = TextEditingController();
  //karthikraja=FT032287
  //Lakshmanan Sir=FT000069
  //sri=FT034528
  //thangareen=FT034568
  TextEditingController passwordController = TextEditingController();
  //karthikraja=Aaa@111
  //Lakshmanan Sir=Demo@1111
  //sri=Wqsb-852
  //thangareena=smile@1A
  TextEditingController pancardController = TextEditingController();
  //karthikraja=EXPPK4076L
  //Lakshmanan Sir=AGMPA8575C
  //sri=DSGPA0038D
  //thangareena=NISPS8983P

  String? curVersion;
  String? forceUpdate;
  Version? installedVersion;
  Version? latestVersion;
  String? appPackageName;
  String? deviceName;
  late final LocalAuthentication auth;
  bool? isBioMetricAuth;
  AppLifecycleState? appState;
  bool clientIdReadOnly = true;
  String clientId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      versionCheck(context);
      cookieverify();
      getBioMetricVerify();
    });
    WidgetsBinding.instance.addObserver(this);
    auth = LocalAuthentication();
    auth.isDeviceSupported().then((bool isSupported) {});
    getUserName();
  }

  getUserName() async {
    SharedPreferences sref = await SharedPreferences.getInstance();
    clientId = sref.getString("clientId") ?? '';
    userIdController.text = clientId;
    if (clientId.isEmpty) {
      clientIdReadOnly = false;

      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    appState = state;
    if (state == AppLifecycleState.resumed) {
      checkBiometricAvailability();
    }
  }

  Future<void> versionCheck(BuildContext context) async {
    if (await isInternetConnected()) {
      getVersionInAPI();
      getDeviceIP();
      deviceName = getDeviceInformation();
    } else {
      noInternetConnectAlertDialog(context, () => versionCheck(context));
    }
  }

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  Future<void> cookieverify() async {
    await Provider.of<NavigationProvider>(context, listen: false).getCookie();
    bool cookieValid = await verifyCookies(context);

    if (cookieValid) {
      Navigator.pushNamed(context, route.novoPage, arguments: 1);
    } else {
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) async {
          // Check if neither mobile nor wifi are active
          if (!results.any((result) =>
              result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi)) {
            // If there's no internet, show the snackbar
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print('NO Internet ++++++++++++++++++');
              showSnackbar(context, "No internet", Colors.red);
            });
          }
        },
      );

      isLoading = false;
      setState(() {});
    }
  }

  Future<void> getBioMetricVerify() async {
    String? isEnableBio = await BiometricAuthentication.getBiometricVerify();
    if (isEnableBio == "Y") {
      bioMetricAuthEnable();
    }
  }

  bioMetricAuthEnable() async {
    await BiometricAuthentication.isBioMetricAvailable(auth);
    await BiometricAuthentication.authenticate(auth, context);
    setState(() {});

    if (BiometricAuthentication.isAuthenticated) {
      isBioMetricAuth = true;
      var pref = await SharedPreferences.getInstance();
      pancardController.text = pref.getString("tOtp") ?? "";
      await BiometricAuthentication.setBiometricVerify("Y");
    } else {
      BiometricAuthentication.isAuthenticated = true;
      isBioMetricAuth = false;
    }
  }

  Future<void> checkBiometricAvailability() async {
    try {
      BiometricAuthentication.availableBiometrics =
          await auth.getAvailableBiometrics();

      if (BiometricAuthentication.availableBiometrics.isEmpty) {
        await BiometricAuthentication.setBiometricVerify("N");
        isBioMetricAuth = false;
        setState(() {});
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  String? platform;
  Future<void> getVersionInAPI() async {
    String apiUrl = "https://novoapi.flattrade.in/getCurVersion";

    platform = Platform.isAndroid
        ? 'Android'
        : Platform.isIOS
            ? 'iOS'
            : 'Unknown';
    Map<String, String> headers = {
      'User-Agent': 'YourApp/1.0 ($platform)', // Custom User-Agent header
    };

    try {
      var response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);

        if (json["status"] == "S") {
          curVersion = json['version'];
          forceUpdate = json['forceUpdate'];
          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          appPackageName = packageInfo.packageName;

          installedVersion = Version.parse(packageInfo.version);
          latestVersion = Version.parse(curVersion!);

          updateAlertDailog();
        } else {
          showSnackbar(
              context, json["errMsg"] ?? somethingError, primaryRedColor);
        }
      } else {
        showSnackbar(context, somethingError, primaryRedColor);
      }
    } catch (e) {
      showSnackbar(context, somethingError, primaryRedColor);
    }
  }

  String? deviceIP;

  void getDeviceIP() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            setState(() {
              deviceIP = addr.address;
            });
          } else if (addr.type == InternetAddressType.IPv6) {
            setState(() {
              deviceIP = addr.address;
            });
          }
        }
      }
    } catch (error) {
      ////////print('Error getting IP address: $error');
    }
  }

  String getDeviceInformation() {
    if (Platform.isAndroid) {
      return '${androidDeviceManufacturer()}-${androidDeviceModel()}';
    } else if (Platform.isIOS) {
      return '${iosDeviceLocalizedModel()}-${iosDeviceModel()}';
    } else {
      return 'Unknown Device';
    }
  }

  String androidDeviceModel() {
    return androidProperty('ro.product.model', 'Unknown');
  }

  String androidDeviceManufacturer() {
    return androidProperty('ro.product.manufacturer', 'Unknown');
  }

  String androidDeviceProduct() {
    return androidProperty('ro.product.name', 'Unknown');
  }

  String androidProperty(String property, String defaultValue) {
    try {
      final result = Process.runSync('getprop', [property]);
      if (result.stdout != null) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      ////////print('Error getting Android property $property: $e');
    }
    return defaultValue;
  }

  String iosDeviceModel() {
    return iosProperty('hw.machine', 'Unknown');
  }

  String iosDeviceLocalizedModel() {
    return iosProperty('hw.model', 'Unknown');
  }

  String iosDeviceSystemName() {
    return 'iOS';
  }

  String iosDeviceSystemVersion() {
    return iosProperty('os.version', 'Unknown');
  }

  String iosProperty(String property, String defaultValue) {
    try {
      final result = Process.runSync('sysctl', ['-n', property]);
      if (result.stdout != null) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      ////////print('Error getting iOS property $property: $e');
    }
    return defaultValue;
  }

  Uri? url;
  updateAlertDailog() {
    if (installedVersion! < latestVersion) {
      if (Platform.isAndroid) {
        url = Uri.parse(
            'https://play.google.com/store/apps/details?id=$appPackageName');
      } else if (Platform.isIOS) {
        url = Uri.parse(
            'https://apps.apple.com/in/app/novo-ipo-sgb-mf-g-sec/id6473023986');
      } else {
        // return 'Unknown Device';
        url = Uri.parse('');
      }

      Future<void> _launchUrl() async {
        if (url == null || !await launchUrl(url!)) {
          // throw Exception('Could not launch $url');
        }
      }

      // Show an update dialog
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) => false,
            child: AlertDialog(
              title: const Text('Update Available'),
              content: Text(
                  'A new version $latestVersion is available. Update for better experience!'),
              actions: [
                Visibility(
                  visible: forceUpdate == 'N',
                  child: MaterialButton(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    color: appPrimeColor,
                    onPressed: () => Navigator.pop(context),
                    child: buttonIsLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "LATER",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                  ),
                ),
                MaterialButton(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: appPrimeColor,
                  onPressed: _launchUrl,
                  child: buttonIsLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "UPDATE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  postLogInDetailsInAPI(curentPagecontext) async {
    try {
      if (await isInternetConnected()) {
        Map? json = await postLogInDetails(
          context: curentPagecontext,
          clientId: userIdController.text.toUpperCase(),
          password: passwordController.text,
          panCardNo: pancardController.text.toUpperCase(),
          deviceName: deviceName!,
          deviceIP: deviceIP!,
        );

        if (json != null) {
          var pref = await SharedPreferences.getInstance();
          pref.setString("tOtp", pancardController.text.toUpperCase());
          Navigator.pushNamed(context, route.novoPage, arguments: 1);
          return;
        }
        setState(() {
          buttonIsLoading = false;
        });
      } else {
        noInternetConnectAlertDialog(
            curentPagecontext, () => postLogInDetailsInAPI(curentPagecontext));
      }
    } catch (e) {
      ////////print(e);
    }
  }

  onLogin() {
    if (buttonIsLoading) {
      return;
    }
    try {
      if (formKey.currentState!.validate()) {
        setState(() {
          buttonIsLoading = true;
        });
        postLogInDetailsInAPI(context);
      }
    } catch (e) {
      showSnackbar(context, e.toString(), primaryRedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        if (DateTime.now().isBefore(goBackApp)) {
          SystemNavigator.pop();
          return true;
        }
        goBackApp = DateTime.now().add(const Duration(seconds: 2));
        appExit(
          context,
          "Press again to Exit",
        );
        return false;
      },
      child: Theme(
        data: ThemeClass.lighttheme,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                body: SafeArea(
                  child: Builder(
                    builder: (context) {
                      return isLoaded
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: myHeight * 0.025),
                                    Center(
                                      child: Container(
                                        height: 22.0,
                                        width: 147.0,
                                        decoration: const BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/flattrade_logo.png"))),
                                      ),
                                    ),
                                    SizedBox(height: myHeight * 0.025),
                                    /* Textform field validation */
                                    Form(
                                      key: formKey,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /* Userid validation */
                                          SizedBox(height: myHeight * 0.025),
                                          NameField(
                                            userIdController: userIdController,
                                            labelname: "User ID",
                                            readOnly: clientIdReadOnly,
                                          ),
                                          SizedBox(height: myHeight * 0.010),
                                          Visibility(
                                            visible: clientIdReadOnly,
                                            child: TextButtonWidget(
                                                buttonName:
                                                    "USE ANOTHER ACCOUNT",
                                                buttonFunction: () {
                                                  userIdController.clear();
                                                  pancardController.clear();
                                                  clientIdReadOnly = false;
                                                  isBioMetricAuth = null;
                                                  BiometricAuthentication
                                                      .setBiometricVerify("N");
                                                  setState(() {});
                                                },
                                                fontStyle: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12.0,
                                                    height: 1.71,
                                                    fontFamily: "inter",
                                                    color: Color.fromRGBO(
                                                        9, 101, 218, 1))),
                                          ),
                                          SizedBox(height: myHeight * 0.010),
                                          /* Password validation */
                                          Passwordfield(
                                            passwordController:
                                                passwordController,
                                            labelname: "Password",
                                          ),
                                          SizedBox(height: myHeight * 0.010),
                                          TextButtonWidget(
                                              buttonName: "FORGOT PASSWORD?",
                                              buttonFunction: () {
                                                forgetPassword(context);
                                              },
                                              fontStyle: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12.0,
                                                  height: 1.71,
                                                  fontFamily: "inter",
                                                  color: Color.fromRGBO(
                                                      9, 101, 218, 1))),
                                          SizedBox(height: myHeight * 0.010),
                                          /* pancard Or dateofbirth validation */
                                          Visibility(
                                            visible: isBioMetricAuth == null ||
                                                isBioMetricAuth == false ||
                                                clientIdReadOnly == false,
                                            child: PanCardField(
                                              panController: pancardController,
                                              labelname: "TOTP/OTP",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: myHeight * 0.010),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Visibility(
                                          visible: isBioMetricAuth == null ||
                                              isBioMetricAuth == false,
                                          child: TextButtonWidget(
                                              buttonName: "GET OTP",
                                              buttonFunction: () {
                                                getOtp(context);
                                              },
                                              fontStyle: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12.0,
                                                  height: 1.71,
                                                  fontFamily: "inter",
                                                  color: Color.fromRGBO(
                                                      9, 101, 218, 1))),
                                        ),
                                        Visibility(
                                            visible: isBioMetricAuth == false &&
                                                BiometricAuthentication
                                                    .availableBiometrics
                                                    .isNotEmpty,
                                            child: InkWell(
                                              onTap: bioMetricAuthEnable,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.fingerprint_rounded,
                                                    size: 18,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    'BIOMETRIC',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12.0,
                                                        height: 1,
                                                        fontFamily: "inter",
                                                        color: Color.fromRGBO(
                                                            9, 101, 218, 1)),
                                                  )
                                                ],
                                              ),
                                            )

                                            // ElevatedButton(
                                            //   onPressed: bioMetricAuthEnable,
                                            //   child: const Text("BioMetric"),
                                            // ),
                                            ),
                                      ],
                                    ),
                                    SizedBox(height: myHeight * 0.015),
                                    Center(
                                      child: MaterialButton(
                                        elevation: 2,
                                        minWidth: 250,
                                        height: 45,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        color: appPrimeColor,
                                        onPressed: () => onLogin(),
                                        child: buttonIsLoading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : const Text(
                                                "LOGIN",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w700,
                                                  height: 1.04,
                                                ),
                                              ),
                                      ),
                                    ),
                                    SizedBox(height: myHeight * 0.050),
                                    TextButtonWidget(
                                      buttonName:
                                          "Don't have an account? Signup Now!",
                                      buttonFunction: () {
                                        final url = Uri.parse(
                                            'https://flattrade.in/open-trading-account?utm_source=NovoApp&utm_medium=organic&utm_campaign=Android');

                                        launchUrl(url);
                                      },
                                      fontStyle: const TextStyle(
                                        color: Color(0xFF0965DA),
                                        fontSize: 14,
                                        fontFamily: 'inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: myHeight * 0.030),
                                    Text(
                                      'SEBI Registration No. INZ000201438. Member Code for NSE: 14572 BSE:6524 MCX: 16765 and ICEX: 2010. CDSL DP ID: 12080300 SEBI Registration No.IN-DP-CDSL-729-2014',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: subTitleTextColor,
                                          fontFamily: 'inter'),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Text(
                                        'FLATTRADE is an online brand of Fortune Capital Services Pvt Ltd',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: subTitleTextColor,
                                            fontFamily: 'inter'))
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
