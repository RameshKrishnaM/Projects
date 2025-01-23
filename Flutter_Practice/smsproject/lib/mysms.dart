import 'package:flutter/material.dart';
// import 'package:sms_autofill/sms_autofill.dart';
// import 'package:smsproject/verifyotpscreen.dart';
import 'package:sms_consent_for_otp_autofill/sms_consent_for_otp_autofill.dart';

class MySms extends StatefulWidget {
  const MySms({super.key});

  @override
  State<MySms> createState() => _MySmsState();
}

class _MySmsState extends State<MySms> {
  TextEditingController mobileNumber = TextEditingController();
  @override
  void initState() {
    listenSms();
    super.initState();
  }

  SmsConsentForOtpAutofill? smsConsentForOtpAutoFill;
  bool startListen = false;
  listenSms() {
    smsConsentForOtpAutoFill =
        SmsConsentForOtpAutofill(phoneNumberListener: (number) {
      print("number...................${number}");
    }, smsListener: (otpcode) {
      print("otp...................${otpcode}");
      setState(() {
        mobileNumber.text = otpcode;
        this.startListen = false;
        //prase code from the OTP sms
        // otpbox.set(otpcode.split(""));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // void submit() async {
    //   if (mobileNumber.text == "") return;

    //   var appSignatureID = await SmsAutoFill().getAppSignature;
    //   Map sendOtpData = {
    //     "mobile_number": mobileNumber.text,
    //     "app_signature_id": appSignatureID
    //   };
    //   print(sendOtpData);
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const VerifyOTPScreen()),
    //   );
    // }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: mobileNumber,
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(8),
              //     color: const Color(0xFFC2C0C0),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 10),
              //     child: TextField(
              //       controller: mobileNumber,
              //       keyboardType: TextInputType.number,
              //       decoration: const InputDecoration(
              //         border: InputBorder.none,
              //         hintText: "Enter Mobile Number",
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 10,
              ),
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child:
                    Text(startListen == false ? 'Stopped' : 'Stop Listening'),
                onPressed: () async {
                  smsConsentForOtpAutoFill!.dispose();
                  setState(() {
                    this.startListen = false;
                  });
                  print("Stop Listening.........");
                },
              ),
              const SizedBox(
                width: 20,
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text(startListen ? 'Started' : 'Start Listening'),
                onPressed: () async {
                  listenSms();
                  smsConsentForOtpAutoFill!.requestSms();
                  setState(() {
                    this.startListen = true;
                  });
                  print("Start Listening.........");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
