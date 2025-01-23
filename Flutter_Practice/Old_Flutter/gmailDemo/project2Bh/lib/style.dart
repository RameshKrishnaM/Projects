import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static Color primary = Colors.blue;
  static Color secondary = Colors.blue.shade300;
  static Color ternary = Colors.blue.shade200;
  static Color accent = Colors.blue.shade100;
  static Color darkPrimary = Color.fromARGB(255, 1, 39, 70);
  static Color darkSecondary = Colors.blueGrey;
  static Color darkTernary = Colors.blue.shade800;
  static Color dark = Colors.black;
  static Color light = Colors.white60;
  static Color semiLight = Colors.grey.shade600;
  static Color semiDark = Colors.grey.shade800;
}

class AppFont {
  double fontSize;
  FontWeight fontWeight;
  Color textColor;

  AppFont.heading({
    required this.textColor,
    this.fontSize = 32.0,
    this.fontWeight = FontWeight.bold,
  });

  AppFont.body({
    required this.textColor,
    this.fontSize = 18.0,
    this.fontWeight = FontWeight.normal,
  });

  AppFont.subtitle({
    required this.textColor,
    this.fontSize = 24.0,
    this.fontWeight = FontWeight.normal,
  });

  TextStyle get primary => GoogleFonts.aBeeZee(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
      );

  TextStyle get secondary => GoogleFonts.acme(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
      );
}
