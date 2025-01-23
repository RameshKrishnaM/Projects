import 'dart:convert';

import 'package:http/http.dart' as http;

class DigioRepository {
  static Map<String, String> headers = {
    "Origin": "https://instakyc.flattrade.in",
    "Referer": "https://instakyc.flattrade.in",
    "User-Agent": "InstaKYC/1.1.3 (Android)",
    "app_mode": "app",
    "api-version": "v2"
  };
  fetchinditialdata(String url, dynamic data, String myCookie,
      [headerValue]) async {
    await checkCookies(myCookie);

    if (headerValue != null && headerValue is Map) {
      headers = {...headers, ...headerValue};
    }

    print("Values*****");

    print("$url/api/ipvRequest $data $headers ");

    http.Response response = await http.post(Uri.parse("$url/api/ipvRequest"),
        body: jsonEncode(data), headers: headers);

    print("response");
    print(response);
    Map json = jsonDecode(response.body);

    print("json");
    print(json);

    if (json["status"] == "I") {
      throw Exception("session Expired");
    }
    return response;
  }

  static checkCookies(MyCookie) async {
    bool? validCookie = await verifyCookies(MyCookie);
    if (validCookie == null) {
      await Future.delayed(Duration(seconds: 1));
      throw Exception("session Expired");
    } else if (!validCookie) {
      await Future.delayed(Duration(seconds: 1));
      throw Exception("session Expired");
    }
  }

  static Future<bool?> verifyCookies(String MyCookie) async {
    // SharedPreferences sref = await SharedPreferences.getInstance();
    // String cookies = sref.getString("cookies") ?? "";
    // String cookieTime = sref.getString("cookieTime") ?? "";
    // headers["cookie"] = cookies;

    // print("cookies");
    // print(cookies);

    // if (cookies.isEmpty) {
    //   return null;
    // } else if (cookieTime.isEmpty ||
    //     DateTime.parse(cookieTime).difference(DateTime.now()).inMicroseconds <
    //         0) {
    //   return false;
    // } else {
    //   return true;
    // }

    headers["cookie"] =
        "ftek_yc_ck=$MyCookie; Path=/; Max-Age=2592000; HttpOnly; Secure; SameSite=Strict";
    return true;
  }
}
