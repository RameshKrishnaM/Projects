import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //sign up user
  Future<String> getUserDetails({
    required String clientId,
    required String deviceName,
    required String deviceIP,
    // required bool deviceIsActive,
  }) async {
    ////////print('*****Firebase*********');
    String res = 'Some Error Occured';
    try {
      await _firestore
          .collection(clientId)

          // .collection(deviceName)
          //$deviceName,(IP)address:$deviceIP
          // .doc('Devices')
          // .collection('$deviceName,(IP)address:$deviceIP')
          .doc('$deviceName,(IP)address:$deviceIP')
          .set({
        'clientId': clientId,
        'deviceName': deviceName,
        'deviceIP': deviceIP,
        // 'deviceIsActive': deviceIsActive,
        'IpoEvent': [],
        'SgbEvent': []
      });
      res = 'success';
      // }

      // } else {}
    } catch (e) {
      ////////print('Firebase Catch+++++$e');
      // res = e.toString();
    }
    return res;
  }

  Future<String> getBidDetails({
    required String clientId,
    required String symbol,
    // required List bidDetails,

    // required bool deviceIsActive,
  }) async {
    ////////print('*****Firebase*********');
    String res = 'Some Error Occured';
    try {
      await _firestore
          .collection(clientId)

          // .collection(deviceName)
          .doc(symbol)
          .set({
        'SymbolName': clientId,
        // 'deviceName': deviceName,
        // 'deviceIP': deviceIP,
        // // 'deviceIsActive': false,
        // 'IpoEvent': [],
        // 'SgbEvent': []
      });
      res = 'success';
      // }

      // } else {}
    } catch (e) {
      ////////print('Catchblock++++++++++$e');
      // res = e.toString();
    }
    return res;
  }
}

bool checkUserIspresent(
    dynamic usersList, String curUserId, String deviceIP, String deviceName) {
  for (var element in usersList.docs) {
    ////////print('element');
    ////////print(element);
    if (element["clientId"] == curUserId &&
        element["deviceIP"] == deviceIP &&
        element["deviceName"] == deviceName) {
      return false;
    }
  }

  return true;
}
