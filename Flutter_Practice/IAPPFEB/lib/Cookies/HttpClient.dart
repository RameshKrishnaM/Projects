// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import '../API%20call/api_call.dart';
// import '../provider/provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Route/route.dart' as route;

// // android:networkSecurityConfig="@xml/network_security_config"

// class CustomHttpClient {
//   static Map<String, String> headers = {
//     "Origin": "https://uatekyc101.flattrade.in",
//     "Referer": "https://uatekyc101.flattrade.in",
//   };
//   static String headersCookie = "";
//   static String mainUrl = "https://uatekyc101.flattrade.in:28094/api/";
//   // static String mainUrl = "http://192.168.2.176:28094/api/"; //swmiya
//   // static String mainUrl = "http://192.168.2.156:28094/api/";

//   static final SecurityContext _securityContext =
//       SecurityContext.defaultContext;
//   static Cookie? cookie;

//   // Add your custom certificate(s) to the security context
//   static void addTrustedCertificate() async {
//     ByteData data = await rootBundle.load('assets/raw/flattrade.crt');
//     List<int> bytes = data.buffer.asUint8List();
//     _securityContext.setTrustedCertificatesBytes(bytes);
//   }

//   static Future<http.Response> post(String url, dynamic data, context,
//       [headerValue
//       // String mainUrl = "https://uatekyc101.flattrade.in:28094/api/"
//       ]) async {
//     // Add trusted certificate(s) globally
//     // addTrustedCertificate('assets/raw/flattrade.crt');
//     addTrustedCertificate();

//     // Check and manage cookies (assuming these methods are defined elsewhere)
//     // await getCookies(context);
//     await checkCookies(context);
//     print("post method");
//     http.Client c = http.Client();
//     // ************************************
// //  final HttpClient httpClient = HttpClient()
// //       ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

// //     // Pass the custom HttpClient to the http.Client constructor
// //     final http.Client client = http.Client(client: httpClient);

// //     // Now you can use the client to make HTTP requests
// //     final response = await client.get(Uri.parse('https://example.com'));

//     // ************************************
//     // Make the HTTPS POST request using the custom HTTP client with the globally set SSL context
//     final HttpClient httpClient = HttpClient(context: _securityContext);
//     // httpClient.badCertificateCallback =
//     //   (X509Certificate cert, String host, int port) => true;
//     final request = await httpClient.postUrl(Uri.parse("$mainUrl$url"));
//     request.headers.add('Content-Type', 'application/json');
//     request.cookies.add(cookie!);

//     for (var headerKey in headers.keys) {
//       request.headers.add(headerKey, jsonEncode(headers[headerKey]));
//     }
//     if (headerValue != null && headerValue is Map) {
//       for (var headerKey in headerValue.keys) {
//         request.headers.add(headerKey, jsonEncode(headerValue[headerKey]));
//       }
//     }
//     print("cookie");
//     print(request.cookies);
//     request.add(utf8.encode(jsonEncode(data)));
//     final response = await request.close();

//     // Read and decode the response
//     final responseBody = await response.transform(utf8.decoder).join();
//     final Map json = jsonDecode(responseBody);
//     print("json ${json["status"]}");
// //************************************************************************************************************ */
//     // http.Client clientInstance1 = http.Client();

//     // // Set up a custom HttpClient with insecure context
//     // final HttpClient httpClientInstance = HttpClient()
//     //   ..badCertificateCallback =
//     //       (X509Certificate cert, String host, int port) => true;

//     // // Pass the custom HttpClient to the http package
//     // http.Client finalClientInstance = http.Client(clientInstance1: httpClientInstance);

//     // Handle session expiration
//     if (json["status"] == "I") {
//       await logout(context);
//       throw Exception("Session Expired");
//     }

//     // Return the response
//     return http.Response(responseBody, response.statusCode);
//   }

//   static Future<http.Response> get(String url, context, [headervalue, mainur]
//       // [String mainUrl = "https://uatekyc101.flattrade.in:28094/api/"]
//       ) async {
//     addTrustedCertificate();
//     await checkCookies(context);

//     final HttpClient httpClient = HttpClient(context: _securityContext);
//     final request =
//         await httpClient.getUrl(Uri.parse("${mainur ?? "$mainUrl$url"}"));

