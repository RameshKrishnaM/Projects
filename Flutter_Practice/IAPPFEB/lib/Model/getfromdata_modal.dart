// To parse this JSON data, do
//
//     final getfromdataModal = getfromdataModalFromJson(jsonString);

import 'dart:convert';

GetfromdataModal getfromdataModalFromJson(String str) =>
    GetfromdataModal.fromJson(json.decode(str));

String getfromdataModalToJson(GetfromdataModal data) =>
    json.encode(data.toJson());

class GetfromdataModal {
  List<Nominee> nominee;
  String status;
  String errMsg;

  GetfromdataModal({
    required this.nominee,
    required this.status,
    required this.errMsg,
  });

  factory GetfromdataModal.fromJson(Map<String, dynamic> json) =>
      GetfromdataModal(
        nominee: json["nominee"] == null
            ? []
            : List<Nominee>.from(
                json["nominee"].map((x) => Nominee.fromJson(x))),
        status: json["status"] ?? "",
        errMsg: json["errMsg"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "nominee": List<dynamic>.from(nominee.map((x) => x.toJson())),
        "status": status,
        "errMsg": errMsg,
      };
}

class Nominee {
  int nomineeID;
  String nomineeName;
  String nomineeTitle;
  String nomineeRelationship;
  String nomineeShare;
  String nomineeDob;
  String nomineeAddress1;
  String nomineeAddress2;
  String nomineeAddress3;
  String nomineeCity;
  String nomineeState;
  String nomineeCountry;
  String nomineePincode;
  String nomineeMobileNo;
  String nomineeEmailId;
  String nomineeProofOfIdentity;
  String nomineeproofofidentitydesc;
  String nomineeProofNumber;
  String nomineeplaceofissue;
  String nomineeproofdateofissue;
  String nomineeproofexpriydate;
  String nomineeFileUploadDocIds;
  String noimineeFilePath;
  String noimineeFileName;
  String noimineeFileString;
  bool guardianVisible;
  String guardianName;
  String guardianTitle;
  String guardianRelationship;
  String guardianrelationshipdesc;
  String guardianAddress1;
  String guardianAddress2;
  String guardianAddress3;
  String guardianCity;
  String guardianState;
  String guardianCountry;
  String guardianPincode;
  String guardianMobileNo;
  String guardianEmailId;
  String guardianProofOfIdentity;
  String guardianproofofidentitydesc;
  String guardianProofNumber;
  String guardianplaceofissue;
  String guardianproofdateofissue;
  String guardianproofexpriydate;
  String guardianFileUploadDocIds;
  String guardianFilePath;
  String guardianFileName;
  String guardianFileString;
  String modelState;
  String nomineerelationshipdesc;

  Nominee(
      {required this.nomineeID,
      required this.nomineeTitle,
      required this.nomineeName,
      required this.nomineeRelationship,
      required this.nomineeShare,
      required this.nomineeDob,
      required this.nomineeAddress1,
      required this.nomineeAddress2,
      required this.nomineeAddress3,
      required this.nomineeCity,
      required this.nomineeState,
      required this.nomineeCountry,
      required this.nomineePincode,
      required this.nomineeMobileNo,
      required this.nomineeEmailId,
      required this.nomineeProofOfIdentity,
      required this.nomineeproofofidentitydesc,
      required this.nomineeProofNumber,
      required this.nomineeFileUploadDocIds,
      required this.noimineeFilePath,
      required this.noimineeFileName,
      required this.noimineeFileString,
      required this.guardianVisible,
      required this.guardianTitle,
      required this.guardianName,
      required this.guardianRelationship,
      required this.guardianrelationshipdesc,
      required this.guardianAddress1,
      required this.guardianAddress2,
      required this.guardianAddress3,
      required this.guardianCity,
      required this.guardianState,
      required this.guardianCountry,
      required this.guardianPincode,
      required this.guardianMobileNo,
      required this.guardianEmailId,
      required this.guardianProofOfIdentity,
      required this.guardianproofofidentitydesc,
      required this.guardianProofNumber,
      required this.guardianFileUploadDocIds,
      required this.guardianFilePath,
      required this.guardianFileName,
      required this.guardianFileString,
      required this.modelState,
      required this.nomineerelationshipdesc,
      required this.nomineeproofdateofissue,
      required this.nomineeplaceofissue,
      required this.nomineeproofexpriydate,
      required this.guardianproofdateofissue,
      required this.guardianplaceofissue,
      required this.guardianproofexpriydate});

