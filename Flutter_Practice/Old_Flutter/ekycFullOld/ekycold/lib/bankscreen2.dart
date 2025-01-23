import 'package:ekycold/widgets/background_animated_container.dart';
import 'package:ekycold/widgets/custom_form_field.dart';
import 'package:ekycold/widgets/fab.dart';
import 'package:ekycold/widgets/panwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyBankScreen extends StatefulWidget {
  const MyBankScreen({super.key});

  @override
  State<MyBankScreen> createState() => _MyBankScreenState();
}

class _MyBankScreenState extends State<MyBankScreen> {
  final formKey = GlobalKey<FormState>();
  bool isExpanded = false;
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
        backgroundColor: Colors.lightBlue.shade100.withOpacity(0.3),
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
              Text(
                'Link Bank Account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Bank Account in your name from which you will transact funds for trading',
                textAlign: TextAlign.center,
              ),
              const BackgroundAnimatedContainer(
                image: 'credit-card.png',
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
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
                          if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
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
                      ],
                      prefixIcon: Icons.account_balance_outlined,
                      controller: accnumController,
                      labelText: 'Bank Account Number',
                      hintText: 'Bank Account Number',
                      keyboardType: TextInputType.number,
                      contenModifytPadding:
                          const EdgeInsets.symmetric(horizontal: 10.0),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Account Number can't be empty";
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    CustomTextFormField(
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
                        if (value.isNotEmpty) {
                          if (accnumController.text !=
                              confirmaccnumController.text) {
                            return 'Account Number Mismatch';
                          }
                        } else {
                          return "Account Number can't be empty ";
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
                    isExpanded = !isExpanded;
                    setState(() {});
                    // }
                  },
                ),
              ),
            ],
          ),
        ),
        bottomSheet: BottomAppBar(
          shape: AutomaticNotchedShape(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            CircleBorder(),
          ),
        ),
        // bottomSheet: MyBottomSheet(
        //   isExpanded: isExpanded,
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => const IpvScreen(),
        //       ),
        //     );
        //     isExpanded = !isExpanded;
        //     setState(() {});
        //   },
        // ),
      ),
    );
  }
}
