// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/ncbModels/ncbmasterModel.dart';
import 'package:novo/utils/colors.dart';

import 'package:provider/provider.dart';

import '../../widgets/NOVO Widgets/customLoadingAni.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../widgets/NOVO Widgets/novoFooterWidget.dart';
import '../../widgets/NOVO Widgets/searchField.dart';
import '/Roating/route.dart' as route;

class NcbActivScreen extends StatefulWidget {
  NcbActivScreen({
    super.key,
    required this.ncbMasterDetailData,
    required this.ncbMasterList,
    required this.ncbMasterFound,
    required this.ncbNoDataText,
    required this.ncbDisclaimer,
    required this.index,
  });

  NcbMasterDetails ncbMasterDetailData;
  List<Detail> ncbMasterList;
  String ncbMasterFound;
  String ncbNoDataText;
  String ncbDisclaimer;
  int index;

  @override
  State<NcbActivScreen> createState() => _NcbActivScreenState();
}

class _NcbActivScreenState extends State<NcbActivScreen> {
  List<Detail> filterdatalist = [];
  bool isLoaded = true;
  @override
  void initState() {
    super.initState();

    fetchTheInitialData();
  }

  fetchTheInitialData() async {
    getNcbMasterData();
    // Provider.of<NavigationProvider>(context, listen: false).themeModel();
    // setState(() {});
  }

  refressFunction() async {
    await fetchTheInitialData();
  }

  List<Detail>? ncbMasterDetailList;

  Future<void> getNcbMasterData() async {
    if (await isInternetConnected()) {
      // sgbMasterDetailList =
      //     // [];
      //     widget.sgbMasterData!.sgbDetail;
      filterdatalist = widget.ncbMasterList;

      setState(() {
        isLoaded = false;
      });
    } else {
      noInternetConnectAlertDialog(context, () => getNcbMasterData());
    }
  }

