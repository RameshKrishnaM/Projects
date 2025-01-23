import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:bgservice/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String text = "Stop Service";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // FlutterBackgroundService().invoke("setAsForeground");
                  // final receiver = ReceivePort();
                  // await Isolate.spawn(apiCall, receiver.sendPort);
                  // receiver.listen((message) {
                  //   print(message);
                  // });
                  // print('*********${receiver.sendPort}');
                },
                child: Text('ForeGround Mode'),
              ),
              ElevatedButton(
                child: const Text("Background Mode"),
                onPressed: () {
                  FlutterBackgroundService().invoke("setAsBackground");
                },
              ),

              ElevatedButton(
                child: Text(text),
                onPressed: () async {
                  final service = FlutterBackgroundService();
                  var isRunning = await service.isRunning();
                  if (isRunning) {
                    service.invoke("stopService");
                  } else {
                    service.startService();
                  }

                  if (!isRunning) {
                    text = 'Stop Service';
                  } else {
                    text = 'Start Service';
                  }
                  setState(() {});
                },
              ),
              // const Expanded(
              //   child: LogView(),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  apiCall(SendPort sendPort) async {
    var client = HttpClient();
    try {
      var request = await client.getUrl(
          Uri.parse('https://dummy.restapiexample.com/api/v1/employees'));
      var response = await request.close();
      var responseBody = await utf8.decodeStream(response);
      if (response.statusCode == HttpStatus.ok) {
        var responseData = jsonDecode(responseBody);

        if (responseData['status'] == "success") {
          sendPort.send(responseData['data']);
        } else {
          showSnackbar(
              context,
              responseData['errMsg'].toString().isEmpty
                  ? 'Something went wrong...'
                  : responseData['errMsg'].toString(),
              Colors.red);
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }
}
