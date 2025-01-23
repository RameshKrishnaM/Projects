import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart';

class ApiCall extends StatefulWidget {
  const ApiCall({super.key});

  @override
  State<ApiCall> createState() => _ApiCallState();
}

class _ApiCallState extends State<ApiCall> {
  bool isLoading = true;
  List? details;
  @override
  void initState() {
    super.initState();
    fetchData();
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _enabled = false;
      });
    });
  }

  bool _enabled = true;
  fetchData() async {
    try {
      var response =
          await http.get(Uri.parse('https://fakestoreapi.com/products'));
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
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Skeletonizer(
                enabled: _enabled,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('Api Call'),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Expanded(
                          child: details!.isEmpty
                              ? const Text('No Data Found')
                              : ListView.builder(
                                  itemCount: details!.length,
                                  itemBuilder: (context, index) {
                                    return Hero(
                                      tag: 'Image_$index',
                                      child: Column(
                                        children: [
                                          Image.network(
                                            details![index]['image'],
                                            height: 300,
                                            // isAntiAlias: true,
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Text(
                                            details![index]['title'],
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Text(
                                            'Prize : ${details![index]['price']}',
                                          ),
                                          const SizedBox(
                                            height: 20.0,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
