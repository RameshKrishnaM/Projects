import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/custom_button.dart';
import 'package:ekyc/Custom%20Widgets/custom_form_field.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/Service/validate_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Custom Widgets/login_page_widget.dart';
import '../Route/route.dart' as route;

class Email extends StatefulWidget {
  final String state;
  final String tempUid;
  final String name;
  final String mobileNumber;
  const Email({
    super.key,
    required this.name,
    required this.mobileNumber,
    required this.state,
    required this.tempUid,
  });

  @override
  State<Email> createState() => _EmailState();
}

class _EmailState extends State<Email> {
  TextEditingController emailController = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  bool buttonIsLoading = false;
  bool emailIsValid = false;

  /* 
  Purpose: This method is used to call the email otp and routes to the mail otp page
  */
  emailOtpCall() async {
    loadingAlertBox(context);
    var json = await otpCallAPI(json: {
      "clientname": widget.name,
      "sendto": emailController.text,
      "sendtotype": "EMAIL",
    }, context: context);
    if (mounted) {
      Navigator.pop(context);
    }

    if (json != null) {
      Navigator.pushNamed(context, route.emailOTP, arguments: {
        "email": emailController.text,
        "encrypteval": json["encryptedval"],
        "insertedid": json["validateid"],
        "name": widget.name,
        "mobileNo": widget.mobileNumber,
        "state": widget.state,
        "tempUid": widget.tempUid,
      }).then((value) async {
        if (value == true) {
          Navigator.pushReplacementNamed(context, route.email, arguments: {
            "name": widget.name,
            "mobileNo": widget.mobileNumber,
            "state": widget.state,
            "tempUid": json["tempUid"],
          });
        }
      });
    }
    buttonIsLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  /* 
  Purpose: This method is used to check the email validation
  */

  checkEmailValidate(value) {
    emailIsValid = validateEmail(value) == null ? true : false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LoginPageWidget(
      isEmail: true,
      title: "Email",
      subTitle: "Tell us your Mail ID to receive an OTP for Verification",
      children: [
        Form(
          key: _formKey,
          child: CustomFormField(
            controller: emailController,
            labelText: "email",
            hintText: 'Enter the email',
            inputFormatters: [
              LengthLimitingTextInputFormatter(50),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@.]'))
            ],
            validator: emailValidation,
            onChange: checkEmailValidate,
          ),
        ),
        const Expanded(flex: 4, child: SizedBox()),
        const SizedBox(
          height: 10.0,
        ),
        CustomButton(
            buttonText: "Send OTP",
            buttonFunc: () {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              buttonIsLoading = true;
              if (mounted) {
                setState(() {});
              }
              emailOtpCall();
            }),
        const Expanded(child: SizedBox()),
        const SizedBox(height: 20.0)
      ],
    );
  }
}
