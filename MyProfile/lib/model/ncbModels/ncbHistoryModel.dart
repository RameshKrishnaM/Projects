// To parse this JSON data, do
//
//     final ncbHistoryModel = ncbHistoryModelFromJson(jsonString);

import 'dart:convert';

NcbHistoryModel ncbHistoryModelFromJson(String str) =>
    NcbHistoryModel.fromJson(json.decode(str));

String ncbHistoryModelToJson(NcbHistoryModel data) =>
    json.encode(data.toJson());

class NcbHistoryModel {
  List<OrderHistoryArr>? gSecOrderHistoryArr;
  List<OrderHistoryArr>? tBillOrderHistoryArr;
  List<OrderHistoryArr>? sdlOrderHistoryArr;
  int? orderCount;
  String? goihistoryFound;
  String? goihistorynoDataText;
  String? tbillhistoryFound;
  String? tbillhistorynoDataText;
  String? sdlhistoryFound;
  String? sdlhistorynoDataText;
  String? status;
  String? errMsg;

  NcbHistoryModel({
    this.gSecOrderHistoryArr,
    this.tBillOrderHistoryArr,
    this.sdlOrderHistoryArr,
    this.orderCount,
    this.goihistoryFound,
    this.goihistorynoDataText,
    this.tbillhistoryFound,
    this.tbillhistorynoDataText,
    this.sdlhistoryFound,
    this.sdlhistorynoDataText,
    this.status,
    this.errMsg,
  });

  factory NcbHistoryModel.fromJson(Map<String, dynamic> json) =>
      NcbHistoryModel(
        gSecOrderHistoryArr: json["gSecOrderHistoryArr"] == null
            ? []
            : List<OrderHistoryArr>.from(json["gSecOrderHistoryArr"]!
                .map((x) => OrderHistoryArr.fromJson(x))),
        tBillOrderHistoryArr: json["tBillOrderHistoryArr"] == null
            ? []
            : List<OrderHistoryArr>.from(json["tBillOrderHistoryArr"]!
                .map((x) => OrderHistoryArr.fromJson(x))),
        sdlOrderHistoryArr: json["sdlOrderHistoryArr"] == null
            ? []
            : List<OrderHistoryArr>.from(json["sdlOrderHistoryArr"]!
                .map((x) => OrderHistoryArr.fromJson(x))),
        orderCount: json["orderCount"] ?? 0,
        goihistoryFound: json["goihistoryFound"] ?? '',
        goihistorynoDataText: json["goihistorynoDataText"] ?? '',
        tbillhistoryFound: json["tbillhistoryFound"] ?? '',
        tbillhistorynoDataText: json["tbillhistorynoDataText"] ?? '',
        sdlhistoryFound: json["sdlhistoryFound"] ?? '',
        sdlhistorynoDataText: json["sdlhistorynoDataText"] ?? '',
        status: json["status"] ?? 'E',
        errMsg: json["errMsg"] ?? 'Error Occure.. ??' '',
      );

  Map<String, dynamic> toJson() => {
        "gSecOrderHistoryArr": gSecOrderHistoryArr == null
            ? []
            : List<dynamic>.from(gSecOrderHistoryArr!.map((x) => x.toJson())),
        "tBillOrderHistoryArr": tBillOrderHistoryArr == null
            ? []
            : List<dynamic>.from(tBillOrderHistoryArr!.map((x) => x.toJson())),
        "sdlOrderHistoryArr": sdlOrderHistoryArr == null
            ? []
            : List<dynamic>.from(sdlOrderHistoryArr!.map((x) => x.toJson())),
        "orderCount": orderCount,
        "goihistoryFound": goihistoryFound,
        "goihistorynoDataText": goihistorynoDataText,
        "tbillhistoryFound": tbillhistoryFound,
        "tbillhistorynoDataText": tbillhistorynoDataText,
        "sdlhistoryFound": sdlhistoryFound,
        "sdlhistorynoDataText": sdlhistorynoDataText,
        "status": status,
        "errMsg": errMsg,
      };
}

