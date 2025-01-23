import 'dart:async';
import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/custom_form_field.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Route/route.dart' as route;

class EsignHtml extends StatefulWidget {
  final String? routename;

  final String? html;
  final String? url;
  const EsignHtml({super.key, this.routename, this.html, this.url});

  @override
  State<EsignHtml> createState() => _EsignHtmlState();
}

class _EsignHtmlState extends State<EsignHtml> {
  var loadingPercentage = 0;
  WebViewController con1 = WebViewController();
  @override
  void initState() {
    // print(widget.html);
    // print("url ${widget.url}");
    if (widget.html != null) {
      WebViewCookieManager cookie = WebViewCookieManager();
      cookie.setCookie(WebViewCookie(
          name: "ftek_yc_ck",
          value:
              "28bdcd306600c2b1543f981d8803a3c0c4f9eec70fe47fa1ac7002e5753c30f9",
          domain: "uatekyc101.flattrade.in"));
      con1
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString(widget.html!)
        ..setNavigationDelegate(NavigationDelegate(
          onUrlChange: (change) {
            // print(change.url);
          },
          onPageFinished: (url) async {
            setState(() {
              // print("loading doneeee!!!");
              loadingPercentage = 100;
            });
            // print("url $url");
            if (url.contains(
                "https://esign.egov-nsdl.com/nsdl-esp/authenticate/auth-ra?authMod=1#no-back-button")) {
              await _injectSSLCertificate(con1);
            }
          },
          onProgress: (progress) {
            setState(() {
              // print(progress);
              loadingPercentage = progress;
            });
          },
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onHttpAuthRequest: (request) {
            // print("request ${request}");
          },
          onNavigationRequest: (request) {
            // print("navigat ${request.url}");
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            // print("error ${error.toString()}");
          },
        ));
      // Timer.periodic(Duration(seconds: 5), (timer) {
      //   func(timer);
      // });
    } else {
      // con1
      //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
      //   ..loadRequest(Uri.parse(widget.url!));
      // }
      // con1.loadHtmlString(widget.html);
      // con1.loadFlutterAsset("assets/images/htm.html");
      // print(widget.url);
      con1
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(
            // "https://api.digitallocker.gov.in/public/oauth2/1/authorize?response_type=code&client_id=8C572142&state=123456",
            widget.url!))
        ..setNavigationDelegate(NavigationDelegate(
          onUrlChange: (change) {
            String url = change.url ?? "";
            // print("url $url");
            if (url.contains("mob/rd/digilocker")) {
              func1();
              // print("new url $url");
              if (widget.routename == route.panCard) {
                Provider.of<Postmap>(context, listen: false).changeUrl(url);
                Navigator.pop(context);
              } else {
                Navigator.popAndPushNamed(context, route.digiLocker,
                    arguments: {"url": url});
              }
              // var uri = Uri.parse(url);
              // Map queryParameters = uri.queryParameters;
              // String digi_id = queryParameters["digi_id"];
              // String error = queryParameters["error"];
              // String error_description = queryParameters["error_description"];
              // if (error != "null") {
              //   getDigiInfo(digi_id);
              // } else {
              //   showDialog(
              //     context: context,
              //     builder: (context) {
              //       return AlertDialog(
              //         content: Column(mainAxisSize: MainAxisSize.min, children: [
              //           Text(error),
              //           const SizedBox(
              //             height: 10.0,
              //           ),
              //           Text(error_description),
              //           const SizedBox(
              //             height: 10.0,
              //           ),
              //           Text("Please try after some time"),
              //         ]),
              //       );
              //     },
              //   );
              // }
            }
          },
        ));
    }
    super.initState();
  }

  func1() async {
    await con1.clearCache();
    await con1.clearLocalStorage();
  }

  // getDigiInfo(digi_id) async {
  //   var response = await getDigiInfoAPI(context: context, digiId: digi_id);
  //   if (response != null) {
  //     print(response);
  //   }
  // }

  func(Timer timer) async {
    var response = await checkEsignCompletedInAPI(context: context);
    if (!mounted) {
      timer.cancel();
    }
    if (response != null) {
      timer.cancel();
      var response1 = await formSubmissionAPI(context: context);
      if (response1 != null) {
        Navigator.pushNamed(context, route.congratulation);
      }
    }
  }

  Future<void> _injectSSLCertificate(
      WebViewController webViewController) async {
    // Inject SSL certificate
    await webViewController.runJavaScript('''
      var cert = `-----BEGIN CERTIFICATE-----
      $_sslContent
      -----END CERTIFICATE-----`;

      fetch("https://esign.egov-nsdl.com/nsdl-esp/authenticate/auth-ra?authMod=1#no-back-button", { 
        headers: { 
          "Content-Type": "application/json", 
          "Certificate": cert 
        }
      });
    ''');
  }

  String _sslContent = "";
  Future<void> _loadSSLAsset() async {
    // Load SSL certificate content from asset file
    _sslContent = await rootBundle.loadString('assets/raw/flattrade.crt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child:
                  //  Html(data: widget.html)
                  Stack(
            children: [
              WebViewWidget(
                controller: con1,
              ),
              if (loadingPercentage < 100)
                LinearProgressIndicator(
                  value: loadingPercentage / 100.0,
                  color: Colors.blue,
                ),
            ],
          )
              //     HtmlWidget(
              //   // '<html><body><div style="padding-top:250px"><img class="center" src="https://flattrade.s3.ap-south-1.amazonaws.com/promo/WallSuccess.png" width="90" height="90"><h2 style="text-align:center"><b>Signed Successfully</b></h2><p style="text-align:center">This page will close automatically in 5 seconds. If not, close manually to continue</p></div></body><style>body,html{background-color:#c8e6c9;color:#424242;font-family:Calibri}img{display:block;margin-left:auto;margin-right:auto}</style></html>'
              //   widget.html,
              //   onTapUrl: (p0) {
              //     print(p0);
              //     return true;
              //   },
              // ),
              ),
          // const SizedBox(height: 20.0),
          // CustomButton(onPressed: () async {
          //   // File f = File("/storage/emulated/0/Documents/docu.html");
          //   // f.writeAsStringSync(widget.html);
          //   con.text = widget.html;
          // }),
          // const SizedBox(height: 20.0),
        ],
      )),
    );
  }
}