//     request.headers.add('Content-Type', 'application/json');
//     request.cookies.add(cookie!);
//     print(request.uri.toString());

//     for (var headerKey in headers.keys) {
//       request.headers.add(headerKey, jsonEncode(headers[headerKey]));
//     }
//     if (headervalue != null) {
//       for (var headerKey in headervalue.keys) {
//         request.headers.add(headerKey.toUpperCase(), headervalue[headerKey]);
//       }
//     }
//     print(headervalue);
//     print(request.headers);

//     final response = await request.close();

//     final responseBody = await response.transform(utf8.decoder).join();
//     final Map json = jsonDecode(responseBody);

//     // if (json["status"] == "I") {
//     //   await logout(context);
//     //   throw Exception("Session Expired");
//     // }

//     // Return the response
//     return http.Response(responseBody, response.statusCode);
//   }

//   static getHtml(String url, context, [headervalue, mainur]
//       // [String mainUrl = "https://uatekyc101.flattrade.in:28094/api/"]
//       ) async {
//     addTrustedCertificate();
//     await checkCookies(context);

//     final HttpClient httpClient = HttpClient(context: _securityContext);
//     final request =
//         await httpClient.getUrl(Uri.parse("${mainur ?? "$mainUrl$url"}"));

//     request.headers.add('Content-Type', 'application/json');
//     request.cookies.add(cookie!);
//     print(request.uri.toString());

//     for (var headerKey in headers.keys) {
//       request.headers.add(headerKey, jsonEncode(headers[headerKey]));
//     }
//     if (headervalue != null) {
//       for (var headerKey in headervalue.keys) {
//         request.headers.add(headerKey.toUpperCase(), headervalue[headerKey]);
//       }
//     }
//     print(headervalue);
//     print(request.headers);

//     final response = await request.close();

//     var responseBody = await response.transform(utf8.decoder).join();
//     // final Map json = jsonDecode(responseBody);

//     // if (json["status"] == "I") {
//     //   await logout(context);
//     //   throw Exception("Session Expired");
//     // }

//     // Return the response
//     // return http.Response(responseBody, response.statusCode);
//     return responseBody;
//   }

//   static getFile(
//     String url,
//     context,
//     //
//     // [String mainUrl = "https://uatekyc101.flattrade.in:28094/api/"]
//   ) async {
//     addTrustedCertificate();
//     await checkCookies(context);

//     final HttpClient httpClient = HttpClient(context: _securityContext);
//     final request = await httpClient.getUrl(Uri.parse("$mainUrl$url"));

//     request.cookies.add(cookie!);
//     print(request.uri.toString());

//     for (var headerKey in headers.keys) {
//       request.headers.add(headerKey, jsonEncode(headers[headerKey]));
//     }

//     final response = await request.close();

//     // final responseBody = await response.transform(utf8.decoder).join();
//     // final Map json = jsonDecode(responseBody);

//     // // if (json["status"] == "I") {
//     // //   await logout(context);
//     // //   throw Exception("Session Expired");
//     // // }

//     // // Return the response
//     // return http.Response(responseBody, response.statusCode);
//     return response;
//   }

//   static getFileType(
//     id,
//     context,
//     //
//     // [String mainUrl = "https://uatekyc101.flattrade.in:28094/api/"]
//   ) async {
//     addTrustedCertificate();
//     await checkCookies(context);

//     final HttpClient httpClient = HttpClient(context: _securityContext);
//     final request =
//         await httpClient.getUrl(Uri.parse("$mainUrl${"pdffile?id=$id"}"));

//     request.cookies.add(cookie!);
//     print(request.uri.toString());

//     for (var headerKey in headers.keys) {
//       request.headers.add(headerKey, jsonEncode(headers[headerKey]));
//     }

//     final response = await request.close();

//     // final responseBody = await response.transform(utf8.decoder).join();
//     // final Map json = jsonDecode(responseBody);

//     // // if (json["status"] == "I") {
//     // //   await logout(context);
//     // //   throw Exception("Session Expired");
//     // // }

