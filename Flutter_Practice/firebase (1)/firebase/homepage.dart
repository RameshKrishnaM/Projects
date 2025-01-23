// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photosaver/viewdata.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.productname,
  });

  final Map<String, dynamic> productname;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String imageUrl = "";

  TextEditingController productnameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: productnameController,
              decoration: InputDecoration(
                  hintText: 'Product Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: quantityController,
              decoration: InputDecoration(
                  hintText: 'Product Quantity',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onPressCameraIcon,
                  icon: const Icon(Icons.camera),
                ),
                IconButton(
                  onPressed: onPressGalleryIcon,
                  icon: const Icon(Icons.photo),
                ),
              ],
            ),
           
           
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FireBaseData(),
                    ));
                setState(() async {
                  DocumentReference docRef = FirebaseFirestore.instance
                      .collection('your_collection')
                      .doc('your_document_id');

                  await docRef.update({
                    'field1': 'new_value1',
                    'field2': 'new_value2',
                  });
                  addDataToFirestore(productnameController.text,
                      quantityController.text, imageUrl);
                });
              },
              child: const Text('View The Image'),
            ),
          ],
        ),
      ),
    );
  }

  void addDataToFirestore(
      String productname, String quantity, String imageUrl) {
    CollectionReference users = firestore.collection('Products');
    users
        .doc(productname)
        .set({
          'product': productname,
          'quantity': quantity,
          'imageUrl': imageUrl,
        })
        .then((value) => print("User added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> onPressGalleryIcon() async {
    productnameController.clear();
    quantityController.clear();
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('Gallery');
      String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();
      Reference referenceImageToUpload =
          referenceDirImages.child(uniqueFileName);
      try {
        await referenceImageToUpload.putFile(File(file.path));
        imageUrl = await referenceImageToUpload.getDownloadURL();
        addDataToFirestore(
            productnameController.text, quantityController.text, imageUrl);
        setState(() {});
      } catch (e) {
        print(e.toString());
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('something happened')));
    }
  }

  Future<void> onPressCameraIcon() async {
    productnameController.clear();
    quantityController.clear();
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
    if (file != null) {
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('Camera');
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      print(uniqueFileName);
      Reference referenceImageToUpload =
          referenceDirImages.child(uniqueFileName);
      try {
        await referenceImageToUpload.putFile(File(file.path));
        imageUrl = await referenceImageToUpload.getDownloadURL();
        addDataToFirestore(
            productnameController.text, quantityController.text, imageUrl);
        setState(() {});
      } catch (e) {
        print(e.toString());
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('something happened')));
    }
  }

  Future<DocumentSnapshot> fetchDataFromFirestore(String name) async {
    try {
      DocumentReference documentRef =
          FirebaseFirestore.instance.collection('Products').doc(name);
      DocumentSnapshot snapshot = await documentRef.get();
      return snapshot;
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}
