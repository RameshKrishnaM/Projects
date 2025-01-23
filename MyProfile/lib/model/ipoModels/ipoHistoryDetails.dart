// To parse this JSON data, do
//
//     final ipoHistoryDetails = ipoHistoryDetailsFromJson(jsonString);

import 'dart:convert';

IpoHistoryDetails ipoHistoryDetailsFromJson(String str) =>
    IpoHistoryDetails.fromJson(json.decode(str));

String ipoHistoryDetailsToJson(IpoHistoryDetails data) =>
    json.encode(data.toJson());

class IpoHistoryDetails {
  List<HistoryDetail>? historyDetail;
  String? historyNoDataText;
  String? historyFound;
  int? orderCount;
  String? status;
  String? errMsg;

  IpoHistoryDetails({
    this.historyDetail,
    this.historyNoDataText,
    this.historyFound,
    this.orderCount,
    this.status,
    this.errMsg,
  });

  factory IpoHistoryDetails.fromJson(Map<String, dynamic> json) =>
      IpoHistoryDetails(
        historyDetail: json["historyDetail"] == null
            ? []
            : List<HistoryDetail>.from(
                json["historyDetail"]!.map((x) => HistoryDetail.fromJson(x))),
        historyNoDataText: json["historyNoDataText"] ?? '',
        historyFound: json["historyFound"] ?? '',
        orderCount: json["orderCount"] ?? 0,
        status: json["status"] ?? '',
        errMsg: json["errMsg"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "historyDetail": historyDetail == null
            ? []
            : List<dynamic>.from(historyDetail!.map((x) => x.toJson())),
        "historyNoDataText": historyNoDataText,
        "historyFound": historyFound,
        "orderCount": orderCount,
        "status": status,
        "errMsg": errMsg,
      };
}

class HistoryDetail {
  int? id;
  int? masterId;
  String? name;
  String? symbol;
  String? orderDate;
  String? dateRange;
  String? priceRange;
  int? lotSize;
  String? issueSizeWithText;
  bool? sme;
  String? exchange;
  String? status;
  String? statusColor;
  String? clientId;
  String? dpStatus;
  String? upiStatus;
  String? errReason;
  CategoryList? categoryList;
  String? registarLink;
  String? cancelFlag;
  String? startDate;
  String? endDate;
  String? allotment;
  String? refund;
  String? demat;
  String? listing;

  HistoryDetail({
    this.id,
    this.masterId,
    this.name,
    this.symbol,
    this.orderDate,
    this.dateRange,
    this.priceRange,
    this.lotSize,
    this.issueSizeWithText,
    this.sme,
    this.exchange,
    this.status,
    this.statusColor,
    this.clientId,
    this.dpStatus,
    this.upiStatus,
    this.errReason,
    this.categoryList,
    this.registarLink,
    this.cancelFlag,
    this.startDate,
    this.endDate,
    this.allotment,
    this.refund,
    this.demat,
    this.listing,
  });

