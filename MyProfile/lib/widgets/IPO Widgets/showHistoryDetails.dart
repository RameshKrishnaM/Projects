// ignore_for_file: must_be_immutable, file_names, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:novo/Provider/provider.dart';
import 'package:novo/model/ipoModels/ipoHistoryDetails.dart';
import 'package:novo/utils/colors.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../NOVO Widgets/validationformat.dart';

class ShowHistoryDetail extends StatefulWidget {
  // int masterid;
  // String appNo;
  HistoryDetail ipoHistoryDetailsData;
  bool isHistorypage;
  ShowHistoryDetail(
      {super.key,
      required this.ipoHistoryDetailsData,
      // required this.masterid,
      // required this.appNo,
      required this.isHistorypage});

  @override
  State<ShowHistoryDetail> createState() => _ShowHistoryDetailState();
}

class _ShowHistoryDetailState extends State<ShowHistoryDetail> {
  @override
  void initState() {
    super.initState();
    getApplicationHistoryRecordInAPI();
  }

  // IpoHistoryDetails? getHistoryrecord;
  bool isLoaded = true;
  // List<HistoryDetail>? biddetail = [];
  // List<HistoryDetail>? ipoHistoryDetailList;
  List<AppliedBid>? biddetail;
  Future<void> getApplicationHistoryRecordInAPI() async {
    if (await isInternetConnected()) {
      if (widget.ipoHistoryDetailsData != null) {
        biddetail = widget
            .ipoHistoryDetailsData.categoryList!.appliedDetail!.appliedBids;

        setState(() {
          isLoaded = false;
        });
      } else {
        // ipoHistoryDetailList = [];
        //////////print('ipoMasterData is Null');
      }
    } else {
      noInternetConnectAlertDialog(
          context, () => getApplicationHistoryRecordInAPI());
    }
  }

