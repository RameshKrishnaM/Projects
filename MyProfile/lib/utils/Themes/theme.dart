// // ignore_for_file: prefer_const_constructors, non_constant_identifier_names

// import 'package:flutter/material.dart';
// import 'package:novo/utils/colors.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeClass {
//   static ThemeData lighttheme = ThemeData(
//     scaffoldBackgroundColor: Colors.white,
//     scrollbarTheme: ScrollbarThemeData(
//         thickness: MaterialStatePropertyAll(5),
//         radius: Radius.circular(30),
//         thumbColor:
//             MaterialStatePropertyAll(subTitleTextColor.withOpacity(0.35))),
//     useMaterial3: false,
//     primaryColor: appPrimeColor,
//     brightness: Brightness.light,
//     // appBarTheme: AppBarTheme(
//     //   systemOverlayStyle: SystemUiOverlayStyle(
//     //       statusBarColor: Colors.transparent,
//     //       statusBarIconBrightness: Brightness.dark),
//     // ),

//     textTheme: TextTheme(
//       titleMedium: TextStyle(
//           color: titleTextColorLight,
//           fontSize: titleFontSize,
//           fontFamily: 'inter',
//           fontWeight: FontWeight.w600),
//       displayMedium: TextStyle(
//         color: subTitleTextColor,
//         fontFamily: 'inter',
//         fontSize: subTitleFontSize,
//       ),
//       bodyMedium: TextStyle(
//         fontSize: subTitleFontSize,
//         color: titleTextColorLight,
//         fontFamily: 'inter',
//       ),
//       bodySmall: TextStyle(
//         fontSize: contentFontSize,
//         color: titleTextColorLight,
//         fontFamily: 'inter',
//       ),
//       headlineMedium: TextStyle(fontFamily: 'Inter'),
//       labelSmall: TextStyle(fontFamily: 'Inter'),
//     ),
//     // primaryTextTheme: TextTheme(
//     //   bodyMedium: TextStyle(fontFamily: 'Inter', color: titleTextColor),
//     //   titleMedium: TextStyle(fontFamily: 'Inter', color: titleTextColor),
//     //   displayMedium: TextStyle(fontFamily: 'Inter', color: titleTextColor),
//     //   headlineMedium: TextStyle(fontFamily: 'Inter', color: titleTextColor),
//     //   labelSmall: TextStyle(fontFamily: 'Inter', color: titleTextColor),
//     // ),
//     // scaffoldBackgroundColor: Colors.red, // You may set the background color
//   );
//   static ThemeData Darktheme = ThemeData(
//     // primarySwatch: Colors.grey,
//     scrollbarTheme: ScrollbarThemeData(
//         radius: Radius.circular(30),
//         thickness: MaterialStatePropertyAll(5),
//         thumbColor:
//             MaterialStatePropertyAll(titleTextColorDark.withOpacity(0.50))),
//     useMaterial3: false,
//     primaryColor: Colors.white,
//     brightness: Brightness.dark,
//     // appBarTheme: AppBarTheme(
//     //   systemOverlayStyle: SystemUiOverlayStyle(
//     //       statusBarColor: Colors.transparent,
//     //       statusBarIconBrightness: Brightness.light),
//     // ),

//     textTheme: TextTheme(
//       titleMedium: TextStyle(
//           color: titleTextColorDark,
//           fontSize: titleFontSize,
//           fontFamily: 'inter',
//           fontWeight: FontWeight.w600),
//       displayMedium: TextStyle(
//         color: subTitleTextColor,
//         fontFamily: 'inter',
//         fontSize: subTitleFontSize,
//       ),
//       bodyMedium: TextStyle(
//         fontSize: subTitleFontSize,
//         color: titleTextColorDark,
//         fontFamily: 'inter',
//       ),
//       bodySmall: TextStyle(
//         fontSize: contentFontSize,
//         color: titleTextColorDark,
//         fontFamily: 'inter',
//       ),
//       headlineMedium: TextStyle(fontFamily: 'Inter'),
//       labelSmall: TextStyle(
//         fontFamily: 'Inter',
//       ),
//     ),
//     // primaryTextTheme: TextTheme(
//     //   bodyMedium: TextStyle(fontFamily: 'Inter', color: Colors.white),
//     //   titleMedium: TextStyle(fontFamily: 'Inter', color: Colors.white),
//     //   displayMedium: TextStyle(fontFamily: 'Inter', color: Colors.white),
//     //   headlineMedium: TextStyle(fontFamily: 'Inter', color: Colors.white),
//     //   labelSmall: TextStyle(fontFamily: 'Inter', color: Colors.white),
//     // ),
//     // scaffoldBackgroundColor:
//     //     Colors.grey.shade800, // You may set the background color
//   );
// }

// class ThemeManager {
//   static Future<void> setThemeMode(ThemeMode themeMode) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('theme_mode', themeMode.toString());
//   }

