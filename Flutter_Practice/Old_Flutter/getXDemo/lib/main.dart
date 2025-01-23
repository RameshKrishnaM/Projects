import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getxdemo/others/demoscreen.dart';
import 'package:getxdemo/others/homescreen.dart';
import 'package:getxdemo/screen/getxapi.dart';
import 'package:getxdemo/widget/color.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' Demo',
      home: DemoScreen(),
    );
    /*  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GetX Demo',
      home: HomeScreen2(),
      theme: ThemeData(primarySwatch: AppColor.purpleColor),
    ); */
  }
}
