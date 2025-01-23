import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_autofill/sms_autofill.dart';

class MySMS extends StatefulWidget {
  const MySMS({super.key});

  @override
  State<MySMS> createState() => _MySMSState();
}

class _MySMSState extends State<MySMS> {
  @override
  void initState() {
    getVersion();
    checkPermissions();
    super.initState();
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? version;
  getVersion() async {
    version = (await deviceInfo.androidInfo).version.release;
  }

  void checkPermissions() async {
    if (int.parse(version!) >= 13) {
      if (await Permission.sms.request().isGranted) {
        PermissionStatus smsStatus = await Permission.sms.status;
        print('SMS Permission Status: $smsStatus');
        sendSms();
      } else {
        // Permissions not granted, handle accordingly
      }
    } else {
      if (await Permission.sms.request().isGranted) {
        PermissionStatus smsStatus = await Permission.sms.status;
        print('SMS Permission Status: $smsStatus');
        sendSms();
      } else {
        // Permissions not granted, handle accordingly
      }
    }
  }

  String code = '';
  sendSms() async {
    SmsAutoFill().unregisterListener();
    await SmsAutoFill().listenForCode();
    String name = await SmsAutoFill().getAppSignature;

    setState(() {});
    print(name);
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PinFieldAutoFill(
              currentCode: code,
              decoration: BoxLooseDecoration(
                strokeColorBuilder:
                    PinListenColorBuilder(Colors.black, Colors.black26),
                bgColorBuilder: const FixedColorBuilder(Colors.white),
                strokeWidth: 2,
              ),
              autoFocus: true,
              cursor: Cursor(color: Colors.red, enabled: true, width: 1),
              // onCodeSubmitted: (code) {},

              codeLength: 6,
              onCodeChanged: (code) {
                print(code);
              },
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                checkPermissions();
              },
              child: Text('Resend OTP'),
            )
          ],
        ),
      ),
    );
  }
}

// import 'dart:async';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:otp_autofill/otp_autofill.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sms_autofill/sms_autofill.dart';

// class MySMS extends StatefulWidget {
//   // final myCode;

//   const MySMS({
//     super.key,
//     // this.myCode,
//   });

//   @override
//   _MySMSState createState() => _MySMSState();
// }

// class _MySMSState extends State<MySMS> {
//   final scaffoldKey = GlobalKey();
//   OTPTextEditController controller = OTPTextEditController(codeLength: 6);
//   TextEditingController otpController = TextEditingController();
//   late OTPInteractor _otpInteractor;

//   @override
//   void initState() {
//     // getVersion();
//     sendSms();
//     // permission();
//     super.initState();
//   }

//   permission() async {
//     print("entereddd");
//     await Permission.sms.request();
//     print("exit");
//   }

//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   String version = '';
//   getVersion() async {
//     version = (await deviceInfo.androidInfo).version.release;
//     checkPermissions();
//   }

//   void checkPermissions() async {
//     if (int.parse(version) >= 13) {
//       if (await Permission.sms.request().isGranted) {
//         PermissionStatus smsStatus = await Permission.sms.status;
//         print('SMS Permission Status: $smsStatus');
//         sendSms();
//       } else {
//         // Permissions not granted, handle accordingly
//       }
//     } else {
//       if (await Permission.sms.request().isGranted) {
//         PermissionStatus smsStatus = await Permission.sms.status;
//         print('SMS Permission Status: $smsStatus');
//         sendSms();
//       } else {
//         // Permissions not grantedversion, handle accordingly
//       }
//     }
//   }

//   String myCode = '';
//   sendSms() async {
//     // _initInteractor();
//     var p = await Permission.sms.request();
//     if (p.isGranted) {
//       controller = OTPTextEditController(
//         codeLength: 6,
//         //ignore: avoid_print
//         onCodeReceive: (code) {
//           // myCode = code;
//           print("myCode : $code");
//         },
//         // otpInteractor: _otpInteractor,
//       );
//       await controller.startListenUserConsent(
//         (code) {
//           // myCode = code!;
//           print("startListenUserConsent Code : $code");
//           final exp = RegExp(r'(\d{6})');
//           print(exp.hasMatch(code ?? ''));
//           print("myCodeee : $code");
//           otpController.text = code!;
//           print(otpController.text);
//           return exp.stringMatch(code ?? '') ?? '';
//           // return myCode;
//         },

//         // strategies: [
//         //   // MyStrategies(controller),
//         // ],
//       );
//       print("controller.text: ${controller.text}");
//       myCode = controller.text;

//       setState(() {});
//     } else {
//       print("permission denied");
//       openAppSettings();
//     }
//   }

//   Future<void> _initInteractor() async {
//     _otpInteractor = OTPInteractor();

//     // You can receive your app signature by using this method.
//     final appSignature = await _otpInteractor.getAppSignature();

//     if (kDebugMode) {
//       print('Your app signature: $appSignature');
//     }
//     // print(await _otpInteractor.getAppSignature());
//   }

//   // @override
//   // void dispose() {
//   //   controller.stopListen();
//   //   super.dispose();
//   // }

//   // String code = '';
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         key: scaffoldKey,
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(40.0),
//               // child: TextFormField(
//               //   controller: controller,
//               //   keyboardType: TextInputType.number,
//               //   decoration: InputDecoration(
//               //     counter: Offstage(),
//               //     contentPadding: EdgeInsets.all(16.0),
//               //     counterText: "",
//               //     border: OutlineInputBorder(
//               //       borderRadius: BorderRadius.circular(10.0),
//               //       borderSide: BorderSide(color: Colors.black),
//               //     ),
//               //     enabledBorder: OutlineInputBorder(
//               //       borderRadius: BorderRadius.circular(10.0),
//               //       borderSide: BorderSide(color: Colors.black),
//               //     ),
//               //     focusedBorder: OutlineInputBorder(
//               //       borderRadius: BorderRadius.circular(10.0),
//               //       borderSide: BorderSide(color: Colors.blue),
//               //     ),
//               //   ),
//               child: PinFieldAutoFill(
//                 decoration: BoxLooseDecoration(
//                   strokeColorBuilder:
//                       PinListenColorBuilder(Colors.black, Colors.black26),
//                   bgColorBuilder: const FixedColorBuilder(Colors.white),
//                   strokeWidth: 2,
//                 ),
//                 autoFocus: true,
//                 cursor: Cursor(color: Colors.red, enabled: true, width: 1),
//                 // onCodeSubmitted: (code) {},

//                 codeLength: 6,
//                 onCodeChanged: (code) {
//                   myCode = controller.text;
//                   print("onCodeChanged : ${controller.text}");
//                 },
//               ),
//             ),
//             SizedBox(
//               height: 30,
//             ),
//             ElevatedButton(
//                 onPressed: () {
//                   setState(() {});
//                   sendSms();
//                   otpController.clear();
//                   controller.clear();
//                 },
//                 child: Text('Clicke here'))
//           ],
//         ),
//       ),
//     );
//   }
// }

// // class MyStrategies extends OTPStrategy {
// //   final OTPTextEditController controller;
// //   MyStrategies(this.controller);
// //   @override
// //   Future<String> listenForCode() {
// //     return Future.delayed(
// //       const Duration(seconds: 4),
// //       () {
// //         print('myStrategies : ${controller.text}');
// //         return controller.text;
// //       },
// //     );
// //   }
// // }
