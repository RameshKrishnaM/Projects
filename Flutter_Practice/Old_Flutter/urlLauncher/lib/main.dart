import 'package:flutter/material.dart';
import 'package:urllauncher/homepage.dart';
import 'package:urllauncher/mysnackbar.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomSnackBar(),
    );
  }
}
