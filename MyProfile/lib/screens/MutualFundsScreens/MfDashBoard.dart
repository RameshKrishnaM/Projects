// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/utils/colors.dart';
import 'package:novo/widgets/MF%20Widgets/mfCustomAlertBox.dart';
import 'package:novo/widgets/MF%20Widgets/mfcustomListTile.dart';
import 'package:novo/widgets/MF%20Widgets/Mf_Bottom_Sheet_Widgets/mfcustomPaymentBS.dart';
import 'package:novo/widgets/MF%20Widgets/mfcustomRichText.dart';
import 'package:provider/provider.dart';
import '../../Provider/change_index.dart';
import '../../widgets/NOVO Widgets/custom_NodataWidget.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';

class MFdashBoardScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final String? schemeDisclaimer;
  final String? mfNFOM1;
  final String? mfNFOM2;
  const MFdashBoardScreen(
      {super.key,
      this.scrollController,
      this.schemeDisclaimer,
      this.mfNFOM1,
      this.mfNFOM2});

  @override
  State<MFdashBoardScreen> createState() => _MFdashBoardScreenState();
}

class _MFdashBoardScreenState extends State<MFdashBoardScreen> {
  bool riskshow = false;
  // int rowsPerPage = 100;
  // int currentPage = 1;
  @override
  void initState() {
    super.initState();
    // showRiskDiscloser();
    getSchemeMasterData(context);
  }

  // String showRisk = 'N';
  // String riskDiscription = '';
  // showRiskDiscloser() async {
  //   var response = await fetchMfDisclimarPop(context);
  //   showRisk = response['disclaimerstatus'];

  //   if (showRisk == 'N') {
  //     riskDiscription = response['disclaimermsg'];
  //     showmfRiskDialog(
  //         context: context,
  //         title: 'Risk Disclosure',
  //         discription: riskDiscription,
  //         func: () async {
  //           Map<String, dynamic> reqData = {"disclaimerflag": "Y"};
  //           var response = await fetchMfDisclimarFlag(context, reqData);
  //           if (response['status'] == 'S') {
  //             Navigator.pop(context);
  //           }
  //         });
  //   }
  // }

