import 'dart:convert';

import 'package:apitask/demo.dart';
import 'package:apitask/secondapipage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SecondApi extends StatefulWidget {
  const SecondApi({super.key});

  @override
  State<SecondApi> createState() => _SecondApiState();
}

class _SecondApiState extends State<SecondApi> {
  bool isLoading = true;
  List? persons;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    try {
      var response = await http.get(
        Uri.parse('https://dummyjson.com/users'),
      );
      if (response.statusCode == 200) {
        Map details = jsonDecode(response.body);
        persons = details['users'];
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
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SkeletonText(),
                              ));
                        },
                        child: const Text(
                          'Users List...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Expanded(
                        child: persons!.isEmpty
                            ? const Text('No Data Found')
                            : GridView.count(
                                physics: const BouncingScrollPhysics(
                                  decelerationRate:
                                      ScrollDecelerationRate.normal,
                                ),
                                childAspectRatio: 0.9,
                                crossAxisCount: 2,
                                crossAxisSpacing: 5.0,
                                mainAxisSpacing: 5.0,
                                children: List.generate(
                                  persons!.length,
                                  (index) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SecondApiPage(
                                              user: persons![index],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              persons![index]['image'],
                                              width: 100.0,
                                              height: 100.0,
                                              fit: BoxFit.cover,
                                            ),
                                            const SizedBox(height: 10.0),
                                            Text(
                                              persons![index]['firstName'],
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(persons![index]['email']),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
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
