// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// // http://192.168.2.5:27094/
// import 'package:flutter/services.dart';

// import '../API call/api_call.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Route/route.dart' as route;

// Map<String, String> headers = {
//   // "Origin": "https://uatekyc101.flattrade.in",
//   // "Referer": "https://uatekyc101.flattrade.in/",
// };

// // String mainUrl = "https://uatekyc101.flattrade.in:28094/api/";
// String mainUrl = "http://192.168.2.5:27094/";

// Future<http.Response> get(String url, context) async {
//   await checkCookies(context);

//   http.Response response =
//       await http.get(Uri.parse("$mainUrl$url"), headers: headers);
//   Map json = jsonDecode(response.body);
//   if (json["status"] == "I") {
//     await logout(context);
//     throw Exception("session Expired");
//     // return http.Response("", 440);
//   }
//   return response;
// }

// Future<http.Response> post(String url, dynamic data, context) async {
//   // await getCookies(context);
//   await checkCookies(context);

//   http.Response response = await http.post(Uri.parse("$mainUrl$url"),
//       body: jsonEncode(data), headers: headers);
//   Map json = jsonDecode(response.body);

//   if (json["status"] == "I") {
//     await logout(context);
//     throw Exception("session Expired");
//     // return http.Response("", 440);
//   }
//   return response;
// }

// // Future<http.Response> put(String url, dynamic data, context) async {
// //   await checkCookies(context);
// //   http.Response response = await http.put(Uri.parse("$mainUrl$url"),
// //       body: jsonEncode(data), headers: headers);
// //   Map json = jsonDecode(response.body);
// //   if (json["status"] == "I") {
// //     await logout(context);
// //     throw Exception("session Expired");
// //     // return http.Response("", 440);
// //   }
// //   return response;
// // }

// Future<http.Response> put(String url, dynamic data, context) async {
//   // await getCookies(context);
//   bool? validCookie = await verifyCookies();
//   if (validCookie == null) {
//     Navigator.pushNamed(context, route.signup);
//     return http.Response("", 440);
//   } else if (!validCookie) {
//     await logout(context);
//     return http.Response("", 440);
//   }
//   http.Response response =
//       await http.put(Uri.parse("$mainUrl$url"), body: data, headers: headers);
//   Map json = jsonDecode(response.body);
//   if (json["status"] == "I") {
//     await logout(context);
//     return http.Response("", 440);
//   }
//   return response;
// }

// Future<http.Response> getWithOutCookie(String url) async {
//   http.Response response =
//       await http.get(Uri.parse("$mainUrl$url"), headers: headers);
//   return response;
// }

// Future<http.Response> postWithOutCookie(String url, dynamic data) async {
//   http.Response response =
//       await http.post(Uri.parse("$mainUrl$url"), body: jsonEncode(data));

//   return response;
// }

// Future<http.Response> putWithOutCookie(String url, dynamic data) async {
//   http.Response response =
//       await http.put(Uri.parse("$mainUrl$url"), body: jsonEncode(data));
//   return response;
// }

// Future<http.Response> logInPost(String url, dynamic data) async {
//   http.Response response =
//       await http.post(Uri.parse("$mainUrl$url"), body: data);
//   updateCookie(response);

//   return response;
// }

// Future<http.Response> logOutGet(String url, context) async {
//   verifyCookies();
//   http.Response response =
//       await http.get(Uri.parse("$mainUrl$url"), headers: headers);
//   return response;
// }

// void updateCookie(http.Response response) async {
//   String? rawCookie = response.headers['set-cookie'];
//   if (rawCookie != null && rawCookie.isNotEmpty) {
//     setCookies(rawCookie, DateTime.now());
//     // headers['cookie'] =
//     //     (index == -1) ? rawCookie : rawCookie.substring(0, index);
//   }
// }

// setCookies(String rawCookie, DateTime time) async {
//   SharedPreferences sref = await SharedPreferences.getInstance();
//   print("rawCookie $rawCookie");
//   DateTime validateTime = time.add(Duration(
//       seconds:
//           int.parse(rawCookie.split(";").toList()[3].split("=").toList()[1])));
//   print(validateTime.difference(DateTime.now()));
//   sref.setString("cookieTime", validateTime.toString());
//   sref.setString("cookies", rawCookie);
// }

