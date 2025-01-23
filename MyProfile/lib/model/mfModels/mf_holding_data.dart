// // To parse this JSON data, do
// //
// //     final mfHoldingData = mfHoldingDataFromJson(jsonString);

// import 'dart:convert';

// MfHoldingData mfHoldingDataFromJson(String str) =>
//     MfHoldingData.fromJson(json.decode(str));

// String mfHoldingDataToJson(MfHoldingData data) => json.encode(data.toJson());

// class MfHoldingData {
//   final List<Holdingsarr>? holdingsarr;
//   String? mfDisclosureMessage;
//   final int? totalinvestment;
//   final double? totalTotalCurrentValue;
//   final double? totalreturns;
//   final int? todaysreturns;
//   final double? totalreturnsvalue;
//   final String? status;
//   final String? errMsg;

//   MfHoldingData({
//     this.holdingsarr,
//     this.mfDisclosureMessage,
//     this.totalinvestment,
//     this.totalTotalCurrentValue,
//     this.totalreturns,
//     this.todaysreturns,
//     this.totalreturnsvalue,
//     this.status,
//     this.errMsg,
//   });

//   factory MfHoldingData.fromJson(Map<String, dynamic> json) => MfHoldingData(
//         holdingsarr: json["holdingsarr"] == null
//             ? []
//             : List<Holdingsarr>.from(
//                 json["holdingsarr"]!.map((x) => Holdingsarr.fromJson(x))),
//         mfDisclosureMessage: json["mfDisclosureMessage"],
//         totalinvestment: json["totalinvestment"],
//         totalTotalCurrentValue: json["totalTotalCurrentValue"]?.toDouble(),
//         totalreturns: json["totalreturns"]?.toDouble(),
//         todaysreturns: json["todaysreturns"],
//         totalreturnsvalue: json["totalreturnsvalue"]?.toDouble(),
//         status: json["status"],
//         errMsg: json["errMsg"],
//       );

//   Map<String, dynamic> toJson() => {
//         "holdingsarr": holdingsarr == null
//             ? []
//             : List<dynamic>.from(holdingsarr!.map((x) => x.toJson())),
//         "mfDisclosureMessage": mfDisclosureMessage,
//         "totalinvestment": totalinvestment,
//         "totalTotalCurrentValue": totalTotalCurrentValue,
//         "totalreturns": totalreturns,
//         "todaysreturns": todaysreturns,
//         "totalreturnsvalue": totalreturnsvalue,
//         "status": status,
//         "errMsg": errMsg,
//       };
// }

// class Holdingsarr {
//   final String? schemename;
//   final String? lightUrl;
//   final int? investment;
//   final double? currentvalue;
//   final String? isin;
//   final double? percentage;

//   Holdingsarr({
//     this.schemename,
//     this.lightUrl,
//     this.investment,
//     this.currentvalue,
//     this.isin,
//     this.percentage,
//   });

//   factory Holdingsarr.fromJson(Map<String, dynamic> json) => Holdingsarr(
//         schemename: json["schemename"],
//         lightUrl: json["light_url"],
//         investment: json["investment"],
//         currentvalue: json["currentvalue"]?.toDouble(),
//         isin: json["isin"],
//         percentage: json["percentage"]?.toDouble(),
//       );

//   Map<String, dynamic> toJson() => {
//         "schemename": schemename,
//         "light_url": lightUrl,
//         "investment": investment,
//         "currentvalue": currentvalue,
//         "isin": isin,
//         "percentage": percentage,
//       };
// }
// To parse this JSON data, do
//
//     final mfHoldingData = mfHoldingDataFromJson(jsonString);
// To parse this JSON data, do
//
//     final mfHoldingData = mfHoldingDataFromJson(jsonString);

import 'dart:convert';

MfHoldingData mfHoldingDataFromJson(String str) =>
    MfHoldingData.fromJson(json.decode(str));

String mfHoldingDataToJson(MfHoldingData data) => json.encode(data.toJson());

class MfHoldingData {
  List<Holdingsarr>? holdingsarr;
  String? mfDisclosureMessage;
  String? pledgeableInfo;
  String? status;
  String? errMsg;

  MfHoldingData({
    this.holdingsarr,
    this.mfDisclosureMessage,
    this.pledgeableInfo,
    this.status,
    this.errMsg,
  });

