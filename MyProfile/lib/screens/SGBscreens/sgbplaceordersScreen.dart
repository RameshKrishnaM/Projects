// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, must_be_immutable, file_names, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novo/API/APICall.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/cookies/cookies.dart';
import 'package:novo/model/sgbModels/sgbdetailsmodel.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/utils/colors.dart';

import 'package:provider/provider.dart';
import '../../widgets/NOVO Widgets/LoadingAlertBox.dart';
import '../../widgets/NOVO Widgets/infoContainer.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../widgets/NOVO Widgets/snackbar.dart';
import '/Roating/route.dart' as route;
// import '/Roating/route.dart' as route;

class SgbPlaceOrder extends StatefulWidget {
  const SgbPlaceOrder({super.key, required this.sgbMasterDetails});
  final SgbDetail sgbMasterDetails;
  // String? applyMethod;

  @override
  State<SgbPlaceOrder> createState() => _SgbPlaceOrderState();
}

class _SgbPlaceOrderState extends State<SgbPlaceOrder> {
  /*Variable Declartion Part*/
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoaded = true;
  bool onchange = false;
  bool submitLoading = false;
  bool deleteLoading = false;
  bool buttonDisable = true;
  bool recheck = false;
  bool isChecked = false;
  Color? totalColor;
  int amountPayable = 0;
  int totalAmount = 0;
  int totalDiscountAmount = 0;
  dynamic accountBalance;
  bool acBalLoading = true;
  double textHeight = 1.5;
  /*Init State*/
  @override
  void initState() {
    super.initState();
    intialationFunc();
  }

  intialationFunc() {
    getAccountBalanceAPI();
    priceController.text = widget.sgbMasterDetails.unitPrice.toString();
    quantityController.text = widget.sgbMasterDetails.actionFlag == 'M'
        ? widget.sgbMasterDetails.appliedUnit.toString()
        : widget.sgbMasterDetails.minBidQty.toString();
    totalAmount =
        int.parse(priceController.text) * int.parse(quantityController.text);

    totalDiscountAmount = int.parse(quantityController.text) *
        widget.sgbMasterDetails.discountAmt;
    amountPayable = totalAmount - totalDiscountAmount;
    // ////////print(accountBalance);
    // widget.sgbMasterDetails.showSI = false;

    isChecked = widget.sgbMasterDetails.sIvalue!;
    if (widget.sgbMasterDetails.actionFlag == 'M' ||
        widget.sgbMasterDetails.actionFlag == 'A' ||
        widget.sgbMasterDetails.actionFlag == 'C') {
      setState(() {
        buttonDisable = true;
      });
    } else {
      setState(() {
        buttonDisable = false;
      });
    }
  }

  /*Get the Account Balance From the API */
  getAccountBalanceAPI() async {
    try {
      var response = await getMethod("/sgb/fetchFund", context);
      if (response != null && response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        ////////print(response.body);
        if (json["status"] == "S") {
          acBalLoading = false;
          accountBalance = json['accountBalance'] == '' ||
                  json['accountBalance'] == null ||
                  json['accountBalance'] == '-'
              ? 'NA'
              : json['accountBalance'] is String
                  ? double.parse(json['accountBalance'].toString()).floor()
                  : double.parse(json['accountBalance'].toString()).floor();

          ////////print('accountBalance');
          ////////print(accountBalance);
          setState(() {});
        } else {
          acBalLoading = false;
          accountBalance = "NA";
          setState(() {});
        }
      }
    } catch (e) {
      acBalLoading = false;
      accountBalance = "NA";
      setState(() {});
      //////////print(e.toString());
      // showSnackbar(context,
      //     e.toString().isNotEmpty ? e.toString() : somethingError, Colors.red);
    }
  }

  sIShowCheckFunc() async {
    setState(() {
      recheck = true;
    });

    if (widget.sgbMasterDetails.showSI!) {
      if (isChecked) {
        postSgbPlaceOrder();
      } else {
        showSnackbar(
            context, "Agree to Terms and Place Order", primaryRedColor);
      }
    } else {
      postSgbPlaceOrder();
    }
  }

  /* Submit The Bid Details...*/

