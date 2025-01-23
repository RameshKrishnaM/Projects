// // ignore_for_file: prefer_const_constructors, use_build_context_synchronously, file_names

// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, file_names

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:local_auth/local_auth.dart';
import 'package:novo/API/APICall.dart';
import 'package:novo/Provider/change_index.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/novoModels/dashboardmodel.dart';
import 'package:novo/screens/IPOscreens/Ipopage.dart';
import 'package:novo/screens/MutualFundsScreens/ActiveStatusScreen.dart';
import 'package:novo/screens/NGBscreens/NcbTabPage.dart';
import 'package:novo/screens/SGBscreens/sgbpage.dart';
import 'package:novo/services/biometricuserAuth.dart';
import 'package:novo/utils/colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/NOVO Widgets/LoadingAlertBox.dart';
import '../../widgets/NOVO Widgets/biometricWidget.dart';
import '../../widgets/NOVO Widgets/customLoadingAni.dart';
import '../../widgets/NOVO Widgets/custom_NodataWidget.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../widgets/NOVO Widgets/openSocialmedia.dart';
import '../../widgets/NOVO Widgets/snackbar.dart';
import 'novoDashboard.dart';

class NovoPage extends StatefulWidget {
  final bool showBiometricDailog;
  const NovoPage({super.key, this.showBiometricDailog = true});
  @override
  State<NovoPage> createState() => _NovoPageState();
}

final changeindex = ChangeIndex();

class _NovoPageState extends State<NovoPage> with WidgetsBindingObserver {
  String clientId = '';
  String clientName = '';
  bool isDialogShown = false;
  bool drawerisOpen = false;
  DateTime goBackApp = DateTime.now();
  double screenHeight = 0;
  List<Widget>? pagePropagation;
  // List<Widget> pagePropagation = [
  //   NovoHome(dashboardDetails: novoDashBoardDataList),
  //   Ipopage(),
  //   Sgbpage(),
  //   NcbTabPage(),
  // ];
  NovoDashBoardDetails? novoDashBoardData;
  List<SegmentArr> novoDashBoardDataList = [];
  bool isLoading = true;
  late final LocalAuthentication auth;
  bool isSwitch = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AppLifecycleState? appState;
  bool showBiometric = false;
  String? isEnableBio;
  bool themestatus = false;

  @override
  void initState() {
    super.initState();

    intialFunction(context);
    // getClientDetails();
    // getDashBoardData();
    // Provider.of<NavigationProvider>(context, listen: false).themeModel();
    // setState(() {});
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   getBioMetricVerification();
    // });
    // WidgetsBinding.instance.addObserver(this);

    // auth = LocalAuthentication();
    // auth.isDeviceSupported().then((bool isSupported) {});
  }

  intialFunction(context) async {
    if (await isInternetConnected()) {
      getClientDetails();
      getDashBoardData();
      Provider.of<NavigationProvider>(context, listen: false).themeModel();

      // SharedPreferences sref = await SharedPreferences.getInstance();
      // sref.setBool("isBiometricShow", true);
      // bool showBiometricDailog = sref.getBool("isBiometricShow") ?? true;
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (changeindex.value == 0
            // && showBiometric
            // && showBiometricDailog
            ) {
          getBioMetricVerification();
        }
      });
      WidgetsBinding.instance.addObserver(this);

      auth = LocalAuthentication();
      auth.isDeviceSupported().then((bool isSupported) {});

      // getMfCheckActivateAPI(); //this is enable to check the ac

      Provider.of<NavigationProvider>(context, listen: false).amcFilterArr = [];

      Provider.of<NavigationProvider>(context, listen: false)
          .categoryFilterArr = [];

      Provider.of<NavigationProvider>(context, listen: false)
          .pledgableFilterKey = "";

