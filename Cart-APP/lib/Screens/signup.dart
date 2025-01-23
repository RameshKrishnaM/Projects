import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/custom_button.dart';
import 'package:ekyc/Custom%20Widgets/custom_form_field.dart';
import 'package:ekyc/Custom%20Widgets/customdropdown.dart';
import 'package:ekyc/Custom%20Widgets/terms_text.dart';
import 'package:ekyc/Service/validate_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../Cookies/cookies.dart';
import '../Custom Widgets/custom_check_box.dart';
import '../Custom Widgets/login_page_widget.dart';
import '../Route/route.dart' as route;
import '../provider/provider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  List states = [];
  String stateCode = "";
  bool buttonIsLoading = false;
  bool isCheck = false;
  bool showReq = false;
  var _formKey = GlobalKey<FormState>();
  bool formIsValid = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getStateName();
    });
    super.initState();
  }

  checkCookie() async {
    if (await CustomHttpClient.verifyCookies() == true) {
      Navigator.pushNamed(context, route.address);
    } else {
      getStateName();
    }
  }

  /* 
  Purpose: This method is used to get the state name from the api 
  */

  getStateName() async {
    loadingAlertBox(context);
    var json = await getDropDownValues(context: context, code: "state");
    if (json != null) {
      states = json['lookupvaluearr'];
      if (mounted) {
        setState(() {});
      }
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  /* 
  Purpose: This method is used to genarate the Otp Mobile from the api
  */

  generateMobileOtp() async {
    loadingAlertBox(context);
    var json = await otpCallAPI(json: {
      "clientname": nameController.text.trim(),
      "sendto": mobileNumberController.text,
      "sendtotype": "phone"
    }, context: context);

    if (json != null) {
      Provider.of<ProviderClass>(context, listen: false)
          .changeMobileNo(mobileNumberController.text.trim());
      if (mounted) {
        Navigator.pop(context);
      }
      Navigator.pushNamed(context, route.mobileOTP, arguments: {
        "tempUid": json["tempUid"],
        "encrypteval": json["encryptedval"],
        "insertedid": json["validateid"],
        "name": nameController.text.trim(),
        "mobileNo": mobileNumberController.text,
        "state": states.firstWhere(
            (element) => element["description"] == stateController.text)["code"]
      }).then((value) {
        if (value == true) {
          Navigator.pushReplacementNamed(context, route.signup);
        }
      });
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
    buttonIsLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  /* 
  Purpose: This method is used to check the form validate or not
  */
// nameController.text.isNotEmpty &&
  checkFormValidOrNot(value) {
    if (mobileNumberController.text.isNotEmpty &&
        stateController.text.isNotEmpty &&
        isCheck) {
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
  }

  @override
  Widget build(BuildContext context) {
    return LoginPageWidget(
      isSignIn: true,
      title: "",
      subTitle: "",
      children: [
        Form(
            key: _formKey,
            onChanged: () => checkFormValidOrNot(""),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Sign Up",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                // const SizedBox(
                //   height: 20.0,
                // ),
                // CustomFormField(
                //     labelText: "Name",
                //     hintText: "Name",
                //     filled: true,
                //     inputFormatters: [
                //       UpperCaseTextFormatter(),
                //       LengthLimitingTextInputFormatter(100),
                //       FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                //     ],
                //     controller: nameController,
                //     onChange: checkFormValidOrNot,
                //     validator: (value) => validateName(value, "Name", 3)),
                const SizedBox(
                  height: 20.0,
                ),
                CustomFormField(
                    labelText: "Mobile Number",
                    hintText: "Mobile number",
                    filled: true,
                    controller: mobileNumberController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    keyboardType: TextInputType.phone,
                    validator: mobileNumberValidation,
                    onChange: checkFormValidOrNot),
                const SizedBox(
                  height: 20.0,
                ),
                CustomSearchDropDown(
                  filled: true,
                  controller: stateController,
                  autoValidate: showReq,
                  list: states.isEmpty
                      ? []
                      : states.map((state) => state["description"]).toList()
                    ..sort(),
                  labelText: "",
                  hintText: "State",
                  isIcon: true,
                  onChange: checkFormValidOrNot,
                ),
              ],
            )),
        const SizedBox(
          height: 10.0,
        ),
        const Expanded(flex: 4, child: SizedBox()),
        CustomCheckBox(
            isCheck: isCheck,
            showReq: showReq,
            onChange: () {
              isCheck = !isCheck;
              showReq = isCheck ? false : true;
              checkFormValidOrNot(isCheck);
              setState(() {});
            },
            child: TermsText()),
        const SizedBox(
          height: 10.0,
        ),
        CustomButton(
            buttonText: "Send OTP",
            buttonFunc: () {
              if (!showReq) {
                showReq = true;
                setState(() {});
              }
              if (_formKey.currentState!.validate() && isCheck) {
                generateMobileOtp();
              }
            }),
        const Expanded(child: SizedBox()),
        const SizedBox(height: 20.0)
      ],
    );
  }
}

loadingAlertBox(context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              )),
        ),
      );
    },
  );
}
