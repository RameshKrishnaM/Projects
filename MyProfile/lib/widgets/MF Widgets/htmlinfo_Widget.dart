// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/colors.dart';
import 'package:provider/provider.dart';

class HtmlInfoContainer extends StatelessWidget {
  String html;
  dynamic title;
  // var url;
  HtmlInfoContainer({
    super.key,
    required this.html,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    var themeModeDark =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border.all(
            color: themeModeDark
                ? Colors.white10 // Light mode
                : const Color.fromRGBO(235, 237, 236, 1),
          ),
          boxShadow: themeModeDark
              ? null
              : [
                  BoxShadow(
                    color: const Color.fromARGB(255, 230, 228, 228)
                        .withOpacity(0.5),
                    offset: const Offset(
                        0, 1.0), // Offset (x, y) controls the shadow's position
                    blurRadius: 15, // Spread of the shadow
                    spreadRadius:
                        5.0, // Positive values expand the shadow, negative values shrink it
                  ),
                ],
          gradient: LinearGradient(
              colors: [const Color.fromRGBO(255, 243, 224, 1), infoColorStart],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              stops: const [0.98, 1.0]),
          borderRadius: const BorderRadius.all(Radius.circular(7.0)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(
                height: 10,
              ),
              // Text(
              //   html,
              //   style: Theme.of(context).textTheme.bodySmall,
              //   textAlign: TextAlign.justify,
              // )
              HtmlWidget(html,
                  // onTapUrl: (url) => launchUrl(url),

                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        overflow: TextOverflow.visible,
                      )),
            ],
          ),
        ));
  }
}
