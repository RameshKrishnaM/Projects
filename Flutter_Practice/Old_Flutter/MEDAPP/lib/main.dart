import 'package:flutter/material.dart';
import 'package:medapp/DemoScreen/screen2.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // onGenerateRoute: RouteGenarator.generateRoute,
      home: MyCustomClipPath(),
      debugShowCheckedModeBanner: false,
      title: 'Med App',
    );
  }
}
