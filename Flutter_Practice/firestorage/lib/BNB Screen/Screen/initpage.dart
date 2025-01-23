import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firestorage/BNB%20Screen/businesspage.dart';
import 'package:firestorage/BNB%20Screen/homepage.dart';
import 'package:firestorage/BNB%20Screen/profilepage.dart';
import 'package:firestorage/logger/logging_util.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  @override
  void initState() {
    analytics.setAnalyticsCollectionEnabled(true);
    analytics.logViewCart(items: [AnalyticsEventItem()]);
    analytics.setSessionTimeoutDuration(
        const Duration(minutes: 5)); // Set session timeout duration

    super.initState();
  }

  WebViewController con1 = WebViewController();

  int selectedIndex = 0;
  List pageNames = ['Home_Page', 'Business_Page', 'Profile_Page'];
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  List widgetOptions = [
    HomePage(),
    BusinessPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FireBase Analytics'),
      ),
      body: Center(
        child: /* widgetOptions.elementAt(selectedIndex) */
            ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => EsignHtml(),
                  //     ));
                  // con1
                  //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  //   ..loadRequest(Uri.parse(
                  //     "http://192.168.2.130:8080/?cid=FT000069&app=fund&key=dZml96r4zSkDbcXFIWp4NM9d",
                  //   ));
                  launchUrlString(
                    'http://192.168.2.130:8080/?cid=FT000069&app=fund&key=dZml96r4zSkDbcXFIWp4NM9d',
                    // 'https://www.google.com/',
                    mode: LaunchMode.inAppWebView,
                  );
                },
                child: Text('Click to launch')),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.cyan,
        onTap: (index) async {
          await analytics.logEvent(
              // name: '${pageNames[index]}',
              name: "Test_Event_June_8",
              parameters: {
                'page_name': pageNames[index],
                'User': index,
              },
              callOptions: AnalyticsCallOptions(global: true));
          print("Event Captured");
          LoggingUtil.log.info("Event Captured $index");

          setState(() {
            // FirebaseAnalytics.instance.logScreenView(
            //   screenName: pageNames[index],
            //   screenClass: pageNames[index],
            // );
            selectedIndex = index;
          });
        },
      ),
    );
  }
}

// class EsignHtml extends StatefulWidget {
//   const EsignHtml({
//     super.key,
//   });

//   @override
//   State<EsignHtml> createState() => _EsignHtmlState();
// }

// class _EsignHtmlState extends State<EsignHtml> {
//   WebViewController con1 = WebViewController();
//   @override
//   void initState() {
//     // print(widget.html);
//     // print("url ${widget.url}");
//     con1
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(Uri.parse(
//         // "https://api.digitallocker.gov.in/public/oauth2/1/authorize?response_type=code&client_id=8C572142&state=123456",
//         // 'https://www.google.com/',
//         "http://192.168.2.130:8080/?cid=FT000069&app=fund&key=dZml96r4zSkDbcXFIWp4NM9d",
//       ));
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//           child: Column(
//         children: [
//           Expanded(
//               child:
//                   //  Html(data: widget.html)
//                   WebViewWidget(
//             controller: con1,
//           )),
//         ],
//       )),
//     );
//   }
// }
