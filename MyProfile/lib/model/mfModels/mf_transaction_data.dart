// // To parse this JSON data, do
// //
// //     final mfTransactionData = mfTransactionDataFromJson(jsonString);

// import 'dart:convert';

// MfTransactionData mfTransactionDataFromJson(String str) =>
//     MfTransactionData.fromJson(json.decode(str));

// String mfTransactionDataToJson(MfTransactionData data) =>
//     json.encode(data.toJson());

// class MfTransactionData {
//   List<MfTransactionDatum>? mfTransactionData;
//   String? mfDisclosureMessage;
//   String? pledgeableInfo;
//   String? status;
//   String? errMsg;

//   MfTransactionData({
//     this.mfTransactionData,
//     this.mfDisclosureMessage,
//     this.pledgeableInfo,
//     this.status,
//     this.errMsg,
//   });

//   factory MfTransactionData.fromJson(Map<String, dynamic> json) =>
//       MfTransactionData(
//         mfTransactionData: json["mfTransactionData"] == null
//             ? []
//             : List<MfTransactionDatum>.from(json["mfTransactionData"]!
//                 .map((x) => MfTransactionDatum.fromJson(x))),
//         mfDisclosureMessage: json["mfDisclosureMessage"],
//         pledgeableInfo: json["pledgeableInfo"],
//         status: json["status"],
//         errMsg: json["errMsg"],
//       );

//   Map<String, dynamic> toJson() => {
//         "mfTransactionData": mfTransactionData == null
//             ? []
//             : List<dynamic>.from(mfTransactionData!.map((x) => x.toJson())),
//         "mfDisclosureMessage": mfDisclosureMessage,
//         "pledgeableInfo": pledgeableInfo,
//         "status": status,
//         "errMsg": errMsg,
//       };
// }

// class MfTransactionDatum {
//   String? buySell;
//   int? orderId;
//   String? maxOrderStatus;
//   String? maxOrderColor;
//   String? schemeName;
//   String? schemeType;
//   String? theme;
//   String? lumpsum;
//   num? qty;
//   num? amount;
//   String? orderDate;
//   String? orderTime;
//   String? transNo;
//   String? pledgeable;
//   String? allotmentStatus;
//   String? allotmentColor;
//   String? placedStatus;
//   String? orderStatusDate;
//   String? orderStatusTime;
//   String? placedColor;
//   String? orderStatus;
//   String? orderColor;
//   String? units;
//   String? stepperInfo;
//   String? nfo;

//   MfTransactionDatum({
//     this.buySell,
//     this.orderId,
//     this.maxOrderStatus,
//     this.maxOrderColor,
//     this.schemeName,
//     this.schemeType,
//     this.theme,
//     this.lumpsum,
//     this.qty,
//     this.amount,
//     this.orderDate,
//     this.orderTime,
//     this.transNo,
//     this.pledgeable,
//     this.allotmentStatus,
//     this.allotmentColor,
//     this.placedStatus,
//     this.orderStatusDate,
//     this.orderStatusTime,
//     this.placedColor,
//     this.orderStatus,
//     this.orderColor,
//     this.units,
//     this.stepperInfo,
//     this.nfo,
//   });

//   factory MfTransactionDatum.fromJson(Map<String, dynamic> json) =>
//       MfTransactionDatum(
//         buySell: json["buySell"] ?? '',
//         orderId: json["orderId"] ?? 0,
//         maxOrderStatus: json["maxOrderStatus"] ?? '',
//         maxOrderColor: json["maxOrderColor"] ?? '',
//         schemeName: json["schemeName"] ?? '',
//         schemeType: json["schemeType"] ?? '',
//         theme: json["theme"] ?? '',
//         lumpsum: json["lumpsum"] ?? '',
//         qty: json["qty"] ?? 0,
//         amount: json["amount"] ?? 0,
//         orderDate: json["orderDate"] ?? '',
//         orderTime: json["orderTime"] ?? '',
//         transNo: json["transNo"] ?? '',
//         pledgeable: json["pledgeable"] ?? '',
//         allotmentStatus: json["allotmentStatus"] ?? '',
//         allotmentColor: json["allotmentColor"] ?? '',
//         placedStatus: json["placedStatus"] ?? '',
//         orderStatusDate: json["orderStatusDate"] ?? '',
//         orderStatusTime: json["orderStatusTime"] ?? '',
//         placedColor: json["placedColor"] ?? '',
//         orderStatus: json["orderStatus"] ?? '',
//         orderColor: json["orderColor"] ?? '',
//         units: json["units"] ?? '',
//         stepperInfo: json["stepperInfo"] ?? '',
//         nfo: json["nfo"] ?? '',
//       );

//   Map<String, dynamic> toJson() => {
//         "buySell": buySell,
//         "orderId": orderId,
//         "maxOrderStatus": maxOrderStatus,
//         "maxOrderColor": maxOrderColor,
//         "schemeName": schemeName,
//         "schemeType": schemeType,
//         "theme": theme,
//         "lumpsum": lumpsum,
//         "qty": qty,
//         "amount": amount,
//         "orderDate": orderDate,
//         "orderTime": orderTime,
//         "transNo": transNo,
//         "pledgeable": pledgeable,
//         "allotmentStatus": allotmentStatus,
//         "allotmentColor": allotmentColor,
//         "placedStatus": placedStatus,
//         "orderStatusDate": orderStatusDate,
//         "orderStatusTime": orderStatusTime,
//         "placedColor": placedColor,
//         "orderStatus": orderStatus,
//         "orderColor": orderColor,
//         "units": units,
//         "stepperInfo": stepperInfo,
//         "nfo": nfo,
//       };
// }