  String formatNumber(int number) {
    if (number < 100000) {
      return number.toString(); // Return as is if less than 1 lakh
    } else if (number >= 100000 && number < 10000000) {
      double lakhs = number / 100000;
      return '${lakhs.toStringAsFixed(2)} Lakhs';
    } else {
      double crores = number / 10000000;
      return '${crores.toStringAsFixed(2)} Crores';
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? Center(
            child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: CircularProgressIndicator(
              color: titleTextColorLight,
              backgroundColor: titleTextColorDark,
            ),
          ))
        : Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                      visible: widget.isHistorypage == false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Align(
                          //   alignment: Alignment.topRight,
                          //   child: InkWell(
                          //       onTap: () => Navigator.pop(context),
                          //       child: Icon(CupertinoIcons.multiply)),
                          // ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.ipoHistoryDetailsData.symbol ?? "",
                                style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                    height: 1),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Visibility(
                                visible: widget.ipoHistoryDetailsData.sme!,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 3.0,
                                      bottom: 3.0,
                                      left: 7.0,
                                      right: 7.0),
                                  decoration: const BoxDecoration(
                                      color: Color.fromRGBO(227, 242, 253, 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0))),
                                  child: Center(
                                      child: Text('SME',
                                          style: TextStyle(
                                              color: appPrimeColor,
                                              fontSize: 8.0,
                                              fontFamily: 'inter',
                                              fontWeight: FontWeight.w600))),
                                ),
                              )
                            ],
                          ),
                          Text(
                            widget.ipoHistoryDetailsData.name ?? "",
                            style: TextStyle(
                                fontSize: subTitleFontSize,
                                color: subTitleTextColor,
                                fontFamily: 'Inter',
                                height: 1.5),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                        ],
                      )),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                        color: Provider.of<NavigationProvider>(context)
                                    .themeMode ==
                                ThemeMode.dark
                            ? const Color.fromRGBO(227, 242, 253, 1)
                            : const Color.fromRGBO(227, 242, 253, 1),
                        border: Border.all(
                            color: Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? Colors.white10 // Light mode
                                : const Color.fromRGBO(235, 237, 236, 1)),
                        // boxShadow: Provider.of<NavigationProvider>(context)
                        //             .themeMode ==
                        //         ThemeMode.dark
                        //     ? null
                        //     : [
                        //         BoxShadow(
                        //           color:
                        //               const Color.fromARGB(255, 230, 228, 228)
                        //                   .withOpacity(0.5),
                        //           offset: const Offset(0,
                        //               1.0), // Offset (x, y) controls the shadow's position
                        //           blurRadius: 15, // Spread of the shadow
                        //           spreadRadius:
                        //               5.0, // Positive values expand the shadow, negative values shrink it
                        //         ),
                        //       ],
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'UPI ID',
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: subTitleTextColor),
                                  ),
                                  Text(
                                    widget.ipoHistoryDetailsData.categoryList!
                                            .appliedDetail!.appliedUpi ??
                                        "",
                                    // Disable text wrapping

                                    overflow: TextOverflow
                                        .ellipsis, // Specify overflow behavior
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: subTitleFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColorLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${widget.ipoHistoryDetailsData.categoryList!.discountText ?? ""} ',
                                  style: TextStyle(
                                      fontSize: 12.0, color: subTitleTextColor),
                                ),
                                Text(
                                  '${widget.ipoHistoryDetailsData.categoryList!.discountPrice ?? ""} ',
                                  // Disable text wrapping

                                  overflow: TextOverflow
                                      .ellipsis, // Specify overflow behavior
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: subTitleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: titleTextColorLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Category',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: subTitleTextColor)),
                                  Text(
                                      widget.ipoHistoryDetailsData.categoryList!
                                              .code ??
                                          "",
                                      style: TextStyle(
                                        fontSize: subTitleFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: titleTextColorLight,
                                      )),
                                ],
                              ),
                            ),
                            // const SizedBox(
                            //   width: 10.0,
                            // ),
                            Expanded(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Amt. Payable',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: subTitleTextColor)),
                                    FittedBox(
                                      child: Text(
                                          indRupeesFormat.format(widget
                                              .ipoHistoryDetailsData
                                              .categoryList!
                                              .appliedDetail!
                                              .appliedAmount),
                                          // '${getHistoryrecord?.total ?? ""}',
                                          style: TextStyle(
                                            fontSize: subTitleFontSize,
                                            fontWeight: FontWeight.bold,
                                            color: titleTextColorLight,
                                          )),
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                        // const SizedBox(
                        //   height: 10.0,
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   padding: const EdgeInsets.all(15.0),
                  //   decoration: BoxDecoration(
                  //       color: infoColor,
                  //       border: Border.all(
                  //           color: Provider.of<NavigationProvider>(context)
                  //                       .themeMode ==
                  //                   ThemeMode.dark
                  //               ? Colors.white10 // Light mode
                  //               : const Color.fromRGBO(235, 237, 236, 1)),
                  //       boxShadow: Provider.of<NavigationProvider>(context)
                  //                   .themeMode ==
                  //               ThemeMode.dark
                  //           ? null
                  //           : [
                  //               BoxShadow(
                  //                 color: const Color.fromARGB(
                  //                         255, 230, 228, 228)
                  //                     .withOpacity(0.5),
                  //                 offset: const Offset(0,
                  //                     1.0), // Offset (x, y) controls the shadow's position
                  //                 blurRadius: 15, // Spread of the shadow
                  //                 spreadRadius:
                  //                     5.0, // Positive values expand the shadow, negative values shrink it
                  //               ),
                  //             ],
                  //       borderRadius: BorderRadius.circular(8.0)),
                  //   child: Column(
                  //     children: [
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Expanded(
                  //             child: Column(
                  //               mainAxisAlignment: MainAxisAlignment.start,
                  //               crossAxisAlignment:
                  //                   CrossAxisAlignment.start,
                  //               children: [
                  //                 Text('Depository Status',
                  //                     style: TextStyle(
                  //                         fontSize: 12.0,
                  //                         color: subTitleTextColor)),
                  //                 Text(getHistoryrecord?.dpStatus ?? "",
                  //                     style: TextStyle(
                  //                       fontSize: subTitleFontSize,
                  //                       fontWeight: FontWeight.bold,
                  //                       color: titleTextColorLight,
                  //                     )),
                  //               ],
                  //             ),
                  //           ),
                  //           // const SizedBox(
                  //           //   width: 10.0,
                  //           // ),
                  //           Expanded(
                  //             child: Column(
                  //                 mainAxisAlignment:
                  //                     MainAxisAlignment.start,
                  //                 crossAxisAlignment:
                  //                     CrossAxisAlignment.end,
                  //                 children: [
                  //                   Text('Upi Status',
                  //                       style: TextStyle(
                  //                           fontSize: 12.0,
                  //                           color: subTitleTextColor)),
                  //                   FittedBox(
                  //                     child: Text(
                  //                         '${getHistoryrecord?.upiStatus ?? ""}',
                  //                         style: TextStyle(
                  //                           fontSize: subTitleFontSize,
                  //                           fontWeight: FontWeight.bold,
                  //                           color: titleTextColorLight,
                  //                         )),
                  //                   ),
                  //                 ]),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 15.0,
                  // ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                        color: Provider.of<NavigationProvider>(context)
                                    .themeMode ==
                                ThemeMode.dark
                            ? const Color.fromRGBO(227, 242, 253, 1)
                            : const Color.fromRGBO(227, 242, 253, 1),
                        border: Border.all(
                            color: Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? Colors.white10 // Light mode
                                : const Color.fromRGBO(235, 237, 236, 1)),
                        // boxShadow: Provider.of<NavigationProvider>(context)
                        //             .themeMode ==
                        //         ThemeMode.dark
                        //     ? null
                        //     : [
                        //         BoxShadow(
                        //           color:
                        //               const Color.fromARGB(255, 230, 228, 228)
                        //                   .withOpacity(0.5),
                        //           offset: const Offset(0,
                        //               1.0), // Offset (x, y) controls the shadow's position
                        //           blurRadius: 15, // Spread of the shadow
                        //           spreadRadius:
                        //               5.0, // Positive values expand the shadow, negative values shrink it
                        //         ),
                        //       ],
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Issue Date',
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: subTitleTextColor),
                                  ),
                                  Text(
                                    '${widget.ipoHistoryDetailsData.orderDate} ',
                                    // Disable text wrapping

                                    overflow: TextOverflow
                                        .ellipsis, // Specify overflow behavior
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: subTitleFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColorLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Issue size',
                                  style: TextStyle(
                                      fontSize: 12.0, color: subTitleTextColor),
                                ),
                                Text(
                                  widget
                                      .ipoHistoryDetailsData.issueSizeWithText!,
                                  // formatNumber(
                                  //     widget.ipoHistoryDetailsData.issueSizeWithText),
                                  // Disable text wrapping

                                  overflow: TextOverflow
                                      .ellipsis, // Specify overflow behavior
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: subTitleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: titleTextColorLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('issue price',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: subTitleTextColor)),
                                  Text(
                                      widget.ipoHistoryDetailsData
                                          .issueSizeWithText!,
                                      style: TextStyle(
                                        fontSize: subTitleFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: titleTextColorLight,
                                      )),
                                ],
                              ),
                            ),
                            // const SizedBox(
                            //   width: 10.0,
                            // ),
                            Expanded(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Lot size',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: subTitleTextColor)),
                                    FittedBox(
                                      child: Text(
                                          '${widget.ipoHistoryDetailsData.lotSize}',
                                          style: TextStyle(
                                            fontSize: subTitleFontSize,
                                            fontWeight: FontWeight.bold,
                                            color: titleTextColorLight,
                                          )),
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  ...biddetail!
                      .map((biddata) => Container(
                            padding: const EdgeInsets.all(15.0),
                            margin: biddetail!.indexOf(biddata) !=
                                    biddetail!.length - 1
                                ? const EdgeInsets.only(bottom: 15.0)
                                : null,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        const Color.fromARGB(94, 151, 136, 136),
                                    width: 0.7 // Light mode

                                    ),
                                borderRadius: BorderRadius.circular(7.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No.of Lot',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: subTitleTextColor),
                                    ),
                                    Text(
                                      '${biddata.quantity}',
                                      style: TextStyle(
                                        fontSize: subTitleFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Provider.of<NavigationProvider>(
                                                        context)
                                                    .themeMode ==
                                                ThemeMode.dark
                                            ? titleTextColorDark
                                            : titleTextColorLight,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Cutoff-Price',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: subTitleTextColor)),
                                    const SizedBox(
                                      height: 5.0,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 1.0,
                                          bottom: 1.0,
                                          left: 5.0,
                                          right: 5.0),
                                      decoration: BoxDecoration(
                                          color: biddata.cutOff == true
                                              ? primaryGreenColor
                                              : primaryOrangeColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5.0))),
                                      child: Center(
                                          child: biddata.cutOff == true
                                              ? const Text(
                                                  'Yes',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              : const Text(
                                                  'No',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(' Price',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: subTitleTextColor)),
                                    Text('${biddata.price}',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: subTitleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Provider.of<NavigationProvider>(
                                                              context)
                                                          .themeMode ==
                                                      ThemeMode.dark
                                                  ? titleTextColorDark
                                                  : titleTextColorLight,
                                        )),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    biddata.activityType == 'new' ||
                                            biddata.activityType == 'modify'
                                        ? Text('Placed Bid',
                                            style: TextStyle(
                                                fontSize: subTitleFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: primaryGreenColor))
                                        : Text('Bid Deleted',
                                            style: TextStyle(
                                                fontSize: subTitleFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: primaryRedColor))
                                  ],
                                )
                              ],
                            ),
                          ))
                      .toList(),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Visibility(
                    visible: widget.ipoHistoryDetailsData.errReason!.isNotEmpty,
                    child: Center(
                      child: Text(
                        widget.ipoHistoryDetailsData.errReason!,
                        style: TextStyle(
                            color: widget.ipoHistoryDetailsData.errReason!
                                        .toUpperCase()
                                        .contains('ACCEPTED') ||
                                    widget.ipoHistoryDetailsData.errReason!
                                        .toUpperCase()
                                        .contains('MODIFIED')
                                ? primaryGreenColor
                                : primaryRedColor,
                            fontSize: titleFontSize - 2,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  if (widget.ipoHistoryDetailsData.registarLink!.isNotEmpty &&
                      widget.ipoHistoryDetailsData.registarLink != 'NA') ...[
                    Visibility(
                      visible: widget.isHistorypage == true,
                      child: GestureDetector(
                          onTap: () async {
                            final Uri url = Uri.parse(
                                widget.ipoHistoryDetailsData.registarLink!
                                // 'https://play.google.com/store/apps/details?id=com.noren.ftconline&hl=en&gl=US',
                                // "http://play.google.com/store/apps/details?id=com.novo.novoapp&hl=en&gl=US"
                                );
                            // Check if the device can launch the URL
                            if (await canLaunchUrl(url)) {
                              // Launch the URL
                              await launchUrl(url);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.info,
                                size: 12,
                                color: Colors.blue.shade400,
                              ),
                              SizedBox(
                                width: 3.0,
                              ),
                              Text('Check Your Allotment',
                                  style: TextStyle(
                                      color: Colors.blue.shade400,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          )),
                    ),
                  ],
                  Visibility(
                      visible: widget.isHistorypage == false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.info,
                            size: 12,
                            color: Colors.blue.shade400,
                          ),
                          SizedBox(
                            width: 3.0,
                          ),
                          Text(
                            'IPO can be modified only between 10 AM to 5 PM',
                            style: TextStyle(
                                color: Colors.blue.shade400,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          );
  }
}