//     // // Return the response
//     // return http.Response(responseBody, response.statusCode);
//     print(response.headers['Content-Type']![0].split("/")[1]);
//     return response.headers['Content-Type']![0].split("/")[1];
//   }

//   static Future<http.Response> put(
//     String url,
//     dynamic data,
//     context,
//     //    [
//     //   String mainUrl = "https://uatekyc101.flattrade.in:28094/api/",
//     // ]
//   ) async {
//     addTrustedCertificate();
//     await checkCookies(context);
//     final HttpClient httpClient = HttpClient(context: _securityContext);
//     final request = await httpClient.putUrl(Uri.parse("$mainUrl$url"));
//     request.headers.add('Content-Type', 'application/json');

//     for (var headerKey in headers.keys) {
//       request.headers.add(headerKey, jsonEncode(headers[headerKey]));
//     }
//     request.cookies.add(cookie!);
//     request.add(utf8.encode(jsonEncode(data)));
//     final response = await request.close();

//     final responseBody = await response.transform(utf8.decoder).join();
//     final Map json = jsonDecode(responseBody);

//     if (json["status"] == "I") {
//       await logout(context);
//       throw Exception("Session Expired");
//     }

//     return http.Response(responseBody, response.statusCode);
//   }

//   static putVerifyEsign(
//     String url,
//     dynamic data,
//     context,
//     //    [
//     //   String mainUrl = "https://uatekyc101.flattrade.in:28094/api/",
//     // ]
//   ) async {
//     addTrustedCertificate();
//     await checkCookies(context);
//     final HttpClient httpClient = HttpClient(context: _securityContext);
//     final request = await httpClient.putUrl(Uri.parse("$mainUrl$url"));
//     request.headers.add('Content-Type', 'application/json');

//     for (var headerKey in headers.keys) {
//       request.headers.add(headerKey, jsonEncode(headers[headerKey]));
//     }
//     request.cookies.add(cookie!);
//     request.add(utf8.encode(jsonEncode(data)));
//     final response = await request.close();

//     final responseBody = await response.transform(utf8.decoder).join();

//     return responseBody;
//   }

//   static Future<http.Response> postWithOutCookie(
//       String url, dynamic data) async {
//     addTrustedCertificate();

//     final HttpClient httpClient = HttpClient(context: _securityContext);
//     final request = await httpClient.postUrl(Uri.parse("$mainUrl$url"));
//     request.headers.add('Content-Type', 'application/json');

//     for (var headerKey in headers.keys) {
//       request.headers.add(headerKey, jsonEncode(headers[headerKey]));
//     }

//     request.add(utf8.encode(jsonEncode(data)));
//     final response = await request.close();

//     // Read and decode the response
//     final responseBody = await response.transform(utf8.decoder).join();
//     final Map json = jsonDecode(responseBody);

//     return http.Response(responseBody, response.statusCode);
//   }

//   static Future<http.Response> getWithOutCookie(String url,
//       [Map? header]) async {
//     addTrustedCertificate();

//     final HttpClient httpClient = HttpClient(context: _securityContext);

//     final request = await httpClient.getUrl(Uri.parse("$mainUrl$url"));
//     request.headers.add('Content-Type', 'application/json');

//     for (var headerKey in headers.keys) {
//       request.headers.add(headerKey, jsonEncode(headers[headerKey]));
//     }
//     if (header != null) {
//       for (var headerKey in header.keys) {
//         request.headers.add(headerKey, header[headerKey]);
//       }
//     }
//     print(request.headers);
//     print("$mainUrl$url");
//     final response = await request.close();

//     final responseBody = await response.transform(utf8.decoder).join();
//     print(responseBody);
//     return http.Response(responseBody, response.statusCode);
//   }

//   static Future<http.Response> putWithOutCookie(
//       String url, dynamic data) async {
//     addTrustedCertificate();

//     final HttpClient httpClient = HttpClient(context: _securityContext);
//     final request = await httpClient.putUrl(Uri.parse("$mainUrl$url"));
//     request.headers.add('Content-Type', 'application/json');

//     for (var headerKey in headers.keys) {
//       request.headers.add(headerKey, jsonEncode(headers[headerKey]));
//     }

//     request.add(utf8.encode(jsonEncode(data)));
//     final response = await request.close();

