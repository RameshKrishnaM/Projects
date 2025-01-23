import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../API%20call/api_call.dart';
import '../Custom Widgets/custom_snackbar.dart';
import '../Custom%20Widgets/login_page_widget.dart';
import '../Firebase_and_Facebook/event_capure.dart';
import '../Route/route.dart' as route;
import '../Route/route.dart';
import '../Screens/signup.dart';
import '../shared_preferences/shared_preference_func.dart';

class EmailOTP extends StatefulWidget {
  final String state;
  String encryptEmail;
  final String tempUid;
  final String name;
  final String email;
  final String mobileNumber;
  final String id;
  EmailOTP(
      {super.key,
      required this.email,
      required this.id,
      required this.encryptEmail,
      required this.name,
      required this.mobileNumber,
      required this.state,
      required this.tempUid});

  @override
  State<EmailOTP> createState() => _EmailOTPState();
}

class _EmailOTPState extends State<EmailOTP> {
  String? tempEmail;
  TextEditingController otpPinController = TextEditingController();
  String id = "";
  bool isResendingOTP = false;
  bool buttonIsLoading = false;
  bool formIsValid = false;
  Duration time = const Duration(minutes: 1);
  Timer? timer;
  String mail = "";
  late FocusNode _focusNode;

  /* 
  Purpose: This method is used to validate the email Otp and move to the next route accourding to the response
  */

