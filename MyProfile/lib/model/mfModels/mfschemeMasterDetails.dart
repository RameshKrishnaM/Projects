// ignore_for_file: file_names

import 'dart:convert';

MfSchemeMasterDetails mfSchemeMasterDetailsFromJson(String str) =>
    MfSchemeMasterDetails.fromJson(json.decode(str));

String mfSchemeMasterDetailsToJson(MfSchemeMasterDetails data) =>
    json.encode(data.toJson());

class MfSchemeMasterDetails {
  List<MfSchemeMasterArr>? mfSchemeMasterArr;
  String? mfDisclosureMessage;
  String? pledgeableInfo;
  String? mfNavInfoMessage;
  String? mfNFOM1;
  String? mfNFOM2;
  String? status;
  String? errMsg;

  MfSchemeMasterDetails({
    this.mfSchemeMasterArr,
    this.mfDisclosureMessage,
    this.pledgeableInfo,
    this.mfNavInfoMessage,
    this.mfNFOM1,
    this.mfNFOM2,
    this.status,
    this.errMsg,
  });

  factory MfSchemeMasterDetails.fromJson(Map<String, dynamic> json) =>
      MfSchemeMasterDetails(
        mfSchemeMasterArr: json["mfSchemeMasterArr"] == null
            ? []
            : List<MfSchemeMasterArr>.from(json["mfSchemeMasterArr"]!
                .map((x) => MfSchemeMasterArr.fromJson(x))),
        mfDisclosureMessage: json["mfDisclosureMessage"] ?? '',
        pledgeableInfo: json["pledgeableInfo"] ?? '',
        mfNavInfoMessage: json["mfNavInfoMessage"] ?? '',
        mfNFOM1: json["mfNFOM1"] ?? '',
        mfNFOM2: json["mfNFOM2"] ?? '',
        status: json["status"] ?? 'E',
        errMsg: json["errMsg"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "mfSchemeMasterArr": mfSchemeMasterArr == null
            ? []
            : List<dynamic>.from(mfSchemeMasterArr!.map((x) => x.toJson())),
        "mfDisclosureMessage": mfDisclosureMessage,
        "pledgeableInfo": pledgeableInfo,
        "mfNavInfoMessage": mfNavInfoMessage,
        "mfNFOM1": mfNFOM1,
        "mfNFOM2": mfNFOM2,
        "status": status,
        "errMsg": errMsg,
      };
}

class MfSchemeMasterArr {
  String? schemeName;
  String? isin;
  String? schemeType;
  String? minPurchaseAmt;
  String? addiPurChaseAmt;
  String? maxPurchaseAmt;
  String? purchaseAmtMulti;
  String? navValue;
  String? pledgeable;
  String? icon;
  String? addedCart;
  String? closeDays;

  MfSchemeMasterArr({
    this.schemeName,
    this.isin,
    this.schemeType,
    this.minPurchaseAmt,
    this.addiPurChaseAmt,
    this.maxPurchaseAmt,
    this.purchaseAmtMulti,
    this.navValue,
    this.pledgeable,
    this.icon,
    this.addedCart,
    this.closeDays,
  });

  factory MfSchemeMasterArr.fromJson(Map<String, dynamic> json) =>
      MfSchemeMasterArr(
        schemeName: json["schemeName"] ?? '',
        isin: json["isin"] ?? '',
        schemeType: json["schemeType"] ?? '',
        minPurchaseAmt: json["minPurchaseAmt"] ?? '',
        addiPurChaseAmt: json["addiPurChaseAmt"] ?? '',
        maxPurchaseAmt: json["maxPurchaseAmt"] ?? '',
        purchaseAmtMulti: json["purchaseAmtMulti"] ?? '',
        navValue: json["navValue"] ?? '',
        pledgeable: json["pledgeable"] ?? '',
        icon: json["icon"] ?? '',
        addedCart: json["addedCart"] ?? '',
        closeDays: json["closeDays"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "schemeName": schemeName,
        "isin": isin,
        "schemeType": schemeType,
        "minPurchaseAmt": minPurchaseAmt,
        "addiPurChaseAmt": addiPurChaseAmt,
        "maxPurchaseAmt": maxPurchaseAmt,
        "purchaseAmtMulti": purchaseAmtMulti,
        "navValue": navValue,
        "pledgeable": pledgeable,
        "icon": icon,
        "addedCart": addedCart,
        "closeDays": closeDays,
      };
}
