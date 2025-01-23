import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novo/Provider/change_index.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/mfModels/mfpurchaseConfigDetails.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/utils/colors.dart';
import 'package:novo/widgets/MF%20Widgets/Mf_Button_Widget.dart';
import 'package:novo/widgets/NOVO%20Widgets/infoContainer.dart';
import 'package:novo/widgets/NOVO%20Widgets/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../API/MFAPICall.dart';
import '../../NOVO Widgets/loadingDailogwithCircle.dart';
import '../../NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../NOVO Widgets/validationformat.dart';
import '../mfcustomvisibelSnackbar.dart';
import 'MfBuyFormField.dart';
import '../TextInBottomSheet.dart';
import '../MfOrderStatusAlertBox.dart';
import '../mfCustomAlertBox.dart';
import '../imagedecoderWidget.dart';

class CustomBuyMF extends StatefulWidget {
  final String isin;
  final num? amount;
  final int? id;
  final String type;
  final dynamic func;

  const CustomBuyMF(
      {super.key,
      required this.isin,
      this.amount,
      this.id,
      required this.type,
      this.func});

  @override
  State<CustomBuyMF> createState() => _CustomBuyMFState();
}

class _CustomBuyMFState extends State<CustomBuyMF> {
  bool isLoading = true;
  bool buttonEnable = true;
  // bool showSipSnackBar = false;
  bool showCopyTextSnackBar = false;
  String showsnackText = '';
  MFpurchaseConfigDetails? purchaseConfigDetails;
  final _formKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController navController = TextEditingController();
  String snackBarContent = "";
  String snackBarStatus = "S";
  String disclaimer = '';
  String navDate = '';
  String showText = '';
  String successImage = '';
  String errorImage = '';
  num? maxRedeemQty;

  @override
  void initState() {
    super.initState();
    getPurchaseConfig(context);
  }

  getPurchaseConfig(context) async {
    if (await isInternetConnected()) {
      var response = await fetchMFPurchaseConfigDetails(
          context: context,
          isin: widget.isin,
          type: widget.type == "redeem" ? "R" : "P");
      print(response);

      if (response is MFpurchaseConfigDetails) {
        purchaseConfigDetails = response;

        isLoading = false;
        amountController.text =
            "${widget.amount is double ? widget.amount?.floor() : widget.amount ?? purchaseConfigDetails?.initialValue ?? ""}";
        navController.text =
            purchaseConfigDetails?.mfSchemeMaster?.navValue ?? "";
        disclaimer = purchaseConfigDetails?.mfDisclaimerMessage ?? '';
        navDate =
            purchaseConfigDetails?.mfSchemeMaster?.navdate.toString() ?? "";
        // num maxRedeemQtyvalue =

        // // (num.parse(amountController.text) /
        // //     num.parse(purchaseConfigDetails?.mfSchemeMaster?.navValue ?? "1"));
        String? formattedMaxRedeemQty =
            purchaseConfigDetails?.mfHoldingsRec?.freeBalQty;

// // If you need it as a double again
        maxRedeemQty = num.parse(formattedMaxRedeemQty ?? '0');

        // maxRedeemQty = purchaseConfigDetails?.mfHoldingsRec?.freeBalQty;
        calculateEstQty(amountController.text);
        if (mounted) {
          setState(() {});
        }
      } else {
        Navigator.pop(context);
      }
    } else {
      noInternetConnectAlertDialog(context, () => getPurchaseConfig(context));
    }
  }

