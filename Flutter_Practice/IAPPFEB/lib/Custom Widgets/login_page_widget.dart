import 'dart:io';

import 'package:ekyc/Custom%20Widgets/alertbox.dart';
import 'package:ekyc/Custom%20Widgets/appExitSnackBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class LoginPageWidget extends StatefulWidget {
  final String title;
  final String subTitle;
  final List<Widget> children;
  final bool? pop;
  final bool? isSignIn;
  const LoginPageWidget(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.children,
      this.pop,
      this.isSignIn});

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  bool? isSignIn;
  @override
  void initState() {
    isSignIn = widget.isSignIn;
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
            canPop: !(isSignIn ?? false), // pop ?? true,
            onPopInvoked: (didPop) {
              if (!didPop) {
                openAlertBox(
                    context: context,
                    content: "Do you want to Exit?",
                    onpressedButton1: () => exit(0));
              }
              // Navigator.pushNamed(context, route.signup);
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
                                onTap: () => widget.isSignIn == true
                                    ?
                                    // () => isSignIn == true
                                    //     ? showExitSnackbar()
                                    //     : SystemNavigator.pop()
                                    openAlertBox(
                                        context: context,
                                        content: "Do you want to Exit?",
                                        onpressedButton1: () =>
                                            SystemNavigator.pop())
                                    : Navigator.pop(context),
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
                                  // "assets/images/Flattrade Absolute Zero Logo.png",
                                  width: 150.0,
                                  errorBuilder: (context, error, stackTrace) {
                                    return SizedBox();
                                  },
                                ),
                              ),
                              //      Column(
                              //   children: [
                              //     Transform.scale(
                              //         scale: 1.5,
                              //         child:
                              //             Image.asset("assets/images/flattrade.png")),
                              //     const SizedBox(
                              //       height: 3.0,
                              //     ),
                              //     const Text(
                              //       "Absolute Zero Brokerage",
                              //       style: TextStyle(
                              //           fontSize: 12.5,
                              //           fontWeight: FontWeight.w400,
                              //           color: Color.fromRGBO(171, 171, 171, 1)),
                              //     ),
                              //   ],
                              // )
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
