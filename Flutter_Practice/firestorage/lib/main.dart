// import 'package:firebase_core/firebase_core.dart';
// import 'package:firestorage/BNB%20Screen/Screen/initpage.dart';
// import 'package:firestorage/firebase_options.dart';
// import 'package:firestorage/logger/logging_util.dart';
// import 'package:flutter/material.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   await LoggingUtil.initializeLogging();

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'FireBase Storage',
//       home: InitPage(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebViewExample(),
    );
  }
}

class WebViewExample extends StatefulWidget {
  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  WebViewController con1 = WebViewController();

  @override
  void initState() {
    con1
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
          'http://192.168.2.130:8080/?cid=FT000069&app=fund&key=dZml96r4zSkDbcXFIWp4NM9d'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebView Example')),
      body: WebViewWidget(
        controller: con1,
      ),
    );
  }
}