// To parse this JSON data, do
//
//     final mfTransactionData = mfTransactionDataFromJson(jsonString);

import 'dart:convert';

MfTransactionData mfTransactionDataFromJson(String str) =>
    MfTransactionData.fromJson(json.decode(str));

String mfTransactionDataToJson(MfTransactionData data) =>
    json.encode(data.toJson());

class MfTransactionData {
  List<MfTransactionDatum>? mfTransactionData;
  List<MfTransactionHisDatum>? mfTransactionHisData;
  String? mfDisclosureMessage;
  String? pledgeableInfo;
  String? status;
  String? errMsg;

  MfTransactionData({
    this.mfTransactionData,
    this.mfTransactionHisData,
    this.mfDisclosureMessage,
    this.pledgeableInfo,
    this.status,
    this.errMsg,
  });

  factory MfTransactionData.fromJson(Map<String, dynamic> json) =>
      MfTransactionData(
        mfTransactionData: json["mfTransactionData"] == null
            ? []
            : List<MfTransactionDatum>.from(json["mfTransactionData"]!
                .map((x) => MfTransactionDatum.fromJson(x))),
        mfTransactionHisData: json["mfTransactionHisData"] == null
            ? []
            : List<MfTransactionHisDatum>.from(json["mfTransactionHisData"]!
                .map((x) => MfTransactionHisDatum.fromJson(x))),
        mfDisclosureMessage: json["mfDisclosureMessage"],
        pledgeableInfo: json["pledgeableInfo"],
        status: json["status"],
        errMsg: json["errMsg"],
      );

  Map<String, dynamic> toJson() => {
        "mfTransactionData": mfTransactionData == null
            ? []
            : List<dynamic>.from(mfTransactionData!.map((x) => x.toJson())),
        "mfTransactionHisData": mfTransactionHisData == null
            ? []
            : List<dynamic>.from(mfTransactionHisData!.map((x) => x.toJson())),
        "mfDisclosureMessage": mfDisclosureMessage,
        "pledgeableInfo": pledgeableInfo,
        "status": status,
        "errMsg": errMsg,
      };
}

class MfTransactionDatum {
  String? schemeName;
  String? schemeType;
  int? qty;
  int? amount;
  String? orderDate;
  String? transNo;
  String? maxOrderStatus;
  String? buySell;
  String? maxOrderColor;
  String? theme;
  String? lumpsum;
  String? orderTime;
  String? pledgeable;
  String? orderStatus;
  String? stepperInfo;
  String? nfo;

  MfTransactionDatum({
    this.schemeName,
    this.schemeType,
    this.qty,
    this.amount,
    this.orderDate,
    this.transNo,
    this.maxOrderStatus,
    this.buySell,
    this.maxOrderColor,
    this.theme,
    this.lumpsum,
    this.orderTime,
    this.pledgeable,
    this.orderStatus,
    this.stepperInfo,
    this.nfo,
  });

  factory MfTransactionDatum.fromJson(Map<String, dynamic> json) =>
      MfTransactionDatum(
        schemeName: json["schemeName"],
        schemeType: json["schemeType"],
        qty: json["qty"],
        amount: json["amount"],
        orderDate: json["orderDate"],
        transNo: json["transNo"],
        maxOrderStatus: json["maxOrderStatus"],
        buySell: json["buySell"],
        maxOrderColor: json["maxOrderColor"],
        theme: json["theme"],
        lumpsum: json["lumpsum"],
        orderTime: json["orderTime"],
        pledgeable: json["pledgeable"],
        orderStatus: json["orderStatus"],
        stepperInfo: json["stepperInfo"],
        nfo: json["nfo"],
      );

  Map<String, dynamic> toJson() => {
        "schemeName": schemeName,
        "schemeType": schemeType,
        "qty": qty,
        "amount": amount,
        "orderDate": orderDate,
        "transNo": transNo,
        "maxOrderStatus": maxOrderStatus,
        "buySell": buySell,
        "maxOrderColor": maxOrderColor,
        "theme": theme,
        "lumpsum": lumpsum,
        "orderTime": orderTime,
        "pledgeable": pledgeable,
        "orderStatus": orderStatus,
        "stepperInfo": stepperInfo,
        "nfo": nfo,
      };
}

class MfTransactionHisDatum {
  String? schemeName;
  String? schemeType;
  int? qty;
  int? amount;
  String? orderPlacedDateTime;
  String? transactionNumber;
  String? transactionType;
  String? currentStatus;
  String? pledgeable;
  String? nfo;

  MfTransactionHisDatum({
    this.schemeName,
    this.schemeType,
    this.qty,
    this.amount,
    this.orderPlacedDateTime,
    this.transactionNumber,
    this.transactionType,
    this.currentStatus,
    this.pledgeable,
    this.nfo,
  });

  factory MfTransactionHisDatum.fromJson(Map<String, dynamic> json) =>
      MfTransactionHisDatum(
        schemeName: json["Scheme Name"],
        schemeType: json["Scheme Type"],
        qty: json["Qty"],
        amount: json["Amount"],
        orderPlacedDateTime: json["Order Placed Date Time"],
        transactionNumber: json["Transaction Number"],
        transactionType: json["Transaction Type"],
        currentStatus: json["Current Status"],
        pledgeable: json["Pledgeable"],
        nfo: json["NFO"],
      );

  Map<String, dynamic> toJson() => {
        "Scheme Name": schemeName,
        "Scheme Type": schemeType,
        "Qty": qty,
        "Amount": amount,
        "Order Placed Date Time": orderPlacedDateTime,
        "Transaction Number": transactionNumber,
        "Transaction Type": transactionType,
        "Current Status": currentStatus,
        "Pledgeable": pledgeable,
        "NFO": nfo,
      };
}
