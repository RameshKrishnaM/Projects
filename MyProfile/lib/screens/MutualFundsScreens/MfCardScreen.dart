// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novo/Provider/change_index.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/colors.dart';
import 'package:novo/widgets/MF%20Widgets/Mf_Button_Widget.dart';
import 'package:novo/widgets/MF%20Widgets/MfOrderStatusAlertBox.dart';
import 'package:novo/widgets/MF%20Widgets/mfcustomListTile.dart';
import 'package:novo/widgets/MF%20Widgets/Mf_Bottom_Sheet_Widgets/mfcustomPaymentBS.dart';
import 'package:novo/widgets/MF%20Widgets/mfcustomRichText.dart';
import 'package:novo/widgets/MF%20Widgets/mfcustomSearchField.dart';
import 'package:novo/widgets/NOVO%20Widgets/customLoadingAni.dart';
import 'package:novo/widgets/NOVO%20Widgets/custom_NodataWidget.dart';
import 'package:novo/widgets/NOVO%20Widgets/custom_alertDialog.dart';
import 'package:novo/widgets/NOVO%20Widgets/loadingDailogwithCircle.dart';
import 'package:novo/widgets/NOVO%20Widgets/netWorkConnectionAlertBox.dart';
import 'package:novo/widgets/NOVO%20Widgets/snackbar.dart';
import 'package:provider/provider.dart';
import '../../API/MFAPICall.dart';
import '../../model/mfModels/Mf_cart_data.dart';
import '../../utils/Themes/theme.dart';
import '../../widgets/MF Widgets/mfCustomAlertBox.dart';
import '../../widgets/NOVO Widgets/Currently_unavailable.dart';
import '../../widgets/NOVO Widgets/infoContainer.dart';

class MFcardScreen extends StatefulWidget {
  const MFcardScreen({super.key});

  @override
  State<MFcardScreen> createState() => _MFcardScreenState();
}

