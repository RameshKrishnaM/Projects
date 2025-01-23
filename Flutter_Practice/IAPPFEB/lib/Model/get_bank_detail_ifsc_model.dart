// To parse this JSON data, do
//
//     final fetchBankDetailByIfsc = fetchBankDetailByIfscFromJson(jsonString);

import 'dart:convert';

FetchBankDetailByIfsc fetchBankDetailByIfscFromJson(String str) =>
    FetchBankDetailByIfsc.fromJson(json.decode(str));

String fetchBankDetailByIfscToJson(FetchBankDetailByIfsc data) =>
    json.encode(data.toJson());

class FetchBankDetailByIfsc {
  String micr;
  String branch;
  String address;
  String state;
  String bank;
  String status;
  String success;
  String errMsg;
  String? acctype;

  FetchBankDetailByIfsc({
    required this.micr,
    required this.branch,
    required this.address,
    required this.state,
    required this.bank,
    required this.status,
    required this.success,
    required this.errMsg,
    this.acctype,
  });

  factory FetchBankDetailByIfsc.fromJson(Map<String, dynamic> json) =>
      FetchBankDetailByIfsc(
          micr: json["micr"] ?? "",
          branch: json["branch"] ?? "",
          address: json["address"] ?? "",
          state: json["state"] ?? "",
          bank: json["bank"] ?? "",
          status: json["status"] ?? "",
          success: json["success"] ?? "",
          errMsg: json["msg"] ?? "",
          acctype: json["acctype"]);

  Map<String, dynamic> toJson() => {
        "micr": micr,
        "branch": branch,
        "address": address,
        "state": state,
        "bank": bank,
        "status": status,
        "success": success,
        "errmsg": errMsg,
        "acctype": acctype
      };
}
