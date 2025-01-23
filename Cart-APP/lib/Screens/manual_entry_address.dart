import 'dart:io';

import 'package:ekyc/API%20call/api_call.dart';
import 'package:ekyc/Custom%20Widgets/file_upload_bottomsheet.dart';
import 'package:ekyc/Custom%20Widgets/custom_form_field.dart';
import 'package:ekyc/Custom%20Widgets/stepwidget.dart';
import 'package:ekyc/Custom%20Widgets/custom_drop_down.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../Nodifier/nodifierclass.dart';
import '../Service/validate_func.dart';
import '../Route/route.dart' as route;

class AddressManualEntry extends StatefulWidget {
  final Map? address;
  const AddressManualEntry({super.key, this.address});

  @override
  State<AddressManualEntry> createState() => _AddressManualEntryState();
}

class _AddressManualEntryState extends State<AddressManualEntry> {
  DateChange dateChange = DateChange();
  String selectedFilePath = '';

  TextEditingController addressLine1Controller = TextEditingController();
  TextEditingController addressLine2Controller = TextEditingController();
  TextEditingController addressLine3Controller = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController residentialAddressLine1Controller =
      TextEditingController();
  TextEditingController residentialAddressLine2Controller =
      TextEditingController();
  TextEditingController residentialAddressLine3Controller =
      TextEditingController();
  TextEditingController residentialPinCodeController = TextEditingController();
  TextEditingController residentialCityController = TextEditingController();
  TextEditingController residentialStateController = TextEditingController();
  TextEditingController residentialCountryController = TextEditingController();
  TextEditingController perProofNumberController = TextEditingController();
  TextEditingController perDateOfIssueController = TextEditingController();
  TextEditingController perPlaceOfIssueController = TextEditingController();
  TextEditingController perAddressProofFrontPageController =
      TextEditingController();
  TextEditingController perAddressProofBackPageController =
      TextEditingController();

  TextEditingController perProofType = TextEditingController();
  TextEditingController perPoiExpireDateController = TextEditingController();
  DateTime? perPoiExpireDate;
  DateTime? perProofIssueDate;

  TextEditingController corProofType = TextEditingController();
  TextEditingController corDateOfIssueController = TextEditingController();
  TextEditingController corProofNumberController = TextEditingController();
  TextEditingController corPlaceOfIssueController = TextEditingController();
  TextEditingController corPoiExpireDateController = TextEditingController();
  TextEditingController corAddressProofFrontPageController =
      TextEditingController();
  TextEditingController corAddressProofBackPageController =
      TextEditingController();
  DateTime? corPoiExpireDate;
  DateTime? corProofIssueDate;
  List? corAddressFrontPageFileDetails;
  List? corAddressBackPageFileDetails;
  String corProofCode = "";
  bool residentailAddressSameAsPermentAddress = false;
  String? selectedItem;
  final _formKey = GlobalKey<FormState>();
  List proofTypes = [];
  bool formIsValid = false;
  String perDocid1 = "";
  String perDocid2 = "";
  String corDocid1 = "";
  String corDocid2 = "";
  List<File?> perFiles = [null, null];
  List<File?> corFiles = [null, null];
  List ids = [null, null, null, null];
  List keys = [null, null, null, null];
  List? perAddressFrontPageFileDetails;
  List? perAddressBackPageFileDetails;

  ScrollController scrollController = ScrollController();
  bool formValidationIsTriggered = false;
  bool perAadhaarValidation = true;
  bool corAadhaarValidation = true;
  bool perIssueDateIsManitory = false;
  bool corIssueDateIsManitory = false;
  String perProofCode = "";
  bool perShowBackPageAddress = false;
  bool corShowBackPageAddress = false;
  bool countinueButtonIsTriggered = false;

  /* 
  Purpose: This method is used to check all the forms are valid or not
  */

