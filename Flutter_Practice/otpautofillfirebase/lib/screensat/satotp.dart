import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebasenew/homepagre.dart';
// import 'package:firebasenew/phoneauth.dart';
// import 'package:firebasenew/wraper.dart';
import 'package:flutter/material.dart';
import 'package:otpautofillfirebase/homepage.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       home: PhoneNoauth(),
//     );
//   }
// }

class PhoneNoauth extends StatefulWidget {
  const PhoneNoauth({super.key});

  @override
  State<PhoneNoauth> createState() => _PhoneNoauthState();
}

class _PhoneNoauthState extends State<PhoneNoauth> {
  TextEditingController mobNoController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: mobNoController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: ' Ph Number',
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.verifyPhoneNumber(
                    verificationCompleted: (PhoneAuthCredential credential) {},
                    verificationFailed: (FirebaseAuthException e) {},
                    codeSent:
                        (String verificationId, int? forceResendingToken) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtpScreen(
                            verificationid: verificationId,
                          ),
                        ),
                      );
                    },
                    codeAutoRetrievalTimeout: (verificationId) {},
                    phoneNumber: mobNoController.text,
                  );
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

class OtpScreen extends StatefulWidget {
  String verificationid;
  OtpScreen({
    super.key,
    required this.verificationid,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("otpscreen"),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: otpController,
            decoration: InputDecoration(label: Text("Enter your otp")),
          ),
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  PhoneAuthCredential credential =
                      await PhoneAuthProvider.credential(
                    verificationId: widget.verificationid,
                    smsCode: otpController.text.toString(),
                  );

                  FirebaseAuth.instance
                      .signInWithCredential(credential)
                      .then((value) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          )));
                } catch (e) {}
              },
              child: Text("Otp"))
        ],
      ),
    ));
  }
}
