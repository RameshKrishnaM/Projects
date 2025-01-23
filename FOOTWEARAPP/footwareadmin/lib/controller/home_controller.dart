import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:footwareadmin/model/product_model.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  String category = 'Category';
  String brand = 'Brand';
  bool offer = false;

  late CollectionReference collectionReference;
  List<Product> fetchProduct = [];
  @override
  void onInit() async {
    fetchProduct = await load();
    update();
    super.onInit();
  }

  addProduct() async {
    if (category != 'Category' && brand != 'Brand') {
      try {
        collectionReference = firestore.collection('Products');
        DocumentReference doc = collectionReference.doc('Shoes');
        List productList = [];

        Map<String, dynamic> productJson = {
          "id": doc.id,
          "name": nameController.text,
          "description": descController.text,
          "image": urlController.text,
          "price": double.parse(priceController.text),
          "category": category,
          "brand": brand,
          "offer": offer
        };
        List<Product> productfromModel = await load();
        // print(productfromModel[0].name);
        productList = jsonDecode(productToJson(productfromModel));
        productList.add(productJson);
        await doc.set({"Product": productList});

        setValuesDefault();

        fetchProduct = await load();
        Get.snackbar(
          'Sucess',
          'Product Added SucessFully',
          colorText: Colors.green,
        );
      } catch (e) {
        print(e);
        Get.snackbar(
          'failure',
          'Product Failed to Add with Exception $e',
          colorText: Colors.red,
        );
      }
    } else {
      Get.snackbar(
        'failure',
        'Please Add Category and Brand',
        colorText: Colors.red,
      );
    }
  }

  Future<List<Product>> load() async {
    List<Product> productList = [];
    List<Map<String, dynamic>> productsJson = [];
    try {
      print('Load 1');
      var collectionRef = firestore.collection('Products');
      var collectionSnapshot = await collectionRef.get();

      if (collectionSnapshot.docs.isNotEmpty) {
        var docSnapshot = await collectionRef.doc('Shoes').get();
        if (docSnapshot.exists && docSnapshot.data()!.containsKey('Product')) {
          productsJson = List.from(docSnapshot.get('Product'));
          productList = productFromJson(jsonEncode(productsJson));
        } else {
          await collectionRef.doc('Shoes').set({'Product': []});
        }
      } else {
        print('else Part');
        await collectionRef.doc('Shoes').set({'Product': []});
      }
    } catch (e) {
      print('Error loading data from Firestore: $e');
      print(e);
    } finally {
      update();
    }
    return productList;
  }

  setValuesDefault() {
    nameController.clear();
    descController.clear();
    urlController.clear();
    priceController.clear();
    category = 'Category';
    brand = 'Brand';

    update();
  }

  deleteProduct(index) async {
    try {
      List productList = [];
      List<Product> productfromModel = await load();
      collectionReference = firestore.collection('Products');
      DocumentReference doc = collectionReference.doc('Shoes');
      productList = jsonDecode(productToJson(productfromModel));
      productList.removeAt(index);
      await doc.set({"Product": productList});
      fetchProduct = await load();
      update();
    } catch (e) {
      print(e);
      Get.snackbar(
        'failure',
        'Product Failed to Add with Exception $e',
        colorText: Colors.red,
      );
    }
  }
}