//   static Future<ThemeMode> getThemeMode() async {
//     final prefs = await SharedPreferences.getInstance();
//     final themeMode = prefs.getString('theme_mode');
//     return themeMode != null
//         ? ThemeMode.values.firstWhere((e) => e.toString() == themeMode)
//         : ThemeMode.system;
//   }
// }
// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:novo/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeClass {
  static ThemeData lighttheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      scrollbarTheme: ScrollbarThemeData(
          thickness: MaterialStatePropertyAll(5),
          radius: Radius.circular(30),
          thumbColor:
              MaterialStatePropertyAll(subTitleTextColor.withOpacity(0.35))),
      useMaterial3: false,
      primaryColor: appPrimeColor,
      brightness: Brightness.light,
      cardColor: titleTextColorLight,
      // appBarTheme: AppBarTheme(
      //   systemOverlayStyle: SystemUiOverlayStyle(
      //       statusBarColor: Colors.transparent,
      //       statusBarIconBrightness: Brightness.dark),
      // ),

      textTheme: TextTheme(
        titleMedium: TextStyle(
            color: titleTextColorLight,
            fontSize: titleFontSize,
            fontFamily: 'inter',
            fontWeight: FontWeight.w600),
        displayMedium: TextStyle(
          color: subTitleTextColor,
          fontFamily: 'inter',
          fontSize: subTitleFontSize,
        ),
        bodyMedium: TextStyle(
          fontSize: subTitleFontSize,
          color: titleTextColorLight,
          fontFamily: 'inter',
        ),
        bodySmall: TextStyle(
          fontSize: contentFontSize,
          color: titleTextColorLight,
          fontFamily: 'inter',
        ),
        headlineMedium: TextStyle(fontFamily: 'Inter'),
        labelSmall: TextStyle(fontFamily: 'Inter'),
      ),
      colorScheme: ColorScheme.light().copyWith(
        primary: appPrimeColor,
      )
      // colorScheme: ColorScheme.light()
      // primaryTextTheme: TextTheme(
      //   bodyMedium: TextStyle(fontFamily: 'Inter', color: titleTextColor),
      //   titleMedium: TextStyle(fontFamily: 'Inter', color: titleTextColor),
      //   displayMedium: TextStyle(fontFamily: 'Inter', color: titleTextColor),
      //   headlineMedium: TextStyle(fontFamily: 'Inter', color: titleTextColor),
      //   labelSmall: TextStyle(fontFamily: 'Inter', color: titleTextColor),
      // ),
      // scaffoldBackgroundColor: Colors.red, // You may set the background color
      );
  static ThemeData Darktheme = ThemeData(
      // primarySwatch: Colors.grey,
      scrollbarTheme: ScrollbarThemeData(
          radius: Radius.circular(30),
          thickness: MaterialStatePropertyAll(5),
          thumbColor:
              MaterialStatePropertyAll(titleTextColorDark.withOpacity(0.50))),
      useMaterial3: false,
      primaryColor: Colors.white,
      brightness: Brightness.dark,
      cardColor: titleTextColorDark,
      // appBarTheme: AppBarTheme(
      //   systemOverlayStyle: SystemUiOverlayStyle(
      //       statusBarColor: Colors.transparent,
      //       statusBarIconBrightness: Brightness.light),
      // ),

      textTheme: TextTheme(
        titleMedium: TextStyle(
            color: titleTextColorDark,
            fontSize: titleFontSize,
            fontFamily: 'inter',
            fontWeight: FontWeight.w600),
        displayMedium: TextStyle(
          color: subTitleTextColor,
          fontFamily: 'inter',
          fontSize: subTitleFontSize,
        ),
        bodyMedium: TextStyle(
          fontSize: subTitleFontSize,
          color: titleTextColorDark,
          fontFamily: 'inter',
        ),
        bodySmall: TextStyle(
          fontSize: contentFontSize,
          color: titleTextColorDark,
          fontFamily: 'inter',
        ),
        headlineMedium: TextStyle(fontFamily: 'Inter'),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
        ),
      ),
      colorScheme: ColorScheme.dark().copyWith(primary: appPrimeColor)
      // primaryTextTheme: TextTheme(
      //   bodyMedium: TextStyle(fontFamily: 'Inter', color: Colors.white),
      //   titleMedium: TextStyle(fontFamily: 'Inter', color: Colors.white),
      //   displayMedium: TextStyle(fontFamily: 'Inter', color: Colors.white),
      //   headlineMedium: TextStyle(fontFamily: 'Inter', color: Colors.white),
      //   labelSmall: TextStyle(fontFamily: 'Inter', color: Colors.white),
      // ),
      // scaffoldBackgroundColor:
      //     Colors.grey.shade800, // You may set the background color
      );
}

class ThemeManager {
  static Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', themeMode.toString());
  }

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('theme_mode');
    return themeMode != null
        ? ThemeMode.values.firstWhere((e) => e.toString() == themeMode)
        : ThemeMode.system;
  }
}
