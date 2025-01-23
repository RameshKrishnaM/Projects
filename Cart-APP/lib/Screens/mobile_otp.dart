import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/login_page_widget.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../Custom Widgets/custom_snackbar.dart';
import '../Firebase_and_Facebook/event_capure.dart';
import '../Route/route.dart' as route;
import '../Route/route.dart';

class MobileOTP extends StatefulWidget {
  final String state;
  final String validateId;
  final String mobileNumber;
  final String tempUid;
  String encryptMobileNumber;
  final String name;
  MobileOTP(
      {super.key,
      required this.mobileNumber,
      required this.validateId,
      required this.name,
      required this.encryptMobileNumber,
      required this.state,
      required this.tempUid});

  @override
  State<MobileOTP> createState() => _MobileOTPState();
}

class _MobileOTPState extends State<MobileOTP> {
  String? secureMobileNumber;
  TextEditingController otpPinController = TextEditingController();
  bool formIsValid = false;
  bool isResendingOTP = false;
  String id = "";
  bool buttonIsLoading = false;
  Duration time = const Duration(minutes: 1);
  Timer? timer;
  String otp = "";
  late FocusNode _focusNode;
  @override
  void initState() {
    id = widget.validateId;
    secureMobileNumber = widget.encryptMobileNumber.replaceAll("*", "x");
    timerFunc();
    if (mounted) {
      setState(() {});
    }
    _focusNode = FocusNode();

    super.initState();
  }

  /* 
  Purpose: This method is used to verify the Otp and move to the page according to the status from the response
  */

  verifyMobileOTP() async {
    loadingAlertBox(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    var json = await validateOTPAPI(json: {
      "clientname": widget.name,
      "email": "",
      "otp": otpPinController.text,
      "otptype": "phone",
      "phone": widget.mobileNumber,
      "state": widget.state,
      "tempUid": widget.tempUid,
      "url": "",
      "validateId": id,
    }, context: context);

    if (json["status"] == "S") {
      var firebaseFirestoreInstance = FirebaseFirestore.instance;
      String? token = await FirebaseMessaging.instance.getToken();
      String collectionName = 'user';
      try {
        var collectionDetails =
            await firebaseFirestoreInstance.collection(collectionName).get();
        int index = collectionDetails.docs
            .indexWhere((element) => element.id == widget.mobileNumber.trim());
        if (index == -1) {
          throw Exception("not present");
        } else {
          Map<String, dynamic> data = collectionDetails.docs[index].data();
          data["token"] = token ?? "";
          firebaseFirestoreInstance
              .collection(collectionName)
              .doc(widget.mobileNumber.trim())
              .update(data);
        }
      } catch (e) {
        firebaseFirestoreInstance
            .collection(collectionName)
            .doc(widget.mobileNumber.trim())
            .set({
          "name": widget.name.trim(),
          "Date": DateTime.now().toString().substring(0, 10),
          "phone": widget.mobileNumber.trim(),
          "email": "",
          "token": token,
          "stage": routeNames[route.signup]
        });
        subScribeTopic(routeNames[route.signup]);
        insertEvents(context, routeNames[route.signup]);
      }
      if (mounted) {
        Navigator.pop(context);
      }
      if (json["encryptedval"] == "") {
        Navigator.pushNamed(context, route.email, arguments: {
          "name": widget.name,
          "mobileNo": widget.mobileNumber,
          "state": widget.state,
          "tempUid": json["tempUid"],
        });
      } else {
        Navigator.pushNamed(context, route.emailOTP, arguments: {
          "tempUid": json["tempUid"],
          "email": "",
          "encrypteval": json["encryptedval"],
          "insertedid": json["validateid"],
          "name": widget.name,
          "mobileNo": widget.mobileNumber,
          "state": widget.state,
        });
      }
    } else if (json["status"] != "S" && json["statusCode"] == "MC") {
      Navigator.pop(context);
      showSnackbar(context, json["msg"], Colors.red);
      Navigator.popAndPushNamed(
        context,
        route.signup,
      );
    } else if (json["status"] == "E") {
      Navigator.pop(context);
      showSnackbar(context, json["msg"], Colors.red);
    } else {
      Navigator.pop(context);
    }

    buttonIsLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  /* 
  Purpose: This method is used to run the time 
  */

  timerFunc() async {
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

  /* 
  Purpose: This method is used to resend the mobile otp
  */

  reSendMobileOTP() async {
    loadingAlertBox(context);
    var json = await otpCallAPI(json: {
      "clientname": widget.name,
      "sendto": widget.mobileNumber,
      "sendtotype": "phone"
    }, context: context);
    if (json != null) {
      time = const Duration(minutes: 1);
      timerFunc();
      widget.encryptMobileNumber = json["encryptedval"];
      id = json["validateid"];
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
  void dispose() {
    timer!.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginPageWidget(
      title: "Mobile OTP Verification",
      subTitle:
          // "We have sent an OTP to your registered Mobile number ${widget.encryptMobileNumber.substring(0, widget.encryptMobileNumber.indexOf("#")).replaceAll("*", "x")}",
          "We have sent an OTP to your registered Mobile number ${(widget.encryptMobileNumber.split("#").first).replaceAll("*", "x")}",
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
                    }
                    if (formIsValid) {
                      verifyMobileOTP();
                      _focusNode.unfocus();
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
                            reSendMobileOTP();
                          },
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
            Expanded(
              child: SizedBox(),
            ),
            InkWell(
              onTap: () => Navigator.pop(context, true),
              child: Text("Change Number",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            )
          ],
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.encryptMobileNumber.split("#").last,
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
        //   } else {
        //     ScaffoldMessenger.of(context).clearSnackBars();
        //   }
        //   buttonIsLoading = true;
        //   if (mounted) {
        //     setState(() {});
        //   }
        //   verifyMobileOTP();
        // }),
        const Expanded(child: SizedBox()),
        const SizedBox(height: 20.0)
      ],
    );
  }
}
