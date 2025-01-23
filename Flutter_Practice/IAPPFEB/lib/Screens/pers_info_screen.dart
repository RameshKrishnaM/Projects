// import '../Route/route.dart' as route;
// import 'package:ekyc/screen/pers_verify_screen.dart';
import 'dart:convert';

import 'package:ekyc/Custom%20Widgets/CustomDropDOwn.dart';
import 'package:ekyc/Custom%20Widgets/custom_snackBar.dart';
import 'package:ekyc/Custom%20Widgets/scrollable_widget.dart';
import 'package:ekyc/Model/get_pers_info_model.dart';
import 'package:ekyc/Nodifier/nodifierCLass.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../API call/api_call.dart';
import '../Custom Widgets/StepWidget.dart';
import '../Custom Widgets/custom_button.dart';
import '../Custom Widgets/custom_drop_down.dart';
import '../Custom Widgets/custom_form_field.dart';
import '../Custom Widgets/custom_radio_tile.dart';
import '../Custom Widgets/risk_diskclosure_alertbox.dart';
import '../Route/route.dart' as route;
import '../Service/validate_func.dart';

class PersInfoScreen extends StatefulWidget {
  const PersInfoScreen({super.key});

  @override
  State<PersInfoScreen> createState() => _PersInfoScreenState();
}

class _PersInfoScreenState extends State<PersInfoScreen> {
  bool isFormValidation = false;
  var formKey = GlobalKey<FormState>();
  FormValidateNodifier formValidateNodifier = FormValidateNodifier({
    "Marital Status": false,
    "Gender": false,
    "Phone number belongs to": false,
    "Mail id belongs to": false,
    "Annual income": false,
    "Trading Experience": false,
    "Occupation": false,
    "Education qualification": false
  });

  PersonalStruct? persDetailStruc;

  ///Dropdown controller:

  TextEditingController maritalDropDownController = TextEditingController();
  TextEditingController genderDropDownController = TextEditingController();
  TextEditingController phoneDropDownController = TextEditingController();
  TextEditingController emailDropDownController = TextEditingController();

  TextEditingController annIncDropDownController = TextEditingController();
  TextEditingController tradingExpDropDownController = TextEditingController();
  TextEditingController occuDropDownController = TextEditingController();
  TextEditingController educationDropDownController = TextEditingController();
  TextEditingController fatcareasonDropDownController = TextEditingController();

  ///TextField controller:

  TextEditingController momNameController = TextEditingController();
  TextEditingController momNameTitleController = TextEditingController();
  TextEditingController dadNameController = TextEditingController();
  TextEditingController dadNameTitleController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController emailBelongsController = TextEditingController();
  TextEditingController phoneBelongsController = TextEditingController();
  TextEditingController postActionController = TextEditingController();
  TextEditingController subBrokerController = TextEditingController();
  // TextEditingController residenceCountry = TextEditingController();
  TextEditingController taxNoController = TextEditingController();
  TextEditingController cityOfBirthController = TextEditingController();
  TextEditingController countryOfBirthController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController fatcacountrycontroller = TextEditingController();

  String politicallyRadio = "N";
  String addNomineeRadio = "N";
  String postAction = "N";
  String subBroker = "N";
  String fatcaDeclaration = "N";
  String oldnominee = "N";
  String fatcaTaxExemptRadio = "N";
  bool occuBool = false;
  bool educationBool = false;
  bool emailBelongBool = false;
  bool phoneBelongBool = false;
  bool isLoadingPersDetails = true;
  bool isEditPersDetails = false;
  RegExp? regexp;
  String Format = "";

  List occuDropDownData = [];

  List fatcareasondropdown = [];
  List fatcacountrydropdown = [];
  List nameTitleDropDownData = [];
  List maritalDropDownData = [];
  List genderDropDownData = [];
  List educationDropDownData = [];
  List belongsDropDownData = [];
  List traExpDropDownData = [];
  List annIncDropDownData = [];

  List occuDescList = [];
  List fatcacountryList = [];
  List fatcareasonList = [];
  List nameTitleDescList = [];
  List maritalDescList = [];
  List genderDescList = [];
  List educationDescList = [];
  List phoneBelongsOwnerDescList = [];
  List emailBelongsOwnerDescList = [];
  List annualIncomeDescList = [];
  List tradingExpDescList = [];
  String defaultOwner = "";
  String occupationOthers = "";
  String educationOthers = "";
  String soa = "";

  bool countinueButtonIsTriggered = false;

