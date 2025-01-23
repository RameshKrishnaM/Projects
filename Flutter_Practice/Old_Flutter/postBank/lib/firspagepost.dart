import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool isLoading = true;
  final ifscKey = GlobalKey<FormState>();
  Map? details;
  TextEditingController ifscController = TextEditingController();

  search() async {
    try {
      var response = await http.get(
        Uri.parse('https://ifsc.razorpay.com/${ifscController.text}'),
      );
      if (response.statusCode == 200) {
        details = jsonDecode(response.body);
        isLoading = false;
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(fontSize: 14.0, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          elevation: 20,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              children: [
                const InkWell(
                  child: Text('IFSC Locator...!!!'),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                Form(
                  key: ifscKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: ifscController,
                        decoration: InputDecoration(
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Enter IFSC Code',
                          labelText: 'Enter IFSC Code',
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
                      ElevatedButton(
                        onPressed: () {
                          if (ifscKey.currentState!.validate()) {
                            search();
                          }
                        },
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                ),
                isLoading
                    ? const Center(
                        child: Text(''),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: details!.length,
                          itemBuilder: (context, index) {
                            List keyList = details!.keys.toList();
                            String key = keyList[index].toString();
                            String value = details![key].toString();
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(key),
                                    Text(value),
                                  ],
                                ),
                              ],
                            );
                          },
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