  postSgbPlaceOrder() async {
    if (_formKey.currentState!.validate()) {
      Map? placeOrderDetailsMap;
      if (await isInternetConnected()) {
        setState(() {
          submitLoading = true;
        });

        if (widget.sgbMasterDetails.actionFlag == 'B' ||
            widget.sgbMasterDetails.actionFlag == 'P') {
          placeOrderDetailsMap = {
            "masterId": widget.sgbMasterDetails.id, // scriptId
            "bidId": "",
            "unit": int.parse(quantityController.text),
            "price": widget.sgbMasterDetails.unitPrice -
                widget.sgbMasterDetails.discountAmt,
            "actionCode": "N",
            "orderNo": "",
            "amount": amountPayable.toInt(),
            "oldUnit": 0,
            "SIvalue": isChecked,
            "SItext": widget
                .sgbMasterDetails.sItext //(*Generate random number for "NEW")
          };

          loadingAlertBox(context, 'Applying SGB...');
        } else if (widget.sgbMasterDetails.actionFlag == 'M' ||
            widget.sgbMasterDetails.actionFlag == 'A') {
          if (int.parse(quantityController.text) !=
              widget.sgbMasterDetails.appliedUnit) {
            placeOrderDetailsMap = {
              "actionCode": "M", // (ActionCodes : "N","M","C")
              "amount": amountPayable.toInt(),
              "bidId": "", // (*Compulsory for modify & cancel)
              "masterId": widget.sgbMasterDetails.id,
              "oldUnit": widget.sgbMasterDetails
                  .appliedUnit, // (*Compulsory for modify & cancel)
              "orderNo": widget.sgbMasterDetails
                  .orderNo, // (*Generate random number for "NEW" and Compulsory return the Actual orderNo for modify & cancel)
              "price": widget.sgbMasterDetails.unitPrice -
                  widget.sgbMasterDetails.discountAmt,
              "unit": int.parse(quantityController.text),
              "SIvalue": isChecked,
              "SItext": widget.sgbMasterDetails.sItext
            };

            loadingAlertBox(context, 'Modifying SGB...');
          }
        }

        Map? placeorderResponse = await sgbPlaceOrderApi(
            context: context, postBidDetails: placeOrderDetailsMap!);
        //////////print(placeOrderDetailsMap);

        if (placeorderResponse != null && placeorderResponse.isNotEmpty) {
          if (placeorderResponse['status'] == 'S') {
            // ChangeSGBIndex().changeSGBIndex(1);
            showSnackbar(
                context, placeorderResponse['orderStatus'], primaryGreenColor);
            Navigator.pushNamed(context, route.novoPage);
          } else {
            Navigator.pop(context);
            showSnackbar(
                context,
                placeorderResponse['errMsg'] ?? somethingError,
                primaryRedColor);
          }
        } else {
          // Navigator.pop(context);
        }
        setState(() {
          submitLoading = false;
        });
      } else {
        noInternetConnectAlertDialog(context, () => postSgbPlaceOrder);
      }
    }
  }
  // /* Delete Application From the ModifyDetails */

  deleteBidInAPI() async {
    setState(() {
      recheck = true;
    });
    if (_formKey.currentState!.validate()) {
      setState(() {
        deleteLoading = false;
      });
      if (await isInternetConnected()) {
        Map deleteApp = {
          "actionCode": "D", // (ActionCodes : "N","M","C")
          "amount": amountPayable.toInt(),
          "bidId": "", // (*Compulsory for modify & cancel)
          "masterId": widget.sgbMasterDetails.id,
          "oldUnit": widget.sgbMasterDetails
              .appliedUnit, // (*Compulsory for modify & cancel)
          "orderNo": widget.sgbMasterDetails
              .orderNo, // (*Generate random number for "NEW" and Compulsory return the Actual orderNo for modify & cancel)
          "price": widget.sgbMasterDetails.unitPrice,
          "unit": int.parse(quantityController.text),
          "SIvalue": isChecked,
          "SItext": widget.sgbMasterDetails.sItext
        };

        loadingAlertBox(context, 'Deleting SGB...');

        Map? placeorderResponse =
            await sgbPlaceOrderApi(context: context, postBidDetails: deleteApp);

        if (placeorderResponse != null && placeorderResponse.isNotEmpty) {
          if (placeorderResponse['status'] == 'S') {
            showSnackbar(
                context, placeorderResponse['orderStatus'], primaryGreenColor);
            Navigator.pushNamed(context, route.novoPage);
          } else {
            showSnackbar(
                context,
                placeorderResponse['errMsg'] ?? somethingError,
                primaryRedColor);
            Navigator.pop(context);
          }
        } else {
          //////////print('DeleteOrder is null value throw');
        }
      } else {
        noInternetConnectAlertDialog(context, () => deleteBidInAPI());
      }
    }
  }

