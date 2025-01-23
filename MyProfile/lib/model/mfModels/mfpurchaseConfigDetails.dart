// // // To parse this JSON data, do
// // //
// // //     final mFpurchaseConfigDetails = mFpurchaseConfigDetailsFromJson(jsonString);

// // import 'dart:convert';

// // MFpurchaseConfigDetails mFpurchaseConfigDetailsFromJson(String str) =>
// //     MFpurchaseConfigDetails.fromJson(json.decode(str));

// // String mFpurchaseConfigDetailsToJson(MFpurchaseConfigDetails data) =>
// //     json.encode(data.toJson());

// // class MFpurchaseConfigDetails {
// //   String? initialValue;
// //   String? incrementValue;
// //   String? incrementCount;
// //   MfSchemeMaster? mfSchemeMaster;
// //   MfDisclaimerMessageInfo? mfDisclaimerMessageInfo;
// //   String? mfDisclaimerMessage;
// //   String? ddpiMsg;
// //   String? minimumQtyMsg;
// //   String? ledgerBalanceMsg;
// //   String? ddpiLink;
// //   String? fundLink;
// //   String? status;
// //   String? errMsg;
// //   String? freeQtyMsg;
// //   String? pledgedQtyMsg;

// //   MFpurchaseConfigDetails(
// //       {this.initialValue,
// //       this.incrementValue,
// //       this.incrementCount,
// //       this.mfSchemeMaster,
// //       this.mfDisclaimerMessage,
// //       this.status,
// //       this.errMsg,
// //       this.ddpiMsg,
// //       this.ledgerBalanceMsg,
// //       this.minimumQtyMsg,
// //       this.ddpiLink,
// //       this.fundLink,
// //       this.freeQtyMsg,
// //       this.pledgedQtyMsg,
// //       this.mfDisclaimerMessageInfo});

// //   factory MFpurchaseConfigDetails.fromJson(Map<String, dynamic> json) =>
// //       MFpurchaseConfigDetails(
// //         initialValue: json["initialValue"] ?? "",
// //         incrementValue: json["incrementValue"] ?? "",
// //         incrementCount: json["incrementCount"] ?? "",
// //         ddpiMsg: json["ddpiMsg"] ?? '',
// //         minimumQtyMsg: json["minimumQtyMsg"] ?? '',
// //         ledgerBalanceMsg: json["ledgerBalanceMsg"] ?? '',
// //         mfSchemeMaster: json["mfSchemeMaster"] == null
// //             ? null
// //             : MfSchemeMaster.fromJson(json["mfSchemeMaster"]),
// //         mfDisclaimerMessageInfo: json["mfDisclaimerMessageInfo"] == null
// //             ? null
// //             : MfDisclaimerMessageInfo.fromJson(json["mfDisclaimerMessageInfo"]),
// //         mfDisclaimerMessage: json["mfDisclaimerMessage"] ?? '',
// //         status: json["status"] ?? "",
// //         errMsg: json["errMsg"] ?? "",
// //         ddpiLink: json["ddpiLink"] ?? "",
// //         fundLink: json["fundLink"] ?? "",
// //         freeQtyMsg: json["freeQtyMsg"] ?? "",
// //         pledgedQtyMsg: json["pledgedQtyMsg"] ?? "",
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "initialValue": initialValue,
// //         "incrementValue": incrementValue,
// //         "incrementCount": incrementCount,
// //         "mfSchemeMaster": mfSchemeMaster?.toJson(),
// //         "mfDisclaimerMessage": mfDisclaimerMessage,
// //         "status": status,
// //         "errMsg": errMsg,
// //       };
// // }

// // class MfSchemeMaster {
// //   String? schemeName;
// //   String? isin;
// //   String? schemeType;
// //   String? minPurchaseAmt;
// //   String? addiPurChaseAmt;
// //   String? maxPurchaseAmt;
// //   String? purchaseAmtMulti;
// //   String? purchaseCutOff;
// //   String? redemAllowed;
// //   String? minRedemQty;
// //   String? redemQtyMilti;
// //   String? maxRedemQty;
// //   String? redemAmtMin;
// //   String? redemAmtMax;
// //   String? redemAmtMulti;
// //   String? redemCutOff;
// //   String? startDate;
// //   String? endDate;
// //   String? navValue;
// //   String? icon;
// //   String? navdate;
// //   String? pledgeReqQty;

