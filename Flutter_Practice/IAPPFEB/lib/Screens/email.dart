import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/custom_button.dart';
import 'package:ekyc/Custom%20Widgets/custom_form_field.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/Service/validate_func.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Custom Widgets/login_page_widget.dart';
import '../Route/route.dart' as route;

class Email extends StatefulWidget {
  final String state;
  final String tempUid;
  final String name;
  final String mobileNumber;
  // final String id;
  const Email({
    super.key,
    required this.name,
    required this.mobileNumber,
    required this.state,
    required this.tempUid,
    // required this.id
  });

  @override
  State<Email> createState() => _EmailState();
}

class _EmailState extends State<Email> {
  TextEditingController emailController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  // FormValidateNodifier formValidateNodifier =
  //     FormValidateNodifier({"email": false});
  bool buttonIsLoading = false;
  bool emailIsValid = false;
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
    print("Email otp generate--------------$json");

    if (json != null) {
      // print(json);
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
          // emailController.clear();
          // await Future.delayed(Duration(seconds: 500));
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   _formKey.currentState!.reset();

          // });
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

  checkEmailValidate(value) {
    emailIsValid = validateEmail(value) == null ? true : false;
    setState(() {});
  }

  @override
  void initState() {
    print("object");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoginPageWidget(
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
              // NoSapceInputFormatter(),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@.]'))
            ],
            validator: emailValidation,
            onChange: checkEmailValidate,
          ),
        ),
        const Expanded(flex: 4, child: SizedBox()),
        // Container(
        //   alignment: Alignment.center,
        //   child: Text.rich(
        //       style:
        //           const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
        //       TextSpan(children: <InlineSpan>[
        //         const TextSpan(
        //             text: 'By proceeding , I agree to the',
        //             style: TextStyle(color: Color.fromRGBO(102, 98, 98, 1))),
        //         TextSpan(
        //             text: " T&C",
        //             style:
        //                 const TextStyle(color: Color.fromRGBO(50, 169, 220, 1)),
        //             recognizer: TapGestureRecognizer()
        //               ..onTap = () async {
        //                 //  Navigator.pushNamed(
        //                 //   context, route.esignHtml,
        //                 //   arguments: {"url": "https://flattrade.in/terms"})
        //                 if (await canLaunchUrlString(
        //                     "https://flattrade.in/terms")) {
        //                   launchUrlString("https://flattrade.in/terms");
        //                 }
        //               }),
        //         const TextSpan(
        //             text: ' and',
        //             style: TextStyle(color: Color.fromRGBO(102, 98, 98, 1))),
        //         TextSpan(
        //             text: " privacy Policy",
        //             style:
        //                 const TextStyle(color: Color.fromRGBO(50, 169, 220, 1)),
        //             recognizer: TapGestureRecognizer()
        //               ..onTap = () async {
        //                 //  Navigator.pushNamed(
        //                 //   context, route.esignHtml,
        //                 //   arguments: {"url": "https://flattrade.in/terms"})
        //                 if (await canLaunchUrlString(
        //                     "https://flattrade.in/privacy")) {
        //                   launchUrlString("https://flattrade.in/privacy");
        //                 }
        //               }),
        //       ])),
        // ),
        const SizedBox(
          height: 10.0,
        ),
        CustomButton(
            buttonText: "Send OTP",
            // valueListenable: formValidateNodifier,
            buttonFunc:
                //  buttonIsLoading || !emailIsValid
                //     ? null
                //     :
                () {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              buttonIsLoading = true;
              if (mounted) {
                setState(() {});
              }
              emailOtpCall();
            }

            // Navigator.pushNamed(context, route.emailOTP, arguments: {
            //   "email": emailController.text,
            //   "encrypteval": "dxxxxxxxx@gxxxx.com",
            //   "insertedid": "123",
            //   "name": widget.name,
            //   "mobileNo": widget.mobileNumber,
            //   "state": widget.state
            // }),
            ),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}
