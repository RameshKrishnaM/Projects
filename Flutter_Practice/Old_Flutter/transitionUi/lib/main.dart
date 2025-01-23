import 'package:flutter/material.dart';
import 'package:transitionui/page/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String title = 'Interests';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        home: const HomePage(),
      );
}