  totalCalculation() {
    setState(() {
      totalAmount = int.parse(
              quantityController.text == "" ? "0" : quantityController.text) *
          (int.parse(priceController.text));
      totalDiscountAmount = int.parse(
              quantityController.text == "" ? "0" : quantityController.text) *
          widget.sgbMasterDetails.discountAmt;
      amountPayable = totalAmount - totalDiscountAmount;
      modifyValidation();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    });
  }

  incrementUnitValue() {
    String currentValue = quantityController.text;
    int currentQuantity = int.tryParse(currentValue) ?? 0;
    if (currentQuantity < widget.sgbMasterDetails.maxBidQty) {
      quantityController.text = (currentQuantity + 1).toString();

      totalCalculation();
    }
  }

  decrementUnitValue() {
    String currentValue = quantityController.text;
    int currentQuantity = int.tryParse(currentValue) ?? 0;
    if (currentQuantity > widget.sgbMasterDetails.minBidQty) {
      quantityController.text = (currentQuantity - 1).toString();
      totalCalculation();
    }
  }

  quantityOnChange(value) {
    quantityValidator(value);

    totalCalculation();
  }

  modifyValidation() {
    if (quantityController.text !=
            widget.sgbMasterDetails.appliedUnit.toString() &&
        quantityController.text != '0' &&
        quantityController.text.isNotEmpty) {
      buttonDisable = false;
    } else {
      buttonDisable = true;
    }
  }

  quantityValidator(value) {
    if (value.isEmpty || value == null) {
      return '';
    }
    if (int.parse(value) < widget.sgbMasterDetails.minBidQty ||
        int.parse(value) > widget.sgbMasterDetails.maxBidQty) {
      return '${widget.sgbMasterDetails.minBidQty}-${widget.sgbMasterDetails.maxBidQty}';
    }
    return null;
  }

/* Calculate the Total Amount with using The Validation */

