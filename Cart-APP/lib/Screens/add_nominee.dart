import 'dart:io';
import 'package:ekyc/Cookies/cookies.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../Custom Widgets/stepwidget.dart';
import '../Custom Widgets/file_upload_bottomsheet.dart';
import '../provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';

import '../API call/api_call.dart';
import '../Custom Widgets/bsheetheader.dart';
import '../Custom Widgets/custom_drop_down.dart';
import '../Custom Widgets/custom_form_field.dart';
import '../Custom Widgets/date_picker_form_field.dart';
import '../Model/getfromdata_modal.dart';
import '../Nodifier/nodifierclass.dart';
import '../Service/validate_func.dart';
import '../Route/route.dart' as route;

class AddNomineeForm extends StatefulWidget {
  final String nom;
  final Map<String, dynamic>? nomineeDetails;
  const AddNomineeForm(
      {super.key, required this.nom, required this.nomineeDetails});

  @override
  State<AddNomineeForm> createState() => _AddNomineeFormState();
}

class _AddNomineeFormState extends State<AddNomineeForm> {
  List<dynamic>? poidropdown = [];
  List<dynamic>? nameTitledropdown = [];
  List<dynamic>? nomineerelation = [];
  List<dynamic>? gaurdianrelation = [];
  bool gVisible = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController nNameTitle = TextEditingController();
  TextEditingController nProofType = TextEditingController();
  TextEditingController nProofnumber = TextEditingController();
  TextEditingController nFile = TextEditingController();
  TextEditingController nName = TextEditingController();
  TextEditingController nState = TextEditingController();
  TextEditingController nCountry = TextEditingController();
  TextEditingController nCity = TextEditingController();
  TextEditingController adressline3 = TextEditingController();
  TextEditingController adressline2 = TextEditingController();
  TextEditingController adressline1 = TextEditingController();
  TextEditingController nPin = TextEditingController();
  TextEditingController percentofshare = TextEditingController();
  TextEditingController nRelationvalue = TextEditingController();
  TextEditingController nMail = TextEditingController();
  TextEditingController nMobile = TextEditingController();

  bool sameAsClientAddress = true;
  File? nomineefile;
  List nomineeFiles = [];
  List gardientFiles = [];
  TextEditingController gNameTitle = TextEditingController();
  TextEditingController gProofType = TextEditingController();
  TextEditingController gProofnumber = TextEditingController();
  TextEditingController gFile = TextEditingController();
  TextEditingController gName = TextEditingController();
  TextEditingController gState = TextEditingController();
  TextEditingController gCountry = TextEditingController();
  TextEditingController gCity = TextEditingController();
  TextEditingController gAdressline3 = TextEditingController();
  TextEditingController gAdressline2 = TextEditingController();
  TextEditingController gAdressline1 = TextEditingController();
  TextEditingController gPin = TextEditingController();

  TextEditingController gRelationvalue = TextEditingController();
  TextEditingController gMail = TextEditingController();
  TextEditingController gMobile = TextEditingController();
  TextEditingController nomineePOIExpireDateController =
      TextEditingController();
  TextEditingController guardianPOIExpireDateController =
      TextEditingController();
  TextEditingController nomineePOIIssueDateController = TextEditingController();
  TextEditingController guardianPOIPlaceOfIssueController =
      TextEditingController();
  TextEditingController nomineePOIPlaceOfIssueController =
      TextEditingController();
  TextEditingController guardianPOIIssueDateController =
      TextEditingController();
  DateTime? nomineePOIExpireDate;
  DateTime? guardianPOIExpireDate;
  DateTime? nomineePOIIssueDate;
  DateTime? guardianPOIIssueDate;
  bool guardianAddressSameAsNomineeAddress = true;
  File? guarFile;
  int id = 0;
  String nomineeDocId = "";
  String guardianDocId = "";

  FormValidateNodifier formValidateNodifier =
      FormValidateNodifier({"PAN Number": false, "Date of Birth": false});
  DateChange dob = DateChange();
  DateChange datechange2 = DateChange();
  bool isloading = false;
  int getlength = 0;
  bool isFormValid = false;
  List? nomineeFileDetails;
  List? gurdianFileDetails;
  String nomineeFileName = "";
  String gardianFileName = "";
  num currentPercentage = 0;
  num percentage = 0;
  num per = 0;
  num tempPer = 0;
  num oldPercentage = 0;
  List<Map<String, dynamic>> nomineesDetails = [];
  ScrollController scrollController = ScrollController();
  String nomineeProofCode = "";
  String guardianProofCode = "";
  bool nomineeIssueDateIsManitory = false;
  bool guardianIssueDateIsManitory = false;
  bool countinueButtonIsTriggered = false;

  nameTitleDropDown() async {
    loadingAlertBox(context);
    Map? data = await getDropDownValues(context: context, code: "client title");
    if (data != null) {
      List actualdata = data["lookupvaluearr"];
      nameTitledropdown = actualdata;
    }
    adressdropdown();
  }

  adressdropdown() async {
    Map? data =
        await getDropDownValues(context: context, code: "Proof of Identity");
    if (data != null) {
      List? actualdata = data["lookupvaluearr"];
      poidropdown = actualdata ?? [];
    }
    nomrelationdropdown();
  }

  nomrelationdropdown() async {
    Map? data =
        await getDropDownValues(context: context, code: "Nominee Relationship");
    if (data != null) {
      List? actualdata = data["lookupvaluearr"];
      nomineerelation = actualdata ?? [];
    }

    guarnomrelationdropdown();
  }

  guarnomrelationdropdown() async {
    Map? data = await getDropDownValues(
        context: context, code: "nomineeGuardianRelationship");
    if (data != null) {
      List actualdata = data["lookupvaluearr"];
      gaurdianrelation = actualdata;
    }
    getClientAddress();
  }

  Map clientAddress = {};

  getClientAddress() async {
    var response = await getClientAddressInAPI(context: context);
    if (response != null) {
      clientAddress = response;
    }

    getNomineeDetails();
  }

