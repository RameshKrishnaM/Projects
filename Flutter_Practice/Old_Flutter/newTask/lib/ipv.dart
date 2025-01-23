import 'package:ekyc/demant.dart';
import 'package:ekyc/widgets/MyBottomSheet.dart';
import 'package:ekyc/widgets/cropimage.dart';
import 'package:ekyc/widgets/panwidget.dart';
import 'package:ekyc/widgets/providerclss.dart';
import 'package:image_cropper/image_cropper.dart';
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

  final formKey = GlobalKey<FormState>();
  bool isExpanded = false;

  CroppedFile? cropimage;

  openbottomsheet(isExpanded) {
    Consumer<MyProvider>(
      builder: (context, value, child) {
        return MyBottomSheet(
          isExpanded: isExpanded,
          onPressed: value.isValidate ? () {} : null,
        );
      },
    );
  }

  double calculateTextSize(BuildContext context, double baseSize) {
    const double scaleFactor = 0.004;
    return MediaQuery.of(context).size.width * scaleFactor * baseSize;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<MyProvider>(
        builder: (context, value, child) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              highlightElevation: 0.0,
              elevation: 0.0,
              backgroundColor: Colors.lightBlue.withOpacity(0.5),
              mini: true,
              onPressed: () {
                setState(() {
                  isExpanded = false;
                });
              },
              child: Icon(
                isExpanded
                    ? Icons.keyboard_double_arrow_down_sharp
                    : Icons.keyboard_double_arrow_up_sharp,
                color: Colors.black54,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ListView(
                    children: [
                      SizedBox(
                        height: calculateTextSize(context, 8.0),
                      ),
                      Text(
                        'Webcam Verification (IPV)',
                        style: TextStyle(
                          fontSize: calculateTextSize(context, 15.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: calculateTextSize(context, 8.0),
                      ),
                      Text(
                        'Write the below code on a piece of paper and hold it infront of camera',
                        style: TextStyle(
                          fontSize: calculateTextSize(context, 10.0),
                        ),
                      ),
                      SizedBox(
                        height: calculateTextSize(context, 8.0),
                      ),
                      ElevatedButton(
                        onPressed: null,
                        child: Text(
                          'xxxxxx',
                          style: TextStyle(
                            fontSize: calculateTextSize(context, 10.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: calculateTextSize(context, 8.0),
                      ),
                      Text(
                        'Ensure that your face and code are clearly visible',
                        style: TextStyle(
                          fontSize: calculateTextSize(context, 10.0),
                        ),
                      ),
                      SizedBox(
                        height: calculateTextSize(context, 8.0),
                      ),
                      InkWell(
                        onTap: () async {
                          MyProvider provider =
                              Provider.of<MyProvider>(context, listen: false);
                          await provider.captureImage();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyCropImage(
                                image: provider.image!.path,
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
                                                    ? Image.network(
                                                        value.image!.path)
                                                    : const FlutterLogo(),
                                                actionsAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: value.isValidate
                                                        ? () {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        : null,
                                                    child: const Text('Ok'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      if (value.name ==
                                                          'Retake') {
                                                        value.captureImage();
                                                      }
                                                      setState(() {});
                                                      value.updateChange();
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
                        },
                        child: Text(
                          'Click here to Get Start IPV',
                          style: TextStyle(
                            fontSize: calculateTextSize(context, 10.0),
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      ClipRRect(
                        child: Image.asset('images/IPV.jpg'),
                      ),
                      SizedBox(
                        height: calculateTextSize(context, 8.0),
                      ),
                      PanWidget(
                        onPressed: value.isValidate
                            ? () {
                                setState(
                                  () {
                                    isExpanded = !isExpanded;
                                    openbottomsheet(isExpanded);
                                  },
                                );
                              }
                            : null,
                      )
                    ],
                  ),
                ),
              );
            }),
            bottomSheet: MyBottomSheet(
              isExpanded: isExpanded,
              onPressed: value.isValidate
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DemantScreen(),
                        ),
                      );
                      isExpanded = false;
                      setState(() {});
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