  void searchdata(String value) {
    if (value.isEmpty) {
      filterdatalist = widget.ncbMasterList;
    } else {
      filterdatalist = widget.ncbMasterList
          .where((data) => data.symbol
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    }
    if (filterdatalist.isEmpty) {}
    setState(() {});
  }

  buttonVisibleFun(Detail filterdataList) {
    if (filterdataList.buttonText!.isNotEmpty &&
        filterdataList.buttonText != '' &&
        filterdataList.actionFlag != '' &&
        filterdataList.actionFlag!.isNotEmpty) {
      return true;
    }

    return false;
  }

  disabelButtonFun(Detail filterdataList) {
    if (!(filterdataList.actionFlag == 'U' ||
            filterdataList.actionFlag == 'P' ||
            filterdataList.actionFlag == 'B' ||
            filterdataList.actionFlag == 'M' ||
            filterdataList.actionFlag == 'A' ||
            filterdataList.actionFlag == 'C') ||
        filterdataList.disableActionBtn == true) {
      return true;
    }

    return false;
  }

  // Color buttonColor = Colors.transparent;

  buttonColorFunc(Detail filterdataList) {
    if ((filterdataList.actionFlag == 'P' ||
            filterdataList.actionFlag == 'B') &&
        filterdataList.disableActionBtn == false) {
      return appPrimeColor;
    } else if ((filterdataList.actionFlag == 'M' ||
            filterdataList.actionFlag == 'A' ||
            filterdataList.actionFlag == 'U' ||
            filterdataList.actionFlag == 'C') &&
        filterdataList.disableActionBtn == false) {
      return modifyButtonColor;
    } else if (filterdataList.disableActionBtn == false) {
      return appPrimeColor;
    }
  }

  onSubmit(Detail ncbMasterDetails) {
    Navigator.pushNamed(context, route.ncbplaceorderscreen, arguments: {
      "index": widget.index,
      "ncbMasterDetails": ncbMasterDetails
    });
  }

  @override
  Widget build(BuildContext context) {
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: isLoaded
          ? const Center(
              // child: CircularProgressIndicator(),
              child: LoadingProgress(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchFeild(
                    visible: widget.ncbMasterFound == 'Y' &&
                        widget.ncbMasterList.isNotEmpty,
                    // &&
                    //     widget.ncbMasterDetailData != null,
                    onChange: searchdata,
                  ),
                  Expanded(
                      child: widget.ncbMasterFound == 'N'
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Spacer(),
                                Center(
                                  child: Text(
                                      // SgbMasterDetails!.masterFound == 'N' &&
                                      //             sgbDetails.isNotEmpty
                                      //         ? 'Record not found'
                                      //         :
                                      // 'No Sgb will Alloted..',
                                      widget.ncbNoDataText,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'inter',
                                        color: subTitleTextColor,
                                        fontSize: titleFontSize,
                                      )),
                                ),
                                Spacer(),
                                Visibility(
                                  visible: widget.ncbDisclaimer.isNotEmpty &&
                                      (widget.ncbMasterFound == 'Y' ||
                                          widget.ncbMasterFound == 'N'),
                                  child: NovoFooterWidget(
                                      disclimerText: widget.ncbDisclaimer),
                                )
                              ],
                            )
                          : RefreshIndicator(
                              // edgeOffset: 10.0,
                              onRefresh: () async {
                                // fetchsgbDetailsInAPI();
                                // getSbgMasterData();
                                refressFunction();
                                // timeBasedButtonText(endTimeString: );
                              },
                              child: filterdatalist.isEmpty
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Spacer(),
                                        Center(
                                            child: Text('Record Not Found',
                                                style: TextStyle(
                                                  fontFamily: 'inter',
                                                  color: subTitleTextColor,
                                                  fontSize: titleFontSize,
                                                ))),
                                        Spacer(),
                                        Visibility(
                                          visible: widget
                                                  .ncbDisclaimer.isNotEmpty &&
                                              (widget.ncbMasterFound == 'Y' ||
                                                  widget.ncbMasterFound == 'N'),
                                          child: NovoFooterWidget(
                                              disclimerText:
                                                  widget.ncbDisclaimer),
                                        ),
                                      ],
                                    )
                                  : ListView.separated(
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
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.65,
                                                                child: Text(
                                                                  filterdatalist[
                                                                          index]
                                                                      .name!,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'inter',
                                                                      color:
                                                                          themeBasedColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          titleFontSize,
                                                                      height:
                                                                          1.5),
                                                                ),
                                                              )),
                                                          // FittedBox(
                                                          //     fit: BoxFit
                                                          //         .scaleDown,
                                                          //     child: SizedBox(
                                                          //       width: MediaQuery.of(
                                                          //                   context)
                                                          //               .size
                                                          //               .width *
                                                          //           0.65,
                                                          //       child: Text(
                                                          //         //'Indicative yield ${filterdatalist[index].indicativeYield}',
                                                          //         filterdatalist[
                                                          //                 index]
                                                          //             .name!,
                                                          //         style: TextStyle(
                                                          //             fontFamily:
                                                          //                 'inter',
                                                          //             color:
                                                          //                 subTitleTextColor,
                                                          //             fontSize:
                                                          //                 subTitleFontSize,
                                                          //             height:
                                                          //                 1.5),
                                                          //       ),
                                                          //     )),
                                                          // Text(
                                                          //     'Unit Price - \u20B9${filterdatalist[index].minPrice}',
                                                          //     style: TextStyle(
                                                          //       fontSize: subTitleFontSize,
                                                          //       color: themeBasedColor,
                                                          //     )),
                                                          RichText(
                                                            text: TextSpan(
                                                              text:
                                                                  'Indicative yield  ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'inter',
                                                                  fontSize:
                                                                      subTitleFontSize,
                                                                  color:
                                                                      subTitleTextColor),
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                    text: filterdatalist[
                                                                            index]
                                                                        .indicativeYield,
                                                                    // '\u{20B9}${filterdatalist[index].unitPrice.toString()}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            subTitleFontSize -
                                                                                1,
                                                                        height:
                                                                            1.4,
                                                                        color:
                                                                            themeBasedColor)),
                                                              ],
                                                            ),
                                                          ),
                                                          RichText(
                                                            text: TextSpan(
                                                              text:
                                                                  'Unit Limits  ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'inter',
                                                                  fontSize:
                                                                      subTitleFontSize,
                                                                  color:
                                                                      subTitleTextColor),
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                    text:
                                                                        // rsFormat.format(
                                                                        "${filterdatalist[index].minBidQuantity}-${filterdatalist[index].maxBidQuantity}",
                                                                    // '\u{20B9}${filterdatalist[index].unitPrice.toString()}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            subTitleFontSize -
                                                                                1,
                                                                        height:
                                                                            1.4,
                                                                        color:
                                                                            themeBasedColor)),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: buttonVisibleFun(
                                                          filterdatalist[
                                                              index]),
                                                      child: SizedBox(
                                                          // height: 28,
                                                          width: 100,
                                                          child: MaterialButton(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5),
                                                              elevation: 2,
                                                              disabledColor:
                                                                  Colors.grey,
                                                              disabledTextColor:
                                                                  Colors
                                                                      .white70,
                                                              // minWidth: 100,
                                                              // height: 15,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            18),
                                                              ),
                                                              color: buttonColorFunc(
                                                                  filterdatalist[
                                                                      index]),
                                                              onPressed: disabelButtonFun(
                                                                      filterdatalist[
                                                                          index])
                                                                  ? null
                                                                  : () {
                                                                      onSubmit(
                                                                          filterdatalist[
                                                                              index]);
                                                                    },
                                                              child: Text(
                                                                filterdatalist[
                                                                        index]
                                                                    .buttonText!,
                                                                maxLines: 1,
                                                                // softWrap: false,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: filterdatalist[index].actionFlag ==
                                                                                'M' ||
                                                                            filterdatalist[index].actionFlag == 'U' &&
                                                                                filterdatalist[index].disableActionBtn ==
                                                                                    false
                                                                        ? appPrimeColor
                                                                        : Colors
                                                                            .white),
                                                              ))),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        text: 'Amount  ',
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize,
                                                            color:
                                                                subTitleTextColor),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: filterdatalist[
                                                                              index]
                                                                          .amount! >
                                                                      0
                                                                  ? rsFormat.format(
                                                                      filterdatalist[
                                                                              index]
                                                                          .amount)
                                                                  : "${filterdatalist[index].amount}",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'inter',
                                                                  fontSize:
                                                                      subTitleFontSize -
                                                                          1,
                                                                  height: 1.4,
                                                                  color:
                                                                      themeBasedColor)),
                                                        ],
                                                      ),
                                                    ),
                                                    FittedBox(
                                                      child: Text(
                                                          filterdatalist[index]
                                                              .endDateWithTime!,
                                                          style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize -
                                                                    1,
                                                            color:
                                                                themeBasedColor,
                                                          )),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Column(
                                            children: [
                                              SizedBox(
                                                height: 20.0,
                                              ),
                                              Visibility(
                                                visible: widget.ncbDisclaimer
                                                        .isNotEmpty &&
                                                    (widget.ncbMasterFound ==
                                                            'Y' ||
                                                        widget.ncbMasterFound ==
                                                            'N'),
                                                child: NovoFooterWidget(
                                                    disclimerText:
                                                        widget.ncbDisclaimer),
                                              ),
                                              // SizedBox(
                                              //   height: 20.0,
                                              // ),
                                              // const Footer(),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                            )),
                ],
              ),
            ),
    );
  }
}
