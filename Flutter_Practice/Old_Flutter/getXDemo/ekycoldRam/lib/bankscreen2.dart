// import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projectdemo2/ipv.dart';
import 'package:projectdemo2/widgets/CustomFormField.dart';
import 'package:projectdemo2/widgets/fab.dart';
import 'package:projectdemo2/widgets/mybottomsheet.dart';
import 'package:projectdemo2/widgets/mycolor.dart';
import 'package:projectdemo2/widgets/panwidget.dart';
import 'package:projectdemo2/widgets/providerclss.dart';
import 'package:provider/provider.dart';

class MyBankScreen extends StatefulWidget {
  const MyBankScreen({super.key});

  @override
  State<MyBankScreen> createState() => _MyBankScreenState();
}

class _MyBankScreenState extends State<MyBankScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController ifscController = TextEditingController();
  TextEditingController accnumController = TextEditingController();
  TextEditingController confirmaccnumController = TextEditingController();

  final List<String> images = [
    'assets/images/illustrator-security-removebg-preview.png',
    'assets/images/preview1-removebg-preview.png',
    'images/credit-card-4489846-3766585.jpg',
    'images/preview-removebg-preview.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MyProvider>(
      builder: (BuildContext context, value, Widget? child) {
        return WillPopScope(
          onWillPop: () async {
            if (value.isExpanded) {
              value.isExpanded = false;
              setState(() {});
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: bgcolor2,
            floatingActionButton: const MyFAB(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            body: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //   colors: [
                    //     bgcolor1,
                    //     // bgcolor2,
                    //     bgcolor3,
                    //   ],
                    //   begin: Alignment.bottomCenter,
                    //   end: Alignment.topCenter,
                    // ),
                    ),
                child: ListView(
                  padding: const EdgeInsets.all(15.0),
                  children: [
                    const Text(
                      'Link Bank Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Bank Account in your name from which you will transact funds for trading',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),

                    Image.asset(
                      'assets/images/preview-removebg-preview.png',
                      height: 230,
                    ),
                    // CarouselSlider(
                    //   options: CarouselOptions(
                    //     height: 220,
                    //     enlargeCenterPage: true,
                    //     autoPlay: true,
                    //     autoPlayInterval: const Duration(seconds: 3),
                    //     autoPlayAnimationDuration:
                    //         const Duration(milliseconds: 800),
                    //     autoPlayCurve: Curves.fastOutSlowIn,
                    //   ),
                    //   items: images
                    //       .map((imagePath) => Image.asset(
                    //             imagePath,
                    //             fit: BoxFit.cover,
                    //           ))
                    //       .toList(),
                    // ),

                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          CustomTextFormFieldramesh(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(11),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9]')),
                            ],
                            prefixIcon: Icons.security,
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
                          CustomTextFormFieldramesh(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            prefixIcon: Icons.account_balance_outlined,
                            controller: accnumController,
                            labelText: 'Bank Account Number',
                            hintText: 'Bank Account Number',
                            keyboardType: TextInputType.number,
                            contenModifytPadding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            validator: (value) {
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Account Number length Mismatch';
                              }
                            },
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          CustomTextFormFieldramesh(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            prefixIcon: Icons.account_balance_outlined,
                            controller: confirmaccnumController,
                            labelText: 'Confirm Bank Account Number',
                            hintText: 'Confirm Bank Account Number',
                            keyboardType: TextInputType.number,
                            contenModifytPadding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            validator: (value) {
                              if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                                if (accnumController.text !=
                                    confirmaccnumController.text) {
                                  return 'Account Number Mismatch';
                                }
                              } else {
                                return 'Enter a valid Account Number';
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: PanWidget(
                        onPressed: () {
                          // if (formKey.currentState!.validate()) {
                          value.changeExpanded();
                          // }
                        },
                      ),
                    ),
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
                      builder: (context) => const IpvScreen(),
                    ));
                value.changeExpanded();
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }
}
