// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// class MyWebWidget extends StatefulWidget {
//   const MyWebWidget({super.key});

//   @override
//   State<MyWebWidget> createState() => _MyWebWidgetState();
// }
// //http://192.168.2.70:28595/api/esignFormrequestcdsl
// //{Origin: https://instakyc.flattrade.in, Referer: https://instakyc.flattrade.in, cookie: ftek_yc_ck=2a8b62fcfeb23eedfca0ebccdd2d989532a675991ae645c0cb5db131fac2093d; Path=/; Domain=localhost; Max-Age=2592000; HttpOnly; Secure; SameSite=Strict, User-Agent: InstaKYC/1.1.5 (Android), app_mode: app, api-version: v2}

// class _MyWebWidgetState extends State<MyWebWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//           child: Column(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(
//               url: WebUri(
//                   "http://192.168.2.70:28595/api/esignFormrequestcdsl"), // Replace with your API URL
//               headers: {
//                 "Origin": "https://instakyc.flattrade.in",
//                 "Referer": "https://instakyc.flattrade.in",
//                 "cookie":
//                     "ftek_yc_ck=2a8b62fcfeb23eedfca0ebccdd2d989532a675991ae645c0cb5db131fac2093d; Path=/; Domain=localhost; Max-Age=2592000; HttpOnly; Secure; SameSite=Strict",
//                 "User-Agent": "InstaKYC/1.1.5 (Android)",
//                 "app_mode": "app",
//                 "api - version": "v2"
//               },
//             ),
//           ),
//           // Expanded(
//           //     child: Stack(
//           //   children: [
//           //     WebViewWidget(
//           //       controller: con1,
//           //     ),
//           //     if (loadingPercentage < 100)
//           //       LinearProgressIndicator(
//           //         value: loadingPercentage / 100.0,
//           //         color: Colors.blue,
//           //       ),
//           //   ],
//           // )),
//         ],
//       )),
//     );
//   }
// }
