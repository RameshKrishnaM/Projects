// ignore_for_file: file_names, use_build_context_synchronously

import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuthentication {
  static bool isAuthenticated =
      false; //this is check the fingerprint credential
  static List<BiometricType> availableBiometrics =
      []; //This is check the biometic available List(finger1,finger2,finger3 ) or not on mobile
  static bool canCheckBiometrics =
      false; //It will check the biometric verify on mobile biometric
  static bool isAuthenticating =
      false; //If the biometric already running or not

//This Method is Checking the available on Biometric option
  static Future<void> isBioMetricAvailable(LocalAuthentication auth) async {
    try {
      if (isAuthenticating) {
        throw Exception("Authentication is already in progress");
      }

      isAuthenticating = true;

      canCheckBiometrics = await auth.canCheckBiometrics;
      availableBiometrics = await auth.getAvailableBiometrics();
    } catch (e) {
      throw Exception(e);
    } finally {
      isAuthenticating = false;
    }
  }

  static Future<void> authenticate(LocalAuthentication auth, context) async {
    try {
      if (isAuthenticating) {
        throw Exception("Authentication is already in progress");
      }

      isAuthenticating = true;

      if (canCheckBiometrics && availableBiometrics.isNotEmpty) {
        isAuthenticated = await auth.authenticate(
          localizedReason: 'Authenticate to access features',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );

        isAuthenticating = false;
      } else {
        isAuthenticated = false;
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      isAuthenticating = false;
    }
  }

  static Future<void> setBiometricVerify(String isEnableBioMetric) async {
    var pref = await SharedPreferences.getInstance();
    pref.setString("isEnableBioMetric", isEnableBioMetric);
  }

  static Future<String?> getBiometricVerify() async {
    var pref = await SharedPreferences.getInstance();
    return pref.getString("isEnableBioMetric");
  }
}
