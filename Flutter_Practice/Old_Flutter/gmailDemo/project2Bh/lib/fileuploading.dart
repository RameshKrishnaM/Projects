import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FileUploading extends ChangeNotifier {
  FilePickerResult? result;
  String? fileName;
  PlatformFile? pickedFile;
  bool isLoading = false;
  File? fileToDisplay;

  pickFile() async {
    try {
      isLoading = true;
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        fileName = result!.files.first.name;
        pickedFile = result!.files.first;
        fileToDisplay = File(pickedFile!.path.toString());
        notifyListeners();
      }
      isLoading = false;

      notifyListeners();
    } catch (e) {
      print(e);
      isLoading = false;
      notifyListeners();
    }
  }
}
