import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/Themes/theme.dart';

import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';

import 'Firebase_setup/firebase_setup.dart';
import 'Roating/route.dart' as route;
import 'firebase_options.dart';
import 'utils/awsomenotificationSetup.dart';

// FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AwesomeNotificationController.initializeLocalNotifications();
  // analytics.setAnalyticsCollectionEnabled(true);

  // try {
  //   // WidgetsFlutterBinding.ensureInitialized();
  //   if (kIsWeb) {
  //     await Firebase.initializeApp(
  //       options: const FirebaseOptions(
  //         apiKey: "AIzaSyCDM04UIi73psmxXX_nxjZxnxwNn3hvyME",
  //         appId: "1:598395567919:android:94f9cc9a055fb0a0702bda",
  //         messagingSenderId: "598395567919",
  //         projectId: "novo-app-flattrade",
  //         storageBucket: "novo-app-flattrade.appspot.com",
  //       ),
  //     );
  //   } else {
  //     await Firebase.initializeApp(
  //         options: const FirebaseOptions(
  //       apiKey: "AIzaSyCDM04UIi73psmxXX_nxjZxnxwNn3hvyME",
  //       appId: "1:598395567919:android:94f9cc9a055fb0a0702bda",
  //       messagingSenderId: "598395567919",
  //       projectId: "novo-app-flattrade",
  //       storageBucket: "novo-app-flattrade.appspot.com",
  //     ));
  //   }
  // } catch (e) {}

  //Firebase Messaging(+)

  firebaseInitialSetup();
  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    print('App Open Listener message');
    // navigateToNotificationScreen(message.data['route'] ?? '');
    // navigatorKey.currentState!.push(MaterialPageRoute(
    //   builder: (context) {
    //     return const NotificationScreen();
    //   },
    // ));
  }, onError: (error) {});
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(handleMessage);
  var token = await FirebaseMessaging.instance.getToken();
  print("token");
  print(token);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => NavigationProvider(),
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AwesomeNotificationController.startListeningNotificationEvents();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'NOVO',
      theme: ThemeClass.lighttheme,
      darkTheme: ThemeClass.Darktheme,
      themeMode: Provider.of<NavigationProvider>(context).themeMode,
      scrollBehavior: MyBehavior(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: route.controller,
      initialRoute: route.flashScreen,
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
