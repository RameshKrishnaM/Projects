import 'package:flutter/material.dart';
import 'package:tasktemp/Screen1.dart';

import 'route.dart' as route;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      onGenerateRoute: route.controller,
      title: 'TempTask',
      debugShowCheckedModeBanner: false,
      home: Screen1(),
    );
  }
}