class OrderHistoryArr {
  int? id;
  String? symbol;
  String? name;
  String? series;
  String? applicationNo;
  String? orderNo;
  String? respOrderNo;
  String? orderDate;
  String? isin;
  String? dateRange;
  String? startDateWithTime;
  String? endDateWithTime;
  int? requestedUnit;
  int? requestedUnitPrice;
  int? requestedAmount;
  int? appliedUnit;
  int? appliedUnitPrice;
  int? appliedAmount;
  int? allotedUnit;
  int? allotedUnitPrice;
  int? allotedAmount;
  String? orderStatus;
  int? discountAmt;
  String? discountText;
  String? statusColor;
  int? sIvalue;
  String? sItext;
  String? rbiStatus;
  String? dpStatus;
  String? exchange;
  String? clientId;

  OrderHistoryArr({
    this.id,
    this.symbol,
    this.name,
    this.series,
    this.applicationNo,
    this.orderNo,
    this.respOrderNo,
    this.orderDate,
    this.isin,
    this.dateRange,
    this.startDateWithTime,
    this.endDateWithTime,
    this.requestedUnit,
    this.requestedUnitPrice,
    this.requestedAmount,
    this.appliedUnit,
    this.appliedUnitPrice,
    this.appliedAmount,
    this.allotedUnit,
    this.allotedUnitPrice,
    this.allotedAmount,
    this.orderStatus,
    this.discountAmt,
    this.discountText,
    this.statusColor,
    this.sIvalue,
    this.sItext,
    this.rbiStatus,
    this.dpStatus,
    this.exchange,
    this.clientId,
  });

  factory OrderHistoryArr.fromJson(Map<String, dynamic> json) =>
      OrderHistoryArr(
        id: json["id"] ?? 0,
        symbol: json["symbol"] ?? '',
        name: json["name"] ?? '',
        series: json["series"] ?? '',
        applicationNo: json["applicationNo"] ?? '',
        orderNo: json["orderNo"] ?? '',
        respOrderNo: json["respOrderNo"] ?? '',
        orderDate: json["orderDate"] ?? '',
        isin: json["isin"] ?? '',
        dateRange: json["dateRange"] ?? '',
        startDateWithTime: json["startDateWithTime"] ?? '',
        endDateWithTime: json["endDateWithTime"] ?? '',
        requestedUnit: json["requestedUnit"] ?? 0,
        requestedUnitPrice: json["requestedUnitPrice"] ?? 0,
        requestedAmount: json["requestedAmount"] ?? 0,
        appliedUnit: json["appliedUnit"] ?? 0,
        appliedUnitPrice: json["appliedUnitPrice"] ?? 0,
        appliedAmount: json["appliedAmount"] ?? 0,
        allotedUnit: json["allotedUnit"] ?? 0,
        allotedUnitPrice: json["allotedUnitPrice"] ?? 0,
        allotedAmount: json["allotedAmount"] ?? 0,
        orderStatus: json["orderStatus"] ?? '',
        discountAmt: json["discountAmt"] ?? 0,
        discountText: json["discountText"] ?? '',
        statusColor: json["statusColor"] ?? '',
        sIvalue: json["SIvalue"] ?? 0,
        sItext: json["SItext"] ?? '',
        rbiStatus: json["rbiStatus"] ?? '',
        dpStatus: json["dpStatus"] ?? '',
        exchange: json["exchange"] ?? '',
        clientId: json["clientId"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
        "series": series,
        "applicationNo": applicationNo,
        "orderNo": orderNo,
        "respOrderNo": respOrderNo,
        "orderDate": orderDate,
        "isin": isin,
        "dateRange": dateRange,
        "startDateWithTime": startDateWithTime,
        "endDateWithTime": endDateWithTime,
        "requestedUnit": requestedUnit,
        "requestedUnitPrice": requestedUnitPrice,
        "requestedAmount": requestedAmount,
        "appliedUnit": appliedUnit,
        "appliedUnitPrice": appliedUnitPrice,
        "appliedAmount": appliedAmount,
        "allotedUnit": allotedUnit,
        "allotedUnitPrice": allotedUnitPrice,
        "allotedAmount": allotedAmount,
        "orderStatus": orderStatus,
        "discountAmt": discountAmt,
        "discountText": discountText,
        "statusColor": statusColor,
        "SIvalue": sIvalue,
        "SItext": sItext,
        "rbiStatus": rbiStatus,
        "dpStatus": dpStatus,
        "exchange": exchange,
        "clientId": clientId,
      };
}