  @override
  Widget build(BuildContext context) {
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    var lightThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.light;
    var darkThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                darkThemeMode ? Brightness.light : Brightness.dark),
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              CupertinoIcons.arrow_left,
              size: 20.0,
              color: themeBasedColor,
            )),
        title: Text(widget.sgbMasterDetails.symbol,
            overflow: TextOverflow.visible,
            style: lightThemeMode
                ? ThemeClass.lighttheme.textTheme.titleMedium
                : ThemeClass.Darktheme.textTheme.titleMedium),
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
        foregroundColor: darkThemeMode ? titleTextColorDark : Colors.black45,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
          child: Stack(
        children: [
          ListView(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 20.0, top: 5.0),
                width: MediaQuery.of(context).size.width,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? "assets/SGB WNovo Icon.png"
                                : "assets/SGB BNovo Icon.png",
                            width: 34.0,
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Flexible(
                            child: Text(
                              widget.sgbMasterDetails.name,
                              overflow: TextOverflow.visible,
                              style: lightThemeMode
                                  ? ThemeClass.lighttheme.textTheme.titleMedium
                                  : ThemeClass.Darktheme.textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // accountBalance is String
                              //     ? SizedBox()
                              //     :
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Ledger Balance',
                                    style: lightThemeMode
                                        ? ThemeClass
                                            .lighttheme.textTheme.titleMedium!
                                            .copyWith(
                                            height: textHeight,
                                          )
                                        : ThemeClass
                                            .Darktheme.textTheme.titleMedium!
                                            .copyWith(
                                            height: textHeight,
                                          ),
                                  ),
                                  acBalLoading
                                      ? SizedBox(
                                          height: 5,
                                          width: 35,
                                          child: LinearProgressIndicator(
                                            backgroundColor: inactiveColor,
                                            color: titleTextColorLight
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ))
                                      : accountBalance is String
                                          ? Text('$accountBalance',
                                              style: ThemeClass.lighttheme
                                                  .textTheme.titleMedium!
                                                  .copyWith(
                                                height: textHeight,
                                              ))
                                          : Text(
                                              // '₹ $accountBalance',

                                              rsFormat.format(accountBalance),
                                              style:
                                                  //  lightThemeMode
                                                  //     ?
                                                  ThemeClass.lighttheme
                                                      .textTheme.titleMedium!
                                                      .copyWith(
                                                          height: textHeight,
                                                          color: accountBalance >
                                                                  0
                                                              ? primaryGreenColor
                                                              : primaryRedColor)
                                              // : ThemeClass.Darktheme
                                              //     .textTheme.titleMedium!
                                              //     .copyWith(
                                              //         height: textHeight,
                                              //         color: accountBalance >
                                              //                 0
                                              //             ? primaryGreenColor
                                              //             : primaryRedColor)
                                              ),
                                ],
                              ),
                              Visibility(
                                visible: widget.sgbMasterDetails.cancelAllowed!,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          deleteBidDialogBox(
                                            context,
                                            deleteLoading,
                                            () => deleteBidInAPI(),
                                            widget
                                                .sgbMasterDetails.sIrefundText,
                                          );
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: primaryRedColor,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            'Unit Price',
                            style:
                                ThemeClass.lighttheme.textTheme.displayMedium,
                          ),
                          Text(
                            rsMrkFormat
                                .format(widget.sgbMasterDetails.unitPrice),
                            style: lightThemeMode
                                ? ThemeClass.lighttheme.textTheme.titleMedium!
                                    .copyWith(
                                    height: textHeight,
                                  )
                                : ThemeClass.Darktheme.textTheme.titleMedium!
                                    .copyWith(
                                    height: textHeight,
                                  ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            widget.sgbMasterDetails.discountText,
                            style:
                                ThemeClass.lighttheme.textTheme.displayMedium,
                          ),
                          Text(
                            widget.sgbMasterDetails.discountAmt == 0
                                ? 'N/A'
                                : rsMrkFormat.format(
                                    widget.sgbMasterDetails.discountAmt),
                            style: lightThemeMode
                                ? ThemeClass.lighttheme.textTheme.titleMedium!
                                    .copyWith(
                                    height: textHeight,
                                  )
                                : ThemeClass.Darktheme.textTheme.titleMedium!
                                    .copyWith(
                                    height: textHeight,
                                  ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Visibility(
                        visible: widget.sgbMasterDetails.infoText.isNotEmpty,
                        child: InfoContainer(
                          infoMsg: widget.sgbMasterDetails.infoText,
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                                color: darkThemeMode
                                    ? Colors.grey
                                    : const Color.fromRGBO(235, 237, 236, 1)),
                            boxShadow: [
                              BoxShadow(
                                color: darkThemeMode
                                    ? Colors.transparent
                                    : Colors.grey.shade200,
                                offset: const Offset(0,
                                    1.0), // Offset (x, y) controls the shadow's position
                                blurRadius: 15, // Spread of the shadow
                                spreadRadius:
                                    5.0, // Positive values expand the shadow, negative values shrink it
                              ),
                            ],
                            color: lightThemeMode
                                ? titleTextColorDark
                                : Colors.transparent),
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bidding Starts: ',
                              style:
                                  ThemeClass.lighttheme.textTheme.displayMedium,
                            ),
                            Text(widget.sgbMasterDetails.startDateWithTime,
                                textAlign: TextAlign.end,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                                style: lightThemeMode
                                    ? ThemeClass
                                        .lighttheme.textTheme.titleMedium!
                                        .copyWith(
                                        height: textHeight,
                                      )
                                    : ThemeClass
                                        .Darktheme.textTheme.titleMedium!
                                        .copyWith(
                                        height: textHeight,
                                      )),
                            SizedBox(
                              height: 15.0,
                            ),
                            Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        const Color.fromRGBO(235, 237, 236, 1),
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        // enabled: unitenable,
                                        style: TextStyle(
                                          fontFamily: 'inter',
                                          fontSize: subTitleFontSize,
                                          // color: titleTextColorLight,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]'))
                                        ],
                                        enabled: widget
                                            .sgbMasterDetails.modifyAllowed,
                                        controller: quantityController,
                                        maxLength: 4,
                                        validator: (value) =>
                                            quantityValidator(value),
                                        onChanged: (value) {
                                          quantityOnChange(value);
                                        },

                                        decoration: InputDecoration(
                                          disabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: const Color.fromRGBO(
                                                      235, 237, 236, 1),
                                                  width: 2.0)),
                                          // isDense: true,
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: const Color.fromRGBO(
                                                      235, 237, 236, 1),
                                                  width: 2.0)),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: primaryGreenColor,
                                                  width: 0.4)),
                                          counterText: '',
                                          labelText: 'Unit to buy',
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          hintText: '0',
                                          labelStyle: ThemeClass.lighttheme
                                              .textTheme.displayMedium!
                                              .copyWith(fontSize: 18),
                                          errorBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: primaryRedColor
                                                      .withOpacity(1),
                                                  width: 2)),
                                          contentPadding: EdgeInsets.zero,

                                          prefix: Visibility(
                                            visible: widget.sgbMasterDetails
                                                .modifyAllowed!,
                                            child: InkWell(
                                              onTap: () => decrementUnitValue(),
                                              child: Transform.scale(
                                                scale: 1.3,
                                                child: Text(
                                                  '-',
                                                  style: TextStyle(
                                                    fontFamily: 'inter',
                                                    color: subTitleTextColor,
                                                    fontSize: 24,
                                                    height: 0.9,
                                                    letterSpacing: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          suffix: InkWell(
                                            onTap: () {
                                              incrementUnitValue();
                                            },
                                            child: Visibility(
                                              visible: widget.sgbMasterDetails
                                                  .modifyAllowed!,
                                              child: Text(
                                                '+',
                                                style: TextStyle(
                                                  fontFamily: 'inter',
                                                  color: subTitleTextColor,
                                                  fontSize: 25,
                                                  height: 1,
                                                  letterSpacing: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8.0,
                                      ),
                                    ],
                                  ),
                                )),
                            SizedBox(
                              height: 40.0,
                            ),
                            Text(
                              'Bidding Ends: ',
                              style:
                                  ThemeClass.lighttheme.textTheme.displayMedium,
                            ),
                            Text(
                              widget.sgbMasterDetails.endDateWithTime,
                              textAlign: TextAlign.end,
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                              style: lightThemeMode
                                  ? ThemeClass.lighttheme.textTheme.titleMedium!
                                      .copyWith(
                                      height: textHeight,
                                    )
                                  : ThemeClass.Darktheme.textTheme.titleMedium!
                                      .copyWith(
                                      height: textHeight,
                                    ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Text(
                              'ISIN: ',
                              style:
                                  ThemeClass.lighttheme.textTheme.displayMedium,
                            ),
                            Text(
                              widget.sgbMasterDetails.isin,
                              style: lightThemeMode
                                  ? ThemeClass.lighttheme.textTheme.titleMedium!
                                      .copyWith(
                                      height: textHeight,
                                    )
                                  : ThemeClass.Darktheme.textTheme.titleMedium!
                                      .copyWith(
                                      height: textHeight,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Visibility(
                        visible: widget.sgbMasterDetails.showSI!,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isChecked = !isChecked;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                margin: EdgeInsets.only(top: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      5.0), // Set the radius to 2.0
                                  color: isChecked
                                      ? appPrimeColor
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: !isChecked && recheck
                                        ? primaryRedColor
                                        : subTitleTextColor,
                                    width: 2,
                                  ),
                                ),
                                child: isChecked
                                    ? const Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Colors.white,
                                        size: 12,
                                      )
                                    : null,
                              ),
                              SizedBox(
                                width: 12.0,
                              ),
                              Expanded(
                                child: Text(
                                  widget.sgbMasterDetails.sItext,
                                  style: ThemeClass
                                      .lighttheme.textTheme.displayMedium,
                                  textAlign: TextAlign.justify,
                                  overflow: TextOverflow
                                      .visible, // Set the overflow behavior
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 150,
              ),
            ],
          ),
          Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Provider.of<NavigationProvider>(context).themeMode ==
                        ThemeMode.dark
                    ? Color.fromRGBO(48, 48, 48, 1)
                    : Color.fromRGBO(240, 240, 240, 1),
                child: Column(
                  children: [
                    /*Total Amount Section...*/
                    Container(
                      // height: 40.0,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      // width: double.infinity,
                      color:
                          Provider.of<NavigationProvider>(context).themeMode ==
                                  ThemeMode.dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade400,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount payable',
                                style: TextStyle(
                                    fontFamily: 'inter',
                                    color:
                                        Provider.of<NavigationProvider>(context)
                                                    .themeMode ==
                                                ThemeMode.dark
                                            ? Colors.black
                                            : titleTextColorLight,
                                    fontSize: 14.0,
                                    height: 1.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                rsFormat.format(amountPayable),
                                style: TextStyle(
                                    fontFamily: 'inter',
                                    color: amountPayable == 0
                                        ? titleTextColorLight
                                        : primaryGreenColor,
                                    height: 1.0,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        disabledColor: Colors.grey,
                        minWidth: MediaQuery.of(context).size.width,
                        height: 45,
                        color: appPrimeColor,
                        onPressed: submitLoading || buttonDisable
                            ? null
                            : () {
                                sIShowCheckFunc();
                              },
                        child: Text(
                          widget.sgbMasterDetails.buttonText,
                          style: TextStyle(
                            color: submitLoading || buttonDisable
                                ? Colors.white.withOpacity(0.20)
                                : Colors.white,
                            fontSize: 18.0,
                            fontFamily: 'inter',
                            fontWeight: FontWeight.w700,
                            height: 1.04,
                          ),
                        )),
                  ],
                ),
              ))
        ],
      )),
    );
  }
}