// Future<bool?> verifyCookies() async {
//   SharedPreferences sref = await SharedPreferences.getInstance();
//   String cookies = sref.getString("cookies") ?? "";
//   String cookieTime = sref.getString("cookieTime") ?? "";
//   headers = {"cookie": cookies};
//   print("cookieTime $cookieTime");
//   if (cookies.isEmpty) {
//     return null;
//   } else if (cookieTime.isEmpty ||
//       DateTime.parse(cookieTime).difference(DateTime.now()).inMicroseconds <
//           0) {
//     return false;
//   } else {
//     return true;
//   }
// }

// checkCookies(context) async {
//   bool? validCookie = await verifyCookies();
//   if (validCookie == null) {
//     Navigator.pushNamed(context, route.signup);
//     throw Exception("session Expired");
//     // return http.Response("", 440);
//   } else if (!validCookie) {
//     await logout(context);
//     throw Exception("session Expired");
//     // return http.Response("", 440);
//   }
// }

// class CustomHttpClient {
//   Future<HttpClient> getClient() async {
//     // HttpClient httpClient = HttpClient();
//     // // Bypass SSL certificate verification (for development only)
//     // httpClient.badCertificateCallback =
//     //     (X509Certificate cert, String host, int port) => true;

//     // return httpClient;
//     ByteData data = await rootBundle.load('assets/raw/flattrade.crt');
//     SecurityContext context = SecurityContext.defaultContext;
//     context.setTrustedCertificatesBytes(data.buffer.asUint8List());
//     HttpClient httpClient = HttpClient(context: context);
//     // httpClient.badCertificateCallback =
//     //     (X509Certificate cert, String host, int port) => true;
//     return httpClient;
//   }
// }

// Future<void> fetchData() async {
//   // Replace http.Client() with your custom client
//   final client = await CustomHttpClient().getClient();

//   try {
//     final request = await client.postUrl(
//         Uri.https("uatekyc101.flattrade.in:28094", "/api/dropDowndata"));
//     request.add(utf8.encode(jsonEncode([
//       {"code": "state", "description": "state Name"}
//     ])));
//     // Process the response
//     var response = await request.close();
//     print(response.statusCode);

//     var responseBody = await response.transform(utf8.decoder).join();
//     Map data = json.decode(responseBody);

//     print(data);
//   } catch (e) {
//     // Handle errors
//     print('Error: $e');
//   } finally {
//     client.close();
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// http://192.168.2.5:27094/
import 'package:ekyc/provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../API call/api_call.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Route/route.dart' as route;

class CustomHttpClient {
  String platform = "";
  static Map<String, String> headers = {
    // "Origin": "https://instakyc.flattrade.in",
    // "Referer": "https://instakyc.flattrade.in",
    "Origin": "https://instakyc.flattrade.in",
    "Referer": "https://instakyc.flattrade.in",
  };
  static Postmap? postmap;

  //String mainUrl = "https://uatekyc101.flattrade.in:28094/api/";
  // static String mainUrl = "https://uatekyc101.flattrade.in:28595/api/"; //uat
// String mainUrl = "http://192.168.2.5:27094/";
  // static String mainUrl = "http://192.168.100.235:28595/api/"; // sowmiya
  // static String mainUrl = "http://192.168.2.70:28595/api/"; // Lokesh
  // static String mainUrl = "http://192.168.2.90:28595/api/"; // dinesh
  // static String mainUrl = "http://192.168.2.186:28595/api/"; // karunya
  //static String mainUrl = "http://192.168.100.138:28595/api/"; // saravanan
  // static String mainUrl = "http://192.168.2.113:28595/api/"; // ayyanar
  static String mainUrl = "https://instakycapi.flattrade.in/api/"; //live
// static String mainUrl = "http://192.168.2.156:28094/api/";
// https://uatekyc101.flattrade.in:28595
  static final SecurityContext _securityContext =
      SecurityContext.defaultContext;
  static Cookie? cookie;
  static String testMobileNo = "9899100101";
  static String testEmail = "manojkumar@flattrade.in";
  static String appCurrentVersion = "1.1.3";

