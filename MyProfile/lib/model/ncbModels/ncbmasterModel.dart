// To parse this JSON data, do
//
//     final ncbMasterDetails = ncbMasterDetailsFromJson(jsonString);

import 'dart:convert';

NcbMasterDetails ncbMasterDetailsFromJson(String str) =>
    NcbMasterDetails.fromJson(json.decode(str));

String ncbMasterDetailsToJson(NcbMasterDetails data) =>
    json.encode(data.toJson());

class NcbMasterDetails {
  List<Detail>? gSecDetail;
  List<Detail>? tBillDetail;
  List<Detail>? sdlDetail;
  String? disclaimer;
  String? goimasterFound;
  String? goinoDataText;
  String? tbillmasterFound;
  String? tbillnoDataText;
  String? sdlmasterFound;
  String? sdlnoDataText;
  int? investCount;
  String? status;
  String? errMsg;

  NcbMasterDetails({
    this.gSecDetail,
    this.tBillDetail,
    this.sdlDetail,
    this.disclaimer,
    this.goimasterFound,
    this.goinoDataText,
    this.tbillmasterFound,
    this.tbillnoDataText,
    this.sdlmasterFound,
    this.sdlnoDataText,
    this.investCount,
    this.status,
    this.errMsg,
  });

  factory NcbMasterDetails.fromJson(Map<String, dynamic> json) =>
      NcbMasterDetails(
        gSecDetail: json["gSecDetail"] == null
            ? []
            : List<Detail>.from(
                json["gSecDetail"]!.map((x) => Detail.fromJson(x))),
        tBillDetail: json["tBillDetail"] == null
            ? []
            : List<Detail>.from(
                json["tBillDetail"]!.map((x) => Detail.fromJson(x))),
        sdlDetail: json["sdlDetail"] == null
            ? []
            : List<Detail>.from(
                json["sdlDetail"]!.map((x) => Detail.fromJson(x))),
        disclaimer: json["disclaimer"] ?? '',
        goimasterFound: json["goimasterFound"] ?? '',
        goinoDataText: json["goinoDataText"] ?? '',
        tbillmasterFound: json["tbillmasterFound"] ?? '',
        tbillnoDataText: json["tbillnoDataText"] ?? '',
        sdlmasterFound: json["sdlmasterFound"] ?? '',
        sdlnoDataText: json["sdlnoDataText"] ?? '',
        investCount: json["investCount"] ?? 0,
        status: json["status"] ?? 'E',
        errMsg: json["errMsg"] ?? 'Error Occure...',
      );

  Map<String, dynamic> toJson() => {
        "gSecDetail": gSecDetail == null
            ? []
            : List<dynamic>.from(gSecDetail!.map((x) => x.toJson())),
        "tBillDetail": tBillDetail == null
            ? []
            : List<dynamic>.from(tBillDetail!.map((x) => x.toJson())),
        "sdlDetail": sdlDetail == null
            ? []
            : List<dynamic>.from(sdlDetail!.map((x) => x.toJson())),
        "disclaimer": disclaimer,
        "goimasterFound": goimasterFound,
        "goinoDataText": goinoDataText,
        "tbillmasterFound": tbillmasterFound,
        "tbillnoDataText": tbillnoDataText,
        "sdlmasterFound": sdlmasterFound,
        "sdlnoDataText": sdlnoDataText,
        "investCount": investCount,
        "status": status,
        "errMsg": errMsg,
      };
}

class Detail {
  int? id;
  String? symbol;
  String? series;
  String? name;
  String? indicativeYield;
  int? minBidQuantity;
  int? maxBidQuantity;
  int? multiples;
  String? totalQuantity;
  String? isin;
  int? unitPrice;
  int? amount;
  String? dateRange;
  String? startDateWithTime;
  String? endDateWithTime;
  int? discountAmt;
  String? discountText;
  String? actionFlag;
  String? buttonText;
  int? appliedUnit;
  bool? disableActionBtn;
  bool? cancelAllowed;
  bool? modifyAllowed;
  int? orderNo;
  String? applicationNo;
  bool? showSi;
  String? sItext;
  String? sIrefundText;
  bool? sIvalue;
  String? infoText;
  String? settlementDate;
  String? maturityDate;

  Detail(
      {this.id,
      this.symbol,
      this.series,
      this.name,
      this.indicativeYield,
      this.minBidQuantity,
      this.maxBidQuantity,
      this.multiples,
      this.totalQuantity,
      this.isin,
      this.unitPrice,
      this.amount,
      this.dateRange,
      this.startDateWithTime,
      this.endDateWithTime,
      this.discountAmt,
      this.discountText,
      this.actionFlag,
      this.buttonText,
      this.appliedUnit,
      this.disableActionBtn,
      this.cancelAllowed,
      this.modifyAllowed,
      this.orderNo,
      this.applicationNo,
      this.showSi,
      this.sItext,
      this.sIrefundText,
      this.sIvalue,
      this.infoText,
      this.settlementDate,
      this.maturityDate});

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["id"] ?? 0,
        symbol: json["symbol"] ?? '',
        series: json["series"] ?? '',
        name: json["name"] ?? '',
        indicativeYield: json["indicativeYield"] ?? '',
        minBidQuantity: json["minBidQuantity"] ?? 0,
        maxBidQuantity: json["maxBidQuantity"] ?? 0,
        multiples: json["multiples"] ?? 0,
        totalQuantity: json["totalQuantity"] ?? '',
        isin: json["isin"] ?? '',
        unitPrice: json["unitPrice"] ?? 0,
        amount: json["amount"] ?? 0,
        dateRange: json["dateRange"] ?? '',
        startDateWithTime: json["startDateWithTime"] ?? '',
        endDateWithTime: json["endDateWithTime"] ?? '',
        discountAmt: json["discountAmt"] ?? 0,
        discountText: json["discountText"] ?? '',
        actionFlag: json["actionFlag"] ?? '',
        buttonText: json["buttonText"] ?? '',
        appliedUnit: json["appliedUnit"] ?? 0,
        disableActionBtn: json["disableActionBtn"] ?? true,
        cancelAllowed: json["cancelAllowed"] ?? false,
        modifyAllowed: json["modifyAllowed"] ?? false,
        orderNo: json["orderNo"] ?? 0,
        applicationNo: json["applicationNo"] ?? '',
        showSi: json["showSI"] ?? false,
        sItext: json["SItext"] ?? '',
        sIrefundText: json["SIrefundText"] ?? '',
        sIvalue: json["SIvalue"] ?? false,
        infoText: json["infoText"] ?? '',
        settlementDate: json["settlementDate"] ?? '',
        maturityDate: json["maturityDate"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "series": series,
        "name": name,
        "indicativeYield": indicativeYield,
        "minBidQuantity": minBidQuantity,
        "maxBidQuantity": maxBidQuantity,
        "multiples": multiples,
        "totalQuantity": totalQuantity,
        "isin": isin,
        "unitPrice": unitPrice,
        "amount": amount,
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
        "applicationNo": applicationNo,
        "showSI": showSi,
        "SItext": sItext,
        "SIrefundText": sIrefundText,
        "SIvalue": sIvalue,
        "infoText": infoText,
        "settlementDate": settlementDate,
        "maturityDate": maturityDate,
      };
}
