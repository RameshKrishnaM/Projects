import 'package:ekyc/Custom%20Widgets/custom_button.dart';
import 'package:ekyc/Custom%20Widgets/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

showinfoalert(
    {required BuildContext context,
    required String heading,
    required String htmlcontent}) {
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
          // height:
          //     //  func == null ? null :
          //     height > 600.0 ? 600.0 : height,
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

                  // InkWell(
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       border: Border.all(
                  //         width: 5.0,
                  //         color: const Color.fromRGBO(147, 147, 147, 1),
                  //       ),
                  //       shape: BoxShape.circle,
                  //     ),
                  //     child: const Icon(Icons.close), //arrow_uturn_left
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                heading,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      //  color: titleColor
                    ),
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
              // func == null
              //     ?
              //      HtmlWidget(htmlData["content"])
              //     :
              Flexible(
                child: Scrollbar(
                  interactive: true,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      HtmlWidget(htmlcontent),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              // CustomButton(
              //   buttonFunc: () => Navigator.pop(context),
              //   buttonText: "OK",
              // )
            ],
          ),
        ),
      );
    },
  );
}
