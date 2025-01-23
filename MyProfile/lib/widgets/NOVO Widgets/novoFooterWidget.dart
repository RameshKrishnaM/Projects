// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/colors.dart';
import 'package:provider/provider.dart';

class NovoFooterWidget extends StatelessWidget {
  NovoFooterWidget({super.key, required this.disclimerText});
  String disclimerText;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
              color: const Color.fromRGBO(156, 155, 173, 1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                disclimerText,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontFamily: 'inter',
                  color: Provider.of<NavigationProvider>(context).themeMode ==
                          ThemeMode.dark
                      ? titleTextColorDark
                      : titleTextColorLight,
                ),
                textAlign: TextAlign.justify,
                maxLines: 10,
                softWrap: true,
              )
            ],
          ),
        ));
  }
}

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Text(
        'FLATTRADE © 2023. All rights reserved. SEBI Registration No. INZ000201438 | MemberCode for NSE: 14572 | BSE:6524 | MCX: 16765 | ICEX: 2010',
        style: TextStyle(
            fontSize: 10.0,
            color: Provider.of<NavigationProvider>(context).themeMode ==
                    ThemeMode.dark
                ? const Color.fromRGBO(248, 249, 252, 1)
                : titleTextColorLight,
            height: 1.5),
      ),
    );
  }
}