  getNomineeDetails() async {
    ProviderClass postMap = Provider.of<ProviderClass>(context, listen: false);
    nomineesDetails = postMap.response
        .where((nominee) => nominee["ModelState"] != "deleted")
        .toList();
    getlength = nomineesDetails.length;

    percentage = nomineesDetails.isNotEmpty
        ? nomineesDetails.fold(
            0,
            (previousValue, element) =>
                previousValue + (int.tryParse(element["nomineeshare"]) ?? 0))
        : 0;
    tempPer = percentage;
    if (widget.nomineeDetails == null) {
      isloading = true;
      if (postMap.mobileNo != CustomHttpClient.testMobileNo &&
          postMap.email != CustomHttpClient.testEmail) {
        guardianAddressSameAsNomineeAddress = true;
        sameAsClientAddress = true;
        nomineeAddresschangeToClientAddress();
        guardianAddresschangeToNomineeAddress();
      }
      per = percentage;
      if (mounted) {
        Navigator.pop(context);
        setState(() {});
      }
      return;
    }
    Nominee n1 = Nominee.fromJson(widget.nomineeDetails ?? {});
    id = n1.nomineeID;
    nNameTitle.text = nameTitledropdown!.firstWhere(
        (element) => element["code"] == n1.nomineeTitle,
        orElse: () => {"description": ""})["description"];
    nName.text = n1.nomineeName;
    dob.value = DateTime.tryParse(
        "${n1.nomineeDob.substring(6, 10)}-${n1.nomineeDob.substring(3, 5)}-${n1.nomineeDob.substring(0, 2)}");
    agecheck(dob);
    percentofshare.text = n1.nomineeShare;
    List relationShip = nomineerelation!
        .where((e) => e['code'] == n1.nomineeRelationship)
        .toList();
    nRelationvalue.text = relationShip.isNotEmpty
        ? relationShip[0]['description'].toString()
        : "";
    nMobile.text = n1.nomineeMobileNo;
    nMail.text = n1.nomineeEmailId;
    List poi = poidropdown!
        .where((e) => e['code'] == n1.nomineeProofOfIdentity)
        .toList();
    nomineeProofCode = n1.nomineeProofOfIdentity;
    nProofType.text = poi.isNotEmpty ? poi[0]['description'].toString() : "";
    nFile.text = n1.noimineeFileName;
    gVisible = n1.guardianVisible;
    adressline1.text = n1.nomineeAddress1;
    adressline2.text = n1.nomineeAddress2;
    adressline3.text = n1.nomineeAddress3;
    nPin.text = n1.nomineePincode;
    nCity.text = n1.nomineeCity;
    nState.text = n1.nomineeState;
    nCountry.text = n1.nomineeCountry;
    nomineeFileName = n1.noimineeFileString;
    nProofnumber.text = n1.nomineeProofNumber;
    nomineePOIIssueDateController.text = n1.nomineeproofdateofissue;
    nomineePOIPlaceOfIssueController.text = n1.nomineeplaceofissue;
    nomineePOIExpireDateController.text = n1.nomineeproofexpriydate;
    gName.text = n1.guardianName;
    gNameTitle.text = nameTitledropdown!.firstWhere(
        (element) => element["code"] == n1.guardianTitle,
        orElse: () => {"description": ""})["description"];
    List gaudianValue = gaurdianrelation!
        .where((e) => e['code'] == n1.guardianRelationship)
        .toList();
    gRelationvalue.text = gaudianValue.isNotEmpty
        ? gaudianValue[0]['description'].toString()
        : "";

    gMobile.text = n1.guardianMobileNo;
    gMail.text = n1.guardianEmailId;
    List proofValue = poidropdown!
        .where((e) => e['code'] == n1.guardianProofOfIdentity)
        .toList();
    guardianProofCode = n1.guardianProofOfIdentity;
    gProofType.text =
        proofValue.isNotEmpty ? proofValue[0]['description'].toString() : "";
    gFile.text = n1.guardianFileName;
    gAdressline1.text = n1.guardianAddress1;
    gAdressline2.text = n1.guardianAddress2;
    gAdressline3.text = n1.guardianAddress3;
    gPin.text = n1.guardianPincode;
    gCity.text = n1.guardianCity;
    gState.text = n1.guardianState;
    gCountry.text = n1.guardianCountry;
    gProofnumber.text = n1.guardianProofNumber;
    guardianPOIIssueDateController.text = n1.guardianproofdateofissue;
    guardianPOIPlaceOfIssueController.text = n1.guardianplaceofissue;
    guardianPOIExpireDateController.text = n1.guardianproofexpriydate;
    gardianFileName = n1.guardianFileString;
    nomineeDocId = n1.nomineeFileUploadDocIds;
    guardianDocId = n1.guardianFileUploadDocIds;
    try {
      nomineeFileDetails = n1.nomineeFileUploadDocIds.isNotEmpty
          ? await fetchFile(
              context: context, id: n1.nomineeFileUploadDocIds, list: true)
          : null;
      gurdianFileDetails = n1.guardianFileUploadDocIds.isNotEmpty
          ? await fetchFile(
              context: context, id: n1.guardianFileUploadDocIds, list: true)
          : null;
    } catch (e) {}
    nomineeFileDetails != null ? nFile.text = "File Uploaded" : null;
    gurdianFileDetails != null ? gFile.text = "File Uploaded" : null;
    isloading = true;
    guardianAddressSameAsNomineeAddress = true;
    sameAsClientAddress = true;
    checkGuardianAddressSameAsNominee("");
    checkNomineeAddressSameAsClinet("");

    if (widget.nomineeDetails != null) {
      currentPercentage = num.tryParse(n1.nomineeShare) ?? 0;
      per = percentage - currentPercentage;
    }
    nomineefile = postMap.getFile(widget.nom, true);
    guarFile = postMap.getFile(widget.nom, false);
    formVaidate("");
    if (mounted) {
      Navigator.pop(context);
      setState(() {});
    }
  }

  getpindata({required String pincode, required bool isnom}) async {
    var json = await getPincode(context: context, pincode: pincode);
    if (json != null) {
      {
        if (isnom) {
          nCity.text = json["resp"]['city'];
          nState.text = json["resp"]['state'];
          nCountry.text = 'india';
        } else {
          gCity.text = json["resp"]['city'];
          gState.text = json["resp"]['state'];
          gCountry.text = 'india';
        }
      }
    }
  }

  int age = 20;
  DateTime? selectedDate;
  agecheck(DateChange dc) {
    selectedDate = dc.value;
    dob.onchange(selectedDate ?? DateTime.now());
    if (dc.value == null) return;
    age = DateTime.now().year - selectedDate!.year;

    if (DateTime.now().month < selectedDate!.month ||
        (DateTime.now().month == selectedDate!.month &&
            DateTime.now().day < selectedDate!.day)) {
      age--;
    }
    if (mounted) {
      setState(() {});
    }
  }

