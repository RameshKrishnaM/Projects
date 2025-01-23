import 'dart:convert';

import 'package:digiopack/digio_repository.dart';
import 'package:flutter/material.dart';
import 'package:kyc_workflow/digio_config.dart';
import 'package:kyc_workflow/environment.dart';
import 'package:kyc_workflow/gateway_event.dart';
import 'package:kyc_workflow/kyc_workflow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  function() async {
    WidgetsFlutterBinding.ensureInitialized();

    var digioConfig = DigioConfig();
    digioConfig.theme.primaryColor = "#32a83a";
    digioConfig.logo = "https://your_logo_url";
    digioConfig.environment = Environment.SANDBOX;

    final _kycWorkflowPlugin = KycWorkflow(digioConfig);
    _kycWorkflowPlugin.setGatewayEventListener((GatewayEvent? gatewayEvent) {
      print("gateway event : " + gatewayEvent.toString());
    });
    var workflowResult = await _kycWorkflowPlugin.start(kidIdController.text,
        emailmobileController.text, gWtController.text, null);
    print('workflowResult : ' + workflowResult.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(title: Text("Digio")),
          body: SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 350,
                  child: TextFormField(
                      controller: urlController,
                      decoration: InputDecoration(
                          labelText: "URL",
                          enabledBorder: OutlineInputBorder())),
                ),
                SizedBox(
                  height: 60,
                  width: 350,
                  child: TextFormField(
                      controller: cookieController,
                      decoration: InputDecoration(
                          labelText: "Cookie",
                          enabledBorder: OutlineInputBorder())),
                ),
                MaterialButton(
                  color: Colors.blueAccent,
                  onPressed: () async {
                    var response = await DigioRepository().fetchinditialdata(
                        urlController.text, "", cookieController.text);

                    if (response.statusCode == 200) {
                      Map json = jsonDecode(response.body);

                      if (json["status"] == "S") {
                        result1 = json;
                      }
                    }
                    kidIdController.text =
                        result1["access_token"]["entity_id"] != ""
                            ? result1["access_token"]["entity_id"]
                            : result1["id"];
                    gWtController.text = result1["access_token"]["id"];
                    emailmobileController.text =
                        result1["customer_identifier"] ?? "";
                  },
                  child: Text(
                    "Fetch-Data",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 70,
                  width: 350,
                  child: TextFormField(
                      controller: kidIdController,
                      decoration: InputDecoration(
                          labelText: "KID-ID",
                          enabledBorder: OutlineInputBorder())),
                ),
                SizedBox(
                  height: 70,
                  width: 350,
                  child: TextFormField(
                      controller: emailmobileController,
                      decoration: InputDecoration(
                          labelText: "Email/Mobile",
                          enabledBorder: OutlineInputBorder())),
                ),
                SizedBox(
                  height: 70,
                  width: 350,
                  child: TextFormField(
                      controller: gWtController,
                      decoration: InputDecoration(
                          labelText: "GWT-ID",
                          enabledBorder: OutlineInputBorder())),
                ),
                MaterialButton(
                  color: Colors.blueAccent,
                  onPressed: () {
                    function();
                  },
                  child: Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
// enum Environment {
//   SANDBOX,
//   PRODUCTION,
// }

// class DigioConfig {
//   late Color theme;
//   late String logo;
//   late Environment environment;
// }

// class GatewayEvent {
//   // Define your GatewayEvent class here
// }

// class KycWorkflow {
//   final DigioConfig config;

//   KycWorkflow(this.config);

//   void setGatewayEventListener(void Function(GatewayEvent?) listener) {
//     // Implement your gateway event listener setup here
//   }

//   Future<dynamic> start(
//       String kid, String identifier, String gwt, dynamic data) async {
//     // Implement your workflow start logic here
//     return null;
//   }
// }

TextEditingController emailmobileController =
    TextEditingController(text: "ramesh003@gmail.com");
TextEditingController kidIdController =
    TextEditingController(text: "KID241106142908987QAAUDDEOQ1KEKS");
TextEditingController gWtController =
    TextEditingController(text: "GWT241106142909121RNYDEOPAWERZOS");
TextEditingController cookieController = TextEditingController();
TextEditingController urlController =
    TextEditingController(text: "http://192.168.2.70:28595");
Map result1 = {};
