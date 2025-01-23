// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:ekycold/widgets/background_animated_container.dart';
import 'package:ekycold/widgets/custom_button.dart';
import 'package:ekycold/widgets/custom_button_small.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class LastStep extends StatefulWidget {
  const LastStep({super.key});

  @override
  State<LastStep> createState() => _LastStepState();
}

class _LastStepState extends State<LastStep> {
  File? image;
  Future<void> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final imageTemporary = File(image.path);

        this.image = imageTemporary;
      }
    } catch (e) {
      print('failed to pic image $e');
    }
    setState(() {});
  }

  bool isButtonEnabled = true;
  bool isEsignButtonClicked = true;
  void esignButtonClicked() {
    isButtonEnabled = true;
    isEsignButtonClicked = true;
    setState(() {});
  }

  void showAlertBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Can we access your files',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await onEsignButtonClicked();
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'No',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onEsignButtonClicked() async {
    if (image == null) {
      await pickImage();
    }
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: FittedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Image:',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: image != null
                          ? Image.file(image!)
                          : const FlutterLogo(),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                CustomButtonSmall(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'),
                ),
                CustomButtonSmall(
                  onPressed: () async {
                    await pickImage();
                    setState(() {});
                  },
                  child: Text('Retake'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ListView(
        padding: const EdgeInsets.all(15.0),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: const BackgroundAnimatedContainer(image: 'laststep.png'),
          ),
          const SizedBox(height: 50),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Last Step',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'The last step is to digitally sign your application form(s). We will e-mail you your login credentials once your forms are verified.',
          ),
          const SizedBox(
            height: 30,
          ),
          CustomButton(
            onPressed: () {
              // image == null ? showAlertBox() : onEsignButtonClicked();
            },
            child: const Text('ESIGN'),
          )
        ],
      )),
    );
  }
}
