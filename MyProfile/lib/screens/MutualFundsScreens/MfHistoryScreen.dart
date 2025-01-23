import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/utils/colors.dart';
import 'package:novo/widgets/MF%20Widgets/mfCustomAlertBox.dart';
import 'package:novo/widgets/MF%20Widgets/mfcustomListTile.dart';
import 'package:novo/widgets/MF%20Widgets/mfcustomRichText.dart';
import 'package:novo/widgets/MF%20Widgets/mfcustomSearchField.dart';
import 'package:novo/widgets/NOVO%20Widgets/custom_NodataWidget.dart';
import 'package:provider/provider.dart';

import '../../API/MFAPICall.dart';
import '../../model/mfModels/mf_transaction_data.dart';
import '../../widgets/MF Widgets/mf_Transaction_Widgets/mf_TimelineTransactionWidget.dart';
import '../../widgets/MF Widgets/mf_Transaction_Widgets/transactionDatePickerWidget.dart';
import '../../widgets/NOVO Widgets/Currently_unavailable.dart';
import '../../widgets/NOVO Widgets/customLoadingAni.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../widgets/NOVO Widgets/snackbar.dart';

class MFhistoryScreen extends StatefulWidget {
  const MFhistoryScreen({super.key});

  @override
  State<MFhistoryScreen> createState() => _MFhistoryScreenState();
}

class _MFhistoryScreenState extends State<MFhistoryScreen> {
  TextEditingController searchController = TextEditingController();
  final ScrollController _mfTransactionScontroller = ScrollController();
  MfTransactionData? mfTransactionDetails;

  String searchtext = '';
  int? selectedIndex;

  List<MfTransactionDatum> filterdatalist = [];
  bool isLoading = true;
  bool riskshow = false;
  // int rowsPerPage = 100;
  // int currentPage = 1;
  @override
  void initState() {
    super.initState();
    getTransactionDetails(context);
  }

  getTransactionDetails(context) async {
    if (await isInternetConnected()) {
      DateTime now = DateTime.now();
      DateTime previousMonth = DateTime(
        now.year,
        now.month - 1,
        now.day,
      );
      mfTransactionDetails = await fetchMfTransactionDetailsAPI(
          context: context,
          transactionDetails: {
            "fromdate": previousMonth.toString().split(' ')[0],
            "todate": now.toString().split(' ')[0],
            "rangetype": 'Y'
          });

      if (mfTransactionDetails != null) {
        filterdatalist = mfTransactionDetails!.mfTransactionData!;
      } else {
        filterdatalist = [];
      }
      isLoading = false;
      if (mounted) {
        setState(() {
          // Your state change code here
        });
      }
    } else {
      noInternetConnectAlertDialog(
          context, () => getTransactionDetails(context));
    }
  }

