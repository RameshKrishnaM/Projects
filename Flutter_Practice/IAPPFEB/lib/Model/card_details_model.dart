// To parse this JSON data, do
//
//     final cardDetailsModel = cardDetailsModelFromJson(jsonString);

import 'dart:convert';

CardDetailsModel cardDetailsModelFromJson(String str) =>
    CardDetailsModel.fromJson(json.decode(str));

String cardDetailsModelToJson(CardDetailsModel data) =>
    json.encode(data.toJson());

class CardDetailsModel {
  String name;
  String dob;
  String phone;
  String gender;
  String mailId;
  String address;
  String pan;
  String status;
  String errMsg;

  CardDetailsModel({
    required this.name,
    required this.dob,
    required this.phone,
    required this.gender,
    required this.mailId,
    required this.address,
    required this.pan,
    required this.status,
    required this.errMsg,
  });

  factory CardDetailsModel.fromJson(Map<String, dynamic> json) =>
      CardDetailsModel(
        name: json["clientname"] ?? "",
        dob: json["dob"] ?? "",
        phone: json["phone"] ?? "",
        gender: json["gender"] ?? "",
        mailId: json["mailId"] ?? "",
        address: json["address"] ?? "",
        pan: json["pan"] ?? "",
        status: json["status"] ?? "",
        errMsg: json["errMsg"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "clientname": name,
        "dob": dob,
        "phone": phone,
        "gender": gender,
        "mailId": mailId,
        "address": address,
        "pan": pan,
        "status": status,
        "errMsg": errMsg,
      };
}
