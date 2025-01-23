import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'custom_button.dart';

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
        style:
            TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, height: 1.3),
        TextSpan(children: <InlineSpan>[
          TextSpan(
              text: 'By proceeding , ',
              style: TextStyle(color: Color.fromRGBO(102, 98, 98, 1))),
          TextSpan(
              text: 'I agree',
              style: TextStyle(color: Color.fromRGBO(50, 169, 220, 1)),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  showTermsAndConditionBottomSheet(context);
                }),
          TextSpan(
              text: ' to the',
              style: TextStyle(color: Color.fromRGBO(102, 98, 98, 1))),
          TextSpan(
              text: " T&C",
              style: TextStyle(color: Color.fromRGBO(50, 169, 220, 1)),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  //  Navigator.pushNamed(
                  //   context, route.esignHtml,
                  //   arguments: {"url": "https://flattrade.in/terms"})
                  if (await canLaunchUrlString("https://flattrade.in/terms")) {
                    launchUrlString(
                      "https://flattrade.in/terms",
                      // mode: LaunchMode.externalApplication
                    );
                  }
                }),
          TextSpan(
              text: ' and',
              style: TextStyle(color: Color.fromRGBO(102, 98, 98, 1))),
          TextSpan(
              text: " Privacy Policy",
              style: TextStyle(color: Color.fromRGBO(50, 169, 220, 1)),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  //  Navigator.pushNamed(
                  //   context, route.esignHtml,
                  //   arguments: {"url": "https://flattrade.in/terms"})
                  if (await canLaunchUrlString(
                      "https://flattrade.in/privacy")) {
                    launchUrlString("https://flattrade.in/privacy");
                  }
                }),
        ]));
  }
}

showTermsAndConditionBottomSheet(context) {
  return showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 335,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xffedf8fd),
              ),
              child: Column(
                children: [
                  Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text.rich(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.w400),
                      TextSpan(children: [
                        TextSpan(
                            text:
                                "I understand that I am initiating the process to open Demat and Trading account under resident Indian status. I authorize FLATTRADE and its representatives to call, email or SMS me regarding FLATTRADE products and services. For more details "),
                        TextSpan(
                            text: "click here",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (await canLaunchUrlString(
                                    "https://flattrade.in/terms")) {
                                  launchUrlString("https://flattrade.in/terms");
                                }
                              })
                      ])),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            //
            CustomButton(
              buttonText: "Close",
              buttonFunc: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(
              height: 20.0,
            )
          ],
        ),
      );
    },
  );
}
