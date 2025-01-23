// To parse this JSON data, do
//
//     final mFpieChartDetails = mFpieChartDetailsFromJson(jsonString);

import 'dart:convert';

MFpieChartDetails mFpieChartDetailsFromJson(String str) =>
    MFpieChartDetails.fromJson(json.decode(str));

String mFpieChartDetailsToJson(MFpieChartDetails data) =>
    json.encode(data.toJson());

class MFpieChartDetails {
  List<String>? mfschemetype;
  List<dynamic>? mfschemepercentage;
  List<String>? mfschemecolor;
  double? mfschemetotal;
  String? mfDisclaimerMessage;
  String? status;
  String? errMsg;

  MFpieChartDetails({
    this.mfschemetype,
    this.mfschemepercentage,
    this.mfschemecolor,
    this.mfschemetotal,
    this.mfDisclaimerMessage,
    this.status,
    this.errMsg,
  });

  factory MFpieChartDetails.fromJson(Map<String, dynamic> json) =>
      MFpieChartDetails(
        mfschemetype: json["mfschemetype"] == null
            ? []
            : List<String>.from(json["mfschemetype"]!.map((x) => x)),
        mfschemepercentage: json["mfschemepercentage"] == null
            ? []
            : List<dynamic>.from(json["mfschemepercentage"]!.map((x) => x)),
        mfschemecolor: json["mfschemecolor"] == null
            ? []
            : List<String>.from(json["mfschemecolor"]!.map((x) => x)),
        mfschemetotal: json["mfschemetotal"]?.toDouble(),
        mfDisclaimerMessage: json["mfDisclaimerMessage"],
        status: json["status"],
        errMsg: json["errMsg"],
      );

  Map<String, dynamic> toJson() => {
        "mfschemetype": mfschemetype == null
            ? []
            : List<dynamic>.from(mfschemetype!.map((x) => x)),
        "mfschemepercentage": mfschemepercentage == null
            ? []
            : List<dynamic>.from(mfschemepercentage!.map((x) => x)),
        "mfschemecolor": mfschemecolor == null
            ? []
            : List<dynamic>.from(mfschemecolor!.map((x) => x)),
        "mfschemetotal": mfschemetotal,
        "mfDisclaimerMessage": mfDisclaimerMessage,
        "status": status,
        "errMsg": errMsg,
      };
}
