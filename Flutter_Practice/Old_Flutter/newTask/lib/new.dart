import 'package:ekyc/ipv.dart';

import 'package:ekyc/widgets/CustomFormField.dart';
import 'package:ekyc/widgets/MyBottomSheet.dart';
import 'package:ekyc/widgets/panwidget.dart';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';

class MyBankScreen extends StatefulWidget {
  const MyBankScreen({super.key});

  @override
  State<MyBankScreen> createState() => _MyBankScreenState();
}

class _MyBankScreenState extends State<MyBankScreen> {
  bool isValidate = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController ifscController = TextEditingController();
  TextEditingController accnumController = TextEditingController();
  TextEditingController confirmaccnumController = TextEditingController();
  bool isExpanded = false;
  void isValue() {
    setState(() {
      if (ifscController.text.isNotEmpty &&
          accnumController.text.isNotEmpty &&
          confirmaccnumController.text.isNotEmpty) {
        isValidate = true;
      } else {
        isValidate = false;
      }
    });
  }

  final List<String> images = [
    'assets/images/illustrator-security.jpg',
    'images/preview1.jpg',
    'images/illustrator2.jpg',
    'images/preview.png',
  ];

  double calculateTextSize(BuildContext context, double baseSize) {
    const double scaleFactor = 0.004;
    return MediaQuery.of(context).size.width * scaleFactor * baseSize;
  }

  openbottomsheet(isExpanded) {
    return MyBottomSheet(
      isExpanded: isExpanded,
      onPressed: isValidate ? () {} : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            size: calculateTextSize(context, 12.0),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Link Bank Account',
                        style: TextStyle(
                          fontSize: calculateTextSize(context, 12.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: calculateTextSize(context, 8.0),
                      ),
                      Text(
                        'Bank Account in your name from which you will transact funds for trading',
                        style: TextStyle(
                          fontSize: calculateTextSize(context, 8.0),
                        ),
                      ),
                      SizedBox(
                        height: calculateTextSize(context, 8.0),
                      ),
                      CarouselSlider(
                        options: CarouselOptions(
                          height: calculateTextSize(context, 140.0),
                          enlargeCenterPage: true,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                        ),
                        items: images
                            .map((imagePath) => Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                ))
                            .toList(),
                      ),
                      SizedBox(
                        height: calculateTextSize(context, 15.0),
                      ),
                      Form(
                        key: formKey,
                        onChanged: isValue,
                        child: Column(
                          children: [
                            CustomTextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(11),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9]')),
                              ],
                              contenModifytPadding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              controller: ifscController,
                              labelText: 'Ifsc Code',
                              hintText: 'IFSC (Required)',
                              validator: (value) {
                                if (value.length == 11) {
                                  if (!RegExp(r'^[a-zA-Z0-9]+$')
                                      .hasMatch(value)) {
                                    return 'Enter valid IFSC code';
                                  }
                                } else {
                                  return 'Enter 11-digit valid IFSC Code';
                                }
                              },
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            CustomTextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(16),
                              ],
                              controller: accnumController,
                              labelText: 'Bank Account Number',
                              hintText: 'Bank Account Number',
                              keyboardType: TextInputType.number,
                              contenModifytPadding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              validator: (value) {
                                if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  if (!(value.length >= 11 &&
                                      value.length <= 16)) {
                                    return 'Account Number length Mismatch';
                                  }
                                } else {
                                  return 'Enter a valid Account Number';
                                }
                              },
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            CustomTextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(16),
                              ],
                              controller: confirmaccnumController,
                              labelText: 'Confirm Bank Account Number',
                              hintText: 'Confirm Bank Account Number',
                              keyboardType: TextInputType.number,
                              contenModifytPadding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              validator: (value) {
                                if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  if (value.length >= 11 &&
                                      value.length <= 16) {
                                    if (accnumController.text !=
                                        confirmaccnumController.text) {
                                      return 'Account Number Mismatch';
                                    }
                                  } else {
                                    return 'Account Number length Mismatch';
                                  }
                                } else {
                                  return 'Enter a valid Account Number';
                                }
                              },
                            ),
                            SizedBox(
                              height: calculateTextSize(context, 8.0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: calculateTextSize(context, 13.0),
                      ),
                      PanWidget(
                        onPressed: isValidate
                            ? () {
                                if (formKey.currentState!.validate()) {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                    openbottomsheet(isExpanded);
                                  });
                                }
                              }
                            : null,
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        bottomSheet: MyBottomSheet(
          isExpanded: isExpanded,
          onPressed: isValidate
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IpvScreen(),
                    ),
                  );
                  isExpanded = false;
                  setState(() {});
                }
              : null,
        ),
      ),
    );
  }
}
