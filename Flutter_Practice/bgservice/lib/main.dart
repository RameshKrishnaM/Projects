import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bgservice/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

List<dynamic> data = [];
int currentIndex = 0;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  await service.startService();
}

void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Call the API and start displaying data
    data = await apiCall();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentIndex < data.length) {
        final dynamic item = data[currentIndex];
        service.setForegroundNotificationInfo(
          title: item['employee_name'],
          content: item['employee_salary'].toString(),
        );
        // Update the notification content with each new message
        // updateNotification(item['employee_name'], service);
        currentIndex++;
      } else {
        timer.cancel();
      }
    });
  }
}

Future<bool> onIosBackground(ServiceInstance service) async {
  // Handle background tasks on iOS here
  return true;
}

Future<List<dynamic>> apiCall() async {
  var client = HttpClient();
  try {
    var request = await client
        .getUrl(Uri.parse('https://dummy.restapiexample.com/api/v1/employees'));
    var response = await request.close();
    var responseBody = await utf8.decodeStream(response);
    if (response.statusCode == HttpStatus.ok) {
      var responseData = jsonDecode(responseBody);
      if (responseData['status'] == "success") {
        return responseData['data'];
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print(e);
  }
  return [];
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notification',
      home: HomeScreen(),
    );
  }
}