  checkFormValidation(value) {
    if (addressLine1Controller.text.isNotEmpty &&
        addressLine2Controller.text.isNotEmpty &&
        pinCodeController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        stateController.text.isNotEmpty &&
        countryController.text.isNotEmpty &&
        (residentailAddressSameAsPermentAddress ||
            (residentialAddressLine1Controller.text.isNotEmpty &&
                residentialAddressLine2Controller.text.isNotEmpty &&
                residentialPinCodeController.text.isNotEmpty &&
                residentialCityController.text.isNotEmpty &&
                residentialStateController.text.isNotEmpty &&
                residentialCountryController.text.isNotEmpty)) &&
        ((!perIssueDateIsManitory) ||
            (perDateOfIssueController.text.isNotEmpty &&
                perPlaceOfIssueController.text.isNotEmpty)) &&
        perProofType.text.isNotEmpty &&
        perAddressProofFrontPageController.text.isNotEmpty &&
        (!(["01", "02", "06", "07"].contains(perProofCode)) ||
            perAddressProofBackPageController.text.isNotEmpty)) {
      formValidationIsTriggered = true;
    } else {
      if (formValidationIsTriggered) {
        _formKey.currentState!.validate();
      }
      formIsValid = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  /* 
  Purpose: This method is used to get address ProofType dropdown values from the api
  */

  getAdressProofType() async {
    loadingAlertBox(context);

    var json = await getDropDownValues(context: context, code: "AddressProof");
    if (mounted) {
      Navigator.pop(context);
    }
    if (json != null) {
      proofTypes = json['lookupvaluearr']
          .where((element) => element["code"] != "12")
          .toList();
      if (mounted) {
        setState(() {});
      }
    }
  }

  /* 
  Purpose: This method is used to get address from the Address Screen
  */

  getInitialData() async {
    await getAdressProofType();
    if (widget.address != null) {
      residentialAddressLine1Controller.text =
          widget.address!["coradrs1"] ?? "";
      residentialAddressLine2Controller.text =
          widget.address!["coradrs2"] ?? "";
      residentialAddressLine3Controller.text =
          widget.address!["coradrs3"] ?? "";
      residentialCityController.text = widget.address!["corcity"] ?? "";
      residentialPinCodeController.text = widget.address!["corpincode"] ?? "";
      residentialStateController.text = widget.address!["corstate"] ?? "";
      residentialCountryController.text = widget.address!["corcountry"] ?? "";
      addressLine1Controller.text = widget.address!["peradrs1"] ?? "";
      addressLine2Controller.text = widget.address!["peradrs2"] ?? "";
      addressLine3Controller.text = widget.address!["peradrs3"] ?? "";
      cityController.text = widget.address!["percity"] ?? "";
      pinCodeController.text = widget.address!["perpincode"] ?? "";
      stateController.text = widget.address!["perstate"] ?? "";
      countryController.text = widget.address!["percountry"] ?? "";
      residentailAddressSameAsPermentAddress =
          widget.address!["aspermenantaddr"] == null ||
                  widget.address!["aspermenantaddr"] == ""
              ? false
              : widget.address!["aspermenantaddr"];

      String soa = widget.address!["soa"] ?? "";
      if (soa.toLowerCase().contains("manual")) {
        perProofType.text = widget.address!["peradrsproofcode"] == null ||
                widget.address!["peradrsproofcode"].isEmpty ||
                !soa.toLowerCase().contains("manual")
            ? ""
            : proofTypes.firstWhere((element) =>
                element["code"] ==
                widget.address!["peradrsproofcode"])["description"];
        perProofCode = widget.address!["peradrsproofcode"];
        perDateOfIssueController.text =
            widget.address!["peradrsproofisudate"] ?? "";
        perProofNumberController.text = widget.address!["peradrsproofno"] ?? "";
        perPlaceOfIssueController.text =
            widget.address!["peradrsproofplaceisu"] ?? "";
        perPoiExpireDateController.text =
            widget.address!["perproofexpirydate"] ?? "";

        corProofType.text = widget.address!["coradrsproofcode"] == null ||
                widget.address!["coradrsproofcode"].isEmpty ||
                !soa.toLowerCase().contains("manual")
            ? ""
            : proofTypes.firstWhere((element) =>
                element["code"] ==
                widget.address!["coradrsproofcode"])["description"];
        corProofCode = widget.address!["coradrsproofcode"] ?? "";
        corDateOfIssueController.text =
            widget.address!["coradrsproofisudate"] ?? "";
        corProofNumberController.text = widget.address!["coradrsproofno"] ?? "";
        corPlaceOfIssueController.text =
            widget.address!["coradrsproofplaceisu"] ?? "";
        corPoiExpireDateController.text =
            widget.address!["corproofexpirydate"] ?? "";
        ids[0] = !soa.toLowerCase().contains("manual") ||
                widget.address!["docid1"].toString().isEmpty
            ? null
            : widget.address!["docid1"];

        ids[1] = !soa.toLowerCase().contains("manual") ||
                widget.address!["docid2"].toString().isEmpty
            ? null
            : widget.address!["docid2"];
        ids[2] = !soa.toLowerCase().contains("manual") ||
                widget.address!["cordocid1"].toString().isEmpty
            ? null
            : widget.address!["cordocid1"];

        ids[3] = !soa.toLowerCase().contains("manual") ||
                widget.address!["cordocid2"].toString().isEmpty
            ? null
            : widget.address!["cordocid2"];
        perDocid1 = ids[0] ?? "";
        perDocid2 = ids[1] ?? "";
        corDocid1 = ids[2] ?? "";
        corDocid2 = ids[3] ?? "";
        perAddressProofFrontPageController.text =
            !soa.toLowerCase().contains("manual")
                ? ""
                : widget.address!["perfilename1"] ?? "";
        perAddressProofBackPageController.text =
            !soa.toLowerCase().contains("manual")
                ? ""
                : widget.address!["perfilename2"] ?? "";
        corAddressProofFrontPageController.text =
            !soa.toLowerCase().contains("manual")
                ? ""
                : widget.address!["corfilename1"] ?? "";
        corAddressProofBackPageController.text =
            !soa.toLowerCase().contains("manual")
                ? ""
                : widget.address!["corfilename2"] ?? "";

        try {
          loadingAlertBox(context);
          perAddressFrontPageFileDetails = perDocid1.isNotEmpty
              ? await fetchFile(context: context, id: perDocid1, list: true)
              : null;
          perAddressBackPageFileDetails = perDocid2.isNotEmpty
              ? await fetchFile(context: context, id: perDocid2, list: true)
              : null;
          corAddressFrontPageFileDetails = corDocid1.isNotEmpty
              ? perDocid1 == corDocid1
                  ? perAddressFrontPageFileDetails == null
                      ? null
                      : [...perAddressFrontPageFileDetails!]
                  : await fetchFile(context: context, id: corDocid1, list: true)
              : null;
          corAddressBackPageFileDetails = corDocid2.isNotEmpty
              ? perDocid2 == corDocid2
                  ? perAddressBackPageFileDetails == null
                      ? null
                      : [...perAddressBackPageFileDetails!]
                  : await fetchFile(context: context, id: corDocid2, list: true)
              : null;
        } catch (e) {
        } finally {
          Navigator.pop(context);
        }
        perAddressFrontPageFileDetails != null
            ? perAddressProofFrontPageController.text = "File Uploaded"
            : null;
        perAddressBackPageFileDetails != null
            ? perAddressProofBackPageController.text = "File Uploaded"
            : null;
        corAddressFrontPageFileDetails != null
            ? corAddressProofFrontPageController.text = "File Uploaded"
            : null;
        corAddressBackPageFileDetails != null
            ? corAddressProofBackPageController.text = "File Uploaded"
            : null;
        perShowBackPageAddress =
            ["01", "02", "06", "07"].contains(perProofCode);
        corShowBackPageAddress =
            ["01", "02", "06", "07"].contains(corProofCode);
        perIssueDateIsManitory = ["01", "02"].contains(perProofCode);
        corIssueDateIsManitory = ["01", "02"].contains(corProofCode);
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getInitialData();
    });
    super.initState();
  }

  /* 
  Purpose: This method is used to change the date format
  */

  changeDateFormat(String date) {
    return "${date.substring(8, 10)}/${date.substring(5, 7)}/${date.substring(0, 4)}";
  }

  /* 
  Purpose: This method is used to insert all the details to the DB
  */

  submitForm() async {
    loadingAlertBox(context);

    Map json = {
      "soa": widget.address?["soa"] == null ||
              widget.address!["soa"].toString().isEmpty
          ? "Manual"
          : widget.address!["soa"].toString().toLowerCase().contains("manual")
              ? widget.address!["soa"]
              : "${widget.address!["soa"]}_Manual",
      "coradrs1": residentailAddressSameAsPermentAddress
          ? addressLine1Controller.text
          : residentialAddressLine1Controller.text,
      "coradrs2": residentailAddressSameAsPermentAddress
          ? addressLine2Controller.text
          : residentialAddressLine2Controller.text,
      "coradrs3": residentailAddressSameAsPermentAddress
          ? addressLine3Controller.text
          : residentialAddressLine3Controller.text,
      "corcity": residentailAddressSameAsPermentAddress
          ? cityController.text
          : residentialCityController.text,
      "corpincode": residentailAddressSameAsPermentAddress
          ? pinCodeController.text
          : residentialPinCodeController.text,
      "corstate": residentailAddressSameAsPermentAddress
          ? stateController.text
          : residentialStateController.text,
      "corcountry": residentailAddressSameAsPermentAddress
          ? countryController.text
          : residentialCountryController.text,
      "coradrsproofname": proofTypes.firstWhere(
          (element) => element["description"] == corProofType.text)["code"],
      "coradrsproofno": corProofNumberController.text,
      "coradrsproofplaceisu": corPlaceOfIssueController.text,
      "coradrsproofisudate": corDateOfIssueController.text,
      "corproofexpirydate": corPoiExpireDateController.text,
      "cordocid1": corDocid1,
      "cordocid2": corDocid2,
      "peradrs1": addressLine1Controller.text,
      "peradrs2": addressLine2Controller.text,
      "peradrs3": addressLine3Controller.text,
      "percity": cityController.text,
      "perpincode": pinCodeController.text,
      "perstate": stateController.text,
      "percountry": countryController.text,
      "peradrsproofname": proofTypes.firstWhere(
          (element) => element["description"] == perProofType.text)["code"],
      "peradrsproofcode": proofTypes.firstWhere(
          (element) => element["description"] == perProofType.text)["code"],
      "peradrsproofisudate": perDateOfIssueController.text,
      "peradrsproofno": perProofNumberController.text,
      "peradrsproofplaceisu": perPlaceOfIssueController.text,
      "perproofexpirydate": perPoiExpireDateController.text,
      "perdocid1": perDocid1,
      "perdocid2": perDocid2,
      "aspermenantaddr": residentailAddressSameAsPermentAddress
    };

    var response1 = jsonIsModified(widget.address ?? {}, json)
        ? await postManualEntryDetailAPI(context: context, json: json)
        : "";
    response1 != null
        ? getNextRoute(context)
        : mounted
            ? Navigator.pop(context)
            : null;
  }

  /* 
  Purpose: This method is used to get the next route name from the Api
  */

  getNextRoute(context) async {
    var response = await getRouteNameInAPI(context: context, data: {
      "routername": route.routeNames[route.address],
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
  Purpose: This method is used to change the res Address as Permenent Address when the check box is clicked
  */

  residentailAddressChangeToSameAsPermentAddress() {
    if (!residentailAddressSameAsPermentAddress) return;
    residentialAddressLine1Controller.text = addressLine1Controller.text;
    residentialAddressLine2Controller.text = addressLine2Controller.text;
    residentialAddressLine3Controller.text = addressLine3Controller.text;
    residentialPinCodeController.text = pinCodeController.text;
    residentialCityController.text = cityController.text;
    residentialStateController.text = stateController.text;
    residentialCountryController.text = countryController.text;
    corProofType.text = perProofType.text;
    corProofCode = perProofCode;
    corProofNumberController.text = perProofNumberController.text;
    corIssueDateIsManitory = perIssueDateIsManitory;
    corProofIssueDate = perProofIssueDate;
    corPoiExpireDate = perPoiExpireDate;
    corDateOfIssueController.text = perDateOfIssueController.text;
    corPoiExpireDateController.text = perPoiExpireDateController.text;
    corPlaceOfIssueController.text = perPlaceOfIssueController.text;
    corAddressFrontPageFileDetails = perAddressFrontPageFileDetails;
    corAddressBackPageFileDetails = perAddressBackPageFileDetails;
    corAddressProofFrontPageController.text =
        perAddressProofFrontPageController.text;
    corAddressProofBackPageController.text =
        perAddressProofBackPageController.text;
    corFiles = perFiles;
    corShowBackPageAddress = perShowBackPageAddress;
    corDocid1 = perDocid1;
    corDocid2 = perDocid2;
    ids[2] = ids[0];
    ids[3] = ids[1];
    keys[2] = keys[0];
    keys[3] = keys[1];
    if (mounted) {
      setState(() {});
    }
  }

  /* 
  Purpose: This method is used to find if the Res address and Permenent address are same and enable the check box
  */

  checkresAddSameAsPerAdd() {
    if (!residentailAddressSameAsPermentAddress) return;
    if (residentialAddressLine1Controller.text == addressLine1Controller.text &&
        residentialAddressLine2Controller.text == addressLine2Controller.text &&
        residentialAddressLine3Controller.text == addressLine3Controller.text &&
        residentialPinCodeController.text == pinCodeController.text &&
        corProofType.text == perProofType.text &&
        corProofNumberController.text == perProofNumberController.text &&
        corDateOfIssueController.text == perDateOfIssueController.text &&
        corPoiExpireDateController.text == perPoiExpireDateController.text &&
        corPlaceOfIssueController.text == perPlaceOfIssueController.text &&
        perDocid1 == corDocid1 &&
        perDocid2 == corDocid2) {
      residentailAddressSameAsPermentAddress = true;
    } else {
      residentailAddressSameAsPermentAddress = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    FormValidateNodifier formValidateNodifier = FormValidateNodifier({
      "Full Address": false,
      "Address Line 2": false,
      "Address Line 3": false,
      "Pincode": false,
      "#Full Address": false,
      "#Address Line 2": false,
      "#Address Line 3": false,
      "#Pincode": false,
      "Proof Type": false,
      "Proof Number": false,
      "Date of issue": false,
      "Place of issue": false,
    });
    /* 
  Purpose: This method is used for date picker
  */

    datePick({required func, isExpiryDate = false}) {
      DateTime today = DateTime.now();
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: SizedBox(
              height: 300,
              width: 250.0,
              child: SfDateRangePicker(
                showNavigationArrow: true,
                initialDisplayDate:
                    isExpiryDate ? perPoiExpireDate : perProofIssueDate,
                initialSelectedDate:
                    isExpiryDate ? perPoiExpireDate : perProofIssueDate,
                minDate: isExpiryDate ? today : DateTime(1900),
                maxDate: isExpiryDate ? DateTime(2100) : today,
                onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
                  Navigator.pop(context);
                  func(dateRangePickerSelectionChangedArgs.value);
                },
                selectionMode: DateRangePickerSelectionMode.single,
              ),
            ),
          );
        },
      );
    }

    return StepWidget(
        step: 1,
        title: "PAN & Address",
        title1: "Address Verification",
        subTitle: "Add your address manually  ",
        endPoint: route.address,
        scrollController: scrollController,
        buttonFunc: () {
          if (!countinueButtonIsTriggered) {
            countinueButtonIsTriggered = true;
            setState(() {});
          }
          if (!(_formKey.currentState!.validate() &&
              perProofType.text.isNotEmpty)) {
            return;
          }
          submitForm();
        },
        children: [
          Form(
            key: _formKey,
            onChanged: () => checkFormValidation(""),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Permanent address",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 20.0),
                ...customFormField(
                    formValidateNodifier: formValidateNodifier,
                    controller: addressLine1Controller,
                    labelText: "Address Line 1",
                    onChange: (value) {
                      checkFormValidation(value);
                      residentailAddressChangeToSameAsPermentAddress();
                    },
                    validator: (value) =>
                        validateAddresss(value, "Address Line 1", 5, 50)),
                const SizedBox(height: 10.0),
                ...customFormField(
                    formValidateNodifier: formValidateNodifier,
                    controller: addressLine2Controller,
                    labelText: "Address Line 2",
                    onChange: (value) {
                      checkFormValidation(value);
                      residentailAddressChangeToSameAsPermentAddress();
                    },
                    validator: (value) =>
                        validateAddresss(value, "Address Line 2", 3, 50)),
                const SizedBox(height: 10.0),
                ...customFormField(
                    formValidateNodifier: formValidateNodifier,
                    controller: addressLine3Controller,
                    labelText: "Address Line 3@",
                    validator: (value) =>
                        nullValidationWithMaxLength(value, 50),
                    onChange: (value) {
                      residentailAddressChangeToSameAsPermentAddress();
                    }),
                const SizedBox(height: 10.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...customFormField(
                                formValidateNodifier: formValidateNodifier,
                                controller: pinCodeController,
                                labelText: "Pincode",
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(6),
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.number,
                                validator: validatePinCode,
                                onChange: (value) async {
                                  if (value.length == 6) {
                                    await getpindata(
                                        pincode: pinCodeController.text,
                                        url: 'api/pincode',
                                        permenant: true);
                                    countryController.text = "India";
                                  } else {
                                    cityController.text = "";
                                    stateController.text = "";
                                    countryController.text = "";
                                  }
                                  checkFormValidation(value);
                                  residentailAddressChangeToSameAsPermentAddress();
                                }),
                          ],
                        )),
                    const Expanded(flex: 1, child: SizedBox()),
                    Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: customFormField(
                              formValidateNodifier: formValidateNodifier,
                              readOnly: true,
                              controller: cityController,
                              labelText: "City",
                              onChange: checkFormValidation),
                        )),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: customFormField(
                              formValidateNodifier: formValidateNodifier,
                              readOnly: true,
                              controller: stateController,
                              labelText: "State",
                              onChange: checkFormValidation),
                        )),
                    const Expanded(flex: 1, child: SizedBox()),
                    Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: customFormField(
                              formValidateNodifier: formValidateNodifier,
                              readOnly: true,
                              controller: countryController,
                              labelText: "Country",
                              onChange: checkFormValidation),
                        )),
                  ],
                ),
                const SizedBox(height: 20.0),
                Text(
                  "Proof of Permanent Address",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 10.0),
                Text(
                  "File format should be (*.jpg,*.jpeg,*.png,*.pdf) and file size should be less than 5MB",
                ),
                const SizedBox(height: 10.0),
                const Text("Proof Type*"),
                const SizedBox(height: 5.0),
                CustomDropDown(
                    formValidateNodifier: formValidateNodifier,
                    label: "Proof Type",
                    controller: perProofType,
                    values:
                        proofTypes.map((state) => state["description"]).toList()
                          ..sort(),
                    showError:
                        countinueButtonIsTriggered && perProofType.text.isEmpty,
                    onChange: (value) async {
                      String oldProofCode = perProofCode;
                      perProofCode = proofTypes.firstWhere(
                          (element) => element["description"] == value,
                          orElse: () => {"code": ""})["code"];
                      perShowBackPageAddress =
                          ["01", "02", "06", "07"].contains(perProofCode);

                      if (perProofCode != oldProofCode) {
                        perProofNumberController.text = "";
                        perDateOfIssueController.text = "";
                        perProofIssueDate = null;
                        perPoiExpireDate = null;
                        perPlaceOfIssueController.text = "";
                        perPoiExpireDateController.text = "";
                        perAddressProofFrontPageController.text = "";
                        perAddressProofBackPageController.text = "";
                        perAddressFrontPageFileDetails = null;
                        perAddressBackPageFileDetails = null;
                        perFiles = [null, null];
                        ids = [null, null, ids[2], ids[3]];
                        keys = [null, null, keys[2], keys[3]];
                      }
                      perIssueDateIsManitory =
                          perProofCode == "01" || perProofCode == "02";
                      checkFormValidation(value);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {});
                      });
                      await Future.delayed(Duration(milliseconds: 50));
                      if (countinueButtonIsTriggered) {
                        _formKey.currentState!.validate();
                      }
                      residentailAddressChangeToSameAsPermentAddress();
                    }),
                const SizedBox(height: 10.0),
                if (proofTypes.firstWhere(
                        (element) =>
                            element["description"] == perProofType.text,
                        orElse: () => {"code": "0"})["code"] ==
                    "12") ...[
                  const Text("Proof Number*"),
                  const SizedBox(height: 5.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomFormField(
                          textAlign: TextAlign.center,
                          readOnly: true,
                          controller: TextEditingController(text: "XXXX"),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: CustomFormField(
                          textAlign: TextAlign.center,
                          readOnly: true,
                          controller: TextEditingController(text: "XXXX"),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: CustomFormField(
                          noNeedErrorText: true,
                          textAlign: TextAlign.center,
                          controller: perProofNumberController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4)
                          ],
                          onChange: (value) {
                            perAadhaarValidation = value.length == 4;
                            residentailAddressChangeToSameAsPermentAddress();
                            setState(() {});
                          },
                          validator: (value) {
                            if (value == null || value.length < 4) {
                              return "";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Enter only the last 4 digits of the Aadhaar number",
                    style: TextStyle(
                        color: perAadhaarValidation
                            ? Theme.of(context).textTheme.bodyMedium!.color
                            : Colors.red),
                  ),
                ] else ...[
                  ...customFormField(
                      formValidateNodifier: formValidateNodifier,
                      controller: perProofNumberController,
                      labelText: "Proof Number",
                      onChange: (value) {
                        checkFormValidation(value);
                        residentailAddressChangeToSameAsPermentAddress();
                      },
                      validator: (value) => validateName(
                          value,
                          perProofType.text.isEmpty
                              ? "Proof Number"
                              : perProofType.text,
                          perProofCode == "01"
                              ? 12
                              : perProofCode == "02"
                                  ? 16
                                  : 4),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(perProofCode == "01"
                            ? 12
                            : perProofCode == "02"
                                ? 16
                                : 50),
                      ]),
                ],
                const SizedBox(height: 10.0),
                if (perIssueDateIsManitory) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: customFormField(
                                formValidateNodifier: formValidateNodifier,
                                readOnly: true,
                                controller: perDateOfIssueController,
                                labelText: perIssueDateIsManitory
                                    ? "Date of issue"
                                    : "Date of issue@",
                                onTap: () async {
                                  datePick(func: (DateTime? date) {
                                    if (date != null &&
                                        perProofIssueDate != date) {
                                      perProofIssueDate = date;
                                      perDateOfIssueController.text =
                                          "${date.toString().substring(8, 10)}/${date.toString().substring(5, 7)}/${date.toString().substring(0, 4)}";
                                    }
                                    checkFormValidation("");
                                    residentailAddressChangeToSameAsPermentAddress();
                                    setState(() {});
                                  });
                                },
                                validator: (value) => perIssueDateIsManitory
                                    ? validateNotNull(value, "Date of issue")
                                    : nullValidation(value)),
                          )),
                      const Expanded(flex: 1, child: SizedBox()),
                      Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: customFormField(
                                formValidateNodifier: formValidateNodifier,
                                controller: perPlaceOfIssueController,
                                labelText: perIssueDateIsManitory
                                    ? "Place of issue"
                                    : "Place of issue@",
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z]')),
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                onChange: (value) {
                                  checkFormValidation(value);
                                  residentailAddressChangeToSameAsPermentAddress();
                                },
                                validator: (value) => perIssueDateIsManitory
                                    ? validatePlace(value)
                                    : nullValidation(value)),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: customFormField(
                        formValidateNodifier: formValidateNodifier,
                        readOnly: true,
                        controller: perPoiExpireDateController,
                        labelText: "Expiry Date",
                        onChange: (value) {
                          residentailAddressChangeToSameAsPermentAddress();
                        },
                        onTap: () async {
                          datePick(
                              isExpiryDate: true,
                              func: (DateTime? date) {
                                if (date != null && perPoiExpireDate != date) {
                                  perPoiExpireDate = date;
                                  perPoiExpireDateController.text =
                                      "${date.toString().substring(8, 10)}/${date.toString().substring(5, 7)}/${date.toString().substring(0, 4)}";
                                }
                                checkFormValidation("");
                                residentailAddressChangeToSameAsPermentAddress();
                                setState(() {});
                              });
                        },
                        validator: (value) {
                          return perIssueDateIsManitory
                              ? validateNotNull(value, "Expiry Date")
                              : nullValidation(value);
                        }),
                  ),
                  const SizedBox(height: 10),
                ],
                ...customFormField(
                    formValidateNodifier: formValidateNodifier,
                    labelText: "Address proof front Page",
                    controller: perAddressProofFrontPageController,
                    readOnly: true,
                    hintText: "Upload",
                    onChange: (value) {
                      checkFormValidation(value);
                      residentailAddressChangeToSameAsPermentAddress();
                    },
                    prefixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(width: 10.0),
                      SvgPicture.asset(
                        "assets/images/attachment.svg",
                        width: 22.0,
                      ),
                      const SizedBox(width: 10.0),
                    ]),
                    suffixIcon: perFiles[0] != null ||
                            perAddressFrontPageFileDetails != null
                        ? IconButton(
                            onPressed: () {
                              if (perFiles[0] != null) {
                                Navigator.pushNamed(
                                    context,
                                    perAddressProofFrontPageController.text
                                            .endsWith(".pdf")
                                        ? route.previewPdf
                                        : route.previewImage,
                                    arguments: {
                                      "title": "manualEntryProof1",
                                      "data": perFiles[0]!.readAsBytesSync(),
                                      "fileName":
                                          perAddressProofFrontPageController
                                              .text
                                    });
                              } else {
                                Navigator.pushNamed(
                                    context,
                                    perAddressFrontPageFileDetails![0]
                                            .toString()
                                            .endsWith(".pdf")
                                        ? route.previewPdf
                                        : route.previewImage,
                                    arguments: {
                                      "title": "manualEntryProof1",
                                      "data":
                                          perAddressFrontPageFileDetails![1],
                                      "fileName":
                                          perAddressFrontPageFileDetails![0]
                                    });
                              }
                            },
                            icon: Icon(
                              Icons.preview,
                              color: const Color.fromARGB(255, 99, 97, 97),
                            ))
                        : null,
                    onTap: () {
                      pickFileBottomSheet(
                          context,
                          (path, docId) => pickAddressProof(
                              context, path, docId,
                              isFrontpage: true),
                          "Address",
                          "PER Manual Address Proof 1",
                          pageCount: perShowBackPageAddress ? 1 : null);
                    }),
                Visibility(
                    visible: perShowBackPageAddress,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10.0),
                        ...customFormField(
                          formValidateNodifier: formValidateNodifier,
                          labelText: "Address proof back Page",
                          controller: perAddressProofBackPageController,
                          hintText: "Upload",
                          readOnly: true,
                          onChange: (value) {
                            checkFormValidation(value);
                            residentailAddressChangeToSameAsPermentAddress();
                          },
                          prefixIcon:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            const SizedBox(width: 10.0),
                            SvgPicture.asset(
                              "assets/images/attachment.svg",
                              width: 22.0,
                            ),
                            const SizedBox(width: 10.0),
                          ]),
                          suffixIcon: (perFiles.length > 1 &&
                                      perFiles[1] != null) ||
                                  perAddressBackPageFileDetails != null
                              ? IconButton(
                                  onPressed: () {
                                    if (perFiles[1] != null) {
                                      Navigator.pushNamed(
                                          context,
                                          perAddressProofFrontPageController
                                                  .text
                                                  .endsWith(".pdf")
                                              ? route.previewPdf
                                              : route.previewImage,
                                          arguments: {
                                            "title": "manualEntryProof1",
                                            "data":
                                                perFiles[1]!.readAsBytesSync(),
                                            "fileName":
                                                perAddressProofFrontPageController
                                                    .text
                                          });
                                    } else {
                                      Navigator.pushNamed(
                                          context,
                                          perAddressBackPageFileDetails![0]
                                                  .toString()
                                                  .endsWith(".pdf")
                                              ? route.previewPdf
                                              : route.previewImage,
                                          arguments: {
                                            "title": "manualEntryProof1",
                                            "data":
                                                perAddressBackPageFileDetails![
                                                    1],
                                            "fileName":
                                                perAddressBackPageFileDetails![
                                                    0]
                                          });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.preview,
                                    color:
                                        const Color.fromARGB(255, 99, 97, 97),
                                  ))
                              : null,
                          onTap: () {
                            pickFileBottomSheet(
                                context,
                                (path, docId) =>
                                    pickAddressProof(context, path, docId),
                                "Address",
                                "PER Manual Address Proof 2",
                                pageCount: perShowBackPageAddress ? 1 : null);
                          },
                          validator:
                              perShowBackPageAddress ? null : (value) => null,
                        ),
                      ],
                    )),
                const SizedBox(height: 20.0),
                Text(
                  "Residential Address",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 20.0),
                InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 15.0,
                          width: 15.0,
                          decoration: BoxDecoration(
                              color: residentailAddressSameAsPermentAddress
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              border: Border.all(
                                  width: 1,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!)),
                          child: residentailAddressSameAsPermentAddress
                              ? Icon(Icons.check_sharp,
                                  size: 12, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                            child: const Text(
                                'Residential Address same as permanent address'))
                      ],
                    ),
                    onTap: () {
                      residentailAddressSameAsPermentAddress =
                          !residentailAddressSameAsPermentAddress;
                      checkFormValidation("");
                      residentailAddressChangeToSameAsPermentAddress();
                      if (mounted) {
                        setState(() {});
                      }
                    }),
                const SizedBox(height: 20.0),
                Visibility(
                  visible: true,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...customFormField(
                            formValidateNodifier: formValidateNodifier,
                            controller: residentialAddressLine1Controller,
                            labelText: "Address Line 1",
                            onChange: (value) {
                              checkFormValidation(value);
                              checkresAddSameAsPerAdd();
                            },
                            validator: (value) => validateAddresss(
                                value, "Address Line 1", 5, 50)),
                        const SizedBox(height: 10.0),
                        ...customFormField(
                            formValidateNodifier: formValidateNodifier,
                            controller: residentialAddressLine2Controller,
                            labelText: "Address Line 2",
                            onChange: (value) {
                              checkFormValidation(value);
                              checkresAddSameAsPerAdd();
                            },
                            validator: (value) => validateAddresss(
                                value, "Address Line 2", 3, 50)),
                        const SizedBox(height: 10.0),
                        ...customFormField(
                            formValidateNodifier: formValidateNodifier,
                            controller: residentialAddressLine3Controller,
                            labelText: "Address Line 3@",
                            validator: (value) =>
                                nullValidationWithMaxLength(value, 50),
                            onChange: (value) {
                              checkFormValidation(value);
                              checkresAddSameAsPerAdd();
                            }),
                        const SizedBox(height: 10.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...customFormField(
                                        formValidateNodifier:
                                            formValidateNodifier,
                                        controller:
                                            residentialPinCodeController,
                                        labelText: "Pincode",
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(6),
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        keyboardType: TextInputType.number,
                                        validator: validatePinCode,
                                        onChange: (value) async {
                                          if (value.length == 6) {
                                            await getpindata(
                                                pincode:
                                                    residentialPinCodeController
                                                        .text,
                                                url: 'pincode',
                                                permenant: false);
                                            residentialCountryController.text =
                                                "India";
                                          } else {
                                            residentialCityController.text = "";
                                            residentialStateController.text =
                                                "";
                                            residentialCountryController.text =
                                                "";
                                          }
                                          checkFormValidation(value);
                                          checkresAddSameAsPerAdd();
                                        }),
                                  ],
                                )),
                            const Expanded(flex: 1, child: SizedBox()),
                            Expanded(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: customFormField(
                                      formValidateNodifier:
                                          formValidateNodifier,
                                      readOnly: true,
                                      controller: residentialCityController,
                                      labelText: "City",
                                      onChange: checkFormValidation),
                                )),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: customFormField(
                                      formValidateNodifier:
                                          formValidateNodifier,
                                      readOnly: true,
                                      controller: residentialStateController,
                                      labelText: "State",
                                      onChange: checkFormValidation),
                                )),
                            const Expanded(flex: 1, child: SizedBox()),
                            Expanded(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: customFormField(
                                      formValidateNodifier:
                                          formValidateNodifier,
                                      readOnly: true,
                                      controller: residentialCountryController,
                                      labelText: "Country",
                                      onChange: checkFormValidation),
                                )),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                      ]),
                ),
                Text(
                  "Proof of Residential Address",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 10.0),
                Text(
                  "File format should be (*.jpg,*.jpeg,*.png,*.pdf) and file size should be less than 5MB",
                ),
                const SizedBox(height: 10.0),
                const Text("Proof Type*"),
                const SizedBox(height: 5.0),
                CustomDropDown(
                    formValidateNodifier: formValidateNodifier,
                    label: "Proof Type",
                    controller: corProofType,
                    values:
                        proofTypes.map((state) => state["description"]).toList()
                          ..sort(),
                    showError:
                        countinueButtonIsTriggered && corProofType.text.isEmpty,
                    onChange: (value) async {
                      String oldProofCode = corProofCode;
                      corProofCode = proofTypes.firstWhere(
                          (element) => element["description"] == value,
                          orElse: () => {"code": ""})["code"];
                      corShowBackPageAddress =
                          ["01", "02", "06", "07"].contains(corProofCode);

                      if (corProofCode != oldProofCode) {
                        corProofNumberController.text = "";
                        corDateOfIssueController.text = "";
                        corProofIssueDate = null;
                        corPoiExpireDate = null;
                        corPlaceOfIssueController.text = "";
                        corPoiExpireDateController.text = "";
                        corAddressProofFrontPageController.text = "";
                        corAddressProofBackPageController.text = "";
                        corAddressFrontPageFileDetails = null;
                        corAddressBackPageFileDetails = null;
                        corFiles = [null, null];
                        ids = [ids[0], ids[1], null, null];
                        keys = [keys[0], keys[1], null, null];
                      }
                      corIssueDateIsManitory =
                          corProofCode == "01" || corProofCode == "02";
                      checkFormValidation(value);
                      checkresAddSameAsPerAdd();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {});
                      });
                      await Future.delayed(Duration(milliseconds: 50));
                      if (countinueButtonIsTriggered) {
                        _formKey.currentState!.validate();
                      }
                    }),
                const SizedBox(height: 10.0),
                if (proofTypes.firstWhere(
                        (element) =>
                            element["description"] == corProofType.text,
                        orElse: () => {"code": "0"})["code"] ==
                    "12") ...[
                  const Text("Proof Number*"),
                  const SizedBox(height: 5.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomFormField(
                          textAlign: TextAlign.center,
                          readOnly: true,
                          controller: TextEditingController(text: "XXXX"),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: CustomFormField(
                          textAlign: TextAlign.center,
                          readOnly: true,
                          controller: TextEditingController(text: "XXXX"),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: CustomFormField(
                          noNeedErrorText: true,
                          textAlign: TextAlign.center,
                          controller: corProofNumberController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4)
                          ],
                          onChange: (value) {
                            corAadhaarValidation = value.length == 4;
                            checkresAddSameAsPerAdd();
                            setState(() {});
                          },
                          validator: (value) {
                            if (value == null || value.length < 4) {
                              return "";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Enter only the last 4 digits of the Aadhaar number",
                    style: TextStyle(
                        color: corAadhaarValidation
                            ? Theme.of(context).textTheme.bodyMedium!.color
                            : Colors.red),
                  ),
                ] else ...[
                  ...customFormField(
                      formValidateNodifier: formValidateNodifier,
                      controller: corProofNumberController,
                      labelText: "Proof Number",
                      onChange: (value) {
                        checkFormValidation(value);
                        checkresAddSameAsPerAdd();
                      },
                      validator: (value) => validateName(
                          value,
                          corProofType.text.isEmpty
                              ? "Proof Number"
                              : corProofType.text,
                          corProofCode == "01"
                              ? 12
                              : corProofCode == "02"
                                  ? 16
                                  : 4),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(corProofCode == "01"
                            ? 12
                            : corProofCode == "02"
                                ? 16
                                : 50),
                      ]),
                ],
                const SizedBox(height: 10.0),
                if (corIssueDateIsManitory) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: customFormField(
                                formValidateNodifier: formValidateNodifier,
                                readOnly: true,
                                controller: corDateOfIssueController,
                                labelText: corIssueDateIsManitory
                                    ? "Date of issue"
                                    : "Date of issue@",
                                onTap: () async {
                                  datePick(func: (DateTime? date) {
                                    if (date != null &&
                                        corProofIssueDate != date) {
                                      corProofIssueDate = date;
                                      corDateOfIssueController.text =
                                          "${date.toString().substring(8, 10)}/${date.toString().substring(5, 7)}/${date.toString().substring(0, 4)}";
                                    }
                                    checkFormValidation("");
                                    checkresAddSameAsPerAdd();
                                    setState(() {});
                                  });
                                },
                                onChange: (value) {
                                  checkFormValidation(value);
                                  checkresAddSameAsPerAdd();
                                },
                                validator: (value) => corIssueDateIsManitory
                                    ? validateNotNull(value, "Date of issue")
                                    : nullValidation(value)),
                          )),
                      const Expanded(flex: 1, child: SizedBox()),
                      Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: customFormField(
                                formValidateNodifier: formValidateNodifier,
                                controller: corPlaceOfIssueController,
                                labelText: corIssueDateIsManitory
                                    ? "Place of issue"
                                    : "Place of issue@",
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z]')),
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                onChange: (value) {
                                  checkFormValidation(value);
                                  checkresAddSameAsPerAdd();
                                },
                                validator: (value) => corIssueDateIsManitory
                                    ? validatePlace(value)
                                    : nullValidation(value)),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: customFormField(
                        formValidateNodifier: formValidateNodifier,
                        readOnly: true,
                        controller: corPoiExpireDateController,
                        labelText: "Expiry Date",
                        onChange: (value) {
                          checkFormValidation(value);
                          checkresAddSameAsPerAdd();
                        },
                        onTap: () async {
                          datePick(
                              isExpiryDate: true,
                              func: (DateTime? date) {
                                if (date != null && corPoiExpireDate != date) {
                                  corPoiExpireDate = date;
                                  corPoiExpireDateController.text =
                                      "${date.toString().substring(8, 10)}/${date.toString().substring(5, 7)}/${date.toString().substring(0, 4)}";
                                }
                                checkFormValidation("");
                                checkresAddSameAsPerAdd();
                                setState(() {});
                              });
                        },
                        validator: (value) {
                          return corIssueDateIsManitory
                              ? validateNotNull(value, "Expiry Date")
                              : nullValidation(value);
                        }),
                  ),
                  const SizedBox(height: 10),
                ],
                ...customFormField(
                    formValidateNodifier: formValidateNodifier,
                    labelText: "Address proof front Page",
                    controller: corAddressProofFrontPageController,
                    readOnly: true,
                    hintText: "Upload",
                    onChange: (value) {
                      checkFormValidation(value);
                      checkresAddSameAsPerAdd();
                    },
                    prefixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(width: 10.0),
                      SvgPicture.asset(
                        "assets/images/attachment.svg",
                        width: 22.0,
                      ),
                      const SizedBox(width: 10.0),
                    ]),
                    suffixIcon: corFiles[0] != null ||
                            corAddressFrontPageFileDetails != null
                        ? IconButton(
                            onPressed: () {
                              if (corFiles[0] != null) {
                                Navigator.pushNamed(
                                    context,
                                    corAddressProofFrontPageController.text
                                            .endsWith(".pdf")
                                        ? route.previewPdf
                                        : route.previewImage,
                                    arguments: {
                                      "title": "manualEntryProof1",
                                      "data": corFiles[0]!.readAsBytesSync(),
                                      "fileName":
                                          corAddressProofFrontPageController
                                              .text
                                    });
                              } else {
                                Navigator.pushNamed(
                                    context,
                                    corAddressFrontPageFileDetails![0]
                                            .toString()
                                            .endsWith(".pdf")
                                        ? route.previewPdf
                                        : route.previewImage,
                                    arguments: {
                                      "title": "manualEntryProof1",
                                      "data":
                                          corAddressFrontPageFileDetails![1],
                                      "fileName":
                                          corAddressFrontPageFileDetails![0]
                                    });
                              }
                            },
                            icon: Icon(
                              Icons.preview,
                              color: const Color.fromARGB(255, 99, 97, 97),
                            ))
                        : null,
                    onTap: () {
                      pickFileBottomSheet(
                          context,
                          (path, docId) => pickAddressProof(
                              context, path, docId,
                              isCorAdds: true, isFrontpage: true),
                          "Address",
                          "COR Manual Address Proof 1",
                          pageCount: corShowBackPageAddress ? 1 : null);
                    }),
                Visibility(
                    visible: corShowBackPageAddress,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10.0),
                        ...customFormField(
                          formValidateNodifier: formValidateNodifier,
                          labelText: "Address proof back Page",
                          controller: corAddressProofBackPageController,
                          hintText: "Upload",
                          readOnly: true,
                          onChange: (value) {
                            checkFormValidation(value);
                            checkresAddSameAsPerAdd();
                          },
                          prefixIcon:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            const SizedBox(width: 10.0),
                            SvgPicture.asset(
                              "assets/images/attachment.svg",
                              width: 22.0,
                            ),
                            const SizedBox(width: 10.0),
                          ]),
                          suffixIcon: (corFiles.length > 1 &&
                                      corFiles[1] != null) ||
                                  corAddressBackPageFileDetails != null
                              ? IconButton(
                                  onPressed: () {
                                    if (corFiles[1] != null) {
                                      Navigator.pushNamed(
                                          context,
                                          corAddressProofFrontPageController
                                                  .text
                                                  .endsWith(".pdf")
                                              ? route.previewPdf
                                              : route.previewImage,
                                          arguments: {
                                            "title": "manualEntryProof1",
                                            "data":
                                                corFiles[1]!.readAsBytesSync(),
                                            "fileName":
                                                corAddressProofFrontPageController
                                                    .text
                                          });
                                    } else {
                                      Navigator.pushNamed(
                                          context,
                                          corAddressBackPageFileDetails![0]
                                                  .toString()
                                                  .endsWith(".pdf")
                                              ? route.previewPdf
                                              : route.previewImage,
                                          arguments: {
                                            "title": "manualEntryProof1",
                                            "data":
                                                corAddressBackPageFileDetails![
                                                    1],
                                            "fileName":
                                                corAddressBackPageFileDetails![
                                                    0]
                                          });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.preview,
                                    color:
                                        const Color.fromARGB(255, 99, 97, 97),
                                  ))
                              : null,
                          onTap: () {
                            pickFileBottomSheet(
                                context,
                                (path, docId) => pickAddressProof(
                                    context, path, docId,
                                    isCorAdds: true),
                                "Address",
                                "COR Manual Address Proof 2",
                                pageCount: corShowBackPageAddress ? 1 : null);
                          },
                          validator:
                              corShowBackPageAddress ? null : (value) => null,
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ]);
  }

  pickAddressProof(context, path, docId,
      {bool isCorAdds = false, bool isFrontpage = false}) {
    File file = File(path);
    String fileName = path.toString().split("/").last;
    if (isCorAdds) {
      if (isFrontpage) {
        corAddressProofFrontPageController.text = fileName;
        ids[2] = docId;
        corFiles[0] = file;
        corDocid1 = docId;
      } else {
        corAddressProofBackPageController.text = fileName;
        ids[3] = docId;
        corFiles[1] = file;
        corDocid2 = docId;
      }
      checkresAddSameAsPerAdd();
    } else {
      if (isFrontpage) {
        perAddressProofFrontPageController.text = fileName;
        ids[0] = docId;
        perFiles[0] = file;
        perDocid1 = docId;
      } else {
        perAddressProofBackPageController.text = fileName;
        ids[1] = docId;
        perFiles[1] = file;
        perDocid2 = docId;
      }
      residentailAddressChangeToSameAsPermentAddress();
    }

    if (mounted) {
      setState(() {});
    }
  }

  getpindata(
      {required String pincode,
      required String url,
      required bool permenant}) async {
    var response = await getPincode(context: context, pincode: pincode);
    if (response != null) {
      if (permenant) {
        cityController.text = response["resp"]['city'];
        stateController.text = response["resp"]['state'];
      } else {
        residentialCityController.text = response["resp"]['city'];
        residentialStateController.text = response["resp"]['state'];
      }
    }
  }
}