deleteBidDialogBox(
    context, bool deleteLoading, Function() deleteBidInAPI, String deletedMsg) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Text(
          deletedMsg,
          textAlign: TextAlign.justify,
          style: TextStyle(
              fontFamily: 'inter',
              fontSize: 12,
              color: Provider.of<NavigationProvider>(context).themeMode ==
                      ThemeMode.dark
                  ? Colors.white
                  : titleTextColorLight,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          SizedBox(
            height: 25.0,
            child: Deleteappbutton(
              deleteLoading: deleteLoading,
              deleteApplication: () => deleteBidInAPI(),
            ),
          ),
          SizedBox(
            height: 25.0,
            child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0))),
                    backgroundColor: MaterialStatePropertyAll(
                        Provider.of<NavigationProvider>(context).themeMode ==
                                ThemeMode.dark
                            ? Colors.white
                            : appPrimeColor)),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'No',
                  style: TextStyle(
                      fontFamily: 'inter',
                      fontSize: 12,
                      color:
                          Provider.of<NavigationProvider>(context).themeMode ==
                                  ThemeMode.dark
                              ? Colors.black
                              : Colors.white),
                )),
          ),
          SizedBox(
            width: 10.0,
          )
        ],
      );
    },
  );
}

class Deleteappbutton extends StatefulWidget {
  Deleteappbutton(
      {super.key,
      required this.deleteLoading,
      required this.deleteApplication});
  bool deleteLoading;
  final deleteApplication;

  @override
  State<Deleteappbutton> createState() => _DeleteappbuttonState();
}

class _DeleteappbuttonState extends State<Deleteappbutton> {
  onChange() {
    setState(() {
      widget.deleteLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0))),
            backgroundColor: MaterialStatePropertyAll(
                Provider.of<NavigationProvider>(context).themeMode ==
                        ThemeMode.dark
                    ? Colors.white
                    : appPrimeColor)),
        onPressed: widget.deleteLoading
            ? null
            : () {
                onChange();

                widget.deleteApplication();
                Navigator.pop(context);
              },
        child: Text(
          'Yes',
          style: TextStyle(
              fontFamily: 'inter',
              fontSize: 12.0,
              color: Provider.of<NavigationProvider>(context).themeMode ==
                      ThemeMode.dark
                  ? Colors.black
                  : Colors.white),
        ));
  }
}