  ScrollController scrollController = ScrollController();
  Map getPersonalDetailsMap = {};

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMaritalDropDownDetails();
    });
    persDetailStruc = PersonalStruct(
        fatcaTaxExempt: "",
        fatcaTaxExemptReason: "",
        fatherNameTitle: "",
        motherNameTitle: "",
        fatherName: "",
        motherName: "",
        annualIncome: "",
        tradingExperience: "",
        occupation: "",
        gender: "",
        emailOwner: "",
        phoneOwner: "",
        politicalExpo: "",
        maritalStatus: "",
        education: "",
        nomineeOpted: "",
        emailOwnerName: "",
        educationOthers: "",
        occOthers: "",
        phoneOwnerName: "",
        soa: "",
        dealSubBroker: "",
        dealSubBrokerDesc: "",
        pastActions: "",
        pastActionsDesc: "",
        emailId: "",
        phoneNumber: "",
        countryofBirth: "",
        fatcaDeclaration: "",
        foreignAddress1: "",
        foreignAddress2: "",
        foreignAddress3: "",
        foreignCity: "",
        foreignCountry: "",
        foreignPincode: "",
        foreignState: "",
        placeofBirth: "",
        residenceCountry: "",
        taxIdendificationNumber: "");
    /*  persDetailStruc = PersonalStruct(
        maritalStatus: "902",
        gender: "112",
        emailOwner: "121",
        phoneOwner: "121",
        fatherName: "rg",
        motherName: "sdg",
        annualIncome: "501",
        tradingExperience: "601",
        occupation: "701",
        politicalExpo: "N",
        education: "801",
        nomineeOpted: "Yes"); */
    super.initState();
  }

  getpattern() async {
    String code = fatcacountryList.firstWhere((element) =>
        element["description"] == fatcacountrycontroller.text)["code"];
    print("code----$code");
    var res = await GetTinValidateData(
        json: {"countrycode": code, "code": "FatcaTinValidation"},
        context: context);
    print("patternnn----${res}");
    regexp = RegExp(res["pattern"]);
    Format = res["formatvalue"];
    print("format----$Format");
    if (mounted) {
      setState(() {});
    }
  }

  formvalidate(value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (maritalDropDownController.text.isNotEmpty &&
          genderDropDownController.text.isNotEmpty &&
          phoneDropDownController.text.isNotEmpty &&
          emailDropDownController.text.isNotEmpty &&
          annIncDropDownController.text.isNotEmpty &&
          tradingExpDropDownController.text.isNotEmpty &&
          occuDropDownController.text.isNotEmpty &&
          educationDropDownController.text.isNotEmpty &&
          dadNameTitleController.text.isNotEmpty &&
          dadNameController.text.isNotEmpty &&
          momNameTitleController.text.isNotEmpty &&
          momNameController.text.isNotEmpty) {
        if (((educationDropDownController.text == educationOthers &&
                    educationController.text.isNotEmpty) ||
                educationDropDownController.text != educationOthers) &&
            ((occuDropDownController.text == occupationOthers &&
                    occupationController.text.isNotEmpty) ||
                occuDropDownController.text != occupationOthers) &&
            ((emailDropDownController.text != defaultOwner &&
                    emailBelongsController.text.isNotEmpty) ||
                emailDropDownController.text == defaultOwner) &&
            ((phoneDropDownController.text != defaultOwner &&
                    phoneBelongsController.text.isNotEmpty) ||
                phoneDropDownController.text == defaultOwner)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // isFormValidation = formKey.currentState!.validate();
            setState(() {});
          });
        } else {
          isFormValidation = false;
        }
      } else {
        isFormValidation = false;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StepWidget(
      endPoint: route.persInfo,
      step: 2,
      title: "Personal Information",
      subTitle: "A bit of personal information about you",
      scrollController: scrollController,
      notShowBackButton: !soa.toLowerCase().contains("manual"),
      buttonFunc:
          //  !isFormValidation
          //     ? null
          //     :
          () async {
        if (!countinueButtonIsTriggered) {
          countinueButtonIsTriggered = true;
          setState(() {});
        }
        if (!(formKey.currentState!.validate() &&
            maritalDropDownController.text.isNotEmpty &&
            genderDropDownController.text.isNotEmpty &&
            phoneDropDownController.text.isNotEmpty &&
            emailDropDownController.text.isNotEmpty &&
            dadNameTitleController.text.isNotEmpty &&
            momNameTitleController.text.isNotEmpty &&
            annIncDropDownController.text.isNotEmpty &&
            tradingExpDropDownController.text.isNotEmpty &&
            (fatcaDeclaration == "N" ||
                fatcaTaxExemptRadio == "N" ||
                fatcareasonDropDownController.text.isNotEmpty) &&
            occuDropDownController.text.isNotEmpty &&
            educationDropDownController.text.isNotEmpty)) {
          return;
        }
        politicallyRadio == "Y" ? getHtmlData() : insertPersInfo();
      },
      children: [
        Form(
          key: formKey,
          child: Column(
            children: [
              // ...getTitleANdSubTitleWidget("Personal Information",
              //     "A bit of personal information about you", context),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Personal Details",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                  color: const Color.fromRGBO(102, 98, 98, 1),
                                  fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text("Marital Status*"),
                  const SizedBox(height: 10.0),
                  CustomDropDown(
                    label: "Marital Status",
                    showError: countinueButtonIsTriggered &&
                        maritalDropDownController.text.isEmpty,
                    controller: maritalDropDownController,
                    values: maritalDescList,
                    formValidateNodifier: formValidateNodifier,
                    isIcon: true,
                    hint: "Marital Status",
                    onChange: formvalidate,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text("Gender*"),
                  const SizedBox(height: 10.0),
                  CustomDropDown(
                    label: "Gender",
                    showError: countinueButtonIsTriggered &&
                        genderDropDownController.text.isEmpty,
                    controller: genderDropDownController,
                    values: genderDescList,
                    formValidateNodifier: formValidateNodifier,
                    isIcon: true,
                    hint: "Gender",
                    onChange: formvalidate,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: "Phone number belongs to",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color)),
                    TextSpan(
                        text: getPersonalDetailsMap["phoneNumber"] == null ||
                                getPersonalDetailsMap["phoneNumber"]
                                    .toString()
                                    .isEmpty
                            ? ""
                            : " (${getPersonalDetailsMap["phoneNumber"]})",
                        style: const TextStyle(color: Colors.green)),
                    TextSpan(
                        text: "*",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color))
                  ])),
                  // const Text("Phone number belongs to me*"),
                  const SizedBox(height: 10.0),
                  CustomDropDown(
                    label:
                        "Phone number belongs to${getPersonalDetailsMap["phoneNumber"] == null || getPersonalDetailsMap["phoneNumber"].toString().isEmpty ? "" : " (${getPersonalDetailsMap["phoneNumber"]})"}",
                    showError: countinueButtonIsTriggered &&
                        phoneDropDownController.text.isEmpty,
                    controller: phoneDropDownController,
                    values: phoneBelongsOwnerDescList,
                    formValidateNodifier: formValidateNodifier,
                    isIcon: true,
                    hint:
                        "Phone number belongs to${getPersonalDetailsMap["phoneNumber"] == null || getPersonalDetailsMap["phoneNumber"].toString().isEmpty ? "" : " (${getPersonalDetailsMap["phoneNumber"]})"}",
                    onChange: (phoneBelongsValue) {
                      phoneBelongsValue == defaultOwner
                          ? phoneBelongBool = false
                          : phoneBelongBool = true;
                      phoneBelongsValue == defaultOwner
                          ? phoneBelongsController.text = ""
                          : null;
                      formvalidate(phoneBelongsValue);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    },
                  ),
                  Visibility(
                      visible: phoneDropDownController.text != defaultOwner,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            ...customFormField(
                                controller: phoneBelongsController,
                                labelText:
                                    "${phoneDropDownController.text} Name",
                                onChange: formvalidate,
                                validator: (value) => validateName(value,
                                    "${phoneDropDownController.text} Name", 3)),
                          ])),
                  const SizedBox(
                    height: 20.0,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: "Mail ID belongs to",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color)),
                    TextSpan(
                        text: getPersonalDetailsMap["emailId"] == null ||
                                getPersonalDetailsMap["emailId"]
                                    .toString()
                                    .isEmpty
                            ? ""
                            : " (${getPersonalDetailsMap["emailId"]})",
                        style: TextStyle(color: Colors.green)),
                    TextSpan(
                        text: "*",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color))
                  ])),
                  // const Text("Mail ID belongs to me*"),
                  const SizedBox(height: 10.0),
                  CustomDropDown(
                    label:
                        "Mail ID belongs to${getPersonalDetailsMap["emailId"] == null || getPersonalDetailsMap["emailId"].toString().isEmpty ? "" : " (${getPersonalDetailsMap["emailId"]})"}",
                    showError: countinueButtonIsTriggered &&
                        emailDropDownController.text.isEmpty,
                    controller: emailDropDownController,
                    values: emailBelongsOwnerDescList,
                    formValidateNodifier: formValidateNodifier,
                    isIcon: true,
                    hint:
                        "Mail ID belongs to${getPersonalDetailsMap["emailId"] == null || getPersonalDetailsMap["emailId"].toString().isEmpty ? "" : " (${getPersonalDetailsMap["emailId"]})"}",
                    onChange: (emailBelongsValue) {
                      emailBelongsValue == defaultOwner
                          ? emailBelongBool = false
                          : emailBelongBool = true;
                      emailBelongsValue == defaultOwner
                          ? emailBelongsController.text = ""
                          : null;
                      formvalidate(emailBelongsValue);
                      // setState(() {})
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    },
                  ),
                  Visibility(
                      visible: emailDropDownController.text != defaultOwner,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            ...customFormField(
                                controller: emailBelongsController,
                                labelText:
                                    "${emailDropDownController.text} Name",
                                onChange: formvalidate,
                                validator: (value) => validateName(value,
                                    "${emailDropDownController.text} Name", 3)),
                          ])),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Parents",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                  color: const Color.fromRGBO(102, 98, 98, 1),
                                  fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text("Father's / Spouse Name*"),
                  const SizedBox(height: 5.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80.0,
                        child: CustomDropDown(
                          showError: countinueButtonIsTriggered &&
                              dadNameTitleController.text.isEmpty,
                          controller: dadNameTitleController,
                          values: nameTitleDescList,
                          formValidateNodifier: formValidateNodifier,
                          isIcon: true,
                          hint: "",
                          onChange: (emailBelongsValue) {
                            formvalidate(emailBelongsValue);
                            // setState(() {})
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {});
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: CustomFormField(
                            // formValidateNodifier: formValidateNodifier,
                            controller: dadNameController,
                            labelText: "Father's or Spouse Name",
                            hintText: "Father's or Spouse Name",
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z\s]')),
                            ],
                            validator: (value) =>
                                validateName(value, "Father's Name", 3)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text("Mother's Name*"),
                  const SizedBox(height: 5.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80.0,
                        child: CustomDropDown(
                          showError: countinueButtonIsTriggered &&
                              momNameTitleController.text.isEmpty,
                          controller: momNameTitleController,
                          values: nameTitleDescList
                              .where((element) => element != "Mr")
                              .toList(),
                          formValidateNodifier: formValidateNodifier,
                          isIcon: true,
                          hint: "",
                          onChange: (emailBelongsValue) {
                            formvalidate(emailBelongsValue);
                            // setState(() {})
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {});
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: CustomFormField(
                            // formValidateNodifier: formValidateNodifier,
                            controller: momNameController,
                            labelText: "Mother's Name",
                            hintText: "Mother's Name",
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z\s]')),
                            ],
                            validator: (value) =>
                                validateName(value, "Mother's Name", 3)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Background",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                  color: const Color.fromRGBO(102, 98, 98, 1),
                                  fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text("Annual Income*"),
                  const SizedBox(height: 10.0),
                  CustomDropDown(
                    label: "Annual Income",
                    showError: countinueButtonIsTriggered &&
                        annIncDropDownController.text.isEmpty,
                    controller: annIncDropDownController,
                    values: annualIncomeDescList,
                    formValidateNodifier: formValidateNodifier,
                    isIcon: true,
                    hint: "Annual Income",
                    onChange: formvalidate,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text("Trading Experience*"),
                  const SizedBox(height: 10.0),
                  CustomDropDown(
                    label: "Trading Experience",
                    showError: countinueButtonIsTriggered &&
                        tradingExpDropDownController.text.isEmpty,
                    controller: tradingExpDropDownController,
                    values: tradingExpDescList,
                    formValidateNodifier: formValidateNodifier,
                    isIcon: true,
                    hint: "Trading Experience",
                    onChange: formvalidate,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text("Occupation*"),
                  const SizedBox(height: 10.0),
                  CustomDropDown(
                    label: "Occupation",
                    showError: countinueButtonIsTriggered &&
                        occuDropDownController.text.isEmpty,
                    controller: occuDropDownController,
                    values: occuDescList,
                    formValidateNodifier: formValidateNodifier,
                    isIcon: true,
                    hint: "Occupation",
                    onChange: (occuValue) {
                      occuValue == occupationOthers
                          ? occuBool = true
                          : occuBool = false;
                      occuValue == occupationOthers
                          ? occupationController.text = ""
                          : null;
                      formvalidate(occuValue);
                      // setState(() {});
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    },
                  ),
                  Visibility(
                      visible: occuDropDownController.text == occupationOthers,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            ...customFormField(
                                controller: occupationController,
                                labelText: "Occupation Others",
                                onChange: formvalidate,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(75)
                                ],
                                validator: (value) => validateName(
                                    value, "Occupation Others", 3)),
                          ])),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text("Education qualification*"),
                  const SizedBox(height: 10.0),
                  CustomDropDown(
                    label: "Education qualification",
                    showError: countinueButtonIsTriggered &&
                        educationDropDownController.text.isEmpty,
                    controller: educationDropDownController,
                    values: educationDescList,
                    formValidateNodifier: formValidateNodifier,
                    isIcon: true,
                    hint: "Education qualification",
                    onChange: (eduValue) {
                      eduValue == educationOthers
                          ? educationBool = true
                          : educationBool = false;
                      eduValue == educationOthers
                          ? educationController.text = ""
                          : null;
                      formvalidate(eduValue);
                      // setState(() {});
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    },
                  ),
                  Visibility(
                      visible:
                          educationDropDownController.text == educationOthers,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            ...customFormField(
                                controller: educationController,
                                labelText: "Education Qualification Others",
                                onChange: formvalidate,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(75)
                                ],
                                validator: (value) => validateName(value,
                                    "Education Qualification Others", 3)),
                          ])),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Text("Are you a politically exposed person?",
                      // textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomRadioTile(
                        label: 'Yes',
                        value: "Y",
                        groupValue: politicallyRadio,
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              politicallyRadio = value!;
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      CustomRadioTile(
                        label: 'No',
                        value: "N",
                        groupValue: politicallyRadio,
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              politicallyRadio = value!;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text("Do you wish to add nominee?",
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomRadioTile(
                        label: 'Yes',
                        value: "Y",
                        groupValue: addNomineeRadio,
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              addNomineeRadio = value!;
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      CustomRadioTile(
                        label: 'No',
                        value: "N",
                        groupValue: addNomineeRadio,
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              addNomineeRadio = value!;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Past Actions",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                  color: const Color.fromRGBO(102, 98, 98, 1),
                                  fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                      "Details of any action / proceeding initiated / pending / taken by SEBI / Stock Exchange / any other authority against the applicant / constituentor its partners / Promoters / Whole time directors / Authorized persons in-charge of dealing in securities during the last 3 years. ",
                      textAlign: TextAlign.justify,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomRadioTile(
                        label: 'Yes',
                        value: "Y",
                        groupValue: postAction,
                        onChanged: (value) {
                          formvalidate("");
                          if (mounted) {
                            setState(() {
                              postAction = value!;
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      CustomRadioTile(
                        label: 'No',
                        value: "N",
                        groupValue: postAction,
                        onChanged: (value) {
                          formvalidate("");
                          if (mounted) {
                            setState(() {
                              postAction = value!;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Visibility(
                      visible: postAction == "Y",
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            ...customFormField(
                                controller: postActionController,
                                labelText: "Past Action Details",
                                onChange: formvalidate,
                                validator: (value) => validateName(
                                    value, "Past Action Details", 1)),
                          ])),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text("Dealings with sub broker and other stock brokers",
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomRadioTile(
                        label: 'Yes',
                        value: "Y",
                        groupValue: subBroker,
                        onChanged: (value) {
                          formvalidate("");
                          if (mounted) {
                            setState(() {
                              subBroker = value!;
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      CustomRadioTile(
                        label: 'No',
                        value: "N",
                        groupValue: subBroker,
                        onChanged: (value) {
                          if (mounted) {
                            formvalidate("");
                            setState(() {
                              subBroker = value!;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Visibility(
                      visible: subBroker == "Y",
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...customFormField(
                                controller: subBrokerController,
                                labelText: "Broker/Sub broker Name",
                                onChange: formvalidate,
                                validator: (value) => validateName(
                                    value, "Broker/Sub broker Name", 1)),
                            const SizedBox(
                              height: 20.0,
                            ),
                          ])),
                  Text("Are you a Tax paying citizen in other country?",
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomRadioTile(
                        label: 'Yes',
                        value: "Y",
                        groupValue: fatcaDeclaration,
                        onChanged: (value) {
                          formvalidate("");
                          if (mounted) {
                            setState(() {
                              fatcaDeclaration = value!;
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      CustomRadioTile(
                        label: 'No',
                        value: "N",
                        groupValue: fatcaDeclaration,
                        onChanged: (value) {
                          if (mounted) {
                            formvalidate("");
                            setState(() {
                              fatcaDeclaration = value!;
                              // if (value == "N") {
                              //   fatcaTaxExemptRadio = "N";
                              //   countryController.clear();
                              //   fatcareasonDropDownController.clear();
                              //   fatcacountrycontroller.clear();
                              //   taxNoController.clear();
                              //   cityOfBirthController.clear();
                              //   countryOfBirthController.clear();
                              //   address1Controller.clear();
                              //   address2Controller.clear();
                              //   cityController.clear();
                              //   stateController.clear();
                              //   countryController.clear();
                              //   pincodeController.clear();
                              // }
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  Visibility(
                      visible: fatcaDeclaration == "Y",
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            Text("Tax Exempt?",
                                // textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Row(
                              children: [
                                CustomRadioTile(
                                    label: "Yes",
                                    value: "Y",
                                    groupValue: fatcaTaxExemptRadio,
                                    onChanged: (value) {
                                      if (mounted) {
                                        formvalidate("");
                                        setState(() {
                                          fatcaTaxExemptRadio = value!;
                                        });
                                        if (countinueButtonIsTriggered) {
                                          formKey.currentState!.validate();
                                        }
                                      }
                                    }),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                CustomRadioTile(
                                    label: "No",
                                    value: "N",
                                    groupValue: fatcaTaxExemptRadio,
                                    onChanged: (value) {
                                      if (mounted) {
                                        formvalidate("");
                                        setState(() {
                                          fatcaTaxExemptRadio = value!;
                                          fatcareasonDropDownController.clear();
                                        });
                                        if (countinueButtonIsTriggered) {
                                          formKey.currentState!.validate();
                                        }
                                      }
                                    })
                              ],
                            ),
                            Visibility(
                              visible: fatcaTaxExemptRadio == "Y",
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  const Text("Tax Exempt Reason*"),
                                  const SizedBox(height: 10.0),
                                  CustomDropDown(
                                    label: "Tax Exempt Reason",
                                    showError: countinueButtonIsTriggered &&
                                        fatcareasonDropDownController
                                            .text.isEmpty,
                                    controller: fatcareasonDropDownController,
                                    values: fatcareasondropdown,
                                    formValidateNodifier: formValidateNodifier,
                                    isIcon: true,
                                    hint: "",
                                    onChange: formvalidate,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            // ...customFormField(
                            //   controller: residenceCountry,
                            //   labelText: "Country of Jurisdiction of Residence",
                            //   onChange: formvalidate,
                            //   // validator: (value) => validateName(value,
                            //   //     "Country of Jurisdiction of Residence", 1)
                            // ),
                            const Text("Country of Jurisdiction of Residence*"),
                            const SizedBox(height: 10.0),
                            CustomSearchDropDown(
                              iscountry: true,
                              autoValidate: true,
                              hintText: "",
                              labelText: "Country of Jurisdiction of Residence",
                              list: fatcacountrydropdown,
                              isIcon: true,
                              onChange: (value) async {
                                formvalidate("");
                                getpattern();
                              },
                              controller: fatcacountrycontroller,
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            ...customFormField(
                              validator: (value) {
                                if (fatcaTaxExemptRadio == "Y") {
                                  return null;
                                }
                                if (value == null || value == "") {
                                  return "TIN is required";
                                } else if (value.length > 18) {
                                  return "Please enter valid TIN";
                                } else if (regexp != null) {
                                  if (!regexp!.hasMatch(value)) {
                                    return "TIN must follow the format: $Format";
                                  }
                                }
                              },
                              controller: taxNoController,
                              labelText:
                                  "Tax Idendification Number or Equivalent(If issued by jurisdiction)",
                              onChange: formvalidate,
                              // validator: (value) => validateName(value,
                              //     "Country of Jurisdiction of Residence", 1)
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            ...customFormField(
                                controller: cityOfBirthController,
                                labelText: "Place/City of Birth",
                                onChange: formvalidate,
                                validator: (value) => validateName(
                                    value, "Place/City of Birth", 3)),
                            const SizedBox(
                              height: 20.0,
                            ),
                            // ...customFormField(
                            //     controller: countryOfBirthController,
                            //     labelText: "Country of Birth",
                            //     onChange: formvalidate,
                            //     validator: (value) =>
                            //         validateName(value, "Country of Birth", 3)),
                            const Text("Country of Birth"),
                            const SizedBox(height: 10.0),
                            CustomSearchDropDown(
                              iscountry: true,
                              autoValidate: true,
                              hintText: "",
                              labelText: "Country of Birth",
                              list: fatcacountrydropdown,
                              isIcon: true,
                              onChange: formvalidate,
                              controller: countryOfBirthController,
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            ...customFormField(
                                controller: address1Controller,
                                labelText: "Address 1",
                                onChange: formvalidate,
                                validator: (value) =>
                                    validateName(value, "Address 1", 5)),
                            const SizedBox(
                              height: 20.0,
                            ),
                            ...customFormField(
                                controller: address2Controller,
                                labelText: "Address 2",
                                onChange: formvalidate,
                                validator: (value) =>
                                    validateName(value, "Address 2", 3)),
                            const SizedBox(
                              height: 20.0,
                            ),
                            ...customFormField(
                                controller: cityController,
                                labelText: "City",
                                onChange: formvalidate,
                                validator: (value) =>
                                    validateName(value, "City", 3)),
                            const SizedBox(
                              height: 20.0,
                            ),
                            ...customFormField(
                                controller: stateController,
                                labelText: "State",
                                onChange: formvalidate,
                                validator: (value) =>
                                    validateName(value, "State", 3)),
                            const SizedBox(
                              height: 20.0,
                            ),
                            // ...customFormField(
                            //     controller: countryController,
                            //     labelText: "Country",
                            //     onChange: formvalidate,
                            //     validator: (value) =>
                            //         validateName(value, "Country", 3)),
                            const Text("Country"),
                            const SizedBox(height: 10.0),
                            CustomSearchDropDown(
                              iscountry: true,
                              autoValidate: true,
                              hintText: "",
                              labelText: "Country",
                              list: fatcacountrydropdown,
                              isIcon: true,
                              onChange: formvalidate,
                              controller: countryController,
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            ...customFormField(
                                controller: pincodeController,
                                labelText: "Postal / Zip Code",
                                onChange: formvalidate,
                                validator: (value) => validateAddresss(
                                    value, "Postal / Zip Code", 1, 15)),
                          ])),
                ],
              ),
            ],
          ),
        ),

        // RichText(
        //     textAlign: TextAlign.center,
        //     text: TextSpan(
        //       children: [
        //         TextSpan(
        //             text:
        //                 "I confirm that I have read and understood the following ",
        //             // textAlign: TextAlign.center,
        //             style: Theme.of(context).textTheme.bodyMedium),
        //         TextSpan(
        //           text: "terms and condition",
        //           style: Theme.of(context)
        //               .textTheme
        //               .bodyMedium!
        //               .copyWith(
        //                   color: const Color.fromRGBO(
        //                       50, 169, 220, 1)),
        //           recognizer: TapGestureRecognizer()
        //             ..onTap = () => Navigator.pushNamed(
        //                     context, route.esignHtml, arguments: {
        //                   "url": "https://flattrade.in/terms"
        //                 }),
        //         )
        //       ],
        //     )),
        // Text(
        //     "I confirm that I have read and understood the following terms and condition",
        //     textAlign: TextAlign.center,
        //     style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  openPermissionAlertBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
              "As of now, We are not opening accounts for politically exposed person Clients"),
          actions: [
            SizedBox(
              height: 30.0,
              child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll(0),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6))),
                  ),
                  onPressed: () async {
                    SystemNavigator.pop();
                  },
                  child: const Text("Ok")),
            ),
          ],
        );
      },
    );
  }

  /*      var response = await addPersInfo(json: {
      "maritalStatus": maritalDropDownData.firstWhere((element) =>
          element["description"] == maritalDropDownController.text)["code"],
      "gender": genderDropDownData.firstWhere((element) =>
          element["description"] == genderDropDownController.text)["code"],
      "emailOwner": belongsDropDownData.firstWhere((element) =>
          element["description"] == emailDropDownController.text)["code"],
      "phoneOwner": belongsDropDownData.firstWhere((element) =>
          element["description"] == phoneDropDownController.text)["code"],
      "fatherName": dadNameController.text,
      "motherName": momNameController.text,
      "annualIncome": annIncDropDownData.firstWhere((element) =>
          element["description"] == annIncDropDownController.text)["code"],
      "tradingExperience": traExpDropDownData.firstWhere((element) =>
          element["description"] == tradingExpDropDownController.text)["code"],
      "occupation": occuDropDownData.firstWhere((element) =>
          element["description"] == occuDropDownController.text)["code"],
      "politicalExpo": "N",
      "education": educationDropDownData.firstWhere((element) =>
          element["description"] == educationDropDownController.text)["code"],
      "nomineeOpted": addNomineeRadio.substring(0, 1)
    }); */

  Map htmlData = {};
  getHtmlData() async {
    loadingAlertBox(context);
    var response = await getDishClosureData(
        context: context, contentType: "Politically Exposed Person");
    Navigator.pop(context);
    if (response != null) {
      htmlData = response["riskDisclosure"];
      // Navigator.pushNamed(context, route.esignHtml,
      //     arguments: {"html": response["content"]});
      // con1
      //   // ..setJavaScriptMode(JavaScriptMode.unrestricted)
      //   ..loadHtmlString(response["content"])
      //   ..enableZoom(true);
      showTerms(
          context: context,
          htmlData: htmlData,
          func: () {
            politicallyRadio = "N";
            setState(() {});
          });
      // contentid
      // contenttype
    }
  }

  insertPersInfo() async {
    loadingAlertBox(context);
    Map addPersonalDetailsJson = {
      "maritalstatus": maritalDropDownData.firstWhere((element) =>
          element["description"] == maritalDropDownController.text)["code"],
      "gender": genderDropDownData.firstWhere((element) =>
          element["description"] == genderDropDownController.text)["code"],
      "emailowner": belongsDropDownData.firstWhere((element) =>
          element["description"] == emailDropDownController.text)["code"],
      "phoneowner": belongsDropDownData.firstWhere((element) =>
          element["description"] == phoneDropDownController.text)["code"],
      "fathertitle": nameTitleDropDownData.firstWhere((element) =>
          element["description"] == dadNameTitleController.text)["code"],
      "fathername": dadNameController.text,
      "mothertitle": nameTitleDropDownData.firstWhere((element) =>
          element["description"] == momNameTitleController.text)["code"],
      "mothername": momNameController.text,
      "annualincome": annIncDropDownData.firstWhere((element) =>
          element["description"] == annIncDropDownController.text)["code"],
      "tradingexperience": traExpDropDownData.firstWhere((element) =>
          element["description"] == tradingExpDropDownController.text)["code"],
      "occupation": occuDropDownData.firstWhere((element) =>
          element["description"] == occuDropDownController.text)["code"],
      "politicalexpo": politicallyRadio,
      "education": educationDropDownData.firstWhere((element) =>
          element["description"] == educationDropDownController.text)["code"],
      "nomineeopted": addNomineeRadio.substring(0, 1),
      "occupationothers": occupationController.text,
      "emailownername": emailBelongsController.text,
      "phoneownername": phoneBelongsController.text,
      "educationothers": educationController.text,
      "pastActions": postAction,
      "dealSubBroker": subBroker,
      "pastActionsDesc": postAction == "N" ? "" : postActionController.text,
      "dealSubBrokerDesc": subBroker == "N" ? "" : subBrokerController.text,
      "fatcaDeclaration": fatcaDeclaration,
      // "residenceCountry": fatcaDeclaration == "N" ? "" : residenceCountry.text,
      "residenceCountry": fatcaDeclaration == "N"
          ? ""
          : fatcacountryList.firstWhere((element) =>
              element["description"] == fatcacountrycontroller.text)["code"],
      "taxIdendificationNumber":
          fatcaDeclaration == "N" ? "" : taxNoController.text,
      "placeofBirth": fatcaDeclaration == "N" ? "" : cityOfBirthController.text,
      "countryofBirth": fatcaDeclaration == "N"
          ? ""
          : fatcacountryList.firstWhere((element) =>
              element["description"] == countryOfBirthController.text)["code"],
      "foreignAddress1": fatcaDeclaration == "N" ? "" : address1Controller.text,
      "foreignAddress2": fatcaDeclaration == "N" ? "" : address2Controller.text,
      "foreignCity": fatcaDeclaration == "N" ? "" : cityController.text,
      "foreignCountry": fatcaDeclaration == "N"
          ? ""
          : fatcacountryList.firstWhere((element) =>
              element["description"] == countryController.text)["code"],
      "foreignState": fatcaDeclaration == "N" ? "" : stateController.text,
      "foreignPincode": fatcaDeclaration == "N" ? "" : pincodeController.text,
      "fatcaTaxExempt": fatcaDeclaration == "N" ? "" : fatcaTaxExemptRadio,
      "fatcaTaxExemptReason":
          fatcaDeclaration == "N" || fatcaTaxExemptRadio == "N"
              ? ""
              : fatcareasonList.firstWhere((element) =>
                  element["description"] ==
                  fatcareasonDropDownController.text)["code"],
    };
    print(
        "insert reason------ ${addPersonalDetailsJson["fatcaTaxExemptReason"]}");
    var response = jsonIsModified(getPersonalDetailsMap, addPersonalDetailsJson)
        ? await addPersInfo(context: context, json: addPersonalDetailsJson)
        : '';
    Postmap provider = Provider.of<Postmap>(context, listen: false);
    (provider.isEditPage && oldnominee == "N" && addNomineeRadio == "Y")
        ? Navigator.pushNamed(context, route.nominee)
        : response != null
            ? getNextRoute(context)
            : mounted
                ? Navigator.pop(context)
                : null;
  }

  getNextRoute(context) async {
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.persInfo],
      "routeraction": "Next"
    });

    if (mounted) {
      Navigator.pop(context);
    }

    if (response != null) {
      Navigator.pushNamed(context, response["endpoint"]);
    }
  }

  fetchMaritalDropDownDetails() async {
    loadingAlertBox(context);
    var response =
        await getDropDownValues(context: context, code: "MarritalStatus");
    // print(response);
    if (response != null) {
      maritalDropDownData = response["lookupvaluearr"];
      maritalDescList =
          maritalDropDownData.map((e) => e["description"]).toList();
      // print(maritalDescList);
      // print("${maritalDescList}");
      if (mounted) {
        setState(() {});
      }
    } else {
      // if (mounted) {
      //   Navigator.pop(context);
      // }
    }
    fetchOccuDropDown();
  }

  fetchOccuDropDown() async {
    var response =
        await getDropDownValues(context: context, code: "Occupation");
    if (response != null) {
      occuDropDownData = response["lookupvaluearr"];
      occuDescList = occuDropDownData.map((e) => e["description"]).toList();

      occupationOthers = occuDropDownData.firstWhere(
          (element) => element["code"] == "711",
          orElse: () => {"description": " "})["description"];
      if (mounted) {
        setState(() {});
      }
    } else {
      // if (mounted) {
      //   Navigator.pop(context);
      // }
    }

    fetchGenderDropDown();
  }

  fetchGenderDropDown() async {
    var response = await getDropDownValues(context: context, code: "Gender");
    if (response != null) {
      genderDropDownData = response["lookupvaluearr"] ?? [];
      genderDescList = genderDropDownData.map((e) => e["description"]).toList();
      if (mounted) {
        setState(() {});
      }
      // print(genderDescList);
    } else {
      // if (mounted) {
      //   Navigator.pop(context);
      // }
    }
    fetchNameTitleDropDown();
  }

  fetchNameTitleDropDown() async {
    var response =
        await getDropDownValues(context: context, code: "client title");
    if (response != null) {
      nameTitleDropDownData = response["lookupvaluearr"] ?? [];
      nameTitleDescList =
          nameTitleDropDownData.map((e) => e["description"]).toList();

      if (mounted) {
        setState(() {});
      }
      // print(genderDescList);
    } else {
      // if (mounted) {
      //   // Navigator.pop(context);
      // }
    }
    fetchEducationDropDown();
  }

  fetchEducationDropDown() async {
    var response = await getDropDownValues(context: context, code: "Eduaction");
    if (response != null) {
      educationDropDownData = response["lookupvaluearr"] ?? [];
      educationDescList =
          educationDropDownData.map((e) => e["description"]).toList();
      educationOthers = educationDropDownData.firstWhere(
          (element) => element["code"] == "808",
          orElse: () => {"description": " "})["description"];
      if (mounted) {
        setState(() {});
      }
      // print(educationDescList);
    } else {
      // if (mounted) {
      //   Navigator.pop(context);
      // }
    }
    fetchphEmailBelongsDropDown();
  }

  fetchphEmailBelongsDropDown() async {
    var response =
        await getDropDownValues(context: context, code: "MobileEmailOwner");

    if (response != null) {
      belongsDropDownData = response["lookupvaluearr"] ?? [];

      phoneBelongsOwnerDescList =
          belongsDropDownData.map((e) => e["description"]).toList();
      emailBelongsOwnerDescList =
          belongsDropDownData.map((e) => e["description"]).toList();
      int indexOfdefalutOwner =
          belongsDropDownData.indexWhere((element) => element["code"] == "121");
      defaultOwner = indexOfdefalutOwner != -1
          ? belongsDropDownData[indexOfdefalutOwner]["description"]
          : "";
      phoneDropDownController.text = defaultOwner;
      emailDropDownController.text = defaultOwner;
      if (mounted) {
        setState(() {});
      }
      // print(phoneBelongsOwnerDescList);
      // print(emailBelongsOwnerDescList);
    } else {
      // if (mounted) {
      //   Navigator.pop(context);
      // }
    }
    fetchAnnualIncomeDropDown();
  }

  fetchAnnualIncomeDropDown() async {
    var response =
        await getDropDownValues(context: context, code: "annualIncome");
    if (response != null) {
      annIncDropDownData = response["lookupvaluearr"] ?? [];
      annualIncomeDescList =
          annIncDropDownData.map((e) => e["description"]).toList();
      if (mounted) {
        setState(() {});
      }
      // print(annualIncomeDescList);
    } else {
      // if (mounted) {
      //   Navigator.pop(context);
      // }
    }
    fetchtradingExpDropDown();
  }

  fetchtradingExpDropDown() async {
    var response =
        await getDropDownValues(context: context, code: "TradingExp");
    if (response != null) {
      traExpDropDownData = response["lookupvaluearr"] ?? [];
      tradingExpDescList =
          traExpDropDownData.map((e) => e["description"]).toList();
      if (mounted) {
        setState(() {});
      }
      // print(tradingExpDescList);
    } else {
      // if (mounted) {
      //   Navigator.pop(context);
      // }
    }
    fetchFatcareason();
  }

  fetchFatcareason() async {
    var response =
        await getDropDownValues(context: context, code: "FatcaExemptReason");
    if (response != null) {
      fatcareasonList = response["lookupvaluearr"] ?? [];
      fatcareasondropdown =
          fatcareasonList.map((e) => e["description"]).toList();

      if (mounted) {
        setState(() {});
      }
      // print(genderDescList);
    } else {
      // if (mounted) {
      //   // Navigator.pop(context);
      // }
    }

    fetchfatcacountrycode();
  }

  fetchfatcacountrycode() async {
    var response =
        await getDropDownValues(context: context, code: "FatcaCountry");
    if (response != null) {
      fatcacountryList = response["lookupvaluearr"] ?? [];
      fatcacountrydropdown =
          fatcacountryList.map((e) => e["description"]).toList();

      if (mounted) {
        setState(() {});
      }
      // print(genderDescList);
    } else {
      // if (mounted) {
      //   // Navigator.pop(context);
      // }
    }
    fetchPersonalDetails();
  }

  fetchPersonalDetails() async {
    var response = await fetchPersonalDetailFromApi(context);
    getPersonalDetailsMap =
        response == null ? {} : response["personalStruct"] ?? {};
    // print(jsonEncode(getPersonalDetailsMap));
    // phoneDropDownController.text = "Self";
    // emailDropDownController.text = "Self";
    if (response != null) {
      GetPersonalDetailsModel? getPersonalDetailsModel =
          getPersonalDetailsModelFromJson(jsonEncode(response));
      persDetailStruc = getPersonalDetailsModel.personalStruct;
      dadNameController.text = persDetailStruc!.fatherName;
      dadNameTitleController.text = nameTitleDropDownData.firstWhere(
        (element) => element["code"] == persDetailStruc!.fatherNameTitle,
        orElse: () => {"description": ""},
      )["description"];
      maritalDropDownController.text = maritalDropDownData.firstWhere(
        (element) => element["code"] == persDetailStruc!.maritalStatus,
        orElse: () => {"description": ""},
      )["description"];
      soa = persDetailStruc?.soa ?? "";
      addNomineeRadio = persDetailStruc!.nomineeOpted.trim().isEmpty
          ? "N"
          : persDetailStruc!.nomineeOpted;
      oldnominee = persDetailStruc!.nomineeOpted.trim().isEmpty
          ? "N"
          : persDetailStruc!.nomineeOpted;
      fatcaTaxExemptRadio = persDetailStruc!.fatcaTaxExempt.trim().isEmpty
          ? "N"
          : persDetailStruc!.fatcaTaxExempt;
      if (persDetailStruc!.gender.isNotEmpty) {
        genderDropDownController.text = genderDropDownData.firstWhere(
          (element) => element["code"] == persDetailStruc!.gender,
          orElse: () => {"description": ""},
        )["description"];
      }
      if (persDetailStruc!.fatcaTaxExempt == "Y") {
        fatcareasonDropDownController.text = fatcareasonList.firstWhere(
          (element) => element["code"] == persDetailStruc!.fatcaTaxExemptReason,
          orElse: () => {"description": ""},
        )["description"];
      }
      // persDetailStruc!.occupation != null &&
      if (persDetailStruc!.occupation.isNotEmpty) {
        //     isEditPersDetails = true;
        occuDropDownController.text = occuDropDownData.firstWhere(
          (element) => element["code"] == persDetailStruc!.occupation,
          orElse: () => {"description": ""},
        )["description"];
        annIncDropDownController.text = annIncDropDownData.firstWhere(
          (element) => element["code"] == persDetailStruc!.annualIncome,
          orElse: () => {"description": ""},
        )["description"];
        // maritalDropDownController.text = maritalDropDownData.firstWhere(
        //   (element) => element["code"] == persDetailStruc!.maritalStatus,
        //   orElse: () => {"description": ""},
        // )["description"];
        educationDropDownController.text = educationDropDownData.firstWhere(
          (element) => element["code"] == persDetailStruc!.education,
          orElse: () => {"description": ""},
        )["description"];
        emailDropDownController.text = belongsDropDownData.firstWhere(
          (element) => element["code"] == persDetailStruc!.emailOwner,
          orElse: () => {"description": ""},
        )["description"];
        phoneDropDownController.text = belongsDropDownData.firstWhere(
          (element) => element["code"] == persDetailStruc!.phoneOwner,
          orElse: () => {"description": ""},
        )["description"];
        tradingExpDropDownController.text = traExpDropDownData.firstWhere(
          (element) => element["code"] == persDetailStruc!.tradingExperience,
          orElse: () => {"description": ""},
        )["description"];

        politicallyRadio = persDetailStruc!.politicalExpo;
        addNomineeRadio = persDetailStruc!.nomineeOpted;
        postAction = persDetailStruc!.pastActions;
        subBroker = persDetailStruc!.dealSubBroker;
        postActionController.text = persDetailStruc!.pastActionsDesc;
        subBrokerController.text = persDetailStruc!.dealSubBrokerDesc;
        // dadNameTitleController.text = nameTitleDropDownData.firstWhere(
        //   (element) => element["code"] == persDetailStruc!.fatherNameTitle,
        //   orElse: () => {"description": ""},
        // )["description"];
        momNameTitleController.text = nameTitleDropDownData.firstWhere(
          (element) => element["code"] == persDetailStruc!.motherNameTitle,
          orElse: () => {"description": ""},
        )["description"];
        fatcacountrycontroller.text = fatcacountryList.firstWhere(
          (element) => element["code"] == persDetailStruc!.residenceCountry,
          orElse: () => {"description": ""},
        )["description"];
        ;
        soa = persDetailStruc!.soa;
        // dadNameController.text = persDetailStruc!.fatherName;
        momNameController.text = persDetailStruc!.motherName;
        educationController.text = persDetailStruc!.educationOthers;
        occupationController.text = persDetailStruc!.occOthers;
        emailBelongsController.text = persDetailStruc!.emailOwnerName;
        phoneBelongsController.text = persDetailStruc!.phoneOwnerName;
        fatcaDeclaration = persDetailStruc!.fatcaDeclaration;
        taxNoController.text = persDetailStruc!.taxIdendificationNumber;
        cityOfBirthController.text = persDetailStruc!.placeofBirth;
        countryOfBirthController.text = fatcacountryList.firstWhere(
          (element) => element["code"] == persDetailStruc!.countryofBirth,
          orElse: () => {"description": ""},
        )["description"];
        address1Controller.text = persDetailStruc!.foreignAddress1;
        address2Controller.text = persDetailStruc!.foreignAddress2;
        cityController.text = persDetailStruc!.foreignCity;
        stateController.text = persDetailStruc!.foreignState;
        countryController.text = fatcacountryList.firstWhere(
          (element) => element["code"] == persDetailStruc!.foreignCountry,
          orElse: () => {"description": ""},
        )["description"];
        pincodeController.text = persDetailStruc!.foreignPincode;
        formvalidate("");
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }

    isLoadingPersDetails = false;
    if (mounted) {
      setState(() {});
    }
  }
}
