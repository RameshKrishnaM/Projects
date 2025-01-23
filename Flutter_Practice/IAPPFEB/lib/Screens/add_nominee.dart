import 'dart:io';
import 'package:ekyc/Cookies/cookies.dart';
import 'package:ekyc/Screens/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../Custom%20Widgets/StepWidget.dart';
import '../Custom Widgets/file_upload_bottomsheet.dart';
import '../Custom%20Widgets/scrollable_widget.dart';
import '../provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';

import '../API call/api_call.dart';
import '../Custom Widgets/bsheetheader.dart';
import '../Custom Widgets/custom_button.dart';
import '../Custom Widgets/custom_drop_down.dart';
import '../Custom Widgets/custom_form_field.dart';
import '../Custom Widgets/date_picker_form_field.dart';
import '../Model/getfromdata_modal.dart';
import '../Nodifier/nodifierCLass.dart';
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
  List<dynamic>? Nomineerelation = [];
  List<dynamic>? gaurdianrelation = [];
  bool Gvisible = false;
  final _formKey = GlobalKey<FormState>();
  // final _formKey1 = GlobalKey<FormState>();
  // final _formKey2 = GlobalKey<FormState>();
  TextEditingController nNameTitle = TextEditingController();
  TextEditingController NproofType = TextEditingController();
  TextEditingController Nproofnumber = TextEditingController();
  TextEditingController Nfile = TextEditingController();
  TextEditingController Nname = TextEditingController();
  TextEditingController Nstate = TextEditingController();
  TextEditingController Ncountry = TextEditingController();
  TextEditingController Ncity = TextEditingController();
  TextEditingController adressline3 = TextEditingController();
  TextEditingController adressline2 = TextEditingController();
  TextEditingController adressline1 = TextEditingController();
  TextEditingController Npin = TextEditingController();
  TextEditingController percentofshare = TextEditingController();
  TextEditingController Nrelationvalue = TextEditingController();
  TextEditingController Nmail = TextEditingController();
  TextEditingController Nmobile = TextEditingController();
  // CheckBoxValueNodifier checkBoxValueNodifier = CheckBoxValueNodifier(false);
  bool sameAsClientAddress = true;
  File? nomineefile;
  List nomineeFiles = [];
  List gardientFiles = [];
  TextEditingController gNameTitle = TextEditingController();
  TextEditingController GproofType = TextEditingController();
  TextEditingController Gproofnumber = TextEditingController();
  TextEditingController Gfile = TextEditingController();
  TextEditingController Gname = TextEditingController();
  TextEditingController Gstate = TextEditingController();
  TextEditingController Gcountry = TextEditingController();
  TextEditingController Gcity = TextEditingController();
  TextEditingController Gadressline3 = TextEditingController();
  TextEditingController Gadressline2 = TextEditingController();
  TextEditingController Gadressline1 = TextEditingController();
  TextEditingController Gpin = TextEditingController();

  TextEditingController Grelationvalue = TextEditingController();
  TextEditingController Gmail = TextEditingController();
  TextEditingController Gmobile = TextEditingController();
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
  // CheckBoxValueNodifier checkBoxValueNodifier2 = CheckBoxValueNodifier(false);
  bool guardianAddressSameAsNomineeAddress = true;
  File? Guarfile;
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

  /*  getfomrdetails() async {
    var response = await post('getData', '', context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['status'] == "S") {
        // print(json["nominee"] != null && json["nominee"].isNotEmpty);
        // if (json["nominee"] != null && json["nominee"].isNotEmpty) {
        //   print("hhhh");
        //   Navigator.pushNamed(context, route.nomineeDashboard);
        // }
        // postdata = json['nominee'];
        // print(json['nominee']);
        getlength = json['nominee']!.length;
        // print(getlength);
        var formdata = getfromdataModalFromJson(response.body);

        if (widget.nom == "Nominee 1") {
          var n1 = formdata.nominee[0];
          id = n1.nomineeID;
          Nproofnumber.text = n1.nomineeProofNumber;
          Nname.text = n1.nomineeName;
          datechange.value = DateTime.parse(n1.nomineeDob);

          List relationShip = Nomineerelation!
              .where((e) => e['code'] == n1.nomineeRelationship.split(",")[1])
              .toList();
          Nrelationvalue.text = relationShip.isNotEmpty
              ? relationShip[0]['description'].toString()
              : "";
          Nmobile.text = n1.nomineeMobileNo;
          Nmail.text = n1.nomineeEmailId;
          List poi = poidropdown!
              .where(
                  (e) => e['code'] == n1.nomineeProofOfIdentity.split(",")[1])
              .toList();
          Nproofvalue.text =
              poi.isNotEmpty ? poi[0]['description'].toString() : "";
          Nfile.text = n1.noimineeFileName;
          Gvisible = n1.guardianVisible; //.toLowerCase() == 'true'
          adressline1.text = n1.nomineeAddress1;
          adressline2.text = n1.nomineeAddress2;
          adressline3.text = n1.nomineeAddress3;
          Npin.text = n1.nomineePincode;
          Ncity.text = n1.nomineeCity;
          Nstate.text = n1.nomineeState;
          Ncountry.text = n1.nomineeCountry;
          Gproofnumber.text = n1.guardianProofNumber;

          Gname.text = n1.guardianName;
          List gaudianValue = gaurdianrelation!
              .where((e) => e['code'] == n1.guardianRelationship.split(",")[1])
              .toList();
          Grelationvalue.text = gaudianValue.isNotEmpty
              ? gaudianValue[0]['description'].toString()
              : "";

          Gmobile.text = n1.guardianMobileNo;
          Gmail.text = n1.guardianMobileNo;
          List proofValue = poidropdown!
              .where(
                  (e) => e['code'] == n1.guardianProofOfIdentity.split(",")[1])
              .toList();
          Gproofvalue.text = proofValue.isNotEmpty
              ? proofValue[0]['description'].toString()
              : "";
          Gfile.text = n1.guardianFileName;
          Gadressline1.text = n1.guardianAddress1;
          Gadressline2.text = n1.guardianAddress2;
          Gadressline3.text = n1.guardianAddress3;
          Gpin.text = n1.guardianPincode;
          Gcity.text = n1.guardianCity;
          Gstate.text = n1.guardianState;
          Gcountry.text = n1.guardianCountry;
          percentofshare.text = n1.nomineeShare;
        }

        if (formdata.nominee.length > 1 && widget.nom == 'Nominee 2') {
          var n2 = formdata.nominee[1];
          Nproofnumber.text = n2.nomineeProofNumber;
          Nname.text = n2.nomineeName;
          datechange.value = DateTime.parse(n2.nomineeDob);
          Nrelationvalue.text = n2.nomineeRelationship == "" ||
                  n2.nomineeRelationship == ","
              ? ""
              : Nomineerelation!
                  .where(
                      (e) => e['code'] == n2.nomineeRelationship.split(",")[1])
                  .toList()[0]['description']
                  .toString();
          Nmobile.text = n2.nomineeMobileNo;
          Nmail.text = n2.nomineeEmailId;
          Nproofvalue.text = n2.nomineeProofOfIdentity == "" ||
                  n2.nomineeProofOfIdentity == ","
              ? ""
              : poidropdown!
                  .where((e) =>
                      e['code'] == n2.nomineeProofOfIdentity.split(",")[1])
                  .toList()[0]['description']
                  .toString();
          Nfile.text = n2.noimineeFileName;
          Gvisible = n2.guardianVisible; //.toLowerCase() == 'true';
          adressline1.text = n2.nomineeAddress1;
          adressline2.text = n2.nomineeAddress2;
          adressline3.text = n2.nomineeAddress3;
          Npin.text = n2.nomineePincode;
          Ncity.text = n2.nomineeCity;
          Nstate.text = n2.nomineeState;
          checkBoxValueNodifier.changeValue(n2.guardianVisible);
          Gproofnumber.text = n2.guardianProofNumber;
          Gname.text = n2.guardianName;
          Grelationvalue.text = n2.guardianRelationship == "" ||
                  n2.guardianRelationship == ","
              ? ""
              : gaurdianrelation!
                  .where(
                      (e) => e['code'] == n2.guardianRelationship.split(",")[1])
                  .toList()[0]['description']
                  .toString();

          Gmobile.text = n2.guardianMobileNo;
          Gmail.text = n2.guardianMobileNo;
          Gproofvalue.text = n2.guardianProofOfIdentity == "" ||
                  n2.guardianProofOfIdentity == ","
              ? ""
              : poidropdown!
                  .where((e) =>
                      e['code'] == n2.guardianProofOfIdentity.split(",")[1])
                  .toList()[0]['description']
                  .toString();
          Gfile.text = n2.guardianFileName;
          Gadressline1.text = n2.guardianAddress1;
          Gadressline2.text = n2.guardianAddress2;
          Gadressline3.text = n2.guardianAddress3;
          Gpin.text = n2.guardianPincode;
          Gcity.text = n2.guardianCity;
          Gstate.text = n2.guardianState;
          percentofshare.text = n2.nomineeShare;
        }
        if (formdata.nominee.length > 1 && widget.nom == 'Nominee 3') {
          var n3 = formdata.nominee[3];
          Nproofnumber.text = n3.nomineeProofNumber;
          percentofshare.text = n3.nomineeShare;
          Nname.text = n3.nomineeName;
          datechange.value = DateTime.parse(n3.nomineeDob);

          Nrelationvalue.text = n3.nomineeRelationship == "" ||
                  n3.nomineeRelationship == ","
              ? ""
              : Nomineerelation!
                  .where(
                      (e) => e['code'] == n3.nomineeRelationship.split(",")[1])
                  .toList()[0]['description']
                  .toString();
          Nmobile.text = n3.nomineeMobileNo;
          Nmail.text = n3.nomineeEmailId;
          Nproofvalue.text = n3.nomineeProofOfIdentity == "" ||
                  n3.nomineeProofOfIdentity == ","
              ? ""
              : poidropdown!
                  .where((e) =>
                      e['code'] == n3.nomineeProofOfIdentity.split(",")[1])
                  .toList()[0]['description']
                  .toString();
          Nfile.text = n3.noimineeFileName;
          Gvisible = n3.guardianVisible; //.toLowerCase() == 'true';
          adressline1.text = n3.nomineeAddress1;
          adressline2.text = n3.nomineeAddress2;
          adressline3.text = n3.nomineeAddress3;
          Npin.text = n3.nomineePincode;
          Ncity.text = n3.nomineeCity;
          Nstate.text = n3.nomineeState;
          checkBoxValueNodifier.changeValue(n3.guardianVisible);
          Gproofnumber.text = n3.guardianProofNumber;
          Gname.text = n3.guardianName;
          Grelationvalue.text = n3.guardianRelationship == "" ||
                  n3.guardianRelationship == ","
              ? ""
              : gaurdianrelation!
                  .where(
                      (e) => e['code'] == n3.guardianRelationship.split(",")[1])
                  .toList()[0]['description']
                  .toString();
          Gmobile.text = n3.guardianMobileNo;
          Gmail.text = n3.guardianMobileNo;
          Gproofvalue.text = n3.guardianProofOfIdentity == "" ||
                  n3.guardianProofOfIdentity == ","
              ? ""
              : poidropdown!
                  .where((e) =>
                      e['code'] == n3.guardianProofOfIdentity.split(",")[1])
                  .toList()[0]['description']
                  .toString();
          Gfile.text = n3.guardianFileName;
          Gadressline1.text = n3.guardianAddress1;
          Gadressline2.text = n3.guardianAddress2;
          Gadressline3.text = n3.guardianAddress3;
          Gpin.text = n3.guardianPincode;
          Gcity.text = n3.guardianCity;
          Gstate.text = n3.guardianState;
        }
      }
    }
    agecheck(DateChange()..onchange(datechange.value ?? DateTime(1990)));
    setState(() {});

    isloading = true;
  } */

  nameTitleDropDown() async {
    loadingAlertBox(context);
    Map? data = await getDropDownValues(context: context, code: "client title");
    if (data != null) {
      List Actualdata = data["lookupvaluearr"];
      // adressproof = Actualdata.map((e) => e['description']).toList();
      nameTitledropdown = Actualdata;
    }
    // print("same as nominee $sameAsClientAddress");
    adressdropdown();
  }

  adressdropdown() async {
    Map? data =
        await getDropDownValues(context: context, code: "Proof of Identity");
    if (data != null) {
      List? Actualdata = data["lookupvaluearr"];
      // adressproof = Actualdata.map((e) => e['description']).toList();
      poidropdown = Actualdata ?? [];
    }
    nomrelationdropdown();
  }

  nomrelationdropdown() async {
    Map? data =
        await getDropDownValues(context: context, code: "Nominee Relationship");
    if (data != null) {
      List? Actualdata = data["lookupvaluearr"];
      // Nomineerelation = Actualdata.map((e) => e['description']).toList();
      Nomineerelation = Actualdata ?? [];
    }

    guarnomrelationdropdown();
  }

  guarnomrelationdropdown() async {
    Map? data = await getDropDownValues(
        context: context, code: "nomineeGuardianRelationship");
    if (data != null) {
      List Actualdata = data["lookupvaluearr"];
      // gaurelation = Actualdata.map((e) => e['description']).toList();
      gaurdianrelation = Actualdata;
    }
    getClientAddress();

    // setState(() {});

    // isloading = true;
  }

  Map clientAddress = {};

  getClientAddress() async {
    var response = await getClientAddressInAPI(context: context);
    if (response != null) {
      clientAddress = response;
    }

    insertNomineeDetails();
  }

  insertNomineeDetails() async {
    // getlength = Provider.of<Postmap>(context, listen: false).response.length;
    Postmap postMap = Provider.of<Postmap>(context, listen: false);
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
    Nname.text = n1.nomineeName;
    dob.value = DateTime.tryParse(
        "${n1.nomineeDob.substring(6, 10)}-${n1.nomineeDob.substring(3, 5)}-${n1.nomineeDob.substring(0, 2)}");
    agecheck(dob);
    percentofshare.text = n1.nomineeShare;
    List relationShip = Nomineerelation!
        .where((e) => e['code'] == n1.nomineeRelationship)
        .toList();
    Nrelationvalue.text = relationShip.isNotEmpty
        ? relationShip[0]['description'].toString()
        : "";
    Nmobile.text = n1.nomineeMobileNo;
    Nmail.text = n1.nomineeEmailId;
    List poi = poidropdown!
        .where((e) => e['code'] == n1.nomineeProofOfIdentity)
        .toList();
    nomineeProofCode = n1.nomineeProofOfIdentity;
    NproofType.text = poi.isNotEmpty ? poi[0]['description'].toString() : "";
    Nfile.text = n1.noimineeFileName;
    Gvisible = n1.guardianVisible; //.toLowerCase() == 'true'
    adressline1.text = n1.nomineeAddress1;
    adressline2.text = n1.nomineeAddress2;
    adressline3.text = n1.nomineeAddress3;
    Npin.text = n1.nomineePincode;
    Ncity.text = n1.nomineeCity;
    Nstate.text = n1.nomineeState;
    Ncountry.text = n1.nomineeCountry;
    nomineeFileName = n1.noimineeFileString;
    Nproofnumber.text = n1.nomineeProofNumber;
    nomineePOIIssueDateController.text = n1.nomineeproofdateofissue;
    nomineePOIPlaceOfIssueController.text = n1.nomineeplaceofissue;
    nomineePOIExpireDateController.text = n1.nomineeproofexpriydate;
    Gname.text = n1.guardianName;
    gNameTitle.text = nameTitledropdown!.firstWhere(
        (element) => element["code"] == n1.guardianTitle,
        orElse: () => {"description": ""})["description"];
    List gaudianValue = gaurdianrelation!
        .where((e) => e['code'] == n1.guardianRelationship)
        .toList();
    Grelationvalue.text = gaudianValue.isNotEmpty
        ? gaudianValue[0]['description'].toString()
        : "";

    Gmobile.text = n1.guardianMobileNo;
    Gmail.text = n1.guardianEmailId;
    List proofValue = poidropdown!
        .where((e) => e['code'] == n1.guardianProofOfIdentity)
        .toList();
    guardianProofCode = n1.guardianProofOfIdentity;
    GproofType.text =
        proofValue.isNotEmpty ? proofValue[0]['description'].toString() : "";
    Gfile.text = n1.guardianFileName;
    Gadressline1.text = n1.guardianAddress1;
    Gadressline2.text = n1.guardianAddress2;
    Gadressline3.text = n1.guardianAddress3;
    Gpin.text = n1.guardianPincode;
    Gcity.text = n1.guardianCity;
    Gstate.text = n1.guardianState;
    Gcountry.text = n1.guardianCountry;
    Gproofnumber.text = n1.guardianProofNumber;
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
    nomineeFileDetails != null ? Nfile.text = "File Uploaded" : null;
    gurdianFileDetails != null ? Gfile.text = "File Uploaded" : null;
    // print("nominee file ${n1.nomineeFileUploadDocIds}");
    // print("guardian file ${n1.guardianFileUploadDocIds}");
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
    Guarfile = postMap.getFile(widget.nom, false);
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
          Ncity.text = json["resp"]['city'];
          Nstate.text = json["resp"]['state'];
          Ncountry.text = 'india';
        } else {
          Gcity.text = json["resp"]['city'];
          Gstate.text = json["resp"]['state'];
          Gcountry.text = 'india';
        }

        // return response;
      }
    }
  }

  int age = 20;
  DateTime? selectedDate;
  agecheck(DateChange dc) {
    // print("age");
    // print(dc.value);

    selectedDate = dc.value;
    dob.onchange(selectedDate ?? DateTime.now());
    if (dc.value == null) return;
    // print(dc.value);
    age = DateTime.now().year - selectedDate!.year;

    if (DateTime.now().month < selectedDate!.month ||
        (DateTime.now().month == selectedDate!.month &&
            DateTime.now().day < selectedDate!.day)) {
      age--;
    }
    // print(age);
    if (mounted) {
      setState(() {});
    }
    // print('${age}');
  }

  nomineeAddresschangeToClientAddress() {
    adressline1.text = clientAddress["address1"] ?? "";
    adressline2.text = clientAddress["address2"] ?? "";
    adressline3.text = clientAddress["address3"] ?? "";
    Npin.text = clientAddress["pincode"] ?? "";
    Ncity.text = clientAddress["city"] ?? "";
    Nstate.text = clientAddress["state"] ?? "";
    Ncountry.text = "India";
  }

  guardianAddresschangeToClientAddress() {
    Gadressline1.text = clientAddress["address1"] ?? "";
    Gadressline2.text = clientAddress["address2"] ?? "";
    Gadressline3.text = clientAddress["address3"] ?? "";
    Gpin.text = clientAddress["pincode"] ?? "";
    Gcity.text = clientAddress["city"] ?? "";
    Gstate.text = clientAddress["state"] ?? "";
    Gcountry.text = "India";
  }

  guardianAddresschangeToNomineeAddress() {
    if (!guardianAddressSameAsNomineeAddress) return;
    Gadressline1.text = adressline1.text;
    Gadressline2.text = adressline2.text;
    Gadressline3.text = adressline3.text;
    Gpin.text = Npin.text;
    Gcity.text = Ncity.text;
    Gstate.text = Nstate.text;
    Gcountry.text = "India";
  }

  checkNomineeAddressSameAsClinet(value) {
    // print("nominnee $sameAsClientAddress");
    if (!sameAsClientAddress) return;
    if (adressline1.text == clientAddress["address1"] &&
        adressline2.text == clientAddress["address2"] &&
        adressline3.text == clientAddress["address3"] &&
        Npin.text == clientAddress["pincode"]) {
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
    if (Gadressline1.text == adressline1.text &&
        Gadressline2.text == adressline2.text &&
        Gadressline3.text == adressline3.text &&
        Gpin.text == Npin.text) {
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

    // insertNomineeDetails();
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
      Nfile.text = l[l.length - 1];
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
      Gfile.text = l[l.length - 1];
      Guarfile = file;
      gardianFileName = getFileTime(
          3,
          widget.nom == "Nominee 1"
              ? 1
              : widget.nom == "Nominee 2"
                  ? 2
                  : 3);
      guardianDocId = docId;
    }
    // setState(() {});
  }

  addNomineeDetailsInProvider() {
    Postmap postmap = Provider.of<Postmap>(context, listen: false);

    Map<String, dynamic> m = {
      "NomineeID": id,
      "nomineename": Nname.text,
      "nomineetitle": nNameTitle.text,
      "nomineerelationship": Nomineerelation!
          .where((e) => e['description'] == Nrelationvalue.text)
          .toList()[0]['code']
          .toString(),
      "nomineerelationshipdesc": Nrelationvalue.text,
      "nomineeshare": percentofshare.text,
      "nomineedob":
          "${dob.value.toString().substring(8, 10)}/${dob.value.toString().substring(5, 7)}/${dob.value.toString().substring(0, 4)}",
      "nomineeaddress1": adressline1.text,
      "nomineeaddress2": adressline2.text,
      "nomineeaddress3": adressline3.text,
      "nomineecity": Ncity.text,
      "nomineestate": Nstate.text,
      "nomineecountry": "India",
      "nomineepincode": Npin.text,
      "nomineemobileno": Nmobile.text,
      "nomineeemailid": Nmail.text,
      "nomineeproofofidentity": NproofType.text == ""
          ? ""
          : poidropdown!
              .where((e) => e['description'] == NproofType.text)
              .toList()[0]['code']
              .toString(),
      "nomineeproofofidentitydesc": NproofType.text,
      "nomineeproofnumber": Nproofnumber.text,
      "nomineeplaceofissue": nomineePOIPlaceOfIssueController.text,
      "nomineeproofdateofissue": nomineePOIIssueDateController.text,
      "nomineeproofexpriydate":
          nomineeIssueDateIsManitory ? nomineePOIExpireDateController.text : "",
      // "NomineeFileUploads": nomineeFiles,
      "nomineefilestring": nomineeFileName,
      "nomineefilename": Nfile.text,
      "nomineefilepath": " ",
      "nomineefileuploaddocids":
          //  nomineefile != null ? "" :
          nomineeDocId,
      "guardianvisible": age >= 18 ? false : true,
      "guardianname": age >= 18 ? "" : Gname.text,
      "guardiantitle": age >= 18 ? "" : gNameTitle.text,
      "guardianrelationship": Grelationvalue.text == "" || age >= 18
          ? ""
          : gaurdianrelation!
              .where((e) => e['description'] == Grelationvalue.text)
              .toList()[0]['code']
              .toString(),
      "guardianrelationshipdesc": age >= 18 ? "" : Grelationvalue.text,
      "guardianaddress1": age >= 18 ? "" : Gadressline1.text,
      "guardianaddress2": age >= 18 ? "" : Gadressline2.text,
      "guardianaddress3": age >= 18 ? "" : Gadressline3.text,
      "guardiancity": age >= 18 ? "" : Gcity.text,
      "guardianstate": age >= 18 ? "" : Gstate.text,
      "guardiancountry": age >= 18 ? "" : "India",
      "guardianpincode": age >= 18 ? "" : Gpin.text,
      "guardianmobileno": age >= 18 ? "" : Gmobile.text,
      "guardianemailid": age >= 18 ? "" : Gmail.text,
      "guardianproofofidentity": GproofType.text == "" || age >= 18
          ? ""
          : poidropdown!
              .where((e) => e['description'] == GproofType.text)
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
      "guardianproofofidentitydesc": age >= 18 ? "" : GproofType.text,
      "guardianproofnumber": age >= 18 ? "" : Gproofnumber.text,
      // "GuardianFileUploads": gardientFiles,
      "guardianfilestring": age >= 18 ? "" : gardianFileName,
      "guardianfilename": age >= 18 ? "" : Gfile.text,
      "guardianfilepath": "",
      "guardianfileuploaddocids":
          //  Guarfile != null ? "" :
          guardianDocId,
      "ModelState": ((getlength >= 1 && widget.nom == "Nominee 1") ||
              (getlength >= 2 && widget.nom == "Nominee 2") ||
              (getlength == 3 && widget.nom == "Nominee 3"))
          ? widget.nomineeDetails == null ||
                  widget.nomineeDetails!["ModelState"] == "added"
              ? "added"
              : "modified"
          : "added"
    };

    // switch (widget.nom) {
    //   case "Nominee 1":
    //     getlength >= 1 ? postmap.response[0] = m : postmap.response.add(m);

    //     break;
    //   case "Nominee 2":
    //     getlength >= 2 ? postmap.response[1] = m : postmap.response.add(m);
    //     break;
    //   case "Nominee 3":
    //     getlength >= 3 ? postmap.response[2] = m : postmap.response.add(m);
    //     break;
    //   default:
    // }
    // List<Map<String, dynamic>> finalNomineesDetails = postmap.response
    //     .where((nominee) => nominee["ModelState"] != "deleted")
    //     .toList();
    // finalNomineesDetails.addAll(nomineesDetails);
    // postmap.changeResponse(finalNomineesDetails);

    int position = int.parse(widget.nom.substring(widget.nom.length - 1));
    int index = postmap.response.indexOf(widget.nomineeDetails ?? {});
    getlength >= position && index != -1
        ? postmap.response[index] = m
        : postmap.response.add(m);
    postmap.changeResponse(postmap.response);
    postmap.changenFile(widget.nom, nomineefile, nomineeFileName, true);
    postmap.changenFile(widget.nom, Guarfile, gardianFileName, false);
  }

  // continueFunc() async {
  //   Map m = {
  //     "NomineeID": 0,
  //     "NomineeName": Nname.text,
  //     "NomineeRelationship": Nomineerelation!
  //         .where((e) => e['description'] == Nrelationvalue.text)
  //         .toList()[0]['code']
  //         .toString(),
  //     "NomineeRelationshipdesc": Nrelationvalue.text,
  //     "NomineeShare": percentofshare.text,
  //     "NomineeDOB": "${datechange.value.toString().substring(0, 10)}",
  //     "NomineeAddress1": adressline1.text,
  //     "NomineeAddress2": adressline2.text,
  //     "NomineeAddress3": adressline3.text,
  //     "NomineeCity": Ncity.text,
  //     "NomineeState": Nstate.text,
  //     "NomineeCountry": "India",
  //     "NomineePincode": Npin.text,
  //     "NomineeMobileNo": Nmobile.text,
  //     "NomineeEmailId": Nmail.text,
  //     "NomineeProofOfIdentity": poidropdown!
  //         .where((e) => e['description'] == Nproofvalue.text)
  //         .toList()[0]['code']
  //         .toString(),
  //     "NomineeProofOfIdentitydesc": Nproofvalue.text,
  //     "NomineeProofNumber": Nproofnumber.text,
  //     "NomineeFileUploads": nomineeFiles,
  //     "NoimineeFileString": "3412036420048",
  //     "NoimineeFileName": Nfile.text,
  //     "NoimineeFilePath": " ",
  //     "NomineeFileUploadDocIds": " ",
  //     "GuardianVisible": age >= 18 ? false : true,
  //     "GuardianName": Gname.text,
  //     "GuardianRelationship": Grelationvalue.text == ""
  //         ? ""
  //         : gaurdianrelation!
  //             .where((e) => e['description'] == Grelationvalue.text)
  //             .toList()[0]['code']
  //             .toString(),
  //     "GuardianRelationshipdesc": Grelationvalue.text,
  //     "GuardianAddress1": Gadressline1.text,
  //     "GuardianAddress2": Gadressline2.text,
  //     "GuardianAddress3": Gadressline3.text,
  //     "GuardianCity": Gcity.text,
  //     "GuardianState": Gstate.text,
  //     "GuardianCountry": " India",
  //     "GuardianPincode": Gpin.text,
  //     "GuardianMobileNo": Gmobile.text,
  //     "GuardianEmailId": Gmail.text,
  //     "GuardianProofOfIdentity": Gproofvalue.text == ""
  //         ? ""
  //         : poidropdown!
  //             .where((e) => e['description'] == Gproofvalue.text)
  //             .toList()[0]['code']
  //             .toString(),
  //     "GuardianProofNumber": Gproofnumber.text,
  //     "GuardianFileUploads": gardientFiles,
  //     "GuardianFileString": "10236109260144",
  //     "GuardianFileName": Gfile.text,
  //     "GuardianFilePath": " ",
  //     "GuardianFileUploadDocIds": " ",
  //     "ModelState": ((getlength >= 1 && widget.nom == "Nominee 1") ||
  //             (getlength >= 2 && widget.nom == "Nominee 2") ||
  //             (getlength == 3 && widget.nom == "Nominee 3"))
  //         ? 'modified'
  //         : "added",
  //   };
  // Provider.of<Postmap>(context, listen: false).addmap(m);
  // var response = await addNomineeAPI(
  //     context: context,
  //     deleteIds: [],
  //     inputJsonData: Provider.of<Postmap>(context, listen: false).response);
  // if (response != null) {
  //   Navigator.pushNamed(context, route.bankScreen);
  //   Provider.of<Postmap>(context, listen: false).changeResponse([]);
  //   }
  // }
  bool ifFormValidateIsTriggered = false;
  formVaidate(value) {
    if (Nname.text != "" &&
        nNameTitle.text != "" &&
        dob.value != null &&
        Nrelationvalue.text != "" &&
        percentofshare.text != "" &&
        (age < 18 ||
            (Nmobile.text != "" &&
                Nmail.text != "" &&
                adressline2.text != "" &&
                NproofType.text != "" &&
                Nproofnumber.text != "" &&
                (!nomineeIssueDateIsManitory ||
                    (nomineePOIPlaceOfIssueController.text != "" &&
                        nomineePOIIssueDateController.text != "" &&
                        nomineePOIExpireDateController.text.isNotEmpty)) &&
                Nfile.text != "")) &&
        // (sameAsClientAddress ||
        //     (
        adressline1.text != "" &&
        Npin.text != "" &&
        Nstate.text != "" &&
        Ncity.text != "" &&
        Ncountry.text != ""
        // ))
        &&
        (age >= 18 ||
            (Gname.text != "" &&
                gNameTitle.text != "" &&
                Grelationvalue.text != "" &&
                Gmobile.text != "" &&
                Gmail.text != "" &&
                // (guardianAddressSameAsNomineeAddress ||
                //     (
                Gadressline1.text != "" &&
                Gadressline2.text != "" &&
                Gpin.text != "" &&
                Gstate.text != "" &&
                Gcity.text != "" &&
                Gcountry.text != ""
                // ))
                &&
                GproofType.text != "" &&
                Gproofnumber.text != "" &&
                (!guardianIssueDateIsManitory ||
                    (guardianPOIPlaceOfIssueController.text != "" &&
                        guardianPOIIssueDateController.text != "" &&
                        guardianPOIExpireDateController.text.isNotEmpty)) &&
                Gfile.text != ""))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ifFormValidateIsTriggered = true;
        if (_formKey.currentState?.validate() ?? false) {
          // bool validateNomineeProof =
          //     _formKey1.currentState?.validate() ?? false;
          // bool validateGuardianProof =
          //     age >= 18 || (_formKey2.currentState?.validate() ?? false);
          // isFormValid = validateNomineeProof && validateGuardianProof;
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

    // if ((_formKey.currentState?.validate() ?? false) &&
    //     Nproofvalue.text != "" &&
    //     (age > 18 || (Grelationvalue.text != "" && Gproofvalue.text != ""))) {
    //   return true;
    // } else {
    //   return false;
    // }
  }

  // addNextNominee() {
  //   if (widget.nom == 'Nominee 1') {
  //     Navigator.pushNamed(context, route.nominee, arguments: "Nominee 2");

  //     Map m = {
  //       "ModelState": getlength >= 1 ? 'modified' : "added",
  //       "NomineeID": id ?? 0,
  //       "NomineeName": Nname.text,
  //       "NomineeRelationship": Nomineerelation!
  //           .where((e) => e['description'] == Nrelationvalue.text)
  //           .toList()[0]['code']
  //           .toString(),
  //       "NomineeRelationshipdesc": Nrelationvalue.text,
  //       "NomineeShare": percentofshare.text,
  //       "NomineeDOB": "${datechange.value.toString().substring(0, 10)}",
  //       "NomineeAddress1": adressline1.text,
  //       "NomineeAddress2": adressline2.text,
  //       "NomineeAddress3": adressline3.text,
  //       "NomineeCity": Ncity.text,
  //       "NomineeState": Nstate.text,
  //       "NomineeCountry": "India",
  //       "NomineePincode": Npin.text,
  //       "NomineeMobileNo": Nmobile.text,
  //       "NomineeEmailId": Nmail.text,
  //       "NomineeProofOfIdentity": "",
  //       "NomineeProofOfIdentitydesc": Nproofvalue.text,
  //       "NomineeProofNumber": Nproofnumber.text,
  //       "NomineeFileUploads": nomineeFiles,
  //       "NoimineeFileString": " ",
  //       "NoimineeFileName": " ",
  //       "NoimineeFilePath": " ",
  //       "NomineeFileUploadDocIds": " ",
  //       "GuardianVisible": age >= 18 ? false : true,
  //       "GuardianName": Gname.text,
  //       "GuardianRelationship": Grelationvalue.text == ""
  //           ? ""
  //           : gaurdianrelation!
  //               .where((e) => e['description'] == Grelationvalue.text)
  //               .toList()[0]['code']
  //               .toString(),
  //       "GuardianRelationshipdesc": Grelationvalue.text,
  //       "GuardianAddress1": Gadressline1.text,
  //       "GuardianAddress2": Gadressline2.text,
  //       "GuardianAddress3": Gadressline3.text,
  //       "GuardianCity": Gcity.text,
  //       "GuardianState": Gstate.text,
  //       "GuardianCountry": " India",
  //       "GuardianPincode": Gpin.text,
  //       "GuardianMobileNo": Gmobile.text,
  //       "GuardianEmailId": Gmail.text,
  //       "GuardianProofOfIdentity": Gproofvalue.text == ""
  //           ? ""
  //           : poidropdown!
  //               .where((e) => e['description'] == Gproofvalue.text)
  //               .toList()[0]['code']
  //               .toString(),
  //       "GuardianProofNumber": Gproofnumber.text,
  //       "GuardianFileUploads": gardientFiles,
  //       "GuardianFileString": " ",
  //       "GuardianFileName": " ",
  //       "GuardianFilePath": " ",
  //       "GuardianFileUploadDocIds": " ",
  //     };
  //     Provider.of<Postmap>(context, listen: false).addmap(m);
  //   } else {
  //     Navigator.pushNamed(context, route.nominee, arguments: "Nominee 3");

  //     Map m = {
  //       "ModelState": getlength >= 2 ? 'modified' : "added",
  //       "NomineeID": id ?? 0,
  //       "NomineeName": Nname.text,
  //       "NomineeRelationship": Nomineerelation!
  //           .where((e) => e['description'] == Nrelationvalue.text)
  //           .toList()[0]['code']
  //           .toString(),
  //       "NomineeRelationshipdesc": Nrelationvalue.text,
  //       "NomineeShare": percentofshare.text,
  //       "NomineeDOB": "${datechange.value.toString().substring(0, 10)}",
  //       "NomineeAddress1": adressline1.text,
  //       "NomineeAddress2": adressline2.text,
  //       "NomineeAddress3": adressline3.text,
  //       "NomineeCity": Ncity.text,
  //       "NomineeState": Nstate.text,
  //       "NomineeCountry": "India",
  //       "NomineePincode": Npin.text,
  //       "NomineeMobileNo": Nmobile.text,
  //       "NomineeEmailId": Nmail.text,
  //       "NomineeProofOfIdentity": "",
  //       "NomineeProofOfIdentitydesc": Nproofvalue.text,
  //       "NomineeProofNumber": Nproofnumber.text,
  //       "NomineeFileUploads": nomineeFiles,
  //       "NoimineeFileString": " ",
  //       "NoimineeFileName": " ",
  //       "NoimineeFilePath": " ",
  //       "NomineeFileUploadDocIds": " ",
  //       "GuardianVisible": age >= 18 ? false : true,
  //       "GuardianName": Gname.text,
  //       "GuardianRelationship": Grelationvalue.text == ""
  //           ? ""
  //           : gaurdianrelation!
  //               .where((e) => e['description'] == Grelationvalue.text)
  //               .toList()[0]['code']
  //               .toString(),
  //       "GuardianRelationshipdesc": Grelationvalue.text,
  //       "GuardianAddress1": Gadressline1.text,
  //       "GuardianAddress2": Gadressline2.text,
  //       "GuardianAddress3": Gadressline3.text,
  //       "GuardianCity": Gcity.text,
  //       "GuardianState": Gstate.text,
  //       "GuardianCountry": " India",
  //       "GuardianPincode": Gpin.text,
  //       "GuardianMobileNo": Gmobile.text,
  //       "GuardianEmailId": Gmail.text,
  //       "GuardianProofOfIdentity": Gproofvalue.text == ""
  //           ? ""
  //           : poidropdown!
  //               .where((e) => e['description'] == Gproofvalue.text)
  //               .toList()[0]['code']
  //               .toString(),
  //       "GuardianProofNumber": Gproofnumber.text,
  //       "GuardianFileUploads": gardientFiles,
  //       "GuardianFileString": " ",
  //       "GuardianFileName": " ",
  //       "GuardianFilePath": " ",
  //       "GuardianFileUploadDocIds": " ",
  //     };
  //     Provider.of<Postmap>(context, listen: false).addmap(m);
  //   }
  //   // print(Provider.of<Postmap>(context, listen: false).response.length);
  // }

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
              // showTodayButton: true,
              showNavigationArrow: true,
              // showActionButtons: true,
              initialDisplayDate: pickedDate ?? today,
              initialSelectedDate: pickedDate,
              minDate: isExpiryDate == true ? today : DateTime(1900),
              maxDate: isExpiryDate == true ? DateTime(2100) : today,
              onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
                Navigator.pop(context);
                func(dateRangePickerSelectionChangedArgs.value);
              },
              // onSubmit: (pickDate) {
              //   if (pickDate == null) return;
              //   Navigator.pop(context);
              //   func(pickDate);
              // },
              // onCancel: () {
              //   Navigator.pop(context);
              // },
              selectionMode: DateRangePickerSelectionMode.single,
            ),
          ),
        );
      },
    );
  }

  // showDatePick(pickedDate, [isExpiryDate]) async {
  //   DateTime today = DateTime.now();
  //   DateTime? pickDate = await showDatePicker(
  //       context: context,
  //       initialDate: pickedDate ?? today,
  //       firstDate: isExpiryDate == true ? today : DateTime(1900),
  //       lastDate: isExpiryDate == true ? DateTime(2100) : today);
  //   return pickDate;
  // }

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
        buttonFunc:
            // isFormValid
            //     ?
            () {
          if (!countinueButtonIsTriggered) {
            countinueButtonIsTriggered = true;
            setState(() {});
          }
          if (!(_formKey.currentState!.validate() &&
              nNameTitle.text.isNotEmpty &&
              Nrelationvalue.text.isNotEmpty &&
              (age < 18 || NproofType.text.isNotEmpty) &&
              (age > 18 ||
                  (gNameTitle.text.isNotEmpty &&
                      Grelationvalue.text.isNotEmpty &&
                      GproofType.text.isNotEmpty)))) {
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
        // : null,
        children: [
          Form(
            key: _formKey,
            onChanged: () => formVaidate(""),
            child: Column(
              children: [
                // ...getTitleANdSubTitleWidget(
                //     'Nomination & Declaration',
                //     'Add up to three nominees to your Demat & Trading account.',
                //     context),
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
                              // values: ['hi', 'hello'],
                              onChange: formVaidate,
                              formValidateNodifier: formValidateNodifier),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                            child: CustomFormField(
                                controller: Nname,
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
                            Nrelationvalue.text.isEmpty,
                        controller: Nrelationvalue,
                        values: Nomineerelation == null
                            ? []
                            : Nomineerelation!
                                .map((e) => e['description'])
                                .toList(),
                        // values: ['hi', 'hello'],
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
                            // print("value $value");
                            // print("currentPercentage $currentPercentage");
                            num newCurrentPercentage = num.tryParse(value) ?? 0;
                            tempPer = per + newCurrentPercentage;
                            print(per);
                            percentage = percentage -
                                currentPercentage +
                                newCurrentPercentage;
                            currentPercentage = newCurrentPercentage;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                // print("percentage $percentage");
                                // print("currentpercentage $currentPercentage");
                                setState(() {});
                              }
                            });
                          },
                          labelText: 'Percentage of share',
                          validator: (String? value) {
                            return validatePercentage(value);
                            // if ((percentage > 100) ||
                            //     (widget.nom == "Nominee 3" &&
                            //         percentage < 100)) {
                            //   return "Remaining (${100 - percentage + currentPercentage}) percentage available";
                            // }
                            // if ((oldPercentage == 100 || oldPercentage == 0) &&
                            //     percentage > 100) {
                            //   return "100 percentage available";
                            // }

                            //  else if (widget.nom == "Nominee 3" &&
                            //     percentage < 100) {
                            //   return "(${100 - percentage + currentPercentage})";
                            // }
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
                            ?
                            // nullValidation
                            (String? value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                return mobileNumberValidation(value);
                              }
                            : mobileNumberValidation,
                        controller: Nmobile,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        labelText:
                            age < 18 ? 'Mobile Number@' : 'Mobile Number',
                        formValidateNodifier: formValidateNodifier,
                        // validator: validateNotNull
                      ),
                    ),
                    SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: customFormField(
                          controller: Nmail,
                          labelText: age < 18 ? 'Mail id@' : 'Mail id',
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          validator: age < 18
                              ?
                              //  nullValidation
                              (String? value) {
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
                      visible: Provider.of<Postmap>(context).mobileNo !=
                              CustomHttpClient.testMobileNo &&
                          Provider.of<Postmap>(context).email !=
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
                                            size: 12,
                                            color:
                                                //  MediaQuery.of(context)
                                                //             .platformBrightness ==
                                                //         Brightness.light
                                                //     ?
                                                Colors.white
                                            // : Color.fromRGBO(0, 0, 0, 1),
                                            )
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
                      visible: true, // sameAsClientAddress == false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: customFormField(
                                controller: adressline1,
                                labelText: 'Addressline 1',
                                // inputFormatters: [
                                //   // LengthLimitingTextInputFormatter(55)
                                // ],
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
                                labelText:
                                    // age < 18 ? 'Adressline 2@' :
                                    'Addressline 2',
                                // inputFormatters: [
                                //   // LengthLimitingTextInputFormatter(30)
                                // ],
                                onChange: (value) {
                                  guardianAddresschangeToNomineeAddress();
                                  checkNomineeAddressSameAsClinet(value);
                                },
                                validator: (value) => validateAddresss(
                                    value, "Address Line 2", 3, 30)
                                //  age < 18
                                //     ?
                                //     //  nullValidation
                                //     (String? value) {
                                //         if (value == null || value.isEmpty) {
                                //           return null;
                                //         }
                                //         return validateAddresss(
                                //             value, "Address Line 2", 3, 30);
                                //       }
                                //     : (value) => validateAddresss(
                                //         value, "Address Line 2", 3, 30)
                                ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: customFormField(
                                controller: adressline3,
                                labelText: 'Addressline 3@',
                                // inputFormatters: [
                                //   LengthLimitingTextInputFormatter(30)
                                // ],
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
                                          controller: Npin,
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
                                              Ncity.text = "";
                                              Nstate.text = "";
                                              Ncountry.text = "";
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
                                        controller: Nstate,
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
                                        controller: Ncity,
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
                                        controller: Ncountry,
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
                            NproofType.text.isEmpty,
                        controller: NproofType,
                        values: poidropdown == null
                            ? []
                            // : poidropdown!
                            //     .where((element) => age < 18
                            //         ? true
                            //         : element["code"] != "136" &&
                            //             element["code"] != "132")
                            //     .map((e) => e['description'])
                            //     .toList(),
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
                          print("old ${oldnomineeProofCode}");
                          print("new ${nomineeProofCode}");
                          if (oldnomineeProofCode != nomineeProofCode &&
                              oldnomineeProofCode != "") {
                            Nproofnumber.text = "";
                            nomineePOIIssueDateController.text = "";
                            nomineePOIIssueDate = null;
                            nomineePOIExpireDateController.text = "";
                            nomineePOIExpireDate = null;
                            nomineePOIPlaceOfIssueController.text = "";
                            Nfile.text = "";
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
                          // _formKey1.currentState!.validate();
                        },
                        formValidateNodifier: formValidateNodifier),
                    SizedBox(height: 20),
                    // Form(
                    //   key: _formKey1,
                    //   onChanged: () {
                    //     _formKey1.currentState?.validate();
                    //     formVaidate("");
                    //   },
                    //   child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: customFormField(
                          controller: Nproofnumber,
                          labelText:
                              age < 18 ? 'Proof Number@' : 'Proof Number',
                          validator: age < 18
                              ?
                              // nullValidation
                              (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  return nomineeProofCode == "131"
                                      ? validatePanCard(value)
                                      : validateName(
                                          value,
                                          NproofType.text.isEmpty
                                              ? 'Proof Number'
                                              : NproofType.text,
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
                                      NproofType.text.isEmpty
                                          ? 'Proof Number'
                                          : NproofType.text,
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
                    // ),

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
                                            ?
                                            //  nullValidation(value)
                                            (String? value) {
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
                        controller: Nfile,
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
                                    print("file");
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
                                          "fileName": Nfile.text
                                        });
                                  } else {
                                    print("id");
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
                      // style: Theme.of(context).textTheme.displayMedium,
                    ),
                    ValueListenableBuilder(
                        valueListenable: dob,
                        builder: (context, value, child) {
                          return Visibility(
                              visible:
                                  // Gvisible == true ? Gvisible :
                                  age < 18,
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
                                            // values: ['hi', 'hello'],
                                            onChange: formVaidate,
                                            formValidateNodifier:
                                                formValidateNodifier),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: CustomFormField(
                                            controller: Gname,
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

                                  // SizedBox(
                                  //   height: 20,
                                  // ),
                                  // Text('Date of Birth*',
                                  //     style: Theme.of(context)
                                  //         .textTheme
                                  //         .bodyMedium),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),
                                  // CustomDateFormField(
                                  //     onChange: () {
                                  //       // colorchange.agecheck(datechange2);
                                  //     },
                                  //     date: datechange2,
                                  //     formValidateNodifier:
                                  //         formValidateNodifier),
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
                                          Grelationvalue.text.isEmpty,
                                      controller: Grelationvalue,
                                      values: gaurdianrelation == null
                                          ? []
                                          : gaurdianrelation!
                                              .map((e) => e['description'])
                                              .toList(),
                                      onChange: formVaidate,
                                      // values: ['hi', 'hello'],
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
                                      controller: Gmobile,
                                      labelText: 'Mobile Number',
                                      formValidateNodifier:
                                          formValidateNodifier,
                                      // validator: validateNotNull
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: customFormField(
                                        controller: Gmail,
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
                                            child: guardianAddressSameAsNomineeAddress
                                                ? Icon(Icons.check_sharp,
                                                    size: 12,
                                                    color:
                                                        //  MediaQuery.of(
                                                        //                 context)
                                                        //             .platformBrightness ==
                                                        //         Brightness.light
                                                        //     ?
                                                        Colors.white)
                                                //       : Color.fromRGBO(
                                                //           0, 0, 0, 1),
                                                // )
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

                                  Visibility(
                                    visible: true, //value == false,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: customFormField(
                                              controller: Gadressline1,
                                              labelText: 'Addressline 1',
                                              // inputFormatters: [
                                              //   // LengthLimitingTextInputFormatter(
                                              //   //     55)
                                              // ],
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
                                              controller: Gadressline2,
                                              labelText: 'Addressline 2',
                                              // inputFormatters: [
                                              //   // LengthLimitingTextInputFormatter(
                                              //   //     55)
                                              // ],
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
                                              controller: Gadressline3,
                                              labelText: 'Addressline 3@',
                                              validator: (value) =>
                                                  nullValidationWithMaxLength(
                                                      value, 55),
                                              // inputFormatters: [
                                              //   LengthLimitingTextInputFormatter(
                                              //       55)
                                              // ],
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: customFormField(
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              6),
                                                          FilteringTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        onChange:
                                                            (value) async {
                                                          if (value.length ==
                                                              6) {
                                                            await getpindata(
                                                                pincode: value,
                                                                isnom: false);
                                                          } else {
                                                            Gcity.text = "";
                                                            Gstate.text = "";
                                                            Gcountry.text = "";
                                                          }

                                                          checkGuardianAddressSameAsNominee(
                                                              value);
                                                        },
                                                        validator:
                                                            validatePinCode,
                                                        formValidateNodifier:
                                                            formValidateNodifier,
                                                        controller: Gpin,
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: customFormField(
                                                        controller: Gstate,
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: customFormField(
                                                        controller: Gcity,
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: customFormField(
                                                        controller: Gcountry,
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
                                          GproofType.text.isEmpty,
                                      controller: GproofType,
                                      values: poidropdown == null
                                          ? []
                                          : poidropdown!
                                              .where((element) =>
                                                  element["code"] != "136" &&
                                                  element["code"] != "132")
                                              .map((e) => e['description'])
                                              .toList(),
                                      onChange: (value) async {
                                        // WidgetsBinding.instance.addPostFrameCallback((_) {
                                        // _formKey2.currentState?.validate();
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
                                          // Gproofnumber.text = "";
                                          Gproofnumber.text = "";
                                          guardianPOIIssueDateController.text =
                                              "";
                                          guardianPOIIssueDate = null;
                                          guardianPOIExpireDateController.text =
                                              "";
                                          guardianPOIExpireDate = null;
                                          guardianPOIPlaceOfIssueController
                                              .text = "";
                                          Gfile.text = "";
                                          Guarfile = null;
                                          gurdianFileDetails = null;
                                        }
                                        // print(value);

                                        guardianIssueDateIsManitory =
                                            guardianProofCode == "133" ||
                                                guardianProofCode == "134";
                                        // print(
                                        // "ooc $guardianIssueDateIsManitory");
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
                                  // Form(
                                  //   key: _formKey2,
                                  //   onChanged: () {
                                  //     _formKey2.currentState!.validate();
                                  //     formVaidate("");
                                  //   },
                                  //   child:
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: customFormField(
                                        controller: Gproofnumber,
                                        labelText: 'Proof Number',
                                        validator: (value) =>
                                            guardianProofCode == "131"
                                                ? validatePanCard(value)
                                                : validateName(
                                                    value,
                                                    GproofType.text.isEmpty
                                                        ? 'Proof Number'
                                                        : GproofType.text,
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
                                  // ),

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
                                      controller: Gfile,
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
                                      suffixIcon: Guarfile != null ||
                                              gurdianFileDetails != null
                                          ? IconButton(
                                              onPressed: () {
                                                if (Guarfile != null) {
                                                  Navigator.pushNamed(
                                                      context,
                                                      (Guarfile?.path.endsWith(
                                                                  ".pdf") ??
                                                              false)
                                                          ? route.previewPdf
                                                          : route.previewImage,
                                                      arguments: {
                                                        "title":
                                                            "${widget.nom.replaceAll(" ", "")}GuradianProof",
                                                        "data": Guarfile!
                                                            .readAsBytesSync(),
                                                        "fileName": Gfile.text
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
                                    // style: Theme.of(context).textTheme.displayMedium,
                                  ),
                                ],
                              ));
                        }),

                    // widget.nom != 'Nominee 3'
                    //     ? CustomButton(
                    //         onPressed: isFormValid
                    //             ? () {
                    //                 addNomineeDetailsInProvider();
                    //                 Postmap postmap = Provider.of<Postmap>(
                    //                     context,
                    //                     listen: false);
                    //                 switch (widget.nom) {
                    //                   case 'Nominee 1':
                    //                     Navigator.pushNamed(
                    //                         context, route.addNominee,
                    //                         arguments: {
                    //                           "nominee": "Nominee 2",
                    //                           "nomineeDetails":
                    //                               postmap.response.length > 1
                    //                                   ? Provider.of<Postmap>(
                    //                                           context,
                    //                                           listen: false)
                    //                                       .response[1]
                    //                                   : null
                    //                         });
                    //                     break;
                    //                   case 'Nominee 2':
                    //                     Navigator.pushNamed(
                    //                         context, route.addNominee,
                    //                         arguments: {
                    //                           "nominee": "Nominee 3",
                    //                           "nomineeDetails":
                    //                               postmap.response.length > 2
                    //                                   ? Provider.of<Postmap>(
                    //                                           context,
                    //                                           listen: false)
                    //                                       .response[2]
                    //                                   : null
                    //                         });
                    //                     break;
                    //                   case 'Nominee 3':
                    //                     Navigator.pushNamed(
                    //                       context,
                    //                       route.nominee,
                    //                     );
                    //                     break;
                    //                   default:
                    //                 }
                    //               }
                    //             : null,
                    // childText: (widget.nom == 'Nominee 1')
                    //     ? 'Add Nominee 2'
                    //     : 'Add Nominee 3')
                    //     : SizedBox(),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    // CustomButton(
                    //     childText:
                    //         percentage >= 100 || widget.nom == 'Nominee 3'
                    //             ? "Continue"
                    //             : widget.nom == 'Nominee 1'
                    //                 ? 'Add Nominee 2'
                    //                 : 'Add Nominee 3',
                    //     onPressed: isFormValid
                    //         ? () {
                    //             addNomineeDetailsInProvider();
                    //             if (percentage >= 100 ||
                    //                 widget.nom == 'Nominee 3') {
                    //               Navigator.pushNamed(
                    //                 context,
                    //                 route.nominee,
                    //               );
                    //               return;
                    //             }
                    //             switch (widget.nom) {
                    //               case 'Nominee 1':
                    //                 Navigator.pushNamed(
                    //                     context, route.addNominee,
                    //                     arguments: {
                    //                       "nominee": "Nominee 2",
                    //                       "nomineeDetails":
                    //                           nomineesDetails.length > 1
                    //                               ? nomineesDetails[1]
                    //                               : null
                    //                     });
                    //                 break;
                    //               case 'Nominee 2':
                    //                 Navigator.pushNamed(
                    //                     context, route.addNominee,
                    //                     arguments: {
                    //                       "nominee": "Nominee 3",
                    //                       "nomineeDetails":
                    //                           nomineesDetails.length > 2
                    //                               ? nomineesDetails[2]
                    //                               : null
                    //                     });
                    //                 break;
                    //               default:
                    //             }
                    //           }
                    //         : null),
                    // const SizedBox(height: 20.0),
                  ],
                ),
              ],
            ),
          ),
        ]);
  }
}
