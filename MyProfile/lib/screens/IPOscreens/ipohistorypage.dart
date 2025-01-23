import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';

import 'package:novo/model/ipoModels/ipoHistoryDetails.dart';

import 'package:novo/utils/colors.dart';
import 'package:novo/widgets/IPO%20Widgets/IpoMrkDataDailog.dart';
import 'package:novo/widgets/NOVO%20Widgets/loadingDailogwithCircle.dart';

import 'package:provider/provider.dart';

import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';

import '../../widgets/IPO Widgets/showHistoryDetails.dart';
import '../../widgets/NOVO Widgets/customLoadingAni.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../widgets/NOVO Widgets/searchField.dart';

// ignore: must_be_immutable
class IpoHistoryPage extends StatefulWidget {
  IpoHistoryPage({
    super.key,
    required this.ipoHistoryDetailsData,
    // required this.ipoDisclaimer
  });

  IpoHistoryDetails ipoHistoryDetailsData;

  // dynamic ipoDisclaimer;

  @override
  State<IpoHistoryPage> createState() => _IpoHistoryPageState();
}

class _IpoHistoryPageState extends State<IpoHistoryPage>
    with AutomaticKeepAliveClientMixin {
  int cancelFlagCount = 0;
  List<HistoryDetail> filterdatalist = [];
  final DateFormat format = DateFormat("yyyy-MM-dd");
/* Get Ipo History API */
  // Future<void> getIpoHistoryInAPI() async {
  //   if (await isInternetConnected()) {
  //     Map? json = await getIpoHistory(context: context);
  //     // //////////print(json);
  //     if (json != null) {
  //       final List<dynamic> ipoHistoryList = json['history'] ?? [];
  //       ipoHistory = ipoHistoryList.map((e) => History.fromJson(e)).toList();

  //       filterdatalist = ipoHistory;

  //       for (var element in filterdatalist) {
  //         if (element.status == 'success' && element.cancelFlag == 'N') {
  //           cancelFlagCount++;
  //         }
  //       }
  //     }
  //     openhistory = List.generate(ipoHistory.length, (index) => false);
  //     setState(() {
  //       isLoaded = false;
  //     });
  //   } else {
  //     noInternetConnectAlertDialog(context, () => getIpoHistoryInAPI());
  //   }
  // }
  List<HistoryDetail>? ipoHistoryDetailList;

  bool isLoaded = true;
  List openhistory = [];
  double timelineHight = 40.0;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    getIpoHistoryData();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> getIpoHistoryData() async {
    if (await isInternetConnected()) {
      if (widget.ipoHistoryDetailsData != null) {
        ipoHistoryDetailList = widget.ipoHistoryDetailsData.historyDetail;

        filterdatalist = ipoHistoryDetailList!;

        openhistory =
            List.generate(ipoHistoryDetailList!.length, (index) => false);
        setState(() {
          isLoaded = false;
        });
      } else {
        ipoHistoryDetailList = [];
      }
    } else {
      noInternetConnectAlertDialog(context, () => getIpoHistoryData());
    }
  }

/* Search the symbol from the api */
  void filterdata(String value) {
    if (value.isEmpty) {
      filterdatalist = ipoHistoryDetailList!;
    } else {
      filterdatalist = ipoHistoryDetailList!
          .where((data) =>
              data.symbol
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              data.orderDate
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              data.status
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  statusColorFun(HistoryDetail filterdatalist, context) {
    // ////////print(filterdatalist.statusColor);
    if (filterdatalist.statusColor == 'G') {
      return primaryGreenColor;
    } else if (filterdatalist.statusColor == 'R') {
      return primaryRedColor;
    } else if (filterdatalist.statusColor == 'O') {
      return primaryOrangeColor;
    } else {
      return Provider.of<NavigationProvider>(context).themeMode ==
              ThemeMode.dark
          ? titleTextColorDark
          : titleTextColorLight;
    }
  }

  void _animateToIndex(int index) {
    _controller.animateTo(
      index * 76,
      duration: Duration(milliseconds: 10),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    var themeModeLight =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.light;
    super.build(context);
    return Scaffold(
      body: isLoaded
          ? LoadingProgress()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchFeild(
                    visible: ipoHistoryDetailList!.isNotEmpty,
                    onChange: filterdata,
                  ),
                  Expanded(
                    child: widget.ipoHistoryDetailsData.historyFound == 'N'
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                    widget.ipoHistoryDetailsData
                                        .historyNoDataText!,
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
                                        Provider.of<NavigationProvider>(context)
                                                    .themeMode ==
                                                ThemeMode.dark
                                            ? Colors.white10 // Light mode
                                            : Color.fromRGBO(235, 237, 236, 1),
                                    thickness: 1.5,
                                  );
                                },
                                itemCount: filterdatalist.length + 1,
                                itemBuilder: (context, index) {
                                  if (index < filterdatalist.length) {
                                    DateTime today = DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day)
                                        .add(Duration(days: 1));
                                    bool startDateValidation =
                                        filterdatalist[index].startDate!.isEmpty
                                            ? false
                                            : format
                                                .parse(filterdatalist[index]
                                                    .startDate!)
                                                .isBefore(today);
                                    bool endDateValidation =
                                        filterdatalist[index].endDate!.isEmpty
                                            ? false
                                            : format
                                                .parse(filterdatalist[index]
                                                    .endDate!)
                                                .isBefore(today);
                                    bool allotmentDateValidation =
                                        filterdatalist[index].allotment!.isEmpty
                                            ? false
                                            : format
                                                .parse(filterdatalist[index]
                                                    .allotment!)
                                                .isBefore(today);
                                    bool refuntDateValidation =
                                        filterdatalist[index].refund!.isEmpty
                                            ? false
                                            : format
                                                .parse(filterdatalist[index]
                                                    .refund!)
                                                .isBefore(today);
                                    bool dematDateValidation = filterdatalist[
                                                index]
                                            .demat!
                                            .isEmpty
                                        ? false
                                        : format
                                            .parse(filterdatalist[index].demat!)
                                            .isBefore(today);
                                    bool listingDateValidation =
                                        filterdatalist[index].listing!.isEmpty
                                            ? false
                                            : format
                                                .parse(filterdatalist[index]
                                                    .listing!)
                                                .isBefore(today);
                                    if (index < filterdatalist.length) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 60,
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              onTap: () {
                                                !openhistory[index]
                                                    ? _animateToIndex(index)
                                                    : null;
                                                setState(() {
                                                  for (var i = 0;
                                                      i < openhistory.length;
                                                      i++) {
                                                    if (index == i) {
                                                      openhistory[i] =
                                                          !openhistory[i];
                                                    } else {
                                                      openhistory[i] = false;
                                                    }
                                                  }
                                                });
                                              },
                                              minLeadingWidth: 0.0,
                                              titleAlignment:
                                                  ListTileTitleAlignment.center,
                                              title: Row(
                                                children: [
                                                  Text(
                                                    filterdatalist[index]
                                                        .symbol!,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Provider.of<NavigationProvider>(
                                                                        context)
                                                                    .themeMode ==
                                                                ThemeMode.dark
                                                            ? titleTextColorDark
                                                            : titleTextColorLight,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            titleFontSize),
                                                  ),
                                                  SizedBox(
                                                    width: 8.0,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      loadingDailogWithCircle(
                                                          context);

                                                      fetchIpoMktDemandInAPI(
                                                          context,
                                                          filterdatalist[index]
                                                              .masterId!,
                                                          filterdatalist[index]
                                                              .symbol!,
                                                          filterdatalist[index]
                                                              .issueSizeWithText!);
                                                    },
                                                    child: Icon(
                                                      CupertinoIcons.info,
                                                      size: 16,
                                                      color: themeModeLight
                                                          ? appPrimeColor
                                                          : Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              subtitle: Text(
                                                'APP.NO : ${filterdatalist[index].categoryList!.applicationNo}',
                                                style: TextStyle(
                                                    color: Provider.of<NavigationProvider>(
                                                                    context)
                                                                .themeMode ==
                                                            ThemeMode.dark
                                                        ? titleTextColorDark
                                                        : titleTextColorLight,
                                                    fontSize: subTitleFontSize),
                                              ),
                                              trailing: SizedBox(
                                                width: 105,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      ' ${filterdatalist[index].orderDate}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                      style: TextStyle(
                                                          color:
                                                              subTitleTextColor,
                                                          fontFamily: 'inter',
                                                          height: 1.2,
                                                          fontSize:
                                                              subTitleFontSize),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        filterdatalist[index]
                                                                    .cancelFlag ==
                                                                'N'
                                                            ? Text(
                                                                " ${filterdatalist[index].status}",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    color: statusColorFun(
                                                                        filterdatalist[
                                                                            index],
                                                                        context),
                                                                    fontSize:
                                                                        subTitleFontSize),
                                                              )
                                                            : Text(
                                                                " ${filterdatalist[index].status}",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    color: statusColorFun(
                                                                        filterdatalist[
                                                                            index],
                                                                        context),
                                                                    fontSize:
                                                                        subTitleFontSize),
                                                              ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                          child: Icon(
                                                            openhistory[index]
                                                                ? CupertinoIcons
                                                                    .arrowtriangle_up_fill
                                                                : CupertinoIcons
                                                                    .arrowtriangle_down_fill,
                                                            size: 10,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: openhistory[index],
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.9,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Instrument',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    color:
                                                                        subTitleTextColor,
                                                                    fontSize:
                                                                        13.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  filterdatalist[
                                                                          index]
                                                                      .symbol!,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'inter',
                                                                      color: Provider.of<NavigationProvider>(context).themeMode ==
                                                                              ThemeMode
                                                                                  .dark
                                                                          ? titleTextColorDark
                                                                          : titleTextColorLight,
                                                                      fontSize:
                                                                          subTitleFontSize,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 3.0,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Bid Date',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    color:
                                                                        subTitleTextColor,
                                                                    fontSize:
                                                                        13.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  filterdatalist[
                                                                          index]
                                                                      .orderDate!,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'inter',
                                                                      color: Provider.of<NavigationProvider>(context).themeMode ==
                                                                              ThemeMode
                                                                                  .dark
                                                                          ? titleTextColorDark
                                                                          : titleTextColorLight,
                                                                      fontSize:
                                                                          subTitleFontSize,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 3.0,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Application No',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    color:
                                                                        subTitleTextColor,
                                                                    fontSize:
                                                                        13.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  filterdatalist[
                                                                          index]
                                                                      .categoryList!
                                                                      .applicationNo!,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'inter',
                                                                      color: Provider.of<NavigationProvider>(context).themeMode ==
                                                                              ThemeMode
                                                                                  .dark
                                                                          ? titleTextColorDark
                                                                          : titleTextColorLight,
                                                                      fontSize:
                                                                          subTitleFontSize,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 3.0,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Status',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    color:
                                                                        subTitleTextColor,
                                                                    fontSize:
                                                                        13.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  filterdatalist[
                                                                          index]
                                                                      .status!,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'inter',
                                                                      color: Provider.of<NavigationProvider>(context).themeMode ==
                                                                              ThemeMode
                                                                                  .dark
                                                                          ? titleTextColorDark
                                                                          : titleTextColorLight,
                                                                      fontSize:
                                                                          subTitleFontSize,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 3.0,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Depository Status',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    color:
                                                                        subTitleTextColor,
                                                                    fontSize:
                                                                        13.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  filterdatalist[
                                                                          index]
                                                                      .dpStatus!,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'inter',
                                                                      color: Provider.of<NavigationProvider>(context).themeMode ==
                                                                              ThemeMode
                                                                                  .dark
                                                                          ? titleTextColorDark
                                                                          : titleTextColorLight,
                                                                      fontSize:
                                                                          subTitleFontSize,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 3.0,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'UPI Status',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    color:
                                                                        subTitleTextColor,
                                                                    fontSize:
                                                                        13.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  filterdatalist[
                                                                          index]
                                                                      .upiStatus!,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'inter',
                                                                      color: Provider.of<NavigationProvider>(context).themeMode ==
                                                                              ThemeMode
                                                                                  .dark
                                                                          ? titleTextColorDark
                                                                          : titleTextColorLight,
                                                                      fontSize:
                                                                          subTitleFontSize,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.75,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height: timelineHight,
                                                          child: TimelineTile(
                                                            isFirst: true,
                                                            isLast: false,
                                                            beforeLineStyle:
                                                                LineStyle(
                                                              color: !startDateValidation
                                                                  ? inactiveColor
                                                                  : activeColor,
                                                            ),
                                                            indicatorStyle:
                                                                IndicatorStyle(
                                                              width: 25,
                                                              color: !startDateValidation
                                                                  ? inactiveColor
                                                                  : activeColor,
                                                              iconStyle: IconStyle(
                                                                  fontSize:
                                                                      17.0,
                                                                  iconData: Icons
                                                                      .done_all_rounded,
                                                                  color: !startDateValidation
                                                                      ? inactiveColor
                                                                      : titleTextColorDark),
                                                            ),
                                                            endChild: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          5.0),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              decoration: BoxDecoration(
                                                                  color: !startDateValidation
                                                                      ? inactiveColor
                                                                      : activeColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                              child: Text(
                                                                'Offer Start ${filterdatalist[index].startDate}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    fontSize:
                                                                        contentFontSize,
                                                                    fontWeight: !startDateValidation
                                                                        ? FontWeight
                                                                            .normal
                                                                        : FontWeight
                                                                            .bold,
                                                                    color: !startDateValidation
                                                                        ? titleTextColorLight
                                                                        : titleTextColorDark),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: timelineHight,
                                                          child: TimelineTile(
                                                            isFirst: false,
                                                            isLast: false,
                                                            beforeLineStyle:
                                                                LineStyle(
                                                              color: !endDateValidation
                                                                  ? inactiveColor
                                                                  : activeColor,
                                                            ),
                                                            indicatorStyle:
                                                                IndicatorStyle(
                                                              width: 25,
                                                              color: !endDateValidation
                                                                  ? inactiveColor
                                                                  : activeColor,
                                                              iconStyle: IconStyle(
                                                                  fontSize:
                                                                      17.0,
                                                                  iconData: Icons
                                                                      .done_all_rounded,
                                                                  color: !endDateValidation
                                                                      ? inactiveColor
                                                                      : titleTextColorDark),
                                                            ),
                                                            endChild: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          5.0),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              decoration: BoxDecoration(
                                                                  color: !endDateValidation
                                                                      ? inactiveColor
                                                                      : activeColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                              child: Text(
                                                                'Offer End  ${filterdatalist[index].endDate}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    fontSize:
                                                                        contentFontSize,
                                                                    fontWeight: !endDateValidation
                                                                        ? FontWeight
                                                                            .normal
                                                                        : FontWeight
                                                                            .bold,
                                                                    color: !endDateValidation
                                                                        ? titleTextColorLight
                                                                        : titleTextColorDark),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: timelineHight,
                                                          child: TimelineTile(
                                                            isFirst: false,
                                                            isLast: false,
                                                            beforeLineStyle:
                                                                LineStyle(
                                                              color: !allotmentDateValidation
                                                                  ? inactiveColor
                                                                  : activeColor,
                                                            ),
                                                            indicatorStyle:
                                                                IndicatorStyle(
                                                              width: 25,
                                                              color: !allotmentDateValidation
                                                                  ? inactiveColor
                                                                  : activeColor,
                                                              iconStyle: IconStyle(
                                                                  fontSize:
                                                                      17.0,
                                                                  iconData: Icons
                                                                      .done_all_rounded,
                                                                  color: !allotmentDateValidation
                                                                      ? inactiveColor
                                                                      : titleTextColorDark),
                                                            ),
                                                            endChild: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          5.0),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              decoration: BoxDecoration(
                                                                  color: !allotmentDateValidation
                                                                      ? inactiveColor
                                                                      : activeColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                              child: Text(
                                                                'Allotment  ${filterdatalist[index].allotment}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    fontSize:
                                                                        contentFontSize,
                                                                    fontWeight: !allotmentDateValidation
                                                                        ? FontWeight
                                                                            .normal
                                                                        : FontWeight
                                                                            .bold,
                                                                    color: !allotmentDateValidation
                                                                        ? titleTextColorLight
                                                                        : titleTextColorDark),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: timelineHight,
                                                          child: TimelineTile(
                                                            isFirst: false,
                                                            isLast: false,
                                                            beforeLineStyle:
                                                                LineStyle(
                                                              color: !refuntDateValidation
                                                                  ? inactiveColor
                                                                  : activeColor,
                                                            ),
                                                            indicatorStyle:
                                                                IndicatorStyle(
                                                              width: 25,
                                                              color: !refuntDateValidation
                                                                  ? inactiveColor
                                                                  : activeColor,
                                                              iconStyle: IconStyle(
                                                                  fontSize:
                                                                      17.0,
                                                                  iconData: Icons
                                                                      .done_all_rounded,
                                                                  color: !refuntDateValidation
                                                                      ? inactiveColor
                                                                      : titleTextColorDark),
                                                            ),
                                                            endChild: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          5.0),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              decoration: BoxDecoration(
                                                                  color: !refuntDateValidation
                                                                      ? inactiveColor
                                                                      : activeColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                              child: Text(
                                                                'Refund  ${filterdatalist[index].refund}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    fontSize:
                                                                        contentFontSize,
                                                                    fontWeight: !refuntDateValidation
                                                                        ? FontWeight
                                                                            .normal
                                                                        : FontWeight
                                                                            .bold,
                                                                    color: !refuntDateValidation
                                                                        ? titleTextColorLight
                                                                        : titleTextColorDark),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: timelineHight,
                                                          child: TimelineTile(
                                                            isFirst: false,
                                                            isLast: false,
                                                            beforeLineStyle:
                                                                LineStyle(
                                                              color: !dematDateValidation
                                                                  ? inactiveColor
                                                                  : activeColor,
                                                            ),
                                                            indicatorStyle:
                                                                IndicatorStyle(
                                                              width: 25,
                                                              color: !dematDateValidation
                                                                  ? inactiveColor
                                                                  : activeColor,
                                                              iconStyle: IconStyle(
                                                                  fontSize:
                                                                      17.0,
                                                                  iconData: Icons
                                                                      .done_all_rounded,
                                                                  color: !dematDateValidation
                                                                      ? inactiveColor
                                                                      : titleTextColorDark),
                                                            ),
                                                            endChild: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          5.0),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              decoration: BoxDecoration(
                                                                  color: !dematDateValidation
                                                                      ? inactiveColor
                                                                      : activeColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                              child: Text(
                                                                'Demat  ${filterdatalist[index].demat}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    fontSize:
                                                                        contentFontSize,
                                                                    fontWeight: !dematDateValidation
                                                                        ? FontWeight
                                                                            .normal
                                                                        : FontWeight
                                                                            .bold,
                                                                    color: !dematDateValidation
                                                                        ? titleTextColorLight
                                                                        : titleTextColorDark),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: timelineHight,
                                                          child: TimelineTile(
                                                            isFirst: false,
                                                            isLast: true,
                                                            beforeLineStyle:
                                                                LineStyle(
                                                              color: !listingDateValidation
                                                                  ? inactiveColor
                                                                  : activeColor,
                                                            ),
                                                            indicatorStyle:
                                                                IndicatorStyle(
                                                              width: 25,
                                                              color: !listingDateValidation
                                                                  ? inactiveColor
                                                                  : activeColor,
                                                              iconStyle: IconStyle(
                                                                  fontSize:
                                                                      17.0,
                                                                  iconData: Icons
                                                                      .done_all_rounded,
                                                                  color: !listingDateValidation
                                                                      ? inactiveColor
                                                                      : titleTextColorDark),
                                                            ),
                                                            endChild: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          5.0),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              decoration: BoxDecoration(
                                                                  color: !listingDateValidation
                                                                      ? inactiveColor
                                                                      : activeColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                              child: Text(
                                                                'Listing  ${filterdatalist[index].listing}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'inter',
                                                                    fontSize:
                                                                        contentFontSize,
                                                                    fontWeight: !listingDateValidation
                                                                        ? FontWeight
                                                                            .normal
                                                                        : FontWeight
                                                                            .bold,
                                                                    color: !listingDateValidation
                                                                        ? titleTextColorLight
                                                                        : titleTextColorDark),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 10.0),
                                                ShowHistoryDetail(
                                                  isHistorypage: true,
                                                  ipoHistoryDetailsData:
                                                      filterdatalist[index],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      );
                                    }
                                  } else {
                                    // return Visibility(
                                    //   visible: widget.ipoDisclaimer.isNotEmpty ||
                                    //       widget.ipoDisclaimer != null,
                                    //   child: Column(
                                    //     children: [
                                    //       const SizedBox(
                                    //         height: 30.0,
                                    //       ),
                                    //       BulletList(widget.ipoDisclaimer)
                                    //     ],
                                    //   ),
                                    // );
                                    // return Column(
                                    //   children: [
                                    //     SizedBox(
                                    //       height: 20.0,
                                    //     ),
                                    //     const IpoFooterWidget(),
                                    //   ],
                                    // );
                                  }
                                  return null;
                                },
                              ),
                  ),
                ],
              ),
            ),
    );
  }
}
