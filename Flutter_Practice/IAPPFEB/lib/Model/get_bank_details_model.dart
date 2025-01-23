// To parse this JSON data, do
//
//     final bankDetailsModel = bankDetailsModelFromJson(jsonString);

import 'dart:convert';

BankDetailsModel bankDetailsModelFromJson(String str) =>
    BankDetailsModel.fromJson(json.decode(str));

String bankDetailsModelToJson(BankDetailsModel data) =>
    json.encode(data.toJson());

class BankDetailsModel {
  BankStruct bankStruct;
  String status;
  String errMsg;

  BankDetailsModel({
    required this.bankStruct,
    required this.status,
    required this.errMsg,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) =>
      BankDetailsModel(
        bankStruct: BankStruct.fromJson(json["bankStruct"]),
        status: json["status"],
        errMsg: json["ErrMsg"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "bankStruct": bankStruct.toJson(),
        "status": status,
        "ErrMsg": errMsg,
      };
}

class BankStruct {
  String accNo;
  String ifsc;
  String micr;
  String bank;
  String branch;
  String address;

  BankStruct({
    required this.accNo,
    required this.ifsc,
    required this.micr,
    required this.bank,
    required this.branch,
    required this.address,
  });

  factory BankStruct.fromJson(Map<String, dynamic>? json) => BankStruct(
        accNo: json!["accNo"] ?? "",
        ifsc: json["Ifsc"] ?? "",
        micr: json["Micr"] ?? "",
        bank: json["Bank"] ?? "",
        branch: json["Branch"] ?? "",
        address: json["Address"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "accNo": accNo,
        "Ifsc": ifsc,
        "Micr": micr,
        "Bank": bank,
        "Branch": branch,
        "Address": address,
      };
}
