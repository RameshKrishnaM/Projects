// To parse this JSON data, do
//
//     final applicationModel = applicationModelFromJson(jsonString);

import 'dart:convert';

ApplicationModel applicationModelFromJson(String str) =>
    ApplicationModel.fromJson(json.decode(str));

String applicationModelToJson(ApplicationModel data) =>
    json.encode(data.toJson());

class ApplicationModel {
  String status;
  String email;
  String mobil;
  String applicationNo;
  String applicationStatus;
  String esigneddocid;
  String rejectmsg;
  Map stagemsg;

  ApplicationModel(
      {required this.status,
      required this.email,
      required this.mobil,
      required this.applicationNo,
      required this.applicationStatus,
      required this.esigneddocid,
      required this.rejectmsg,
      required this.stagemsg});

  factory ApplicationModel.fromJson(Map<String, dynamic> json) =>
      ApplicationModel(
        status: json["status"] ?? "",
        email: json["email"] ?? "",
        mobil: json["mobileno"] ?? "",
        applicationNo: json["applicationno"] ?? "",
        applicationStatus: json["applicationstatus"] ?? "",
        esigneddocid: json["esigneddocid"] ?? "",
        rejectmsg: json["rejectmsg"] ?? "",
        stagemsg: json["stagemsg"] ?? {},
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "email": email,
        "mobil": mobil,
        "application_no": applicationNo,
        "application_status": applicationStatus,
        "esigneddocid": esigneddocid
      };
}