class _MFcardScreenState extends State<MFcardScreen> {
  TextEditingController searchController = TextEditingController();
  final ScrollController _mfCartScontroller = ScrollController();
  final ScrollController _mfCartScontroller1 = ScrollController();
  List<Map<String, dynamic>> newInvestedButtonList = [];
  MfCartData? mfCartData;
  bool isLoading = true;
  bool riskshow = false;
  num totalAmount = 0;
  int cardCount = 0;
  int totalCardCount = 0;
  num totalCartAmount = 0;
  int rowsPerPage = 100;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    getCartDetails(context);
  }

  deleteCart({required int id, context}) async {
    // loadingDailogWithCircle(context);
    Map cardDetails = {
      "id": id,
      "cartStatus": "N",
    };
    var response = await fetchMfCartUpdationAPI(
        context: context, cartDetails: cardDetails);
    if (response != null) {
      Navigator.pop(context);
      // Navigator.pop(context);
      mfOrderStatusAlartBox(
          context: context,
          message: response["status"] == "S"
              ? "Item deleted successfully"
              : "Failed to delete",
          status: response["status"],
          completeImg: 'assets/Completed.png',
          errorImg: 'assets/Error.png',
          transactionMsg: response['transactionMsg'] ?? '');
      if (response["status"] == "S") {
        Provider.of<NavigationProvider>(context, listen: false)
            .getmfCartcountAPI(context);
        Provider.of<NavigationProvider>(context, listen: false)
            .getmfmasterschemeApi(context);
      }
      getCartDetails(context);
    } else {
      Navigator.pop(context);
    }
  }

  getCartDetails(context) async {
    if (await isInternetConnected()) {
      mfCartData = await fetchMfCartDetailsAPI(context);
      if (mfCartData != null) {
        filterdatalist = mfCartData!.mfCartDataArr!;
        Provider.of<NavigationProvider>(context, listen: false)
            .getmfCartcountAPI(context);
        calculateTotalAmount();
      } else {
        filterdatalist = [];
      }

      isLoading = false;
      setState(() {});
    } else {
      noInternetConnectAlertDialog(context, () => getCartDetails(context));
    }
  }

  calculateTotalAmount() {
    totalAmount = 0;
    cardCount = 0;
    if (mfCartData!.mfCartDataArr!.isNotEmpty) {
      for (var element in mfCartData!.mfCartDataArr!) {
        if (element.isChecked!) {
          totalAmount = totalAmount + element.orderValue!;
          cardCount++;
        }
      }
      totalCartAmount = mfCartData!.mfCartDataArr!
          .map((element) => element.orderValue!)
          .reduce((a, b) => a + b);
    }

    setState(() {});
  }

  buysingleCart(context) async {
    Map<String, dynamic> singlePurMap = {};
    for (MfCartDataArr mfCartDatum
        in mfCartData == null ? [] : mfCartData!.mfCartDataArr!) {
      if (mfCartDatum.isChecked!) {
        singlePurMap = {
          "isin": mfCartDatum.isin,
          "OrderVal": mfCartDatum.orderValue,
          "BuySell": "P",
          "BuySellType": "FRESH",
          "Qty": 0,
          "navValue": double.parse(mfCartDatum.navValue!),
        };
        loadingDailogWithCircle(context);
        var response = await postPurchaseOrderAPI(
            context: context, purchaseDetails: singlePurMap);
        Navigator.pop(context);
        if (response != null) {
          mfOrderStatusAlartBox(
              context: context,
              message: response["status"] == "E"
                  ? "Order Failed!"
                  : response['respStatusMsg'],
              status: response["status"],
              completeImg: 'assets/Completed.png',
              errorImg: 'assets/Error.png',
              ftTransactionCode: response["transactioncode"],
              bscOrderNo: response["bseorderno"],
              transactionMsg: response['transactionMsg']);
        } else {}
      } else {}
    }
  }

  buyAllCart(context) async {
    loadingDailogWithCircle(context);
    List cartPurArr = [];
    List cartIdArr = [];
    for (MfCartDataArr mfCartDatum
        in mfCartData == null ? [] : mfCartData!.mfCartDataArr!) {
      if (mfCartDatum.isChecked!) {
        cartPurArr.add({
          "isin": mfCartDatum.isin,
          "OrderVal": mfCartDatum.orderValue,
          "BuySell": "P",
          "Qty": 0,
        });
        // mfCartDatum.toJson()

        cartIdArr.add(mfCartDatum.id);
      }
    }

    var response = await mfbuyAllCartDataAPI(
        context: context,
        cartDetails: {"cartBuyReq": cartPurArr, 'recordIdArr': cartIdArr});
    Navigator.pop(context);
    if (response != null) {
      print("lkjsl;kdfgjlkdsjflkjds");
      print(response);
      if (response["cartErrorPurRec"] == null) {
        mfOrderStatusAlartBox(
            context: context,
            message: response['respStatusMsg'],
            status: "S",
            completeImg: 'assets/Completed.png',
            errorImg: 'assets/Error.png',
            transactionMsg: response['transactionMsg']);
      } else {
        List cartSuccessArr = (response["cartSuccessPurRec"] ?? [])
            .map((value) => {"status": "S", ...value as Map})
            .toList();

        cartSuccessArr.addAll((response["cartErrorPurRec"] ?? [])
            .map((value) => {"status": "E", ...value as Map}));

        customMfAlertBox(
            context: context,
            type: 'cartStatus',
            title: 'ORDER DETAILS',
            contentWidget: Scrollbar(
              thumbVisibility: true,
              controller: _mfCartScontroller1,
              child: ListView.builder(
                controller: _mfCartScontroller1,
                shrinkWrap: true,
                itemCount: cartSuccessArr.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4, right: 8),
                    child: MFCustomListTile(
                      showImage: false,
                      imageUrl: '',
                      title: cartSuccessArr[index]['schemeName'],
                      subtitle3: Padding(
                        padding: const EdgeInsets.only(top: 5.0, left: 10),
                        child: Text(
                          textAlign: TextAlign.end,
                          rsFormat.format(cartSuccessArr[index]['orderValue']),
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width > 360
                                            ? 17
                                            : 14,
                                  ),
                        ),
                      ),
                      // tailingWidgetWidth: 100,
                      // tailingWidget: Text(
                      //     '${rsFormat.format(cartSuccessArr[index]['orderValue'])}'),
                      subtitl1: Visibility(
                        visible: cartSuccessArr[index]['transactionNumber']
                            .isNotEmpty,
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(
                                text: cartSuccessArr[index]
                                    ['transactionNumber']));
                            appExit(context, 'Text copied');
                          },
                          child: FittedBox(
                            child: Container(
                              margin: const EdgeInsets.only(right: 10, top: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? modifyButtonColor.withOpacity(0.2)
                                      : modifyButtonColor.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ref : ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontSize: 11,
                                          )),
                                  Text(
                                      cartSuccessArr[index]
                                          ['transactionNumber'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
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
                      // Text(cartSuccessArr[index]['transactionNumber']),
                      subtitle2: Container(
                          margin: const EdgeInsets.only(right: 5, top: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 4),
                          decoration: BoxDecoration(
                              color: cartSuccessArr[index]['status'] == 'S'
                                  ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? primaryGreenColor.withOpacity(0.3)
                                      : primaryGreenColor.withOpacity(0.1)
                                  : cartSuccessArr[index]['status'] == 'E'
                                      ? Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? primaryRedColor.withOpacity(0.3)
                                          : primaryRedColor.withOpacity(0.1)
                                      : Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? inactiveColor.withOpacity(0.7)
                                          : subTitleTextColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            cartSuccessArr[index]['status'] == 'S'
                                ? 'Success'
                                : 'Failed',
                            textAlign: TextAlign.center,
                            style: ThemeClass.lighttheme.textTheme.bodySmall!
                                .copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: cartSuccessArr[index]['status'] ==
                                            "S"
                                        ? primaryGreenColor
                                        : cartSuccessArr[index]['status'] == 'E'
                                            ? primaryRedColor
                                            : titleTextColorLight),
                          )),
                    ),
                  );
                  // Text(cartSuccessArr[index]['status'] == 'S'
                  //     ? 'Success'
                  //     : 'Failed'))

                  // ListTile(
                  //   title: Text(cartSuccessArr[index]['schemeName']),
                  // )
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     // Text(cartStatusArr[index]['schemeName']),
                  //     Text("cartStatusArr[index]['schemeName']"),
                  //     Text('Success')
                  //   ],
                  // )
                },
              ),
            ),
            func1: {});
        // showSnackbar(
        //   context,
        //   "${response["cartSuccessPurRec"] == null || response["cartSuccessPurRec"].isEmpty ? 0 : response["cartSuccessPurRec"].length} cart payment Sucess ${response["cartErrorPurRec"] == null || response["cartErrorPurRec"].isEmpty ? 0 : response["cartErrorPurRec"].length} cart payment Failed",
        //   Theme.of(context).brightness == Brightness.dark
        //       ? titleTextColorDark
        //       : titleTextColorLight,
        //   textColor: Theme.of(context).brightness == Brightness.dark
        //       ? titleTextColorLight
        //       : titleTextColorDark,
        // );
      }

      getCartDetails(context);
    } else {}
  }

  String searchtext = '';
  List<MfCartDataArr> filterdatalist = [];
  void searchdata(String value) {
    searchtext = value;
    if (searchtext.isEmpty) {
      filterdatalist = mfCartData!.mfCartDataArr!;
    } else {
      filterdatalist = mfCartData!.mfCartDataArr!
          .where((data) => data.schemeName
              .toString()
              .toLowerCase()
              .contains(searchtext.toLowerCase()))
          .toList();
    }
    if (filterdatalist.isEmpty) {}
    currentPage = 1; // Reset current page to 1

    setState(() {});
  }

  void _handleTap(int index) {
    setState(() {
      // for (int i = 0; i < filterdatalist.length; i++) {
      //   filterdatalist[i].isChecked =
      //       (i == index) ? !filterdatalist[i].isChecked! : false;
      // }
      filterdatalist[index].isChecked = !filterdatalist[index].isChecked!;
    });
    calculateTotalAmount();
  }

  bool isAnyChecked() {
    return filterdatalist.any((element) => element.isChecked!);
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (filterdatalist.length / rowsPerPage).ceil();

    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex =
        (currentPage * rowsPerPage).clamp(0, filterdatalist.length);

    final pageItems = rowsPerPage == -1
        ? filterdatalist
        : filterdatalist.sublist(startIndex.clamp(0, filterdatalist.length),
            endIndex.clamp(0, filterdatalist.length));
    return isLoading
        ? const LoadingProgress()
        : mfCartData == null
            ? Center(child: CurrentlyUnavailableWidget(
                refressFunc: () async {
                  print('ldld');
                  await getCartDetails(context);
                },
              ))
            : mfCartData!.mfCartDataArr!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        cartNotFoundWidget(context),
                        const SizedBox(
                          height: 15,
                        ),
                        CustomButton(
                            isSmall: true,
                            buttonWidget: const Text(
                              'EXPLORE FUNDS',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTapFunc: () {
                              MFChangeIndex().value = 0;
                            })
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: totalCartAmount > 0 &&
                              mfCartData!.mfCartDataArr!.isNotEmpty,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(rsFormat.format(totalCartAmount),
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              Text(
                                'Total Cart Value',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: mfCartData!.mfCartDataArr!.isNotEmpty,
                          child: MfCustomSearchField(
                              onChange: searchdata,
                              titleText: 'My Cart',
                              hintText: 'Search...',
                              searchController: searchController),
                        ),
                        Visibility(
                          visible: mfCartData!.mfCartDataArr!.isNotEmpty &&
                              mfCartData!.bulkpurchase != 'Y',
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InfoContainer(
                              infoMsg: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.info,
                                    size: 15,
                                    color: appPrimeColor,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Text(
                                      mfCartData!.mfDisclosureMessage!,
                                      overflow: TextOverflow.visible,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(color: titleTextColorLight),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        filterdatalist.isEmpty
                            ? noDataFoundWidget(context)
                            : Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    getCartDetails(context);
                                  },
                                  child: Scrollbar(
                                    controller: _mfCartScontroller,
                                    child: ListView.separated(
                                      controller: _mfCartScontroller,
                                      itemCount: pageItems.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index < pageItems.length) {
                                          var jsonData = pageItems[index];
                                          return InkWell(
                                            onTap: () async {
                                              mfCartData!.bulkpurchase == 'Y'
                                                  ? _handleTap(index)
                                                  : mfInvestBottomSheet(
                                                      context: context,
                                                      isin: jsonData.isin!,
                                                      type: 'delete',
                                                      amount:
                                                          jsonData.orderValue,
                                                      id: jsonData.id,
                                                      func: () =>
                                                          getCartDetails(
                                                              context));

                                              setState(() {});
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        MFCustomListTile(
                                                          imageUrl:
                                                              jsonData.theme!,
                                                          title: jsonData
                                                              .schemeName!,
                                                          titlepadding: 25,
                                                          subtitl1: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5,
                                                                    vertical:
                                                                        2),
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            1,
                                                                        color: subTitleTextColor.withOpacity(
                                                                            0.2)),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                child: Text(
                                                                    jsonData
                                                                        .schemeType!,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: Theme.of(
                                                                            context)
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
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'Pledgeable Info',
                                                                            contentWidget:
                                                                                Text(Provider.of<NavigationProvider>(context, listen: false).pledgeableInfo),
                                                                            func1: () {}),
                                                                        child:
                                                                            RichTextWidget(
                                                                          alignRight:
                                                                              MainAxisAlignment.start,
                                                                          firstWidget:
                                                                              Container(
                                                                            padding:
                                                                                const EdgeInsets.only(right: 3, left: 0),
                                                                            child:
                                                                                Image.asset(
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
                                                          subtitle2: Text(
                                                              // '₹${doubleformatAmount(jsonData.orderValue ?? 0)}',
                                                              rsFormat.format(
                                                                  jsonData
                                                                      .orderValue),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        17,
                                                                  )),
                                                        ),
                                                        Positioned(
                                                          right: 0,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    // left: 7,
                                                                    right: 5,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            child: InkWell(
                                                                onTap: () {
                                                                  customAlertBox(
                                                                      context:
                                                                          context,
                                                                      content:
                                                                          "Confirm to delete this item?",
                                                                      func1:
                                                                          () {
                                                                        deleteCart(
                                                                            id: jsonData
                                                                                .id!,
                                                                            context:
                                                                                context);
                                                                      });
                                                                },
                                                                child: Icon(
                                                                  Icons
                                                                      .close_rounded,
                                                                  size: 16.0,
                                                                  color:
                                                                      primaryRedColor,
                                                                )),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: jsonData
                                                              .isChecked!,
                                                          child: Positioned(
                                                              left: 5,
                                                              top: 1,
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height: 15,
                                                                width: 15,
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        primaryGreenColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Icon(
                                                                  Icons.done,
                                                                  color:
                                                                      titleTextColorDark,
                                                                  size: 12,
                                                                ),
                                                              )

                                                              //  Icon(
                                                              //   Icons
                                                              //       .cirlce,
                                                              //   color:
                                                              //       primaryGreenColor,
                                                              //   size: 17,
                                                              // )

                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return totalPages > 0 &&
                                                  totalPages < 2
                                              ? const SizedBox()
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: appPrimeColor,
                                                          border: Border.all(
                                                              color:
                                                                  titleTextColorDark),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          8),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          8))),
                                                      width: 35,
                                                      height: 35,
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            if (currentPage >
                                                                1) {
                                                              if (_mfCartScontroller
                                                                  .hasClients) {
                                                                _mfCartScontroller
                                                                    .animateTo(
                                                                  0.0,
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          300),
                                                                  curve: Curves
                                                                      .easeOut,
                                                                );
                                                                currentPage--;
                                                              }
                                                            }
                                                          });
                                                        },
                                                        child: Icon(
                                                          Icons
                                                              .arrow_back_ios_new_outlined,
                                                          size: 14,
                                                          color:
                                                              titleTextColorDark,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: appPrimeColor,
                                                        border: Border.symmetric(
                                                            horizontal: BorderSide(
                                                                color:
                                                                    titleTextColorDark)),
                                                      ),
                                                      width: 100,
                                                      height: 35,
                                                      child: Text(
                                                        '$currentPage - $totalPages of $rowsPerPage',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                color:
                                                                    titleTextColorDark),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 35,
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                          color: appPrimeColor,
                                                          border: Border.all(
                                                              color:
                                                                  titleTextColorDark),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          8),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                          8))),
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            if (currentPage <
                                                                totalPages) {
                                                              if (_mfCartScontroller
                                                                  .hasClients) {
                                                                _mfCartScontroller
                                                                    .animateTo(
                                                                  0.0,
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          300),
                                                                  curve: Curves
                                                                      .easeOut,
                                                                );
                                                                currentPage++;
                                                              }
                                                            }
                                                          });
                                                        },
                                                        child: Icon(
                                                          Icons
                                                              .arrow_forward_ios_rounded,
                                                          size: 14,
                                                          color:
                                                              titleTextColorDark,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                        }
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(
                                        height: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        Visibility(
                          visible: filterdatalist.isNotEmpty &&
                              mfCartData!.bulkpurchase == 'Y',
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: modifyButtonColor.withOpacity(0.8)),
                            // height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Expanded(
                                //   child: RichText(
                                //       textAlign: TextAlign.right,
                                //       text: TextSpan(children: [
                                //         TextSpan(
                                //             text:
                                //                 "The total payable amount for cart ",
                                //             style: Theme.of(context)
                                //                 .textTheme
                                //                 .bodyMedium!
                                //                 .copyWith(
                                //                     color: titleTextColorLight,
                                //                     fontWeight:
                                //                         FontWeight.w600)),
                                //         TextSpan(
                                //             text: "($cardCount) ",
                                //             style: Theme.of(context)
                                //                 .textTheme
                                //                 .bodyMedium!
                                //                 .copyWith(
                                //                     fontWeight: FontWeight.bold,
                                //                     color: primaryGreenColor)),
                                //         TextSpan(
                                //             text: "is\n",
                                //             style: Theme.of(context)
                                //                 .textTheme
                                //                 .bodyMedium!
                                //                 .copyWith(
                                //                     color: titleTextColorLight,
                                //                     fontWeight:
                                //                         FontWeight.w600)),
                                //         TextSpan(
                                //             text:
                                //                 "${rsFormat.format(totalAmount)} ",
                                //             style: Theme.of(context)
                                //                 .textTheme
                                //                 .titleMedium!
                                //                 .copyWith(
                                //                     color: primaryGreenColor)),
                                //       ])),
                                // ),
                                // const SizedBox(width: 10.0),
                                // Text('The Total Transaction is \n 12,00,000'),
                                SizedBox(
                                  height: 35,
                                  width: 130,
                                  child: CustomButton(
                                      backgroundColor: isAnyChecked()
                                          ? appPrimeColor
                                          : inactiveColor,
                                      buttonWidget: Text(
                                        'Buy Now',
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: isAnyChecked()
                                                ? titleTextColorDark
                                                : titleTextColorLight
                                                    .withOpacity(0.5)),
                                      ),
                                      onTapFunc: () {
                                        // MfSuccessAlartBox(
                                        //     context, 'Order Placed Succesfully', "S");
                                        // buyAllCart(context);

                                        isAnyChecked()
                                            ? buyAllCart(context)
                                            // buysingleCart(context)
                                            : null;
                                      }),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  );
  }
}
