import 'dart:convert';

MFschemeTypeDetails mFschemeTypeDetailsFromJson(String str) =>
    MFschemeTypeDetails.fromJson(json.decode(str));

String mFschemeTypeDetailsToJson(MFschemeTypeDetails data) =>
    json.encode(data.toJson());

class MFschemeTypeDetails {
  List<MfSchemeArr>? mfSchemeArr;
  List<MfSchemeCodeArr>? mfSchemeCodeArr;
  List<MfSchemeArr>? mfSchemeCountArr;
  String? status;
  String? errMsg;

  MFschemeTypeDetails({
    this.mfSchemeArr,
    this.mfSchemeCodeArr,
    this.mfSchemeCountArr,
    this.status,
    this.errMsg,
  });

  factory MFschemeTypeDetails.fromJson(Map<String, dynamic> json) =>
      MFschemeTypeDetails(
        mfSchemeArr: json["mfSchemeArr"] == null
            ? []
            : List<MfSchemeArr>.from(
                json["mfSchemeArr"]!.map((x) => MfSchemeArr.fromJson(x))),
        mfSchemeCodeArr: json["mfSchemeCodeArr"] == null
            ? []
            : List<MfSchemeCodeArr>.from(json["mfSchemeCodeArr"]!
                .map((x) => MfSchemeCodeArr.fromJson(x))),
        mfSchemeCountArr: json["mfSchemeCountArr"] == null
            ? []
            : List<MfSchemeArr>.from(
                json["mfSchemeCountArr"]!.map((x) => MfSchemeArr.fromJson(x))),
        status: json["status"],
        errMsg: json["errMsg"],
      );

  Map<String, dynamic> toJson() => {
        "mfSchemeArr": mfSchemeArr == null
            ? []
            : List<dynamic>.from(mfSchemeArr!.map((x) => x.toJson())),
        "mfSchemeCodeArr": mfSchemeCodeArr == null
            ? []
            : List<dynamic>.from(mfSchemeCodeArr!.map((x) => x.toJson())),
        "mfSchemeCountArr": mfSchemeCountArr == null
            ? []
            : List<dynamic>.from(mfSchemeCountArr!.map((x) => x.toJson())),
        "status": status,
        "errMsg": errMsg,
      };
}

class MfSchemeArr {
  String? schemeName;
  String? schemeType;
  int? schemeCount;
  String? color;
  bool? isChecked;

  MfSchemeArr({
    this.schemeName,
    this.schemeType,
    this.schemeCount,
    this.color,
    this.isChecked,
  });

  factory MfSchemeArr.fromJson(Map<String, dynamic> json) => MfSchemeArr(
        schemeName: json["schemeName"],
        schemeType: json["schemeType"],
        schemeCount: json["schemeCount"],
        color: json["color"],
        isChecked: json["isChecked"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "schemeName": schemeName,
        "schemeType": schemeType,
        "schemeCount": schemeCount,
        "color": color,
        "isChecked": isChecked,
      };
}

class MfSchemeCodeArr {
  String? schemeName;
  String? schemeCode;
  bool? isChecked;

  MfSchemeCodeArr({
    this.schemeName,
    this.schemeCode,
    this.isChecked,
  });

  factory MfSchemeCodeArr.fromJson(Map<String, dynamic> json) =>
      MfSchemeCodeArr(
        schemeName: json["schemeName"],
        schemeCode: json["schemeCode"],
        isChecked: json["isChecked"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "schemeName": schemeName,
        "schemeCode": schemeCode,
        "isChecked": isChecked,
      };
}
