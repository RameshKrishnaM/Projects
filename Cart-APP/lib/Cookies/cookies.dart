import 'dart:convert';
import 'dart:io';

import 'package:ekyc/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../API call/api_call.dart';
import '../Route/route.dart' as route;

class CustomHttpClient {
  String platform = "";
  static Map<String, String> headers = {
    "Origin": "https://instakyc.flattrade.in",
    "Referer": "https://instakyc.flattrade.in",
  };
  static ProviderClass? postmap;

  // static String mainUrl = "https://uatekyc101.flattrade.in:28595/api/"; //uat
  // static String mainUrl = "http://192.168.100.235:28595/api/"; // sowmiya
  // static String mainUrl = "http://192.168.2.133:28595/api/"; // Raghu
  // static String mainUrl = "http://192.168.2.102:28595/api/"; // Ramesh
  static String mainUrl = "http://192.168.70.79:28595/api/"; // LokeshVM
  // static String mainUrl = "http://192.168.2.70:28595/api/"; // Lokesh
  // static String mainUrl = "http://192.168.2.90:28595/api/"; // dinesh
  // static String mainUrl = "http://192.168.2.186:28595/api/"; // karunya
  //static String mainUrl = "http://192.168.100.138:28595/api/"; // saravanan
  // static String mainUrl = "http://192.168.2.113:28595/api/"; // ayyanar
  // static String mainUrl = "https://instakycapi.flattrade.in/api/"; //live
  static final SecurityContext _securityContext =
      SecurityContext.defaultContext;
  static Cookie? cookie;
  static String testMobileNo = "9899100101";
  static String testEmail = "manojkumar@flattrade.in";
  // static String appCurrentVersion = "1.1.5";

  // Add your custom certificate(s) to the security context
  static void addTrustedCertificate(context) async {
    ByteData data =
        await rootBundle.load('assets/sslCertificate/flattrade.crt');
    List<int> bytes = data.buffer.asUint8List();
    _securityContext.setTrustedCertificatesBytes(bytes);
    postmap = Provider.of<ProviderClass>(context, listen: false);
  }

  static Future<http.Response> get(
    String url,
    context, [
    headerValue,
  ]) async {
    await checkCookies(context);
    if (headerValue != null && headerValue is Map) {
      headers = {...headers, ...headerValue};
    }

    http.Response response =
        await http.get(Uri.parse("$mainUrl$url"), headers: headers);

    if ((response.headers["content-type"] ?? "").contains("text/plain") &&
        response.body.isNotEmpty) {
      var json = jsonDecode(response.body);

      if (json is Map &&
          json["status"] == "I" &&
          !url.contains("clearCookie")) {
        await logout(context);
        throw Exception("session Expired");
      }
    }

    return response;
  }

  static getFileType(id, context) async {
    await checkCookies(context);
    http.Response response = await http
        .get(Uri.parse("$mainUrl${"pdffile?id=$id"}"), headers: headers);

    return response.headers['content-type']!.split("/")[1];
  }

  static Future<http.Response> post(String url, dynamic data, context,
      [headerValue]) async {
    await checkCookies(context);

    if (headerValue != null && headerValue is Map) {
      headers = {...headers, ...headerValue};
    }

    http.Response response = await http.post(Uri.parse("$mainUrl$url"),
        body: jsonEncode(data), headers: headers);
    Map json = jsonDecode(response.body);

    if (json["status"] == "I") {
      await logout(context);
      throw Exception("session Expired");
    }
    return response;
  }

