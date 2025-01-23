import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:medapp/customwidget.dart';
import 'package:medapp/widgets/snackBar.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'userdetails.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  List? login;
  List? medicineMaster;
  List? stock;
  List loginhistory = [];
  SharedPreferences? sref;
  bool passwordVisible = false;

  fetchData() async {
    sref = await SharedPreferences.getInstance();
    String data = sref!.getString('login') ?? '[]';
    String data2 = sref!.getString('medicineMaster') ?? '[]';
    String data1 = sref!.getString('stock') ?? '[]';
    String data3 = sref!.getString('login History') ?? '[]';
    if (medicineMaster == null || medicineMaster!.isEmpty) {
      medicineMaster = jsonDecode(data2);
      if (medicineMaster == null || medicineMaster!.isEmpty) {
        medicineMaster = medicineMasterList;
        sref!.setString('medicineMaster', jsonEncode(medicineMaster));
      }
    }

    if (stock == null || stock!.isEmpty) {
      stock = jsonDecode(data1);
      if (stock == null || stock!.isEmpty) {
        stock = stockList;
        sref!.setString('stock', jsonEncode(stock));
      }
    }
    if (login == null || login!.isEmpty) {
      login = jsonDecode(data);
      if (login == null || login!.isEmpty) {
        login = logindata;
        sref!.setString('login', jsonEncode(login));
      }
    }

    if (loginhistory.isEmpty) {
      loginhistory = jsonDecode(data3);
    }
    setState(() {});
  }

  final loginKey = GlobalKey<FormState>();
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();
  submit() {
    Map? foundUser;
    if (login!.map((e) => e['User Id']).contains(userController.text)) {
      for (var user in login!) {
        if (user['User Id'] == userController.text) {
          foundUser = Map.from(user);
        }
      }
      if (passController.text == foundUser!['password']) {
        Map argument = {
          'User Id': userController.text,
          'role': foundUser['role'],
        };
        Navigator.pushNamed(context, '/firstPage', arguments: argument);
      } else {
        return ScaffoldMessenger.of(context).showSnackBar(
          const MySnackBar(message: 'Password InCorrect', color: Colors.red)
              .openSnackBar(),
        );
      }
    } else {
      return ScaffoldMessenger.of(context).showSnackBar(
        const MySnackBar(message: 'Username Not Found', color: Colors.red)
            .openSnackBar(),
      );
    }

    loginhistory.add({
      'User Id ': userController.text,
      'Type': 'Login',
      'Date': dateTime(),
    });
    sref!.setString('login History', jsonEncode(loginhistory));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                elevation: 8.0,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Form(
                        key: loginKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: userController,
                              decoration: InputDecoration(
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                labelText: 'Enter Username',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Field is Empty';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              obscureText: !passwordVisible,
                              controller: passController,
                              decoration: InputDecoration(
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                prefixIcon: const Icon(Icons.lock_outline),
                                prefixIconColor: Colors.blue.shade300,
                                suffixIconColor: Colors.blue.shade300,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                  icon: Icon(passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                                hintText: 'Enter Your Password',
                                labelText: 'Enter Your Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Field is Empty';
                                } else if (value.length < 3) {
                                  return 'Enter Valid Password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (loginKey.currentState!.validate()) {
                                  submit();
                                }
                              },
                              child: const Text("Submit"),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
