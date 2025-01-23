import 'dart:convert';

import 'package:apitask/secondpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FirstApi extends StatefulWidget {
  const FirstApi({super.key});

  @override
  State<FirstApi> createState() => _FirstApiState();
}

class _FirstApiState extends State<FirstApi> {
  bool isLoading = true;
  List? products;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    try {
      var response = await http.get(
        Uri.parse('https://dummyjson.com/products'),
      );
      if (response.statusCode == 200) {
        Map details = jsonDecode(response.body);
        products = details['products'];
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
                child: CircularProgressIndicator(
                    // backgroundColor: Colors.red,
                    // color: Colors.amber,
                    ),
              )
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        'All Products...!!!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Expanded(
                        child: products!.isEmpty
                            ? const Text('No Data Found')
                            : ListView.builder(
                                itemCount: products!.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SecondPage(
                                                thumbnail: products![index]
                                                    ['thumbnail'],
                                                brand: products![index]
                                                    ['brand'],
                                                name: products![index]['title'],
                                                description: products![index]
                                                    ['description'],
                                                price: products![index]
                                                    ['price'],
                                                rating: products![index]
                                                    ['rating'],
                                                disprize: products![index]
                                                    ['discountPercentage'],
                                                stock: products![index]
                                                    ['stock'],
                                                images: products![index]
                                                    ['images'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Hero(
                                          tag:
                                              'image_${products![index]['title']}',
                                          child: ListTile(
                                            leading: SizedBox(
                                              height: 60,
                                              width: 60,
                                              child: Image.network(
                                                products![index]['thumbnail'],
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            title: Text(
                                              products![index]['title'],
                                            ),
                                            subtitle: Text(
                                              'Price : \$ ${products![index]['price']}',
                                            ),
                                          ),
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
