import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../API call/api_call.dart';
import '../Screens/signup.dart';
import 'custom_button.dart';
import 'dotted_line.dart';

void showTerms({required context, required htmlData, func}) {
  List rgbcolor = htmlData["titlerbgcolor"]
      .toString()
      .replaceAll('(', '')
      .replaceAll(')', '')
      .split(",")
      .map((e) => int.parse(e))
      .toList();
  Color titleColor = rgbcolor.length == 3
      ? Color.fromRGBO(rgbcolor[0], rgbcolor[1], rgbcolor[2], 1)
      : Colors.black;
  insertRiskdisclosure() async {
    loadingAlertBox(context);
    var response = await riskdisclosureinsertInAPI(context: context, json: {
      "contentid": htmlData["contentid"],
      "contenttype": htmlData["contenttype"]
    });

    Navigator.pop(context);
    Navigator.pop(context);
    if (response != null) {
      func != null ? func() : null;
    }
  }

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      double height = MediaQuery.of(context).size.height * 0.75;
      return AlertDialog(
        content: Container(
          constraints: BoxConstraints(
              minHeight: 200.0,
              minWidth: MediaQuery.of(context).size.width,
              maxHeight: height > 600.0 ? 600.0 : height,
              maxWidth: MediaQuery.of(context).size.width),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(9, 101, 218, 0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              width: 1.0,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!)),
                      child: Row(children: [
                        Icon(
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
                    onTap: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(''),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                htmlData["title"] ?? "",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.w700, color: titleColor),
              ),
              const SizedBox(
                height: 10.0,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 20.0,
                  child: DottedLine()),
              const SizedBox(
                height: 20.0,
              ),
              Flexible(
                child: Scrollbar(
                  interactive: true,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      HtmlWidget(htmlData["content"]),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              CustomButton(
                buttonFunc: () => insertRiskdisclosure(),
                buttonText: htmlData["buttontext"] ?? "",
              )
            ],
          ),
        ),
      );
    },
  );
}