//     // Read and decode the response
//     final responseBody = await response.transform(utf8.decoder).join();
//     final Map json = jsonDecode(responseBody);

//     return http.Response(responseBody, response.statusCode);
//   }

//   static uploadProof(String url, List<File> files, Map headerMap) async {
//     addTrustedCertificate();
//     print(headerMap);

//     final HttpClient httpClient = HttpClient(context: _securityContext);

//     var request = await httpClient.postUrl(Uri.parse("$mainUrl$url"));
//     // var gttpClient = http.Client();
//     var mutipartRequest =
//         http.MultipartRequest('POST', Uri.parse("$mainUrl$url"));
//     int j = 0;

//     List keys = headerMap["key"];
//     // Attach each file to the request
//     for (int i = 0; i < keys.length; i++) {
//       if (keys[i] != "" && keys[i] != null) {
//         mutipartRequest.files.add(
//           await http.MultipartFile.fromPath(keys[i], files[j++].path),
//         );
//       }
//     }

//     for (var key in headers.keys) {
//       mutipartRequest.headers[key] = headers[key] ?? "";
//     }
//     mutipartRequest.headers["cookie"] = headersCookie;
//     // Add text data to the headers
//     mutipartRequest.headers['FileStruct'] = jsonEncode(headerMap);
//     print(mutipartRequest.files);
//     print(mutipartRequest.headers);
//     // final response = await request.close();
//     final response = await mutipartRequest.send();

//     return response;
//   }

//   static uploadFiles(String url, Map files, Map headerMap) async {
//     addTrustedCertificate();

//     final HttpClient httpClient = HttpClient(context: _securityContext);

//     var request = await httpClient.postUrl(Uri.parse("$mainUrl$url"));
//     // var gttpClient = http.Client();
//     var mutipartRequest =
//         http.MultipartRequest('POST', Uri.parse("$mainUrl$url"));

//     // Attach each file to the request

//     for (var fileKey in files.keys) {
//       mutipartRequest.files.add(
//         await http.MultipartFile.fromPath(fileKey, files[fileKey].path),
//       );
//     }

//     for (var key in headers.keys) {
//       mutipartRequest.headers[key] = headers[key] ?? "";
//     }
//     mutipartRequest.headers["cookie"] = headersCookie;
//     // Add text data to the headers
//     mutipartRequest.headers['filestruct'] = jsonEncode(headerMap);
//     print(mutipartRequest.files);
//     print(mutipartRequest.headers);
//     // final response = await request.close();
//     final response = await mutipartRequest.send();

//     return response;
//   }

//   static Future<http.StreamedResponse> addNomineePost(BuildContext context,
//       String url, List deleteIds, List inputJsonData) async {
//     // final HttpClient httpClient = HttpClient(
//     //     context: _securityContext); // Create an instance of HttpClient

//     // var request = await httpClient
//     //     .postUrl(Uri.parse('$mainUrl$url')); // Create a POST request
//     var mutipartRequest =
//         http.MultipartRequest('POST', Uri.parse("$mainUrl$url"));
//     Postmap p = Provider.of<Postmap>(context, listen: false);
//     List<File> files = [];
//     List<String> fileName = [];

//     p.nFIle1 != null ? files.add(p.nFIle1 ?? File("")) : null;
//     p.nFIle2 != null ? files.add(p.nFIle2 ?? File("")) : null;
//     p.nFIle3 != null ? files.add(p.nFIle3 ?? File("")) : null;
//     p.gFIle1 != null ? files.add(p.gFIle1 ?? File("")) : null;
//     p.gFIle2 != null ? files.add(p.gFIle2 ?? File("")) : null;
//     p.gFIle3 != null ? files.add(p.gFIle3 ?? File("")) : null;

//     p.nFIle1 != null ? fileName.add(p.nFIleName1) : null;
//     p.nFIle2 != null ? fileName.add(p.nFIleName2) : null;
//     p.nFIle3 != null ? fileName.add(p.nFIleName3) : null;
//     p.gFIle1 != null ? fileName.add(p.gFIleName1) : null;
//     p.gFIle2 != null ? fileName.add(p.gFIleName2) : null;
//     p.gFIle3 != null ? fileName.add(p.gFIleName3) : null;
//     print(fileName);