  factory HistoryDetail.fromJson(Map<String, dynamic> json) => HistoryDetail(
        id: json["id"] ?? 0,
        masterId: json["masterId"] ?? 0,
        name: json["name"] ?? '',
        symbol: json["symbol"] ?? '',
        orderDate: json["orderDate"] ?? '',
        dateRange: json["dateRange"] ?? '',
        priceRange: json["priceRange"] ?? '',
        lotSize: json["lotSize"] ?? 0,
        issueSizeWithText: json["issueSizeWithText"] ?? '',
        sme: json["sme"] ?? false,
        exchange: json["exchange"] ?? '',
        status: json["status"] ?? '',
        statusColor: json["statusColor"] ?? '',
        clientId: json["clientId"] ?? '',
        dpStatus: json["dpStatus"] ?? '',
        upiStatus: json["upiStatus"] ?? '',
        errReason: json["errReason"] ?? '',
        categoryList: json["categoryList"] == null
            ? null
            : CategoryList.fromJson(json["categoryList"]),
        registarLink: json["registarLink"] ?? '',
        cancelFlag: json["cancelFlag"] ?? '',
        startDate: json["startDate"] ?? ''
        //  == null
        //     ? null
        //     : String.parse(json["startDate"])
        ,
        endDate: json["endDate"] ?? ''
        // == null ? null : String.parse(json["endDate"])
        ,
        allotment: json["allotment"] ?? '',
        refund: json["refund"] ?? '',
        demat: json["demat"] ?? '',
        listing: json["listing"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "masterId": masterId,
        "name": name,
        "symbol": symbol,
        "orderDate": orderDate,
        "dateRange": dateRange,
        "priceRange": priceRange,
        "lotSize": lotSize,
        "issueSizeWithText": issueSizeWithText,
        "sme": sme,
        "exchange": exchange,
        "status": status,
        "statusColor": statusColor,
        "clientId": clientId,
        "dpStatus": dpStatus,
        "upiStatus": upiStatus,
        "errReason": errReason,
        "categoryList": categoryList?.toJson(),
        "registarLink": registarLink,
        "cancelFlag": cancelFlag,
        "startDate": startDate,
        // "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "endDate": endDate,
        // "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "allotment": allotment,
        "refund": refund,
        "demat": demat,
        "listing": listing,
      };
}

class CategoryList {
  String? category;
  String? code;
  String? applicationNo;
  String? discountText;
  int? discountPrice;
  String? discountType;
  AppliedDetail? appliedDetail;

  CategoryList({
    this.category,
    this.code,
    this.applicationNo,
    this.discountText,
    this.discountPrice,
    this.discountType,
    this.appliedDetail,
  });

  factory CategoryList.fromJson(Map<String, dynamic> json) => CategoryList(
        category: json["category"] ?? '',
        code: json["code"] ?? '',
        applicationNo: json["applicationNo"] ?? '',
        discountText: json["discountText"] ?? '',
        discountPrice: json["discountPrice"] ?? 0,
        discountType: json["discountType"] ?? '',
        appliedDetail: json["appliedDetail"] == null
            ? null
            : AppliedDetail.fromJson(json["appliedDetail"]),
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "code": code,
        "applicationNo": applicationNo,
        "discountText": discountText,
        "discountPrice": discountPrice,
        "discountType": discountType,
        "appliedDetail": appliedDetail?.toJson(),
      };
}

class AppliedDetail {
  String? appliedUpi;
  int? appliedAmount;
  List<AppliedBid>? appliedBids;

  AppliedDetail({
    this.appliedUpi,
    this.appliedAmount,
    this.appliedBids,
  });

  factory AppliedDetail.fromJson(Map<String, dynamic> json) => AppliedDetail(
        appliedUpi: json["appliedUPI"] ?? '',
        appliedAmount: json["appliedAmount"] ?? 0,
        appliedBids: json["appliedBids"] == null
            ? []
            : List<AppliedBid>.from(
                json["appliedBids"]!.map((x) => AppliedBid.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "appliedUPI": appliedUpi,
        "appliedAmount": appliedAmount,
        "appliedBids": appliedBids == null
            ? []
            : List<dynamic>.from(appliedBids!.map((x) => x.toJson())),
      };
}

class AppliedBid {
  int? id;
  String? activityType;
  String? bidReferenceNo;
  int? quantity;
  int? price;
  int? amount;
  bool? cutOff;

  AppliedBid({
    this.id,
    this.activityType,
    this.bidReferenceNo,
    this.quantity,
    this.price,
    this.amount,
    this.cutOff,
  });

  factory AppliedBid.fromJson(Map<String, dynamic> json) => AppliedBid(
        id: json["id"] ?? 0,
        activityType: json["activityType"] ?? '',
        bidReferenceNo: json["bidReferenceNo"] ?? '',
        quantity: json["quantity"] ?? 0,
        price: json["price"] ?? 0,
        amount: json["amount"] ?? 0,
        cutOff: json["cutOff"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "activityType": activityType,
        "bidReferenceNo": bidReferenceNo,
        "quantity": quantity,
        "price": price,
        "amount": amount,
        "cutOff": cutOff,
      };
}
