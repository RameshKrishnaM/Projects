import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerifyOTPScreen extends StatefulWidget {
  const VerifyOTPScreen({Key? key}) : super(key: key);

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  String codeValue = "";

  @override
  void initState() {
    getAppSignature();
    // TODO: implement initState
    super.initState();
  }

  getAppSignature() async {
    appSignature = await SmsAutoFill().getAppSignature;
    print(appSignature);
    SmsAutoFill().listenForCode();
    setState(() {});
  }

  String appSignature = '';
  // void listenOtp() async {
  //   // await SmsAutoFill().unregisterListener();
  //   // listenForCode();

  //   print("OTP listen Called");
  // }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    print("unregisterListener");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: PinFieldAutoFill(
                currentCode: codeValue,
                codeLength: 4,
                onCodeChanged: (code) {
                  print("onCodeChanged $code");
                  setState(() {
                    codeValue = code.toString();
                  });
                },
                onCodeSubmitted: (val) {
                  print("onCodeSubmitted $val");
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  print(codeValue);
                },
                child: const Text("Verify OTP")),
            ElevatedButton(
                onPressed: getAppSignature, child: const Text("Resend")),
            SizedBox(
              height: 10,
            ),
            Text(appSignature)
          ],
        ),
      ),
    );
  }
}
