import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Color appPrimeColor = const Color.fromRGBO(0, 74, 177, 1);
Color titleTextColorLight = const Color.fromRGBO(67, 67, 79, 1);
Color titleTextColorDark = Colors.white;
Color subTitleTextColor = const Color.fromRGBO(156, 155, 173, 1);
Color primaryRedColor = const Color.fromRGBO(236, 52, 78, 1);
Color primaryGreenColor = const Color.fromRGBO(11, 154, 124, 1);
Color primaryOrangeColor = const Color.fromRGBO(251, 140, 0, 1);
Color modifyButtonColor = const Color.fromRGBO(187, 222, 251, 1);
Color footerBackgroundColor = const Color.fromRGBO(225, 245, 254, 1);
Color activeColor = const Color.fromRGBO(83, 183, 162, 1);
Color inactiveColor = const Color.fromRGBO(240, 240, 240, 1);
Color infoColorStart = const Color.fromRGBO(236, 177, 82, 1);
Color infoColor = const Color.fromRGBO(255, 243, 224, 1);
Color sgbPrimaryColor = const Color.fromRGBO(255, 249, 160, 1);
Color appformFieldBcakGroundColor = Color.fromRGBO(233, 243, 255, 1);

double titleFontSize = 16.0;
double subTitleFontSize = 14.0;
double contentFontSize = 12.0;
String somethingError = 'Something went wrong...';
String sessionError = 'Session Expired...';
var rsFormat = NumberFormat.currency(
  // name: "",
  locale: 'en_IN',
  decimalDigits: 0,
  // change it to get decimal places
  symbol: '₹ ',
);
var rsMrkFormat = NumberFormat.currency(
  // name: "",
  locale: 'en_IN',
  decimalDigits: 0,
  symbol: '',
  // change it to get decimal places
);

String formatMrkNumber(int number) {
  if (number < 100000) {
    return rsMrkFormat.format(number); // Return as is if less than 1 lakh
  } else if (number >= 100000 && number < 10000000) {
    double lakhs = number / 100000;
    return '${lakhs.toStringAsFixed(2)} Lakhs';
  } else {
    double crores = number / 10000000;
    return '${crores.toStringAsFixed(2)} Crores';
  }
}

String formatNumber(int number) {
  if (number < 100000) {
    return rsFormat.format(number); // Return as is if less than 1 lakh
  } else if (number >= 100000 && number < 10000000) {
    double lakhs = number / 100000;
    return '${lakhs.toStringAsFixed(2)} Lakhs';
  } else {
    double crores = number / 10000000;
    return '${crores.toStringAsFixed(2)} Crores';
  }
}

String formatDoubleNumber(double number) {
  final NumberFormat numberFormat = NumberFormat("#,##0.00", "en_IN");

  if (number < 100000) {
    return numberFormat
        .format(number); // Return formatted with commas and decimal
  } else if (number >= 100000 && number < 10000000) {
    double lakhs = number / 100000;
    return '${numberFormat.format(lakhs)} Lakhs';
  } else {
    double crores = number / 10000000;
    return '${numberFormat.format(crores)} Crores';
  }
}

List sortList = ['A-Z', 'Z-A', 'NAV Low to High', 'NAV High to Low'];

// final String htmlData =
//     // "<div><h2 style='color:blue'>Risk Disclosure</h2><ul><li>Mutual fund investments are subject to market risks, read all scheme related documents carefully.</li><li>There can be no assurance that the schemes objectives will be achieved.</li></ul><p>Visit <a href='https://flutter.dev'>Mutual Funds</a> for more information.</p></div>";
final String htmlData =
    "<p style='color: Black;font-family:Inter;font-size: 12px;font-weight:bold;text-align: center;margin:0px;padding:0px 0px 2px 0px;'>Fortune Capital Services Private Ltd.</ p><p style='color: grey;font-family:Inter;font-size: 10px;   text-align: center;margin:0px;padding:0px 0px 1px 0px;'>SEBI Reg. No. INZ000201438 | AMFI Reg. No. ARN-105728</ p><p style='color: grey;font-family:Inter;font-size: 10px;   text-align: center;margin:0px;padding:0px;'>Investments in the Securities and Mutual Funds market are subject to market risk. There is no guaranteed or assured rate of return. Past Performance is not an indication of future returns. Please read all related documents carefully before investing.</ p>";
// final String htmlData = '''
// <!DOCTYPE html>
// <html>
//   <head>
//     <style>
//       body {
//         font-family: Arial, sans-serif;
//       }
//       p {
//         color: black;
//         font-size: 10px;
//         text-align: center;
//       }
//       .bold {
//         font-weight: bold;
//       }
//     </style>
//   </head>
//   <body>
//     <p class="bold">Fortune Capital Services Private Ltd.</p>
//     <p>SEBI Reg. No. INZ000201438 | AMFI Reg. No. ARN-105728</p>
//     <p>
//       Investments in the Securities and Mutual Funds market are subject to
//       market risk. There is no guaranteed or assured rate of return. Past
//       Performance is not an indication of future returns. Please read all
//       related documents carefully before investing.
//     </p>
//   </body>
// </html>
// ''';
