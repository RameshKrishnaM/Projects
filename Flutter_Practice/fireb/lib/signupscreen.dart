import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  void initState() {
    analytics.setAnalyticsCollectionEnabled(true);
    super.initState();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobNoController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final firestore = FirebaseFirestore.instance;
  Future<String> response(String user, String mail) async {
    var res = 'Error';
    try {
      if (user.contains('Abc')) {
        await analytics.logEvent(
          name: 'Sign_Up',
          parameters: {
            "usersCount": usrCount++,
          },
        );
        setState(() {});
      }
      await firestore.collection('SignUp Page').doc('User $usrCount').set({
        "Name": user,
        "Mail Id": mail,
        // "Phone Number": mobNoController,
        // "PassWord": pwdController,
      });
      res = 'Sucess';
    } catch (e) {
      print('Catch Error');
      print(e);
    }
    print("Response ");
    print(res);
    return res;
  }

  final formKey = GlobalKey<FormState>();

  int usrCount = 1;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Enter value';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Mail Address',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Enter value';
                    }
                    return null;
                  },
                ),
                // SizedBox(
                //   height: 10,
                // ),
                // TextFormField(
                //   controller: mobNoController,
                //   decoration: InputDecoration(
                //     labelText: 'Phone ',
                //     border: OutlineInputBorder(
                //       borderSide: BorderSide(color: Colors.amber),
                //     ),
                //   ),
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Please Enter value';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                // TextFormField(
                //   controller: pwdController,
                //   decoration: InputDecoration(
                //     labelText: 'Password ',
                //     border: OutlineInputBorder(
                //       borderSide: BorderSide(color: Colors.amber),
                //     ),
                //   ),
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Please Enter value';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {});
                    if (formKey.currentState!.validate()) {
                      if (nameController.text.isNotEmpty &&
                              emailController.text.isNotEmpty
                          // mobNoController.text.isNotEmpty &&
                          // pwdController.text.isNotEmpty
                          ) {
                        response(nameController.text, emailController.text);
                      }
                    }
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
