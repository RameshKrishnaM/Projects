// To parse this JSON data, do
//
//     final sgbMasterDetail = sgbMasterDetailFromJson(jsonString);

import 'dart:convert';

SgbMasterDetail sgbMasterDetailFromJson(String str) =>
    SgbMasterDetail.fromJson(json.decode(str));

String sgbMasterDetailToJson(SgbMasterDetail data) =>
    json.encode(data.toJson());

class SgbMasterDetail {
  List<SgbDetail>? sgbDetail;
  String disclaimer;
  String masterFound;
  String noDataText;
  int investCount;
  String status;
  String errMsg;

  SgbMasterDetail({
    this.sgbDetail,
    this.disclaimer = '',
    this.masterFound = '',
    this.noDataText = '',
    this.investCount = 0,
    this.status = 'E',
    this.errMsg = 'Error Occurs...',
  });

  factory SgbMasterDetail.fromJson(Map<String, dynamic> json) =>
      SgbMasterDetail(
        sgbDetail: List<SgbDetail>.from(json["sgbDetail"] == null
            ? []
            : json["sgbDetail"].map((x) => SgbDetail.fromJson(x))),
        disclaimer: json["disclaimer"] ?? '',
        masterFound: json["masterFound"] ?? '',
        noDataText: json["noDataText"] ?? '',
        investCount: int.parse(json["investCount"].toString()),
        status: json["status"] ?? '',
        errMsg: json["errMsg"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "sgbDetail": sgbDetail == null
            ? []
            : List<dynamic>.from(sgbDetail!.map((x) => x.toJson())),
        "disclaimer": disclaimer,
        "masterFound": masterFound,
        "noDataText": noDataText,
        "investCount": investCount,
        "status": status,
        "errMsg": errMsg,
      };
}

class SgbDetail {
  int id;
  String symbol;
  String name;
  int minBidQty;
  int maxBidQty;
  String isin;
  int unitPrice;
  String dateRange;
  String startDateWithTime;
  String endDateWithTime;
  int discountAmt;
  String discountText;
  String actionFlag;
  String buttonText;
  int appliedUnit;
  bool? disableActionBtn;
  bool? cancelAllowed;
  bool? modifyAllowed;
  String orderNo;
  String sItext;
  String sIrefundText;
  bool? sIvalue;
  String infoText;
  bool? showSI;

  SgbDetail({
    this.id = 0,
    this.symbol = '',
    this.name = '',
    this.minBidQty = 0,
    this.maxBidQty = 0,
    this.isin = '',
    this.unitPrice = 0,
    this.dateRange = '',
    this.startDateWithTime = '',
    this.endDateWithTime = '',
    this.discountAmt = 0,
    this.discountText = '',
    this.actionFlag = '',
    this.buttonText = '',
    this.appliedUnit = 0,
    disableActionBtn,
    cancelAllowed,
    modifyAllowed,
    this.orderNo = '',
    this.sItext = '',
    this.sIrefundText = '',
    sIvalue,
    this.infoText = '',
    showSI,
  }) {
    this.disableActionBtn =
        disableActionBtn == 0 || disableActionBtn == false ? false : true;
    this.cancelAllowed =
        cancelAllowed == 1 || cancelAllowed == true ? true : false;
    this.modifyAllowed =
        modifyAllowed == 1 || modifyAllowed == true ? true : false;
    this.sIvalue = sIvalue == 1 || sIvalue == true ? true : false;
    this.showSI = showSI == 1 || showSI == true ? true : false;
  }

  factory SgbDetail.fromJson(Map<String, dynamic> json) => SgbDetail(
        id: int.parse(json["id"].toString()),
        symbol: json["symbol"] ?? '',
        name: json["name"] ?? '',
        minBidQty: int.parse(json["minBidQty"].toString()),
        maxBidQty: int.parse(json["maxBidQty"].toString()),
        isin: json["isin"] ?? '',
        unitPrice: int.parse(json["unitPrice"].toString()),
        dateRange: json["dateRange"] ?? '',
        startDateWithTime: json["startDateWithTime"] ?? '',
        endDateWithTime: json["endDateWithTime"] ?? '',
        discountAmt: int.parse(json["discountAmt"].toString()),
        discountText: json["discountText"] ?? '',
        actionFlag: json["actionFlag"] ?? '',
        buttonText: json["buttonText"] ?? '',
        appliedUnit: int.parse(json["appliedUnit"].toString()),
        disableActionBtn: json["disableActionBtn"] ?? '',
        cancelAllowed: json["cancelAllowed"] ?? '',
        modifyAllowed: json["modifyAllowed"] ?? '',
        orderNo: json["orderNo"] ?? '',
        sItext: json["SItext"] ?? '',
        sIrefundText: json["SIrefundText"] ?? '',
        sIvalue: json["SIvalue"] ?? false,
        infoText: json["infoText"] ?? '',
        showSI: json["showSI"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
        "minBidQty": minBidQty,
        "maxBidQty": maxBidQty,
        "isin": isin,
        "unitPrice": unitPrice,
        "dateRange": dateRange,
        "startDateWithTime": startDateWithTime,
        "endDateWithTime": endDateWithTime,
        "discountAmt": discountAmt,
        "discountText": discountText,
        "actionFlag": actionFlag,
        "buttonText": buttonText,
        "appliedUnit": appliedUnit,
        "disableActionBtn": disableActionBtn,
        "cancelAllowed": cancelAllowed,
        "modifyAllowed": modifyAllowed,
        "orderNo": orderNo,
        "SItext": sItext,
        "SIrefundText": sIrefundText,
        "SIvalue": sIvalue,
        "infoText": infoText,
        "showSI": showSI,
      };
}