  nomineeAddresschangeToClientAddress() {
    adressline1.text = clientAddress["address1"] ?? "";
    adressline2.text = clientAddress["address2"] ?? "";
    adressline3.text = clientAddress["address3"] ?? "";
    nPin.text = clientAddress["pincode"] ?? "";
    nCity.text = clientAddress["city"] ?? "";
    nState.text = clientAddress["state"] ?? "";
    nCountry.text = "India";
  }

  guardianAddresschangeToClientAddress() {
    gAdressline1.text = clientAddress["address1"] ?? "";
    gAdressline2.text = clientAddress["address2"] ?? "";
    gAdressline3.text = clientAddress["address3"] ?? "";
    gPin.text = clientAddress["pincode"] ?? "";
    gCity.text = clientAddress["city"] ?? "";
    gState.text = clientAddress["state"] ?? "";
    gCountry.text = "India";
  }

  guardianAddresschangeToNomineeAddress() {
    if (!guardianAddressSameAsNomineeAddress) return;
    gAdressline1.text = adressline1.text;
    gAdressline2.text = adressline2.text;
    gAdressline3.text = adressline3.text;
    gPin.text = nPin.text;
    gCity.text = nCity.text;
    gState.text = nState.text;
    gCountry.text = "India";
  }

  checkNomineeAddressSameAsClinet(value) {
    if (!sameAsClientAddress) return;
    if (adressline1.text == clientAddress["address1"] &&
        adressline2.text == clientAddress["address2"] &&
        adressline3.text == clientAddress["address3"] &&
        nPin.text == clientAddress["pincode"]) {
      sameAsClientAddress = true;
    } else {
      sameAsClientAddress = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  checkGuardianAddressSameAsNominee(value) {
    if (!guardianAddressSameAsNomineeAddress) return;
    if (gAdressline1.text == adressline1.text &&
        gAdressline2.text == adressline2.text &&
        gAdressline3.text == adressline3.text &&
        gPin.text == nPin.text) {
      guardianAddressSameAsNomineeAddress = true;
    } else {
      guardianAddressSameAsNomineeAddress = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameTitleDropDown();
    });

    super.initState();
  }

  String getFileTime(int f1, int f2) {
    DateTime d = DateTime.now();

    int d2 = d.millisecondsSinceEpoch * f1 * f2;
    return d2.toString();
  }

  filePick(isNominee, path, docId) async {
    File file = File(path!);
    List l = path.split("/");
    if (isNominee) {
      nFile.text = l[l.length - 1];
      nomineefile = file;
      nomineeFileName = getFileTime(
          2,
          widget.nom == "Nominee 1"
              ? 1
              : widget.nom == "Nominee 2"
                  ? 2
                  : 3);
      nomineeDocId = docId;
    } else {
      gFile.text = l[l.length - 1];
      guarFile = file;
      gardianFileName = getFileTime(
          3,
          widget.nom == "Nominee 1"
              ? 1
              : widget.nom == "Nominee 2"
                  ? 2
                  : 3);
      guardianDocId = docId;
    }
  }

  addNomineeDetailsInProvider() {
    ProviderClass postmap = Provider.of<ProviderClass>(context, listen: false);

    Map<String, dynamic> m = {
      "NomineeID": id,
      "nomineename": nName.text,
      "nomineetitle": nNameTitle.text,
      "nomineerelationship": nomineerelation!
          .where((e) => e['description'] == nRelationvalue.text)
          .toList()[0]['code']
          .toString(),
      "nomineerelationshipdesc": nRelationvalue.text,
      "nomineeshare": percentofshare.text,
      "nomineedob":
          "${dob.value.toString().substring(8, 10)}/${dob.value.toString().substring(5, 7)}/${dob.value.toString().substring(0, 4)}",
      "nomineeaddress1": adressline1.text,
      "nomineeaddress2": adressline2.text,
      "nomineeaddress3": adressline3.text,
      "nomineecity": nCity.text,
      "nomineestate": nState.text,
      "nomineecountry": "India",
      "nomineepincode": nPin.text,
      "nomineemobileno": nMobile.text,
      "nomineeemailid": nMail.text,
      "nomineeproofofidentity": nProofType.text == ""
          ? ""
          : poidropdown!
              .where((e) => e['description'] == nProofType.text)
              .toList()[0]['code']
              .toString(),
      "nomineeproofofidentitydesc": nProofType.text,
      "nomineeproofnumber": nProofnumber.text,
      "nomineeplaceofissue": nomineePOIPlaceOfIssueController.text,
      "nomineeproofdateofissue": nomineePOIIssueDateController.text,
      "nomineeproofexpriydate":
          nomineeIssueDateIsManitory ? nomineePOIExpireDateController.text : "",
      "nomineefilestring": nomineeFileName,
      "nomineefilename": nFile.text,
      "nomineefilepath": " ",
      "nomineefileuploaddocids": nomineeDocId,
      "guardianvisible": age >= 18 ? false : true,
      "guardianname": age >= 18 ? "" : gName.text,
      "guardiantitle": age >= 18 ? "" : gNameTitle.text,
      "guardianrelationship": gRelationvalue.text == "" || age >= 18
          ? ""
          : gaurdianrelation!
              .where((e) => e['description'] == gRelationvalue.text)
              .toList()[0]['code']
              .toString(),
      "guardianrelationshipdesc": age >= 18 ? "" : gRelationvalue.text,
      "guardianaddress1": age >= 18 ? "" : gAdressline1.text,
      "guardianaddress2": age >= 18 ? "" : gAdressline2.text,
      "guardianaddress3": age >= 18 ? "" : gAdressline3.text,
      "guardiancity": age >= 18 ? "" : gCity.text,
      "guardianstate": age >= 18 ? "" : gState.text,
      "guardiancountry": age >= 18 ? "" : "India",
      "guardianpincode": age >= 18 ? "" : gPin.text,
      "guardianmobileno": age >= 18 ? "" : gMobile.text,
      "guardianemailid": age >= 18 ? "" : gMail.text,
      "guardianproofofidentity": gProofType.text == "" || age >= 18
          ? ""
          : poidropdown!
              .where((e) => e['description'] == gProofType.text)
              .toList()[0]['code']
              .toString(),
      "guardianplaceofissue":
          age >= 18 ? "" : guardianPOIPlaceOfIssueController.text,
      "guardianproofdateofissue":
          age >= 18 ? "" : guardianPOIIssueDateController.text,
      "guardianproofexpriydate": age >= 18
          ? ""
          : guardianIssueDateIsManitory
              ? guardianPOIExpireDateController.text
              : "",
      "guardianproofofidentitydesc": age >= 18 ? "" : gProofType.text,
      "guardianproofnumber": age >= 18 ? "" : gProofnumber.text,
      "guardianfilestring": age >= 18 ? "" : gardianFileName,
      "guardianfilename": age >= 18 ? "" : gFile.text,
      "guardianfilepath": "",
      "guardianfileuploaddocids": guardianDocId,
      "ModelState": ((getlength >= 1 && widget.nom == "Nominee 1") ||
              (getlength >= 2 && widget.nom == "Nominee 2") ||
              (getlength == 3 && widget.nom == "Nominee 3"))
          ? widget.nomineeDetails == null ||
                  widget.nomineeDetails!["ModelState"] == "added"
              ? "added"
              : "modified"
          : "added"
    };
    int position = int.parse(widget.nom.substring(widget.nom.length - 1));
    int index = postmap.response.indexOf(widget.nomineeDetails ?? {});
    getlength >= position && index != -1
        ? postmap.response[index] = m
        : postmap.response.add(m);
    postmap.changeResponse(postmap.response);
    postmap.changenFile(widget.nom, nomineefile, nomineeFileName, true);
    postmap.changenFile(widget.nom, guarFile, gardianFileName, false);
  }

  bool ifFormValidateIsTriggered = false;
  formVaidate(value) {
    if (nName.text != "" &&
        nNameTitle.text != "" &&
        dob.value != null &&
        nRelationvalue.text != "" &&
        percentofshare.text != "" &&
        (age < 18 ||
            (nMobile.text != "" &&
                nMail.text != "" &&
                adressline2.text != "" &&
                nProofType.text != "" &&
                nProofnumber.text != "" &&
                (!nomineeIssueDateIsManitory ||
                    (nomineePOIPlaceOfIssueController.text != "" &&
                        nomineePOIIssueDateController.text != "" &&
                        nomineePOIExpireDateController.text.isNotEmpty)) &&
                nFile.text != "")) &&
        adressline1.text != "" &&
        nPin.text != "" &&
        nState.text != "" &&
        nCity.text != "" &&
        nCountry.text != "" &&
        (age >= 18 ||
            (gName.text != "" &&
                gNameTitle.text != "" &&
                gRelationvalue.text != "" &&
                gMobile.text != "" &&
                gMail.text != "" &&
                gAdressline1.text != "" &&
                gAdressline2.text != "" &&
                gPin.text != "" &&
                gState.text != "" &&
                gCity.text != "" &&
                gCountry.text != "" &&
                gProofType.text != "" &&
                gProofnumber.text != "" &&
                (!guardianIssueDateIsManitory ||
                    (guardianPOIPlaceOfIssueController.text != "" &&
                        guardianPOIIssueDateController.text != "" &&
                        guardianPOIExpireDateController.text.isNotEmpty)) &&
                gFile.text != ""))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ifFormValidateIsTriggered = true;
        if (_formKey.currentState?.validate() ?? false) {
          isFormValid = true;
        }
      });
    } else if (ifFormValidateIsTriggered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.validate();
      });
    }

    isFormValid = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  datePick({required func, required pickedDate, isExpiryDate}) {
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
              initialDisplayDate: pickedDate ?? today,
              initialSelectedDate: pickedDate,
              minDate: isExpiryDate == true ? today : DateTime(1900),
              maxDate: isExpiryDate == true ? DateTime(2100) : today,
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

  @override
  Widget build(BuildContext context) {
    return StepWidget(
        title: 'Nomination & Declaration',
        subTitle: 'Add up to three nominees to your Demat & Trading account.',
        scrollController: scrollController,
        backFunc: true,
        buttonText: percentage >= 100 || widget.nom == 'Nominee 3'
            ? "Continue"
            : widget.nom == 'Nominee 1'
                ? 'Add Nominee 2'
                : 'Add Nominee 3',
        buttonFunc: () {
          if (!countinueButtonIsTriggered) {
            countinueButtonIsTriggered = true;
            setState(() {});
          }
          if (!(_formKey.currentState!.validate() &&
              nNameTitle.text.isNotEmpty &&
              nRelationvalue.text.isNotEmpty &&
              (age < 18 || nProofType.text.isNotEmpty) &&
              (age > 18 ||
                  (gNameTitle.text.isNotEmpty &&
                      gRelationvalue.text.isNotEmpty &&
                      gProofType.text.isNotEmpty)))) {
            return;
          }
          addNomineeDetailsInProvider();
          if (percentage >= 100 || widget.nom == 'Nominee 3') {
            Navigator.pushNamed(
              context,
              route.nominee,
            );
            return;
          }
          switch (widget.nom) {
            case 'Nominee 1':
              Navigator.pushNamed(context, route.addNominee, arguments: {
                "nominee": "Nominee 2",
                "nomineeDetails":
                    nomineesDetails.length > 1 ? nomineesDetails[1] : null
              });
              break;
            case 'Nominee 2':
              Navigator.pushNamed(context, route.addNominee, arguments: {
                "nominee": "Nominee 3",
                "nomineeDetails":
                    nomineesDetails.length > 2 ? nomineesDetails[2] : null
              });
              break;
            default:
          }
        },
        children: [
          Form(
            key: _formKey,
            onChanged: () => formVaidate(""),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bsheethead(name: widget.nom),
                    const SizedBox(
                      height: 25,
                    ),
                    const Text("Name*"),
                    const SizedBox(height: 5.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 80.0,
                          child: CustomDropDown(
                              controller: nNameTitle,
                              showError: countinueButtonIsTriggered &&
                                  nNameTitle.text.isEmpty,
                              values: nameTitledropdown == null
                                  ? []
                                  : nameTitledropdown!
                                      .map((e) => e['description'])
                                      .toList(),
                              onChange: formVaidate,
                              formValidateNodifier: formValidateNodifier),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                            child: CustomFormField(
                                controller: nName,
                                labelText: 'Name',
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z\s]')),
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                validator: (value) =>
                                    validateName(value, "Nominee Name", 3)))
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Date of Birth*',
                        style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(
                      height: 10,
                    ),
                    CustomDateFormField(
                        errorText:
                            countinueButtonIsTriggered && dob.value == null
                                ? "DOB is required"
                                : null,
                        onChange: (value) async {
                          agecheck(dob);
                          formVaidate("");
                          await Future.delayed(Duration(milliseconds: 50));
                          if (countinueButtonIsTriggered) {
                            _formKey.currentState!.validate();
                          }
                        },
                        date: dob,
                        formValidateNodifier: formValidateNodifier),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Relationship*',
                        style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(
                      height: 10,
                    ),
                    CustomDropDown(
                        label: "Relationship",
                        showError: countinueButtonIsTriggered &&
                            nRelationvalue.text.isEmpty,
                        controller: nRelationvalue,
                        values: nomineerelation == null
                            ? []
                            : nomineerelation!
                                .map((e) => e['description'])
                                .toList(),
                        onChange: formVaidate,
                        formValidateNodifier: formValidateNodifier),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: customFormField(
                          controller: percentofshare,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(3),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChange: (value) {
                            num newCurrentPercentage = num.tryParse(value) ?? 0;
                            tempPer = per + newCurrentPercentage;
                            percentage = percentage -
                                currentPercentage +
                                newCurrentPercentage;
                            currentPercentage = newCurrentPercentage;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {});
                              }
                            });
                          },
                          labelText: 'Percentage of share',
                          validator: (String? value) {
                            return validatePercentage(value);
                          }),
                    ),
                    Visibility(
                        visible: tempPer != 0 && tempPer != 100,
                        child: Row(
                          children: [
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                "Nominee total share percentage is $tempPer , which is ${tempPer > 100 ? "greater" : "lesser"} than 100",
                                style: TextStyle(
                                    color: Color.fromRGBO(176, 0, 32, 1)),
                              ),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: customFormField(
                        validator: age < 18
                            ? (String? value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                return mobileNumberValidation(value);
                              }
                            : mobileNumberValidation,
                        controller: nMobile,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        labelText:
                            age < 18 ? 'Mobile Number@' : 'Mobile Number',
                        formValidateNodifier: formValidateNodifier,
                      ),
                    ),
                    SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: customFormField(
                          controller: nMail,
                          labelText: age < 18 ? 'Mail id@' : 'Mail id',
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          validator: age < 18
                              ? (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  return emailValidation(value);
                                }
                              : emailValidation),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: Provider.of<ProviderClass>(context).mobileNo !=
                              CustomHttpClient.testMobileNo &&
                          Provider.of<ProviderClass>(context).email !=
                              CustomHttpClient.testEmail,
                      child: Column(
                        children: [
                          InkWell(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 15.0,
                                    width: 15.0,
                                    decoration: BoxDecoration(
                                        color: sameAsClientAddress
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.transparent,
                                        border: Border.all(
                                            width: 1,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color!)),
                                    child: sameAsClientAddress
                                        ? Icon(Icons.check_sharp,
                                            size: 12, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                      child: const Text(
                                          'The nominee residential address are the same as the applicant'))
                                ],
                              ),
                              onTap: () {
                                sameAsClientAddress = !sameAsClientAddress;
                                sameAsClientAddress
                                    ? nomineeAddresschangeToClientAddress()
                                    : null;
                                if (mounted) {
                                  setState(() {});
                                }
                              }),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: customFormField(
                                controller: adressline1,
                                labelText: 'Addressline 1',
                                onChange: (value) {
                                  checkNomineeAddressSameAsClinet(value);
                                  guardianAddresschangeToNomineeAddress();
                                },
                                validator: (value) => validateAddresss(
                                    value, "Address Line 1", 3, 55)),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: customFormField(
                                controller: adressline2,
                                labelText: 'Addressline 2',
                                onChange: (value) {
                                  guardianAddresschangeToNomineeAddress();
                                  checkNomineeAddressSameAsClinet(value);
                                },
                                validator: (value) => validateAddresss(
                                    value, "Address Line 2", 3, 30)),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: customFormField(
                                controller: adressline3,
                                labelText: 'Addressline 3@',
                                validator: (value) =>
                                    nullValidationWithMaxLength(value, 30),
                                onChange: (value) {
                                  guardianAddresschangeToNomineeAddress();
                                  checkNomineeAddressSameAsClinet(value);
                                }),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: customFormField(
                                          formValidateNodifier:
                                              formValidateNodifier,
                                          controller: nPin,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(6),
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          keyboardType: TextInputType.number,
                                          validator: validatePinCode,
                                          onChange: (value) async {
                                            if (value.length == 6) {
                                              await getpindata(
                                                  pincode: value, isnom: true);
                                            } else {
                                              nCity.text = "";
                                              nState.text = "";
                                              nCountry.text = "";
                                            }
                                            checkNomineeAddressSameAsClinet(
                                                value);
                                            guardianAddresschangeToNomineeAddress();
                                          },
                                          labelText: 'Pincode'),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: customFormField(
                                        controller: nState,
                                        labelText: "State",
                                        readOnly: true,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: customFormField(
                                        controller: nCity,
                                        labelText: "City",
                                        readOnly: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: customFormField(
                                        controller: nCountry,
                                        labelText: "Country",
                                        readOnly: true,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    Text(age < 18 ? 'Proof Of Identity' : 'Proof Of Identity*',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 10.0),
                    CustomDropDown(
                        label: "Proof Of Identity",
                        showError: age > 18 &&
                            countinueButtonIsTriggered &&
                            nProofType.text.isEmpty,
                        controller: nProofType,
                        values: poidropdown == null
                            ? []
                            : age < 18
                                ? poidropdown!
                                    .where(
                                        (element) => element["code"] != "132")
                                    .map((e) => e['description'])
                                    .toList()
                                : poidropdown!
                                    .where((element) =>
                                        element["code"] != "136" &&
                                        element["code"] != "132")
                                    .map((e) => e['description'])
                                    .toList(),
                        onChange: (value) async {
                          String oldnomineeProofCode = nomineeProofCode;
                          nomineeProofCode = poidropdown!.firstWhere(
                              (element) => element["description"] == value,
                              orElse: () => {"code": ""})["code"];
                          if (oldnomineeProofCode != nomineeProofCode &&
                              oldnomineeProofCode != "") {
                            nProofnumber.text = "";
                            nomineePOIIssueDateController.text = "";
                            nomineePOIIssueDate = null;
                            nomineePOIExpireDateController.text = "";
                            nomineePOIExpireDate = null;
                            nomineePOIPlaceOfIssueController.text = "";
                            nFile.text = "";
                            nomineefile = null;
                            nomineeFileDetails = null;
                          }

                          nomineeIssueDateIsManitory =
                              nomineeProofCode == "133" ||
                                  nomineeProofCode == "134";
                          formVaidate(value);
                          if (countinueButtonIsTriggered) {
                            await Future.delayed(Duration(milliseconds: 50));
                            _formKey.currentState!.validate();
                          }
                        },
                        formValidateNodifier: formValidateNodifier),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: customFormField(
                          controller: nProofnumber,
                          labelText:
                              age < 18 ? 'Proof Number@' : 'Proof Number',
                          validator: age < 18
                              ? (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  return nomineeProofCode == "131"
                                      ? validatePanCard(value)
                                      : validateName(
                                          value,
                                          nProofType.text.isEmpty
                                              ? 'Proof Number'
                                              : nProofType.text,
                                          nomineeProofCode == "133"
                                              ? 12
                                              : nomineeProofCode == "134"
                                                  ? 16
                                                  : 4);
                                }
                              : (String? value) => nomineeProofCode == "131"
                                  ? validatePanCard(value)
                                  : validateName(
                                      value,
                                      nProofType.text.isEmpty
                                          ? 'Proof Number'
                                          : nProofType.text,
                                      nomineeProofCode == "133"
                                          ? 12
                                          : nomineeProofCode == "134"
                                              ? 16
                                              : 4),
                          inputFormatters: nomineeProofCode == "131"
                              ? [
                                  LengthLimitingTextInputFormatter(10),
                                  UpperCaseTextFormatter(),
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]')),
                                ]
                              : [
                                  LengthLimitingTextInputFormatter(
                                      nomineeProofCode == "133"
                                          ? 12
                                          : nomineeProofCode == "134"
                                              ? 16
                                              : 50),
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'))
                                ]),
                    ),
                    if (nomineeIssueDateIsManitory) ...[
                      const SizedBox(
                        height: 20.0,
                      ),
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
                                  controller: nomineePOIIssueDateController,
                                  labelText:
                                      age < 18 || !nomineeIssueDateIsManitory
                                          ? "Date of issue@"
                                          : "Date of issue",
                                  validator: (value) => age < 18 ||
                                          !nomineeIssueDateIsManitory
                                      ? nullValidation(value)
                                      : validateNotNull(value, "Date of issue"),
                                  onTap: () async {
                                    datePick(
                                      pickedDate: nomineePOIIssueDate,
                                      func: (DateTime? date) {
                                        if (date != null &&
                                            nomineePOIIssueDate != date) {
                                          nomineePOIIssueDate = date;
                                          nomineePOIIssueDateController.text =
                                              "${date.toString().substring(8, 10)}/${date.toString().substring(5, 7)}/${date.toString().substring(0, 4)}";
                                        }
                                      },
                                    );
                                  },
                                ),
                              )),
                          const Expanded(flex: 1, child: SizedBox()),
                          Expanded(
                              flex: 4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: customFormField(
                                    formValidateNodifier: formValidateNodifier,
                                    controller:
                                        nomineePOIPlaceOfIssueController,
                                    labelText:
                                        age < 18 || !nomineeIssueDateIsManitory
                                            ? "Place of issue@"
                                            : "Place of issue",
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[a-zA-Z]'))
                                    ],
                                    validator:
                                        age < 18 || !nomineeIssueDateIsManitory
                                            ? (String? value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return null;
                                                }
                                                return validatePlace(value);
                                              }
                                            : (value) => validatePlace(value)),
                              )),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: customFormField(
                          formValidateNodifier: formValidateNodifier,
                          readOnly: true,
                          controller: nomineePOIExpireDateController,
                          labelText: age < 18 ? "Expiry Date@" : "Expiry Date",
                          validator: (value) =>
                              age < 18 || !nomineeIssueDateIsManitory
                                  ? nullValidation(value)
                                  : validateNotNull(value, "Expiry Date"),
                          onTap: () async {
                            datePick(
                                func: (DateTime? date) {
                                  if (date != null &&
                                      nomineePOIExpireDate != date) {
                                    nomineePOIExpireDate = date;
                                    nomineePOIExpireDateController.text =
                                        "${date.toString().substring(8, 10)}/${date.toString().substring(5, 7)}/${date.toString().substring(0, 4)}";
                                  }
                                },
                                pickedDate: nomineePOIExpireDate,
                                isExpiryDate: true);
                          },
                        ),
                      ),
                    ],
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: customFormField(
                        onTap: () async {
                          pickFileBottomSheet(
                              context,
                              (path, docId) => filePick(true, path, docId),
                              "",
                              "Nominee Proof ${widget.nom.split("").last}");
                        },
                        controller: nFile,
                        labelText:
                            age < 18 ? 'Proof of Nominee@' : 'Proof of Nominee',
                        readOnly: true,
                        hintText: 'Upload',
                        validator: age < 18
                            ? nullValidation
                            : (value) =>
                                validateNotNull(value, 'Proof of Nominee'),
                        prefixIcon:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          const SizedBox(width: 10.0),
                          SvgPicture.asset(
                            "assets/images/attachment.svg",
                            width: 22.0,
                          ),
                          const SizedBox(width: 10.0),
                        ]),
                        suffixIcon: nomineefile != null ||
                                nomineeFileDetails != null
                            ? IconButton(
                                onPressed: () {
                                  if (nomineefile != null) {
                                    Navigator.pushNamed(
                                        context,
                                        (nomineefile?.path.endsWith(".pdf") ??
                                                false)
                                            ? route.previewPdf
                                            : route.previewImage,
                                        arguments: {
                                          "title":
                                              "${widget.nom.replaceAll(" ", "")}Proof",
                                          "data":
                                              nomineefile!.readAsBytesSync(),
                                          "fileName": nFile.text
                                        });
                                  } else {
                                    Navigator.pushNamed(
                                        context,
                                        nomineeFileDetails![0]
                                                .toString()
                                                .endsWith(".pdf")
                                            ? route.previewPdf
                                            : route.previewImage,
                                        arguments: {
                                          "title":
                                              "${widget.nom.replaceAll(" ", "")}Proof",
                                          "data": nomineeFileDetails![1],
                                          "fileName": nomineeFileDetails![0]
                                        });
                                  }
                                },
                                icon: Icon(
                                  Icons.preview,
                                  color: const Color.fromARGB(255, 99, 97, 97),
                                ))
                            : null,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "File format should be (*.jpg,*.jpeg,*.png,*.pdf) and file size should be less than 5MB",
                    ),
                    ValueListenableBuilder(
                        valueListenable: dob,
                        builder: (context, value, child) {
                          return Visibility(
                              visible: age < 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Text('Guardian Details'),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  const Text("Name*"),
                                  const SizedBox(height: 5.0),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 80.0,
                                        child: CustomDropDown(
                                            controller: gNameTitle,
                                            showError:
                                                countinueButtonIsTriggered &&
                                                    gNameTitle.text.isEmpty,
                                            values: nameTitledropdown == null
                                                ? []
                                                : nameTitledropdown!
                                                    .map(
                                                        (e) => e['description'])
                                                    .toList(),
                                            onChange: formVaidate,
                                            formValidateNodifier:
                                                formValidateNodifier),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: CustomFormField(
                                            controller: gName,
                                            labelText: 'Name',
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[a-zA-Z\s]')),
                                              LengthLimitingTextInputFormatter(
                                                  25)
                                            ],
                                            validator: (value) => validateName(
                                                value, "Guardian Name", 3)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text('Relationship*',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CustomDropDown(
                                      label: "Relationship",
                                      showError: countinueButtonIsTriggered &&
                                          gRelationvalue.text.isEmpty,
                                      controller: gRelationvalue,
                                      values: gaurdianrelation == null
                                          ? []
                                          : gaurdianrelation!
                                              .map((e) => e['description'])
                                              .toList(),
                                      onChange: formVaidate,
                                      formValidateNodifier:
                                          formValidateNodifier),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: customFormField(
                                      validator: mobileNumberValidation,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10)
                                      ],
                                      controller: gMobile,
                                      labelText: 'Mobile Number',
                                      formValidateNodifier:
                                          formValidateNodifier,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: customFormField(
                                        controller: gMail,
                                        labelText: 'Mail id',
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(50)
                                        ],
                                        validator: emailValidation),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  InkWell(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 15.0,
                                            width: 15.0,
                                            decoration: BoxDecoration(
                                                color:
                                                    guardianAddressSameAsNomineeAddress
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : Colors.transparent,
                                                border: Border.all(
                                                    width: 1,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .color!)),
                                            child:
                                                guardianAddressSameAsNomineeAddress
                                                    ? Icon(Icons.check_sharp,
                                                        size: 12,
                                                        color: Colors.white)
                                                    : null,
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              child: const Text(
                                                  'The guardian residential address are the same as the nominee'))
                                        ],
                                      ),
                                      onTap: () {
                                        guardianAddressSameAsNomineeAddress =
                                            !guardianAddressSameAsNomineeAddress;
                                        guardianAddresschangeToNomineeAddress();
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      }),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: customFormField(
                                            controller: gAdressline1,
                                            labelText: 'Addressline 1',
                                            onChange: (value) {
                                              checkGuardianAddressSameAsNominee(
                                                  value);
                                            },
                                            validator: (value) =>
                                                validateAddresss(value,
                                                    "Address Line 1", 3, 55)),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: customFormField(
                                            controller: gAdressline2,
                                            labelText: 'Addressline 2',
                                            onChange: (value) {
                                              checkGuardianAddressSameAsNominee(
                                                  value);
                                            },
                                            validator: (value) =>
                                                validateAddresss(value,
                                                    "Address Line 2", 3, 55)),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: customFormField(
                                            controller: gAdressline3,
                                            labelText: 'Addressline 3@',
                                            validator: (value) =>
                                                nullValidationWithMaxLength(
                                                    value, 55),
                                            onChange: (value) {
                                              checkGuardianAddressSameAsNominee(
                                                  value);
                                            }),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: customFormField(
                                                      inputFormatters: [
                                                        LengthLimitingTextInputFormatter(
                                                            6),
                                                        FilteringTextInputFormatter
                                                            .digitsOnly
                                                      ],
                                                      onChange: (value) async {
                                                        if (value.length == 6) {
                                                          await getpindata(
                                                              pincode: value,
                                                              isnom: false);
                                                        } else {
                                                          gCity.text = "";
                                                          gState.text = "";
                                                          gCountry.text = "";
                                                        }

                                                        checkGuardianAddressSameAsNominee(
                                                            value);
                                                      },
                                                      validator:
                                                          validatePinCode,
                                                      formValidateNodifier:
                                                          formValidateNodifier,
                                                      controller: gPin,
                                                      labelText: 'Pincode'),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: customFormField(
                                                      controller: gState,
                                                      labelText: "State",
                                                      readOnly: true),
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: customFormField(
                                                      controller: gCity,
                                                      labelText: "City",
                                                      readOnly: true),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: customFormField(
                                                      controller: gCountry,
                                                      labelText: "Country",
                                                      readOnly: true),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text('Proof Of Identity*',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CustomDropDown(
                                      label: "Proof Of Identity",
                                      showError: countinueButtonIsTriggered &&
                                          gProofType.text.isEmpty,
                                      controller: gProofType,
                                      values: poidropdown == null
                                          ? []
                                          : poidropdown!
                                              .where((element) =>
                                                  element["code"] != "136" &&
                                                  element["code"] != "132")
                                              .map((e) => e['description'])
                                              .toList(),
                                      onChange: (value) async {
                                        String oldGuardianProofCode =
                                            guardianProofCode;
                                        guardianProofCode = poidropdown!
                                            .firstWhere(
                                                (element) =>
                                                    element["description"] ==
                                                    value,
                                                orElse: () =>
                                                    {"code": ""})["code"];
                                        if (guardianProofCode !=
                                                oldGuardianProofCode &&
                                            oldGuardianProofCode != "") {
                                          gProofnumber.text = "";
                                          guardianPOIIssueDateController.text =
                                              "";
                                          guardianPOIIssueDate = null;
                                          guardianPOIExpireDateController.text =
                                              "";
                                          guardianPOIExpireDate = null;
                                          guardianPOIPlaceOfIssueController
                                              .text = "";
                                          gFile.text = "";
                                          guarFile = null;
                                          gurdianFileDetails = null;
                                        }

                                        guardianIssueDateIsManitory =
                                            guardianProofCode == "133" ||
                                                guardianProofCode == "134";

                                        formVaidate(value);
                                        if (countinueButtonIsTriggered) {
                                          await Future.delayed(
                                              Duration(milliseconds: 50));
                                          _formKey.currentState!.validate();
                                        }
                                      },
                                      formValidateNodifier:
                                          formValidateNodifier),
                                  SizedBox(height: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: customFormField(
                                        controller: gProofnumber,
                                        labelText: 'Proof Number',
                                        validator: (value) =>
                                            guardianProofCode == "131"
                                                ? validatePanCard(value)
                                                : validateName(
                                                    value,
                                                    gProofType.text.isEmpty
                                                        ? 'Proof Number'
                                                        : gProofType.text,
                                                    guardianProofCode == "133"
                                                        ? 12
                                                        : guardianProofCode ==
                                                                "134"
                                                            ? 16
                                                            : 4),
                                        inputFormatters: guardianProofCode ==
                                                "131"
                                            ? [
                                                LengthLimitingTextInputFormatter(
                                                    10),
                                                UpperCaseTextFormatter(),
                                                FilteringTextInputFormatter
                                                    .allow(
                                                        RegExp(r'[a-zA-Z0-9]')),
                                              ]
                                            : [
                                                LengthLimitingTextInputFormatter(
                                                    guardianProofCode == "133"
                                                        ? 12
                                                        : guardianProofCode ==
                                                                "134"
                                                            ? 16
                                                            : 50),
                                                FilteringTextInputFormatter
                                                    .allow(
                                                        RegExp(r'[a-zA-Z0-9]'))
                                              ]),
                                  ),
                                  if (guardianIssueDateIsManitory) ...[
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 4,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: customFormField(
                                                formValidateNodifier:
                                                    formValidateNodifier,
                                                readOnly: true,
                                                controller:
                                                    guardianPOIIssueDateController,
                                                labelText:
                                                    !guardianIssueDateIsManitory
                                                        ? "Date of issue@"
                                                        : "Date of issue",
                                                validator: (value) =>
                                                    !guardianIssueDateIsManitory
                                                        ? nullValidation(value)
                                                        : validateNotNull(value,
                                                            "Date of issue"),
                                                onTap: () async {
                                                  datePick(
                                                      func: (DateTime? date) {
                                                        if (date != null &&
                                                            guardianPOIIssueDate !=
                                                                date) {
                                                          guardianPOIIssueDate =
                                                              date;
                                                          guardianPOIIssueDateController
                                                                  .text =
                                                              "${date.toString().substring(8, 10)}/${date.toString().substring(5, 7)}/${date.toString().substring(0, 4)}";
                                                        }
                                                      },
                                                      pickedDate:
                                                          guardianPOIIssueDate);
                                                },
                                              ),
                                            )),
                                        const Expanded(
                                            flex: 1, child: SizedBox()),
                                        Expanded(
                                            flex: 4,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: customFormField(
                                                  formValidateNodifier:
                                                      formValidateNodifier,
                                                  controller:
                                                      guardianPOIPlaceOfIssueController,
                                                  labelText:
                                                      !guardianIssueDateIsManitory
                                                          ? "Place of issue@"
                                                          : "Place of issue",
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(
                                                            RegExp(r'[a-zA-Z]'))
                                                  ],
                                                  validator: (value) =>
                                                      !guardianIssueDateIsManitory
                                                          ? nullValidation(
                                                              value)
                                                          : validatePlace(
                                                              value)),
                                            )),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: customFormField(
                                        formValidateNodifier:
                                            formValidateNodifier,
                                        readOnly: true,
                                        controller:
                                            guardianPOIExpireDateController,
                                        labelText: "Expiry Date",
                                        validator: (value) =>
                                            !guardianIssueDateIsManitory
                                                ? nullValidation(value)
                                                : validateNotNull(
                                                    value, "Expiry Date"),
                                        onTap: () async {
                                          datePick(
                                              func: (DateTime? date) {
                                                if (date != null &&
                                                    guardianPOIExpireDate !=
                                                        date) {
                                                  guardianPOIExpireDate = date;
                                                  guardianPOIExpireDateController
                                                          .text =
                                                      "${date.toString().substring(8, 10)}/${date.toString().substring(5, 7)}/${date.toString().substring(0, 4)}";
                                                }
                                              },
                                              pickedDate: guardianPOIExpireDate,
                                              isExpiryDate: true);
                                        },
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: customFormField(
                                      onTap: () {
                                        pickFileBottomSheet(
                                            context,
                                            (path, docId) =>
                                                filePick(false, path, docId),
                                            "",
                                            "Guadian Proof ${widget.nom.split("").last}");
                                      },
                                      controller: gFile,
                                      labelText: 'Proof of Guardian',
                                      readOnly: true,
                                      hintText: 'Upload',
                                      prefixIcon: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(width: 10.0),
                                            SvgPicture.asset(
                                              "assets/images/attachment.svg",
                                              width: 22.0,
                                            ),
                                            const SizedBox(width: 10.0),
                                          ]),
                                      suffixIcon: guarFile != null ||
                                              gurdianFileDetails != null
                                          ? IconButton(
                                              onPressed: () {
                                                if (guarFile != null) {
                                                  Navigator.pushNamed(
                                                      context,
                                                      (guarFile?.path.endsWith(
                                                                  ".pdf") ??
                                                              false)
                                                          ? route.previewPdf
                                                          : route.previewImage,
                                                      arguments: {
                                                        "title":
                                                            "${widget.nom.replaceAll(" ", "")}GuradianProof",
                                                        "data": guarFile!
                                                            .readAsBytesSync(),
                                                        "fileName": gFile.text
                                                      });
                                                } else {
                                                  Navigator.pushNamed(
                                                      context,
                                                      gurdianFileDetails![0]
                                                              .toString()
                                                              .endsWith(".pdf")
                                                          ? route.previewPdf
                                                          : route.previewImage,
                                                      arguments: {
                                                        "title":
                                                            "${widget.nom.replaceAll(" ", "")}GuradianProof",
                                                        "data":
                                                            gurdianFileDetails![
                                                                1],
                                                        "fileName":
                                                            gurdianFileDetails![
                                                                0]
                                                      });
                                                }
                                              },
                                              icon: Icon(
                                                Icons.preview,
                                                color: const Color.fromARGB(
                                                    255, 99, 97, 97),
                                              ))
                                          : null,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "File format should be (*.jpg,*.jpeg,*.png,*.pdf) and file size should be less than 5MB",
                                  ),
                                ],
                              ));
                        }),
                  ],
                ),
              ],
            ),
          ),
        ]);
  }
}
