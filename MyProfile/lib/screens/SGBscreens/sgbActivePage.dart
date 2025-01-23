// ignore_for_file: prefer_final_fields, unused_field, no_leading_underscores_for_local_identifiers, unused_local_variable, use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/sgbModels/sgbdetailsmodel.dart';
import 'package:novo/utils/colors.dart';

import 'package:provider/provider.dart';
import '../../widgets/NOVO Widgets/customLoadingAni.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../widgets/NOVO Widgets/novoFooterWidget.dart';
import '../../widgets/NOVO Widgets/searchField.dart';
import '/Roating/route.dart' as route;

class SgbActiveScreen extends StatefulWidget {
  const SgbActiveScreen({super.key, required this.sgbMasterData});
  final SgbMasterDetail? sgbMasterData;

  @override
  State<SgbActiveScreen> createState() => _SgbActiveScreenState();
}

class _SgbActiveScreenState extends State<SgbActiveScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool isLoaded = true;
  String searchtext = '';
  List<SgbDetail>? sgbMasterDetailList;
  String? sgbMasterNoDataText;
  List<SgbDetail> filterdatalist = [];
  @override
  void initState() {
    super.initState();
    fetchTheInitialData();
  }

  fetchTheInitialData() async {
    getSbgMasterData();
    // Provider.of<NavigationProvider>(context, listen: false).themeModel();
    // setState(() {});
  }

  refressFunction() async {
    await fetchTheInitialData();
  }

  Future<void> getSbgMasterData() async {
    if (await isInternetConnected()) {
      if (widget.sgbMasterData != null) {
        sgbMasterDetailList = widget.sgbMasterData!.sgbDetail;
        filterdatalist = sgbMasterDetailList!;
        sgbMasterNoDataText = widget.sgbMasterData!.noDataText;
        setState(() {
          isLoaded = false;
        });
      } else {
        sgbMasterDetailList = [];
        //////////print('SgbMasterData is Null');
      }
    } else {
      noInternetConnectAlertDialog(context, () => getSbgMasterData());
    }
  }

  void searchdata(String value) {
    searchtext = value;
    if (searchtext.isEmpty) {
      filterdatalist = sgbMasterDetailList!;
    } else {
      filterdatalist = sgbMasterDetailList!
          .where((data) => data.symbol
              .toString()
              .toLowerCase()
              .contains(searchtext.toLowerCase()))
          .toList();
    }
    if (filterdatalist.isEmpty) {}
    setState(() {});
  }

  buttonVisibleFun(SgbDetail filterdataList) {
    if (filterdataList.buttonText.isNotEmpty &&
        filterdataList.buttonText != '' &&
        filterdataList.actionFlag != '' &&
        filterdataList.actionFlag.isNotEmpty) {
      return true;
    }

    return false;
  }

  disabelButtonFun(SgbDetail filterdataList) {
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

  buttonColorFunc(SgbDetail filterdataList) {
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

  onSubmit(SgbDetail sgbMasterDetails) {
    Navigator.pushNamed(context, route.sgbplaceorderscreen,
        arguments: sgbMasterDetails);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: isLoaded
          ? const Center(
              // child: CircularProgressIndicator(),
              child: LoadingProgress())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchFeild(
                    visible: widget.sgbMasterData!.masterFound == 'Y' &&
                        sgbMasterDetailList!.isNotEmpty,
                    onChange: searchdata,
                  ),
                  Expanded(
                      child: widget.sgbMasterData!.masterFound == 'N'
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
                                      widget.sgbMasterData!.noDataText,
                                      style: TextStyle(
                                        fontFamily: 'inter',
                                        color: subTitleTextColor,
                                        fontSize: titleFontSize,
                                      )),
                                ),
                                Spacer(),
                                Visibility(
                                  visible: widget.sgbMasterData!.disclaimer
                                          .isNotEmpty &&
                                      (widget.sgbMasterData!.masterFound ==
                                              'Y' ||
                                          widget.sgbMasterData!.masterFound ==
                                              'N'),
                                  child: NovoFooterWidget(
                                      disclimerText:
                                          widget.sgbMasterData!.disclaimer),
                                ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          visible: widget.sgbMasterData!
                                                  .disclaimer.isNotEmpty &&
                                              (widget.sgbMasterData!
                                                          .masterFound ==
                                                      'Y' ||
                                                  widget.sgbMasterData!
                                                          .masterFound ==
                                                      'N'),
                                          child: NovoFooterWidget(
                                              disclimerText: widget
                                                  .sgbMasterData!.disclaimer),
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
                                                                      .symbol,
                                                                  // 'dddddddddddddddddddddddddddddddddddddddddddddddd',
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
                                                                      .name,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'inter',
                                                                      color:
                                                                          subTitleTextColor,
                                                                      fontSize:
                                                                          subTitleFontSize,
                                                                      height:
                                                                          1.5),
                                                                ),
                                                              )),
                                                          // Text(
                                                          //     'Unit Price - \u20B9${filterdatalist[index].minPrice}',
                                                          //     style: TextStyle(
                                                          //       fontSize: subTitleFontSize,
                                                          //       color: themeBasedColor,
                                                          //     )),
                                                          RichText(
                                                            text: TextSpan(
                                                              text:
                                                                  'Unit Price  ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'inter',
                                                                  fontSize:
                                                                      subTitleFontSize,
                                                                  color:
                                                                      themeBasedColor),
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                    text: rsMrkFormat.format(
                                                                        filterdatalist[index]
                                                                            .unitPrice),
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
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          5),
                                                              elevation: 2,
                                                              disabledColor: Colors
                                                                  .grey,
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
                                                                      index])

                                                              //  filterdatalist[
                                                              //                 index]
                                                              //             .actionFlag ==
                                                              //         'M'
                                                              //     ? modifyButtonColor
                                                              //     : appPrimeColor,
                                                              ,
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
                                                                    .buttonText,
                                                                maxLines: 1,
                                                                // softWrap: false,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: filterdatalist[index].actionFlag ==
                                                                                'M' &&
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
                                                        text: 'Ordered Unit  ',
                                                        style: TextStyle(
                                                            fontFamily: 'inter',
                                                            fontSize:
                                                                subTitleFontSize,
                                                            color:
                                                                themeBasedColor),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: filterdatalist[
                                                                      index]
                                                                  .appliedUnit
                                                                  .toString(),
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
                                                              .dateRange,
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
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              Visibility(
                                                visible: widget
                                                        .sgbMasterData!
                                                        .disclaimer
                                                        .isNotEmpty &&
                                                    (widget.sgbMasterData!
                                                                .masterFound ==
                                                            'Y' ||
                                                        widget.sgbMasterData!
                                                                .masterFound ==
                                                            'N'),
                                                child: NovoFooterWidget(
                                                    disclimerText: widget
                                                        .sgbMasterData!
                                                        .disclaimer),
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

  @override
  bool get wantKeepAlive => true;
}