// //   MfSchemeMaster(
// //       {this.schemeName,
// //       this.isin,
// //       this.schemeType,
// //       this.minPurchaseAmt,
// //       this.addiPurChaseAmt,
// //       this.maxPurchaseAmt,
// //       this.purchaseAmtMulti,
// //       this.purchaseCutOff,
// //       this.redemAllowed,
// //       this.minRedemQty,
// //       this.redemQtyMilti,
// //       this.maxRedemQty,
// //       this.redemAmtMin,
// //       this.redemAmtMax,
// //       this.redemAmtMulti,
// //       this.redemCutOff,
// //       this.startDate,
// //       this.endDate,
// //       this.navValue,
// //       this.icon,
// //       this.navdate,
// //       this.pledgeReqQty});

// //   factory MfSchemeMaster.fromJson(Map<String, dynamic> json) => MfSchemeMaster(
// //       schemeName: json["schemeName"] ?? "",
// //       isin: json["isin"] ?? "",
// //       schemeType: json["schemeType"] ?? "",
// //       minPurchaseAmt: json["minPurchaseAmt"] ?? "",
// //       addiPurChaseAmt: json["addiPurChaseAmt"] ?? "",
// //       maxPurchaseAmt: json["maxPurchaseAmt"] ?? "",
// //       purchaseAmtMulti: json["purchaseAmtMulti"] ?? "",
// //       purchaseCutOff: json["purchaseCutOff"] ?? "",
// //       redemAllowed: json["redemAllowed"] ?? "",
// //       minRedemQty: json["minRedemQty"] ?? "",
// //       redemQtyMilti: json["redemQtyMilti"] ?? "",
// //       maxRedemQty: json["maxRedemQty"] ?? "",
// //       redemAmtMin: json["redemAmtMin"] ?? "",
// //       redemAmtMax: json["redemAmtMax"] ?? "",
// //       redemAmtMulti: json["redemAmtMulti"] ?? "",
// //       redemCutOff: json["redemCutOff"] ?? "",
// //       startDate: json["startDate"] ?? "",
// //       endDate: json["endDate"] ?? "",
// //       navValue: json["navValue"] ?? "",
// //       icon: json["icon"] ?? "",
// //       navdate: json["navdate"] ?? "",
// //       pledgeReqQty: json["pledgeReqQty"] ?? ""
// //       //  == null ? null : DateTime.parse(json["navdate"]??""),
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "schemeName": schemeName,
// //         "isin": isin,
// //         "schemeType": schemeType,
// //         "minPurchaseAmt": minPurchaseAmt,
// //         "addiPurChaseAmt": addiPurChaseAmt,
// //         "maxPurchaseAmt": maxPurchaseAmt,
// //         "purchaseAmtMulti": purchaseAmtMulti,
// //         "purchaseCutOff": purchaseCutOff,
// //         "redemAllowed": redemAllowed,
// //         "minRedemQty": minRedemQty,
// //         "redemQtyMilti": redemQtyMilti,
// //         "maxRedemQty": maxRedemQty,
// //         "redemAmtMin": redemAmtMin,
// //         "redemAmtMax": redemAmtMax,
// //         "redemAmtMulti": redemAmtMulti,
// //         "redemCutOff": redemCutOff,
// //         "startDate": startDate,
// //         "endDate": endDate,
// //         "navValue": navValue,
// //         "icon": icon,
// //         "navdate": navdate
// //         // ?.toIso8601String(),
// //       };
// // }

// // class MfDisclaimerMessageInfo {
// //   String? mfDisclaimerInfoMessage;
// //   String? mfDisclaimerInfoIcon;

// //   MfDisclaimerMessageInfo({
// //     this.mfDisclaimerInfoMessage,
// //     this.mfDisclaimerInfoIcon,
// //   });

