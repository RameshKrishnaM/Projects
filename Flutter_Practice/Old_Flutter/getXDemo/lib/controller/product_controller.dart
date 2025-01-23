import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getxdemo/model/product_model.dart';
import 'package:getxdemo/services/apiservice.dart';

class ProductController extends GetxController {
  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  var isLoading = true.obs;
  var productList = <ProductModel>[].obs;

  fetchProducts() async {
    try {
      List<ProductModel> products = await ApiService.fetchProduct();
      // print(products[1].description);
      productList.assignAll(products);
      // print(productList);
    } catch (e) {
      print(e);
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
    } finally {
      isLoading(false);
    }
    // print(productList);
  }
}