  factory Nominee.fromJson(Map<String, dynamic> json) => Nominee(
        nomineeID: json["NomineeID"] ?? "",
        nomineeTitle: json["nomineetitle"] ?? "",
        nomineeName: json["nomineename"] ?? "",
        nomineeRelationship: json["nomineerelationship"] ?? "",
        nomineerelationshipdesc: json["nomineerelationshipdesc"] ?? "",
        nomineeShare: json["nomineeshare"] ?? "",
        nomineeDob: json["nomineedob"] ?? "",
        nomineeAddress1: json["nomineeaddress1"] ?? "",
        nomineeAddress2: json["nomineeaddress2"] ?? "",
        nomineeAddress3: json["nomineeaddress3"] ?? "",
        nomineeCity: json["nomineecity"] ?? "",
        nomineeState: json["nomineestate"] ?? "",
        nomineeCountry: json["nomineecountry"] ?? "",
        nomineePincode: json["nomineepincode"] ?? "",
        nomineeMobileNo: json["nomineemobileno"] ?? "",
        nomineeEmailId: json["nomineeemailid"] ?? "",
        nomineeProofOfIdentity: json["nomineeproofofidentity"] ?? "",
        nomineeproofofidentitydesc: json["nomineeproofofidentitydesc"] ?? "",
        nomineeProofNumber: json["nomineeproofnumber"] ?? "",
        nomineeproofdateofissue: json["nomineeproofdateofissue"] ?? "",
        nomineeplaceofissue: json["nomineeplaceofissue"] ?? "",
        nomineeproofexpriydate: json["nomineeproofexpriydate"] ?? "",
        nomineeFileUploadDocIds: json["nomineefileuploaddocids"] ?? "",
        noimineeFilePath: json["nomineefilepath"] ?? "",
        noimineeFileName: json["nomineefilename"] ?? "",
        noimineeFileString: json["nomineefilestring"] ?? "",
        guardianVisible: json["guardianvisible"] ?? false ?? "",
        guardianName: json["guardianname"] ?? "",
        guardianTitle: json["guardiantitle"],
        guardianRelationship: json["guardianrelationship"] ?? "",
        guardianrelationshipdesc: json["guardianrelationshipdesc"] ?? "",
        guardianAddress1: json["guardianaddress1"] ?? "",
        guardianAddress2: json["guardianaddress2"] ?? "",
        guardianAddress3: json["guardianaddress3"] ?? "",
        guardianCity: json["guardiancity"] ?? "",
        guardianState: json["guardianstate"] ?? "",
        guardianCountry: json["guardiancountry"] ?? "",
        guardianPincode: json["guardianpincode"] ?? "",
        guardianMobileNo: json["guardianmobileno"] ?? "",
        guardianEmailId: json["guardianemailid"] ?? "",
        guardianProofOfIdentity: json["guardianproofofidentity"] ?? "",
        guardianproofofidentitydesc: json["guardianproofofidentitydesc"] ?? "",
        guardianProofNumber: json["guardianproofnumber"] ?? "",
        guardianproofdateofissue: json["guardianproofdateofissue"] ?? "",
        guardianplaceofissue: json["guardianplaceofissue"] ?? "",
        guardianproofexpriydate: json["guardianproofexpriydate"] ?? "",
        guardianFileUploadDocIds: json["guardianfileuploaddocids"] ?? "",
        guardianFilePath: json["guardianfilepath"] ?? "",
        guardianFileName: json["guardianfilename"] ?? "",
        guardianFileString: json["guardianfilestring"] ?? "",
        modelState: json["ModelState"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "NomineeID": nomineeID,
        "NomineeName": nomineeName,
        "NomineeRelationship": nomineeRelationship,
        "NomineeShare": nomineeShare,
        "NomineeDOB": nomineeDob,
        "NomineeAddress1": nomineeAddress1,
        "NomineeAddress2": nomineeAddress2,
        "NomineeAddress3": nomineeAddress3,
        "NomineeCity": nomineeCity,
        "NomineeState": nomineeState,
        "NomineeCountry": nomineeCountry,
        "NomineePincode": nomineePincode,
        "NomineeMobileNo": nomineeMobileNo,
        "NomineeEmailId": nomineeEmailId,
        "NomineeProofOfIdentity": nomineeProofOfIdentity,
        "NomineeProofNumber": nomineeProofNumber,
        "NomineeFileUploadDocIds": nomineeFileUploadDocIds,
        "NoimineeFilePath": noimineeFilePath,
        "NoimineeFileName": noimineeFileName,
        "NoimineeFileString": noimineeFileString,
        "GuardianVisible": guardianVisible,
        "GuardianName": guardianName,
        "GuardianRelationship": guardianRelationship,
        "GuardianAddress1": guardianAddress1,
        "GuardianAddress2": guardianAddress2,
        "GuardianAddress3": guardianAddress3,
        "GuardianCity": guardianCity,
        "GuardianState": guardianState,
        "GuardianCountry": guardianCountry,
        "GuardianPincode": guardianPincode,
        "GuardianMobileNo": guardianMobileNo,
        "GuardianEmailId": guardianEmailId,
        "GuardianProofOfIdentity": guardianProofOfIdentity,
        "GuardianProofNumber": guardianProofNumber,
        "GuardianFileUploadDocIds": guardianFileUploadDocIds,
        "GuardianFilePath": guardianFilePath,
        "GuardianFileName": guardianFileName,
        "GuardianFileString": guardianFileString,
        "ModelState": modelState,
      };
}