// //   factory MfDisclaimerMessageInfo.fromJson(Map<String, dynamic> json) =>
// //       MfDisclaimerMessageInfo(
// //         mfDisclaimerInfoMessage: json["mfDisclaimerInfoMessage"] ?? "",
// //         mfDisclaimerInfoIcon: json["mfDisclaimerInfoIcon"] ?? "",
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "mfDisclaimerInfoMessage": mfDisclaimerInfoMessage,
// //         "mfDisclaimerInfoIcon": mfDisclaimerInfoIcon,
// //       };
// // }
// // To parse this JSON data, do
// //
// //     final mFpurchaseConfigDetails = mFpurchaseConfigDetailsFromJson(jsonString);
// import 'dart:convert';
// MFpurchaseConfigDetails mFpurchaseConfigDetailsFromJson(String str) =>
//     MFpurchaseConfigDetails.fromJson(json.decode(str));
// String mFpurchaseConfigDetailsToJson(MFpurchaseConfigDetails data) =>
//     json.encode(data.toJson());
// class MFpurchaseConfigDetails {
//   String? initialValue;
//   String? incrementValue;
//   String? incrementCount;
//   MfSchemeMaster? mfSchemeMaster;
//   MfHoldingsRec? mfHoldingsRec;
//   String? mfDisclaimerMessage;
//   MfDisclaimerMessageInfo? mfDisclaimerMessageInfo;
//   String? status;
//   String? errMsg;
//   String? ddpiMsg;
//   String? ddpiLink;
//   String? fundLink;
//   String? minimumQtyMsg;
//   String? ledgerBalanceMsg;
//   String? freeQtyMsg;
//   String? pledgedQtyMsg;

//   MFpurchaseConfigDetails({
//     this.initialValue,
//     this.incrementValue,
//     this.incrementCount,
//     this.mfSchemeMaster,
//     this.mfHoldingsRec,
//     this.mfDisclaimerMessage,
//     this.mfDisclaimerMessageInfo,
//     this.status,
//     this.errMsg,
//     this.ddpiMsg,
//     this.ddpiLink,
//     this.fundLink,
//     this.minimumQtyMsg,
//     this.ledgerBalanceMsg,
//     this.freeQtyMsg,
//     this.pledgedQtyMsg,
//   });

//   factory MFpurchaseConfigDetails.fromJson(Map<String, dynamic> json) =>
//       MFpurchaseConfigDetails(
//         initialValue: json["initialValue"],
//         incrementValue: json["incrementValue"],
//         incrementCount: json["incrementCount"],
//         mfSchemeMaster: json["mfSchemeMaster"] == null
//             ? null
//             : MfSchemeMaster.fromJson(json["mfSchemeMaster"]),
//         mfHoldingsRec: json["mfHoldingsRec"] == null
//             ? null
//             : MfHoldingsRec.fromJson(json["mfHoldingsRec"]),
//         mfDisclaimerMessage: json["mfDisclaimerMessage"],
//         mfDisclaimerMessageInfo: json["mfDisclaimerMessageInfo"] == null
//             ? null
//             : MfDisclaimerMessageInfo.fromJson(json["mfDisclaimerMessageInfo"]),
//         status: json["status"],
//         errMsg: json["errMsg"],
//         ddpiMsg: json["ddpiMsg"],
//         ddpiLink: json["ddpiLink"],
//         fundLink: json["fundLink"],
//         minimumQtyMsg: json["minimumQtyMsg"],
//         ledgerBalanceMsg: json["ledgerBalanceMsg"],
//         freeQtyMsg: json["freeQtyMsg"],
//         pledgedQtyMsg: json["pledgedQtyMsg"],
//       );
//   Map<String, dynamic> toJson() => {
//         "initialValue": initialValue,
//         "incrementValue": incrementValue,
//         "incrementCount": incrementCount,
//         "mfSchemeMaster": mfSchemeMaster?.toJson(),
//         "mfHoldingsRec": mfHoldingsRec?.toJson(),
//         "mfDisclaimerMessage": mfDisclaimerMessage,
//         "mfDisclaimerMessageInfo": mfDisclaimerMessageInfo?.toJson(),
//         "status": status,
//         "errMsg": errMsg,
//         "ddpiMsg": ddpiMsg,
//         "ddpiLink": ddpiLink,
//         "fundLink": fundLink,
//         "minimumQtyMsg": minimumQtyMsg,
//         "ledgerBalanceMsg": ledgerBalanceMsg,
//         "freeQtyMsg": freeQtyMsg,
//         "pledgedQtyMsg": pledgedQtyMsg,
//       };
// }

