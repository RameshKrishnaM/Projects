import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    fontFamily: "Inter",
    textTheme: const TextTheme(
        bodyMedium: TextStyle(
            fontSize: 12.0,
            height: 1.7,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(102, 98, 98, 1)),
        bodySmall: TextStyle(
            fontSize: 10.0,
            height: 1.8,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(102, 98, 98, 1)),
        bodyLarge: TextStyle(
            height: 1.2,
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(0, 0, 0, 1)),
        displayMedium: TextStyle(
            height: 1.4,
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(0, 0, 0, 1))),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.0),
        borderSide: const BorderSide(
          color: Color.fromRGBO(9, 101, 218, 1), // Border color
          width: 1.3, // Border width
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.0),
        borderSide: const BorderSide(
          color: Color.fromRGBO(9, 101, 218, 1), // Border color
          width: 1.3, // Border width
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.0),
        borderSide: const BorderSide(
          color: Color.fromRGBO(9, 101, 218, 1), // Border color
          width: 1.3, // Border width
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.0),
        borderSide: const BorderSide(
          color: Colors.red, // Border color
          width: 1.3, // Border width
        ),
      ),
    ),
    colorScheme: ColorScheme.light(primary: Color.fromRGBO(9, 101, 218, 1)));