      setState(() {});
    } else {
      noInternetConnectAlertDialog(context, () => intialFunction(context));
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

  Future<void> checkBiometricAvailability() async {
    try {
      BiometricAuthentication.availableBiometrics =
          await auth.getAvailableBiometrics();

      if (BiometricAuthentication.availableBiometrics.isEmpty &&
          isSwitch == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AskBiometric(
              title: "Biometric Required",
              cancelBtn: () async {
                setState(() {});
                isSwitch = false;
                await BiometricAuthentication.setBiometricVerify("N");
                SystemNavigator.pop();
              },
              onPress: () async {
                await BiometricAuthentication.isBioMetricAvailable(auth);
                if (BiometricAuthentication.availableBiometrics.isEmpty) {
                  await AppSettings.openAppSettings(
                      type: AppSettingsType.lockAndPassword);
                }
                await BiometricAuthentication.authenticate(auth, context);

                if (BiometricAuthentication.isAuthenticated &&
                    BiometricAuthentication.availableBiometrics.isNotEmpty) {
                  await BiometricAuthentication.setBiometricVerify("Y");
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                }
              },
              content:
                  "Biometric authentication is not set up on your device. Go to 'Settings > Security to add biometric authentication.",
              buttonText: 'Go To Settings',
            );
          },
        );
      } else {
        if (BiometricAuthentication.isAuthenticated == false &&
            BiometricAuthentication.availableBiometrics.isNotEmpty) {
          // bioMetricToggle(true);
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> getBioMetricVerification() async {
    isEnableBio = await BiometricAuthentication.getBiometricVerify();

    if ((isEnableBio == "N" || isEnableBio == null)
        // &&
        //     widget.showBiometricDailog
        ) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AskBiometric(
            title: "Set Biometric",
            // title: "SET BIOMETRIC",
            cancelBtn: () {
              Navigator.of(context).pop(false);
              // SharedPreferences sref = await SharedPreferences.getInstance();
              // // bool showBiometricDailog =
              // sref.setBool("isBiometricShow", false);
              // print(sref.getBool("isBiometricShow"));
            },
            onPress: () {
              Navigator.of(context).pop();
              bioMetricToggle(true);
              // _scaffoldKey.currentState?.openDrawer();
            },
            content: "Enable Biometric Authentication",
          );
        },
      );
    } else {
      // if (widget.showBiometricDailog == false) {
      //   // Navigator.of(context).pop(false);
      //   // Navigator.pop(context);
      //   print('Yes))))))))))))))');
      //   setState(() {});
      //   isSwitch = false;
      // } else {
      //   setState(() {});
      //   isSwitch = true;
      // }
      setState(() {});
      isSwitch = true;
      if (isEnableBio == "Y" &&
          BiometricAuthentication.isAuthenticated == false) {
        setState(() {});
        showBiometric = true;
        await BiometricAuthentication.isBioMetricAvailable(auth);
        await BiometricAuthentication.authenticate(auth, context);
        setState(() {});
        showBiometric = false;
        if (BiometricAuthentication.isAuthenticated == false &&
            BiometricAuthentication.availableBiometrics.isNotEmpty) {
          showBiometric = true;
          showVerificationBiometricBox();
        }
      }
    }
  }

  showVerificationBiometricBox() async {
    if (isEnableBio == "Y" &&
        BiometricAuthentication.isAuthenticated == false) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AskBiometric(
            title: "Verificaition Required",
            cancelBtn: () {
              SystemNavigator.pop();
            },
            onPress: () async {
              Navigator.of(context).pop();

              setState(() {});
              showBiometric = true;
              await BiometricAuthentication.isBioMetricAvailable(auth);
              await BiometricAuthentication.authenticate(auth, context);
              showVerificationBiometricBox();
              if (BiometricAuthentication.isAuthenticated) {
                await BiometricAuthentication.setBiometricVerify("Y");
                setState(() {});
                showBiometric = false;
              }
            },
            content: "Please Verify The Biometric Authenication",
          );
        },
      );
    }
  }

  String alartTitle = 'Biometric';
  String alartContent = "Please Enable the Biometric";

  void bioMetricToggle(bool toggle) async {
    print("isSwitch+++++");
    print(isSwitch);
    setState(() {});
    isSwitch = toggle;
    SharedPreferences sref = await SharedPreferences.getInstance();
    String clientId = sref.getString("clientId") ?? "";
    String cookieToken =
        Provider.of<NavigationProvider>(context, listen: false).cookies;
    String token = "";
    if (cookieToken.isNotEmpty) {
      token = cookieToken.split('=')[1].split(';')[0];
    }

    if (isSwitch) {
      await BiometricAuthentication.isBioMetricAvailable(auth);
      if (BiometricAuthentication.availableBiometrics.isEmpty) {
        alartContent =
            "Biometric authentication is not set up on your device. Go to 'Settings>Security' to add biometric authentication.";
        await AppSettings.openAppSettings(
            type: AppSettingsType.lockAndPassword);
      }
      setState(() {});
      showBiometric = true;
      await BiometricAuthentication.authenticate(auth, context);
      if (BiometricAuthentication.isAuthenticated) {
        await BiometricAuthentication.setBiometricVerify("Y");

        setBioMetric(
          context: context,
          bioMetric: {
            "clientId": clientId,
            "token": token,
            "isEnableBio": "Y",
          },
        );

        setState(() {});

        showBiometric = false;
      } else {
        isSwitch = false;
        setState(() {});
        await BiometricAuthentication.setBiometricVerify("N");
        setState(() {});

        showBiometric = false;
      }
    } else {
      await BiometricAuthentication.setBiometricVerify("N");

      setBioMetric(
        context: context,
        bioMetric: {
          "clientId": clientId,
          "token": token,
          "isEnableBio": "N",
        },
      );
    }
  }

  getDashBoardData() async {
    novoDashBoardData = await fetchNovoDashBoardDetails(context: context);

    if (novoDashBoardData != null && novoDashBoardData!.segmentArr != null) {
      novoDashBoardDataList = novoDashBoardData!.segmentArr!
          .where(
              (e) => e.status!.toUpperCase() == 'Y' && getPage(e.path) != null)
          .toList();
    } else {
      novoDashBoardDataList = [];
    }
    pagePropagation = [
      NovoHome(dashboardDetails: novoDashBoardDataList),
      // Ipopage(),
      // Sgbpage(),
      // NcbTabPage(),
      ...novoDashBoardDataList
          .map((e) => getPage(e.path))
          .where((element) => element != null)
    ];

    setState(() {});

    isLoading = false;
  }

  // getPage(value) {
  //   print("value");
  //   print(value);
  //   switch (value) {
  //     case "/ipo":
  //       return Ipopage();
  //     case "/sgb":
  //       return Sgbpage();
  //     case "/gsec":
  //       return NcbTabPage();
  //     case "/mutualfunds":
  //       // return MfMainScreen();
  //       return Ipopage();
  //     // return _conditionalMfMainScreen();
  //     default:
  //       return null;
  //   }
  // }
  getPage(value) {
    switch (value) {
      case "/ipo":
        // changeindex.value = 1;
        return Ipopage();
      case "/sgb":
        // changeindex.value = 2;
        return Sgbpage();
      case "/gsec":
        // changeindex.value = 3;
        return NcbTabPage();
      case "/mutualfunds":
        // changeindex.value = 4;
        // return MfMainScreen();
        return MFactiveScreen();
      // return mutualCondition;

      // return Ipopage();
      // return _conditionalMfMainScreen();
      default:
        return null;
    }
  }

  // Widget mfActiveStatus(NavigationProvider value) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     showRiskDisclosureDialog(context, value);
  //   });
  //   return Container(
  //     color: Colors.transparent,
  //   );
  // }

  // Widget mutualCondition() {
  //   var navigationProvider =
  //       Provider.of<NavigationProvider>(context, listen: false);
  //   if ((navigationProvider.mfCheckActive['status'] == 'W' ||
  //           navigationProvider.mfCheckActive['status'] == 'R' ||
  //           navigationProvider.mfCheckActive['status'] == 'E') &&
  //       navigationProvider.mfCheckActive['mfSoftLiveKey'] == 'Y') {
  //     return mfActiveStatus(navigationProvider);
  //   } else {
  //     return MfMainScreen();
  //   }
  // }

  getClientDetails() async {
    try {
      if (await isInternetConnected()) {
        clientId = await validateToken(context);
        SharedPreferences sref = await SharedPreferences.getInstance();
        sref.setString("clientId", clientId);
        clientName = await getClientName(context);
      } else {
        noInternetConnectAlertDialog(context, () => getClientDetails());
      }
      setState(() {});
    } catch (e) {
      showSnackbar(context, somethingError, Colors.red);
    }
    return null;
  }

  closeLogoutLoadingAlertBox() async {
    if (!await logout(context)) {
      Navigator.of(context).pop();
    }
  }

  willPopScopeFunc() async {
    if (drawerisOpen) {
      Navigator.of(context).pop();
      return false;
    }

    if (isDialogShown) {
      return true; // Allow the back button to exit
    }
    if (DateTime.now().isBefore(goBackApp)) {
      SystemNavigator.pop();
      return true;
    }

    if (changeindex.value != 0) {
      changeindex.value = 0;
      return false;
    }

    goBackApp = DateTime.now().add(Duration(seconds: 2));
    appExit(
      context,
      "Press again to Exit",
    );

    return false;
  }

  //MFMethods

  // Map<String, dynamic> mfboActive = {};
  // getMfCheckActivateAPI() async {
  //   var response = await fetchMfCheckActivate(context);
  //   print(response);

  //   if (response != null) {
  //     setState(() {
  //       navigationProvider.mfCheckActive = response;
  //     });
  //   } else {
  //     navigationProvider.mfCheckActive = {};
  //   }
  // }

  // getMfboActivateAPI(context) async {
  //   NavigationProvider navigationProvider =
  //       Provider.of<NavigationProvider>(context, listen: false);
  //   if (navigationProvider.mfCheckActive['status'] == 'R' ||
  //       navigationProvider.mfCheckActive['status'] == 'W') {
  //     String data = '';
  //     if (navigationProvider.mfCheckActive['status'] == 'R') {
  //       data = 'REGISTERED';
  //     } else if (navigationProvider.mfCheckActive['status'] == 'W') {
  //       data = 'NEW';
  //     }
  //     var response = await fetchMfBoActivate(context, data);

  //     if (response != null) {
  //       if (response['status'] == 'S') {
  //         if (navigationProvider.mfCheckActive['status'] == 'R') {
  //           print('show the url launcher');
  //           print(navigationProvider.mfCheckActive['navigateLink']);
  //           // launchUrl(navigationProvider.mfCheckActive['navigateLink']);
  //           launchUrlFunction(navigationProvider.mfCheckActive['navigateLink']);
  //           setState(() {
  //             changeindex.value = 0;
  //           });
  //           navigationProvider.getMfCheckActivateAPI(context);
  //           Navigator.pop(context);
  //         } else if (navigationProvider.mfCheckActive['status'] == 'W') {
  //           setState(() {
  //             changeindex.value = 0;
  //           });
  //           navigationProvider.getMfCheckActivateAPI(context);
  //           Navigator.pop(context);
  //         }
  //       } else {
  //         Navigator.pop(context);
  //       }
  //     }
  //   } else {}
  // }

  // Widget _conditionalMfMainScreen() {
  //   print('+++++++++++++++++=====');

  //   NavigationProvider navigationProvider =
  //       Provider.of<NavigationProvider>(context, listen: false);
  //   navigationProvider.getMfCheckActivateAPI(context);
  //   print(navigationProvider.mfCheckActive['status']);
  //   print(navigationProvider.mfCheckActive['mfSoftLiveKey']);
  //   print((navigationProvider.mfCheckActive['status'] == 'W' ||
  //           navigationProvider.mfCheckActive['status'] == 'R' ||
  //           navigationProvider.mfCheckActive['status'] == 'E') &&
  //       navigationProvider.mfCheckActive['mfSoftLiveKey'] == 'Y');
  //   if ((navigationProvider.mfCheckActive['status'] == 'W' ||
  //           navigationProvider.mfCheckActive['status'] == 'R' ||
  //           navigationProvider.mfCheckActive['status'] == 'E') &&
  //       navigationProvider.mfCheckActive['mfSoftLiveKey'] == 'Y') {
  //     print('conditiontrue');
  //     // Show MFMainScreen if terms are accepted
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       _showRiskDisclosureDialog(context);
  //     });
  //     return Container(
  //       color: Colors.transparent,
  //     );
  //   }
  //   // else if (navigationProvider.mfCheckActive['status'] == 'E') {
  //   //   // showSnackbar(context, navigationProvider.mfCheckActive['errMsg'], primaryRedColor);
  //   //   return Placeholder();
  //   // }
  //   else {
  //     print('conditionfalse');
  //     return MfMainScreen();
  //     // Show dialog and return an empty Container until the dialog is handled
  //     // Prevent navigation until dialog is handled
  //   }
  // }

  // void _showRiskDisclosureDialog(context) {
  //   NavigationProvider navigationProvider =
  //       Provider.of<NavigationProvider>(context, listen: false);
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         // title: Row(
  //         //   mainAxisAlignment: MainAxisAlignment.start,
  //         //   crossAxisAlignment: CrossAxisAlignment.end,
  //         //   children: [
  //         //     Icon(
  //         //       Icons.info_outline,
  //         //       size: 17,
  //         //       color: Theme.of(context).brightness == Brightness.dark
  //         //           ? Colors.blue
  //         //           : appPrimeColor,
  //         //     ),
  //         //     SizedBox(
  //         //       width: 10,
  //         //     ),
  //         //     Text(
  //         //       'Mutual Fund Activation Status',
  //         //       style: Theme.of(context).textTheme.titleMedium!.copyWith(
  //         //           color: Theme.of(context).brightness == Brightness.dark
  //         //               ? Colors.blue
  //         //               : appPrimeColor),
  //         //     ),
  //         //   ],
  //         // ),
  //         contentPadding: EdgeInsets.only(
  //           top: 15,
  //         ),
  //         content: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Icon(
  //                 Icons.info_outline,
  //                 size: 15,
  //                 color: Theme.of(context).brightness == Brightness.dark
  //                     ? Colors.blue
  //                     : appPrimeColor,
  //               ),
  //               SizedBox(
  //                 width: 5,
  //               ),
  //               Flexible(
  //                 child: Text(
  //                   navigationProvider.mfCheckActive['errMsg'] ??
  //                       somethingError,
  //                   textAlign: TextAlign.justify,
  //                   overflow: TextOverflow.visible,
  //                   style: Theme.of(context).textTheme.bodyMedium,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actionsPadding: EdgeInsets.only(right: 15),
  //         actions: [
  //           Visibility(
  //             visible: navigationProvider.mfCheckActive['boActive'] == 'Y',
  //             child: TextButton(
  //               onPressed: () async {
  //                 // if (navigationProvider.mfCheckActive['status']=='R') {

  //                 // } else {
  //                 await getMfboActivateAPI(
  //                   context,
  //                 );
  //                 // }
  //               },
  //               child: Text(
  //                 'Send Request',
  //                 style: Theme.of(context)
  //                     .textTheme
  //                     .bodySmall!
  //                     .copyWith(color: primaryGreenColor),
  //               ),
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               changeindex.value = 0;
  //               // Close dialog without accepting
  //             },
  //             child: Text(
  //               'Cancel',
  //               style: Theme.of(context)
  //                   .textTheme
  //                   .bodySmall!
  //                   .copyWith(color: primaryRedColor),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // var dartThemeMode =
    //     Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    getVersion(context, snapshot) {
      if (snapshot.hasData) {
        return Text(
          'Version: ${snapshot.data!.version}',
          style: TextStyle(
              color: themeBasedColor,
              fontSize: subTitleFontSize,
              fontFamily: 'inter'),
        );
      } else {
        return Text(
            'Version'); // You can display a loading indicator here if needed.
      }
    }

    return WillPopScope(
        onWillPop: () => willPopScopeFunc(),
        child: showBiometric
            ? Container(
                height: MediaQuery.of(context).size.height,
                color: Provider.of<NavigationProvider>(context).themeMode ==
                        ThemeMode.dark
                    ? titleTextColorLight
                    : titleTextColorDark,
                child: Center(
                  child: Image.asset(
                    // "assets/Novo_Animation .gif",
                    // "assets/Novo_app_Logo.png",
                    "assets/novo_logo_Transp.png",
                    height: 80,
                  ),
                ),
              )
            : ValueListenableBuilder(
                valueListenable: changeindex,
                builder: (context, value, child) {
                  var darkThemeMode =
                      Provider.of<NavigationProvider>(context).themeMode ==
                          ThemeMode.dark;
                  return Scaffold(
                    key: _scaffoldKey,
                    onDrawerChanged: (isOpened) => drawerisOpen = isOpened,
                    drawerEdgeDragWidth:
                        MediaQuery.of(context).size.width * 0.10,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      systemOverlayStyle: SystemUiOverlayStyle(
                          statusBarColor: Colors.transparent,
                          systemNavigationBarDividerColor: Colors.transparent,
                          statusBarIconBrightness: darkThemeMode
                              ? Brightness.light
                              : Brightness.dark),
                      elevation: 0,
                      title: GestureDetector(
                        onTap: () {
                          changeindex.value = 0;
                        },
                        child: Image.asset(
                          Provider.of<NavigationProvider>(context).themeMode ==
                                  ThemeMode.dark
                              ? 'assets/novoLogoBlack.png'
                              : 'assets/Novo Transp.png',
                          width: 100.0,
                          height: 100.0,
                        ),
                      ),
                      centerTitle: true,
                      leading: Builder(builder: (context) {
                        return InkWell(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                            // changeindex.value = 0;
                          },
                          child: Icon(
                            Icons.menu_rounded,
                            color: themeBasedColor,
                            size: 25,
                          ),
                        );
                      }),
                      //old novo widget
                      // leading: Builder(
                      //   builder: (BuildContext context) {
                      //     return IconButton(
                      //         icon: Icon(
                      //           CupertinoIcons.line_horizontal_3,
                      //           color: themeBasedColor,
                      //           size: 25,
                      //         ), // Use the menu icon for the drawer
                      //         onPressed: () {
                      //           Scaffold.of(context)
                      //               .openDrawer(); // Open the drawer
                      //         },
                      //         color: themeBasedColor);
                      //   },
                      // ),
                    ),
//BottomNavigation Removed From the MF Screen is Present
                    // bottomNavigationBar: changeindex.value == 0 ||
                    //         isLoading ||
                    //         novoDashBoardDataList.isEmpty
                    //     ? SizedBox()
                    //     : CurvedNavigationBar(
                    //         height: 60,
                    //         backgroundColor: Colors.transparent,
                    //         color: appPrimeColor,
                    //         animationDuration: Duration(milliseconds: 500),
                    //         index: changeindex.value - 1 < 0
                    //             ? 0
                    //             : changeindex.value - 1,
                    //         onTap: (newValue) {
                    //           changeindex.value = newValue + 1;
                    //           ChangeNCBIndex().changeNCBIndex(0);
                    //         },
                    //         items: <Widget>[
                    //             ...novoDashBoardDataList.map(
                    //               (e) => Padding(
                    //                 padding: const EdgeInsets.all(4.0),
                    //                 child: Column(
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment.center,
                    //                   crossAxisAlignment:
                    //                       CrossAxisAlignment.center,
                    //                   children: [
                    //                     e.path == '/ipo'
                    //                         ? Image.asset(
                    //                             'assets/IPO WNovo Icon.png',
                    //                             width: 27,
                    //                           )
                    //                         : e.path == '/sgb'
                    //                             ? Image.asset(
                    //                                 'assets/SGB WNovo Icon.png',
                    //                                 width: 34,
                    //                               )
                    //                             : e.path == '/gsec'
                    //                                 ? Image.asset(
                    //                                     'assets/NCB W.png',
                    //                                     width: 30,
                    //                                   )
                    //                                 : SizedBox(),
                    //                     // dartThemeMode
                    //                     //     ?
                    //                     // Image.network(e.darkThemeImage!,
                    //                     //     width: e.path == '/ipo'
                    //                     //         ? 27
                    //                     //         : e.path == '/sgb'
                    //                     //             ? 34
                    //                     //             : e.path == '/gsec'
                    //                     //                 ? 30
                    //                     //                 : 30, errorBuilder:
                    //                     //         (context, error, stackTrace) {
                    //                     //   return e.path == '/ipo'
                    //                     //       ? Image.asset(
                    //                     //           'assets/IPO WNovo Icon.png',
                    //                     //           width: 27,
                    //                     //         )
                    //                     //       : e.path == '/sgb'
                    //                     //           ? Image.asset(
                    //                     //               'assets/SGB WNovo Icon.png',
                    //                     //               width: 34,
                    //                     //             )
                    //                     //           : e.path == '/gsec'
                    //                     //               ? Image.asset(
                    //                     //                   'assets/NCB W.png',
                    //                     //                   width: 30,
                    //                     //                 )
                    //                     //               : SizedBox();
                    //                     //   // SizedBox();
                    //                     // }
                    //                     // SizedBox(),
                    //                     // ),
                    //                     // : Image.network(
                    //                     //     e.image!,
                    //                     //     width: 30,
                    //                     //     errorBuilder:
                    //                     //         (context, error, stackTrace) =>
                    //                     //             SizedBox(),
                    //                     // ),
                    //                     SizedBox(
                    //                       height: 3.0,
                    //                     ),
                    //                     Text(
                    //                       e.name!,
                    //                       style: TextStyle(
                    //                           fontSize: 10,
                    //                           color: Colors.white,
                    //                           fontFamily: 'Kiro'),
                    //                     )
                    //                   ],
                    //                 ),
                    //               ),
                    //             )
                    //             // Padding(
                    //             //   padding: const EdgeInsets.all(4.0),
                    //             //   child: Column(
                    //             //     mainAxisAlignment: MainAxisAlignment.center,
                    //             //     crossAxisAlignment: CrossAxisAlignment.center,
                    //             //     children: [
                    //             //       Image.asset(
                    //             //         'assets/layout.png',
                    //             //         width: 30,
                    //             //       ),
                    //             //       Text(
                    //             //         'novo',
                    //             //         style: TextStyle(
                    //             //             fontSize: 12,
                    //             //             color: Colors.white,
                    //             //             fontFamily: 'Kiro'),
                    //             //       )
                    //             //     ],
                    //             //   ),
                    //             // ),
                    //             // Padding(
                    //             //   padding: const EdgeInsets.all(4.0),
                    //             //   child: Column(
                    //             //     mainAxisAlignment: MainAxisAlignment.center,
                    //             //     crossAxisAlignment: CrossAxisAlignment.center,
                    //             //     children: [
                    //             //       Image.asset(
                    //             //         'assets/IPO WNovo Icon.png',
                    //             //         width: 27,
                    //             //       ),
                    //             //       SizedBox(
                    //             //         height: 3.0,
                    //             //       ),
                    //             //       Text(
                    //             //         'IPO',
                    //             //         style: TextStyle(
                    //             //             fontSize: 10,
                    //             //             color: Colors.white,
                    //             //             fontFamily: 'Kiro'),
                    //             //       )
                    //             //     ],
                    //             //   ),
                    //             // ),
                    //             // Padding(
                    //             //   padding: const EdgeInsets.all(2.0),
                    //             //   child: Column(
                    //             //     mainAxisAlignment: MainAxisAlignment.center,
                    //             //     crossAxisAlignment: CrossAxisAlignment.center,
                    //             //     children: [
                    //             //       Image.asset(
                    //             //         'assets/SGB WNovo Icon.png',
                    //             //         width: 34,
                    //             //       ),
                    //             //       SizedBox(
                    //             //         height: 3.0,
                    //             //       ),
                    //             //       Text(
                    //             //         'SGB',
                    //             //         style: TextStyle(
                    //             //             fontSize: 10,
                    //             //             color: Colors.white,
                    //             //             fontFamily: 'Kiro'),
                    //             //       )
                    //             //     ],
                    //             //   ),
                    //             // ),
                    //             // Padding(
                    //             //   padding: const EdgeInsets.all(6.0),
                    //             //   child: Column(
                    //             //     mainAxisAlignment: MainAxisAlignment.center,
                    //             //     crossAxisAlignment: CrossAxisAlignment.center,
                    //             //     children: [
                    //             //       Image.asset(
                    //             //         'assets/NCB W.png',
                    //             //         width: 30,
                    //             //       ),
                    //             //       Text(
                    //             //         'G-Sec',
                    //             //         style: TextStyle(
                    //             //             fontSize: 11,
                    //             //             color: Colors.white,
                    //             //             fontFamily: 'Kiro'),
                    //             //       )
                    //             //     ],
                    //             //   ),
                    //             // ),
                    //           ]),
                    drawer: Drawer(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: DrawerHeader(
                                margin: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                    color:
                                        Provider.of<NavigationProvider>(context)
                                                    .themeMode ==
                                                ThemeMode.dark
                                            ? titleTextColorLight
                                            : appPrimeColor),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      clientName,
                                      maxLines: 3,
                                      style: TextStyle(
                                          overflow: TextOverflow.clip,
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Kiro'),
                                    ),
                                    Text(
                                      clientId.toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Kiro'),
                                    ),
                                  ],
                                )),
                          ),
                          ListTile(
                            dense: true,
                            leading: Image.asset(
                              "assets/layout.png",
                              width: 20.0,
                              color: Provider.of<NavigationProvider>(context)
                                          .themeMode ==
                                      ThemeMode.dark
                                  ? titleTextColorDark
                                  : titleTextColorLight,
                            ),
                            title: Text(
                              "NOVO",
                              style: TextStyle(
                                  fontFamily: 'Kiro',
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: changeindex.value == 0
                                      ? Provider.of<NavigationProvider>(context)
                                                  .themeMode ==
                                              ThemeMode.dark
                                          ? Colors.blue.shade400
                                          : appPrimeColor
                                      : Provider.of<NavigationProvider>(context)
                                                  .themeMode ==
                                              ThemeMode.dark
                                          ? titleTextColorDark
                                          : titleTextColorLight),
                            ),
                            onTap: () {
                              changeindex.value = 0;

                              Navigator.pop(context);
                            },
                          ),
                          ...novoDashBoardDataList.map(
                            (e) => ListTile(
                              dense: true,
                              leading: Provider.of<NavigationProvider>(context)
                                          .themeMode ==
                                      ThemeMode.dark
                                  ? Image.network(
                                      "${e.darkThemeImage}",
                                      width: 20.0,
                                    )
                                  : Image.network(
                                      "${e.image}",
                                      width: 20.0,
                                    ),
                              title: Text(
                                '${e.name}',
                                style: TextStyle(
                                    fontFamily: 'Kiro',
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: changeindex.value ==
                                            novoDashBoardDataList.indexOf(e) + 1
                                        ? Provider.of<NavigationProvider>(
                                                        context)
                                                    .themeMode ==
                                                ThemeMode.dark
                                            ? Colors.blue.shade400
                                            : appPrimeColor
                                        : Provider.of<NavigationProvider>(
                                                        context)
                                                    .themeMode ==
                                                ThemeMode.dark
                                            ? titleTextColorDark
                                            : titleTextColorLight),
                              ),
                              onTap: () {
                                changeindex.value =
                                    novoDashBoardDataList.indexOf(e) + 1;
                                MFChangeIndex().value = 0;

                                Navigator.pop(context);
                              },
                            ),
                          ),
                          ListTile(
                            // selected: changeindex.value == 6,
                            // selectedTileColor: darkThemeMode
                            //     ? modifyButtonColor.withOpacity(0.1)
                            //     : modifyButtonColor.withOpacity(0.5),
                            dense: true,
                            title: Text(
                              !darkThemeMode ? "DARK THEME" : "LIGHT THEME",
                              style: TextStyle(
                                  fontFamily: 'Kiro',
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: changeindex.value == 6
                                      ? darkThemeMode
                                          ? Colors.blue.shade400
                                          : appPrimeColor
                                      : darkThemeMode
                                          ? titleTextColorDark
                                          : titleTextColorLight),
                            ),
                            leading: !darkThemeMode
                                ? Icon(
                                    CupertinoIcons.moon_stars_fill,
                                    color: themeBasedColor,
                                    size: 20.0,
                                  )
                                : Icon(
                                    CupertinoIcons.brightness_solid,
                                    color: themeBasedColor,
                                    size: 20.0,
                                  ),
                            trailing: Container(
                              width: 43,
                              height: 18,
                              child: FlutterSwitch(
                                valueFontSize: 8.0,
                                toggleSize: 9.0,
                                value: themestatus,
                                inactiveIcon: Transform.scale(
                                  scale: 8,
                                  child: Icon(
                                    CupertinoIcons.moon_stars_fill,
                                    color: titleTextColorLight,
                                    size: 50.0,
                                  ),
                                ),
                                activeIcon: Transform.scale(
                                  scale: 8,
                                  child: Icon(
                                    CupertinoIcons.brightness_solid,
                                    color: titleTextColorLight,
                                    size: 50.0,
                                  ),
                                ),

                                borderRadius: 8.0,
                                // padding: 5.0,

                                activeColor: appPrimeColor,
                                inactiveColor:
                                    titleTextColorLight.withOpacity(0.8),
                                inactiveText: 'Dark',
                                activeText: 'Light',
                                showOnOff: true,
                                onToggle: (val) {
                                  setState(() {
                                    themestatus = val;
                                    Provider.of<NavigationProvider>(context,
                                            listen: false)
                                        .toggleTheme();
                                  });
                                },
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                themestatus = !themestatus;
                                // changeindex.value = 6;

                                // Navigator.pop(context);
                                Provider.of<NavigationProvider>(context,
                                        listen: false)
                                    .toggleTheme();
                              });
                            },
                          ),

                          // Flexible(
                          //   fit: FlexFit.loose,
                          //   child: ListView.builder(
                          //     shrinkWrap: true,
                          //     itemCount: novoDashBoardDataList.length,
                          //     itemBuilder: (BuildContext context, int index) {
                          //       return Container(
                          //         color: Colors.blue,
                          //         child: ListTile(
                          //           dense: true,
                          //           leading: Image.asset(
                          //             Provider.of<NavigationProvider>(context)
                          //                         .themeMode ==
                          //                     ThemeMode.dark
                          //                 ? "assets/IPO WNovo Icon.png"
                          //                 : "assets/IPO BNovo Icon.png",
                          //             width: 20.0,
                          //           ),
                          //           title: Text(
                          //             '${novoDashBoardDataList[index].name}',
                          //             style: TextStyle(
                          //                 fontFamily: 'Kiro',
                          //                 fontSize: titleFontSize,
                          //                 fontWeight: FontWeight.bold,
                          //                 color: changeindex.value == 1
                          //                     ? Provider.of<NavigationProvider>(
                          //                                     context)
                          //                                 .themeMode ==
                          //                             ThemeMode.dark
                          //                         ? Colors.blue.shade400
                          //                         : appPrimeColor
                          //                     : Provider.of<NavigationProvider>(
                          //                                     context)
                          //                                 .themeMode ==
                          //                             ThemeMode.dark
                          //                         ? titleTextColorDark
                          //                         : titleTextColorLight),
                          //           ),
                          //           onTap: () {
                          //             changeindex.value = 1;

                          //             Navigator.pop(context);
                          //           },
                          //         ),
                          //       );
                          //     },
                          //   ),
                          // ),

                          // ListTile(
                          //   dense: true,
                          //   leading: Image.asset(
                          //     Provider.of<NavigationProvider>(context).themeMode ==
                          //             ThemeMode.dark
                          //         ? "assets/IPO WNovo Icon.png"
                          //         : "assets/IPO BNovo Icon.png",
                          //     width: 20.0,
                          //   ),
                          //   title: Text(
                          //     "IPO",
                          //     style: TextStyle(
                          //         fontFamily: 'Kiro',
                          //         fontSize: titleFontSize,
                          //         fontWeight: FontWeight.bold,
                          //         color: changeindex.value == 1
                          //             ? Provider.of<NavigationProvider>(context)
                          //                         .themeMode ==
                          //                     ThemeMode.dark
                          //                 ? Colors.blue.shade400
                          //                 : appPrimeColor
                          //             : Provider.of<NavigationProvider>(context)
                          //                         .themeMode ==
                          //                     ThemeMode.dark
                          //                 ? titleTextColorDark
                          //                 : titleTextColorLight),
                          //   ),
                          //   onTap: () {
                          //     changeindex.value = 1;

                          //     Navigator.pop(context);
                          //   },
                          // ),
                          // ListTile(
                          //   dense: true,
                          //   leading: Image.asset(
                          //     Provider.of<NavigationProvider>(context).themeMode ==
                          //             ThemeMode.dark
                          //         ? "assets/SGB WNovo Icon.png"
                          //         : "assets/SGB BNovo Icon.png",
                          //     width: 25.0,
                          //   ),
                          //   title: Text(
                          //     "SGB",
                          //     style: TextStyle(
                          //         fontFamily: 'Kiro',
                          //         fontSize: titleFontSize,
                          //         fontWeight: FontWeight.bold,
                          //         color: changeindex.value == 2
                          //             ? Provider.of<NavigationProvider>(context)
                          //                         .themeMode ==
                          //                     ThemeMode.dark
                          //                 ? Colors.blue.shade400
                          //                 : appPrimeColor
                          //             : themeBasedColor),
                          //   ),
                          //   onTap: () {
                          //     changeindex.value = 2;

                          //     Navigator.pop(context);
                          //   },
                          // ),
                          // ListTile(
                          //   dense: true,
                          //   leading: Image.asset(
                          //     Provider.of<NavigationProvider>(context).themeMode ==
                          //             ThemeMode.dark
                          //         ? "assets/NCB W.png"
                          //         : "assets/NCB B.png",
                          //     width: 25.0,
                          //   ),
                          //   title: Text(
                          //     "G-Sec",
                          //     style: TextStyle(
                          //         fontFamily: 'Kiro',
                          //         fontSize: titleFontSize,
                          //         fontWeight: FontWeight.bold,
                          //         color: changeindex.value == 3
                          //             ? Provider.of<NavigationProvider>(context)
                          //                         .themeMode ==
                          //                     ThemeMode.dark
                          //                 ? Colors.blue.shade400
                          //                 : appPrimeColor
                          //             : themeBasedColor),
                          //   ),
                          //   onTap: () {
                          //     ChangeNCBIndex().changeNCBIndex(0);
                          //     changeindex.value = 3;

                          //     Navigator.pop(context);
                          //   },
                          // ),

                          // ListTile(
                          //   dense: true,
                          //   leading: Switch(
                          //     activeColor: Color.fromRGBO(9, 101, 218, 1),
                          //     trackOutlineWidth:
                          //         const WidgetStatePropertyAll(1),
                          //     value: isSwitch,
                          //     onChanged: bioMetricToggle,
                          //   ),
                          //   title: Text(
                          //     "BioMetric",
                          //     style: TextStyle(
                          //       fontFamily: 'Kiro',
                          //       fontSize: titleFontSize,
                          //       fontWeight: FontWeight.bold,
                          //       color: themeBasedColor,
                          //     ),
                          //   ),
                          // ),
                          ListTile(
                            selected: changeindex.value == 7,
                            selectedTileColor: darkThemeMode
                                ? modifyButtonColor.withOpacity(0.1)
                                : modifyButtonColor.withOpacity(0.5),
                            dense: true,
                            leading: darkThemeMode
                                ? Image.asset(
                                    "assets/Biomet W.png",
                                    width: 25.0,
                                    color: titleTextColorDark,
                                  )
                                : Image.asset(
                                    "assets/Biomet B.png",
                                    width: 25.0,
                                    color: titleTextColorLight,
                                  ),
                            title: Text(
                              "BIOMETRIC",
                              style: TextStyle(
                                  fontFamily: 'Kiro',
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: changeindex.value == 7
                                      ? darkThemeMode
                                          ? Colors.blue.shade400
                                          : appPrimeColor
                                      : darkThemeMode
                                          ? titleTextColorDark
                                          : titleTextColorLight),
                            ),
                            trailing: SizedBox(
                              width: 43,
                              height: 18,
                              child: FlutterSwitch(
                                // width: 55.0,
                                // height: 55.0,
                                valueFontSize: 8.0,
                                toggleSize: 9.0,
                                value: isSwitch,
                                borderRadius: 8.0,
                                // padding: 5.0,
                                activeColor: appPrimeColor,
                                inactiveColor:
                                    titleTextColorLight.withOpacity(0.8),
                                // activeText: 'dark',
                                showOnOff: true,
                                onToggle: (val) {
                                  bioMetricToggle(val);
                                  // setState(() {
                                  //   isSwitch = val;
                                  // });
                                },
                              ),
                            ),
                            onTap: () {
                              bioMetricToggle(!isSwitch);
                              // bioMetricToggle();
                              // changeindex.value = 7;

                              // Navigator.pop(context);
                            },
                          ),

                          ListTile(
                            dense: true,
                            leading: Icon(
                              CupertinoIcons.power,
                              size: 17,
                              color: themeBasedColor,
                            ),
                            title: Text(
                              "LOGOUT",
                              style: TextStyle(
                                fontFamily: 'Kiro',
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: themeBasedColor,
                              ),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Text(
                                      'Do you want to Logout ?',
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          color: themeBasedColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    actions: [
                                      SizedBox(
                                        height: 25.0,
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                                shape: WidgetStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    18.0))),
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                        subTitleTextColor)),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text('No',
                                                style: TextStyle(
                                                    fontFamily: 'inter',
                                                    fontSize: 12.0,
                                                    color: Colors.white))),
                                      ),
                                      SizedBox(
                                        height: 25.0,
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                                shape: WidgetStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    18.0))),
                                                backgroundColor: WidgetStatePropertyAll(
                                                    // Provider.of<NavigationProvider>(
                                                    //                 context)
                                                    //             .themeMode ==
                                                    //         ThemeMode.dark
                                                    //     ? Colors.white
                                                    //     :
                                                    appPrimeColor)),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              loadingAlertBox(
                                                  context, 'Logging Out...');
                                              closeLogoutLoadingAlertBox();
                                            },
                                            child: Text(
                                              'Yes',
                                              style: TextStyle(
                                                  fontFamily: 'inter',
                                                  fontSize: 12.0,
                                                  color: Colors.white),
                                            )),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Implement logout functionality
                            },
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/Facebook.png",
                                height: 25.0,
                                width: 25.0,
                                color: darkThemeMode
                                    ? Colors.white
                                    : appPrimeColor,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () => openApp(
                                    context,
                                    'WhatsApp',
                                    'https://wa.me/channel/0029Va5e3xX2P59q5v1G8g13',
                                    'https://play.google.com/store/apps/details?id=com.whatsapp'),
                                child: Image.asset(
                                  "assets/Whatsapp.png",
                                  height: 25.0,
                                  width: 25.0,
                                  color: darkThemeMode
                                      ? Colors.white
                                      : appPrimeColor,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () => openApp(
                                    context,
                                    'Instagram',
                                    'instagram://user?username=flattradein',
                                    'https://play.google.com/store/apps/details?id=com.instagram'),
                                child: Image.asset(
                                  "assets/Insta.png",
                                  height: 25.0,
                                  width: 25.0,
                                  color: darkThemeMode
                                      ? Colors.white
                                      : appPrimeColor,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () => openApp(
                                  context,
                                  'LinkedIn',
                                  'https://www.linkedin.com/company/flattradein/',
                                  'https://play.google.com/store/apps/details?id=com.linkedin.android',
                                ),
                                child: Image.asset(
                                  "assets/Linkedin.png",
                                  height: 25.0,
                                  width: 25.0,
                                  color: darkThemeMode
                                      ? Colors.white
                                      : appPrimeColor,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () => openApp(
                                  context,
                                  'Twitter',
                                  'twitter://user?screen_name=Flattradein',
                                  'https://play.google.com/store/apps/details?id=com.twitter.android',
                                ),
                                child: Image.asset(
                                  "assets/Twitter.png",
                                  height: 25.0,
                                  width: 25.0,
                                  color: darkThemeMode
                                      ? Colors.white
                                      : appPrimeColor,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () => openApp(
                                  context,
                                  'YouTube',
                                  'vnd.youtube://channel/UCqoiLYmVTt4dsFO4YOBAXuQ',
                                  'https://play.google.com/store/apps/details?id=com.google.android.youtube',
                                ),
                                child: Image.asset(
                                  "assets/Youtube.png",
                                  height: 25.0,
                                  width: 25.0,
                                  color: darkThemeMode
                                      ? Colors.white
                                      : appPrimeColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (context, snapshot) =>
                                getVersion(context, snapshot),
                          ),
                          SizedBox(
                            height: 15.0,
                          )
                        ],
                      ),
                    ),
                    body: isLoading
                        ? Center(child: LoadingProgress())
                        : SafeArea(
                            bottom: false,
                            child: pagePropagation == null
                                ? noDataFoundWidget(context)
                                :
                                // changeindex.getIndex == 1
                                //     ? _conditionalMfMainScreen()
                                //     :
                                pagePropagation![changeindex.getIndex],
                          ),
                    //This is OldNovo conditons
                    // isLoading
                    //     ? Center(child: LoadingProgress())
                    //     : pagePropagation![changeindex.getIndex],
                  );
                },
              ));
  }
}
