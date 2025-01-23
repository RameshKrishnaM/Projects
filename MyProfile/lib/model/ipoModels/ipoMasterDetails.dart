// To parse this JSON data, do
//
//     final ipoMasterDetails = ipoMasterDetailsFromJson(jsonString);

import 'dart:convert';

IpoMasterDetails ipoMasterDetailsFromJson(String str) =>
    IpoMasterDetails.fromJson(json.decode(str));

String ipoMasterDetailsToJson(IpoMasterDetails data) =>
    json.encode(data.toJson());

class IpoMasterDetails {
  List<IpoDetail>? ipoDetail;
  String? policyText;
  String? suggestUpi;
  String? masterNoDataText;
  String? masterFound;
  int? investCount;
  dynamic disclaimer;
  String? offlineIndicator;
  String? offlineText;
  String? status;
  String? errMsg;

  IpoMasterDetails({
    this.ipoDetail,
    this.policyText,
    this.suggestUpi,
    this.masterNoDataText,
    this.masterFound,
    this.investCount,
    this.disclaimer,
    this.offlineIndicator,
    this.offlineText,
    this.status,
    this.errMsg,
  });

  factory IpoMasterDetails.fromJson(Map<String, dynamic> json) =>
      IpoMasterDetails(
        ipoDetail: json["ipoDetail"] == null
            ? []
            : List<IpoDetail>.from(
                json["ipoDetail"]!.map((x) => IpoDetail.fromJson(x))),
        policyText: json["policyText"] ?? '',
        suggestUpi: json["suggestUPI"] ?? '',
        masterNoDataText: json["masterNoDataText"] ?? '',
        masterFound: json["masterFound"] ?? '',
        investCount: json["investCount"] ?? 0,
        disclaimer: json["disclaimer"] ?? [],
        offlineIndicator: json["offlineIndicator"] ?? '',
        offlineText: json["offlineText"] ?? '',
        status: json["status"] ?? '',
        errMsg: json["errMsg"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "ipoDetail": ipoDetail == null
            ? []
            : List<dynamic>.from(ipoDetail!.map((x) => x.toJson())),
        "policyText": policyText,
        "suggestUPI": suggestUpi,
        "masterNoDataText": masterNoDataText,
        "masterFound": masterFound,
        "investCount": investCount,
        "disclaimer": disclaimer,
        "offlineIndicator": offlineIndicator,
        "offlineText": offlineText,
        "status": status,
        "errMsg": errMsg,
      };
}

class IpoDetail {
  int? id;
  String? name;
  String? symbol;
  String? dateRange;
  String? priceRange;
  int? minBidQuantity;
  int? minPrice;
  int? cutOffPrice;
  int? lotSize;
  int? issueSize;
  String? issueSizeWithText;
  dynamic? cutOffFlag;
  String? actionFlag;
  String? preApply;
  String? ipoPurchased;
  String? buttonText;
  bool? sme;
  String? smeText;
  String? blogLink;
  String? drhpLink;
  bool? disableActionBtn;
  String? exchange;
  List<CategoryList>? categoryList;

  IpoDetail({
    this.id,
    this.name,
    this.symbol,
    this.dateRange,
    this.priceRange,
    this.minBidQuantity,
    this.minPrice,
    this.cutOffPrice,
    this.lotSize,
    this.issueSize,
    this.issueSizeWithText,
    this.cutOffFlag,
    this.actionFlag,
    this.preApply,
    this.ipoPurchased,
    this.buttonText,
    this.sme,
    this.smeText,
    this.blogLink,
    this.drhpLink,
    this.disableActionBtn,
    this.exchange,
    this.categoryList,
  });

