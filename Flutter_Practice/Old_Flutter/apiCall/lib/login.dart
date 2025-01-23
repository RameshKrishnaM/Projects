import 'dart:convert';

import 'package:apicall/details.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formkey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  submit() async {
    SharedPreferences sref = await SharedPreferences.getInstance();
    String data = sref.getString('data') ?? '[]';
    List userDetails = jsonDecode(data);
    userDetails.add(
      {'name': nameController.text, 'mobile': mobileController.text},
    );
    sref.setString('data', jsonEncode(userDetails));
    nameController.clear();
    mobileController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(),
                      ),
                    );
                  },
                  child: const Text('Details Page'),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                Form(
                  key: formkey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.account_circle),
                          prefixIconColor: Colors.blue.shade300,
                          hintText: 'Enter User Name',
                          labelText: 'Enter User Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Container is Empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        controller: mobileController,
                        decoration: InputDecoration(
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.phone_android),
                          prefixIconColor: Colors.blue.shade300,
                          hintText: 'Enter Phone Number',
                          labelText: 'Enter Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          try {
                            int.parse(value!);
                            if (value.length != 10) {
                              return "Please Enter a Valid 10-digit Mobile No";
                            }
                          } catch (e) {
                            return 'Enter valid Number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                            submit();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Login Sucessfully...',
                                  style: TextStyle(
                                      fontSize: 14.0, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor: Colors.green,
                                elevation: 20,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
