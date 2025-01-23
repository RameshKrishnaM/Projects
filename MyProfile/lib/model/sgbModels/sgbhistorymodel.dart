// To parse this JSON data, do
//
//     final sgbHistory = sgbHistoryFromJson(jsonString);

import 'dart:convert';

SgbHistory sgbHistoryFromJson(String str) =>
    SgbHistory.fromJson(json.decode(str));

String sgbHistoryToJson(SgbHistory data) => json.encode(data.toJson());

class SgbHistory {
  List<SgbOrderHistoryArr>? sgbOrderHistoryArr;
  int orderCount;
  String historyFound;
  String historynoDataText;
  String status;
  String errMsg;

  SgbHistory({
    this.sgbOrderHistoryArr,
    this.orderCount = 0,
    this.historyFound = '',
    this.historynoDataText = '',
    this.status = 'E',
    this.errMsg = 'Error Occurs',
  });

  factory SgbHistory.fromJson(Map<String, dynamic> json) => SgbHistory(
        sgbOrderHistoryArr: List<SgbOrderHistoryArr>.from(
            json["sgbOrderHistoryArr"] == null
                ? []
                : json["sgbOrderHistoryArr"]
                    .map((x) => SgbOrderHistoryArr.fromJson(x))),
        orderCount: int.parse(json["orderCount"].toString()),
        historyFound: json["historyFound"] ?? '',
        historynoDataText: json["historynoDataText"] ?? '',
        status: json["status"] ?? '',
        errMsg: json["errMsg"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "sgbOrderHistoryArr": sgbOrderHistoryArr == null
            ? []
            : List<dynamic>.from(sgbOrderHistoryArr!.map((x) => x.toJson())),
        "orderCount": orderCount,
        "historyFound": historyFound,
        "historynoDataText": historynoDataText,
        "status": status,
        "errMsg": errMsg,
      };
}

class SgbOrderHistoryArr {
  int id;
  String symbol;
  String name;
  String orderNo;
  String exchOrderNo;
  String orderDate;
  String isin;
  String dateRange;
  String startDateWithTime;
  String endDateWithTime;
  int requestedUnit;
  int requestedUnitPrice;
  int requestedAmount;
  int appliedUnit;
  int appliedUnitPrice;
  int appliedAmount;
  int allotedUnit;
  int allotedUnitPrice;
  int allotedAmount;
  String orderStatus;
  int discountAmt;
  String discountText;
  String statusColor;
  int sIvalue;
  String sItext;
  String rbiStatus;
  String dpStatus;
  String exchange;
  String clientId;

  SgbOrderHistoryArr({
    this.id = 0,
    this.symbol = '',
    this.name = '',
    this.orderNo = '',
    this.exchOrderNo = '',
    this.orderDate = '',
    this.isin = '',
    this.dateRange = '',
    this.startDateWithTime = '',
    this.endDateWithTime = '',
    this.requestedUnit = 0,
    this.requestedUnitPrice = 0,
    this.requestedAmount = 0,
    this.appliedUnit = 0,
    this.appliedUnitPrice = 0,
    this.appliedAmount = 0,
    this.allotedUnit = 0,
    this.allotedUnitPrice = 0,
    this.allotedAmount = 0,
    this.orderStatus = '',
    this.discountAmt = 0,
    this.discountText = '',
    this.statusColor = '',
    this.sIvalue = 0,
    this.sItext = '',
    this.rbiStatus = '',
    this.dpStatus = '',
    this.exchange = '',
    this.clientId = '',
  });

  factory SgbOrderHistoryArr.fromJson(Map<String, dynamic> json) =>
      SgbOrderHistoryArr(
        id: int.parse(json["id"].toString()),
        symbol: json["symbol"] ?? '',
        name: json["name"] ?? '',
        orderNo: json["orderNo"] ?? '',
        exchOrderNo: json["exchOrderNo"] ?? '',
        orderDate: json["orderDate"] ?? '',
        isin: json["isin"] ?? '',
        dateRange: json["dateRange"] ?? '',
        startDateWithTime: json["startDateWithTime"] ?? '',
        endDateWithTime: json["endDateWithTime"] ?? '',
        requestedUnit: int.parse(json["requestedUnit"].toString()),
        requestedUnitPrice: int.parse(json["requestedUnitPrice"].toString()),
        requestedAmount: int.parse(json["requestedAmount"].toString()),
        appliedUnit: int.parse(json["appliedUnit"].toString()),
        appliedUnitPrice: int.parse(json["appliedUnitPrice"].toString()),
        appliedAmount: int.parse(json["appliedAmount"].toString()),
        allotedUnit: int.parse(json["allotedUnit"].toString()),
        allotedUnitPrice: int.parse(json["allotedUnitPrice"].toString()),
        allotedAmount: int.parse(json["allotedAmount"].toString()),
        orderStatus: json["orderStatus"] ?? '',
        discountAmt: int.parse(json["discountAmt"].toString()),
        discountText: json["discountText"] ?? '',
        statusColor: json["statusColor"] ?? '',
        sIvalue: int.parse(json["sIvalue"] ?? 0.toString()),
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
        "orderNo": orderNo,
        "exchOrderNo": exchOrderNo,
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
