// To parse this JSON data, do
//
//     final personelDetailModal = personelDetailModalFromJson(jsonString);

import 'dart:convert';

PersonalDetailModel personalDetailModalFromJson(String str) =>
    PersonalDetailModel.fromJson(json.decode(str));

String personelDetailModalToJson(PersonalDetailModel data) =>
    json.encode(data.toJson());

class PersonalDetailModel {
  PersonalStruct personalStruct;
  String status;
  String errMsg;

  PersonalDetailModel({
    required this.personalStruct,
    required this.status,
    required this.errMsg,
  });

  factory PersonalDetailModel.fromJson(Map<String, dynamic> json) =>
      PersonalDetailModel(
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

  PersonalStruct({
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
  });

  factory PersonalStruct.fromJson(Map<String, dynamic>? json) => PersonalStruct(
        fatherName: json!["fatherName"] ?? "",
        motherName: json["motherName"] ?? "",
        annualIncome: json["annualIncome"] ?? "",
        tradingExperience: json["tradingExperience"] ?? "",
        occupation: json["occupation"] ?? "",
        gender: json["gender"] ?? "",
        emailOwner: json["emailOwner"] ?? "",
        phoneOwner: json["phoneOwner"] ?? "",
        politicalExpo: json["politicalExpo"] ?? "",
        maritalStatus: json["maritalStatus"] ?? "",
        education: json["education"] ?? "",
        nomineeOpted: json["nomineeOpted"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "fatherName": fatherName,
        "motherName": motherName,
        "annualIncome": annualIncome,
        "tradingExperience": tradingExperience,
        "occupation": occupation,
        "gender": gender,
        "emailOwner": emailOwner,
        "phoneOwner": phoneOwner,
        "politicalExpo": politicalExpo,
        "maritalStatus": maritalStatus,
        "education": education,
        "nomineeOpted": nomineeOpted,
      };
}
