import 'dart:async';

import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Cookies/cookies.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Custom Widgets/custom_snackbar.dart';
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
  bool isLoading = true;
  WebViewController con1 = WebViewController();
  @override
  void initState() {
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
          onUrlChange: (change) {},
          onPageFinished: (url) async {
            setState(() {
              loadingPercentage = 100;
            });
            if (url.contains(
                "https://esign.egov-nsdl.com/nsdl-esp/authenticate/auth-ra?authMod=1#no-back-button")) {
              await _injectSSLCertificate(con1);
            }
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onHttpAuthRequest: (request) {},
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {},
        ));
    } else {
      con1
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(
          Uri.parse(widget.url!),
          headers: widget.url!.contains("esignFormrequestcdsl")
              ? getHeader(context: context) // Use your custom headers
              : {},
        )
        ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
              // loadingPercentage = 0;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
          onUrlChange: (change) async {
            String url = change.url ?? "";
            if (url.contains("mob/rd/digilocker")) {
              func1();

              if (widget.routename == route.panCard) {
                Provider.of<ProviderClass>(context, listen: false)
                    .changeUrl(url);
                Navigator.pop(context);
              } else {
                Navigator.popAndPushNamed(context, route.digiLocker,
                    arguments: {"url": url});
              }
            } else if (url.contains("?&ecres") ||
                url.contains("/Demat-Details")) {
              if (widget.routename == route.aggregator) {
                Provider.of<ProviderClass>(context, listen: false)
                    .changeUrl(url);
                Navigator.pop(context);
              } else {
                Navigator.popAndPushNamed(context, route.aggregator,
                    arguments: {"url": url});
              }
            } else if (url.contains("esignFormResponse")) {
              if (widget.routename == route.review) {
                Provider.of<ProviderClass>(context, listen: false)
                    .changeUrl(url);
                Future.delayed(
                  Duration(seconds: 6),
                  () => Navigator.pop(context),
                );
                //http://192.168.2.70:28595/api/esignFormResponse?&txnid=a462a049bb1b4aba9674a0a689f62f4b&docid=61012&request
              }
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
  Future<void> loadSSLAsset() async {
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
              child: Stack(
            children: [
              WebViewWidget(
                controller: con1,
              ),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
            ],
          )),
        ],
      )),
    );
  }
}

getHeader({required context}) {
  try {
    return CustomHttpClient.headers;
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}