  // Add your custom certificate(s) to the security context
  static void addTrustedCertificate(context) async {
    ByteData data =
        await rootBundle.load('assets/sslCertificate/flattrade.crt');
    List<int> bytes = data.buffer.asUint8List();
    _securityContext.setTrustedCertificatesBytes(bytes);
    postmap = Provider.of<Postmap>(context, listen: false);
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
    print("GETheader####### $headers");
    print("$mainUrl$url mainurl-----");
    http.Response response =
        await http.get(Uri.parse("$mainUrl$url"), headers: headers);
    // print("json json josn ${response.headers["content-type"]}");
    if ((response.headers["content-type"] ?? "").contains("text/plain") &&
        response.body.isNotEmpty) {
      // print("response##### ${response.body}");
      var json = jsonDecode(response.body);
      // print("json json josn $json");
      // url != "clearCookie" ? json["status"] = "I" : null;
      if (json is Map &&
          json["status"] == "I" &&
          !url.contains("clearCookie")) {
        await logout(context);
        // await Future.delayed(const Duration(seconds: 5));
        throw Exception("session Expired");
        // return http.Response("", 440);
      }
    }
    // var json = response.body.isNotEmpty ? jsonDecode(response.body) : "";

    return response;
  }

  static getFileType(id, context) async {
    await checkCookies(context);
    http.Response response = await http
        .get(Uri.parse("$mainUrl${"pdffile?id=$id"}"), headers: headers);
    // print(response.headers);
    // print("file type ${response.headers['content-type']!.split("/")[1]}");
    // var json = jsonDecode(response.body);

    // Map json = jsonDecode(response.body);
    // if (json is Map && json["status"] == "I") {
    //   await logout(context);
    //   throw Exception("session Expired");
    //   // return http.Response("", 440);
    // }
    return response.headers['content-type']!.split("/")[1];
  }

  static Future<http.Response> post(String url, dynamic data, context,
      [headerValue]) async {
    // await getCookies(context);
    await checkCookies(context);

    if (headerValue != null && headerValue is Map) {
      headers = {...headers, ...headerValue};
    }
    print("POSTheader####### $headers");
    print("$mainUrl$url mainurl-----");
    http.Response response = await http.post(Uri.parse("$mainUrl$url"),
        body: jsonEncode(data), headers: headers);
    // print("json body------------${response.body}");
    Map json = jsonDecode(response.body);

    if (json["status"] == "I") {
      await logout(context);
      throw Exception("session Expired");
      // return http.Response("", 440);
    }
    return response;
  }

// Future<http.Response> postWithHeader(
//     String url, dynamic data, context, headerValue,
//     [mainUrl = "http://192.168.2.5:27094/"]) async {
//   // await getCookies(context);

//   await checkCookies(context);
//   headers["digi_id"] = headerValue;
//   http.Response response = await http.post(Uri.parse("$mainUrl$url"),
//       body: jsonEncode(data), headers: headers);

//   Map json = jsonDecode(response.body);

//   if (json["status"] == "I") {
//     await logout(context);
//     throw Exception("session Expired");
//     // return http.Response("", 440);
//   }
//   return response;
// }

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
        // return http.Response("", 440);
      }
    }
    return response;
  }

