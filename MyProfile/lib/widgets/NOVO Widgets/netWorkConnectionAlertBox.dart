// ignore_for_file: file_names

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:novo/utils/colors.dart';
// import 'package:ipoapp/Provider/provider.dart';
// import 'package:ipoapp/utils/colors.dart';
// import 'package:provider/provider.dart';

// Future<bool> isInternetConnected() async {
//   var connectivityResult = await (Connectivity().checkConnectivity());
//   if (connectivityResult == ConnectivityResult.mobile ||
//       connectivityResult == ConnectivityResult.wifi) {
//     return true; // Device is connected to the internet
//   } else {
//     return false;
//     // Device is not connected to the internet
//   }
// }
Future<bool> isInternetConnected() async {
  // Check connectivity result, which might now return a list
  var connectivityResult = await (Connectivity().checkConnectivity());

  // If it's a list, check if any result indicates mobile or wifi
  return connectivityResult.any((result) =>
      result == ConnectivityResult.mobile || result == ConnectivityResult.wifi);
}

noInternetConnectAlertDialog(context, retryFunction) {
  // throw Exception("ethavathu   ");
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Oops..!",
                  style: TextStyle(
                      letterSpacing: -3.0,
                      fontSize: 40.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                ),
                Icon(
                  Icons.cell_tower,
                  size: 100,
                  color: appPrimeColor,
                ),
                Text(
                  "No Internet Connection",
                  style: TextStyle(
                      fontSize: 18.0,
                      color: appPrimeColor,
                      fontFamily: 'inter',
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  // height: 42.0,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0))),
                          backgroundColor:
                              MaterialStatePropertyAll(appPrimeColor)),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await Future.delayed(const Duration(milliseconds: 600));
                        retryFunction();
                      },
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                            fontFamily: 'inter',
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                ),
                // const SizedBox(
                //   height: 20.0,
                // )
              ],
            ),
          ),
        ),
      );
    },
  );
}
