// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/ncbModels/ncbHistoryModel.dart';

import 'package:novo/utils/colors.dart';

import 'package:novo/widgets/NGB%20Widgets/ncbhistoryPriceInfoDailog.dart';

import 'package:provider/provider.dart';

import '../../widgets/NOVO Widgets/customLoadingAni.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../widgets/NOVO Widgets/searchField.dart';

class NcbHistoryScreen extends StatefulWidget {
  NcbHistoryScreen(
      {super.key,
      required this.ncbHistoryDetails,
      required this.ncbHistoryList,
      required this.ncbHistoryFound,
      required this.ncbHistoryNoDataText,
      required this.ncbDisclimer});
  NcbHistoryModel ncbHistoryDetails;
  List<OrderHistoryArr> ncbHistoryList;
  String ncbHistoryFound;
  String ncbHistoryNoDataText;
  String ncbDisclimer;

  @override
  State<NcbHistoryScreen> createState() => _NcbHistoryScreenState();
}

class _NcbHistoryScreenState extends State<NcbHistoryScreen> {
  @override
  void initState() {
    super.initState();
    fetchTheInitialData();
  }

  fetchTheInitialData() async {
    // fetchsgbDetailsInAPI();
    getNcbHIstoryData();
    // timeBasedButtonText();
    Provider.of<NavigationProvider>(context, listen: false).themeModel();
    setState(() {});
  }

  List<OrderHistoryArr> filterdatalist = [];
  bool isLoaded = true;
  final ScrollController _controller = ScrollController();
  Future<void> getNcbHIstoryData() async {
    if (await isInternetConnected()) {
      // if (widget.ncbHistoryList.isNotEmpty) {
      filterdatalist = widget.ncbHistoryList;
      setState(() {
        isLoaded = false;
      });
      // } else {
      //   filterdatalist = [];
      //   // filterdatalist = sgbHistoryDetailList!;
      //   //////////print('SgbHistoryData is Null');
      // }
    } else {
      noInternetConnectAlertDialog(context, () => getNcbHIstoryData());
    }
  }

  void filterdata(String value) {
    if (value.isEmpty) {
      filterdatalist = widget.ncbHistoryList;
    } else {
      filterdatalist = widget.ncbHistoryList
          .where((data) =>
              data.symbol
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              data.orderDate
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              data.orderStatus
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
    }
    if (filterdatalist.isEmpty) {}
    setState(() {});
  }

  statusColorFun(OrderHistoryArr filterdatalist, context) {
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
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    var themeModeLight =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.light;
    return Scaffold(
      body: isLoaded
          ? const Center(
              // child: CircularProgressIndicator(),
              child: LoadingProgress(),
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
                          visible: widget.ncbHistoryFound == 'Y' &&
                              widget.ncbHistoryList.isNotEmpty,
                          onChange: filterdata,
                        ),
                        Expanded(
                          child: widget.ncbHistoryFound == 'N'
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(widget.ncbHistoryNoDataText,
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
                                                  : const Color.fromRGBO(
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
                                                        'Security Name',
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
                                                              .symbol!,
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
                                                        'Bid Order date',
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize,
                                                            color:
                                                                subTitleTextColor),
                                                      ),
                                                      Text(
                                                        filterdatalist[index]
                                                            .orderDate!,
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
                                              const SizedBox(
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
                                                        'Int.Order No',
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
                                                              .orderNo!,
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
                                                            .orderStatus!,
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
                                              const SizedBox(
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
                                                        'Order No',
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize,
                                                            color:
                                                                subTitleTextColor),
                                                      ),
                                                      Text(
                                                        filterdatalist[index]
                                                            .respOrderNo!,
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
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
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
                                                            '${filterdatalist[index].requestedUnitPrice}',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'inter',
                                                                color:
                                                                    themeBasedColor,
                                                                fontSize:
                                                                    subTitleFontSize,
                                                                height: 1.4),
                                                          ),
                                                          const SizedBox(
                                                            width: 5.0,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              ncbHistoryPriceInfoDailog(
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
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        } else {
                                          return const Column(
                                            children: [
                                              SizedBox(
                                                height: 20.0,
                                              ),
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
}
