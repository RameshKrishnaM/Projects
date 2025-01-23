import 'dart:io';

import 'package:ekyc/Custom%20Widgets/alertbox.dart';
import 'package:ekyc/Custom%20Widgets/appExitSnackBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPageWidget extends StatefulWidget {
  final String title;
  final String subTitle;
  final List<Widget> children;
  final bool? pop;
  final bool? isSignIn;
  final bool? isEmail;
  const LoginPageWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.children,
    this.pop,
    this.isSignIn,
    this.isEmail,
  });

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  bool? isSignIn;
  bool? isEmail;
  @override
  void initState() {
    isSignIn = widget.isSignIn;
    isEmail = widget.isEmail;
    setState(() {});
    super.initState();
  }

  showExitSnackbar() {
    isSignIn = false;
    setState(() {});
    appExit(context);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        isSignIn = true;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(1),
        child: SingleChildScrollView(
          child: PopScope(
            canPop: !((isSignIn ?? false) || (isEmail ?? false)),
            onPopInvoked: (didPop) {
              if (!didPop) {
                if (isEmail == true) {
                  // Perform double pop when isEmail is true
                  Navigator.pop(context); // First pop
                  Navigator.pop(context); // Second pop
                } else if (isSignIn == true) {
                  // Show exit confirmation alert if isSignIn is true
                  openAlertBox(
                    context: context,
                    content: "Do you want to Exit?",
                    onpressedButton1: () => exit(0),
                  );
                }
              }
              // if (isEmail == true) {
              //   print("IsEmail");
              //   Navigator.pop(context);
              //   Navigator.pop(context);
              // }
            },
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image:
                            AssetImage("assets/images/background_image.png"))),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isSignIn != true) ...[
                              GestureDetector(
                                onTap: () {
                                  if (widget.isSignIn == true) {
                                    openAlertBox(
                                      context: context,
                                      content: "Do you want to Exit?",
                                      onpressedButton1: () =>
                                          SystemNavigator.pop(),
                                    );
                                  } else if (widget.isEmail == true) {
                                    // Pop twice when isEmail is true
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                                // onTap: () => widget.isSignIn == true
                                //     ? openAlertBox(
                                //         context: context,
                                //         content: "Do you want to Exit?",
                                //         onpressedButton1: () =>
                                //             SystemNavigator.pop())
                                //     : widget.isEmail == true
                                //         ? Navigator.pushNamed(
                                //             context,
                                //             route.signup,
                                //           )
                                //         : Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          9, 101, 218, 0.1),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                          width: 1.0,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color!)),
                                  child: Row(children: [
                                    const Icon(
                                      CupertinoIcons.arrow_uturn_left,
                                      size: 12.0,
                                    ),
                                    const SizedBox(width: 2.0),
                                    Text(
                                      "Back",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(fontSize: 12.0),
                                    )
                                  ]),
                                ),
                              ),
                            ],
                            Expanded(
                              child: Center(
                                child: Image.network(
                                  "https://flattrade.s3.ap-south-1.amazonaws.com/instakyc/Insta_kyc_logo2.png",
                                  width: 150.0,
                                  errorBuilder: (context, error, stackTrace) {
                                    return SizedBox();
                                  },
                                ),
                              ),
                            ),
                            if (isSignIn != true) ...[
                              const SizedBox(
                                width: 40.0,
                              )
                            ]
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Visibility(
                          visible: widget.subTitle.isNotEmpty,
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Visibility(
                          visible: widget.title.isNotEmpty,
                          child: SizedBox(
                            height: 10.0,
                          ),
                        ),
                        Visibility(
                            visible: widget.subTitle.isNotEmpty,
                            child: Text(widget.subTitle)),
                        Visibility(
                          visible: widget.subTitle.isNotEmpty,
                          child: const SizedBox(
                            height: 10.0,
                          ),
                        ),
                        ...widget.children
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