  order({required String purchaseType, context}) async {
    if (await isInternetConnected()) {
      try {
        if (!_formKey.currentState!.validate()) {
          return;
        }
        if (qtyController.text.trim().isEmpty ||
            qtyController.text.trim() == "0") {
          snackBarContent = "Invalid Qty";
          snackBarStatus = "E";
          // showSipSnackBar = true;
          setState(() {});
          await Future.delayed(const Duration(seconds: 3));
          // showSipSnackBar = false;
          setState(() {});
          return;
        }
        Map orderDetails;
        if (purchaseType == "buy") {
          orderDetails = {
            "isin": purchaseConfigDetails?.mfSchemeMaster?.isin ?? "",
            "OrderVal": double.tryParse(amountController.text) ?? 0,
            "BuySell": "P",
            "BuySellType": "FRESH",
            "Qty": 0,
            "navValue": double.tryParse(navController.text) ?? 0,
          };
        } else if (purchaseType == "redeem") {
          orderDetails = {
            "isin": purchaseConfigDetails?.mfSchemeMaster?.isin ?? "",
            "OrderVal": 0,
            "BuySell": "R",
            "Qty": double.tryParse(qtyController.text) ?? 0,
            "navValue": double.tryParse(navController.text) ?? 0,
          };
        } else if (purchaseType == "cartbuy") {
          orderDetails = {
            "isin": purchaseConfigDetails?.mfSchemeMaster?.isin ?? "",
            "OrderVal": double.tryParse(amountController.text) ?? 0,
            "BuySell": "P",
            "BuySellType": "FRESH",
            "Qty": 0,
            "navValue": double.tryParse(navController.text) ?? 0,
          };
        } else if (purchaseType == 'ExistBuy') {
          orderDetails = {
            "isin": purchaseConfigDetails?.mfSchemeMaster?.isin ?? "",
            "OrderVal": double.tryParse(amountController.text) ?? 0,
            "BuySell": "P",
            "BuySellType": "FRESH",
            "Qty": 0,
            "navValue": double.tryParse(navController.text) ?? 0,
          };
        } else {
          orderDetails = {};
        }
        loadingDailogWithCircle(context);

        var response = await postPurchaseOrderAPI(
            context: context, purchaseDetails: orderDetails);
        print('00000000000000000000');
        print(response);
        print(widget.id);

        if (response != null) {
          Navigator.pop(context);
          Navigator.pop(context);
          if (response["status"] == 'S' && purchaseType == 'cartbuy') {
            Map cardDetails = {
              "cartStatus": "N",
              "isin": purchaseConfigDetails?.mfSchemeMaster?.isin ?? "",
              "orderValue": double.tryParse(amountController.text) ?? 0
            };
            cardDetails.addAll(widget.id != null ? {"id": widget.id} : {});
            var response = await fetchMfCartUpdationAPI(
                context: context, cartDetails: cardDetails);
            print("response['status']==================");
            print(response['status']);
          }
          mfOrderStatusAlartBox(
              context: context,
              message: response["status"] == "F"
                  ? "Order Failed!"
                  : response["status"] == "E"
                      ? response["networkErr"]
                      : purchaseType == "redeem"
                          ? response['respStatusMsg']
                          : response['respStatusMsg'],
              status: response["status"],
              completeImg: 'assets/Completed.png',
              errorImg: 'assets/Error.png',
              ftTransactionCode: response["transactioncode"],
              bscOrderNo: response["bseorderno"],
              transactionMsg: response['transactionMsg'],
              furtherSteps: response['furtherSteps'] ?? '',
              orderPlacedResp: response['orderPlacedResp'],
              purchaseType: purchaseType,
              sympolImage: purchaseConfigDetails?.mfSchemeMaster?.icon ?? "");
        } else {
          Navigator.pop(context);
        }
      } catch (e) {
        print('Internet Errro: $e');
        print(e);
      }
    } else {
      noInternetConnectAlertDialog(
          context, () => order(purchaseType: purchaseType, context: context));
    }
  }

  responseAlertboxDetails(
      {required String responseStatus,
      required String responseText,
      required String type}) {
    if (type == 'InsertCart') {
      if (responseStatus == "S") {
        if (widget.type == "delete") {
          showText = "Cart Saved Sucessfully";
          successImage = 'assets/Save.png';
        } else {
          if (responseText == '') {
            showText = 'Added To Cart';
            successImage = Theme.of(context).brightness == Brightness.dark
                ? 'assets/CartAddSuccess.png'
                : 'assets/CartAddSuccess_W.png';
          } else {
            showText = responseText;
            successImage = Theme.of(context).brightness == Brightness.dark
                ? 'assets/Error_B.png'
                : 'assets/Error.png';
          }
        }
      } else if (responseStatus == "E") {
        if (responseText == '') {
          showText = 'Cart Addition Failed!';
          successImage = Theme.of(context).brightness == Brightness.dark
              ? 'assets/CartAddSuccess.png'
              : 'assets/CartAddSuccess_W.png';
        } else {
          showText = responseText;
          successImage = Theme.of(context).brightness == Brightness.dark
              ? 'assets/Error_B.png'
              : 'assets/Error.png';
        }

        errorImage = Theme.of(context).brightness == Brightness.dark
            ? 'assets/Error_B.png'
            : 'assets/Error.png';
      } else {
        showText = '';
        errorImage = Theme.of(context).brightness == Brightness.dark
            ? 'assets/Error_B.png'
            : 'assets/Error.png';
      }
    } else {
      showText = '';
      errorImage = Theme.of(context).brightness == Brightness.dark
          ? 'assets/Error.png'
          : 'assets/Error_B.png';
    }
  }

  String cartText = 'Add to cart';
  bool cartAdded = false;
  Color bgcolor = appPrimeColor;