// Future<http.Response> put(String url, dynamic data, context) async {
//   // await getCookies(context);
//   bool? validCookie = await verifyCookies();
//   if (validCookie == null) {
//     Navigator.pushNamed(context, route.signup);
//     return http.Response("", 440);
//   } else if (!validCookie) {
//     await logout(context);
//     return http.Response("", 440);
//   }
//   http.Response response =
//       await http.put(Uri.parse("$mainUrl$url"), body: data, headers: headers);
//   Map json = jsonDecode(response.body);
//   if (json["status"] == "I") {
//     await logout(context);
//     return http.Response("", 440);
//   }
//   return response;
// }

  static Future<http.Response> getWithOutCookie(String url,
      [Map? header]) async {
    // if (postmap?.isNetworkConnected != true) throw Exception("No Internet");
    checkInternet();
    Map<String, String> newHeader = {...headers};
    if (header != null) {
      newHeader = {...newHeader, ...header};
    }
    // print(newHeader);
    http.Response response =
        await http.get(Uri.parse("$mainUrl$url"), headers: newHeader);
    return response;
  }

  static Future<http.Response> postWithOutCookie(
      String url, dynamic data) async {
    checkInternet();
    print("header----$headers");
    print("mainurl-----$mainUrl$url");
    // if (postmap?.isNetworkConnected != true) throw Exception("No Internet");
    http.Response response = await http.post(Uri.parse("$mainUrl$url"),
        headers: headers, body: jsonEncode(data));
    print("json post respppp-------${response.body}");

    return response;
  }

  static Future<http.Response> putWithOutCookie(
      String url, dynamic data) async {
    // if (postmap?.isNetworkConnected != true) throw Exception("No Internet");
    // await F
    checkInternet();
    http.Response response = await http.put(Uri.parse("$mainUrl$url"),
        headers: headers, body: jsonEncode(data));
    print(response.body);
    return response;
  }

  static Future<http.Response> logInPost(String url, dynamic data) async {
    // if (postmap?.isNetworkConnected != true) throw Exception("No Internet");
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
    // Attach each file to the request

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
    // Add text data to the headers
    mutipartRequest.headers['FileStruct'] = jsonEncode(headerMap);
    // print(mutipartRequest.files);
    // print(mutipartRequest.headers);
    // final response = await request.close();
    final response = await mutipartRequest.send();

    return response;
  }

  static uploadFiles(
      BuildContext context, String url, List files, Map headerMap) async {
    await checkCookies(context);
    // var request = http.MultipartRequest('POST', Uri.parse("$mainUrl$url"));
    // var gttpClient = http.Client();
    var mutipartRequest =
        http.MultipartRequest('POST', Uri.parse("$mainUrl$url"));
    // Attach each file to the request
    int fileIndex = 0;
    for (var element in headerMap["uploadfilearr"] ?? []) {
      mutipartRequest.files.add(
        await http.MultipartFile.fromPath(
            element["doctype"], files[fileIndex++].path),
      );
    }

    // for (var fileKey in files.keys) {
    //   mutipartRequest.files.add(
    //     await http.MultipartFile.fromPath(fileKey, files[fileKey].path),
    //   );
    // }

    for (var key in headers.keys) {
      mutipartRequest.headers[key] = headers[key] ?? "";
    }
    // Add text data to the headers
    // mutipartRequest.fields

    mutipartRequest.fields['FileStruct'] = jsonEncode(headerMap);
    // print(mutipartRequest.files);
    // print(mutipartRequest.headers);
    // final response = await request.close();
    final response = await mutipartRequest.send();

    return response;
  }

  static addNomineePost(
      BuildContext context, url, List deleteIds, List inputJsonData) async {
    await checkCookies(context);
    var request = http.MultipartRequest('POST', Uri.parse("$mainUrl$url"));
    Postmap p = Provider.of<Postmap>(context, listen: false);
    // List<File> files = [];
    // List<String> fileName = [];
    // p.nFile1 != null ? files.add(p.nFile1 ?? File("")) : null;
    // p.nFile2 != null ? files.add(p.nFile2 ?? File("")) : null;
    // p.nFile3 != null ? files.add(p.nFile3 ?? File("")) : null;
    // p.gFile1 != null ? files.add(p.gFile1 ?? File("")) : null;
    // p.gFile2 != null ? files.add(p.gFile2 ?? File("")) : null;
    // p.gFile3 != null ? files.add(p.gFile3 ?? File("")) : null;

    // p.nFile1 != null ? fileName.add(p.nFileName1) : null;
    // p.nFile2 != null ? fileName.add(p.nFileName2) : null;
    // p.nFile3 != null ? fileName.add(p.nFileName3) : null;
    // p.gFile1 != null ? fileName.add(p.gFileName1) : null;
    // p.gFile2 != null ? fileName.add(p.gFileName2) : null;
    // p.gFile3 != null ? fileName.add(p.gFileName3) : null;

    // for (int i = 0; i < files.length; i++) {
    //   request.files.add(
    //     await http.MultipartFile.fromPath("File_${i + 1}", files[i].path),
    //   );
    //   request.fields["FileString_${i + 1}"] = fileName[i];
    //   // request.fields[""]= await http.MultipartFile.fromPath("File_${i + 1}", files[i].path);
    //   // List<int> fileBytes = await files[i].readAsBytes();
    //   // String encodedFile = base64Encode(fileBytes);
    //   // request.fields["File_${i + 1}"] = encodedFile;
    //   // request.fields["File_${i + 1}"] = jsonEncode([]);
    // }

    request.fields["ProcessType"] = "Nominee_Proof_Upload";
    request.fields["deletedIds"] = jsonEncode(deleteIds);
    // request.fields["FileCount"] = "${files.length}";
    request.fields["inputJsonData"] = jsonEncode(inputJsonData);
    // request.files.add(await http.MultipartFile.fromString(
    //     "ProcessType", "Nominee_Proof_Upload"));
    // request.files.add(
    //     await http.MultipartFile.fromString("deletedIds", jsonEncode(deleteIds)));
    // request.files.add(await http.MultipartFile.fromString("FileCount", "0"));
    // request.files.add(await http.MultipartFile.fromString(
    //     "inputJsonData", jsonEncode(inputJsonData)));

    for (var key in headers.keys) {
      request.headers[key] = headers[key] ?? "";
    }
    // print("url ${request.url}");
    // print(request.fields);
    // print(request.files);

    final response = await request.send();
    // print(await response.stream.bytesToString());
    return response;
    // Send the request
    // try {
    //   final response = await request.send();

    //   if (response.statusCode == 200) {
    //     print('Files uploaded successfully');
    //   } else {
    //     print('Failed to upload files. Status code: ${response.statusCode}');
    //   }
    // } catch (error) {
    //   print('Error uploading files: $error');
    // }
  }

  static updateCookie(http.Response response) async {
    String? rawCookie = response.headers['set-cookie'] ?? "";
    List<String> l = rawCookie.split(",");
    print(l);
    int index = l.indexWhere((element) => element.contains("ftek_yc_ck"));

    // print("new cookie $newcookie");
    // String rawCookie =
    //     "ftek_yc_ck=0cd14754d76227d4df69545b268ad70f9bf48d3bb215065572a47b9519eb33ff; Path=/; Max-Age=18000; HttpOnly; Secure; SameSite=Strict";
    if (index != -1) {
      String newcookie = l.sublist(index).join();
      await setCookies(newcookie, DateTime.now());
      // headers['cookie'] =
      //     (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  static setCookies(String rawCookie, DateTime time) async {
    // print("am set cookie");
    SharedPreferences sref = await SharedPreferences.getInstance();
    print("raw sss $rawCookie");
    // print(
    //     "rawCookie time ${int.parse(rawCookie.split(";").toList()[3].split("=").toList()[1])}");
    List<String> l = rawCookie.split(";").toList();
    int index = l.indexWhere((element) => element.contains("Max-Age"));
    if (index != -1) {
      DateTime validateTime = time.add(Duration(
          seconds: int.parse(
              rawCookie.split(";").toList()[index].split("=").toList()[1])));
      // print(validateTime.difference(DateTime.now()));

      sref.setString("cookieTime", validateTime.toString());
      sref.setString("cookies", rawCookie);
    }
  }

  static Future<bool?> verifyCookies() async {
    SharedPreferences sref = await SharedPreferences.getInstance();
    String cookies = sref.getString("cookies") ?? "";
    String cookieTime = sref.getString("cookieTime") ?? "";
    headers["cookie"] = cookies;
    // print(headers);
    // print("cookieTime $cookieTime");
    if (cookies.isEmpty) {
      return null;
    } else if (cookieTime.isEmpty ||
        DateTime.parse(cookieTime).difference(DateTime.now()).inMicroseconds <
            0) {
      return false;
    } else {
      return true;
    }
// ftek_yc_ck =
//         e73bf9a17d26f4e94060c1a2b50291e0c3a01678de20815e054a9205b7bc7e0a;
// ftek_yc_ck=5bc1805098ab1271d15741ed33a58fdb4b9af4b8b5613f722c2312d3f6fcfd38;
    // diwan=ab778bec0bebb2eb7f294bac43cfdb84d8cbffd549cde07ce150798d8cb3c757
    //BalaMurugan=3bd51f769c257d6a856354263de0e3e6f3e914b4341db8bd7014016a3ad63c68
    // 14c38eb32aee0fef37fc7be57037a8ae7975d0994b56d4118695618a11074292
    //  31a68809770748d2415644c9d4b7baf1e59ba1c3b3265e2c90229cd3e4ad3931
    // ftek_yc_ck=f12f52f0378c9f0e146183ae7807d45c488d9709adfc7b708e4749dfd9436172

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
    // if (postmap?.isNetworkConnected != true) throw Exception("No Internet");
    checkInternet();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ScaffoldMessenger.of(context).clearSnackBars();
    // });
    bool? validCookie = await verifyCookies();
    // print("hai cookie $validCookie");
    if (validCookie == null) {
      Navigator.pushNamedAndRemoveUntil(
          context, route.signup, (route) => route.isFirst);
      // Navigator.pushNamed(context, route.signup);
      await Future.delayed(Duration(seconds: 1));
      throw Exception("session Expired");
      // return http.Response("", 440);
    } else if (!validCookie) {
      await logout(context);
      await Future.delayed(Duration(seconds: 1));
      throw Exception("session Expired");
      // return http.Response("", 440);
    }
  }
}