  getSchemeMasterData(context) async {
    if (await isInternetConnected()) {
      await Provider.of<NavigationProvider>(context, listen: false)
          .getmfmasterschemeApi(context);
    } else {
      noInternetConnectAlertDialog(context, () => getSchemeMasterData(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    NavigationProvider navigationProvider =
        Provider.of<NavigationProvider>(context);
    var darkThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;

    // final totalPages =
    //     (navigationProvider.mfSchemeMasterFilterArr.length / rowsPerPage)
    //         .ceil();

    // final startIndex = (currentPage - 1) * rowsPerPage;
    // final endIndex = (currentPage * rowsPerPage)
    //     .clamp(0, navigationProvider.mfSchemeMasterFilterArr.length);

    // final pageItems = rowsPerPage == -1
    //     ? navigationProvider.mfSchemeMasterFilterArr
    //     : navigationProvider.mfSchemeMasterFilterArr.sublist(
    //         startIndex.clamp(
    //             0, navigationProvider.mfSchemeMasterFilterArr.length),
    //         endIndex.clamp(
    //             0, navigationProvider.mfSchemeMasterFilterArr.length));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                child: Text('Explore',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              // InkWell(
              //   onTap: () => Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => MfCustomCalculator(),
              //       )),
              //   child: Icon(
              //     Icons.calculate_outlined,
              //     color: appPrimeColor,
              //   ),
              // )
            ],
          ),
          Expanded(
            child: navigationProvider.mfSchemeMasterFilterArr.isEmpty
                ? noDataFoundWidget(context)
                : RefreshIndicator(
                    onRefresh: () async {
                      // await Provider.of<NavigationProvider>(context,
                      //         listen: false)
                      //     .getmfmasterschemeApi(context);
                    },
                    child: Scrollbar(
                      // thumbVisibility: true,
                      // trackVisibility: true,
                      interactive: true,
                      controller: widget.scrollController,
                      child: ListView.separated(
                        controller: widget.scrollController,
                        // itemCount:
                        //     navigationProvider.mfSchemeMasterFilterArr.length +
                        //         1,
                        itemCount:
                            navigationProvider.mfSchemeMasterFilterArr.length,
                        itemBuilder: (context, index) {
                          // if (index <
                          //     navigationProvider
                          //         .mfSchemeMasterFilterArr.length) {
                          var jsonData =
                              navigationProvider.mfSchemeMasterFilterArr[index];
                          // print(jsonData);
                          // print("jsonData.isin${jsonData.isin}");
                          // print(
                          //     "jsonData.navValue${jsonData.navValue.runtimeType}");
                          // print("jsonData.navValue${jsonData.navValue}");
                          return MFCustomListTile(
                            imageUrl: jsonData.icon!,
                            title: jsonData.schemeName!,
                            subtitl1: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: subTitleTextColor
                                              .withOpacity(0.2)),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(jsonData.schemeType!,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11.5)),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    RichTextWidget(
                                      firstWidget: jsonData.pledgeable != "Y"
                                          ? const SizedBox()
                                          : InkWell(
                                              onTap: () => customMfAlertBox(
                                                  context: context,
                                                  title: 'Pledge Info',
                                                  contentWidget: Text(Provider
                                                          .of<NavigationProvider>(
                                                              context,
                                                              listen: false)
                                                      .pledgeableInfo),
                                                  func1: () {}),
                                              child: RichTextWidget(
                                                alignRight:
                                                    MainAxisAlignment.start,
                                                firstWidget: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 9, left: 0),
                                                  child: Image.asset(
                                                    'assets/pledgedicon.png',
                                                    height: 16,
                                                    width: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                    jsonData.addedCart == "Y"
                                        ? InkWell(
                                            onTap: () {
                                              MFChangeIndex().value = 3;
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              height: 17,
                                              width: 17,
                                              alignment: Alignment.center,
                                              child: Image.asset(
                                                darkThemeMode
                                                    ? 'assets/CartAddSuccess.png'
                                                    : 'assets/CartAddSuccess_W.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                ),
                              ],
                            ),
                            subtitle2: RichTextWidget(
                              alignRight: MainAxisAlignment.start,
                              firstWidget: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('NAV ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              // color: subTitleTextColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11.5)),
                                  Text(
                                      '${jsonData.navValue == '' || jsonData.navValue == '0' || jsonData.navValue == 'NA' ? '-' : jsonData.navValue}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11.5)),
                                  Visibility(
                                      visible: (jsonData.navValue == '' ||
                                          jsonData.navValue == '0' ||
                                          jsonData.navValue == 'NA'),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: InkWell(
                                          onTap: () => customMfAlertBox(
                                              context: context,
                                              func1: () {},
                                              title: 'NAV value',
                                              contentWidget: Text(
                                                  navigationProvider
                                                          .mfSchemeMasterDetails
                                                          ?.mfNavInfoMessage ??
                                                      '')),
                                          child: Icon(
                                            Icons.info,
                                            size: 14,
                                            color: appPrimeColor,
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            subtitle3: Visibility(
                              visible: jsonData.closeDays!.isNotEmpty,
                              child: Container(
                                margin:
                                    const EdgeInsets.only(right: 10, top: 3),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color:
                                            subTitleTextColor.withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.access_time_filled_rounded,
                                      color: primaryGreenColor,
                                      size: 15,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                        jsonData.closeDays == "0"
                                            ? widget.mfNFOM2!
                                            : (widget.mfNFOM1 ?? '')
                                                .toString()
                                                .replaceAll(
                                                    "\$", jsonData.closeDays!),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11.5)),
                                  ],
                                ),
                              ),
                            ),
                            titleWidget: SizedBox(
                              width: 75,
                              height: 25,
                              child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  color: (jsonData.navValue == '' ||
                                          jsonData.navValue == '0' ||
                                          jsonData.navValue == 'NA')
                                      ? modifyButtonColor
                                      : appPrimeColor,
                                  padding: EdgeInsets.zero,
                                  onPressed: () async {
                                    (jsonData.navValue == '' ||
                                            jsonData.navValue == '0' ||
                                            jsonData.navValue == 'NA')
                                        ? null
                                        : mfInvestBottomSheet(
                                            context: context,
                                            isin: jsonData.isin ?? "",
                                            // purchaseConfigDetails: data,
                                            type: 'buy');
                                  },
                                  child: Text(
                                    (jsonData.navValue == '' ||
                                            jsonData.navValue == '0' ||
                                            jsonData.navValue == 'NA')
                                        ? 'Coming Soon'
                                        : 'LUMPSUM',
                                    style: ThemeClass
                                        .Darktheme.textTheme.bodyLarge!
                                        .copyWith(
                                            color: (jsonData.navValue == '' ||
                                                    jsonData.navValue == '0' ||
                                                    jsonData.navValue == 'NA')
                                                ? appPrimeColor
                                                : titleTextColorDark,
                                            fontWeight: FontWeight.bold,
                                            fontSize: (jsonData.navValue ==
                                                        '' ||
                                                    jsonData.navValue == '0' ||
                                                    jsonData.navValue == 'NA')
                                                ? 10
                                                : 11),
                                  )),
                            ),
                          );
                          // } else {
                          //   return SizedBox();

                          //    totalPages > 0 && totalPages < 2
                          //       ? const SizedBox()
                          //       : Row(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.start,
                          //           children: [
                          //             Container(
                          //               // color: Colors.red,
                          //               decoration: BoxDecoration(
                          //                   color: appPrimeColor,
                          //                   border: Border.all(
                          //                       color: titleTextColorDark),
                          //                   borderRadius:
                          //                       const BorderRadius.only(
                          //                           topLeft: Radius.circular(8),
                          //                           bottomLeft:
                          //                               Radius.circular(8))),
                          //               width: 35,
                          //               height: 35,
                          //               child: InkWell(
                          //                 onTap: () {
                          //                   setState(() {
                          //                     if (currentPage > 1) {
                          //                       if (widget.scrollController!
                          //                           .hasClients) {
                          //                         widget.scrollController!
                          //                             .animateTo(
                          //                           0.0,
                          //                           duration: const Duration(
                          //                               milliseconds: 300),
                          //                           curve: Curves.easeOut,
                          //                         );
                          //                         currentPage--;
                          //                       }
                          //                     }
                          //                   });
                          //                 },
                          //                 child: Icon(
                          //                   Icons.arrow_back_ios_new_outlined,
                          //                   size: 14,
                          //                   color: titleTextColorDark,
                          //                 ),
                          //               ),
                          //             ),
                          //             Container(
                          //               alignment: Alignment.center,
                          //               decoration: BoxDecoration(
                          //                 color: appPrimeColor,
                          //                 border: Border.symmetric(
                          //                     horizontal: BorderSide(
                          //                         color: titleTextColorDark)),
                          //               ),
                          //               width: 100,
                          //               height: 35,
                          //               child: Text(
                          //                 '$currentPage - $totalPages of $rowsPerPage',
                          //                 style: Theme.of(context)
                          //                     .textTheme
                          //                     .bodySmall!
                          //                     .copyWith(
                          //                         color: titleTextColorDark),
                          //               ),
                          //             ),
                          //             Container(
                          //               width: 35,
                          //               height: 35,
                          //               decoration: BoxDecoration(
                          //                   color: appPrimeColor,
                          //                   border: Border.all(
                          //                       color: titleTextColorDark),
                          //                   borderRadius:
                          //                       const BorderRadius.only(
                          //                           topRight:
                          //                               Radius.circular(8),
                          //                           bottomRight:
                          //                               Radius.circular(8))),
                          //               child: InkWell(
                          //                 onTap: () {
                          //                   setState(() {
                          //                     if (currentPage < totalPages) {
                          //                       if (widget.scrollController!
                          //                           .hasClients) {
                          //                         widget.scrollController!
                          //                             .animateTo(
                          //                           0.0,
                          //                           duration: const Duration(
                          //                               milliseconds: 300),
                          //                           curve: Curves.easeOut,
                          //                         );
                          //                         currentPage++;
                          //                       }
                          //                     }
                          //                   });
                          //                 },
                          //                 child: Icon(
                          //                   Icons.arrow_forward_ios_rounded,
                          //                   size: 14,
                          //                   color: titleTextColorDark,
                          //                 ),
                          //               ),
                          //             ),
                          //           ],
                          //         );
                          // }
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 10,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
