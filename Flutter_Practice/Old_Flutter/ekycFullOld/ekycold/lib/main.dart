import 'package:ekycold/bankscreen2.dart';
import 'package:ekycold/widgets/theme.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: lightTheme,
        title: 'EKYC',
        debugShowCheckedModeBanner: false,
        home: const MyBankScreen());
  }
}
