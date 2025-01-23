import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novo/API/APICall.dart';
import 'package:provider/provider.dart';

import '../../Provider/provider.dart';
import '../../model/ipoModels/ipoMktDemandmodel.dart';
import '../../utils/Themes/theme.dart';
import '../../utils/colors.dart';
import '../NOVO Widgets/netWorkConnectionAlertBox.dart';

IpoMktDemandModel? ipoMktDemandModel;
List<IpoMktDemandArr>? ipoMktDemandData;
List<IpoMktCatwiseArr>? ipoMktCatwiseData;
// int rowsPerPage = 5;
// int currentPage = 1;
// int currentPageCat = 1;

ScrollController _controllerPrice = ScrollController();
ScrollController _controllerCategory = ScrollController();

Future<void> fetchIpoMktDemandInAPI(
    context, int masterId, String symbol, String issueSize) async {
  if (await isInternetConnected()) {
    ipoMktDemandModel =
        await fetchIpoMktDemand(context: context, masterid: masterId);
    Navigator.pop(context);

    if (ipoMktDemandModel != null) {
      ipoMktDemandData =
          //  [];

          ipoMktDemandModel!.ipoMktDemandArr;
      ipoMktCatwiseData = ipoMktDemandModel!.ipoMktCatwiseArr;

      showIpoMktDialog(context, ipoMktDemandData!, ipoMktCatwiseData!,
          ipoMktDemandModel!.noDataText!, symbol, issueSize);
    } else {
      // //////////print(ipoMktDemandModel);
      // showSnackbar(context, '', color)
    }
  } else {
    noInternetConnectAlertDialog(
        context, () => fetchIpoMktDemand(context: context, masterid: masterId));
  }
}

// showIpoMktDialog(
//     BuildContext context,
//     List<IpoMktDemandArr> ipoMktDemandData,
//     List<IpoMktCatwiseArr> ipoMktCatwiseData,
//     String ipoMrtnoDataText,
//     String symbol,
//     String issueSize) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           final demandTotalPages =
//               (ipoMktDemandData.length / rowsPerPage).ceil();
//           final catTotalPages = (ipoMktCatwiseData.length / rowsPerPage).ceil();
//           final startIndex = (currentPage - 1) * rowsPerPage;
//           final startIndexCat = (currentPageCat - 1) * rowsPerPage;
//           final demandEndIndex =
//               (currentPage * rowsPerPage).clamp(0, ipoMktDemandData.length);
//           final catEndIndex =
//               (currentPageCat * rowsPerPage).clamp(0, ipoMktCatwiseData.length);