// class MfDisclaimerMessageInfo {
//   String? mfDisclaimerInfoMessage;
//   String? mfDisclaimerInfoIcon;

//   MfDisclaimerMessageInfo({
//     this.mfDisclaimerInfoMessage,
//     this.mfDisclaimerInfoIcon,
//   });

//   factory MfDisclaimerMessageInfo.fromJson(Map<String, dynamic> json) =>
//       MfDisclaimerMessageInfo(
//         mfDisclaimerInfoMessage: json["mfDisclaimerInfoMessage"],
//         mfDisclaimerInfoIcon: json["mfDisclaimerInfoIcon"],
//       );

//   Map<String, dynamic> toJson() => {
//         "mfDisclaimerInfoMessage": mfDisclaimerInfoMessage,
//         "mfDisclaimerInfoIcon": mfDisclaimerInfoIcon,
//       };
// }

// class MfHoldingsRec {
//   MfHoldingsRec();

//   factory MfHoldingsRec.fromJson(Map<String, dynamic> json) => MfHoldingsRec();

//   Map<String, dynamic> toJson() => {};
// }
// class MfHoldingsRec {
//   MfHoldingsRec();
//   factory MfHoldingsRec.fromJson(Map<String, dynamic> json) => MfHoldingsRec();
//   Map<String, dynamic> toJson() => {};
// }
// class MfSchemeMaster {
//   String? schemeName;
//   String? isin;
//   String? schemeType;
//   String? minPurchaseAmt;
//   String? addiPurChaseAmt;
//   String? maxPurchaseAmt;
//   String? purchaseAmtMulti;
//   String? purchaseCutOff;
//   String? minRedemQty;
//   String? redemQtyMilti;
//   String? maxRedemQty;
//   String? redemAmtMin;
//   String? redemAmtMax;
//   String? redemAmtMulti;
//   String? redemCutOff;
//   String? startDate;
//   String? endDate;
//   String? navValue;
//   String? icon;
//   String? navdate;
//   String? purchaseallowded;
//   String? schemeplan;
//   String? redemAllowed;
//   String? purchasetransmode;
//   String? redeemtransmode;
//   String? addcart;

//   MfSchemeMaster({
//     this.schemeName,
//     this.isin,
//     this.schemeType,
//     this.minPurchaseAmt,
//     this.addiPurChaseAmt,
//     this.maxPurchaseAmt,
//     this.purchaseAmtMulti,
//     this.purchaseCutOff,
//     this.minRedemQty,
//     this.redemQtyMilti,
//     this.maxRedemQty,
//     this.redemAmtMin,
//     this.redemAmtMax,
//     this.redemAmtMulti,
//     this.redemCutOff,
//     this.startDate,
//     this.endDate,
//     this.navValue,
//     this.icon,
//     this.navdate,
//     this.purchaseallowded,
//     this.schemeplan,
//     this.redemAllowed,
//     this.purchasetransmode,
//     this.redeemtransmode,
//     this.addcart,
//   });

