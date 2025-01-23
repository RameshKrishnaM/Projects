import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/mfModels/mfpurchaseConfigDetails.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/utils/colors.dart';
import 'package:novo/widgets/MF%20Widgets/mfCustomAlertBox.dart';
import 'package:novo/widgets/MF%20Widgets/mfcustomListTile.dart';
import 'package:novo/widgets/MF%20Widgets/mfcustomRichText.dart';
import 'package:novo/widgets/MF%20Widgets/mfcustomSearchField.dart';
import 'package:provider/provider.dart';
import '../../API/MFAPICall.dart';
import '../../model/mfModels/mf_holding_data.dart';
import '../../model/mfModels/mf_pieChart_Model.dart';
import '../../widgets/MF Widgets/mf_Portfolio_Widgets/assetoverviewChart.dart';
import '../../widgets/MF Widgets/mf_Portfolio_Widgets/suggestordertypeBS.dart';
import '../../widgets/NOVO Widgets/Currently_unavailable.dart';
import '../../widgets/NOVO Widgets/customLoadingAni.dart';
import '../../widgets/NOVO Widgets/custom_NodataWidget.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../widgets/NOVO Widgets/validationformat.dart';

class MFportfolioScreen extends StatefulWidget {
  const MFportfolioScreen({super.key});

  @override
  State<MFportfolioScreen> createState() => _MFportfolioScreenState();
}

class _MFportfolioScreenState extends State<MFportfolioScreen> {
  bool isLoading = true;
  bool riskshow = false;
  TextEditingController searchController = TextEditingController();
  final ScrollController _mfportfolioSController = ScrollController();
  MFpurchaseConfigDetails? mfPurchaseConfigDetails;
  MfHoldingData? mfHoldingData;
  MFpieChartDetails? mFpieChartDetails;
  String searchtext = '';
  List<Holdingsarr> filterdatalist = [];
  // int rowsPerPage = 100;
  // int currentPage = 1;

  @override
  void initState() {
    getHoldingData(context);
    // getPieChartData();
    super.initState();
  }

  // getMfPurchaseConfigDetailsAPI(String isin) async {
  //   mfPurchaseConfigDetails =
  //       await fetchMFPurchaseConfigDetails(context, isin, "P");
  // }

  getHoldingData(context) async {
    if (await isInternetConnected()) {
      mfHoldingData = await fetchMfHoldingDetailsAPI(context);
      await getPieChartData();
      if (mfHoldingData != null) {
        filterdatalist = mfHoldingData!.holdingsarr!;
      } else {
        filterdatalist = [];
      }
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    } else {
      noInternetConnectAlertDialog(context, () => getHoldingData(context));
    }
  }

  double? assetValue;

  getPieChartData() async {
    mFpieChartDetails = await fetchMfPieChartData(context);
    if (mFpieChartDetails != null) {
      assetValue = mFpieChartDetails?.mfschemetotal ?? 0.0;
    } else {
      assetValue = 0.0;
    }
  }

  void searchdata(String value) {
    searchtext = value;
    if (searchtext.isEmpty) {
      filterdatalist = mfHoldingData!.holdingsarr!;
    } else {
      filterdatalist = mfHoldingData!.holdingsarr!
          .where((data) =>
              data.schemename
                  .toString()
                  .toLowerCase()
                  .contains(searchtext.toLowerCase()) ||
              data.schemeType
                  .toString()
                  .toLowerCase()
                  .contains(searchtext.toLowerCase()))
          .toList();
    }
    if (filterdatalist.isEmpty) {}
    // currentPage = 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var darkThemeMode =
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
        : mfHoldingData == null
            ? Center(child: CurrentlyUnavailableWidget(
                refressFunc: () async {
                  await getHoldingData(context);
                },
              ))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // PortfolioChart(),
                    Visibility(
                      visible: assetValue! > 0 &&
                          mfHoldingData!.holdingsarr!.isNotEmpty,
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                    Visibility(
                      visible: assetValue! > 0 &&
                          mfHoldingData!.holdingsarr!.isNotEmpty,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '₹ ${doubleformatAmount(assetValue ?? 0)}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                'Current Asset Value',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () => showAssetOverviewDailog(
                                context, mFpieChartDetails!),
                            child: Image.asset(
                              'assets/graph.png',
                              width: 30,
                              height: 30,
                            ),
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: mfHoldingData!.holdingsarr!.isNotEmpty,
                      child: MfCustomSearchField(
                          onChange: searchdata,
                          titleText: 'Your Investments',
                          hintText: 'Search your Investments',
                          searchController: searchController),
                    ),

                    Expanded(
                      child: filterdatalist.isEmpty ||
                              mfHoldingData!.holdingsarr!.isEmpty
                          ? noDataFoundWidget(context)
                          : RefreshIndicator(
                              onRefresh: () async {
                                await getHoldingData(context);
                              },
                              child: Scrollbar(
                                controller: _mfportfolioSController,
                                child: ListView.separated(
                                  controller: _mfportfolioSController,
                                  // itemCount: pageItems.length + 1,
                                  itemCount: filterdatalist.length,
                                  itemBuilder: (context, index) {
                                    // if (index < pageItems.length) {
                                    var jsonData = filterdatalist[index];
                                    return InkWell(
                                      onTap: () async {
                                        showSugestionBottomSheet(
                                            newContext: context,
                                            isin: jsonData.isin ?? "",
                                            amount: jsonData.currentvalue);
                                      },
                                      child: MFCustomListTile(
                                        imageUrl: jsonData.lightUrl ?? "",
                                        title: jsonData.schemename ?? "",
                                        subtitl1: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  right: 8),
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
                                              child: Text(jsonData.schemeType!,
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11.5)),
                                            ),
                                            RichTextWidget(
                                              firstWidget: jsonData
                                                          .pledgeable !=
                                                      "Y"
                                                  ? const SizedBox()
                                                  : InkWell(
                                                      onTap: () => customMfAlertBox(
                                                          context: context,
                                                          title:
                                                              'Pledgeable Info',
                                                          contentWidget: Text(
                                                              mfHoldingData!
                                                                      .pledgeableInfo ??
                                                                  ""),
                                                          func1: () {}),
                                                      child: RichTextWidget(
                                                        alignRight:
                                                            MainAxisAlignment
                                                                .center,
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
                                        subtitle2: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text('₹ ${jsonData.currentvalue!}',
                                                // doubleformatAmount(
                                                //     jsonData.currentvalue!),
                                                // rsFormat.format(
                                                //     jsonData.currentvalue),
                                                style: darkThemeMode
                                                    ? ThemeClass.Darktheme
                                                        .textTheme.bodyLarge!
                                                        .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17,
                                                      )
                                                    : ThemeClass.lighttheme
                                                        .textTheme.bodyLarge!
                                                        .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17,
                                                      )),
                                            RichTextWidget(
                                              firstWidget: Text(
                                                  '${jsonData.curBalQty}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        fontSize: 10,
                                                      )),
                                              secondWidget: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 0),
                                                child: Text(' Units',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontSize: 10)),
                                              ),
                                            ),
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
                                    //                 // color: Colors.red,
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
                                    //                         if (_mfportfolioSController
                                    //                             .hasClients) {
                                    //                           _mfportfolioSController
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
                                    //                         if (_mfportfolioSController
                                    //                             .hasClients) {
                                    //                           _mfportfolioSController
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
