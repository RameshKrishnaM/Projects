// ignore_for_file: avoid_print


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:photosaver/firebase_options.dart';
import 'package:photosaver/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomePage(productname: {}),
    );
  }
}