//   factory MfSchemeMaster.fromJson(Map<String, dynamic> json) => MfSchemeMaster(
//         schemeName: json["schemeName"],
//         isin: json["isin"],
//         schemeType: json["schemeType"],
//         minPurchaseAmt: json["minPurchaseAmt"],
//         addiPurChaseAmt: json["addiPurChaseAmt"],
//         maxPurchaseAmt: json["maxPurchaseAmt"],
//         purchaseAmtMulti: json["purchaseAmtMulti"],
//         purchaseCutOff: json["purchaseCutOff"],
//         minRedemQty: json["minRedemQty"],
//         redemQtyMilti: json["redemQtyMilti"],
//         maxRedemQty: json["maxRedemQty"],
//         redemAmtMin: json["redemAmtMin"],
//         redemAmtMax: json["redemAmtMax"],
//         redemAmtMulti: json["redemAmtMulti"],
//         redemCutOff: json["redemCutOff"],
//         startDate: json["startDate"],
//         endDate: json["endDate"],
//         navValue: json["navValue"],
//         icon: json["icon"],
//         navdate: json["navdate"],
//         purchaseallowded: json["purchaseallowded"],
//         schemeplan: json["schemeplan"],
//         redemAllowed: json["redemAllowed"],
//         purchasetransmode: json["purchasetransmode"],
//         redeemtransmode: json["redeemtransmode"],
//         addcart: json["addcart"],
//       );
//   Map<String, dynamic> toJson() => {
//         "schemeName": schemeName,
//         "isin": isin,
//         "schemeType": schemeType,
//         "minPurchaseAmt": minPurchaseAmt,
//         "addiPurChaseAmt": addiPurChaseAmt,
//         "maxPurchaseAmt": maxPurchaseAmt,
//         "purchaseAmtMulti": purchaseAmtMulti,
//         "purchaseCutOff": purchaseCutOff,
//         "minRedemQty": minRedemQty,
//         "redemQtyMilti": redemQtyMilti,
//         "maxRedemQty": maxRedemQty,
//         "redemAmtMin": redemAmtMin,
//         "redemAmtMax": redemAmtMax,
//         "redemAmtMulti": redemAmtMulti,
//         "redemCutOff": redemCutOff,
//         "startDate": startDate,
//         "endDate": endDate,
//         "navValue": navValue,
//         "icon": icon,
//         "navdate": navdate,
//         "purchaseallowded": purchaseallowded,
//         "schemeplan": schemeplan,
//         "redemAllowed": redemAllowed,
//         "purchasetransmode": purchasetransmode,
//         "redeemtransmode": redeemtransmode,
//         "addcart": addcart,
//       };
// }
// To parse this JSON data, do
//
//     final mFpurchaseConfigDetails = mFpurchaseConfigDetailsFromJson(jsonString);
import 'dart:convert';

MFpurchaseConfigDetails mFpurchaseConfigDetailsFromJson(String str) =>
    MFpurchaseConfigDetails.fromJson(json.decode(str));
String mFpurchaseConfigDetailsToJson(MFpurchaseConfigDetails data) =>
    json.encode(data.toJson());

class MFpurchaseConfigDetails {
  String? initialValue;
  String? incrementValue;
  String? incrementCount;
  MfSchemeMaster? mfSchemeMaster;
  MfHoldingsRec? mfHoldingsRec;
  String? mfDisclaimerMessage;
  MfDisclaimerMessageInfo? mfDisclaimerMessageInfo;
  String? status;
  String? errMsg;
  String? ddpiMsg;
  String? ddpiLink;
  String? fundLink;
  String? minimumQtyMsg;
  String? ledgerBalanceMsg;
  String? freeQtyMsg;
  String? pledgedQtyMsg;
  MFpurchaseConfigDetails({
    this.initialValue,
    this.incrementValue,
    this.incrementCount,
    this.mfSchemeMaster,
    this.mfHoldingsRec,
    this.mfDisclaimerMessage,
    this.mfDisclaimerMessageInfo,
    this.status,
    this.errMsg,
    this.ddpiMsg,
    this.ddpiLink,
    this.fundLink,
    this.minimumQtyMsg,
    this.ledgerBalanceMsg,
    this.freeQtyMsg,
    this.pledgedQtyMsg,
  });
  factory MFpurchaseConfigDetails.fromJson(Map<String, dynamic> json) =>
      MFpurchaseConfigDetails(
        initialValue: json["initialValue"],
        incrementValue: json["incrementValue"],
        incrementCount: json["incrementCount"],
        mfSchemeMaster: json["mfSchemeMaster"] == null
            ? null
            : MfSchemeMaster.fromJson(json["mfSchemeMaster"]),
        mfHoldingsRec: json["mfHoldingsRec"] == null
            ? null
            : MfHoldingsRec.fromJson(json["mfHoldingsRec"]),
        mfDisclaimerMessage: json["mfDisclaimerMessage"],
        mfDisclaimerMessageInfo: json["mfDisclaimerMessageInfo"] == null
            ? null
            : MfDisclaimerMessageInfo.fromJson(json["mfDisclaimerMessageInfo"]),
        status: json["status"],
        errMsg: json["errMsg"],
        ddpiMsg: json["ddpiMsg"],
        ddpiLink: json["ddpiLink"],
        fundLink: json["fundLink"],
        minimumQtyMsg: json["minimumQtyMsg"],
        ledgerBalanceMsg: json["ledgerBalanceMsg"],
        freeQtyMsg: json["freeQtyMsg"],
        pledgedQtyMsg: json["pledgedQtyMsg"],
      );
  Map<String, dynamic> toJson() => {
        "initialValue": initialValue,
        "incrementValue": incrementValue,
        "incrementCount": incrementCount,
        "mfSchemeMaster": mfSchemeMaster?.toJson(),
        "mfHoldingsRec": mfHoldingsRec?.toJson(),
        "mfDisclaimerMessage": mfDisclaimerMessage,
        "mfDisclaimerMessageInfo": mfDisclaimerMessageInfo?.toJson(),
        "status": status,
        "errMsg": errMsg,
        "ddpiMsg": ddpiMsg,
        "ddpiLink": ddpiLink,
        "fundLink": fundLink,
        "minimumQtyMsg": minimumQtyMsg,
        "ledgerBalanceMsg": ledgerBalanceMsg,
        "freeQtyMsg": freeQtyMsg,
        "pledgedQtyMsg": pledgedQtyMsg,
      };
}

