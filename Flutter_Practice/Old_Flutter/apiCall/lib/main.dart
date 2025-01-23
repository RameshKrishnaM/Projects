import 'package:apicall/apicall.dart';
// import 'package:apicall/login.dart';
// import 'package:apicall/post.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ApiCall(),
      // home: PostApi(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
    );
  }
}
