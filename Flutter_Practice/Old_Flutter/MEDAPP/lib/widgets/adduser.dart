import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:medapp/customwidget.dart';
import 'package:medapp/widgets/snackBar.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  TextEditingController usrController = TextEditingController();
  final addKey = GlobalKey<FormState>();
  String? selectedOption;
  TextEditingController pwdController = TextEditingController();
  List? login;
  SharedPreferences? sref;
  fetchData() async {
    sref = await SharedPreferences.getInstance();
    String data = sref!.getString('login') ?? '[]';
    if (login == null || login!.isEmpty) {
      login = jsonDecode(data);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (login == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Form(
                key: addKey,
                child: Column(
                  children: [
                    myform(
                      icon: Icons.account_circle,
                      text: 'Enter User Name',
                      ctrl: usrController,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    myform(
                      icon: Icons.lock,
                      text: 'Enter Password',
                      ctrl: pwdController,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    DropdownButton(
                      hint: const Text('Role'),
                      items: ['Biller', 'Manager', 'Inventory', 'System Admin']
                          .map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      value: selectedOption,
                      onChanged: (newValue) {
                        setState(
                          () {
                            selectedOption = newValue;
                          },
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (addKey.currentState!.validate()) {
                          bool userAlreadyExists = false;
                          Map newItem = {
                            'User Id': usrController.text,
                            'password': pwdController.text,
                            'role': selectedOption
                          };
                          for (var user in login!) {
                            if (user['User Id'] == usrController.text) {
                              userAlreadyExists = true;
                              break;
                            }
                          }

                          if (userAlreadyExists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const MySnackBar(
                                      message: 'User already exists!',
                                      color: Colors.red)
                                  .openSnackBar(),
                            );
                          } else {
                            login!.add(newItem);
                            sref!.setString('login', jsonEncode(login));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const MySnackBar(
                                      message:
                                          'New User Added Sucessfully ...!!!',
                                      color: Colors.green)
                                  .openSnackBar(),
                            );
                            usrController.clear();
                            pwdController.clear();
                          }
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