//     for (int i = 0; i < files.length; i++) {
//       mutipartRequest.files.add(
//         await http.MultipartFile.fromPath("File_${i + 1}", files[i].path),
//       );
//       mutipartRequest.fields["FileString_${i + 1}"] = fileName[i];
//       // request.fields[""]= await http.MultipartFile.fromPath("File_${i + 1}", files[i].path);
//       // List<int> fileBytes = await files[i].readAsBytes();
//       // String encodedFile = base64Encode(fileBytes);
//       // request.fields["File_${i + 1}"] = encodedFile;
//       // request.fields["File_${i + 1}"] = jsonEncode([]);
//     }

//     mutipartRequest.fields["ProcessType"] = "Nominee_Proof_Upload";
//     mutipartRequest.fields["deletedIds"] = jsonEncode(deleteIds);
//     mutipartRequest.fields["FileCount"] = "${files.length}";
//     mutipartRequest.fields["inputJsonData"] = jsonEncode(inputJsonData);
//     // request.files.add(await http.MultipartFile.fromString(
//     //     "ProcessType", "Nominee_Proof_Upload"));
//     // request.files.add(
//     //     await http.MultipartFile.fromString("deletedIds", jsonEncode(deleteIds)));
//     // request.files.add(await http.MultipartFile.fromString("FileCount", "0"));
//     // request.files.add(await http.MultipartFile.fromString(
//     //     "inputJsonData", jsonEncode(inputJsonData)));

//     for (var key in headers.keys) {
//       mutipartRequest.headers[key] = headers[key] ?? "";
//     }
//     mutipartRequest.headers["cookie"] = headersCookie;
//     print(mutipartRequest.files);
//     print(mutipartRequest.fields);

//     final response = await mutipartRequest.send();
//     // print(await response.stream.bytesToString());
//     return response;
//   }

//   static Future<http.Response> logInPut(String url, dynamic data) async {
//     addTrustedCertificate();

//     final HttpClient httpClient = HttpClient(context: _securityContext);
//     final request = await httpClient.putUrl(Uri.parse("$mainUrl$url"));
//     request.headers.add('Content-Type', 'application/json');

//     for (var headerKey in headers.keys) {
//       request.headers.add(headerKey, jsonEncode(headers[headerKey]));
//     }

//     request.add(utf8.encode(jsonEncode(data)));
//     final response = await request.close();

//     // Read and decode the response
//     final responseBody = await response.transform(utf8.decoder).join();
//     await updateCookie(response.cookies);
//     final Map json = jsonDecode(responseBody);

//     return http.Response(responseBody, response.statusCode);
//   }

// // ****************************************************************

//   static updateCookie(cookie) async {
//     print("cookie ${cookie}");
//     // String? rawCookie = response.headers['set-cookie'];

//     // print("am update cookie ${rawCookie = response.headers['set-cookie']}");
//     // String rawCookie =
//     //     "ftek_yc_ck=0cd14754d76227d4df69545b268ad70f9bf48d3bb215065572a47b9519eb33ff; Path=/; Max-Age=18000; HttpOnly; Secure; SameSite=Strict";
//     if (cookie != null && cookie.isNotEmpty) {
//       setCookies(cookie, DateTime.now());
//       // headers['cookie'] =
//       //     (index == -1) ? rawCookie : rawCookie.substring(0, index);
//     }
//   }

//   static setCookies(List<Cookie> cookies, DateTime time) async {
//     print("am set cookie");
//     SharedPreferences sref = await SharedPreferences.getInstance();
//     String rawCookie = "${cookies[0].name}=${cookies[0].value}";
//     print("rawCookie $rawCookie");

//     // DateTime validateTime = time.add(Duration(
//     //     seconds: int.parse(
//     //         rawCookie.split(";").toList()[1].split("=").toList()[1])));
//     DateTime validateTime = time.add(Duration(seconds: cookies[0].maxAge!));
//     print(validateTime.difference(DateTime.now()));

//     sref.setString("cookieTime", validateTime.toString());
//     sref.setString("cookies", rawCookie);
//   }