  insertCart(
      {required String amount, required String cartType, context}) async {
    if (await isInternetConnected()) {
      try {
        if (!_formKey.currentState!.validate()) {
          return;
        }
        if (qtyController.text.trim().isEmpty ||
            qtyController.text.trim() == "0") {
          snackBarContent = "Invalid Qty";
          snackBarStatus = "E";
          // showSipSnackBar = true;
          setState(() {});
          await Future.delayed(const Duration(seconds: 3));
          // showSipSnackBar = false;
          setState(() {});
          return;
        }
        loadingDailogWithCircle(context);
        Map cardDetails = {
          "cartStatus": "Y",
          "isin": purchaseConfigDetails?.mfSchemeMaster?.isin ?? "",
          "orderValue": double.tryParse(amount) ?? 0
        };
        cardDetails.addAll(widget.id != null ? {"id": widget.id} : {});
        var response = await fetchMfCartUpdationAPI(
            context: context, cartDetails: cardDetails);

        if (response != null) {
          if (response['status'] == 'S') {
            Navigator.pop(context);

            Provider.of<NavigationProvider>(context, listen: false)
                .getmfCartcountAPI(context);
            Provider.of<NavigationProvider>(context, listen: false)
                .getmfmasterschemeApi(context);
            if (cartType == 'saveCart') {
              showSnackbar(
                  context, 'Cart Saved Successfully', primaryGreenColor);
              Navigator.pop(context);
            } else {
              cartText = 'Go to cart';
              cartAdded = true;
              showCopyTextSnackBar = true;
              showsnackText = 'Fund Added to Cart';
              bgcolor = primaryGreenColor;
            }

            if (mounted) {
              setState(() {});
            }

            await Future.delayed(const Duration(seconds: 3));

            showCopyTextSnackBar = false;
            if (mounted) {
              setState(() {});
            }
          } else {
            Navigator.pop(context);

            cartText = 'Add to cart';
            cartAdded = false;
            showCopyTextSnackBar = true;
            bgcolor = primaryOrangeColor;

            showsnackText = response['cartcheck'];
            // Navigator.pop(context);

            if (mounted) {
              setState(() {});
            }

            await Future.delayed(const Duration(seconds: 3));

            showCopyTextSnackBar = false;
            if (mounted) {
              setState(() {});
            }

            // Navigator.pop(context);
            // responseAlertboxDetails(
            //     responseStatus: response["status"],
            //     responseText: response["cartcheck"],
            //     type: "InsertCart");
          }
          // mfOrderStatusAlartBox(
          //   context: context,
          //   message: showText,
          //   status: response["status"],
          //   completeImg: successImage,
          //   errorImg: errorImage,
          // );
        } else {
          showCopyTextSnackBar = true;

          showsnackText = 'Something Wrong';
          if (mounted) {
            setState(() {});
          }

          await Future.delayed(const Duration(seconds: 3));

          showCopyTextSnackBar = false;
          if (mounted) {
            setState(() {});
          }
          Navigator.pop(context);
          // Navigator.pop(context);
        }
      } catch (e) {
        print(e);
      }
    } else {
      noInternetConnectAlertDialog(
          context,
          () =>
              insertCart(amount: amount, cartType: cartType, context: context));
    }
  }

  calculateEstQty(value) {
    try {
      value as String;
      if (value.isNotEmpty) {
        if (widget.type == 'redeem') {
          qtyController.text = maxRedeemQty.toString();

          // (num.parse(value) /
          //         num.parse(
          //             purchaseConfigDetails?.mfSchemeMaster?.navValue ?? "1"))
          //     .toStringAsFixed(2);
        } else {
          qtyController.text = (num.parse(value) /
                  num.parse(
                      purchaseConfigDetails?.mfSchemeMaster?.navValue ?? "1"))
              .toStringAsFixed(2);
        }
        // qtyController.text = (num.parse(value) /
        //         num.parse(
        //             purchaseConfigDetails?.mfSchemeMaster?.navValue ?? "1"))
        //     .toStringAsFixed(2);
        // print("qtyController");
        // print(qtyController.text);
      } else {
        qtyController.text = "0.0";
      }
    } catch (e) {
      qtyController.text = "0.0";
    }
  }

  String? amountValidate(value) {
    if (value == null || value.isEmpty) {
      return 'amount required';
    } else {
      num amt = num.tryParse(value) ?? 0;
      num min = widget.type == 'redeem'
          ? 0
          : num.tryParse(
                  purchaseConfigDetails?.mfSchemeMaster?.minPurchaseAmt ??
                      "1") ??
              1;
      // num max = num.tryParse(
      //         purchaseConfigDetails?.mfSchemeMaster?.maxRedemQty ?? "1") ??
      //     1;
      if (amt < min) {
        return 'Minimum amount is ${min is double ? min.floor() : min}';
      }
      //  else if (widget.type == "redeem" && amt > (widget.amount ?? 0)) {
      //   print("widget.amount");
      //   print(widget.amount);
      //   return 'max amt ${widget.amount ?? 0}';
      // }
      return null;
    }
  }

