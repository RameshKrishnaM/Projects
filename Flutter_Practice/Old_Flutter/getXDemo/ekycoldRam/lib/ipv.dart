import 'package:projectdemo2/demant.dart';
import 'package:projectdemo2/widgets/blob.dart';
import 'package:projectdemo2/widgets/cropimage.dart';
import 'package:projectdemo2/widgets/fab.dart';
import 'package:projectdemo2/widgets/mybottomsheet.dart';
import 'package:projectdemo2/widgets/mycolor.dart';
import 'package:projectdemo2/widgets/panwidget.dart';
import 'package:projectdemo2/widgets/providerclss.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

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

  var cropimage;

  @override
  Widget build(BuildContext context) {
    return Consumer<MyProvider>(
      builder: (context, value, child) {
        return WillPopScope(
          onWillPop: () async {
            if (value.isExpanded) {
              value.changeExpanded();
              return false;
            }
            return true;
          },
          child: Scaffold(
            // backgroundColor: const Color.fromRGBO(228, 242, 253, 1.0),
            floatingActionButton: const MyFAB(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bgcolor1,
                      // bgcolor2,
                      bgcolor3,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(15.0),
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      'Webcam Verification (IPV)',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      'Write the below code on a piece of paper and hold it infront of camera',
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      height: 30.0,
                      color: ipvcodecolor,
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
                        if (value.image == null) {
                          MyProvider provider =
                              Provider.of<MyProvider>(context, listen: false);
                          await provider.captureImage();
                        }

                        if (value.image != null) {
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyCropImage(
                                image: value.image!.path,
                                onImageCropped: (Image? croppedImage) {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return Consumer<MyProvider>(
                                            builder: (context, value, child) {
                                              return AlertDialog(
                                                content: value.image != null
                                                    ? croppedImage
                                                    : const FlutterLogo(),
                                                actionsAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Ok'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      if (value.name ==
                                                          'Retake') {
                                                        value.captureImage();
                                                      }
                                                      setState(() {});
                                                      value.changename();
                                                    },
                                                    child: Text(value.name),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Click here to Get Start IPV',
                        style: TextStyle(
                          color: highlightcolor,
                        ),
                      ),
                    ),
                    const MyBlob(),
                    PanWidget(
                      onPressed: () {
                        value.changeExpanded();
                      },
                    )
                  ],
                ),
              ),
            ),
            bottomSheet: MyBottomSheet(
              isExpanded: value.isExpanded,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DemantScreen(),
                    ));
                value.isExpanded = false;
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }
}