  factory IpoDetail.fromJson(Map<String, dynamic> json) => IpoDetail(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        symbol: json["symbol"] ?? '',
        dateRange: json["dateRange"] ?? '',
        priceRange: json["priceRange"] ?? '',
        minBidQuantity: json["minBidQuantity"] ?? 0,
        minPrice: json["minPrice"] ?? 0,
        cutOffPrice: json["cutOffPrice"] ?? 0,
        lotSize: json["lotSize"] ?? 0,
        issueSize: json["issueSize"] ?? 0,
        issueSizeWithText: json["issueSizeWithText"] ?? '',
        cutOffFlag: json["cutOffFlag"] ?? false,
        actionFlag: json["actionFlag"] ?? '',
        preApply: json["preApply"] ?? '',
        ipoPurchased: json["ipoPurchased"] ?? '',
        buttonText: json["buttonText"] ?? '',
        sme: json["sme"] ?? false,
        smeText: json["smeText"] ?? '',
        blogLink: json["blogLink"] ?? '',
        drhpLink: json["drhpLink"] ?? '',
        disableActionBtn: json["disableActionBtn"] ?? true,
        exchange: json["exchange"] ?? '',
        categoryList: json["categoryList"] == null
            ? []
            : List<CategoryList>.from(
                json["categoryList"]!.map((x) => CategoryList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "symbol": symbol,
        "dateRange": dateRange,
        "priceRange": priceRange,
        "minBidQuantity": minBidQuantity,
        "minPrice": minPrice,
        "cutOffPrice": cutOffPrice,
        "lotSize": lotSize,
        "issueSize": issueSize,
        "issueSizeWithText": issueSizeWithText,
        "cutOffFlag": cutOffFlag,
        "actionFlag": actionFlag,
        "preApply": preApply,
        "ipoPurchased": ipoPurchased,
        "buttonText": buttonText,
        "sme": sme,
        "smeText": smeText,
        "blogLink": blogLink,
        "drhpLink": drhpLink,
        "disableActionBtn": disableActionBtn,
        "exchange": exchange,
        "categoryList": categoryList == null
            ? []
            : List<dynamic>.from(categoryList!.map((x) => x.toJson())),
      };
}

class CategoryList {
  String? category;
  String? categoryButtonText;
  String? code;
  String? purchaseFlag;
  String? applicationNo;
  int? minimumlot;
  int? minValue;
  int? maxValue;
  String? discountText;
  int? discountPrice;
  String? discountType;
  bool? modifyAllowed;
  bool? cancelAllowed;
  bool? showDiscount;
  String? infoText;
  bool? cutOffFlag;
  AppliedDetail? appliedDetail;
  bool? showSi;
  String? sItext;
  bool? sIvalue;
  String? subCategoryFound;
  List<String>? subcategoryOptions;
  List<CategoryList>? subCategoryList;
  // SubCategoryList? subCategoryList;

  String? subCategoryInfoText;
  String? categoryorderText;
  String? hniRangeText;
  String? hniModifyInfoText;
  String? indRangeText;
  List<dynamic>? categorydisclaimerText;

  CategoryList({
    this.category,
    this.categoryButtonText,
    this.code,
    this.purchaseFlag,
    this.applicationNo,
    this.minimumlot,
    this.minValue,
    this.maxValue,
    this.discountText,
    this.discountPrice,
    this.discountType,
    this.modifyAllowed,
    this.cancelAllowed,
    this.showDiscount,
    this.infoText,
    this.cutOffFlag,
    this.appliedDetail,
    this.showSi,
    this.sItext,
    this.sIvalue,
    this.subCategoryFound,
    this.subcategoryOptions,
    this.subCategoryList,
    this.hniRangeText,
    this.hniModifyInfoText,
    this.indRangeText,
    this.categorydisclaimerText,
    this.subCategoryInfoText,
    this.categoryorderText,
  });

  factory CategoryList.fromJson(Map<String, dynamic> json) => CategoryList(
        category: json["category"] ?? '',
        categoryButtonText: json["categoryButtonText"] ?? '',
        code: json["code"] ?? '',
        purchaseFlag: json["purchaseFlag"] ?? '',
        applicationNo: json["applicationNo"] ?? '',
        minimumlot: json["minimumlot"] ?? 0,
        minValue: json["minValue"] ?? 0,
        maxValue: json["maxValue"] ?? 0,
        discountText: json["discountText"] ?? '',
        discountPrice: json["discountPrice"] ?? 0,
        discountType: json["discountType"] ?? '',
        modifyAllowed: json["modifyAllowed"] ?? false,
        cancelAllowed: json["cancelAllowed"] ?? false,
        showDiscount: json["showDiscount"] ?? false,
        infoText: json["infoText"] ?? '',
        cutOffFlag: json["cutOffFlag"] ?? false,
        appliedDetail: json["appliedDetail"] == null
            ? null
            : AppliedDetail.fromJson(json["appliedDetail"]),
        showSi: json["showSI"] ?? false,
        sItext: json["SItext"] ?? '',
        sIvalue: json["SIvalue"] ?? false,
        subCategoryFound: json["subCategoryFound"] ?? 'N',
        subcategoryOptions: json["subcategoryOptions"] == null
            ? []
            : List<String>.from(json["subcategoryOptions"]!.map((x) => x)),
        // subCategoryList: json["subCategoryList"] == null
        //     ? null
        //     : SubCategoryList.fromJson(json["subCategoryList"]),
        subCategoryList: json["subCategoryList"] == null
            ? []
            : List<CategoryList>.from(
                json["subCategoryList"]!.map((x) => CategoryList.fromJson(x))),
        hniRangeText: json["hniRangeText"] ?? "",
        hniModifyInfoText: json["hniModifyInfoText"] ?? "",
        indRangeText: json["indRangeText"] ?? "",
        categorydisclaimerText: json["categorydisclaimerText"] == null
            ? []
            : List<String>.from(json["categorydisclaimerText"]!.map((x) => x)),
        subCategoryInfoText: json["subCategoryInfoText"] ?? "",
        categoryorderText: json["categoryorderText"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "categoryButtonText": categoryButtonText,
        "code": code,
        "purchaseFlag": purchaseFlag,
        "applicationNo": applicationNo,
        "minimumlot": minimumlot,
        "minValue": minValue,
        "maxValue": maxValue,
        "discountText": discountText,
        "discountPrice": discountPrice,
        "discountType": discountType,
        "modifyAllowed": modifyAllowed,
        "cancelAllowed": cancelAllowed,
        "showDiscount": showDiscount,
        "infoText": infoText,
        "appliedDetail": appliedDetail?.toJson(),
        "showSI": showSi,
        "SItext": sItext,
        "SIvalue": sIvalue,
        "subCategoryFound": subCategoryFound,
        "subcategoryOptions": subcategoryOptions == null
            ? []
            : List<dynamic>.from(subcategoryOptions!.map((x) => x)),
        "subCategoryList":
            // subCategoryList
            subCategoryList == null
                ? []
                : List<dynamic>.from(subCategoryList!.map((x) => x.toJson())),
        "hniRangeText": hniRangeText,
        "hniModifyInfoText": hniModifyInfoText,
        "indRangeText": indRangeText,
        "categorydisclaimerText": categorydisclaimerText,
        "subCategoryInfoText": subCategoryInfoText,
        "categoryorderText": categoryorderText,
      };
}

// class SubCategoryList {
//   String? category;
//   String? categoryButtonText;
//   String? code;
//   String? purchaseFlag;
//   String? applicationNo;
//   int? minimumlot;
//   int? minValue;
//   int? maxValue;
//   String? discountText;
//   int? discountPrice;
//   String? discountType;
//   bool? modifyAllowed;
//   bool? cancelAllowed;
//   bool? showDiscount;
//   String? infoText;
//   AppliedDetail? appliedDetail;
//   String? subCategoryFound;
//   List<String>? subcategoryOptions;
//   List<CategoryList>? subCategoryList;

//   SubCategoryList({
//     this.category,
//     this.categoryButtonText,
//     this.code,
//     this.purchaseFlag,
//     this.applicationNo,
//     this.minimumlot,
//     this.minValue,
//     this.maxValue,
//     this.discountText,
//     this.discountPrice,
//     this.discountType,
//     this.modifyAllowed,
//     this.cancelAllowed,
//     this.showDiscount,
//     this.infoText,
//     this.appliedDetail,
//     this.subCategoryFound,
//     this.subcategoryOptions,
//     this.subCategoryList,
//   });

//   factory SubCategoryList.fromJson(Map<String, dynamic> json) =>
//       SubCategoryList(
//         category: json["category"] ?? '',
//         categoryButtonText: json["categoryButtonText"] ?? '',
//         code: json["code"] ?? '',
//         purchaseFlag: json["purchaseFlag"] ?? '',
//         applicationNo: json["applicationNo"] ?? '',
//         minimumlot: json["minimumlot"] ?? 0,
//         minValue: json["minValue"] ?? 0,
//         maxValue: json["maxValue"] ?? 0,
//         discountText: json["discountText"] ?? '',
//         discountPrice: json["discountPrice"] ?? 0,
//         discountType: json["discountType"] ?? '',
//         modifyAllowed: json["modifyAllowed"] ?? false,
//         cancelAllowed: json["cancelAllowed"] ?? false,
//         showDiscount: json["showDiscount"] ?? false,
//         infoText: json["infoText"] ?? '',
//         appliedDetail: json["appliedDetail"] == null
//             ? null
//             : AppliedDetail.fromJson(json["appliedDetail"]),
//         subCategoryFound: json["subCategoryFound"] ?? 'N',
//         subcategoryOptions: json["subcategoryOptions"] == null
//             ? []
//             : List<String>.from(json["subcategoryOptions"]!.map((x) => x)),
//         subCategoryList: json["subCategoryList"] == null
//             ? []
//             : List<CategoryList>.from(
//                 json["subCategoryList"]!.map((x) => CategoryList.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "category": category,
//         "categoryButtonText": categoryButtonText,
//         "code": code,
//         "purchaseFlag": purchaseFlag,
//         "applicationNo": applicationNo,
//         "minimumlot": minimumlot,
//         "minValue": minValue,
//         "maxValue": maxValue,
//         "discountText": discountText,
//         "discountPrice": discountPrice,
//         "discountType": discountType,
//         "modifyAllowed": modifyAllowed,
//         "cancelAllowed": cancelAllowed,
//         "showDiscount": showDiscount,
//         "infoText": infoText,
//         "appliedDetail": appliedDetail?.toJson(),
//         "subCategoryFound": subCategoryFound,
//         "subcategoryOptions": subcategoryOptions == null
//             ? []
//             : List<dynamic>.from(subcategoryOptions!.map((x) => x)),
//         "subCategoryList": subCategoryList == null
//             ? []
//             : List<dynamic>.from(subCategoryList!.map((x) => x.toJson())),
//       };
// }

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
