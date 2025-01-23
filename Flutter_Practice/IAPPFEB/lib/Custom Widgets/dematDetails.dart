import '../Custom%20Widgets/Service.dart';
import '../Custom%20Widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';

import '../Model/route_model.dart';
import '../Screens/segmentselection.dart';
import 'Custom.dart';
import 'error_message.dart';

// import '../Expansion/Custom.dart';

class DematDetails extends StatelessWidget {
  final String scheme;
  final String dis;
  final String edis;
  final String settlement;
  final List titles;
  final List subTitles;
  final List selectedTile;
  final ScrollController scrollController;
  final RouteModel? routeDetails;
  final List brokerageData;
  final List brokerageHeading;
  const DematDetails(
      {super.key,
      required this.scheme,
      required this.dis,
      required this.edis,
      required this.titles,
      required this.subTitles,
      required this.selectedTile,
      required this.scrollController,
      this.routeDetails,
      required this.brokerageData,
      required this.brokerageHeading,
      required this.settlement});

  @override
  Widget build(BuildContext context) {
    return CustomStyledContainer(
      child:
          // SizedBox(
          //   height: 400.0,
          //   child: ScrollableWidget(
          //     controller: scrollController,
          //     child:
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            ErrorMessageContainer(routeDetails: routeDetails),
            CustomColumnWidget(title: 'Select DP Scheme :', value: scheme),
            const SizedBox(
              height: 15,
            ),
            CustomColumnWidget(
                title: 'Do You require DIS Slip Book', value: dis),
            const SizedBox(
              height: 15,
            ),
            CustomColumnWidget(
                title:
                    'Whether You are required to transact EDIS transaction for sale obligation?',
                value: edis),
            const SizedBox(
              height: 15,
            ),
            CustomColumnWidget(
                title:
                    'I / we authorize FCSPL to settle the funds atleast once in a calendar quarter / month as specified by me below in accordance with regulations in force.',
                value: settlement),
            const SizedBox(
              height: 15,
            ),
            const DottedLine(),
            const SizedBox(
              height: 15,
            ),
            Text(
              'Exchange Segments ',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).textTheme.displayMedium!.color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(
              height: 15,
            ),
            for (var index = 0; index < titles.length; index++) ...{
              CustomTile(
                  title: titles[index],
                  subtitle: subTitles[index],
                  selectedTile: selectedTile),
            },
            if (brokerageHeading.isNotEmpty) ...[
              const SizedBox(
                height: 20.0,
              ),
              // Text(
              //   "Brokerage Tariff Details",
              //   style: Theme.of(context).textTheme.bodyLarge,
              // ),
              // const SizedBox(
              //   height: 10.0,
              // ),
              BrockerageConatiner(
                brokData: brokerageData,
                brokHead: brokerageHeading,
                isSmall: true,
              ),
            ]
          ]),
      //   ),
      // ),
    );
  }
}
