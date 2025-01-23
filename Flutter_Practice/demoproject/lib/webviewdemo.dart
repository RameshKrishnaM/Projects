import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DemoWebview extends StatefulWidget {
  const DemoWebview({super.key});

  @override
  State<DemoWebview> createState() => _DemoWebviewState();
}

class _DemoWebviewState extends State<DemoWebview> {
  WebViewController webController = WebViewController();
  @override
  void initState() {
    webController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.youtube.com/watch?v=pDUf0YN0ILc'))
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) {
            String url = change.url ?? "";
            print("url $url");
            // if (url.contains("mob/rd/digilocker")) {
            //   print("new url $url");
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => MyHomePage(
            //         title: 'WebView Example',
            //       ),
            //     ),
            //   );
            // }
          },
        ),
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(
        controller: webController,
      ),
    );
  }
}
