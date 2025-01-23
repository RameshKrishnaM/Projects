import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/login_page_widget.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../Custom Widgets/custom_button.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../Custom Widgets/custom_snackBar.dart';

// import 'package:telephony/telephony.dart';
import '../Firebase_and_Facebook/event_capure.dart';
import '../Route/route.dart' as route;
import '../Route/route.dart';
// import 'package:readsms/readsms.dart';

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
  // FormValidateNodifier formValidateNodifier =
  //     FormValidateNodifier({"otp": false});
  bool formIsValid = false;
  bool isResendingOTP = false;
  String id = "";
  bool buttonIsLoading = false;
  Duration time = const Duration(minutes: 1);
  Timer? timer;
  String otp = "";
  // final readSms = Readsms();
  // final Telephony telephony = Telephony.instance;
  @override
  void initState() {
    // SmsAutoFill().unregisterListener();
    // SmsAutoFill().listenForCode();
    // listenOTP();
    // if (!Platform.isIOS) {
    //   listenOtp();
    // }
    id = widget.validateId;

    // print("id $id");
    secureMobileNumber = widget.encryptMobileNumber.replaceAll("*", "x");
    // "${widget.mobileNumber.substring(0, 3)} xxxxxx${widget.mobileNumber.substring(9)}"; //987654
    timerFunc();
    // otp = widget.encryptMobileNumber.split("##")[1];
    if (mounted) {
      setState(() {});
    }
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showSnackbar(
    //       context, widget.encryptMobileNumber.split("##")[1], Colors.green);
    // });
    super.initState();
  }

  // listenOtp() {
  //   readSms.read();
  //   readSms.smsStream.listen((sms) {
  //     if (sms.body.contains("www.Flattrade.in")) {
  //       Match? match = RegExp(r'\d{6}').firstMatch(sms.body);
  //       if (match != null) {
  //         try {
  //           otpPinController.text = match.group(0)!;
  //         } catch (e) {}
  //       }
  //     }
  //   });
  // }
  // listenOTP() {
  //   telephony.listenIncomingSms(
  //     onNewMessage: (SmsMessage message) {
  //       String sms = message.body ?? "";
  //       if (sms.contains("www.Flattrade.in")) {
  //         String code = RegExp(r'(\d{6})').stringMatch(sms) ?? "";
  //         code.isNotEmpty ? otpPinController.text = code : null;
  //       }
  //     },
  //   );
  // }

// {"encrypteval":"d**********@g****.com##845504","insertedid":"5740","attemptcount":1,"status":"S"}
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
    print("mobile otp valid--------------$json");

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
        // else {
        //   Map<String, dynamic> oldDetails = value.docs[index].data();
        //   oldDetails["phone"] = "9876500104";
        //   firebaseFirestoreInstance.doc(widget.email).update(oldDetails);
        //
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
        print("mobile valid iddd----${json}");
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
        // (route) => false,
      );
      // Navigator.pop(context);
    }
    //  else if (mounted) {
    //   Navigator.pop(context);
    // }
    else if (json["status"] == "E") {
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

  timerFunc() async {
    // print("aggSIgnature :${await SmsAutoFill().getAppSignature}");
    // showSnackbar(context, await SmsAutoFill().getAppSignature, Colors.red);
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

  ResendMobileOTP() async {
    loadingAlertBox(context);
    // String code = states.firstWhere(
    //     (element) => element["description"] == state.text)["code"];

    print("entered!!!!");
    var json = await otpCallAPI(json: {
      "clientname": widget.name,
      "sendto": widget.mobileNumber,
      "sendtotype": "phone"
    }, context: context);
    if (json != null) {
      // SmsAutoFill().unregisterListener();
      // SmsAutoFill().listenForCode();
      print(json);
      time = const Duration(minutes: 1);
      timerFunc();
      widget.encryptMobileNumber = json["encryptedval"];
      id = json["validateid"];
      isResendingOTP = false;
      // showSnackbar(context, "OTP sent Sucessfully", Colors.green);
      // otp = json["encryptedval"].split("##")[1];
      if (mounted) {
        setState(() {});
      }
      // showSnackbar(context, json["encrypteval"].split("##")[1], Colors.green);
      // setState(() {});
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
    // SmsAutoFill().unregisterListener();
    timer!.cancel();
    // if (!Platform.isIOS) {
    //   readSms.dispose();
    // }

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
                          // errorText: "",
                          // errorTextStyle: TextStyle(height: 1.5),
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
                            ResendMobileOTP();
                          },
                    child: Text(
                      //Resend with in :00:42
                      "Resend OTP !",
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
        // const SizedBox(height: 10.0),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text(
        //       widget.encryptMobileNumber.split("#").last,
        //       style: const TextStyle(
        //           fontSize: 18.0,
        //           fontWeight: FontWeight.bold,
        //           color: Colors.black),
        //     ),
        //   ],
        // ),
        const Expanded(flex: 4, child: SizedBox()),
        CustomButton(
            // buttonText: "Send OTP",
            buttonFunc:
                //  buttonIsLoading || !formIsValid
                //     ? null
                //     :
                () {
          if (otpPinController.text.length != 6) {
            showSnackbar(context, "Please enter valid OTP", Colors.red);
            return;
          } else {
            ScaffoldMessenger.of(context).clearSnackBars();
          }
          buttonIsLoading = true;
          if (mounted) {
            setState(() {});
          }
          verifyMobileOTP();
        }
            //     () => Navigator.pushNamed(context, route.email, arguments: {
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
