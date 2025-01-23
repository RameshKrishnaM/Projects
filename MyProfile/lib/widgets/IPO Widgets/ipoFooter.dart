import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/colors.dart';
import 'package:provider/provider.dart';

class IpoFooterWidget extends StatelessWidget {
  const IpoFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
              color: const Color.fromRGBO(156, 155, 173, 1), width: 1),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FooterContent(
                  message: 'UPI ID is compulsory for applying online IPO.'),
              SizedBox(
                height: 5.0,
              ),
              FooterContent(
                  message:
                      'You can subscribe to IPO by placing live bids through our portal between 10 AM and 5 PM on trading days and until the IPO subscription is open.'),
              SizedBox(
                height: 5.0,
              ),
              FooterContent(
                  message:
                      'You can pre-apply to IPO by placing offline Bids placed between 5 PM to 10 AM and a mandate will be generated next day.'),
              SizedBox(
                height: 5.0,
              ),
              FooterContent(
                  message:
                      'Once you place the IPO bids, you will receive a mandate request to your corresponding UPI app.'),
              SizedBox(
                height: 5.0,
              ),
              FooterContent(
                  message:
                      'The bidding will happen under the retail category when the IPO application amount is up to Rs 2 lakhs.'),
              SizedBox(
                height: 5.0,
              ),
              FooterContent(
                  message:
                      'The application amount is between Rs 2 lakhs to Rs 5 lakh, the bidding will happen under the HNI category. HNI bidders are requested to submit their application before 3 PM on the last day of the IPO.'),
              SizedBox(
                height: 5.0,
              ),
              FooterContent(
                  message:
                      'Please note the amount will be blocked but not deducted from your bank account.'),
              SizedBox(
                height: 5.0,
              ),
              FooterContent(
                  message:
                      'If there is no allotment of shares in your demat account, then the amount will be unblocked.'),
              SizedBox(
                height: 5.0,
              ),
            ],
          ),
        ));
  }
}

class BulletList extends StatelessWidget {
  final List<dynamic> ipoDisclimer;
  Color bgColor;

  BulletList(this.ipoDisclimer, [this.bgColor = Colors.transparent]);

  @override
  Widget build(BuildContext context) {
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: bgColor,
        border: Border.all(color: Color.fromRGBO(194, 193, 202, 1), width: 1),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ipoDisclimer.map((str) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\u2022',
                // textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: bgColor == Colors.transparent
                        ? themeBasedColor
                        : titleTextColorLight),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    str,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        fontFamily: 'inter',
                        fontSize: 12,
                        height: 1.7,
                        color: bgColor == Colors.transparent
                            ? themeBasedColor
                            : titleTextColorLight),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class FooterContent extends StatelessWidget {
  const FooterContent({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(
            Icons.fiber_manual_record,
            size: 10,
            color: themeBasedColor,
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Flexible(
          child: Text(
            message,
            softWrap: true,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.justify,
            style: TextStyle(
                fontFamily: 'inter',
                fontSize: 12,
                height: 1.3,
                color: themeBasedColor),
          ),
        )
      ],
    );
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
            fontFamily: 'inter',
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
