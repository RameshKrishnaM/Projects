import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:footwareadmin/Screens/homescreen.dart';
import 'package:footwareadmin/controller/home_controller.dart';
import 'package:footwareadmin/firebase_options.dart';
import 'package:get/get.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(HomeController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin-Page',
      home: HomeScreen(),
    );
  }
}
