import 'package:flutter/material.dart';
import 'package:newtask/flutter_get.dart';
import 'package:newtask/imagecropp.dart';
import 'package:newtask/skeletonizerrrr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: PincodeDetails(),
    );
  }
}