  String? qtyValidate(value) {
    if (value == null || value.isEmpty) {
      return 'Units required';
    } else {
      num amt = num.tryParse(value) ?? 0;
      num min = num.tryParse(
              purchaseConfigDetails?.mfSchemeMaster?.minRedemQty ?? "1") ??
          1;

      // num max = (num.parse(value) /
      //     num.parse(purchaseConfigDetails?.mfSchemeMaster?.navValue ?? "1"));

      if (amt < min) {
        return 'Minimum Units is $min';
      } else if (widget.type == "redeem" && maxRedeemQty! < (amt)) {
        return 'Available Units is \n ${maxRedeemQty ?? 0}';
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<int> values = [];

    for (int i = 0;
        i < int.parse(purchaseConfigDetails?.incrementCount ?? "0");
        i++) {
      values.add(int.parse(purchaseConfigDetails?.initialValue ?? "0") +
          i * int.parse(purchaseConfigDetails?.incrementValue ?? "0"));
    }

    var darkThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;
    final loadingImg = purchaseConfigDetails?.mfSchemeMaster?.icon ?? "";

    if (purchaseConfigDetails != null &&
        purchaseConfigDetails!.status == "S" &&
        (purchaseConfigDetails?.mfSchemeMaster?.purchaseallowded != 'Y' ||
            purchaseConfigDetails?.mfSchemeMaster?.purchasetransmode != 'DP' ||
            purchaseConfigDetails?.mfSchemeMaster?.schemeplan != 'DIRECT')) {
      return Container(
        padding: const EdgeInsets.only(bottom: 25, top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      size: 22,
                    )),
                const SizedBox(
                  width: 20,
                )
              ],
            ),
            Image.asset(
              'assets/Error W.png',
              height: 100,
              width: 100,
            ),
            const SizedBox(
              height: 5,
            ),
            const Text('Purchase Not Allowed')
          ],
        ),
      );
    }
    if (purchaseConfigDetails != null &&
        purchaseConfigDetails!.status == "S" &&
        widget.type == 'redeem' &&
        (purchaseConfigDetails?.mfSchemeMaster?.redemAllowed != 'Y' ||
            purchaseConfigDetails?.mfSchemeMaster?.redeemtransmode != 'DP' ||
            purchaseConfigDetails?.mfSchemeMaster?.schemeplan != 'DIRECT')) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/Error W.png',
              height: 100,
              width: 100,
            ),
            const Text('Record Not Found')
          ],
        ),
      );
    }
    if (purchaseConfigDetails != null && purchaseConfigDetails!.status == "W") {
      return Padding(
          padding:
              const EdgeInsets.only(top: 10.0, bottom: 20, left: 20, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      color: primaryOrangeColor,
                      size: 33.0,
                    ),
                  ),
                  InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                      )),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              if ((purchaseConfigDetails?.ddpiMsg ?? "").isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      size: 18.0,
                      color: primaryRedColor.withOpacity(0.6),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text: purchaseConfigDetails?.ddpiMsg ?? "",
                          style: darkThemeMode
                              ? ThemeClass.Darktheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColorDark,
                                      fontSize: 12)
                              : ThemeClass.lighttheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColorLight,
                                      height: 1,
                                      fontSize: 12),
                        ),
                        WidgetSpan(
                            child: InkWell(
                          onTap: () {
                            launchUrlString(
                                purchaseConfigDetails?.ddpiLink ?? "");
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.only(
                                top: 2, bottom: 3, left: 5, right: 5),
                            decoration: BoxDecoration(
                                color: appPrimeColor,
                                // border: Border.all(
                                //     width: 1,
                                //     color:
                                //         subTitleTextColor
                                //             .withOpacity(
                                //                 0.2)),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text('click here',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: titleTextColorDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10)),
                          ),
                        )

                            //  " click here",
                            // style: ThemeClass.Darktheme.textTheme.bodyMedium!
                            //     .copyWith(color: appPrimeColor, fontSize: 12),
                            // recognizer: TapGestureRecognizer()
                            //   ..onTap = () {
                            //     launchUrlString(
                            //         purchaseConfigDetails?.fundLink ?? "");
                            //   }

                            )
                        // TextSpan(
                        //     text: " click here",
                        //     style: ThemeClass.Darktheme.textTheme.bodyMedium!
                        //         .copyWith(color: appPrimeColor, fontSize: 12),
                        //     recognizer: TapGestureRecognizer()
                        //       ..onTap = () {
                        //         launchUrlString(
                        //             purchaseConfigDetails?.ddpiLink ?? "");
                        //       })
                      ])),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
              ],
              if ((purchaseConfigDetails?.freeQtyMsg ?? "").isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      size: 18.0,
                      color: primaryRedColor.withOpacity(0.6),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text: purchaseConfigDetails?.freeQtyMsg ?? "",
                          style: darkThemeMode
                              ? ThemeClass.Darktheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColorDark,
                                      fontSize: 12)
                              : ThemeClass.lighttheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColorLight,
                                      fontSize: 12),
                        ),
                      ])),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
              ],
              if ((purchaseConfigDetails?.minimumQtyMsg ?? "").isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      size: 18.0,
                      color: primaryRedColor.withOpacity(0.6),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: Text.rich(
                          // softWrap: true,
                          // overflow: TextOverflow.visible,
                          TextSpan(children: [
                        TextSpan(
                          text: purchaseConfigDetails?.minimumQtyMsg ?? "",
                          style: darkThemeMode
                              ? ThemeClass.Darktheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColorDark,
                                      fontSize: 12)
                              : ThemeClass.lighttheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColorLight,
                                      fontSize: 12),
                        ),
                      ])),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
              ],
              if ((purchaseConfigDetails?.pledgedQtyMsg ?? "").isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      size: 18.0,
                      color: primaryRedColor.withOpacity(0.6),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text: purchaseConfigDetails?.pledgedQtyMsg ?? "",
                          style: darkThemeMode
                              ? ThemeClass.Darktheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColorDark,
                                      fontSize: 12)
                              : ThemeClass.lighttheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColorLight,
                                      fontSize: 12),
                        ),
                      ])),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
              ],
              if ((purchaseConfigDetails?.ledgerBalanceMsg ?? "")
                  .isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      size: 18.0,
                      color: primaryRedColor.withOpacity(0.6),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                          text: purchaseConfigDetails?.ledgerBalanceMsg ?? "",
                          style: darkThemeMode
                              ? ThemeClass.Darktheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColorDark,
                                      fontSize: 12)
                              : ThemeClass.lighttheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColorLight,
                                      fontSize: 12),
                        ),
                        WidgetSpan(
                            child: InkWell(
                          onTap: () {
                            launchUrlString(
                                purchaseConfigDetails?.fundLink ?? "");
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.only(
                                top: 2, bottom: 3, left: 5, right: 5),
                            decoration: BoxDecoration(
                                color: appPrimeColor,
                                // border: Border.all(
                                //     width: 1,
                                //     color:
                                //         subTitleTextColor
                                //             .withOpacity(
                                //                 0.2)),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text('click here',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: titleTextColorDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10)),
                          ),
                        )

                            //  " click here",
                            // style: ThemeClass.Darktheme.textTheme.bodyMedium!
                            //     .copyWith(color: appPrimeColor, fontSize: 12),
                            // recognizer: TapGestureRecognizer()
                            //   ..onTap = () {
                            //     launchUrlString(
                            //         purchaseConfigDetails?.fundLink ?? "");
                            //   }

                            )
                      ])),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
              ],
              const SizedBox(height: 10.0),
            ],
          ));
    }
    return Skeletonizer(
      ignoreContainers: true,
      enabled: isLoading,
      child: PopScope(
        onPopInvoked: (didPop) {
          if (widget.func != null) {
            widget.func();
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
              top: 15.0,
              right: 15.0,
              left: 15.0,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: _formKey,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ListView(
                  shrinkWrap: true,
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                              color: darkThemeMode
                                  ? const Color.fromARGB(255, 54, 54, 54)
                                  : const Color.fromARGB(90, 236, 234, 233),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 50.0,
                                height: 50.0,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: loadingImg.isNotEmpty
                                    ? ImageLoader(
                                        loadingImg: loadingImg,
                                      )
                                    : const SizedBox(),
                              ),
                              const SizedBox(width: 20.0),
                              Expanded(
                                  child: Text(
                                purchaseConfigDetails
                                        ?.mfSchemeMaster?.schemeName ??
                                    "",
                                textAlign: TextAlign.start,
                                style: darkThemeMode
                                    ? ThemeClass.Darktheme.textTheme.bodyMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            height: 1.4,
                                            color: titleTextColorDark)
                                    : ThemeClass
                                        .lighttheme.textTheme.bodyMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            height: 1.4,
                                            color: Colors.black),
                              ))
                            ],
                          ),
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width - 60,
                          top: -17,
                          child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.close,
                                size: 20,
                              )),
                        )
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Visibility(
                      visible: widget.type == 'redeem',
                      //Buy textform Fields.....
                      replacement: Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // const CustomTextInBottomSheet(text: "Amount"),
                              Text(
                                'Lumpsum Amount',
                                style: darkThemeMode
                                    ? ThemeClass.Darktheme.textTheme.bodyMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)
                                    : ThemeClass
                                        .lighttheme.textTheme.bodyMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                              ),
                              const SizedBox(height: 10.0),
                              Container(
                                  // color: Colors.red,
                                  width: 200.0,
                                  child: CustomBuyFormField(
                                    focusBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: appPrimeColor, width: 1.0)),
                                    textColor: darkThemeMode
                                        ? Colors.blue
                                        : appPrimeColor,
                                    textAlign: TextAlign.center,
                                    contorller: amountController,
                                    fontsize: 20,
                                    bgColor: darkThemeMode
                                        ? titleTextColorDark
                                        : modifyButtonColor.withOpacity(0.4),
                                    borderColor: isLoading
                                        ? Colors.transparent
                                        : appPrimeColor,
                                    inputFormat: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*'))
                                    ],
                                    readonly:
                                        widget.type == "redeem" ? true : false,
                                    prefix: Visibility(
                                      visible: widget.type != "redeem",
                                      child: GestureDetector(
                                        onTap: () {
                                          if (amountController
                                              .text.isNotEmpty) {
                                            num amount = (num.tryParse(
                                                        amountController
                                                            .text) ??
                                                    500) -
                                                500;
                                            amount <
                                                    (num.tryParse(purchaseConfigDetails
                                                                ?.mfSchemeMaster
                                                                ?.minPurchaseAmt ??
                                                            "0") ??
                                                        0)
                                                ? amount = num.tryParse(
                                                        purchaseConfigDetails
                                                                ?.mfSchemeMaster
                                                                ?.minPurchaseAmt ??
                                                            "0") ??
                                                    0
                                                : amount;

                                            amountController.text = "$amount";

                                            calculateEstQty("$amount");
                                          } else {
                                            amountController.text =
                                                "${num.tryParse(purchaseConfigDetails?.mfSchemeMaster?.minPurchaseAmt ?? "0") ?? 0}";
                                            calculateEstQty(
                                                "${num.tryParse(purchaseConfigDetails?.mfSchemeMaster?.minPurchaseAmt ?? "0") ?? 0}");
                                          }
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: appPrimeColor,
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.5, vertical: 3),
                                            child: Transform.scale(
                                              scale: 1.6,
                                              child: Text(
                                                "-",
                                                style: TextStyle(
                                                    height: 1.1,
                                                    fontWeight: FontWeight.bold,
                                                    color: titleTextColorDark),
                                              ),
                                            )),
                                      ),
                                    ),
                                    suffix: Visibility(
                                      visible: widget.type != "redeem",
                                      child: GestureDetector(
                                        onTap: () {
                                          if (amountController
                                              .text.isNotEmpty) {
                                            num amount = (num.tryParse(
                                                        amountController
                                                            .text) ??
                                                    0) +
                                                500;
                                            amount <
                                                    num.parse(purchaseConfigDetails
                                                            ?.mfSchemeMaster
                                                            ?.minPurchaseAmt ??
                                                        "0")
                                                ? amount = num.parse(
                                                    (purchaseConfigDetails
                                                            ?.mfSchemeMaster
                                                            ?.minPurchaseAmt) ??
                                                        "0")
                                                : amount;
                                            if (amount.toString().length <= 9) {
                                              amountController.text = "$amount";

                                              calculateEstQty("$amount");
                                            } else {}
                                          } else {
                                            amountController.text =
                                                "${num.tryParse(purchaseConfigDetails?.mfSchemeMaster?.minPurchaseAmt ?? "0") ?? 0}";
                                            calculateEstQty(
                                                "${num.tryParse(purchaseConfigDetails?.mfSchemeMaster?.minPurchaseAmt ?? "0") ?? 0}");
                                          }
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: appPrimeColor,
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 3),
                                            child: Transform.scale(
                                              scale: 1.4,
                                              child: Text(
                                                "+",
                                                style: TextStyle(
                                                    height: 1.1,
                                                    fontWeight: FontWeight.bold,
                                                    color: titleTextColorDark),
                                              ),
                                            )),
                                      ),
                                    ),
                                    onChange: calculateEstQty,
                                    validator: amountValidate,
                                  ))
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Container(
                            height: 25.0,
                            width: MediaQuery.of(context).size.width - 30,
                            alignment: Alignment.center,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              children: values
                                  .map((amount) => GestureDetector(
                                        onTap: () {
                                          amountController.text = "$amount";
                                          calculateEstQty(amount.toString());
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(left: 8.0),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 3.0),
                                          decoration: BoxDecoration(
                                              color: appPrimeColor,
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          child: Text(
                                            rsFormat.format(amount),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                height: 1.4,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: CustomTextInBottomSheet(
                                          text: "NAV : "))),
                              // const SizedBox(
                              //   width: 10,
                              // ),
                              // const CustomTextInBottomSheet(text: ": "),
                              // const SizedBox(width: 10.0),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IntrinsicWidth(
                                        child: CustomBuyFormField(
                                      contorller: navController,
                                      bgColor: darkThemeMode
                                          ? titleTextColorDark.withOpacity(0.8)
                                          : primaryGreenColor.withOpacity(0.1),
                                      borderColor: isLoading
                                          ? Colors.transparent
                                          : primaryGreenColor,
                                      readonly: true,
                                    )),
                                    navDate.isNotEmpty
                                        ? InkWell(
                                            onTap: () => customMfAlertBox(
                                                context: context,
                                                title: 'Last NAV Date',
                                                contentWidget: Text(navDate),
                                                func1: () {}),
                                            child: Icon(
                                              Icons.info_outline_rounded,
                                              size: 18,
                                              color: darkThemeMode
                                                  ? ThemeClass
                                                      .Darktheme
                                                      .textTheme
                                                      .bodyMedium!
                                                      .color
                                                  : ThemeClass
                                                      .lighttheme
                                                      .textTheme
                                                      .bodyMedium!
                                                      .color,
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              )
                            ],
                          ),
                          // const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: CustomTextInBottomSheet(
                                        text: "Estimated Units : ")),
                              ),
                              // const SizedBox(width: 10.0),
                              // const CustomTextInBottomSheet(text: ": "),
                              // const SizedBox(width: 10.0),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: IntrinsicWidth(
                                      child: CustomBuyFormField(
                                    inputFormat: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d{0,2}')),
                                      // LengthLimitingTextInputFormatter(10),
                                    ],
                                    contorller: qtyController,
                                    bgColor: darkThemeMode
                                        ? titleTextColorDark.withOpacity(0.8)
                                        : primaryGreenColor.withOpacity(0.1),
                                    borderColor: isLoading
                                        ? Colors.transparent
                                        : primaryGreenColor,
                                    readonly:
                                        widget.type == "redeem" ? false : true,
                                    onChange: (value) {
                                      num qty = num.tryParse(value) ?? 0;
                                      num amount = qty *
                                          (num.tryParse(purchaseConfigDetails
                                                      ?.mfSchemeMaster
                                                      ?.navValue ??
                                                  "0") ??
                                              0);
                                      String formattedAmount =
                                          doubleformatAmount(amount);

                                      amountController.text = formattedAmount;
                                    },
                                  )),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      //Redeem Text Form Field
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CustomTextInBottomSheet(
                                  text: "Units To Redeem"),
                              const SizedBox(height: 10.0),
                              SizedBox(
                                  width: 125,
                                  child: CustomBuyFormField(
                                    textAlign: TextAlign.center,
                                    focusBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: appPrimeColor, width: 1.0)),
                                    textColor: appPrimeColor,
                                    fontsize: 20,
                                    inputFormat: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d{0,3}')),
                                    ],
                                    contorller: qtyController,
                                    bgColor: darkThemeMode
                                        ? titleTextColorDark.withOpacity(0.8)
                                        : primaryGreenColor.withOpacity(0.1),
                                    borderColor: isLoading
                                        ? Colors.transparent
                                        : primaryGreenColor,
                                    readonly:
                                        widget.type == "redeem" ? false : true,
                                    onChange: (value) {
                                      num qty = num.tryParse(value) ?? 0;
                                      num amount = qty *
                                          (num.tryParse(purchaseConfigDetails
                                                      ?.mfSchemeMaster
                                                      ?.navValue ??
                                                  "0") ??
                                              0);
                                      String formattedAmount =
                                          doubleformatAmount(amount);

                                      amountController.text = formattedAmount;
                                    },
                                    validator: qtyValidate,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: CustomTextInBottomSheet(
                                          text: "NAV "))),
                              const SizedBox(
                                width: 10,
                              ),
                              const CustomTextInBottomSheet(text: ": "),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IntrinsicWidth(
                                      child: CustomBuyFormField(
                                        contorller: navController,
                                        bgColor: darkThemeMode
                                            ? titleTextColorDark
                                                .withOpacity(0.8)
                                            : primaryGreenColor
                                                .withOpacity(0.1),
                                        borderColor: isLoading
                                            ? Colors.transparent
                                            : primaryGreenColor,
                                        readonly: true,
                                      ),
                                    ),
                                    navDate.isNotEmpty
                                        ? InkWell(
                                            onTap: () => customMfAlertBox(
                                                context: context,
                                                title: 'NAV Date',
                                                contentWidget: Text(navDate),
                                                func1: () {}),
                                            child: Icon(
                                              Icons.info_outline_rounded,
                                              size: 18,
                                              color: darkThemeMode
                                                  ? ThemeClass
                                                      .Darktheme
                                                      .textTheme
                                                      .bodyMedium!
                                                      .color
                                                  : ThemeClass
                                                      .lighttheme
                                                      .textTheme
                                                      .bodyMedium!
                                                      .color,
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child:
                                      CustomTextInBottomSheet(text: "Amount"),
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              const CustomTextInBottomSheet(text: ": "),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: IntrinsicWidth(
                                        child: CustomBuyFormField(
                                      contorller: amountController,
                                      bgColor: darkThemeMode
                                          ? titleTextColorDark
                                          : modifyButtonColor.withOpacity(0.4),
                                      borderColor: isLoading
                                          ? Colors.transparent
                                          : appPrimeColor,
                                      inputFormat: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d{0,2}')),
                                      ],
                                      readonly: widget.type == "redeem"
                                          ? true
                                          : false,
                                      prefix: Visibility(
                                        visible: widget.type != "redeem",
                                        child: GestureDetector(
                                          onTap: () {
                                            if (amountController
                                                .text.isNotEmpty) {
                                              num amount = (num.tryParse(
                                                          amountController
                                                              .text) ??
                                                      500) -
                                                  500;
                                              amount <
                                                      (num.tryParse(purchaseConfigDetails
                                                                  ?.mfSchemeMaster
                                                                  ?.minPurchaseAmt ??
                                                              "0") ??
                                                          0)
                                                  ? amount = num.tryParse(
                                                          purchaseConfigDetails
                                                                  ?.mfSchemeMaster
                                                                  ?.minPurchaseAmt ??
                                                              "0") ??
                                                      0
                                                  : amount;

                                              amountController.text = "$amount";

                                              calculateEstQty("$amount");
                                            } else {
                                              amountController.text =
                                                  "${num.tryParse(purchaseConfigDetails?.mfSchemeMaster?.minPurchaseAmt ?? "0") ?? 0}";
                                              calculateEstQty(
                                                  "${num.tryParse(purchaseConfigDetails?.mfSchemeMaster?.minPurchaseAmt ?? "0") ?? 0}");
                                            }
                                          },
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 3),
                                              child: Transform.scale(
                                                scale: 1.7,
                                                child: Text(
                                                  "-",
                                                  style: TextStyle(
                                                      height: 1.1,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: appPrimeColor),
                                                ),
                                              )),
                                        ),
                                      ),
                                      suffix: Visibility(
                                        visible: widget.type != "redeem",
                                        child: GestureDetector(
                                          onTap: () {
                                            if (amountController
                                                .text.isNotEmpty) {
                                              num amount = (num.tryParse(
                                                          amountController
                                                              .text) ??
                                                      0) +
                                                  500;
                                              amount <
                                                      num.parse(purchaseConfigDetails
                                                              ?.mfSchemeMaster
                                                              ?.minPurchaseAmt ??
                                                          "0")
                                                  ? amount = num.parse(
                                                      purchaseConfigDetails
                                                              ?.mfSchemeMaster
                                                              ?.minPurchaseAmt ??
                                                          "0")
                                                  : amount;
                                              if (amount.toString().length <=
                                                  9) {
                                                amountController.text =
                                                    "$amount";

                                                calculateEstQty("$amount");
                                              } else {}
                                            } else {
                                              amountController.text =
                                                  "${num.tryParse(purchaseConfigDetails?.mfSchemeMaster?.minPurchaseAmt ?? "0") ?? 0}";
                                              calculateEstQty(
                                                  "${num.tryParse(purchaseConfigDetails?.mfSchemeMaster?.minPurchaseAmt ?? "0") ?? 0}");
                                            }
                                          },
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 3),
                                              child: Transform.scale(
                                                scale: 1.6,
                                                child: Text(
                                                  "+",
                                                  style: TextStyle(
                                                      height: 1.1,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: appPrimeColor),
                                                ),
                                              )),
                                        ),
                                      ),
                                      onChange: calculateEstQty,
                                      validator: amountValidate,
                                    ))),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    InkWell(
                      onTap: () {
                        customMfAlertBox(
                            context: context,
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.info,
                                  size: 18,
                                  color: primaryOrangeColor,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Cut-Off Time',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(color: primaryOrangeColor),
                                )
                              ],
                            ),
                            contentWidget: Padding(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                left: 10.0,
                                right: 20,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(disclaimer, // 'ldsfo',
                                        overflow: TextOverflow.visible,
                                        textAlign: TextAlign.justify,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!),
                                  )
                                ],
                              ),
                            ),
                            func1: () {});
                      },
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
                                purchaseConfigDetails?.mfDisclaimerMessageInfo!
                                        .mfDisclaimerInfoMessage ??
                                    "",
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
                    const SizedBox(height: 10.0),
                    widget.type == "buy"
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CustomButton(
                                  buttonEnable: false,
                                  buttonWidget: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // SizedBox(
                                      //   height: 20,
                                      //   width: 20,
                                      //   child: Image.asset(
                                      //     'assets/Cart.png',
                                      //     color: appPrimeColor,
                                      //   ),
                                      // ),
                                      // const SizedBox(
                                      //   width: 5,
                                      // ),
                                      Text(
                                        purchaseConfigDetails
                                                    ?.mfSchemeMaster?.addcart ==
                                                'Y'
                                            ? 'Go to cart'
                                            : cartText,
                                        style: TextStyle(
                                            color: appPrimeColor,
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                  borderColor: isLoading
                                      ? Colors.transparent
                                      : appPrimeColor,
                                  onTapFunc: () {
                                    if (cartAdded ||
                                        purchaseConfigDetails
                                                ?.mfSchemeMaster?.addcart ==
                                            'Y') {
                                      Navigator.pop(context);
                                      MFChangeIndex().value = 3;
                                    } else {
                                      insertCart(
                                          cartType: 'addCart',
                                          amount: amountController.text,
                                          context: context);
                                    }
                                    // cartAdded
                                    //     ?

                                    //     print('SDFDs')
                                    //     : insertCart(
                                    //         amount: amountController.text,
                                    //         context: context);
                                  },
                                  backgroundColor: Colors.white,
                                  textColor: appPrimeColor,
                                ),
                              ),
                              const SizedBox(width: 20.0),
                              Expanded(
                                child: CustomButton(
                                    buttonWidget: "BUY",
                                    buttonEnable: false,
                                    onTapFunc: () async {
                                      order(
                                          purchaseType: "buy",
                                          context: context);
                                    }),
                              ),
                            ],
                          )
                        : widget.type == "redeem"
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 170,
                                    child: CustomButton(
                                        buttonWidget: "REDEEM",
                                        textColor: Colors.white,
                                        backgroundColor: primaryRedColor,
                                        onTapFunc: () {
                                          order(
                                              purchaseType: "redeem",
                                              context: context);
                                        }),
                                  ),
                                ],
                              )
                            : widget.type == "delete"
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: CustomButton(
                                          buttonEnable: false,
                                          buttonWidget: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                height: 17,
                                                width: 17,
                                                child: Image.asset(
                                                  'assets/Save.png',
                                                  color: appPrimeColor,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 7,
                                              ),
                                              Text(
                                                'SAVE',
                                                style: TextStyle(
                                                    color: appPrimeColor,
                                                    fontSize: 17.0,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            ],
                                          ),
                                          borderColor: isLoading
                                              ? Colors.transparent
                                              : appPrimeColor,
                                          onTapFunc: () {
                                            insertCart(
                                                cartType: 'saveCart',
                                                amount: amountController.text,
                                                context: context);
                                          },
                                          backgroundColor: Colors.white,
                                          textColor: appPrimeColor,
                                        ),
                                      ),
                                      const SizedBox(width: 15.0),
                                      Expanded(
                                        child: CustomButton(
                                            buttonWidget: "BUY NOW",
                                            onTapFunc: () {
                                              order(
                                                  purchaseType: "cartbuy",
                                                  context: context);
                                            }),
                                      ),
                                    ],
                                  )
                                : widget.type == "cart"
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 170,
                                            child: CustomButton(
                                              buttonWidget: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    'ADD MORE',
                                                    style: TextStyle(
                                                        color: appPrimeColor,
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  )
                                                ],
                                              ),
                                              borderColor: isLoading
                                                  ? Colors.transparent
                                                  : appPrimeColor,
                                              onTapFunc: () {
                                                order(
                                                    purchaseType: "ExistBuy",
                                                    context: context);
                                              },
                                              backgroundColor: Colors.white,
                                              textColor: appPrimeColor,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                    const SizedBox(height: 20.0),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: CustomSnackbarwithDelay(
                    bgColor: bgcolor,
                    visible: showCopyTextSnackBar,
                    value: showsnackText,
                    titleWidget: bgcolor == primaryOrangeColor
                        ? null
                        : Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 12,
                              color: titleTextColorDark,
                            ),
                          ),
                  ),
                )
                // Visibility(
                //   visible: showSipSnackBar,
                //   child: Padding(
                //     padding: const EdgeInsets.all(15.0),
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 10.0, vertical: 5.0),
                //       decoration: BoxDecoration(
                //           color: snackBarStatus == "E"
                //               ? primaryRedColor
                //               : primaryGreenColor, //titleTextColorLight,
                //           borderRadius: BorderRadius.circular(10.0)),
                //       child: Text(
                //         snackBarContent,
                //         style: TextStyle(
                //             fontSize: 13.0,
                //             fontWeight: FontWeight.bold,
                //             color: titleTextColorDark),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