class MfDisclaimerMessageInfo {
  String? mfDisclaimerInfoMessage;
  String? mfDisclaimerInfoIcon;
  MfDisclaimerMessageInfo({
    this.mfDisclaimerInfoMessage,
    this.mfDisclaimerInfoIcon,
  });
  factory MfDisclaimerMessageInfo.fromJson(Map<String, dynamic> json) =>
      MfDisclaimerMessageInfo(
        mfDisclaimerInfoMessage: json["mfDisclaimerInfoMessage"],
        mfDisclaimerInfoIcon: json["mfDisclaimerInfoIcon"],
      );
  Map<String, dynamic> toJson() => {
        "mfDisclaimerInfoMessage": mfDisclaimerInfoMessage,
        "mfDisclaimerInfoIcon": mfDisclaimerInfoIcon,
      };
}

class MfHoldingsRec {
  String? totalQty;
  String? plBalQty;
  String? freeBalQty;
  String? boughtFromUs;
  String? notBoughtFromUs;
  String? invested;
  String? avgbuyprice;
  String? marginPledge;
  String? pledged4Mtf;
  String? funded;
  String? cuspa;
  String? todayPurchQty;
  String? longTerm;
  String? pledgeReqQty;
  String? redeemReqQty;

  MfHoldingsRec({
    this.totalQty,
    this.plBalQty,
    this.freeBalQty,
    this.boughtFromUs,
    this.notBoughtFromUs,
    this.invested,
    this.avgbuyprice,
    this.marginPledge,
    this.pledged4Mtf,
    this.funded,
    this.cuspa,
    this.todayPurchQty,
    this.longTerm,
    this.pledgeReqQty,
    this.redeemReqQty,
  });

  factory MfHoldingsRec.fromJson(Map<String, dynamic> json) => MfHoldingsRec(
        totalQty: json["TotalQty"],
        plBalQty: json["PlBalQty"],
        freeBalQty: json["FreeBalQty"],
        boughtFromUs: json["boughtFromUs"],
        notBoughtFromUs: json["notBoughtFromUs"],
        invested: json["invested"],
        avgbuyprice: json["avgbuyprice"],
        marginPledge: json["marginPledge"],
        pledged4Mtf: json["pledged4MTF"],
        funded: json["funded"],
        cuspa: json["cuspa"],
        todayPurchQty: json["todayPurchQty"],
        longTerm: json["longTerm"],
        pledgeReqQty: json["pledgeReqQty"],
        redeemReqQty: json["redeemReqQty"],
      );

  Map<String, dynamic> toJson() => {
        "TotalQty": totalQty,
        "PlBalQty": plBalQty,
        "FreeBalQty": freeBalQty,
        "boughtFromUs": boughtFromUs,
        "notBoughtFromUs": notBoughtFromUs,
        "invested": invested,
        "avgbuyprice": avgbuyprice,
        "marginPledge": marginPledge,
        "pledged4MTF": pledged4Mtf,
        "funded": funded,
        "cuspa": cuspa,
        "todayPurchQty": todayPurchQty,
        "longTerm": longTerm,
        "pledgeReqQty": pledgeReqQty,
        "redeemReqQty": redeemReqQty,
      };
}

