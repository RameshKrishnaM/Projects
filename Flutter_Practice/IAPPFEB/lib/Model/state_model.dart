// To parse this JSON data, do
//
//     final clientTransactionHistoryModel = clientTransactionHistoryModelFromJson(jsonString);

import 'dart:convert';

ClientTransactionHistoryModel clientTransactionHistoryModelFromJson(
        String str) =>
    ClientTransactionHistoryModel.fromJson(json.decode(str));

String clientTransactionHistoryModelToJson(
        ClientTransactionHistoryModel data) =>
    json.encode(data.toJson());

class ClientTransactionHistoryModel {
  List<Dropdowndatalist> dropdowndatalist;
  String dropdowndatadesc;
  String status;
  String errMsg;

  ClientTransactionHistoryModel({
    required this.dropdowndatalist,
    required this.dropdowndatadesc,
    required this.status,
    required this.errMsg,
  });

  factory ClientTransactionHistoryModel.fromJson(Map<String, dynamic> json) =>
      ClientTransactionHistoryModel(
        dropdowndatalist: List<Dropdowndatalist>.from(
            json["dropdowndatalist"].map((x) => Dropdowndatalist.fromJson(x))),
        dropdowndatadesc: json["dropdowndatadesc"],
        status: json["status"],
        errMsg: json["errMsg"],
      );

  Map<String, dynamic> toJson() => {
        "dropdowndatalist":
            List<dynamic>.from(dropdowndatalist.map((x) => x.toJson())),
        "dropdowndatadesc": dropdowndatadesc,
        "status": status,
        "errMsg": errMsg,
      };
}

class Dropdowndatalist {
  String code;
  String description;

  Dropdowndatalist({
    required this.code,
    required this.description,
  });

  factory Dropdowndatalist.fromJson(Map<String, dynamic> json) =>
      Dropdowndatalist(
        code: json["code"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "description": description,
      };
}
