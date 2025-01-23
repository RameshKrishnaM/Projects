import 'dart:convert';

GetPersonalDetailsModel getPersonalDetailsModelFromJson(String str) =>
    GetPersonalDetailsModel.fromJson(json.decode(str));

String getPersonalDetailsModelToJson(GetPersonalDetailsModel data) =>
    json.encode(data.toJson());

class GetPersonalDetailsModel {
  PersonalStruct personalStruct;
  String status;
  String errMsg;

  GetPersonalDetailsModel({
    required this.personalStruct,
    required this.status,
    required this.errMsg,
  });

  factory GetPersonalDetailsModel.fromJson(Map<String, dynamic> json) =>
      GetPersonalDetailsModel(
        personalStruct: PersonalStruct.fromJson(json["personalStruct"]),
        status: json["status"] ?? "",
        errMsg: json["ErrMsg"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "personalStruct": personalStruct.toJson(),
        "status": status,
        "ErrMsg": errMsg,
      };
}

class PersonalStruct {
  String fatherNameTitle;
  String motherNameTitle;
  String fatherName;
  String motherName;
  String annualIncome;
  String tradingExperience;
  String occupation;
  String gender;
  String emailOwner;
  String phoneOwner;
  String politicalExpo;
  String maritalStatus;
  String education;
  String nomineeOpted;
  String emailOwnerName;
  String phoneOwnerName;
  String occOthers;
  String educationOthers;
  String soa;
  String pastActions;
  String dealSubBroker;
  String pastActionsDesc;
  String dealSubBrokerDesc;
  String phoneNumber;
  String emailId;
  String fatcaDeclaration;
  String residenceCountry;
  String taxIdendificationNumber;
  String placeofBirth;
  String countryofBirth;
  String foreignAddress1;
  String foreignAddress2;
  String foreignAddress3;
  String foreignCity;
  String foreignCountry;
  String foreignState;
  String foreignPincode;
  String fatcaTaxExempt;
  String fatcaTaxExemptReason;

  PersonalStruct(
      {required this.fatherNameTitle,
      required this.motherNameTitle,
      required this.fatherName,
      required this.motherName,
      required this.annualIncome,
      required this.tradingExperience,
      required this.occupation,
      required this.gender,
      required this.emailOwner,
      required this.phoneOwner,
      required this.politicalExpo,
      required this.maritalStatus,
      required this.education,
      required this.nomineeOpted,
      required this.educationOthers,
      required this.phoneOwnerName,
      required this.emailOwnerName,
      required this.occOthers,
      required this.soa,
      required this.pastActions,
      required this.dealSubBroker,
      required this.pastActionsDesc,
      required this.dealSubBrokerDesc,
      required this.phoneNumber,
      required this.emailId,
      required this.fatcaDeclaration,
      required this.residenceCountry,
      required this.taxIdendificationNumber,
      required this.placeofBirth,
      required this.countryofBirth,
      required this.foreignAddress1,
      required this.foreignAddress2,
      required this.foreignAddress3,
      required this.foreignCity,
      required this.foreignCountry,
      required this.foreignState,
      required this.fatcaTaxExempt,
      required this.fatcaTaxExemptReason,
      required this.foreignPincode});
  factory PersonalStruct.fromJson(Map<String, dynamic>? json) => PersonalStruct(
      fatherNameTitle: json!["fathertitle"] ?? "",
      motherNameTitle: json["mothertitle"] ?? "",
      fatherName: json["fathername"] ?? "",
      motherName: json["mothername"] ?? "",
      annualIncome: json["annualincome"] ?? "",
      tradingExperience: json["tradingexperience"] ?? "",
      occupation: json["occupation"] ?? "",
      gender: json["gender"] ?? "",
      emailOwner: json["emailowner"] ?? "",
      phoneOwner: json["phoneowner"] ?? "",
      politicalExpo: json["politicalexpo"] ?? "N",
      maritalStatus: json["maritalstatus"] ?? "",
      education: json["education"] ?? "",
      nomineeOpted: json["nomineeopted"] ?? "Y",
      phoneOwnerName: json["phoneownername"] ?? "",
      emailOwnerName: json["emailownername"] ?? "",
      educationOthers: json["educationothers"] ?? "",
      occOthers: json["occupationothers"] ?? "",
      soa: json["soa"] ?? "",
      pastActions: json["pastActions"] ?? "",
      pastActionsDesc: json["pastActionsDesc"] ?? "",
      dealSubBroker: json["dealSubBroker"] ?? "",
      dealSubBrokerDesc: json["dealSubBrokerDesc"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      emailId: json["emailId"] ?? "",
      fatcaDeclaration: json["fatcaDeclaration"] ?? "",
      residenceCountry: json["residenceCountry"] ?? "",
      taxIdendificationNumber: json["taxIdendificationNumber"] ?? "",
      placeofBirth: json["placeofBirth"] ?? "",
      countryofBirth: json["countryofBirth"] ?? "",
      foreignAddress1: json["foreignAddress1"] ?? "",
      foreignAddress2: json["foreignAddress2"] ?? "",
      foreignAddress3: json["foreignAddress3"] ?? "",
      foreignCity: json["foreignCity"] ?? "",
      foreignCountry: json["foreignCountry"] ?? "",
      foreignState: json["foreignState"] ?? "",
      foreignPincode: json["foreignPincode"] ?? "",
      fatcaTaxExemptReason: json["fatcaTaxExemptReason"] ?? "",
      fatcaTaxExempt: json["fatcaTaxExempt"] ?? "");

  Map<String, dynamic> toJson() => {
        "fathername": fatherName,
        "mothername": motherName,
        "annualincome": annualIncome,
        "tradingexperience": tradingExperience,
        "occupation": occupation,
        "gender": gender,
        "emailowner": emailOwner,
        "phoneowner": phoneOwner,
        "politicalexpo": politicalExpo,
        "maritalstatus": maritalStatus,
        "education": education,
        "nomineeopted": nomineeOpted,
        "phoneownername": phoneOwnerName,
        "emailOwnername": emailOwnerName,
        "educationothers": educationOthers,
        "occupationothers": occOthers,
        "phoneNumber": phoneNumber,
        "emailId": emailId,
        "fatcaTaxExemptReason": fatcaTaxExemptReason,
        "fatcaTaxExempt": fatcaTaxExempt,
      };
}