  factory MfHoldingData.fromJson(Map<String, dynamic> json) => MfHoldingData(
        holdingsarr: json["holdingsarr"] == null
            ? []
            : List<Holdingsarr>.from(
                json["holdingsarr"]!.map((x) => Holdingsarr.fromJson(x))),
        mfDisclosureMessage: json["mfDisclosureMessage"],
        pledgeableInfo: json["pledgeableInfo"] ?? "",
        status: json["status"] ?? "",
        errMsg: json["errMsg"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "holdingsarr": holdingsarr == null
            ? []
            : List<dynamic>.from(holdingsarr!.map((x) => x.toJson())),
        "mfDisclosureMessage": mfDisclosureMessage,
        "status": status,
        "errMsg": errMsg,
      };
}

class Holdingsarr {
  num? freeBalQty;
  num? curBalQty;
  String? schemename;
  String? lightUrl;
  num? currentvalue;
  String? isin;
  String? schemeType;
  String? pledgeable;

  Holdingsarr({
    this.freeBalQty,
    this.curBalQty,
    this.schemename,
    this.lightUrl,
    this.currentvalue,
    this.isin,
    this.schemeType,
    this.pledgeable,
  });

  factory Holdingsarr.fromJson(Map<String, dynamic> json) => Holdingsarr(
        freeBalQty: json["FreeBalQty"],
        curBalQty: json["TotalQty"],
        schemename: json["schemename"],
        lightUrl: json["light_url"],
        currentvalue: json["currentvalue"],
        isin: json["isin"],
        schemeType: json["schemeType"],
        pledgeable: json["pledgeable"],
      );

  Map<String, dynamic> toJson() => {
        "FreeBalQty": freeBalQty,
        "CurBalQty": curBalQty,
        "schemename": schemename,
        "light_url": lightUrl,
        "currentvalue": currentvalue,
        "isin": isin,
        "schemeType": schemeType,
        "pledgeable": pledgeable,
      };
}

// To parse this JSON data, do

//     final mfHoldingData = mfHoldingDataFromJson(jsonString);

// import 'package:meta/meta.dart';
// import 'dart:convert';

// MfHoldingData mfHoldingDataFromJson(String str) =>
//     MfHoldingData.fromJson(json.decode(str));

// String mfHoldingDataToJson(MfHoldingData data) => json.encode(data.toJson());

// class MfHoldingData {
//   List<Holdingsarr> holdingsarr;
//   String mfDisclosureMessage;
//   String status;
//   String errMsg;

//   MfHoldingData({
//     required this.holdingsarr,
//     required this.mfDisclosureMessage,
//     required this.status,
//     required this.errMsg,
//   });

//   factory MfHoldingData.fromJson(Map<String, dynamic> json) => MfHoldingData(
//         holdingsarr: json["holdingsarr"] == null
//             ? []
//             : List<Holdingsarr>.from(
//                 json["holdingsarr"].map((x) => Holdingsarr.fromJson(x))),
//         mfDisclosureMessage: json["mfDisclosureMessage"] ?? '',
//         status: json["status"] ?? '',
//         errMsg: json["errMsg"] ?? '',
//       );

//   Map<String, dynamic> toJson() => {
//         "holdingsarr": List<dynamic>.from(holdingsarr.map((x) => x.toJson())),
//         "mfDisclosureMessage": mfDisclosureMessage,
//         "status": status,
//         "errMsg": errMsg,
//       };
// }

// class Holdingsarr {
//   double freeBalQty;
//   double curBalQty;
//   String schemename;
//   String lightUrl;
//   double currentvalue;
//   String isin;
//   String schemeType;
//   String pledgeable;

//   Holdingsarr({
//     required this.freeBalQty,
//     required this.curBalQty,
//     required this.schemename,
//     required this.lightUrl,
//     required this.currentvalue,
//     required this.isin,
//     required this.schemeType,
//     required this.pledgeable,
//   });

//   factory Holdingsarr.fromJson(Map<String, dynamic> json) => Holdingsarr(
//         freeBalQty: json["FreeBalQty"]?.toDouble() ?? 0.0,
//         curBalQty: json["CurBalQty"]?.toDouble() ?? 0.0,
//         schemename: json["schemename"] ?? '',
//         lightUrl: json["light_url"] ?? '',
//         currentvalue: json["currentvalue"]?.toDouble() ?? 0.0,
//         isin: json["isin"] ?? '',
//         schemeType: json["schemeType"] ?? '',
//         pledgeable: json["pledgeable"] ?? '',
//       );

//   Map<String, dynamic> toJson() => {
//         "FreeBalQty": freeBalQty,
//         "CurBalQty": curBalQty,
//         "schemename": schemename,
//         "light_url": lightUrl,
//         "currentvalue": currentvalue,
//         "isin": isin,
//         "schemeType": schemeType,
//         "pledgeable": pledgeable,
//       };
// }
