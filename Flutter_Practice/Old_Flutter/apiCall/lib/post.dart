import 'dart:convert';

import 'package:apicall/apicall.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostApi extends StatefulWidget {
  const PostApi({super.key});

  @override
  State<PostApi> createState() => _PostApiState();
}

class _PostApiState extends State<PostApi> {
  final formkey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController addController = TextEditingController();
  bool passwordVisible = false;
  Map? details;
  submit() async {
    int mobile = int.parse(mobileController.text);
    details = {
      "userName": nameController.text,
      "password": passController.text,
      "mailID": mailController.text,
      "mobileNo": mobile,
      "dob": dobController.text,
      "address": addController.text
    };
    try {
      var response = await http.post(
        Uri.parse('http://192.168.2.153:26302/adduser'),
        body: jsonEncode(details),
      );
      if (response.statusCode == 200) {
        Map result = jsonDecode(response.body);
        if (result["status"] == 'S') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ApiCall(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${'Login Sucessfully!!!...'} ${response.body}',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.green,
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['errMsg'],
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.red,
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                const Text(
                  'Registration Form',
                  textAlign: TextAlign.center,
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
                            return 'Field is Empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20.0,
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
                          if (value!.isNotEmpty) {
                            if (!RegExp(
                                    r'^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[.!@#\$&*]).{8,}$')
                                .hasMatch(value)) {
                              return 'Enter a valid password!';
                            }
                          } else {
                            return "Password can't be empty";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        controller: mailController,
                        decoration: InputDecoration(
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.mail),
                          prefixIconColor: Colors.blue.shade300,
                          hintText: 'Enter your E-mail',
                          labelText: 'Enter your E-mail',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            if (!value.contains('@gmail.com')) {
                              return 'Enter proper mailID';
                            }
                          } else {
                            return 'Field is Empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15.0,
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
                      TextFormField(
                        controller: dobController,
                        decoration: InputDecoration(
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.calendar_month_outlined),
                          prefixIconColor: Colors.blue.shade300,
                          hintText: 'YYYY-MM-DD',
                          labelText: 'Enter Date-Of-Birth',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Date is required';
                          } else if (!RegExp(r'^\d{4}-\d{2}-\d{2}$')
                              .hasMatch(value)) {
                            return 'Invalid date format. Please use YYYY-MM-DD';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        controller: addController,
                        decoration: InputDecoration(
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.home),
                          prefixIconColor: Colors.blue.shade300,
                          hintText: 'Enter Address',
                          labelText: 'Enter Address',
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
                        height: 15.0,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                            submit();
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
