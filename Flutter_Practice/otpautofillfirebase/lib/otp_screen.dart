import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:telephony/telephony.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  const OtpScreen({
    super.key,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

//I/flutter
class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();
  Telephony telephony = Telephony.instance;
  String otp = '';
  OtpFieldController otpbox = OtpFieldController();
  @override
  void initState() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        print(message.address);
        print(message.body);
        print(message.date);

        String sms = message.body.toString();
        print(sms);

        if (message.body!.contains('otpautofill-53fc1.firebaseapp.com')) {
          String otpcode = sms.replaceAll(new RegExp(r'[^0-9]'), '');
          print(otpcode);
          otpbox.set(otpcode.split(""));
          setState(() {});
        } else {
          print("Normal message.");
        }
      },
      listenInBackground: false,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OTPTextField(
                outlineBorderRadius: 10,
                controller: otpbox,
                length: 6,
                width: MediaQuery.of(context).size.width,
                fieldWidth: 50,
                style: TextStyle(fontSize: 17),
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldStyle: FieldStyle.box,
                onCompleted: (pin) {
                  otp = pin;
                },
              ),
              // TextFormField(
              //   // onChanged: (value) {
              //   //   myCode = otpController.text;
              //   // },
              //   inputFormatters: [
              //     LengthLimitingTextInputFormatter(6),
              //     FilteringTextInputFormatter.digitsOnly,
              //   ],
              //   keyboardType: TextInputType.number,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10.0),
              //     ),
              //     hintText: 'Enter OTP',
              //   ),
              // ),
              SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    PhoneAuthCredential credential =
                        await PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: otpController.text,
                    );
                    FirebaseAuth.instance
                        .signInWithCredential(credential)
                        .then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: SizedBox(
                            height: 80,
                            child: Text('Otp verified Sucessfully'),
                          ),
                        ),
                      );
                    });
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text('verify Otp'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