  emailOtpCall() async {
    loadingAlertBox(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    var response = await validateOTPAPI(json: {
      "clientname": widget.name,
      "email": mail,
      "otp": otpPinController.text,
      "otptype": "email",
      "phone": widget.mobileNumber,
      "state": widget.state,
      "tempUid": widget.tempUid,
      "url": "",
      "validateId": id,
    }, context: context);
    if (response["status"] == "S") {
      login();
      await getNextRoute(context);
      return;
    } else if (response["status"] != "S") {
      switch (response["statusCode"]) {
        case "MC":
          {
            Navigator.pop(context);
            showSnackbar(context, response["msg"], Colors.red);
            Navigator.pushNamedAndRemoveUntil(
              context,
              route.signup,
              (route) => route.isFirst,
            );

            break;
          }
        case "EC":
          {
            Navigator.pop(context);
            showSnackbar(context, response["msg"], Colors.red);
            Navigator.pop(context, true);
            break;
          }
        case "MEC":
          {
            Navigator.pop(context);
            Navigator.pushNamed(
              context,
              route.congratulation,
            );

            break;
          }
        default:
          {
            Navigator.pop(context);
            showSnackbar(context, response["msg"], Colors.red);
          }
      }
    }

    buttonIsLoading = false;
  }

  /* 
  Purpose: This method is used to store the necessary login details into firebase , provider , shared preference 
  */

  login() async {
    if (true) {
      Provider.of<ProviderClass>(context, listen: false)
          .changeMobileNo(widget.mobileNumber);
      Provider.of<ProviderClass>(context, listen: false).changeEmail(mail);
      setMobileNo(widget.mobileNumber);
      setEmail(mail);
      var firebaseFirestoreInstance = FirebaseFirestore.instance;
      String? token = await FirebaseMessaging.instance.getToken();
      String collectionName = 'user';
      try {
        var collectionDetails =
            await firebaseFirestoreInstance.collection(collectionName).get();
        int index = collectionDetails.docs
            .indexWhere((element) => element.id == widget.mobileNumber);
        if (index == -1) {
          throw Exception("not present");
        } else {
          Map<String, dynamic> data = collectionDetails.docs[index].data();
          if (widget.email.trim().isNotEmpty &&
              data["email"] != widget.email.trim()) {
            data["email"] = widget.email.trim();
            firebaseFirestoreInstance
                .collection(collectionName)
                .doc(widget.mobileNumber)
                .update(data);
          }
        }
      } catch (e) {
        firebaseFirestoreInstance
            .collection(collectionName)
            .doc(widget.mobileNumber)
            .set({
          "name": widget.name,
          "Date": DateTime.now().toString().substring(0, 10),
          "phone": widget.mobileNumber,
          "email": widget.email,
          "token": token,
          "stage": routeNames[route.signup]
        });
        subScribeTopic(routeNames[route.signup]);
        insertEvents(context, routeNames[route.signup]);
      }
    }
  }

  /* 
  Purpose: This method is used to get the next route name from the api
  */

  getNextRoute(context) async {
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.signup],
      "routeraction": "Next"
    });

    if (response != null) {
      Navigator.pop(context);
      Navigator.pushNamed(context, response["endpoint"]);
    } else {
      buttonIsLoading = false;
      if (mounted) {
        Navigator.pop(context);
        setState(() {});
      }
    }
  }

  /* 
  Purpose: This method is used to resent the mail otp 
  */

  reSendEmailOTP() async {
    loadingAlertBox(context);
    var json = await otpCallAPI(json: {
      "clientname": widget.name,
      "sendto": mail,
      "sendtotype": "EMAIL"
    }, context: context);
    if (json != null) {
      id = json["validateid"];
      time = const Duration(minutes: 1);
      widget.encryptEmail = json["encryptedval"];
      timerFunc();
      isResendingOTP = false;
      if (mounted) {
        setState(() {});
      }
    } else {
      isResendingOTP = false;
      if (mounted) {
        setState(() {});
      }
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    id = widget.id;
    mail = widget.email == "" ? widget.encryptEmail : widget.email;
    timerFunc();
    if (mounted) {
      setState(() {});
    }
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    timer!.cancel();
    _focusNode.dispose();
    super.dispose();
  }
  /* 
  Purpose: This method is used to run hte time func
  */

  timerFunc() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      time = time - const Duration(seconds: 1);
      if (time == Duration.zero) {
        Future.delayed(const Duration(milliseconds: 500), () {
          timer.cancel();
          if (mounted) {
            setState(() {});
          }
        });
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoginPageWidget(
      title: "Email OTP Verification",
      subTitle:
          // "We have sent an OTP to your registered Mail ID ${widget.encryptEmail.substring(0, widget.encryptEmail.indexOf("#")).replaceAll("*", "x")}",
          "We have sent an OTP to your registered Mail ID ${(widget.encryptEmail.split("#").first).replaceAll("*", "x")}",
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40.0,
                width: MediaQuery.of(context).size.width - 60 > 315
                    ? 315
                    : MediaQuery.of(context).size.width - 60,
                child: PinFieldAutoFill(
                  focusNode: _focusNode,
                  cursor: Cursor(
                      enabled: true,
                      width: 2,
                      height: 20,
                      color: Theme.of(context).colorScheme.primary),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  codeLength: 6,
                  decoration: BoxLooseDecoration(
                      gapSpace: 12,
                      radius: Radius.circular(6.5),
                      strokeWidth: 1.3,
                      textStyle: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                      strokeColorBuilder: PinListenColorBuilder(
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary),
                      bgColorBuilder:
                          FixedColorBuilder(Color.fromRGBO(255, 255, 255, 1))),
                  enableInteractiveSelection: false,
                  currentCode: otpPinController.text,
                  controller: otpPinController,
                  onCodeChanged: (p0) {
                    formIsValid = p0?.length == 6 ? true : false;
                    if (mounted) {
                      setState(() {});
                      if (formIsValid) {
                        emailOtpCall();
                        _focusNode.unfocus();
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Visibility(
              visible: otpPinController.text != "",
              replacement: SizedBox(
                width: 20.0,
              ),
              child: GestureDetector(
                child: Icon(
                  Icons.cancel_outlined,
                  size: 20.0,
                ),
                onTap: () => otpPinController.text = "",
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            timer != null && timer!.isActive
                ? RichText(
                    text: TextSpan(children: <InlineSpan>[
                      const WidgetSpan(child: Text("Resend with in:")),
                      WidgetSpan(
                          child: Text(
                        time.toString().substring(2, 7),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                    ]),
                  )
                : InkWell(
                    onTap: isResendingOTP
                        ? null
                        : () {
                            isResendingOTP = true;
                            if (mounted) {
                              setState(() {});
                            }
                            reSendEmailOTP();
                          },
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
            Expanded(child: SizedBox()),
            InkWell(
              onTap: () {
                if (widget.email == "") {
                  Navigator.pushReplacementNamed(context, route.email,
                      arguments: {
                        "name": widget.name,
                        "mobileNo": widget.mobileNumber,
                        "state": widget.state,
                        "tempUid": widget.tempUid,
                      });
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(
                "Change Email",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            )
          ],
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.encryptEmail.split("#").last,
              style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
        const Expanded(flex: 4, child: SizedBox()),
        // CustomButton(buttonFunc: () {
        //   if (otpPinController.text.length != 6) {
        //     showSnackbar(context, "Please enter valid OTP", Colors.red);
        //     return;
        //   }
        //   buttonIsLoading = true;
        //   if (mounted) {
        //     setState(() {});
        //   }
        //   emailOtpCall();
        // }),
        const Expanded(child: SizedBox()),
        const SizedBox(height: 20.0)
      ],
    );
  }
}
