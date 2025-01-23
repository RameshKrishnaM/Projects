// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class BiometricAuth extends StatelessWidget {
//   static const platform = MethodChannel('com.example.fingerprint/authenticate');

//   Future<void> _authenticate() async {
//     try {
//       final bool authenticated = await platform.invokeMethod('authenticate');
//       if (authenticated) {
//         // Authentication succeeded, proceed with your app logic
//         print('Authentication successful');
//       } else {
//         // Authentication failed
//         print('Authentication failed');
//       }
//     } on PlatformException catch (e) {
//       print("Failed to authenticate: '${e.message}'.");
//       // Handle platform exceptions
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Fingerprint Authentication'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _authenticate,
//           child: Text('Authenticate with Fingerprint'),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BiometricAuth extends StatelessWidget {
  static const platform = MethodChannel('com.example.biomatricpro');

  Future<void> _storeFingerprint() async {
    try {
      final bool stored = await platform.invokeMethod('storeFingerprint');
      if (stored) {
        // Fingerprint data stored successfully
        print('Fingerprint data stored successfully');
      } else {
        // Failed to store fingerprint data
        print('Failed to store fingerprint data');
      }
    } on PlatformException catch (e) {
      print("Failed to store fingerprint data: '${e.message}'.");
      // Handle platform exceptions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fingerprint Storage'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _storeFingerprint,
          child: Text('Store Fingerprint Data'),
        ),
      ),
    );
  }
}