//           final pageItems =
//               ipoMktDemandData.sublist(startIndex, demandEndIndex);
//           final pageItemsCat =
//               ipoMktCatwiseData.sublist(startIndexCat, catEndIndex);
//           return Dialog(
//             child: Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           symbol,
//                           overflow: TextOverflow.visible,
//                           style: Provider.of<NavigationProvider>(context)
//                                       .themeMode ==
//                                   ThemeMode.light
//                               ? ThemeClass.lighttheme.textTheme.titleMedium
//                               : ThemeClass.Darktheme.textTheme.titleMedium,
//                         ),
//                         InkWell(
//                           onTap: () {
//                             currentPage = 1;
//                             currentPageCat = 1;
//                             Navigator.pop(context);
//                           },
//                           child: Icon(
//                             CupertinoIcons.multiply,
//                             color: Provider.of<NavigationProvider>(context)
//                                         .themeMode ==
//                                     ThemeMode.light
//                                 ? ThemeClass
//                                     .lighttheme.textTheme.titleMedium!.color
//                                 : ThemeClass
//                                     .Darktheme.textTheme.titleMedium!.color,
//                           ),
//                         )
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 8.0,
//                     ),
//                     ipoMktDemandData.isEmpty && ipoMktCatwiseData.isEmpty
//                         ? Text(
//                             ipoMrtnoDataText,
//                             style:
//                                 ThemeClass.lighttheme.textTheme.displayMedium,
//                           )
//                         : Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Text('Subscription Details',
//                                   style:
//                                       Provider.of<NavigationProvider>(context)
//                                                   .themeMode ==
//                                               ThemeMode.light
//                                           ? ThemeClass
//                                               .lighttheme.textTheme.titleMedium!
//                                               .copyWith(fontSize: 13)
//                                           : ThemeClass
//                                               .Darktheme.textTheme.titleMedium!
//                                               .copyWith(fontSize: 13)),
//                               const SizedBox(
//                                 height: 5.0,
//                               ),
//                               Visibility(
//                                 visible: ipoMktDemandData.isNotEmpty,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text('By Price',
//                                         style: Provider.of<NavigationProvider>(
//                                                         context)
//                                                     .themeMode ==
//                                                 ThemeMode.light
//                                             ? ThemeClass.lighttheme.textTheme
//                                                 .titleMedium!
//                                                 .copyWith(fontSize: 13)
//                                             : ThemeClass.Darktheme.textTheme
//                                                 .titleMedium!
//                                                 .copyWith(fontSize: 13)),
//                                     const SizedBox(
//                                       height: 5.0,
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Price',
//                                           style:
//                                               Provider.of<NavigationProvider>(
//                                                               context)
//                                                           .themeMode ==
//                                                       ThemeMode.light
//                                                   ? ThemeClass.lighttheme
//                                                       .textTheme.displayMedium
//                                                   : ThemeClass.Darktheme
//                                                       .textTheme.displayMedium,
//                                         ),
//                                         Text(
//                                           'Quantity',
//                                           style:
//                                               Provider.of<NavigationProvider>(
//                                                               context)
//                                                           .themeMode ==
//                                                       ThemeMode.light
//                                                   ? ThemeClass.lighttheme
//                                                       .textTheme.displayMedium
//                                                   : ThemeClass.Darktheme
//                                                       .textTheme.displayMedium,
//                                         )
//                                       ],
//                                     ),
//                                     Divider(
//                                       color: subTitleTextColor,
//                                     ),
//                                     SizedBox(
//                                       // height: pageItems.length <= 5
//                                       //     ? pageItems.length.toDouble() * 20
//                                       //     : 100,
//                                       child: Column(
//                                         // controller: _controllerPrice,
//                                         children: [
//                                           ...pageItems.map((e) => SizedBox(
//                                                 height: 20,
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     e.cutoff!
//                                                         ? Text(
//                                                             'Cutoff(${e.price})',
//                                                             style: Provider.of<NavigationProvider>(
//                                                                             context)
//                                                                         .themeMode ==
//                                                                     ThemeMode
//                                                                         .light
//                                                                 ? ThemeClass
//                                                                     .lighttheme
//                                                                     .textTheme
//                                                                     .bodyMedium!
//                                                                     .copyWith(
//                                                                         height:
//                                                                             1.5)
//                                                                 : ThemeClass
//                                                                     .Darktheme
//                                                                     .textTheme
//                                                                     .bodyMedium!
//                                                                     .copyWith(
//                                                                         height:
//                                                                             1.5),
//                                                           )
//                                                         : Text(
//                                                             e.price!,
//                                                             style: Provider.of<NavigationProvider>(
//                                                                             context)
//                                                                         .themeMode ==
//                                                                     ThemeMode
//                                                                         .light
//                                                                 ? ThemeClass
//                                                                     .lighttheme
//                                                                     .textTheme
//                                                                     .bodyMedium!
//                                                                     .copyWith(
//                                                                         height:
//                                                                             1.5)
//                                                                 : ThemeClass
//                                                                     .Darktheme
//                                                                     .textTheme
//                                                                     .bodyMedium!
//                                                                     .copyWith(
//                                                                         height:
//                                                                             1.5),
//                                                           ),
//                                                     Text(
//                                                       "${e.quantity}",
//                                                       style: Provider.of<NavigationProvider>(
//                                                                       context)
//                                                                   .themeMode ==
//                                                               ThemeMode.light
//                                                           ? ThemeClass
//                                                               .lighttheme
//                                                               .textTheme
//                                                               .bodyMedium!
//                                                               .copyWith(
//                                                                   height: 1.5)
//                                                           : ThemeClass
//                                                               .Darktheme
//                                                               .textTheme
//                                                               .bodyMedium!
//                                                               .copyWith(
//                                                                   height: 1.5),
//                                                     )
//                                                   ],
//                                                 ),
//                                               )),
//                                         ],
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Visibility(
//                                       visible: demandTotalPages != 1,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             '${startIndex + 1}-$demandEndIndex of ${ipoMktDemandData.length}',
//                                             style: TextStyle(
//                                               fontSize: 10,
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: 10,
//                                           ),
//                                           InkWell(
//                                             onTap: currentPage > 1
//                                                 ? () {
//                                                     setState(() {
//                                                       currentPage--;
//                                                     });
//                                                   }
//                                                 : null,
//                                             child: Icon(
//                                               Icons.arrow_back_ios,
//                                               size: 12,
//                                               color: currentPage > 1
//                                                   ? Colors.black
//                                                   : Colors.grey,
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: 5,
//                                           ),
//                                           InkWell(
//                                             onTap:
//                                                 currentPage < demandTotalPages
//                                                     ? () {
//                                                         setState(() {
//                                                           currentPage++;
//                                                         });
//                                                       }
//                                                     : null,
//                                             child: Icon(
//                                               Icons.arrow_forward_ios,
//                                               size: 12,
//                                               color:
//                                                   currentPage < demandTotalPages
//                                                       ? Colors.black
//                                                       : Colors.grey,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Divider(
//                                       color: subTitleTextColor,
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'Total subcription',
//                                           style:
//                                               Provider.of<NavigationProvider>(
//                                                               context)
//                                                           .themeMode ==
//                                                       ThemeMode.light
//                                                   ? ThemeClass.lighttheme
//                                                       .textTheme.displayMedium!
//                                                       .copyWith(height: 1.5)
//                                                   : ThemeClass.Darktheme
//                                                       .textTheme.displayMedium!
//                                                       .copyWith(height: 1.5),
//                                         ),
//                                         Text(
//                                           '${ipoMktDemandModel!.totalQtywithText}',
//                                           style:
//                                               Provider.of<NavigationProvider>(
//                                                               context)
//                                                           .themeMode ==
//                                                       ThemeMode.light
//                                                   ? ThemeClass.lighttheme
//                                                       .textTheme.titleMedium!
//                                                       .copyWith(height: 1.5)
//                                                   : ThemeClass.Darktheme
//                                                       .textTheme.titleMedium!
//                                                       .copyWith(height: 1.5),
//                                         )
//                                       ],
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'Offered Qty',
//                                           style: ThemeClass.lighttheme.textTheme
//                                               .displayMedium!
//                                               .copyWith(height: 1.5),
//                                         ),
//                                         Text(
//                                           issueSize,
//                                           style:
//                                               Provider.of<NavigationProvider>(
//                                                               context)
//                                                           .themeMode ==
//                                                       ThemeMode.light
//                                                   ? ThemeClass.lighttheme
//                                                       .textTheme.titleMedium!
//                                                       .copyWith(height: 1.5)
//                                                   : ThemeClass.Darktheme
//                                                       .textTheme.titleMedium!
//                                                       .copyWith(height: 1.5),
//                                         )
//                                       ],
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'Subscription %',
//                                           style: ThemeClass.lighttheme.textTheme
//                                               .displayMedium!
//                                               .copyWith(height: 1.5),
//                                         ),
//                                         Text(
//                                           '${ipoMktDemandModel!.subscriptionText}',
//                                           style: Provider.of<NavigationProvider>(
//                                                           context)
//                                                       .themeMode ==
//                                                   ThemeMode.light
//                                               ? ThemeClass.lighttheme.textTheme
//                                                   .titleMedium!
//                                                   .copyWith(
//                                                       height: 1.5,
//                                                       color: primaryGreenColor)
//                                               : ThemeClass.Darktheme.textTheme
//                                                   .titleMedium!
//                                                   .copyWith(
//                                                       height: 1.5,
//                                                       color: primaryGreenColor),
//                                         )
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(
//                                 height: 15.0,
//                               ),
//                               Visibility(
//                                 visible: ipoMktCatwiseData.isNotEmpty,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text('By Category',
//                                         style: Provider.of<NavigationProvider>(
//                                                         context)
//                                                     .themeMode ==
//                                                 ThemeMode.light
//                                             ? ThemeClass.lighttheme.textTheme
//                                                 .titleMedium!
//                                                 .copyWith(fontSize: 13)
//                                             : ThemeClass.Darktheme.textTheme
//                                                 .titleMedium!
//                                                 .copyWith(fontSize: 13)),
//                                     const SizedBox(
//                                       height: 5.0,
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'Category',
//                                           style: ThemeClass.lighttheme.textTheme
//                                               .displayMedium!
//                                               .copyWith(height: 1.5),
//                                         ),
//                                         Text(
//                                           'Quantity',
//                                           style: ThemeClass.lighttheme.textTheme
//                                               .displayMedium!
//                                               .copyWith(height: 1.5),
//                                         )
//                                       ],
//                                     ),
//                                     Divider(
//                                       color: subTitleTextColor,
//                                     ),
//                                     SizedBox(
//                                       // height: ipoMktCatwiseData.length <= 5
//                                       //     ? ipoMktCatwiseData.length * 21
//                                       //     : 100,
//                                       child: Column(
//                                         // controller: _controllerCategory,
//                                         children: [
//                                           ...pageItemsCat.map((e) => SizedBox(
//                                                 height: 20,
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     Text(
//                                                       e.category!,
//                                                       style: Provider.of<NavigationProvider>(
//                                                                       context)
//                                                                   .themeMode ==
//                                                               ThemeMode.light
//                                                           ? ThemeClass
//                                                               .lighttheme
//                                                               .textTheme
//                                                               .bodyMedium!
//                                                               .copyWith(
//                                                                   height: 1.5)
//                                                           : ThemeClass
//                                                               .Darktheme
//                                                               .textTheme
//                                                               .bodyMedium!
//                                                               .copyWith(
//                                                                   height: 1.5),
//                                                     ),
//                                                     Text(
//                                                       '${e.quantity}',
//                                                       style: Provider.of<NavigationProvider>(
//                                                                       context)
//                                                                   .themeMode ==
//                                                               ThemeMode.light
//                                                           ? ThemeClass
//                                                               .lighttheme
//                                                               .textTheme
//                                                               .bodyMedium!
//                                                               .copyWith(
//                                                                   height: 1.5)
//                                                           : ThemeClass
//                                                               .Darktheme
//                                                               .textTheme
//                                                               .bodyMedium!
//                                                               .copyWith(
//                                                                   height: 1.5),
//                                                     )
//                                                   ],
//                                                 ),
//                                               )),
//                                         ],
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Visibility(
//                                       visible: catTotalPages != 1,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             '${startIndexCat + 1}-$catEndIndex of ${ipoMktCatwiseData.length}',
//                                             style: TextStyle(fontSize: 10),
//                                           ),
//                                           SizedBox(
//                                             width: 10,
//                                           ),
//                                           InkWell(
//                                             onTap: currentPageCat > 1
//                                                 ? () {
//                                                     setState(() {
//                                                       currentPageCat--;
//                                                     });
//                                                   }
//                                                 : null,
//                                             child: Icon(
//                                               Icons.arrow_back_ios,
//                                               size: 12,
//                                               color: currentPageCat > 1
//                                                   ? Colors.black
//                                                   : Colors.grey,
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: 5,
//                                           ),
//                                           InkWell(
//                                             onTap:
//                                                 currentPageCat < catTotalPages
//                                                     ? () {
//                                                         setState(() {
//                                                           currentPageCat++;
//                                                         });
//                                                       }
//                                                     : null,
//                                             child: Icon(
//                                               Icons.arrow_forward_ios,
//                                               size: 12,
//                                               color:
//                                                   currentPageCat < catTotalPages
//                                                       ? Colors.black
//                                                       : Colors.grey,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     },
//   );
// }

showIpoMktDialog(
    BuildContext context,
    List<IpoMktDemandArr> ipoMktDemandData,
    List<IpoMktCatwiseArr> ipoMktCatwiseData,
    String ipoMrtnoDataText,
    String symbol,
    String issueSize) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      overflow: TextOverflow.visible,
                      style:
                          Provider.of<NavigationProvider>(context).themeMode ==
                                  ThemeMode.light
                              ? ThemeClass.lighttheme.textTheme.titleMedium
                              : ThemeClass.Darktheme.textTheme.titleMedium,
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        CupertinoIcons.multiply,
                        color: Provider.of<NavigationProvider>(context)
                                    .themeMode ==
                                ThemeMode.light
                            ? ThemeClass.lighttheme.textTheme.titleMedium!.color
                            : ThemeClass.Darktheme.textTheme.titleMedium!.color,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                ipoMktDemandData.isEmpty && ipoMktCatwiseData.isEmpty
                    ? Text(
                        ipoMrtnoDataText,
                        style: ThemeClass.lighttheme.textTheme.displayMedium,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Subscription Details',
                              style: Provider.of<NavigationProvider>(context)
                                          .themeMode ==
                                      ThemeMode.light
                                  ? ThemeClass.lighttheme.textTheme.titleMedium!
                                      .copyWith(fontSize: 13)
                                  : ThemeClass.Darktheme.textTheme.titleMedium!
                                      .copyWith(fontSize: 13)),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Visibility(
                            visible: ipoMktDemandData.isNotEmpty,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('By Price',
                                    style:
                                        Provider.of<NavigationProvider>(context)
                                                    .themeMode ==
                                                ThemeMode.light
                                            ? ThemeClass.lighttheme.textTheme
                                                .titleMedium!
                                                .copyWith(fontSize: 13)
                                            : ThemeClass.Darktheme.textTheme
                                                .titleMedium!
                                                .copyWith(fontSize: 13)),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Price',
                                      style: Provider.of<NavigationProvider>(
                                                      context)
                                                  .themeMode ==
                                              ThemeMode.light
                                          ? ThemeClass.lighttheme.textTheme
                                              .displayMedium
                                          : ThemeClass.Darktheme.textTheme
                                              .displayMedium,
                                    ),
                                    Text(
                                      'Quantity',
                                      style: Provider.of<NavigationProvider>(
                                                      context)
                                                  .themeMode ==
                                              ThemeMode.light
                                          ? ThemeClass.lighttheme.textTheme
                                              .displayMedium
                                          : ThemeClass.Darktheme.textTheme
                                              .displayMedium,
                                    )
                                  ],
                                ),
                                Divider(
                                  color: subTitleTextColor,
                                ),
                                SizedBox(
                                  height: ipoMktDemandData.length <= 5
                                      ? ipoMktDemandData.length.toDouble() * 20
                                      : 100,
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    controller: _controllerPrice,
                                    child: ListView(
                                      controller: _controllerPrice,
                                      children: [
                                        ...ipoMktDemandData
                                            .map((e) => Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 10.0),
                                                  height: 20,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      e.cutoff!
                                                          ? Text(
                                                              'Cutoff(${e.price})',
                                                              style: Provider.of<NavigationProvider>(
                                                                              context)
                                                                          .themeMode ==
                                                                      ThemeMode
                                                                          .light
                                                                  ? ThemeClass
                                                                      .lighttheme
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                          height:
                                                                              1.5)
                                                                  : ThemeClass
                                                                      .Darktheme
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                          height:
                                                                              1.5),
                                                            )
                                                          : Text(
                                                              e.price!,
                                                              style: Provider.of<NavigationProvider>(
                                                                              context)
                                                                          .themeMode ==
                                                                      ThemeMode
                                                                          .light
                                                                  ? ThemeClass
                                                                      .lighttheme
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                          height:
                                                                              1.5)
                                                                  : ThemeClass
                                                                      .Darktheme
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                          height:
                                                                              1.5),
                                                            ),
                                                      Text(
                                                        "${e.quantity}",
                                                        style: Provider.of<NavigationProvider>(
                                                                        context)
                                                                    .themeMode ==
                                                                ThemeMode.light
                                                            ? ThemeClass
                                                                .lighttheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    height: 1.5)
                                                            : ThemeClass
                                                                .Darktheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    height:
                                                                        1.5),
                                                      )
                                                    ],
                                                  ),
                                                )),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: subTitleTextColor,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total subcription',
                                      style: Provider.of<NavigationProvider>(
                                                      context)
                                                  .themeMode ==
                                              ThemeMode.light
                                          ? ThemeClass.lighttheme.textTheme
                                              .displayMedium!
                                              .copyWith(height: 1.5)
                                          : ThemeClass.Darktheme.textTheme
                                              .displayMedium!
                                              .copyWith(height: 1.5),
                                    ),
                                    Text(
                                      ipoMktDemandModel!.totalQtywithText!,
                                      style: Provider.of<NavigationProvider>(
                                                      context)
                                                  .themeMode ==
                                              ThemeMode.light
                                          ? ThemeClass
                                              .lighttheme.textTheme.titleMedium!
                                              .copyWith(height: 1.5)
                                          : ThemeClass
                                              .Darktheme.textTheme.titleMedium!
                                              .copyWith(height: 1.5),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Offered Qty',
                                      style: ThemeClass
                                          .lighttheme.textTheme.displayMedium!
                                          .copyWith(height: 1.5),
                                    ),
                                    Text(
                                      issueSize,
                                      style: Provider.of<NavigationProvider>(
                                                      context)
                                                  .themeMode ==
                                              ThemeMode.light
                                          ? ThemeClass
                                              .lighttheme.textTheme.titleMedium!
                                              .copyWith(height: 1.5)
                                          : ThemeClass
                                              .Darktheme.textTheme.titleMedium!
                                              .copyWith(height: 1.5),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Subscription %',
                                      style: ThemeClass
                                          .lighttheme.textTheme.displayMedium!
                                          .copyWith(height: 1.5),
                                    ),
                                    Text(
                                      ipoMktDemandModel!.subscriptionText!,
                                      style: Provider.of<NavigationProvider>(
                                                      context)
                                                  .themeMode ==
                                              ThemeMode.light
                                          ? ThemeClass
                                              .lighttheme.textTheme.titleMedium!
                                              .copyWith(
                                                  height: 1.5,
                                                  color: primaryGreenColor)
                                          : ThemeClass
                                              .Darktheme.textTheme.titleMedium!
                                              .copyWith(
                                                  height: 1.5,
                                                  color: primaryGreenColor),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Visibility(
                            visible: ipoMktCatwiseData.isNotEmpty,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('By Category',
                                    style:
                                        Provider.of<NavigationProvider>(context)
                                                    .themeMode ==
                                                ThemeMode.light
                                            ? ThemeClass.lighttheme.textTheme
                                                .titleMedium!
                                                .copyWith(fontSize: 13)
                                            : ThemeClass.Darktheme.textTheme
                                                .titleMedium!
                                                .copyWith(fontSize: 13)),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Category',
                                      style: ThemeClass
                                          .lighttheme.textTheme.displayMedium!
                                          .copyWith(height: 1.5),
                                    ),
                                    Text(
                                      'Quantity',
                                      style: ThemeClass
                                          .lighttheme.textTheme.displayMedium!
                                          .copyWith(height: 1.5),
                                    )
                                  ],
                                ),
                                Divider(
                                  color: subTitleTextColor,
                                ),
                                SizedBox(
                                  height: ipoMktCatwiseData.length <= 5
                                      ? ipoMktCatwiseData.length * 21
                                      : 100,
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    controller: _controllerCategory,
                                    child: ListView(
                                      controller: _controllerCategory,
                                      children: [
                                        ...ipoMktCatwiseData
                                            .map((e) => Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 10.0),
                                                  height: 20,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        e.category!,
                                                        style: Provider.of<NavigationProvider>(
                                                                        context)
                                                                    .themeMode ==
                                                                ThemeMode.light
                                                            ? ThemeClass
                                                                .lighttheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    height: 1.5)
                                                            : ThemeClass
                                                                .Darktheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    height:
                                                                        1.5),
                                                      ),
                                                      Text(
                                                        '${e.quantity}',
                                                        style: Provider.of<NavigationProvider>(
                                                                        context)
                                                                    .themeMode ==
                                                                ThemeMode.light
                                                            ? ThemeClass
                                                                .lighttheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    height: 1.5)
                                                            : ThemeClass
                                                                .Darktheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    height:
                                                                        1.5),
                                                      )
                                                    ],
                                                  ),
                                                )),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