  void searchdata(String value) {
    searchtext = value;
    if (searchtext.isEmpty) {
      filterdatalist = mfTransactionDetails!.mfTransactionData!;
    } else {
      filterdatalist = mfTransactionDetails!.mfTransactionData!
          .where((data) =>
              data.schemeName
                  .toString()
                  .toLowerCase()
                  .contains(searchtext.toLowerCase()) ||
              data.schemeType
                  .toString()
                  .toLowerCase()
                  .contains(searchtext.toLowerCase()) ||
              data.stepperInfo
                  .toString()
                  .toLowerCase()
                  .contains(searchtext.toLowerCase()) ||
              data.amount
                  .toString()
                  .toLowerCase()
                  .contains(searchtext.toLowerCase()) ||
              data.transNo
                  .toString()
                  .toLowerCase()
                  .contains(searchtext.toLowerCase()) ||
              data.lumpsum
                  .toString()
                  .toLowerCase()
                  .contains(searchtext.toLowerCase()))
          .toList();
    }
    // currentPage = 1; // Reset current page to 1

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var darkThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;

    var darkthememode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;
    // final totalPages = (filterdatalist.length / rowsPerPage).ceil();

    // final startIndex = (currentPage - 1) * rowsPerPage;
    // final endIndex =
    //     (currentPage * rowsPerPage).clamp(0, filterdatalist.length);

    // final pageItems = rowsPerPage == -1
    //     ? filterdatalist
    //     : filterdatalist.sublist(startIndex.clamp(0, filterdatalist.length),
    //         endIndex.clamp(0, filterdatalist.length));
    return isLoading
        ? const LoadingProgress()
        : mfTransactionDetails == null
            ? Center(child: CurrentlyUnavailableWidget(
                refressFunc: () async {
                  await getTransactionDetails(context);
                },
              ))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible:
                          mfTransactionDetails!.mfTransactionData!.isNotEmpty,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: MfCustomSearchField(
                                onChange: searchdata,
                                titleText: 'Transaction Summary',
                                hintText: 'Search your Transaction',
                                searchController: searchController),
                          ),
                          InkWell(
                            onTap: () => customMfAlertBox(
                                context: context,
                                title: 'Download Transaction History',
                                contentWidget: DatePickerForm(),
                                func1: () {}),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Icon(Icons.file_download_outlined,
                                  size: 28,
                                  color: darkthememode
                                      ? Colors.blue
                                      : appPrimeColor),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: filterdatalist.isEmpty ||
                              mfTransactionDetails!.mfTransactionData!.isEmpty
                          ? noDataFoundWidget(context)
                          : RefreshIndicator(
                              onRefresh: () async {
                                await getTransactionDetails(context);
                              },
                              child: Scrollbar(
                                controller: _mfTransactionScontroller,
                                child: ListView.separated(
                                  controller: _mfTransactionScontroller,
                                  // itemCount: pageItems.length + 1,
                                  itemCount: filterdatalist.length,
                                  itemBuilder: (context, index) {
                                    // if (index < pageItems.length) {
                                    MfTransactionDatum mfTransactionDatum =
                                        filterdatalist[index];

                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = index;
                                        });
                                        mfTransactionBottomSheet(
                                          context: context,
                                          mfTransactionDatum:
                                              mfTransactionDatum,
                                        ).then((value) => {
                                              if (mounted)
                                                {
                                                  setState(() {
                                                    selectedIndex = -1;
                                                  })
                                                }
                                            });
                                      },
                                      child: MFCustomListTile(
                                        imageUrl: mfTransactionDatum.theme!,
                                        title: mfTransactionDatum.schemeName!,
                                        selectedColor: selectedIndex == index
                                            ? appPrimeColor
                                            : darkThemeMode
                                                ? const Color.fromARGB(
                                                    255, 54, 54, 54)
                                                : const Color.fromRGBO(
                                                    248, 248, 247, 1),
                                        subtitl1: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1,
                                                      color: subTitleTextColor
                                                          .withOpacity(0.2)),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Text(
                                                  '${mfTransactionDatum.schemeType}',
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11.5)),
                                            ),
                                            Visibility(
                                              visible:
                                                  mfTransactionDatum.nfo == 'Y',
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                    color: primaryGreenColor,
                                                    // border: Border.all(
                                                    //     width: 1,
                                                    //     color:
                                                    //         subTitleTextColor
                                                    //             .withOpacity(
                                                    //                 0.2)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Text('NFO',
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            color:
                                                                titleTextColorDark,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 10)),
                                              ),
                                            ),
                                            RichTextWidget(
                                              firstWidget: mfTransactionDatum
                                                          .pledgeable !=
                                                      "Y"
                                                  ? const SizedBox()
                                                  : InkWell(
                                                      onTap: () => customMfAlertBox(
                                                          context: context,
                                                          title:
                                                              'Pledgeable Info',
                                                          contentWidget: Text(
                                                              Provider.of<NavigationProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .pledgeableInfo),
                                                          func1: () {}),
                                                      child: RichTextWidget(
                                                        alignRight:
                                                            MainAxisAlignment
                                                                .start,
                                                        firstWidget: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 3,
                                                                  left: 0),
                                                          child: Image.asset(
                                                            'assets/pledgedicon.png',
                                                            height: 17,
                                                            width: 17,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        ),
                                        subtitle2: RichTextWidget(
                                          secondWidget: Text(
                                              mfTransactionDatum.buySell == "R"
                                                  ? ' Unit(s)'
                                                  : '',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(fontSize: 11)),
                                          firstWidget: Text(
                                            mfTransactionDatum.buySell == "R"
                                                ? "${mfTransactionDatum.qty}"
                                                : rsFormat.format(
                                                    mfTransactionDatum.amount),
                                            // '₹${doubleformatAmount(mfTransactionDatum.amount ?? 0)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width >
                                                              360
                                                          ? 17
                                                          : 14,
                                                ),
                                          ),
                                        ),
                                        subtitle3: Wrap(
                                          direction: Axis.horizontal,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.start,
                                          alignment: WrapAlignment.start,
                                          children: [
                                            Visibility(
                                              visible: mfTransactionDatum
                                                  .lumpsum!.isNotEmpty,
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    right: 10, top: 5),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? modifyButtonColor
                                                            .withOpacity(0.2)
                                                        : modifyButtonColor
                                                            .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Text(
                                                    mfTransactionDatum.lumpsum!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11)),
                                              ),
                                            ),
                                            Visibility(
                                              visible: mfTransactionDatum
                                                  .transNo!.isNotEmpty,
                                              child: InkWell(
                                                onTap: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text:
                                                              mfTransactionDatum
                                                                  .transNo!));
                                                  appExit(
                                                      context, 'Text copied');
                                                },
                                                child: FittedBox(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10, top: 5),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? modifyButtonColor
                                                                .withOpacity(
                                                                    0.2)
                                                            : modifyButtonColor
                                                                .withOpacity(
                                                                    0.5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Ref : ',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  fontSize: 11,
                                                                )),
                                                        Text(
                                                            mfTransactionDatum
                                                                .transNo!,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                )),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        const Icon(
                                                          Icons.copy_rounded,
                                                          size: 13,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    right: 5, top: 5),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: mfTransactionDatum
                                                                .maxOrderColor ==
                                                            "S"
                                                        ? darkthememode
                                                            ? primaryGreenColor
                                                                .withOpacity(
                                                                    0.3)
                                                            : primaryGreenColor
                                                                .withOpacity(
                                                                    0.1)
                                                        : mfTransactionDatum
                                                                    .maxOrderColor ==
                                                                "F"
                                                            ? darkthememode
                                                                ? primaryRedColor
                                                                    .withOpacity(
                                                                        0.3)
                                                                : primaryRedColor
                                                                    .withOpacity(
                                                                        0.1)
                                                            : mfTransactionDatum
                                                                        .maxOrderColor ==
                                                                    "CL"
                                                                ? darkthememode
                                                                    ? primaryOrangeColor
                                                                        .withOpacity(
                                                                            0.3)
                                                                    : primaryOrangeColor
                                                                        .withOpacity(
                                                                            0.1)
                                                                : darkthememode
                                                                    ? inactiveColor.withOpacity(0.7)
                                                                    : subTitleTextColor.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(5)),
                                                child: Text(
                                                  mfTransactionDatum
                                                      .stepperInfo!,
                                                  textAlign: TextAlign.center,
                                                  style: ThemeClass.lighttheme
                                                      .textTheme.bodySmall!
                                                      .copyWith(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: mfTransactionDatum
                                                                      .maxOrderColor ==
                                                                  "S"
                                                              ? primaryGreenColor
                                                              : mfTransactionDatum
                                                                          .maxOrderColor ==
                                                                      "F"
                                                                  ? primaryRedColor
                                                                  : mfTransactionDatum
                                                                              .maxOrderColor ==
                                                                          "CL"
                                                                      ? primaryOrangeColor
                                                                      : titleTextColorLight),
                                                )),
                                          ],
                                        ),
                                      ),
                                    );
                                    // } else {
                                    //   return totalPages > 0 && totalPages < 2
                                    //       ? const SizedBox()
                                    //       : Container(
                                    //           padding: const EdgeInsets.only(
                                    //               bottom: 20),
                                    //           child: Row(
                                    //             mainAxisAlignment:
                                    //                 MainAxisAlignment.center,
                                    //             children: [
                                    //               Container(
                                    //                 decoration: BoxDecoration(
                                    //                     color: appPrimeColor,
                                    //                     border: Border.all(
                                    //                         color:
                                    //                             titleTextColorDark),
                                    //                     borderRadius:
                                    //                         const BorderRadius
                                    //                             .only(
                                    //                             topLeft: Radius
                                    //                                 .circular(
                                    //                                     8),
                                    //                             bottomLeft: Radius
                                    //                                 .circular(
                                    //                                     8))),
                                    //                 width: 35,
                                    //                 height: 35,
                                    //                 child: InkWell(
                                    //                   onTap: () {
                                    //                     setState(() {
                                    //                       if (currentPage > 1) {
                                    //                         if (_mfTransactionScontroller
                                    //                             .hasClients) {
                                    //                           _mfTransactionScontroller
                                    //                               .animateTo(
                                    //                             0.0,
                                    //                             duration:
                                    //                                 const Duration(
                                    //                                     milliseconds:
                                    //                                         300),
                                    //                             curve: Curves
                                    //                                 .easeOut,
                                    //                           );
                                    //                           currentPage--;
                                    //                         }
                                    //                       }
                                    //                       // currentPage > 1 ? currentPage-- : null;
                                    //                     });
                                    //                   },
                                    //                   child: Icon(
                                    //                     Icons
                                    //                         .arrow_back_ios_new_outlined,
                                    //                     size: 14,
                                    //                     color:
                                    //                         titleTextColorDark,
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //               Container(
                                    //                 alignment: Alignment.center,
                                    //                 decoration: BoxDecoration(
                                    //                   color: appPrimeColor,
                                    //                   border: Border.symmetric(
                                    //                       horizontal: BorderSide(
                                    //                           color:
                                    //                               titleTextColorDark)),
                                    //                 ),
                                    //                 width: 100,
                                    //                 height: 35,
                                    //                 child: Text(
                                    //                   '$currentPage - $totalPages of $rowsPerPage',
                                    //                   style: Theme.of(context)
                                    //                       .textTheme
                                    //                       .bodySmall!
                                    //                       .copyWith(
                                    //                           color:
                                    //                               titleTextColorDark),
                                    //                 ),
                                    //               ),
                                    //               Container(
                                    //                 width: 35,
                                    //                 height: 35,
                                    //                 decoration: BoxDecoration(
                                    //                     color: appPrimeColor,
                                    //                     border: Border.all(
                                    //                         color:
                                    //                             titleTextColorDark),
                                    //                     borderRadius:
                                    //                         const BorderRadius
                                    //                             .only(
                                    //                             topRight: Radius
                                    //                                 .circular(
                                    //                                     8),
                                    //                             bottomRight: Radius
                                    //                                 .circular(
                                    //                                     8))),
                                    //                 child: InkWell(
                                    //                   onTap: () {
                                    //                     setState(() {
                                    //                       if (currentPage <
                                    //                           totalPages) {
                                    //                         if (_mfTransactionScontroller
                                    //                             .hasClients) {
                                    //                           _mfTransactionScontroller
                                    //                               .animateTo(
                                    //                             0.0,
                                    //                             duration:
                                    //                                 const Duration(
                                    //                                     milliseconds:
                                    //                                         300),
                                    //                             curve: Curves
                                    //                                 .easeOut,
                                    //                           );
                                    //                           currentPage++;
                                    //                         }
                                    //                       }
                                    //                     });
                                    //                   },
                                    //                   child: Icon(
                                    //                     Icons
                                    //                         .arrow_forward_ios_rounded,
                                    //                     size: 14,
                                    //                     color:
                                    //                         titleTextColorDark,
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         );
                                    // }
                                  },
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(
                                    height: 3,
                                  ),
                                ),
                              ),
                            ),
                    )
                  ],
                ),
              );
  }
}