// class CustomHttpClient {
//   Future<HttpClient> getClient() async {
//     // HttpClient httpClient = HttpClient();
//     // // Bypass SSL certificate verification (for development only)
//     // httpClient.badCertificateCallback =
//     //     (X509Certificate cert, String host, int port) => true;

//     // return httpClient;
//     ByteData data = await rootBundle.load('assets/raw/flattrade.crt');
//     SecurityContext context = SecurityContext.defaultContext;
//     context.setTrustedCertificatesBytes(data.buffer.asUint8List());
//     HttpClient httpClient = HttpClient(context: context);
//     // httpClient.badCertificateCallback =
//     //     (X509Certificate cert, String host, int port) => true;
//     return httpClient;
//   }
// }

// Future<void> fetchData() async {
//   // Replace http.Client() with your custom client
//   final client = await CustomHttpClient().getClient();

//   try {
//     final request = await client.postUrl(
//         Uri.https("uatekyc101.flattrade.in:28094", "/api/dropDowndata"));
//     request.add(utf8.encode(jsonEncode([
//       {"code": "state", "description": "state Name"}
//     ])));
//     // Process the response
//     var response = await request.close();
//     print(response.statusCode);

//     var responseBody = await response.transform(utf8.decoder).join();
//     Map data = json.decode(responseBody);

//     print(data);
//   } catch (e) {
//     // Handle errors
//     print('Error: $e');
//   } finally {
//     client.close();
//   }
// }

// m1() async {
//   // Create a security context
//   final SecurityContext context = SecurityContext.defaultContext;

//   // Load the custom certificate (e.g., self-signed certificate)
//   final File certificateFile = File('path_to_your_certificate.crt');
//   context.setTrustedCertificates(certificateFile.path);

//   // Make HTTPS requests with the custom security context
//   final HttpClient httpClient = HttpClient(context: context);
//   final HttpClientRequest request =
//       await httpClient.getUrl(Uri.parse('https://example.com'));
//   final HttpClientResponse response = await request.close();
//   // Handle response
// }
