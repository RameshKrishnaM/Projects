import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyProvider extends ChangeNotifier {
  File? image;
  String name = 'Capture';
  bool isExpanded = false;
  Future<void> captureImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        final imageTemporary = File(image.path);

        this.image = imageTemporary;
      }
    } catch (e) {
      print('faliled to pic image $e');
    }
    notifyListeners();
  }

  changename() {
    if (name == "Capture") {
      name = "Retake";
    } else {
      name = "Capture";
    }
    notifyListeners();
  }

  changeExpanded() {
    isExpanded = !isExpanded;
    notifyListeners();
  }

  chngExp() {
    isExpanded = false;
    notifyListeners();
  }
}
