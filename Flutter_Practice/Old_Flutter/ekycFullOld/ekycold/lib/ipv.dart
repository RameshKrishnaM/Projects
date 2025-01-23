// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:ekycold/demant.dart';
import 'package:ekycold/widgets/background_animated_container.dart';
import 'package:ekycold/widgets/custom_button_small.dart';
import 'package:ekycold/widgets/fab.dart';
import 'package:ekycold/widgets/mybottomsheet.dart';
import 'package:ekycold/widgets/panwidget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class IpvScreen extends StatefulWidget {
  const IpvScreen({super.key});

  @override
  State<IpvScreen> createState() => _IpvScreenState();
}

class _IpvScreenState extends State<IpvScreen> {
  @override
  void initState() {
    super.initState();
  }

  bool isExpanded = false;
  File? image;
  String name = 'Capture';
  Future<void> captureImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        final imageTemporary = File(image.path);

        this.image = imageTemporary;
      }
    } catch (e) {
      print('failed to pic image $e');
    }
    setState(() {});
  }

  Future<void> opencamera() async {
    if (image == null) {
      await captureImage();
    }
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: image != null ? Image.file(image!) : const FlutterLogo(),
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
                    await captureImage();
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
    return WillPopScope(
      onWillPop: () async {
        if (isExpanded) {
          isExpanded = false;
          setState(() {});
          return false;
        }
        return true;
      },
      child: Scaffold(
        // backgroundColor: const Color.fromRGBO(228, 242, 253, 1.0),
        floatingActionButton: MyFAB(
          mini: true,
          icon: isExpanded
              ? Icons.keyboard_double_arrow_down_sharp
              : Icons.keyboard_double_arrow_up_sharp,
          onPressed: () {
            isExpanded = false;
            setState(() {});
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(15.0),
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Text(
                'Webcam Verification (IPV)',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                'Write the below code on a piece of paper and hold it infront of camera',
              ),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                height: 30.0,
                color: Colors.blueGrey.shade200,
                alignment: Alignment.center,
                child: const Text(
                  'xxxxxx',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                'Ensure that your face and code are clearly visible',
              ),
              const SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () async {
                  await opencamera();
                },
                child: const Text(
                  'Click here to Get Start IPV',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
              const BackgroundAnimatedContainer(image: 'IPV.png'),
              PanWidget(
                onPressed: () {
                  isExpanded = !isExpanded;
                  setState(() {});
                },
              )
            ],
          ),
        ),
        bottomSheet: MyBottomSheet(
          isExpanded: isExpanded,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DemantScreen(),
              ),
            );
            isExpanded = false;
            setState(() {});
          },
        ),
      ),
    );
  }
}
