import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getxdemo/model/product_model.dart';

import 'package:http/http.dart' as http;

class ApiService {
  static fetchProduct() async {
    var response1 = await http.get(Uri.parse(
        'https://makeup-api.herokuapp.com/api/v1/products.json?brand=marienatie'));
    var response2 = await http.get(Uri.parse(
        'https://makeup-api.herokuapp.com/api/v1/products.json?brand=colourpop'));
    if (response1.statusCode == 200) {
      var json = response1.body;

      // var colourpopData = productModelFromJson(response2.body);
      // print(productModelFromJson(json));
      // print(productModelFromJson(response1.body));
      // print(json);
      var products = productModelFromJson(json);
      print(products[1].priceSign);
      return productModelFromJson(json);
    }
  }
}
