import 'package:apitask/firstApi.dart';
// import 'package:apitask/secondApi.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ApiTask',
      debugShowCheckedModeBanner: false,
      home: FirstApi(),
    );
  }
}
