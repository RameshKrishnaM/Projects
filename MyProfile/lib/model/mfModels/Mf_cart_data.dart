// To parse this JSON data, do
//
//     final mfCartData = mfCartDataFromJson(jsonString);

import 'dart:convert';

MfCartData mfCartDataFromJson(String str) =>
    MfCartData.fromJson(json.decode(str));

String mfCartDataToJson(MfCartData data) => json.encode(data.toJson());

class MfCartData {
  List<MfCartDataArr>? mfCartDataArr;
  String? mfDisclosureMessage;
  String? pledgeableInfo;
  dynamic mfCartValue;
  String? bulkpurchase;
  String? status;
  String? errMsg;

  MfCartData({
    this.mfCartDataArr,
    this.mfDisclosureMessage,
    this.pledgeableInfo,
    this.mfCartValue,
    this.bulkpurchase,
    this.status,
    this.errMsg,
  });

  factory MfCartData.fromJson(Map<String, dynamic> json) => MfCartData(
        mfCartDataArr: json["mfCartData"] == null
            ? []
            : List<MfCartDataArr>.from(
                json["mfCartData"]!.map((x) => MfCartDataArr.fromJson(x))),
        mfDisclosureMessage: json["mfDisclosureMessage"] ?? "",
        pledgeableInfo: json["pledgeableInfo"] ?? "",
        mfCartValue: json["mfCartValue"] ?? "",
        bulkpurchase: json["bulkpurchase"] ?? "",
        status: json["status"] ?? "",
        errMsg: json["errMsg"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "mfCartData": mfCartDataArr == null
            ? []
            : List<dynamic>.from(mfCartDataArr!.map((x) => x.toJson())),
        "mfDisclosureMessage": mfDisclosureMessage,
        "pledgeableInfo": pledgeableInfo,
        "mfCartValue": mfCartValue,
        "bulkpurchase": bulkpurchase,
        "status": status,
        "errMsg": errMsg,
      };
}

class MfCartDataArr {
  int? id;
  String? isin;
  String? schemeName;
  String? schemeType;
  String? navValue;
  String? theme;
  dynamic orderValue;
  String? estimatedUnit;
  String? pledgeable;
  bool? isChecked;

  MfCartDataArr({
    this.id,
    this.isin,
    this.schemeName,
    this.schemeType,
    this.navValue,
    this.theme,
    this.orderValue,
    this.estimatedUnit,
    this.pledgeable,
    this.isChecked,
  });

  factory MfCartDataArr.fromJson(Map<String, dynamic> json) => MfCartDataArr(
        id: json["id"] ?? 0,
        isin: json["isin"] ?? "",
        schemeName: json["schemeName"] ?? "",
        schemeType: json["schemeType"] ?? "",
        navValue: json["navValue"] ?? "",
        theme: json["theme"] ?? "",
        orderValue: json["orderValue"] ?? "",
        estimatedUnit: json["estimated_Unit"] ?? "",
        pledgeable: json["pledgeable"] ?? "",
        isChecked: false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "isin": isin,
        "schemeName": schemeName,
        "schemeType": schemeType,
        "navValue": navValue,
        "theme": theme,
        "orderValue": orderValue,
        "estimated_Unit": estimatedUnit,
        "pledgeable": pledgeable,
        "isChecked": isChecked,
      };
}
