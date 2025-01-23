// import 'package:flutter/material.dart';
// import 'package:otp_text_field/otp_field.dart';
// import 'package:otp_text_field/style.dart';
// import 'package:sms_consent_for_otp_autofill/sms_consent_for_otp_autofill.dart';

// class MySMSS extends StatefulWidget {
//   @override
//   _MySMSSState createState() => _MySMSSState();
// }

// class _MySMSSState extends State<MySMSS> {
//   SmsConsentForOtpAutofill? smsConsentForOtpAutoFill;
//   OtpFieldController otpbox = OtpFieldController();
//   String? phoneNumber;

//   @override
//   void initState() {
//     super.initState();
//     smsConsentForOtpAutoFill =
//         SmsConsentForOtpAutofill(phoneNumberListener: (number) {
//       phoneNumber = number;
//       print("number...................${number}");
//     }, smsListener: (otpcode) {
//       print("otp...................${otpcode}");
//       setState(() {
//         this.startListen = false;
//         //prase code from the OTP sms
//         otpbox.set(otpcode.split(""));
//       });
//     });
//   }

//   @override
//   void dispose() {
//     smsConsentForOtpAutoFill!.dispose();
//     super.dispose();
//   }

//   bool startListen = false;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('SMS consent For Otp AutoFill'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.max,
//             children: <Widget>[
//               const Center(
//                 child: Text(
//                   "Enter OTP Code",
//                   style: TextStyle(fontSize: 20),
//                 ),
//               ),
//               const Padding(padding: EdgeInsets.all(20)),
//               OTPTextField(
//                 controller: otpbox,
//                 length: 6,
//                 width: double.infinity,
//                 fieldWidth: 50,
//                 style: const TextStyle(fontSize: 17),
//                 textFieldAlignment: MainAxisAlignment.spaceAround,
//                 fieldStyle: FieldStyle.box,
//                 onCompleted: (pin) {
//                   print("Entered OTP Code: $pin");
//                 },
//               ),
//               const SizedBox(
//                 height: 30,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   MaterialButton(
//                     color: Colors.red,
//                     textColor: Colors.white,
//                     child: Text(
//                         startListen == false ? 'Stopped' : 'Stop Listening'),
//                     onPressed: () async {
//                       smsConsentForOtpAutoFill!.dispose();
//                       setState(() {
//                         this.startListen = false;
//                       });
//                       print("Stop Listening.........");
//                     },
//                   ),
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   MaterialButton(
//                     color: Colors.green,
//                     textColor: Colors.white,
//                     child: Text(startListen ? 'Started' : 'Start Listening'),
//                     onPressed: () async {
//                       smsConsentForOtpAutoFill!.requestSms();
//                       setState(() {
//                         this.startListen = true;
//                       });
//                       print("Start Listening.........");
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 width: 20,
//               ),
//               MaterialButton(
//                 color: Colors.green,
//                 textColor: Colors.white,
//                 child: const Text("Select phone number"),
//                 onPressed: () async {
//                   smsConsentForOtpAutoFill!.requestPhoneNumber();
//                   print("Start  Listening.........");
//                 },
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               Text("Selected Number  $phoneNumber"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class MySMSS extends StatefulWidget {
  const MySMSS({super.key});

  @override
  State<MySMSS> createState() => _MySMSSState();
}

class _MySMSSState extends State<MySMSS> {
  @override
  void initState() {
    super.initState();
    textEditingController1 = TextEditingController();
    initSmsListener();
  }

  TextEditingController? textEditingController1;

  String _comingSms = 'Unknown';

  Future<void> initSmsListener() async {
    String? comingSms;
    try {
      comingSms = await AltSmsAutofill().listenForSms;
    } on PlatformException {
      comingSms = 'Failed to get Sms.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: SizedBox(
        height: 100,
        child: Text(comingSms),
      )));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: SizedBox(
        height: 100,
        child: Text(e.toString()),
      )));
    }
    if (!mounted) return;
    setState(() {
      _comingSms = comingSms!;
      print("====>Message: ${_comingSms}");
      print("${_comingSms[32]}");
      if (_comingSms.toLowerCase().contains('code')) {
        textEditingController1!.text = _comingSms[32] +
            _comingSms[33] +
            _comingSms[34] +
            _comingSms[35] +
            _comingSms[36] +
            _comingSms[
                37]; //used to set the code in the message to a string and setting it to a textcontroller. message length is 38. so my code is in string index 32-37.
      }
    });
  }

  @override
  void dispose() {
    textEditingController1!.dispose();
    AltSmsAutofill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PinCodeTextField(
            appContext: context,
            pastedTextStyle: TextStyle(
              color: Colors.green.shade600,
              fontWeight: FontWeight.bold,
            ),
            length: 6,
            obscureText: false,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(10),
              fieldHeight: 50,
              fieldWidth: 40,
              inactiveFillColor: Colors.white,
              selectedFillColor: Colors.white,
              activeFillColor: Colors.white,
            ),
            cursorColor: Colors.black,
            animationDuration: Duration(milliseconds: 300),
            enableActiveFill: true,
            controller: textEditingController1,
            keyboardType: TextInputType.number,
            boxShadows: [
              BoxShadow(
                offset: Offset(0, 1),
                color: Colors.black12,
                blurRadius: 10,
              )
            ],
            onCompleted: (v) {
              //do something or move to next screen when code complete
            },
            onChanged: (value) {
              print(value);
              setState(() {});
            },
          ),
          ElevatedButton(onPressed: initSmsListener, child: Text('Proceed'))
        ],
      ),
    );
  }
}