//   static Future<bool?> verifyCookies() async {
//     // SharedPreferences sref = await SharedPreferences.getInstance();
//     // String cookies = sref.getString("cookies") ?? "";
//     // String cookieTime = sref.getString("cookieTime") ?? "";
//     // // headers["cookie"] = cookies;
//     // // print(headers);

//     // if (cookies.isNotEmpty) {
//     //   List l = cookies.split("=");
//     //   cookie = Cookie(l[0], l[1]);
//     //   headersCookie = cookies;
//     // }

//     // if (cookies.isEmpty) {
//     //   return null;
//     // } else if (cookieTime.isEmpty ||
//     //     DateTime.parse(cookieTime).difference(DateTime.now()).inMicroseconds <
//     //         0) {
//     //   print(DateTime.parse(cookieTime).difference(DateTime.now()));
//     //   return false;
//     // } else {
//     //   print(DateTime.parse(cookieTime).difference(DateTime.now()));
//     //   return true;
//     // }
//     cookie = Cookie("ftek_yc_ck",
//         "07bcb78d1ff753c3ae0d94a97e4d2cad999d6afacd7ae8db93725d9271df4ca9");
//     headersCookie =
//         "ftek_yc_ck=07bcb78d1ff753c3ae0d94a97e4d2cad999d6afacd7ae8db93725d9271df4ca9";
//     return true;
//     // for reject =5a172f18d95c4e9a6b0953be41654d8a95ff43064e3686671c24a766031fc1af
// //new =5edec8b2ae59103b3610652c8c4d65f6d746093a27864e6c5594034db616543d
//     // diwan=ab778bec0bebb2eb7f294bac43cfdb84d8cbffd549cde07ce150798d8cb3c757
//     //BalaMurugan=3bd51f769c257d6a856354263de0e3e6f3e914b4341db8bd7014016a3ad63c68
//     // 14c38eb32aee0fef37fc7be57037a8ae7975d0994b56d4118695618a11074292
//   }

//   static checkCookies(context) async {
//     bool? validCookie = await verifyCookies();
//     print("valid $validCookie");
//     if (validCookie == null) {
//       Navigator.pushNamedAndRemoveUntil(
//         context,
//         route.signup,
//         (route) => false,
//       );
//       await Future.delayed(Duration(seconds: 1));
//       throw Exception("session Expired");
//       // return http.Response("", 440);
//     } else if (!validCookie) {
//       await logout(context);
//       await Future.delayed(Duration(seconds: 1));
//       throw Exception("session Expired");
//       // return http.Response("", 440);
//     }
//   }
// }

// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:http/http.dart' as http;

// // Future<void> uploadFileWithSSL(String filePath) async {
// //   HttpClient httpClient = HttpClient();

// //   // Configure HttpClient to trust certificates signed by your certificate authority
// //   httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
// //     // Verify the certificate here, return true if it's trusted.
// //     // For demonstration purposes, we'll return true to trust all certificates.
// //     return true;
// //   };

// //   var uri = Uri.parse('https://your_upload_url');

// //   try {
// //     var request = await httpClient.postUrl(uri);

// //     // Create a multipart request
// //     var multipartRequest = http.MultipartRequest('POST', uri);

// //     // Add file to multipart
// //     multipartRequest.files.add(await http.MultipartFile.fromPath('file', filePath));

// //     // You can add additional fields if needed
// //     multipartRequest.fields['field1'] = 'value1';

// //     // Serialize the multipart request data into a request body
// //     var requestBody = await multipartRequest.finalize();

// //     // Write the request body to the HttpClient request
// //     request.contentLength = requestBody.length;
// //     request.add(requestBody);

// //     // Send the request and get the response
// //     var response = await request.close();

// //     // Read response
// //     var responseBody = await response.transform(utf8.decoder).join();

// //     // Check the response status code
// //     if (response.statusCode == 200) {
// //       print('Uploaded successfully');
// //     } else {
// //       print('Failed to upload, status code: ${response.statusCode}');
// //     }
// //   } catch (e) {
// //     print('Error uploading file: $e');
// //   } finally {
// //     httpClient.close();
// //   }
// // }

// // void main() {
// //   uploadFileWithSSL('/path/to/your/file');
// // }
