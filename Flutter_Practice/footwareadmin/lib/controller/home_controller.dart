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
  TextEditingController offerController = TextEditingController();

  String category = 'Category';
  String brand = 'Brand';
  bool offer = false;

  late CollectionReference collectionReference;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  addProduct() async {
    if (category != 'Category' && brand != 'Brand') {
      try {
        collectionReference = firestore.collection('Products');
        DocumentReference doc = collectionReference.doc('Shoes');

        Product product = Product(
          id: doc.id,
          name: nameController.text,
          description: descController.text,
          image: urlController.text,
          price: double.tryParse(priceController.text) ?? 0.0,
          category: category,
          brand: brand,
          offer: offer,
        );

        final productJson = product.toJson();
        List productList = [];
        productList = await load();
        productList.add(productJson);
        await doc.set({"Product": productList});

        nameController.clear();
        descController.clear();
        urlController.clear();
        priceController.clear();
        category = 'Category';
        brand = 'Brand';

        Get.snackbar(
          'Sucess',
          'Product Added SucessFully',
          colorText: Colors.green,
        );
      } catch (e) {
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

  Future<List<Map<String, dynamic>>> load() async {
    List<Map<String, dynamic>> msg = [];

    try {
      print('Load 1 ');
      var collectionRef = firestore.collection('Products');
      var collectionSnapshot = await collectionRef.get();

      if (collectionSnapshot.docs.isNotEmpty) {
        var docSnapshot = await collectionRef.doc('Shoes').get();
        if (docSnapshot.exists && docSnapshot.data()!.containsKey('Product')) {
          msg = List<Map<String, dynamic>>.from(docSnapshot.get('Product'));
          print(msg);
        } else {
          await collectionRef.doc('Shoes').set({'Product': []});
        }
      } else {
        print('else Part');
        await collectionRef.doc('Shoes').set({'Product': []});
        msg = [];
      }
    } catch (e) {
      print('Error loading data from Firestore: $e');
    }

    return msg;
  }
}
