import 'package:flutter/material.dart';
import 'package:pokedex/screen1.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokemon Api',
      home: Screen1(),
    );
  }
}
