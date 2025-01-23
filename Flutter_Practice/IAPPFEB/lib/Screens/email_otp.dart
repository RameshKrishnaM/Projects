import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:provider/provider.dart';

import '../API%20call/api_call.dart';
import '../Cookies/cookies.dart';
import '../Custom%20Widgets/login_page_widget.dart';
import '../Firebase_and_Facebook/event_capure.dart';
import '../Route/route.dart';
import '../Screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Custom Widgets/custom_button.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../Custom Widgets/custom_snackBar.dart';
import '../Nodifier/nodifierCLass.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../Route/route.dart' as route;
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
  FormValidateNodifier formValidateNodifier =
      FormValidateNodifier({"otp": false});
  String id = "";
  bool isResendingOTP = false;
  bool buttonIsLoading = false;
  bool formIsValid = false;
  Duration time = const Duration(minutes: 1);
  Timer? timer;
  // String otp = "";
  String mail = "";
  emailOtpCall() async {
    print(" tempuidddd-----${widget.tempUid}");
    loadingAlertBox(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    print("alidateid------${widget.id}");
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
    print("Email otp valid--------------$response");
    if (response["status"] == "S") {
      login();
      await getNextRoute(context);
      return;
    } else if (response["status"] != "S") {
      print("entered error status");
      switch (response["statusCode"]) {
        case "MC":
          {
            print("mccccc");
            Navigator.pop(context);
            showSnackbar(context, response["msg"], Colors.red);
            // Navigator.popUntil(
            //     context, (route) => route.settings.name == "/Signup"
            //     // route.signup,
            //     // (route) => false,
            //     );
            Navigator.pushNamedAndRemoveUntil(
              context,
              route.signup,
              (route) => route.isFirst,
            );

            break;
          }
        case "EC":
          {
            print(response["tempUid"]);
            Navigator.pop(context);
            showSnackbar(context, response["msg"], Colors.red);
            // print("poaoaihfslhfekhfkjg");
            // Navigator.popAndPushNamed(context, route.email, arguments: {
            //   "name": widget.name,
            //   "mobileNo": widget.mobileNumber,
            //   "state": widget.state,
            //   "tempUid": widget.tempUid,
            // });
            Navigator.pop(context, true);
            break;
          }
        case "MEC":
          {
            // showSnackbar(context, response["msg"], Colors.red);
            Navigator.pop(context);
            // print("start");
            Navigator.pushNamed(
              context,
              route.congratulation,
              // (route) => route.isFirst,
            );
            // print("end");

            break;
          }
        default:
          {
            Navigator.pop(context);
            // print("idd-----${id} -----${widget.encryptEmail}");
            showSnackbar(context, response["msg"], Colors.red);
          }
      }
    }

    buttonIsLoading = false;
    // if (mounted) {
    //   Navigator.pop(context);
    //   setState(() {});
    // }
  }

  login() async {
    // var response = await loginAPI(context: context, json: {
    //   "clientname": widget.name,
    //   "phone": widget.mobileNumber,
    //   "email": widget.email,
    //   "state": widget.state
    // });
    // print(jsonEncode({
    //   "name": widget.name,
    //   "phone": widget.mobileNumber,
    //   "email": widget.email,
    //   "state": widget.state
    // }));

    // if (response != null) {
    if (true) {
      print("login sucess");
      Provider.of<Postmap>(context, listen: false)
          .changeMobileNo(widget.mobileNumber);
      Provider.of<Postmap>(context, listen: false).changeEmail(mail);
      setMobileNo(widget.mobileNumber);
      setEmail(mail);
      var firebaseFirestoreInstance = FirebaseFirestore.instance;
      String? token = await FirebaseMessaging.instance.getToken();
      String collectionName = 'user';
      try {
        var collectionDetails =
            await firebaseFirestoreInstance.collection(collectionName).get();
        // print("changes ${collectionDetails.docChanges}");
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
        // else {
        //   Map<String, dynamic> oldDetails = value.docs[index].data();
        //   oldDetails["phone"] = "9876500104";
        //   firebaseFirestoreInstance.doc(widget.email).update(oldDetails);
        //
      } catch (e) {
        firebaseFirestoreInstance
            .collection(collectionName)
            .doc(widget.mobileNumber)
            .set({
          "name": widget.name,
          "Date": DateTime.now().toString().substring(0, 10),
          "phone": widget.mobileNumber,
          "email": mail,
          "token": token,
          "stage": routeNames[route.signup]
        });
        subScribeTopic(routeNames[route.signup]);
        insertEvents(context, routeNames[route.signup]);
      }
      // FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      // var a = await firebaseFirestore.collection("user").get();
      // if (a.docs.) {
      //   print("present");
      // } else {
      //   print("not present");
      // }
    }
  }

  getNextRoute(context) async {
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.signup],
      "routeraction": "Next"
    });
    print("route response------${response}");

    if (response != null) {
      String status = await getStatus();
      // if (widget.mobileNumber == CustomHttpClient.testMobileNo &&
      //     widget.email == CustomHttpClient.testEmail) {
      //   if (status == "c") {
      //     Navigator.pushNamedAndRemoveUntil(
      //         context, route.congratulationTest, (route) => route.isFirst);
      //   } else {
      //     Navigator.pushNamedAndRemoveUntil(
      //         context, route.panCard, (route) => route.isFirst);
      //   }
      // } else {
      print("endpoint....${response["endpoint"]}");
      Navigator.pop(context);
      Navigator.pushNamed(context, response["endpoint"]);
      // }
    } else {
      buttonIsLoading = false;
      if (mounted) {
        Navigator.pop(context);
        setState(() {});
      }
    }
  }

  ResendEmailOTP() async {
    loadingAlertBox(context);
    // String code = states.firstWhere(
    //     (element) => element["description"] == state.text)["code"];
    var json = await otpCallAPI(json: {
      "clientname": widget.name,
      "sendto": mail,
      "sendtotype": "EMAIL"
    }, context: context);
    if (json != null) {
      // print(json);
      id = json["validateid"];
      time = const Duration(minutes: 1);
      widget.encryptEmail = json["encryptedval"];
      timerFunc();
      isResendingOTP = false;
      // showSnackbar(context, "OTP sent Sucessfully", Colors.green);
      // otp = json["encryptedval"].split("##")[1];
      if (mounted) {
        setState(() {});
      }
      // showSnackbar(context, json["encrypteval"].split("##")[1], Colors.green);
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
    print(" tempuidddd-----${widget.tempUid}");
    id = widget.id;
    print("email va;id id-----$id");
    mail = widget.email == "" ? widget.encryptEmail : widget.email;
    print("encrptyyyyyy ${widget.encryptEmail}");
    timerFunc();
    // otp = widget.encryptEmail.split("##")[1];
    if (mounted) {
      setState(() {});
    }
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showSnackbar(context, widget.encryptEmail.split("##")[1], Colors.green);
    // });
    super.initState();
  }

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

//   @override
//   void initState() {
//     int atIndex = widget.email.lastIndexOf("@");
//     // subString for email upto @
//     String first = widget.email.substring(0, atIndex);
//     // replace content to *
//     first = first.replaceRange(1, first.length, "x" * (first.length - 1));
// // subString for email then @
//     String last = widget.email.substring(atIndex);
//     // find . position
//     int dotIndex = last.lastIndexOf(".");
//     // repace to *
//     last = last.replaceRange(2, dotIndex, "x" * (dotIndex - 2));
//     tempEmail = first + last;
//     super.initState();
//   }

  @override
  Widget build(BuildContext context) {
    return LoginPageWidget(
      title: "Email OTP Verification",
      subTitle:
          // "We have sent a OTP to your registered Mail id dxxxxxx.gxxxx.com",
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
                  cursor: Cursor(
                      enabled: true,
                      width: 2,
                      height: 20,
                      color: Theme.of(context).colorScheme.primary),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  codeLength: 6,
                  decoration:
                      //  CirclePinDecoration(
                      //     strokeColorBuilder: PinListenColorBuilder(
                      //         Theme.of(context).colorScheme.primary, grey1),
                      //     bgColorBuilder: FixedColorListBuilder(List.generate(
                      //         6, (index) => Color.fromARGB(255, 248, 248, 255)))),

                      BoxLooseDecoration(
                          gapSpace: 12,
                          radius: Radius.circular(6.5),
                          strokeWidth: 1.3,
                          textStyle: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color),
                          strokeColorBuilder: PinListenColorBuilder(
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary
                              // Colors.blue,
                              // Theme.of(context).textTheme.bodyMedium!.color ??
                              //     Colors.black
                              ),
                          bgColorBuilder: FixedColorBuilder(
                              Color.fromRGBO(255, 255, 255, 1))),
                  enableInteractiveSelection: false,
                  currentCode: otpPinController.text,
                  controller: otpPinController,
                  onCodeChanged: (p0) {
                    // formValidateNodifier.changeValue(formValidateNodifier.getValue
                    //   ..["otp"] = p0?.length == 6 ? true : false);
                    formIsValid = p0?.length == 6 ? true : false;
                    if (mounted) {
                      setState(() {});
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
                            ResendEmailOTP();
                          },
                    child: Text(
                      "Resend OTP !",
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
        // const SizedBox(height: 10.0),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text(
        //       widget.encryptEmail.split("#").last,
        //       style: const TextStyle(
        //           fontSize: 18.0,
        //           fontWeight: FontWeight.bold,
        //           color: Colors.black),
        //     ),
        //   ],
        // ),
        const Expanded(flex: 4, child: SizedBox()),
        CustomButton(
            valueListenable: formValidateNodifier,
            buttonFunc:
                //  buttonIsLoading || !formIsValid
                //     ? null
                //     :
                () {
              if (otpPinController.text.length != 6) {
                showSnackbar(context, "Please enter valid OTP", Colors.red);
                return;
              }
              buttonIsLoading = true;
              if (mounted) {
                setState(() {});
              }
              emailOtpCall();
              // Navigator.pushNamed(context, route.panCard);
            }),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}
