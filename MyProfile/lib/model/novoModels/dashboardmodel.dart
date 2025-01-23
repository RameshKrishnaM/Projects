// To parse this JSON data, do
//
//     final novoDashBoardDetails = novoDashBoardDetailsFromJson(jsonString);

import 'dart:convert';

NovoDashBoardDetails novoDashBoardDetailsFromJson(String str) =>
    NovoDashBoardDetails.fromJson(json.decode(str));

String novoDashBoardDetailsToJson(NovoDashBoardDetails data) =>
    json.encode(data.toJson());

class NovoDashBoardDetails {
  List<SegmentArr>? segmentArr;
  dynamic? routerArr;
  String? status;
  String? errMsg;

  NovoDashBoardDetails({
    this.segmentArr,
    this.routerArr,
    this.status,
    this.errMsg,
  });

  factory NovoDashBoardDetails.fromJson(Map<String, dynamic> json) =>
      NovoDashBoardDetails(
        segmentArr: json["segmentArr"] == null
            ? []
            : List<SegmentArr>.from(
                json["segmentArr"]!.map((x) => SegmentArr.fromJson(x))),
        routerArr: json["routerArr"] ?? [],
        status: json["status"] ?? '',
        errMsg: json["errMsg"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "segmentArr": segmentArr == null
            ? []
            : List<dynamic>.from(segmentArr!.map((x) => x.toJson())),
        "routerArr": routerArr,
        "status": status,
        "errMsg": errMsg,
      };
}

class SegmentArr {
  int? id;
  String? name;
  String? fullname;
  String? path;
  int? taskId;
  String? image;
  String? darkThemeImage;
  String? color;
  String? status;

  SegmentArr({
    this.id,
    this.name,
    this.fullname,
    this.path,
    this.taskId,
    this.image,
    this.darkThemeImage,
    this.color,
    this.status,
  });

  factory SegmentArr.fromJson(Map<String, dynamic> json) => SegmentArr(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        fullname: json["fullname"] ?? '',
        path: json["path"] ?? '',
        taskId: json["taskId"] ?? '',
        image: json["image"] ?? '',
        darkThemeImage: json["darkThemeImage"] ?? '',
        color: json["color"] ?? '',
        status: json["status"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "fullname": fullname,
        "path": path,
        "taskId": taskId,
        "image": image,
        "darkThemeImage": darkThemeImage,
        "color": color,
        "status": status,
      };
}
