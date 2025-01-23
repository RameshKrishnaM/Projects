import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/custom_button.dart';
import 'package:ekyc/Custom%20Widgets/custom_form_field.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackbar.dart';
import 'package:ekyc/Custom%20Widgets/date_picker_form_field.dart';
import 'package:ekyc/Custom%20Widgets/stepwidget.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/Service/validate_func.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

import '../Nodifier/nodifierclass.dart';
import '../Route/route.dart' as route;
import '../provider/provider.dart';
import '../shared_preferences/shared_preference_func.dart';

class PanCard extends StatefulWidget {
  const PanCard({super.key});

  @override
  State<PanCard> createState() => _PanCardState();
}

class _PanCardState extends State<PanCard> {
  TextEditingController nameController = TextEditingController();
  TextEditingController panNumberController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String digiId = "";
  String verifyFlag = "KRAVERIFY";
  FormValidateNodifier formValidateNodifier =
      FormValidateNodifier({"PAN Number": false, "Date of Birth": false});
  DateChange dob = DateChange();
  Map? address;
  bool buttonIsLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool formIsValid = false;
  bool? panValidate;
  bool verifyButtonClicked = false;
  String errorCode = "";
  String nameFlag = "";
  String oldName = " ";
  String oldPan = " ";
  DateTime oldDate = DateTime.now().add(const Duration(days: 1));

  /* 
  Purpose: This method is used to check the pan details and show the apropriate fields according to the response and also move to the next page 
  */