class MfSchemeMaster {
  String? schemeName;
  String? isin;
  String? schemeType;
  String? minPurchaseAmt;
  String? addiPurChaseAmt;
  String? maxPurchaseAmt;
  String? purchaseAmtMulti;
  String? purchaseCutOff;
  String? minRedemQty;
  String? redemQtyMilti;
  String? maxRedemQty;
  String? redemAmtMin;
  String? redemAmtMax;
  String? redemAmtMulti;
  String? redemCutOff;
  String? startDate;
  String? endDate;
  String? navValue;
  String? icon;
  String? navdate;
  String? purchaseallowded;
  String? schemeplan;
  String? redemAllowed;
  String? purchasetransmode;
  String? redeemtransmode;
  String? addcart;
  MfSchemeMaster({
    this.schemeName,
    this.isin,
    this.schemeType,
    this.minPurchaseAmt,
    this.addiPurChaseAmt,
    this.maxPurchaseAmt,
    this.purchaseAmtMulti,
    this.purchaseCutOff,
    this.minRedemQty,
    this.redemQtyMilti,
    this.maxRedemQty,
    this.redemAmtMin,
    this.redemAmtMax,
    this.redemAmtMulti,
    this.redemCutOff,
    this.startDate,
    this.endDate,
    this.navValue,
    this.icon,
    this.navdate,
    this.purchaseallowded,
    this.schemeplan,
    this.redemAllowed,
    this.purchasetransmode,
    this.redeemtransmode,
    this.addcart,
  });
  factory MfSchemeMaster.fromJson(Map<String, dynamic> json) => MfSchemeMaster(
        schemeName: json["schemeName"],
        isin: json["isin"],
        schemeType: json["schemeType"],
        minPurchaseAmt: json["minPurchaseAmt"],
        addiPurChaseAmt: json["addiPurChaseAmt"],
        maxPurchaseAmt: json["maxPurchaseAmt"],
        purchaseAmtMulti: json["purchaseAmtMulti"],
        purchaseCutOff: json["purchaseCutOff"],
        minRedemQty: json["minRedemQty"],
        redemQtyMilti: json["redemQtyMilti"],
        maxRedemQty: json["maxRedemQty"],
        redemAmtMin: json["redemAmtMin"],
        redemAmtMax: json["redemAmtMax"],
        redemAmtMulti: json["redemAmtMulti"],
        redemCutOff: json["redemCutOff"],
        startDate: json["startDate"],
        endDate: json["endDate"],
        navValue: json["navValue"],
        icon: json["icon"],
        navdate: json["navdate"],
        purchaseallowded: json["purchaseallowded"],
        schemeplan: json["schemeplan"],
        redemAllowed: json["redemAllowed"],
        purchasetransmode: json["purchasetransmode"],
        redeemtransmode: json["redeemtransmode"],
        addcart: json["addcart"],
      );
  Map<String, dynamic> toJson() => {
        "schemeName": schemeName,
        "isin": isin,
        "schemeType": schemeType,
        "minPurchaseAmt": minPurchaseAmt,
        "addiPurChaseAmt": addiPurChaseAmt,
        "maxPurchaseAmt": maxPurchaseAmt,
        "purchaseAmtMulti": purchaseAmtMulti,
        "purchaseCutOff": purchaseCutOff,
        "minRedemQty": minRedemQty,
        "redemQtyMilti": redemQtyMilti,
        "maxRedemQty": maxRedemQty,
        "redemAmtMin": redemAmtMin,
        "redemAmtMax": redemAmtMax,
        "redemAmtMulti": redemAmtMulti,
        "redemCutOff": redemCutOff,
        "startDate": startDate,
        "endDate": endDate,
        "navValue": navValue,
        "icon": icon,
        "navdate": navdate,
        "purchaseallowded": purchaseallowded,
        "schemeplan": schemeplan,
        "redemAllowed": redemAllowed,
        "purchasetransmode": purchasetransmode,
        "redeemtransmode": redeemtransmode,
        "addcart": addcart,
      };
}
