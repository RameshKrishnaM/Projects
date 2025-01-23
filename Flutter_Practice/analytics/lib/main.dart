import 'package:analytics/firebase_options.dart';
import 'package:analytics/realTimeDatabase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: 'SecondaryApp', options: DefaultFirebaseOptions.currentPlatform);

  FirebaseApp secondaryApp = Firebase.app('SecondaryApp');
  // FirebaseFirestore firestore =
  //     FirebaseFirestore.instanceFor(app: secondaryApp);
  // FirebaseFirestore.instance;

  runApp(MyApp(
      // firestore: firestore,
      ));
}

class MyApp extends StatelessWidget {
  // final FirebaseFirestore firestore;
  const MyApp({
    super.key,
    /* required this.firestore */
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RealTimeDatabase(
          // firestore: firestore,
          ),
      debugShowCheckedModeBanner: false,
    );
  }
}
