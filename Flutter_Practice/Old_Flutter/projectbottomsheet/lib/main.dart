import 'package:flutter/material.dart';
import 'package:projectbottomsheet/drawer1.dart';
// import 'package:task1/bottomsheet.dart';
// import 'package:task1/demo.dart';
// import 'package:task1/drawer1.dart';
// import 'package:task1/task2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task 1',
      home: Drawer1(),
      // home: Screen1(),
      // home: BottomSheet1(),
      // home: Task2(),
    );
  }
}
