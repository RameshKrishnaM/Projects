import 'dart:convert';

List<ProductModel> productModelFromJson(String str) => List<ProductModel>.from(
    json.decode(str).map((x) => ProductModel.fromJson(x)));

String productModelToJson(List<ProductModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductModel {
  int id;
  Brand brand;
  String name;
  String price;
  PriceSign priceSign;
  Currency currency;
  String imageLink;
  String productLink;
  String websiteLink;
  String description;
  dynamic rating;
  String category;
  String productType;
  List<TagList> tagList;
  DateTime createdAt;
  DateTime updatedAt;
  String productApiUrl;
  String apiFeaturedImage;
  List<ProductColor> productColors;

  ProductModel({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    required this.priceSign,
    required this.currency,
    required this.imageLink,
    required this.productLink,
    required this.websiteLink,
    required this.description,
    required this.rating,
    required this.category,
    required this.productType,
    required this.tagList,
    required this.createdAt,
    required this.updatedAt,
    required this.productApiUrl,
    required this.apiFeaturedImage,
    required this.productColors,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json["id"],
        brand: brandValues.map[json["brand"]]!,
        name: json["name"],
        price: json["price"],
        priceSign: priceSignValues.map[json["price_sign"]]!,
        currency: currencyValues.map[json["currency"]]!,
        imageLink: json["image_link"],
        productLink: json["product_link"],
        websiteLink: json["website_link"],
        description: json["description"],
        rating: json["rating"],
        category: json["category"],
        productType: json["product_type"],
        tagList: List<TagList>.from(
            json["tag_list"].map((x) => tagListValues.map[x]!)),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        productApiUrl: json["product_api_url"],
        apiFeaturedImage: json["api_featured_image"],
        productColors: List<ProductColor>.from(
            json["product_colors"].map((x) => ProductColor.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "brand": brandValues.reverse[brand],
        "name": name,
        "price": price,
        "price_sign": priceSignValues.reverse[priceSign],
        "currency": currencyValues.reverse[currency],
        "image_link": imageLink,
        "product_link": productLink,
        "website_link": websiteLink,
        "description": description,
        "rating": rating,
        "category": category,
        "product_type": productType,
        "tag_list":
            List<dynamic>.from(tagList.map((x) => tagListValues.reverse[x])),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "product_api_url": productApiUrl,
        "api_featured_image": apiFeaturedImage,
        "product_colors":
            List<dynamic>.from(productColors.map((x) => x.toJson())),
      };
}

enum Brand { COLOURPOP, MARIENATIE }

final brandValues =
    EnumValues({"colourpop": Brand.COLOURPOP, "marienatie": Brand.MARIENATIE});

enum Currency { CAD, USD }

final currencyValues = EnumValues({"CAD": Currency.CAD, "USD": Currency.USD});

enum PriceSign { EMPTY }

final priceSignValues = EnumValues({"\u0024": PriceSign.EMPTY});

class ProductColor {
  String hexValue;
  String colourName;

  ProductColor({
    required this.hexValue,
    required this.colourName,
  });

  factory ProductColor.fromJson(Map<String, dynamic> json) => ProductColor(
        hexValue: json["hex_value"],
        colourName: json["colour_name"],
      );

  Map<String, dynamic> toJson() => {
        "hex_value": hexValue,
        "colour_name": colourName,
      };
}

enum TagList { CERT_CLEAN, CRUELTY_FREE, GLUTEN_FREE, PURPICKS, VEGAN }

final tagListValues = EnumValues({
  "CertClean": TagList.CERT_CLEAN,
  "cruelty free": TagList.CRUELTY_FREE,
  "Gluten Free": TagList.GLUTEN_FREE,
  "purpicks": TagList.PURPICKS,
  "Vegan": TagList.VEGAN
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
