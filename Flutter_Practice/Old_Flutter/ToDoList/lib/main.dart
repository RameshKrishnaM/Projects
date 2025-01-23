import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/providerclass.dart';
import 'package:todolist/screen1.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeModel>(
          create: (context) => ThemeModel(),
        ),
      ],
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          // darkTheme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          title: 'ToDo List',
          home: const Screen1(),
        );
      },
    );
  }
}
