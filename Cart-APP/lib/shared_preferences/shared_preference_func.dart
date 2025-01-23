import 'package:shared_preferences/shared_preferences.dart';

setMobileNo(String mobileNo) async {
  SharedPreferences sref = await SharedPreferences.getInstance();
  sref.setString("mobileNo", mobileNo);
}

setEmail(String email) async {
  SharedPreferences sref = await SharedPreferences.getInstance();
  sref.setString("email", email);
}

setStatus(String status) async {
  SharedPreferences sref = await SharedPreferences.getInstance();
  sref.setString("status", status);
}

Future<String> getMobileNo() async {
  SharedPreferences sref = await SharedPreferences.getInstance();
  return sref.getString("mobileNo") ?? "123";
}

Future<String> getEmail() async {
  SharedPreferences sref = await SharedPreferences.getInstance();
  return sref.getString("email") ?? "";
}

Future<String> getStatus() async {
  SharedPreferences sref = await SharedPreferences.getInstance();
  return sref.getString("status") ?? "";
}

clearCookies() async {
  SharedPreferences sref = await SharedPreferences.getInstance();
  await sref.remove("cookies");
  await sref.remove("cookieTime");
  await sref.remove("status");
}