  static Future<http.Response> put(
    String url,
    dynamic data,
    context,
  ) async {
    await checkCookies(context);

    http.Response response = await http.put(Uri.parse("$mainUrl$url"),
        body: jsonEncode(data), headers: headers);

    if (response.body.toString().isNotEmpty) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "I") {
        await logout(context);
        throw Exception("session Expired");
      }
    }
    return response;
  }

  static Future<http.Response> getWithOutCookie(String url,
      [Map? header]) async {
    checkInternet();
    Map<String, String> newHeader = {...headers};
    if (header != null) {
      newHeader = {...newHeader, ...header};
    }
    http.Response response =
        await http.get(Uri.parse("$mainUrl$url"), headers: newHeader);
    return response;
  }

  static Future<http.Response> postWithOutCookie(
      String url, dynamic data) async {
    checkInternet();
    http.Response response = await http.post(Uri.parse("$mainUrl$url"),
        headers: headers, body: jsonEncode(data));

    return response;
  }

  static Future<http.Response> putWithOutCookie(
      String url, dynamic data) async {
    checkInternet();
    http.Response response = await http.put(Uri.parse("$mainUrl$url"),
        headers: headers, body: jsonEncode(data));
    return response;
  }

  static Future<http.Response> logInPost(String url, dynamic data) async {
    checkInternet();
    http.Response response = await http.post(Uri.parse("$mainUrl$url"),
        headers: headers, body: jsonEncode(data));
    var json = jsonDecode(response.body);
    if (json is Map && (json["status"] == "S" || json["statusCode"] == "MEC")) {
      await updateCookie(response);
    }
    return response;
  }

  static Future<http.Response?> logOut(context) async {
    checkInternet();
    if (postmap?.isNetworkConnected != true) throw Exception("No Internet");
    bool? verifyCookie = await verifyCookies();
    verifyCookie == null
        ? Navigator.pushNamedAndRemoveUntil(
            context, route.signup, (route) => route.isFirst)
        : verifyCookie == false
            ? logout(context)
            : null;
    if (verifyCookie == true) {
      http.Response response = await http
          .get(Uri.parse("$mainUrl${"clearCookie"}"), headers: headers);
      return response;
    }
    return null;
  }

  static uploadProof(
      BuildContext context, String url, List<File> files, Map headerMap) async {
    await checkCookies(context);
    var mutipartRequest =
        http.MultipartRequest('POST', Uri.parse("$mainUrl$url"));
    int j = 0;

    List keys = headerMap["key"];

    for (int i = 0; i < keys.length; i++) {
      if (keys[i] != "" && keys[i] != null) {
        mutipartRequest.files.add(
          await http.MultipartFile.fromPath(keys[i], files[j++].path),
        );
      }
    }

    for (var key in headers.keys) {
      mutipartRequest.headers[key] = headers[key] ?? "";
    }
    mutipartRequest.headers['FileStruct'] = jsonEncode(headerMap);

    final response = await mutipartRequest.send();

    return response;
  }

  static uploadFiles(
      BuildContext context, String url, List files, Map headerMap) async {
    await checkCookies(context);
    var mutipartRequest =
        http.MultipartRequest('POST', Uri.parse("$mainUrl$url"));
    int fileIndex = 0;
    for (var element in headerMap["uploadfilearr"] ?? []) {
      mutipartRequest.files.add(
        await http.MultipartFile.fromPath(
            element["doctype"], files[fileIndex++].path),
      );
    }

    for (var key in headers.keys) {
      mutipartRequest.headers[key] = headers[key] ?? "";
    }

    mutipartRequest.fields['FileStruct'] = jsonEncode(headerMap);

    final response = await mutipartRequest.send();

    return response;
  }

  static addNomineePost(
      BuildContext context, url, List deleteIds, List inputJsonData) async {
    await checkCookies(context);
    var request = http.MultipartRequest('POST', Uri.parse("$mainUrl$url"));
    ProviderClass p = Provider.of<ProviderClass>(context, listen: false);
    request.fields["ProcessType"] = "Nominee_Proof_Upload";
    request.fields["deletedIds"] = jsonEncode(deleteIds);
    request.fields["inputJsonData"] = jsonEncode(inputJsonData);

    for (var key in headers.keys) {
      request.headers[key] = headers[key] ?? "";
    }

    final response = await request.send();
    return response;
  }

  static updateCookie(http.Response response) async {
    String? rawCookie = response.headers['set-cookie'] ?? "";
    List<String> l = rawCookie.split(",");
    int index = l.indexWhere((element) => element.contains("ftek_yc_ck"));

    if (index != -1) {
      String newcookie = l.sublist(index).join();
      await setCookies(newcookie, DateTime.now());
    }
  }

  static setCookies(String rawCookie, DateTime time) async {
    SharedPreferences sref = await SharedPreferences.getInstance();
    List<String> l = rawCookie.split(";").toList();
    int index = l.indexWhere((element) => element.contains("Max-Age"));
    if (index != -1) {
      DateTime validateTime = time.add(Duration(
          seconds: int.parse(
              rawCookie.split(";").toList()[index].split("=").toList()[1])));

      sref.setString("cookieTime", validateTime.toString());
      sref.setString("cookies", rawCookie);
    }
  }

  static Future<bool?> verifyCookies() async {
    SharedPreferences sref = await SharedPreferences.getInstance();
    String cookies = sref.getString("cookies") ?? "";
    String cookieTime = sref.getString("cookieTime") ?? "";
    headers["cookie"] = cookies;
    if (cookies.isEmpty) {
      return null;
    } else if (cookieTime.isEmpty ||
        DateTime.parse(cookieTime).difference(DateTime.now()).inMicroseconds <
            0) {
      return false;
    } else {
      return true;
    }

    // headers["cookie"] =
    //     "ftek_yc_ck=1dce395687215055e2191dc99dad9c7ce91c4e1649ee139c6991c737b5131428; Path=/; Max-Age=18000; HttpOnly; Secure; SameSite=Strict";
    // return true;
  }

  static checkInternet() {
    if (!postmap!.isNetworkConnected) {
      throw Exception("No internet");
    }
  }

  static checkCookies(context) async {
    checkInternet();

    bool? validCookie = await verifyCookies();
    if (validCookie == null) {
      Navigator.pushNamedAndRemoveUntil(
          context, route.signup, (route) => route.isFirst);
      await Future.delayed(Duration(seconds: 1));
      throw Exception("session Expired");
    } else if (!validCookie) {
      await logout(context);
      await Future.delayed(Duration(seconds: 1));
      throw Exception("session Expired");
    }
  }
}
