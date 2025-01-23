import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otpautofillfirebase/otp_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: 'Enter Phone Number',
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.verifyPhoneNumber(
                    verificationCompleted: (PhoneAuthCredential credential) {
                      print('verificationCompleted');
                    },
                    verificationFailed: (FirebaseAuthException e) {
                      print('verificationFailed');
                    },
                    codeSent:
                        (String verificationId, int? forceResendingToken) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtpScreen(
                            verificationId: verificationId,
                          ),
                        ),
                      );
                    },
                    codeAutoRetrievalTimeout: (verificationId) {},
                    phoneNumber: mobNoController.text,
                  );
                },
                child: Text('Send Otp'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main(List<String> args) {
  runApp(MyAppp());
}

class MyAppp extends StatefulWidget {
  const MyAppp({super.key});

  @override
  State<MyAppp> createState() => _MyApppState();
}

class _MyApppState extends State<MyAppp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
    );
  }
}
