import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectdemo2/bankscreen2.dart';
import 'package:projectdemo2/widgets/providerclss.dart';
import 'package:provider/provider.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MyProvider>(
          create: (context) => MyProvider(),
        ),
      ],
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            textTheme: GoogleFonts.aBeeZeeTextTheme(),
          ),
          title: 'Bank Screen',
          debugShowCheckedModeBanner: false,
          home: const MyBankScreen(),
        );
      },
    );
  }
}
