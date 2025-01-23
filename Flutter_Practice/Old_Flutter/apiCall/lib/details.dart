import 'dart:convert';

import 'package:apicall/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List? details;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    SharedPreferences sref = await SharedPreferences.getInstance();
    String data = sref.getString('data') ?? '[]';
    details = jsonDecode(data);
    setState(() {});
    sref.get('dxfdx');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text('Home'),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Row(
                  children: [
                    Expanded(
                      child: Text('Name'),
                    ),
                    Expanded(
                      child: Text('Number'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  child: details == null || details!.isEmpty
                      ? const Text('no Data Found')
                      : ListView.builder(
                          itemCount: details!.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    details![index]['name'],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    details![index]['mobile'],
                                  ),
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