  checkPanDetails() async {
    loadingAlertBox(context);
    buttonIsLoading = true;
    if (mounted) {
      setState(() {});
    }
    String date = dob.value == null || dob.value.toString().isEmpty
        ? ""
        : "${dob.value.toString().substring(8, 10)}/${dob.value.toString().substring(5, 7)}/${dob.value.toString().substring(0, 4)}";
    var response = await postPanNo(
      digiid: digiId,
      verifyflag: verifyFlag,
      context: context,
      panname: nameController.text.trim(),
      pannumber: panNumberController.text.toUpperCase(),
      pandob: date,
    );
    Navigator.pop(context);
    if (response != null) {
      verifyButtonClicked = false;
      if (response["status"] == "S") {
        nameController.text = response["name"]!;
        showBottomSheet(response["name"]!, context, response);
        var firebaseFirestoreInstance = FirebaseFirestore.instance;
        String? token = await FirebaseMessaging.instance.getToken();
        String collectionName = 'user';
        String mobileNo = await getMobileNo();
        String email = await getEmail();
        try {
          var collectionDetails =
              await firebaseFirestoreInstance.collection(collectionName).get();
          int index = collectionDetails.docs
              .indexWhere((element) => element.id == mobileNo);
          if (index == -1) {
            throw Exception("not present");
          } else {
            Map<String, dynamic> data = collectionDetails.docs[index].data();
            if (response["name"].trim().isNotEmpty &&
                data["name"] != response["name"].trim()) {
              data["name"] = response["name"].trim();
              firebaseFirestoreInstance
                  .collection(collectionName)
                  .doc(mobileNo)
                  .update(data);
            }
          }
        } catch (e) {
          firebaseFirestoreInstance
              .collection(collectionName)
              .doc(mobileNo)
              .set({
            "name": response["name"],
            "Date": DateTime.now().toString().substring(0, 10),
            "phone": mobileNo,
            "email": email,
            "token": token,
            "stage": ""
          });
        }
        panValidate = true;
      } else if (response["status"] == "E") {
        if (response["statusCode"] == "reDirectUrl") {
          List<int> bytes = base64.decode(response["msg"]!);

          String normalString = utf8.decode(bytes);

          Navigator.pushNamed(context, route.esignHtml,
                  arguments: {"url": normalString, "routeName": route.panCard})
              .then((value) {
            String url = Provider.of<ProviderClass>(context, listen: false).url;
            if (url != null && url.isNotEmpty) {
              getDigiLockerDetails(url);
            } else {}
          });
          return;
        }
        digiId = '';
        errorCode = response["statusCode"] ?? "";
        if (response["statusCode"] == "E") {
          showSnackbar(context, response["msg"]!, Colors.red);
          return;
        }
        verifyFlag = errorCode == "PAN" ? "KRAVERIFY" : errorCode;

        oldName = nameController.text;
        oldPan = panNumberController.text;
        oldDate = dob.value ?? DateTime.now().add(Duration(days: 1));

        if (errorCode != "DOBFLAG") {
          errorBottomSheet(nameController.text, response["msg"]!, context);
        }
      }
    }
    buttonIsLoading = false;
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        checkFormValidOrNot("");
      });
    }
  }

  /* 
  Purpose: This method is used to get the next route name from the api 
  */

  getNextRoute(context) async {
    loadingAlertBox(context);

    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.panCard],
      "routeraction": "Next"
    });
    if (mounted) {
      Navigator.pop(context);
    }
    if (response != null) {
      Navigator.pushNamed(context, response["endpoint"]);
    }
  }

  /* 
  Purpose: This method is used to check the form valids 
  */

  checkFormValidOrNot(value) {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (panNumberController.text.isNotEmpty) {
        bool formValid = _formKey.currentState!.validate();
        if (formIsValid != formValid) {
          formIsValid = formValid;
          if (mounted) {
            setState(() {});
          }
        }
      } else {
        if (formIsValid) {
          formIsValid = false;
          if (mounted) {
            setState(() {});
          }
        }
      }
    });
  }

  /* 
  Purpose: This method is used to get the details from the digilocker
  */

  getDigiLockerDetails(url) async {
    var uri = Uri.parse(url ?? "");
    Map queryParameters = uri.queryParameters;
    String digiId = queryParameters["digi_id"] ?? "";
    String error = queryParameters["error"] ?? "";
    String errorDescription = queryParameters["error_description"] ?? "";

    if (error == "null") {
      this.digiId = digiId;
      verifyFlag = "reDirectUrl";
      setState(() {});
      checkPanDetails();
    } else {
      showSnackbar(context, errorDescription, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepWidget(
        endPoint: route.panCard,
        step: 1,
        title: "PAN & Address",
        subTitle: "PAN card is necessary to open Demat account in India",
        buttonText: "Verify",
        scrollController: scrollController,
        buttonFunc: () async {
          if (!verifyButtonClicked) {
            verifyButtonClicked = true;

            setState(() {});
            await Future.delayed(Duration(milliseconds: 100));
          }

          if (!(_formKey.currentState!.validate() &&
              ((errorCode.contains("DOB")) ? dob.value != null : true))) {
            return;
          }
          checkPanDetails();
        },
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...(errorCode.contains("NAME") || nameFlag == "Y")
                    ? customFormField(
                        labelText: "Name as per PAN card",
                        formValidateNodifier: formValidateNodifier,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                          LengthLimitingTextInputFormatter(100),
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]'))
                        ],
                        controller: nameController,
                        onChange: checkFormValidOrNot,
                        validator: verifyButtonClicked &&
                                errorCode.contains("NAME")
                            ? (value) =>
                                validateName(value, "Name as per PAN card", 3)
                            : (value) => nullValidation(value),
                      )
                    : [],
                const SizedBox(height: 15.0),
                ...customFormField(
                    readOnly: verifyFlag == "KRAVERIFY" ? false : true,
                    formValidateNodifier: formValidateNodifier,
                    controller: panNumberController,
                    labelText: "PAN Number",
                    helperText:
                        errorCode == "DOBFLAG" ? null : "Example:ABCDE1234A",
                    textIsGrey: verifyFlag != "KRAVERIFY",
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      UpperCaseTextFormatter(),
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    ],
                    onChange: checkFormValidOrNot,
                    validator: (value) => validatePanCard(value),
                    suffixIcon: verifyFlag != "KRAVERIFY"
                        ? InkWell(
                            onTap: () {
                              digiId = "";
                              verifyFlag = "KRAVERIFY";
                              errorCode = "";
                              panNumberController.clear();
                              nameController.clear();
                              dob.value = null;
                              setState(() {});
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          )
                        : Text("")),
                Visibility(
                    visible: errorCode == "DOBFLAG",
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        RichText(
                            text: TextSpan(children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                          WidgetSpan(
                              child: SizedBox(
                            width: 5,
                          )),
                          TextSpan(
                              text:
                                  "PAN Verified in KRA, please enter DOB to proceed",
                              style: TextStyle(color: Colors.green))
                        ])),
                      ],
                    )),
                const SizedBox(height: 20.0),
                (errorCode.contains("DOB") || errorCode.contains("DOBFLAG"))
                    ? const Text("Date of Birth as per PAN card*")
                    : Text(""),
                const SizedBox(height: 5.0),
                Visibility(
                    visible: (errorCode.contains("DOB") ||
                        errorCode.contains("DOBFLAG") ||
                        errorCode.contains("NAMEDOB")),
                    child: CustomDateFormField(
                      errorText: verifyButtonClicked &&
                              errorCode.contains("DOB") &&
                              dob.value == null
                          ? "DOB is required"
                          : null,
                      formValidateNodifier: formValidateNodifier,
                      date: dob,
                      onChange: checkFormValidOrNot,
                    )),
                const SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset("assets/images/Vector.svg", width: 15.0),
                    const SizedBox(width: 3.0),
                    const Text(
                      "Your information is safe with us!",
                      style: TextStyle(color: Color.fromRGBO(0, 232, 218, 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          )
        ]);
  }

  showBottomSheet(String name, context1, Map response) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 40.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 60.0,
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(237, 249, 254, 1),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: name.isNotEmpty
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              name.isNotEmpty
                                  ? Text(
                                      "Hi, $name",
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Color.fromRGBO(0, 192, 100, 1),
                                          fontWeight: FontWeight.w600),
                                    )
                                  : SizedBox(),
                              const SizedBox(height: 20.0),
                              response["panxmlpanno"] != null &&
                                      response["panxmlpanno"].isNotEmpty
                                  ? RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text:
                                                "You have entered an incorrect PAN ",
                                            style:
                                                TextStyle(color: Colors.black)),
                                        TextSpan(
                                            text: response["pan"],
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                            text:
                                                ", We have retrieved your correct PAN ",
                                            style:
                                                TextStyle(color: Colors.black)),
                                        TextSpan(
                                            text: response["panxmlpanno"],
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                            text: " from the Digilocker.",
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ]))
                                  : Text(
                                      "Using your PAN details we securely fetched your details from the Income Tax Department"),
                              const SizedBox(height: 20.0),
                              RichText(
                                  text: TextSpan(children: [
                                const WidgetSpan(child: Text("Not you? ")),
                                WidgetSpan(
                                  child: InkWell(
                                    child: Text(
                                      're enter PAN',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                    onTap: () {
                                      verifyFlag = "KRAVERIFY";
                                      nameController.clear();
                                      formIsValid = false;
                                      verifyButtonClicked = false;
                                      dob.value = null;
                                      errorCode = "";
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                  ),
                                )
                              ]))
                            ])
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Text("Record (PAN not found in KRA Database)",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Color.fromRGBO(98, 100, 103, 1),
                                      fontWeight: FontWeight.w600)),
                            ]),
                ),
              ),
              const SizedBox(height: 20.0),
              CustomButton(buttonFunc: () async {
                var res =
                    await insertPanDetails(json: response, context: context);
                if (res["status"] == "S") {
                  getNextRoute(context1);
                }
              })
            ],
          ),
        );
      },
    );
  }

  errorBottomSheet(String name, String html, context1) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 40.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 60.0,
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(237, 249, 254, 1),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20.0),
                          HtmlWidget(html),
                          const SizedBox(height: 20.0),
                        ])),
              ),
              const SizedBox(height: 20.0),
              CustomButton(
                  buttonText: errorCode == "NAME"
                      ? "Re-enter Name"
                      : errorCode == "DOB"
                          ? "Re-enter Date of Birth"
                          : errorCode == "NAMEDOB"
                              ? "Re-enter Name & DOB"
                              : "Re-enter PAN",
                  buttonFunc: () => Navigator.pop(context))
            ],
          ),
        );
      },
    );
  }
}
