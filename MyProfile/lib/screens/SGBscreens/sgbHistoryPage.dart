// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_null_comparison, use_build_context_synchronously, file_names, must_be_immutable

// import 'dart:js_util';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/sgbModels/sgbhistorymodel.dart';

import 'package:novo/utils/colors.dart';

import 'package:novo/widgets/SGB%20Widgets/sgbHistoryPriceInfoDailog.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../widgets/NOVO Widgets/searchField.dart';

class SgbappliedPage extends StatefulWidget {
  const SgbappliedPage({
    super.key,
    required this.sgbHistoryData,
    // required this.disclaimer
  });
  final SgbHistory? sgbHistoryData;
  // String disclaimer;

  @override
  State<SgbappliedPage> createState() => _SgbappliedPageState();
}

class _SgbappliedPageState extends State<SgbappliedPage>
    with AutomaticKeepAliveClientMixin {
  bool isLoaded = true;
  List openhistory = [];
  double timelineHight = 40.0;
  final DateFormat format = DateFormat("yyyy-MM-dd");
  final ScrollController _controller = ScrollController();
  List<SgbOrderHistoryArr>? sgbHistoryDetailList;
  String? sgbHistoryNoDataText;
  List<SgbOrderHistoryArr> filterdatalist = [];
  int cancelFlagCount = 0;
  @override
  void initState() {
    super.initState();
    fetchTheInitialData();
  }

  fetchTheInitialData() async {
    getSbgHistoryData();

    // Provider.of<NavigationProvider>(context, listen: false).themeModel();
    // setState(() {});
  }

  Future<void> getSbgHistoryData() async {
    if (await isInternetConnected()) {
      if (widget.sgbHistoryData != null) {
        sgbHistoryDetailList = widget.sgbHistoryData!.sgbOrderHistoryArr;
        filterdatalist = sgbHistoryDetailList!;
        sgbHistoryNoDataText = widget.sgbHistoryData!.historynoDataText;
        setState(() {
          isLoaded = false;
        });
      } else {
        sgbHistoryDetailList = [];
        // filterdatalist = sgbHistoryDetailList!;
        //////////print('SgbHistoryData is Null');
      }
    } else {
      noInternetConnectAlertDialog(context, () => getSbgHistoryData());
    }
  }

  void filterdata(String value) {
    if (value.isEmpty) {
      filterdatalist = sgbHistoryDetailList!;
    } else {
      filterdatalist = sgbHistoryDetailList!
          .where((data) =>
              data.orderStatus
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              data.name
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              data.orderDate
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  statusColorFun(SgbOrderHistoryArr filterdatalist, context) {
    if (filterdatalist.statusColor == 'G') {
      return primaryGreenColor;
    } else if (filterdatalist.statusColor == 'R') {
      return primaryRedColor;
    } else {
      return Provider.of<NavigationProvider>(context).themeMode ==
              ThemeMode.dark
          ? titleTextColorDark
          : titleTextColorLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    var themeModeLight =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.light;
    return Scaffold(
      body: isLoaded
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SearchFeild(
                          visible: widget.sgbHistoryData!.historyFound == 'Y' &&
                              sgbHistoryDetailList!.isNotEmpty,
                          onChange: filterdata,
                        ),
                        Expanded(
                          child: widget.sgbHistoryData!.historyFound == 'N'
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                          widget.sgbHistoryData!
                                              .historynoDataText,
                                          style: TextStyle(
                                            fontFamily: 'inter',
                                            color: subTitleTextColor,
                                            fontSize: titleFontSize,
                                          )),
                                    ),
                                  ],
                                )
                              : filterdatalist.isEmpty
                                  ? Center(
                                      child: Text('Record Not Found',
                                          style: TextStyle(
                                            fontFamily: 'inter',
                                            color: subTitleTextColor,
                                            fontSize: titleFontSize,
                                          )))
                                  : ListView.separated(
                                      controller: _controller,
                                      separatorBuilder: (context, index) {
                                        return Divider(
                                          color:
                                              Provider.of<NavigationProvider>(
                                                              context)
                                                          .themeMode ==
                                                      ThemeMode.dark
                                                  ? Colors.white10 // Light mode
                                                  : Color.fromRGBO(
                                                      235, 237, 236, 1),
                                          thickness: 1.5,
                                        );
                                      },
                                      itemCount: filterdatalist.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index < filterdatalist.length) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Tranche',
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize,
                                                            color:
                                                                subTitleTextColor),
                                                      ),
                                                      SizedBox(
                                                        // color: Colors.red,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.52,
                                                        child: Text(
                                                          filterdatalist[index]
                                                              .name,
                                                          overflow: TextOverflow
                                                              .visible,
                                                          softWrap: true,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color:
                                                                  themeBasedColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize:
                                                                  subTitleFontSize,
                                                              height: 1.4),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'Ordered Date',
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize,
                                                            color:
                                                                subTitleTextColor),
                                                      ),
                                                      Text(
                                                        filterdatalist[index]
                                                            .orderDate,
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            color:
                                                                themeBasedColor,
                                                            fontSize:
                                                                subTitleFontSize -
                                                                    2,
                                                            height: 1.4),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Int.RefNo',
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize,
                                                            color:
                                                                subTitleTextColor),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.52,
                                                        child: Text(
                                                          filterdatalist[index]
                                                              .isin,
                                                          overflow: TextOverflow
                                                              .visible,
                                                          softWrap: true,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color:
                                                                  themeBasedColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize:
                                                                  subTitleFontSize,
                                                              height: 1.4),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'Status',
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize,
                                                            color:
                                                                subTitleTextColor),
                                                      ),
                                                      Text(
                                                        filterdatalist[index]
                                                            .orderStatus,
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            color: statusColorFun(
                                                                filterdatalist[
                                                                    index],
                                                                context),
                                                            fontSize:
                                                                subTitleFontSize -
                                                                    2,
                                                            height: 1.4),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Exch OrderNo',
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize,
                                                            color:
                                                                subTitleTextColor),
                                                      ),
                                                      Text(
                                                        filterdatalist[index]
                                                            .exchOrderNo,
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            color:
                                                                themeBasedColor,
                                                            fontSize:
                                                                subTitleFontSize,
                                                            height: 1.4),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'Units',
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize,
                                                            color:
                                                                subTitleTextColor),
                                                      ),
                                                      Text(
                                                        filterdatalist[index]
                                                            .requestedUnit
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontFamily: 'inter',
                                                          fontSize:
                                                              subTitleFontSize,
                                                          height: 1.4,
                                                          color:
                                                              themeBasedColor,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5.0,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Unit price',
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize,
                                                            color:
                                                                subTitleTextColor),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            rsFormat.format(
                                                                filterdatalist[
                                                                        index]
                                                                    .requestedUnitPrice),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'inter',
                                                                color:
                                                                    themeBasedColor,
                                                                fontSize:
                                                                    subTitleFontSize,
                                                                height: 1.4),
                                                          ),
                                                          SizedBox(
                                                            width: 5.0,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              sgbHistoryPriceInfoDailog(
                                                                  filterdatalist[
                                                                      index],
                                                                  context);
                                                            },
                                                            child: Icon(
                                                              CupertinoIcons
                                                                  .info,
                                                              size: 15,
                                                              color: themeModeLight
                                                                  ? appPrimeColor
                                                                  : Colors.blue,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'Total',
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize,
                                                            color:
                                                                subTitleTextColor),
                                                      ),
                                                      Text(
                                                        rsFormat.format(
                                                            filterdatalist[
                                                                    index]
                                                                .requestedAmount),
                                                        style: TextStyle(
                                                          fontFamily: 'inter',
                                                          fontSize:
                                                              subTitleFontSize,
                                                          height: 1.4,
                                                          color:
                                                              themeBasedColor,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5.0,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Column(
                                            children: [
                                              // SizedBox(
                                              //   height: 20.0,
                                              // ),
                                              // Visibility(
                                              //   visible: widget.disclaimer
                                              //           .isNotEmpty &&
                                              //       widget.sgbHistoryData!
                                              //               .historyFound ==
                                              //           'Y',
                                              //   child: FooterSbgWidget(
                                              //       disclimerText:
                                              //           widget.disclaimer),
                                              // ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer(),
              ],
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// class SgbHistoryInfoContent extends StatelessWidget {
//   SgbHistoryInfoContent({
//     super.key,
//     required this.infoTitleUnit,
//     required this.infoUnit,
//     required this.infoTitleUnitPrice,
//     required this.infoUnitPrice,
//     required this.infoTitleAmount,
//     required this.infoUnitAmount,
//   });

//   String infoTitleUnit;
//   dynamic infoUnit;
//   String infoTitleUnitPrice;
//   dynamic infoUnitPrice;
//   String infoTitleAmount;
//   dynamic infoUnitAmount;

//   double textHeight = 1.7;

//   @override
//   Widget build(BuildContext context) {
//     var themeModeLight =
//         Provider.of<NavigationProvider>(context, listen: false).themeMode ==
//             ThemeMode.light;
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               infoTitleUnit,
//               style: themeModeLight
//                   ? ThemeClass.lighttheme.textTheme.bodyMedium!
//                       .copyWith(height: textHeight)
//                   : ThemeClass.Darktheme.textTheme.bodyMedium!
//                       .copyWith(height: textHeight),
//             ),
//             Text(
//               infoUnit.toString(),
//               style: themeModeLight
//                   ? ThemeClass.lighttheme.textTheme.titleMedium!
//                       .copyWith(height: textHeight)
//                   : ThemeClass.Darktheme.textTheme.titleMedium!
//                       .copyWith(height: textHeight),
//             )
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               infoTitleUnitPrice,
//               style: themeModeLight
//                   ? ThemeClass.lighttheme.textTheme.bodyMedium!
//                       .copyWith(height: textHeight)
//                   : ThemeClass.Darktheme.textTheme.bodyMedium!
//                       .copyWith(height: textHeight),
//             ),
//             Text(
//               rsFormat.format(infoUnitPrice),
//               style: themeModeLight
//                   ? ThemeClass.lighttheme.textTheme.titleMedium!
//                       .copyWith(height: textHeight)
//                   : ThemeClass.Darktheme.textTheme.titleMedium!
//                       .copyWith(height: textHeight),
//             )
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               infoTitleAmount,
//               style: themeModeLight
//                   ? ThemeClass.lighttheme.textTheme.bodyMedium!
//                       .copyWith(height: textHeight)
//                   : ThemeClass.Darktheme.textTheme.bodyMedium!
//                       .copyWith(height: textHeight),
//             ),
//             Text(
//               rsFormat.format(infoUnitAmount),
//               style: themeModeLight
//                   ? ThemeClass.lighttheme.textTheme.titleMedium!
//                       .copyWith(height: textHeight)
//                   : ThemeClass.Darktheme.textTheme.titleMedium!
//                       .copyWith(height: textHeight),
//             )
//           ],
//         ),
//       ],
//     );
//   }
// }
