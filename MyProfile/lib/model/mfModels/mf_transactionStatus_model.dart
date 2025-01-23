// To parse this JSON data, do
//
//     final mfTransactionStatusDetails = mfTransactionStatusDetailsFromJson(jsonString);

import 'dart:convert';

MfTransactionStatusDetails mfTransactionStatusDetailsFromJson(String str) =>
    MfTransactionStatusDetails.fromJson(json.decode(str));

String mfTransactionStatusDetailsToJson(MfTransactionStatusDetails data) =>
    json.encode(data.toJson());

class MfTransactionStatusDetails {
  dynamic qty;
  dynamic amount;
  String? placedDate;
  String? placedTime;
  String? transNo;
  String? remarks;
  String? buySell;
  String? allotmentStatusDate;
  dynamic allotmentUnits;
  dynamic allotmentAmount;
  String? orderStatusDate;
  String? orderStatusTime;
  String? allotmentStatus;
  String? allotmentColor;
  String? placedStatus;
  String? placedColor;
  String? orderStatus;
  String? orderColor;
  String? nfo;
  String? closeDate;
  String? closeDateMessage;
  String? transInfo;
  String? transStatus;
  String? status;
  String? errMsg;

  MfTransactionStatusDetails({
    this.qty,
    this.amount,
    this.placedDate,
    this.placedTime,
    this.transNo,
    this.remarks,
    this.buySell,
    this.allotmentStatusDate,
    this.allotmentUnits,
    this.allotmentAmount,
    this.orderStatusDate,
    this.orderStatusTime,
    this.allotmentStatus,
    this.allotmentColor,
    this.placedStatus,
    this.placedColor,
    this.orderStatus,
    this.orderColor,
    this.nfo,
    this.closeDate,
    this.closeDateMessage,
    this.transInfo,
    this.transStatus,
    this.status,
    this.errMsg,
  });

  factory MfTransactionStatusDetails.fromJson(Map<String, dynamic> json) =>
      MfTransactionStatusDetails(
        qty: json["qty"] ?? '',
        amount: json["amount"] ?? '',
        placedDate: json["placedDate"] ?? '',
        placedTime: json["placedTime"] ?? '',
        transNo: json["transNo"] ?? '',
        remarks: json["remarks"] ?? '',
        buySell: json["buySell"] ?? '',
        allotmentStatusDate: json["allotmentStatusDate"] ?? '',
        allotmentUnits: json["allotmentUnits"] ?? '',
        allotmentAmount: json["allotmentAmount"] ?? '',
        orderStatusDate: json["orderStatusDate"] ?? '',
        orderStatusTime: json["orderStatusTime"] ?? '',
        allotmentStatus: json["allotmentStatus"] ?? '',
        allotmentColor: json["allotmentColor"] ?? '',
        placedStatus: json["placedStatus"] ?? '',
        placedColor: json["placedColor"] ?? '',
        orderStatus: json["orderStatus"] ?? '',
        orderColor: json["orderColor"] ?? '',
        nfo: json["nfo"] ?? '',
        closeDate: json["closeDate"] ?? '',
        closeDateMessage: json["closeDateMessage"] ?? '',
        transInfo: json["transInfo"] ?? '',
        transStatus: json["transStatus"] ?? '',
        status: json["status"] ?? '',
        errMsg: json["errMsg"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "qty": qty,
        "amount": amount,
        "placedDate": placedDate,
        "placedTime": placedTime,
        "transNo": transNo,
        "remarks": remarks,
        "buySell": buySell,
        "allotmentStatusDate": allotmentStatusDate,
        "allotmentUnits": allotmentUnits,
        "allotmentAmount": allotmentAmount,
        "orderStatusDate": orderStatusDate,
        "orderStatusTime": orderStatusTime,
        "allotmentStatus": allotmentStatus,
        "allotmentColor": allotmentColor,
        "placedStatus": placedStatus,
        "placedColor": placedColor,
        "orderStatus": orderStatus,
        "orderColor": orderColor,
        "transInfo": transInfo,
        "transStatus": transStatus,
        "status": status,
        "errMsg": errMsg,
      };
}
