import 'dart:convert';
import 'dart:io';

import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/custom_button.dart';
import 'package:ekyc/Custom%20Widgets/custom_drop_down.dart';
import 'package:ekyc/Custom%20Widgets/login_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Custom Widgets/custom_snackBar.dart';
import '../Nodifier/nodifierCLass.dart';
import '../Route/route.dart' as route;
import 'package:http/http.dart' as http;

// class CustomHttpClient {
//   Future<HttpClient> getClient() async {
//     // HttpClient httpClient = HttpClient();
//     // // Bypass SSL certificate verification (for development only)
//     // httpClient.badCertificateCallback =
//     //     (X509Certificate cert, String host, int port) => true;

//     // return httpClient;
//     ByteData data = await rootBundle.load('assets/raw/flattrade.crt');
//     SecurityContext context = SecurityContext.defaultContext;
//     context.setTrustedCertificatesBytes(data.buffer.asUint8List());
//     HttpClient httpClient = HttpClient(context: context);
//     // httpClient.badCertificateCallback =
//     //     (X509Certificate cert, String host, int port) => true;
//     return httpClient;
//   }
// }

class StateSelection extends StatefulWidget {
  const StateSelection({super.key});

  @override
  State<StateSelection> createState() => _StateSelectionState();
}

class _StateSelectionState extends State<StateSelection> {
  TextEditingController state = TextEditingController();
  TextEditingController langunage = TextEditingController();
  FormValidateNodifier formValidateNodifier =
      FormValidateNodifier({"State": false, "Language Preference": false});
  @override
  void initState() {
    // getState(context);

    // putWithOutCookie(
    //     "otpcall",
    //     {"username": "", "sendto": "9790506785", "sendtotype": "MOBILE"},
    //     context);
    // getState(context);
    // put();
    // fetchData();
    super.initState();
  }

  // Future<void> fetchData() async {
  //   // Replace http.Client() with your custom client
  //   final client = await CustomHttpClient1().getClient();

  //   try {
  //     final request = await client.postUrl(
  //         Uri.https("uatekyc101.flattrade.in:28094", "/api/dropDowndata"));
  //     request.add(utf8.encode(jsonEncode([
  //       {"code": "state", "description": "state Name"}
  //     ])));
  //     // Process the response
  //     var response = await request.close();
  //     print(response.statusCode);
  //     var responseBody = await response.transform(utf8.decoder).join();
  //     Map data = json.decode(responseBody);

  //     print(data);
  //   } catch (e) {
  //     // Handle errors
  //     print('Error: $e');
  //   } finally {
  //     client.close();
  //   }
  // }

  put() async {
    try {
      var response = await http.post(
          Uri.parse("http://192.168.2.5:27094/api/dropDowndata"),
          headers: {
            // "Origin": "https://uatekyc101.flattrade.in",
            // "Referer": "https://uatekyc101.flattrade.in/",
          },
          body: jsonEncode([
            {"code": "state", "description": "state Name"}
          ]));
    } catch (e) {}
  }

  getState() async {
    try {
      var response = await getDropDownValues(context: context, code: "state");
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        if (json["status"] == "S") {
          Navigator.pushNamed(context, route.panCard);
        } else {
          showSnackbar(context, json["errMsg"], Colors.red);
        }
      }
    } catch (e) {
      showSnackbar(context, e.toString(), Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginPageWidget(
        title: "State",
        subTitle: "Please select the State and language",
        children: [
          // CustomSearchDropDown(
          //     controller: TextEditingController(),
          //     list: [1, 2, 3, 4, 5],
          //     labelText: "State",
          //     hintText: "State"),
          // const SizedBox(
          //   height: 10.0,
          // ),
          // CustomSearchDropDown(
          //     controller: TextEditingController(),
          //     list: [1, 2, 3, 4, 5],
          //     labelText: "language",
          //     hintText: "Language Preference"),
          CustomDropDown(
            formValidateNodifier: formValidateNodifier,
            controller: state,
            values: ["TamilNadu", "Kerala", "Delhi", "Telangana"],
            isIcon: true,
            label: "State",
          ),
          const SizedBox(
            height: 10.0,
          ),
          CustomDropDown(
            formValidateNodifier: formValidateNodifier,
            controller: langunage,
            values: ["Tamil", "English", "Hindi", "Telugu"],
            isIcon: true,
            label: "Language Preference",
          ),
          const Expanded(flex: 4, child: SizedBox()),
          CustomButton(
              valueListenable: formValidateNodifier,
              buttonFunc: () => Navigator.pushNamed(context, route.panCard)),
          const Expanded(child: SizedBox()),
        ]);
  }
}

Map m = {
  "authority": "uatekyc101.flattrade.in:28094",
  "method": "POST",
  "path": "/api/dropDowndata",
  "scheme": "https",
  "Accept": "application/json",
  "Accept-Encoding": "gzip, deflate, br",
  "Accept-Language": "en-GB,en-US;q=0.9,en;q=0.8",
  "Content-Length": 45,
  "Content-Type": "application/json",
  "Cookie":
      "fortunetradingcorporation-_zldp=YyabJSmWdaowzkiFlx8dl5ziLKQspEj3PWDyh7G67qArNzcktkFHE9Zl4wHiSI3%2BmKwM1K1ctjo%3D; _ga_T5Q69Z3LRK=GS1.1.1700489091.6.0.1700489091.60.0.0; _gcl_au=1.1.449352029.1703682970; _ga=GA1.1.237999822.1694689860; _fbp=fb.1.1703682979403.52853987; _ga_MW0L67PCZ7=GS1.1.1703686004.3.0.1703686004.60.0.0",
  "Origin": "https://uatekyc101.flattrade.in",
  "Referer": "https://uatekyc101.flattrade.in/",
  "Sec-Fetch-Dest": "empty",
  "Sec-Fetch-Mode": "cors",
  "Sec-Fetch-Site": "same-site",
  "User-Agent":
      "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1"
};
