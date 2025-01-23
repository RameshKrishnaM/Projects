// To parse this JSON data, do
//
//     final routeModel = routeModelFromJson(jsonString);

import 'dart:convert';

List<RouteModel> routeModelFromJson(String str) =>
    List<RouteModel>.from(json.decode(str).map((x) => RouteModel.fromJson(x)));

String routeModelToJson(List<RouteModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RouteModel {
  String routerstatus;
  String routername;
  String routerendpoint;
  String usereditable;
  List? message;

  RouteModel(
      {required this.routerstatus,
      required this.routername,
      required this.routerendpoint,
      required this.usereditable,
      required this.message});

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
      routerstatus: json["routerstatus"] ?? "",
      routername: json["routername"] ?? "",
      routerendpoint: json["routerendpoint"] ?? "",
      usereditable: json["usereditable"] ?? "",
      message: json["message"]);

  Map<String, dynamic> toJson() => {
        "routerstatus": routerstatus,
        "routername": routername,
        "routerendpoint": routerendpoint,
        "usereditable": usereditable,
      };
}
