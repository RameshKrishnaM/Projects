import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ekyc/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'Firebase_and_Facebook/firebase_notification.dart';
import 'Theme/theme.dart';
import 'provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'Route/route.dart' as route;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
}

bool isFlutterLocalNotificationsInitialized = false;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannel channel;
Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ShowPushNotification.init();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Future<void> handleMessage(RemoteMessage? message) async {
  //   // ShowPushNotification.showNotification(fileName: message);
  // }

  FirebaseMessaging.onMessage.listen(ShowPushNotification.showNotification);
  FirebaseMessaging.onMessageOpenedApp
      .listen(ShowPushNotification.showNotification);
  FirebaseMessaging.onBackgroundMessage(ShowPushNotification.showNotification);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(0, 71, 255, 0.81)));
  // runApp(const MyApp());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Postmap()),
        // Add more providers if needed
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  // ConnectivityResult? result;
  // late StreamSubscription<ConnectivityResult> subscription;
  // This widget is the root of your application.
  var result;
  var subscription;
  Postmap? postmap;
  check() {
    String networkStatusText;

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
      default:
        networkStatusText = "Unknown";
        break;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!networkStatusText.contains("Connected")) {
        // print("network not connected");
        postmap!.changeIsNetworkConnected(false);
        // showSnackbar(context, "No internet", Colors.red);
      } else {
        // print("network connected");
        postmap!.changeIsNetworkConnected(true);
        // showSnackbar(context, "Internet connected", Colors.green);
        // ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    postmap = Provider.of<Postmap>(context, listen: false);
    // print("object aaaa");
    // netWorkVerify(context);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      scrollBehavior: MyBehavior(),
      theme: lightTheme.copyWith(useMaterial3: false),
      onGenerateRoute: route.controller,
      debugShowCheckedModeBanner: false,

      initialRoute: route.splashPage,
      // home: const Dummy(),
      // home: SplashScreen(),
      // home: FireBaseDemo()
      // home: const Signup(),
      // home: Page1(),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// import 'dart:convert';
// import 'dart:typed_data';
// import 'Cookies/cookies.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   final String apiUrl = 'http://localhost:your_port/your_api_endpoint';
//   Future<Uint8List> fetchImage() async {
//     // final response = await http.get(Uri.parse(apiUrl));
//     final response = await get1("api/pdffile?id=9499");
//     if (response.statusCode == 200) {
//       print(response.bodyBytes.runtimeType);
//       return response.bodyBytes;
//     } else {
//       throw Exception('Failed to load image');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Local API Image Example'),
//         ),
//         body: Center(
//           child: FutureBuilder<Uint8List>(
//             future: fetchImage(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return CircularProgressIndicator();
//               } else if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               } else if (!snapshot.hasData) {
//                 return Text('No image data');
//               } else {
//                 return Image.memory(
//                   snapshot.data!,
//                   fit: BoxFit.cover,
//                 );
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  m1() async {
    await Future.delayed(Duration(seconds: 3));
    if (mounted) {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Page2(),
                      ),
                      (route) => false);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => Page2(),
                  //     ));
                  m1();
                },
                child: Text("data"))));
  }
}

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ElevatedButton(onPressed: () {}, child: Text("hai"))));
  }
}
