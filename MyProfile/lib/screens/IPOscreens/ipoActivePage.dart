// ignore_for_file: prefer_final_fields, unused_field, no_leading_underscores_for_local_identifiers, unused_local_variable, use_build_context_synchronously, file_names, must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:novo/API/APICall.dart';

import 'package:novo/Provider/provider.dart';

import 'package:novo/model/ipoModels/ipoMasterDetails.dart';

import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/utils/colors.dart';
import 'package:novo/utils/launchurl.dart';

import 'package:provider/provider.dart';
import '../../widgets/IPO Widgets/IpoMrkDataDailog.dart';
import '../../widgets/IPO Widgets/ipoFooter.dart';
import '../../widgets/IPO Widgets/smeContainer.dart';
import '../../widgets/NOVO Widgets/customLoadingAni.dart';
import '../../widgets/NOVO Widgets/loadingDailogwithCircle.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../widgets/NOVO Widgets/searchField.dart';
import '/Roating/route.dart' as route;

class IpoScreen extends StatefulWidget {
  String user = 'a';
  IpoScreen({super.key, required this.ipoMasterDetailsData});
  IpoMasterDetails? ipoMasterDetailsData;

  @override
  State<IpoScreen> createState() => _IpoScreenState();
}

class _IpoScreenState extends State<IpoScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool isLoaded = true;
  String searchtext = '';
  List<IpoDetail>? ipoMasterDetailList;
  String? ipoMasterNoDataText;
  List<IpoDetail> filterdatalist = [];
  @override
  void initState() {
    super.initState();

    fetchTheInitialData();
  }

  fetchTheInitialData() {
    // super.widget.user;
    getIpoMasterData();
  }

  Future<void> getIpoMasterData() async {
    if (await isInternetConnected()) {
      if (widget.ipoMasterDetailsData != null) {
        ipoMasterDetailList = widget.ipoMasterDetailsData!.ipoDetail;
        filterdatalist = ipoMasterDetailList!;
        ipoMasterNoDataText = widget.ipoMasterDetailsData!.masterNoDataText;
        // ////////print('sdflksdf${filterdatalist.map}');
        setState(() {
          isLoaded = false;
        });
      } else {
        filterdatalist = [];
      }
    } else {
      noInternetConnectAlertDialog(context, () => getIpoMasterData());
    }
  }

  void searchdata(String value) {
    searchtext = value;
    if (searchtext.isEmpty) {
      filterdatalist = ipoMasterDetailList!;
    } else {
      filterdatalist = ipoMasterDetailList!
          .where((data) => data.symbol
              .toString()
              .toLowerCase()
              .contains(searchtext.toLowerCase()))
          .toList();
    }
    if (filterdatalist.isEmpty) {}
    setState(() {});
  }

  buttonVisibleFun(IpoDetail filterdataList) {
    if (filterdataList.buttonText!.isNotEmpty &&
        filterdataList.buttonText != '' &&
        filterdataList.actionFlag != '' &&
        filterdataList.actionFlag!.isNotEmpty) {
      return true;
    }

    return false;
  }

  disabelButtonFun(IpoDetail filterdataList) {
    if (!(filterdataList.actionFlag == 'U' ||
            filterdataList.actionFlag == 'PA' ||
            filterdataList.actionFlag == 'B' ||
            filterdataList.actionFlag == 'M' ||
            filterdataList.actionFlag == 'O' ||
            filterdataList.actionFlag == 'CL') ||
        filterdataList.disableActionBtn == true) {
      return true;
    }

    return false;
  }

  buttonColorFunc(IpoDetail filterdataList) {
    if ((filterdataList.actionFlag == 'PA' ||
            filterdataList.actionFlag == 'B' ||
            filterdataList.actionFlag == 'O') &&
        filterdataList.disableActionBtn == false) {
      return appPrimeColor;
    } else if ((filterdataList.actionFlag == 'M' ||
            filterdataList.actionFlag == 'U' ||
            filterdataList.actionFlag == 'CL') &&
        filterdataList.disableActionBtn == false) {
      return modifyButtonColor;
    } else if (filterdataList.disableActionBtn == false) {
      return appPrimeColor;
    }
  }

  onCategorySubmit(IpoDetail ipoMasterDetails) {
    if (ipoMasterDetails.categoryList!.isEmpty) {
      return;
    }
    if (ipoMasterDetails.categoryList!.length == 1) {
      onSubmit(ipoMasterDetails, ipoMasterDetails.categoryList![0]);
    } else {
      showCategoryBottomSheet(ipoMasterDetails, ipoMasterDetails.categoryList!);
    }
  }

  onSubmit(IpoDetail ipoDetail, CategoryList ipoCategoryList) {
    Navigator.pushNamed(context, route.bidscreen, arguments: {
      'ipoDetail': ipoDetail,
      'categoryList': ipoCategoryList,
      'suggestUPI': widget.ipoMasterDetailsData!.suggestUpi
    });
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
      // backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: isLoaded
          ? const Center(child: LoadingProgress())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchFeild(
                    visible: widget.ipoMasterDetailsData!.masterFound == 'Y' &&
                        ipoMasterDetailList!.isNotEmpty,
                    onChange: searchdata,
                  ),
                  Visibility(
                    visible: filterdatalist.isNotEmpty &&
                        ipoMasterDetailList!.isNotEmpty &&
                        widget.ipoMasterDetailsData!.offlineIndicator == 'Y' &&
                        widget.ipoMasterDetailsData!.offlineText!.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outlined,
                            size: 16,
                            color: themeModeLight
                                ? appPrimeColor
                                : Colors.blue.shade400,
                          ),
                          Text(
                            ' ${widget.ipoMasterDetailsData!.offlineText}',
                            style: TextStyle(
                                color: themeModeLight
                                    ? appPrimeColor
                                    : Colors.blue.shade400,
                                fontSize: 13,
                                fontFamily: 'inter',
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: widget.ipoMasterDetailsData!.masterFound == 'N'
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(),
                                Center(
                                  child: Text(
                                      widget.ipoMasterDetailsData!
                                          .masterNoDataText!,
                                      style: TextStyle(
                                        fontFamily: 'inter',
                                        color: subTitleTextColor,
                                        fontSize: titleFontSize,
                                      )),
                                ),
                                const Spacer(),
                                Visibility(
                                  visible: widget.ipoMasterDetailsData!
                                          .disclaimer.isNotEmpty ||
                                      widget.ipoMasterDetailsData!.disclaimer !=
                                          null,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 30.0,
                                      ),
                                      BulletList(widget
                                          .ipoMasterDetailsData!.disclaimer)
                                    ],
                                  ),
                                )
                              ],
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                // await fetchTheInitialData();
                                await fetchIpoMasterDetails(context: context);
                              },
                              child: filterdatalist.isEmpty
                                  ? ListView(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Center(
                                            child: Text('Record Not Found',
                                                style: TextStyle(
                                                  fontFamily: 'inter',
                                                  color: subTitleTextColor,
                                                  fontSize: titleFontSize,
                                                ))),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Visibility(
                                          visible: widget.ipoMasterDetailsData!
                                                  .disclaimer.isNotEmpty ||
                                              widget.ipoMasterDetailsData!
                                                      .disclaimer !=
                                                  null,
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 30.0,
                                              ),
                                              BulletList(widget
                                                  .ipoMasterDetailsData!
                                                  .disclaimer)
                                            ],
                                          ),
                                        )
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
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
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
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Flexible(
                                                                child: filterdatalist[
                                                                            index]
                                                                        .blogLink!
                                                                        .isNotEmpty
                                                                    ? InkWell(
                                                                        onTap: () =>
                                                                            launchUrlFunction(filterdatalist[index].blogLink!),
                                                                        child:
                                                                            Text(
                                                                          filterdatalist[index]
                                                                              .symbol!,
                                                                          overflow:
                                                                              TextOverflow.visible,
                                                                          style: TextStyle(
                                                                              color: themeModeLight ? appPrimeColor : Colors.blue,
                                                                              fontFamily: 'inter',
                                                                              fontSize: titleFontSize,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      )
                                                                    : Text(
                                                                        filterdatalist[index]
                                                                            .symbol!,
                                                                        overflow:
                                                                            TextOverflow.visible,
                                                                        style: themeModeLight
                                                                            ? ThemeClass.lighttheme.textTheme.titleMedium
                                                                            : ThemeClass.Darktheme.textTheme.titleMedium,
                                                                      ),
                                                              ),
                                                              const SizedBox(
                                                                width: 5.0,
                                                              ),
                                                              Visibility(
                                                                visible:
                                                                    filterdatalist[
                                                                            index]
                                                                        .sme!,
                                                                child:
                                                                    const SmeContainer(),
                                                              ),
                                                              Visibility(
                                                                visible:
                                                                    filterdatalist[
                                                                            index]
                                                                        .sme!,
                                                                child:
                                                                    const SizedBox(
                                                                  width: 5.0,
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  loadingDailogWithCircle(
                                                                      context);

                                                                  fetchIpoMktDemandInAPI(
                                                                      context,
                                                                      filterdatalist[
                                                                              index]
                                                                          .id!,
                                                                      filterdatalist[
                                                                              index]
                                                                          .symbol!,
                                                                      filterdatalist[
                                                                              index]
                                                                          .issueSizeWithText!);
                                                                },
                                                                child: Icon(
                                                                  CupertinoIcons
                                                                      .info,
                                                                  size: 16,
                                                                  color: themeModeLight
                                                                      ? appPrimeColor
                                                                      : Colors
                                                                          .blue,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              )
                                                            ],
                                                          ),
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
                                                                          subTitleTextColor,
                                                                      fontSize:
                                                                          subTitleFontSize,
                                                                      height:
                                                                          1.5),
                                                                ),
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Visibility(
                                                          visible:
                                                              buttonVisibleFun(
                                                                  filterdatalist[
                                                                      index]),
                                                          child: SizedBox(
                                                              width: 100,
                                                              child:
                                                                  MaterialButton(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              5),
                                                                      elevation:
                                                                          2,
                                                                      disabledColor:
                                                                          Colors
                                                                              .grey,
                                                                      disabledTextColor:
                                                                          Colors
                                                                              .white70,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(18),
                                                                      ),
                                                                      color: buttonColorFunc(
                                                                          filterdatalist[
                                                                              index]),
                                                                      onPressed: disabelButtonFun(filterdatalist[
                                                                              index])
                                                                          ? null
                                                                          : () {
                                                                              onCategorySubmit(filterdatalist[index]);
                                                                            },
                                                                      child:
                                                                          Text(
                                                                        filterdatalist[index]
                                                                            .buttonText!,
                                                                        maxLines:
                                                                            1,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            color: (filterdatalist[index].actionFlag == 'M' || filterdatalist[index].actionFlag == 'U' || filterdatalist[index].actionFlag == 'CL') && filterdatalist[index].disableActionBtn == false
                                                                                ? appPrimeColor
                                                                                : Colors.white),
                                                                      ))),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        '\u20B9${filterdatalist[index].minPrice} - \u20B9${filterdatalist[index].cutOffPrice}',
                                                        style: themeModeLight
                                                            ? ThemeClass
                                                                .lighttheme
                                                                .textTheme
                                                                .bodyMedium
                                                            : ThemeClass
                                                                .Darktheme
                                                                .textTheme
                                                                .bodyMedium),
                                                    FittedBox(
                                                      child: Text(
                                                          filterdatalist[index]
                                                              .dateRange!,
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
                                          return Visibility(
                                            visible: widget
                                                    .ipoMasterDetailsData!
                                                    .disclaimer
                                                    .isNotEmpty ||
                                                widget.ipoMasterDetailsData!
                                                        .disclaimer !=
                                                    null,
                                            child: Column(
                                              children: [
                                                const SizedBox(
                                                  height: 30.0,
                                                ),
                                                BulletList(widget
                                                    .ipoMasterDetailsData!
                                                    .disclaimer)
                                              ],
                                            ),
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

  void showCategoryBottomSheet(
      IpoDetail ipoDetail, List<CategoryList> ipoCategoryData) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: ipoCategoryData
                .map((e) => InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onSubmit(ipoDetail, e);
                      },
                      child: Container(
                        width: 80,
                        height: 70,
                        margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Provider.of<NavigationProvider>(context)
                                          .themeMode ==
                                      ThemeMode.dark
                                  ? const Color.fromARGB(255, 230, 228, 228)
                                      .withOpacity(0.1)
                                  : Colors.grey.shade200.withOpacity(0.9),
                              offset: const Offset(
                                5.0,
                                5.0,
                              ),
                              blurRadius: 20.0,
                              spreadRadius: 10.0,
                            ), //BoxShadow
                            BoxShadow(
                              color: Provider.of<NavigationProvider>(context)
                                          .themeMode ==
                                      ThemeMode.dark
                                  ? const Color.fromRGBO(48, 48, 48, 1)
                                  : Colors.white,
                              offset: const Offset(
                                0.0,
                                0.0,
                              ),
                              blurRadius: 0.0,
                              spreadRadius: 5.0,
                            ), //BoxShadow
                          ],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                                visible: e.purchaseFlag == 'Y' ||
                                    (e.subCategoryFound == 'Y' &&
                                        e.subCategoryList![0].purchaseFlag ==
                                            "Y"),
                                child: Image.asset(
                                  'assets/Applied.png',
                                  width: 15,
                                )),
                            Center(
                              child: e.code == 'IND'
                                  ? Image.asset(
                                      'assets/Ind.png',
                                      width: 20,
                                    )
                                  : e.code == 'EMP'
                                      ? Image.asset(
                                          'assets/Employee New.png',
                                          width: 20,
                                        )
                                      : e.code == 'SHA'
                                          ? Image.asset(
                                              'assets/Share Holder.png',
                                              width: 23,
                                            )
                                          : const Icon(Icons.person),
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            Center(
                              child: Text(
                                e.code == 'IND' &&
                                        (e.subCategoryFound == 'Y' &&
                                            e.subCategoryList![0]
                                                    .purchaseFlag ==
                                                "Y")
                                    ? 'HNI'
                                    : e.code == 'IND' &&
                                            !(e.subCategoryFound == 'Y' &&
                                                e.subCategoryList![0]
                                                        .purchaseFlag ==
                                                    "Y")
                                        ? 'Individual'
                                        : e.code == 'EMP'
                                            ? 'Employee'
                                            : e.code == 'SHA'
                                                ? 'Shareholder'
                                                // :
                                                // (e.subCategoryFound == 'Y' &&
                                                //         e.subCategoryList![0]
                                                //                 .purchaseFlag ==
                                                //             "Y")
                                                //     ? 'HNI'
                                                : '',
                                softWrap: true,
                                maxLines: 4,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    fontFamily: 'Kiro'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
