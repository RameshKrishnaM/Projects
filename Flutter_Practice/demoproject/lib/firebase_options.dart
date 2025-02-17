// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAPY9SRHVvnp5nCSd_93pSAwJ7k93jZj54',
    appId: '1:454339662971:web:f0d0db6fae51a64e10bede',
    messagingSenderId: '454339662971',
    projectId: 'novo121krish',
    authDomain: 'novo121krish.firebaseapp.com',
    databaseURL: 'https://novo121krish-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'novo121krish.appspot.com',
    measurementId: 'G-37JXSZKFWV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLhJ507XXM5GZRqUbYivl5KVI3QWW48rk',
    appId: '1:454339662971:android:1f9578c65c67553410bede',
    messagingSenderId: '454339662971',
    projectId: 'novo121krish',
    databaseURL: 'https://novo121krish-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'novo121krish.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBk5YRJE9bVi2cALe-3xk0aXwsDn_nZEn4',
    appId: '1:454339662971:ios:d0b5bfdb0778f8ee10bede',
    messagingSenderId: '454339662971',
    projectId: 'novo121krish',
    databaseURL: 'https://novo121krish-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'novo121krish.appspot.com',
    iosBundleId: 'com.example.demoproject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBk5YRJE9bVi2cALe-3xk0aXwsDn_nZEn4',
    appId: '1:454339662971:ios:6695bb5c9e7d832210bede',
    messagingSenderId: '454339662971',
    projectId: 'novo121krish',
    databaseURL: 'https://novo121krish-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'novo121krish.appspot.com',
    iosBundleId: 'com.example.demoproject.RunnerTests',
  );
}
