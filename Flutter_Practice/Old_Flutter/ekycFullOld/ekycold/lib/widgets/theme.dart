import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData lightTheme = ThemeData(
    appBarTheme: const AppBarTheme(
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark)),
    // fontFamily: 'KhulaRegular',

    //  text form fields
    inputDecorationTheme: InputDecorationTheme(
      // fillColor: Color.fromARGB(255, 240, 239, 239),
      // filled: true,
      labelStyle: const TextStyle(
        color: Color.fromRGBO(85, 84, 84, 1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.withOpacity(0.30), // Border color
          width: 2, // Border width
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.withOpacity(0.30), // Border color
          width: 2, // Border width
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.green.withOpacity(0.30), // Border color
          width: 2, // Border width
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red, // Border color
          width: 1, // Border width
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red, // Border color
          width: 1, // Border width
        ),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.blue),

    // fonts
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color.fromRGBO(8, 27, 60, 1), height: 1.2),
      bodyLarge: TextStyle(
          fontFamily: "KhulaBold",
          fontSize: 35.0,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(2, 18, 52, 1),
          // shadows: [
          //   Shadow(
          //       blurRadius: 5.0,
          //       color: Color.fromARGB(255, 110, 109, 109),
          //       offset: Offset(3, 2))
          // ],
          height: 1.3),
      displayMedium: TextStyle(
        fontSize: 22.0,
        color: Color.fromARGB(255, 66, 66, 66),
        fontFamily: "KhulaSemiBold",
      ),
      displaySmall: TextStyle(
        fontSize: 18.0,
        height: 1.5,
        fontWeight: FontWeight.w300,
        color: Color.fromRGBO(8, 27, 60, 1),
        fontFamily: "KhulaRegular",
      ),
    ),
    colorScheme: const ColorScheme.light(
        primary: Colors.blue, // Color.fromRGBO(8, 27, 60, 1),
        onPrimary: Colors.white));

ThemeData darkTheme = ThemeData(
    appBarTheme: const AppBarTheme(
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light)),
    fontFamily: 'Inter',
    iconTheme: const IconThemeData(color: Colors.blue),

    // fonts
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(
          fontFamily: "Sriracha",
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.0),
      displayMedium: TextStyle(
          fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
      displaySmall: TextStyle(fontSize: 17.0, color: Colors.white),
    ),
    colorScheme:
        const ColorScheme.dark(primary: Colors.white, onPrimary: Colors.black));
