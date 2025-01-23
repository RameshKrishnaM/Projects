// To parse this JSON data, do
//
//     final ipoMktDemandModel = ipoMktDemandModelFromJson(jsonString);

import 'dart:convert';

IpoMktDemandModel ipoMktDemandModelFromJson(String str) =>
    IpoMktDemandModel.fromJson(json.decode(str));

String ipoMktDemandModelToJson(IpoMktDemandModel data) =>
    json.encode(data.toJson());

class IpoMktDemandModel {
  int? totalQty;
  String? totalQtywithText;
  String? subscriptionText;
  List<IpoMktDemandArr>? ipoMktDemandArr;
  List<IpoMktCatwiseArr>? ipoMktCatwiseArr;
  String? noDataText;
  String? status;
  String? errMsg;

  IpoMktDemandModel({
    this.totalQty,
    this.totalQtywithText,
    this.subscriptionText,
    this.ipoMktDemandArr,
    this.ipoMktCatwiseArr,
    this.noDataText,
    this.status,
    this.errMsg,
  });

  factory IpoMktDemandModel.fromJson(Map<String, dynamic> json) =>
      IpoMktDemandModel(
        totalQty: json["totalQty"] ?? 0,
        totalQtywithText: json["totalQtywithText"] ?? '0',
        subscriptionText: json["subscriptionText"] ?? '0',
        ipoMktDemandArr: json["ipoMktDemandArr"] == null
            ? []
            : List<IpoMktDemandArr>.from(json["ipoMktDemandArr"]!
                .map((x) => IpoMktDemandArr.fromJson(x))),
        ipoMktCatwiseArr: json["ipoMktCatwiseArr"] == null
            ? []
            : List<IpoMktCatwiseArr>.from(json["ipoMktCatwiseArr"]!
                .map((x) => IpoMktCatwiseArr.fromJson(x))),
        noDataText: json["noDataText"] ?? '',
        status: json["status"] ?? '',
        errMsg: json["errMsg"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "totalQty": totalQty,
        "totalQtywithText": totalQtywithText,
        "subscriptionText": subscriptionText,
        "ipoMktDemandArr": ipoMktDemandArr == null
            ? []
            : List<dynamic>.from(ipoMktDemandArr!.map((x) => x.toJson())),
        "ipoMktCatwiseArr": ipoMktCatwiseArr == null
            ? []
            : List<dynamic>.from(ipoMktCatwiseArr!.map((x) => x.toJson())),
        "noDataText": noDataText,
        "status": status,
        "errMsg": errMsg,
      };
}

class IpoMktCatwiseArr {
  String? category;
  String? quantity;

  IpoMktCatwiseArr({
    this.category,
    this.quantity,
  });

  factory IpoMktCatwiseArr.fromJson(Map<String, dynamic> json) =>
      IpoMktCatwiseArr(
        category: json["category"] ?? '',
        quantity: json["quantity"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "quantity": quantity,
      };
}

class IpoMktDemandArr {
  String? price;
  String? quantity;
  bool? cutoff;

  IpoMktDemandArr({
    this.price,
    this.quantity,
    this.cutoff,
  });

  factory IpoMktDemandArr.fromJson(Map<String, dynamic> json) =>
      IpoMktDemandArr(
        price: json["price"] ?? '',
        quantity: json["quantity"] ?? '',
        cutoff: json["cutoff"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "quantity": quantity,
        "cutoff": cutoff,
      };
}
