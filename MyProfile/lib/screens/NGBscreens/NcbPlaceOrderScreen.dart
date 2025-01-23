// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novo/API/APICall.dart';
import 'package:novo/Provider/change_index.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/ncbModels/ncbmasterModel.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/utils/colors.dart';

import 'package:provider/provider.dart';
import '../../widgets/NOVO Widgets/LoadingAlertBox.dart';
import '../../widgets/NOVO Widgets/infoContainer.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../widgets/NOVO Widgets/snackbar.dart';
import '/Roating/route.dart' as route;

class NcbPlaceOrderScreen extends StatefulWidget {
  NcbPlaceOrderScreen(
      {super.key, required this.ncbMasterDetails, required this.index});
  final Detail ncbMasterDetails;
  int index;

  @override
  State<NcbPlaceOrderScreen> createState() => _NcbPlaceOrderScreenState();
}

class _NcbPlaceOrderScreenState extends State<NcbPlaceOrderScreen> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool submitLoading = false;
  bool deleteLoading = false;
  bool buttonDisable = true;
  bool recheck = false;
  bool isChecked = false;
  String? CateText;

  int amountPayable = 0;
  int totalAmount = 0;
  int totalDiscountAmount = 0;

  dynamic accountBalance = 0.0;
  double textHeight = 1.5;

  @override
  void initState() {
    super.initState();
    intialationFunc();
  }

  intialationFunc() {
    // //////////print('sdlfjjdsf');

    priceController.text = widget.ncbMasterDetails.unitPrice.toString();
    quantityController.text = widget.ncbMasterDetails.actionFlag == 'M'
        ? widget.ncbMasterDetails.appliedUnit.toString()
        : widget.ncbMasterDetails.minBidQuantity.toString();
    totalAmount =
        int.parse(priceController.text) * int.parse(quantityController.text);

    totalDiscountAmount = int.parse(quantityController.text) *
        widget.ncbMasterDetails.discountAmt!;
    amountPayable = totalAmount - totalDiscountAmount;
    CateText = widget.ncbMasterDetails.series == 'GS'
        ? 'Govt.Bonds'
        : widget.ncbMasterDetails.series == 'TB'
            ? 'T-Bills'
            : widget.ncbMasterDetails.series == 'SG'
                ? 'SDL'
                : 'G-sec';

    isChecked = widget.ncbMasterDetails.sIvalue!;
    if (widget.ncbMasterDetails.actionFlag == 'M' ||
        widget.ncbMasterDetails.actionFlag == 'A' ||
        widget.ncbMasterDetails.actionFlag == 'C' ||
        widget.ncbMasterDetails.multiples == 0) {
      setState(() {
        buttonDisable = true;
      });
    } else {
      setState(() {
        buttonDisable = false;
      });
    }
  }

  sIShowCheckFunc() async {
    //////////print('1');
    setState(() {
      recheck = true;
    });
    //////////print(widget.ncbMasterDetails.showSi!);
    if (widget.ncbMasterDetails.showSi!) {
      if (isChecked) {
        postSgbPlaceOrder();
      } else {
        showSnackbar(
            context, "Agree to Terms and Place Order", primaryRedColor);
      }
    } else {
      postSgbPlaceOrder();

      // isChecked = false;
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

        if (widget.ncbMasterDetails.actionFlag == 'B' ||
            widget.ncbMasterDetails.actionFlag == 'P') {
          placeOrderDetailsMap = {
            "masterId": widget.ncbMasterDetails.id,
            "unit": int.parse(quantityController.text),
            "oldUnit": widget.ncbMasterDetails.appliedUnit,
            "actionType": "N",
            "price": widget.ncbMasterDetails.unitPrice!.toDouble() -
                widget.ncbMasterDetails.discountAmt!.toDouble(),
            "orderNo": widget.ncbMasterDetails.orderNo,
            "series": widget.ncbMasterDetails.series,
            "amount": amountPayable.toDouble(),
            "SItext": widget.ncbMasterDetails.sItext,
            "SIvalue": isChecked,
          };

          loadingAlertBox(context, 'Applying $CateText...');
        } else if (widget.ncbMasterDetails.actionFlag == 'M' ||
            widget.ncbMasterDetails.actionFlag == 'A') {
          if (int.parse(quantityController.text) !=
              widget.ncbMasterDetails.appliedUnit) {
            placeOrderDetailsMap = {
              "masterId": widget.ncbMasterDetails.id,
              "unit": int.parse(quantityController.text),
              "oldUnit": widget.ncbMasterDetails.appliedUnit,
              "actionType": "M",
              "price": widget.ncbMasterDetails.unitPrice!.toDouble() -
                  widget.ncbMasterDetails.discountAmt!.toDouble(),
              "orderNo": widget.ncbMasterDetails.orderNo,
              "series": widget.ncbMasterDetails.series,
              "amount": amountPayable.toDouble(),
              "SItext": widget.ncbMasterDetails.sItext,
              "SIvalue": isChecked,
            };

            loadingAlertBox(context, 'Modifying $CateText...');
          }
          // else {
          //   //////////print('modifyFalse');
          //   showSnackbar(
          //       context, 'Please Modify the Quantity...', primaryRedColor);
          // }
        }

        Map? placeorderResponse = await ncbPlaceOrderApi(
            context: context, postBidDetails: placeOrderDetailsMap!);

        if (placeorderResponse != null && placeorderResponse.isNotEmpty) {
          if (placeorderResponse['status'] == 'S') {
            showSnackbar(
                context, placeorderResponse['orderStatus'], primaryGreenColor);
            ChangeNCBIndex().changeNCBIndex(widget.index);
            Navigator.pushNamed(context, route.novoPage);
          } else {
            Navigator.pop(context);
            showSnackbar(
                context, placeorderResponse['errMsg'], primaryRedColor);
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
      //  else {
      //   //////////print('else');
      //   // placeOrderDetailsMap = {};
      //   //////////print(placeOrderDetailsMap);
      //   // showSnackbar(context, 'Something went to Wrong...', primaryRedColor);
      // }
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
          "masterId": widget.ncbMasterDetails.id,
          "unit": int.parse(quantityController.text),
          "oldUnit": widget.ncbMasterDetails.appliedUnit,
          "actionType": "D",
          "price": widget.ncbMasterDetails.unitPrice!.toDouble(),
          "orderNo": widget.ncbMasterDetails.orderNo,
          "series": widget.ncbMasterDetails.series,
          // (ActionCodes : "N","M","C")
          "amount": amountPayable.toDouble(),
          "SItext": widget.ncbMasterDetails.sItext,
          "SIvalue": isChecked,
          // (*Compulsory for modify & cancel)

          // (*Compulsory for modify & cancel)
          // (*Generate random number for "NEW" and Compulsory return the Actual orderNo for modify & cancel)
        };

        // Navigator.of(context).pop();
        loadingAlertBox(context, 'Deleting $CateText...');
        // Navigator.of(context).pop();
        Map? placeorderResponse =
            await ncbPlaceOrderApi(context: context, postBidDetails: deleteApp);

        if (placeorderResponse != null && placeorderResponse.isNotEmpty) {
          if (placeorderResponse['status'] == 'S') {
            showSnackbar(
                context, placeorderResponse['orderStatus'], primaryGreenColor);
            // ChangeNCBIndex().
            ChangeNCBIndex().changeNCBIndex(widget.index);

            Navigator.pushNamed(context, route.novoPage);
          } else {
            showSnackbar(
                context, placeorderResponse['errMsg'], primaryRedColor);
            Navigator.pop(context);
          }
        } else {
          //////////print('DeleteOrder is null value throw');
          // Navigator.pop(context);
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
          widget.ncbMasterDetails.discountAmt!;
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
    if (currentQuantity < widget.ncbMasterDetails.maxBidQuantity!) {
      quantityController.text =
          (currentQuantity + widget.ncbMasterDetails.multiples!).toString();

      totalCalculation();
    }
  }

  decrementUnitValue() {
    String currentValue = quantityController.text;
    int currentQuantity = int.tryParse(currentValue) ?? 0;
    if (currentQuantity > widget.ncbMasterDetails.minBidQuantity!) {
      quantityController.text =
          (currentQuantity - widget.ncbMasterDetails.multiples!).toString();
      totalCalculation();
    }
  }

  quantityOnChange(value) {
    quantityValidator(value);
    // modifyValidation(value);
    totalCalculation();
  }

  modifyValidation() {
    if (quantityController.text !=
            widget.ncbMasterDetails.appliedUnit.toString() &&
        quantityController.text != '0' &&
        quantityController.text.isNotEmpty) {
      buttonDisable = false;
    } else {
      buttonDisable = true;
    }
  }

  quantityValidator(value) {
    // modifyValidation(value);
    int? parsedValue = int.tryParse(value);
    if (parsedValue == null ||
        parsedValue % widget.ncbMasterDetails.multiples! != 0) {
      return 'Enter a valid multiple of ${widget.ncbMasterDetails.multiples!}';
    }
    if (value.isEmpty || value == null) {
      return '';
    }
    if (int.parse(value) < widget.ncbMasterDetails.minBidQuantity! ||
        int.parse(value) > widget.ncbMasterDetails.maxBidQuantity!) {
      return '${widget.ncbMasterDetails.minBidQuantity}-${widget.ncbMasterDetails.maxBidQuantity}';
    }
    return null;
  }

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.ncbMasterDetails.series == 'GS'
                ? Image.asset(
                    Provider.of<NavigationProvider>(context).themeMode ==
                            ThemeMode.dark
                        ? "assets/GOI white.png"
                        : "assets/GOI_2.png",
                    width: 26.0,
                  )
                : widget.ncbMasterDetails.series == 'TB'
                    ? Image.asset(
                        Provider.of<NavigationProvider>(context).themeMode ==
                                ThemeMode.dark
                            ? "assets/GSEC White.png"
                            : "assets/GSEC_1.png",
                        width: 26.0,
                      )
                    : widget.ncbMasterDetails.series == 'SG'
                        ? Image.asset(
                            Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? "assets/SDL White.png"
                                : "assets/SDL.png",
                            width: 26.0,
                          )
                        : Image.asset(
                            Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? "assets/NCB W.png"
                                : "assets/NCB B.png",
                            width: 28.0,
                          ),
            // Image.asset(
            //   widget.ncbMasterDetails.series == 'GS'
            //       ? "assets/gseclogo.png"
            //       : widget.ncbMasterDetails.series == 'TB'
            //           ? "assets/tbillsLogo.png"
            //           : "assets/SdlLogo.png",
            //   width: 15.0,
            // ),
            const SizedBox(
              width: 10.0,
            ),
            Flexible(
              child: Text(
                widget.ncbMasterDetails.symbol!,
                overflow: TextOverflow.visible,
                style: lightThemeMode
                    ? ThemeClass.lighttheme.textTheme.titleMedium
                    : ThemeClass.Darktheme.textTheme.titleMedium,
              ),
            ),
          ],
        ),

        // Text(widget.ncbMasterDetails.symbol!,
        //     overflow: TextOverflow.visible,
        //     style: lightThemeMode
        //         ? ThemeClass.lighttheme.textTheme.titleMedium
        //         : ThemeClass.Darktheme.textTheme.titleMedium),

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
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Image.asset(
                      //       widget.ncbMasterDetails.series == 'GS'
                      //           ? "assets/gseclogo.png"
                      //           : widget.ncbMasterDetails.series == 'TB'
                      //               ? "assets/tbillsLogo.png"
                      //               : "assets/SdlLogo.png",
                      //       width: 25.0,
                      //     ),
                      //     const SizedBox(
                      //       width: 10.0,
                      //     ),
                      //     Flexible(
                      //       child: Text(
                      //         widget.ncbMasterDetails.name!,
                      //         overflow: TextOverflow.visible,
                      //         style: lightThemeMode
                      //             ? ThemeClass.lighttheme.textTheme.titleMedium
                      //             : ThemeClass.Darktheme.textTheme.titleMedium,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(
                      //   height: 10.0,
                      // ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unit Price',
                                    style: ThemeClass
                                        .lighttheme.textTheme.displayMedium,
                                  ),
                                  Text(
                                    "${widget.ncbMasterDetails.unitPrice}",
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
                                ],
                              ),
                              Visibility(
                                visible: widget.ncbMasterDetails.cancelAllowed!,
                                child: InkWell(
                                    // style: ElevatedButton.styleFrom(
                                    //     // padding: EdgeInsets.zero,
                                    //     backgroundColor: Colors.red),
                                    onTap: () {
                                      deleteBidDialogBox(
                                        context,
                                        deleteLoading,
                                        // () => deleteBidInAPI(),
                                        () => deleteBidInAPI(),
                                        widget.ncbMasterDetails.sIrefundText!,
                                      );
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: primaryRedColor,
                                    )),
                              )
                              // Visibility(
                              //   visible:
                              //       widget.ncbMasterDetails.discountAmt! > 0,
                              //   child: Column(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     crossAxisAlignment: CrossAxisAlignment.end,
                              //     children: [
                              //       Text(
                              //         '${widget.ncbMasterDetails.discountText}',
                              //         style: ThemeClass
                              //             .lighttheme.textTheme.displayMedium,
                              //       ),
                              //       Text(
                              //         '${widget.ncbMasterDetails.discountAmt == 0 ? 'NA' : widget.ncbMasterDetails.discountAmt}',
                              //         style: lightThemeMode
                              //             ? ThemeClass
                              //                 .lighttheme.textTheme.titleMedium!
                              //                 .copyWith(
                              //                 height: textHeight,
                              //               )
                              //             : ThemeClass
                              //                 .Darktheme.textTheme.titleMedium!
                              //                 .copyWith(
                              //                 height: textHeight,
                              //               ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Indicative yield',
                                    style: ThemeClass
                                        .lighttheme.textTheme.displayMedium,
                                  ),
                                  Text(
                                    '${widget.ncbMasterDetails.indicativeYield}',
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
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Maturity',
                                    style: ThemeClass
                                        .lighttheme.textTheme.displayMedium,
                                  ),
                                  Text(
                                    '${widget.ncbMasterDetails.maturityDate}',
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
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Visibility(
                        visible: widget.ncbMasterDetails.infoText!.isNotEmpty,
                        child: InfoContainer(
                          infoMsg: widget.ncbMasterDetails.infoText!,
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Visibility(
                        visible: widget.ncbMasterDetails.discountAmt! > 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.ncbMasterDetails.discountText}',
                              style:
                                  ThemeClass.lighttheme.textTheme.displayMedium,
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              '${widget.ncbMasterDetails.discountAmt == 0 ? 'NA' : widget.ncbMasterDetails.discountAmt}',
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
                      // Visibility(
                      //   visible: widget.ncbMasterDetails.cancelAllowed!,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //       InkWell(
                      //           // style: ElevatedButton.styleFrom(
                      //           //     // padding: EdgeInsets.zero,
                      //           //     backgroundColor: Colors.red),
                      //           onTap: () {
                      //             deleteBidDialogBox(
                      //               context,
                      //               deleteLoading,
                      //               // () => deleteBidInAPI(),
                      //               () => deleteBidInAPI(),
                      //               widget.ncbMasterDetails.sIrefundText!,
                      //             );
                      //           },
                      //           child: Icon(
                      //             Icons.delete,
                      //             color: primaryRedColor,
                      //           )),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Container(
                        // color: sgbPrimaryColor,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                                // style: BorderStyle.solid,
                                color:
                                    // themeBasedColor
                                    darkThemeMode
                                        ? Colors.grey
                                        : const Color.fromRGBO(
                                            235, 237, 236, 1)),
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
                            // color: Colors.white

                            color: lightThemeMode
                                ? titleTextColorDark
                                : Colors.transparent),
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last bid: ',
                              style:
                                  ThemeClass.lighttheme.textTheme.displayMedium,
                            ),
                            Text(widget.ncbMasterDetails.endDateWithTime!,
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
                            const SizedBox(
                              height: 15.0,
                            ),
                            Container(
                                // margin: const EdgeInsets.only(bottom: 20.0),
                                // height: 218,
                                decoration: BoxDecoration(
                                  // color: Colors.white,
                                  border: Border.all(
                                    color:
                                        const Color.fromRGBO(235, 237, 236, 1),
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: const Color.fromARGB(
                                  //             255, 230, 228, 228)
                                  //         .withOpacity(0.3),
                                  //     offset: const Offset(0,
                                  //         1.0), // Offset (x, y) controls the shadow's position
                                  //     blurRadius: 15, // Spread of the shadow
                                  //     spreadRadius:
                                  //         5.0, // Positive values expand the shadow, negative values shrink it
                                  //   ),
                                  // ],
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
                                        enabled: widget.ncbMasterDetails
                                                .modifyAllowed! &&
                                            widget.ncbMasterDetails.multiples !=
                                                0,
                                        controller: quantityController,
                                        maxLength: widget
                                            .ncbMasterDetails.maxBidQuantity
                                            .toString()
                                            .length,
                                        validator: (value) =>
                                            quantityValidator(value),
                                        onChanged: (value) {
                                          quantityOnChange(value);
                                        },

                                        decoration: InputDecoration(
                                          disabledBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color.fromRGBO(
                                                          235, 237, 236, 1),
                                                      width: 2.0)),
                                          // isDense: true,
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color.fromRGBO(
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
                                            visible: widget.ncbMasterDetails
                                                    .modifyAllowed! &&
                                                widget.ncbMasterDetails
                                                        .multiples !=
                                                    0,
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
                                              visible: widget.ncbMasterDetails
                                                      .modifyAllowed! &&
                                                  widget.ncbMasterDetails
                                                          .multiples !=
                                                      0,
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
                                      // Visibility(
                                      //   visible: widget.applyMethod == null,
                                      //   child: Visibility(
                                      //     visible: quantityController.text !=
                                      //         widget.sgbPlaceOrderdetails.unit,
                                      //     child: InkWell(
                                      //       onTap: () {},
                                      //       child: Text('UNDO'),
                                      //     ),
                                      //   ),
                                      // )
                                    ],
                                  ),
                                )),
                            const SizedBox(
                              height: 40.0,
                            ),
                            Text(
                              'Settlement: ',
                              style:
                                  ThemeClass.lighttheme.textTheme.displayMedium,
                            ),
                            Text(
                              widget.ncbMasterDetails.settlementDate!,
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
                            const SizedBox(
                              height: 15.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Visibility(
                        visible: widget.ncbMasterDetails.showSi!,
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
                                margin: const EdgeInsets.only(top: 4.0),
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
                              const SizedBox(
                                width: 12.0,
                              ),
                              Expanded(
                                // width: MediaQuery.of(context).size.width *
                                //     0.78, // Set the maximum width as a percentage of the screen width
                                child: Text(
                                  widget.ncbMasterDetails.sItext!,
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
              const SizedBox(
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
                    ? const Color.fromRGBO(48, 48, 48, 1)
                    : const Color.fromRGBO(240, 240, 240, 1),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /*Total Amount Section...*/
                    Container(
                      // height: 40.0,
                      padding: const EdgeInsets.symmetric(
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
                          // Visibility(
                          //   visible: totalDiscountAmount != 0,
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         'Total :',
                          //         style: TextStyle(
                          //             fontFamily: 'inter',
                          //             color: Provider.of<NavigationProvider>(
                          //                             context)
                          //                         .themeMode ==
                          //                     ThemeMode.dark
                          //                 ? Colors.black
                          //                 : titleTextColorLight,
                          //             fontSize: 14.0,
                          //             height: 1.0,
                          //             fontWeight: FontWeight.bold),
                          //       ),
                          //       Text(
                          //         rsFormat.format(totalAmount),
                          //         // ' ${widget.ncbMasterDetails.discountAmt}',
                          //         style: TextStyle(
                          //             fontFamily: 'inter',
                          //             color: Provider.of<NavigationProvider>(
                          //                             context)
                          //                         .themeMode ==
                          //                     ThemeMode.dark
                          //                 ? Colors.black
                          //                 : titleTextColorLight,
                          //             //  total == 0.0
                          //             //     ? Colors.black
                          //             //     :
                          //             //     total <= accountBalance
                          //             //         ? primaryGreenColor
                          //             //         : primaryRedColor,
                          //             fontSize: 16.0,
                          //             height: 1.0,
                          //             fontWeight: FontWeight.bold),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // Visibility(
                          //   visible: totalDiscountAmount != 0,
                          //   child: SizedBox(
                          //     height: 5.0,
                          //   ),
                          // ),
                          // Visibility(
                          //   visible: totalDiscountAmount != 0,
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         '${widget.ncbMasterDetails.discountText} :',
                          //         style: TextStyle(
                          //             fontFamily: 'inter',
                          //             color: Provider.of<NavigationProvider>(
                          //                             context)
                          //                         .themeMode ==
                          //                     ThemeMode.dark
                          //                 ? Colors.black
                          //                 : titleTextColorLight,
                          //             fontSize: 14.0,
                          //             height: 1.0,
                          //             fontWeight: FontWeight.bold),
                          //       ),
                          //       Text(
                          //         rsFormat.format(totalDiscountAmount),
                          //         // ' ${widget.ncbMasterDetails.discountAmt}',
                          //         style: TextStyle(
                          //             fontFamily: 'inter',
                          //             color: Provider.of<NavigationProvider>(
                          //                             context)
                          //                         .themeMode ==
                          //                     ThemeMode.dark
                          //                 ? Colors.black
                          //                 : titleTextColorLight,
                          //             //  total == 0.0
                          //             //     ? Colors.black
                          //             //     :
                          //             //     total <= accountBalance
                          //             //         ? primaryGreenColor
                          //             //         : primaryRedColor,
                          //             fontSize: 16.0,
                          //             height: 1.0,
                          //             fontWeight: FontWeight.bold),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 5.0,
                          // ),
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
                                    // Provider.of<NavigationProvider>(context)
                                    //             .themeMode ==
                                    //         ThemeMode.dark
                                    //     ? Colors.black
                                    //     : titleTextColorLight,
                                    //  total == 0.0
                                    //     ? Colors.black
                                    //     :
                                    //     total <= accountBalance
                                    //         ? primaryGreenColor
                                    //         : primaryRedColor,
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

                                // postSgbPlaceOrder();

                                // widget.ncbMasterDetails.actionFlag == 'B' ||
                                //         widget.ncbMasterDetails.actionFlag ==
                                //             'P'
                                //     ? onPlaceOrder()
                                //     : modifiedBidInAPI();
                                // // widget.ncbMasterDetails.actionFlag == 'M'
                                // //     ? modifiedBidInAPI()
                                // //     : widget.ncbMasterDetails.actionFlag ==
                                // //             'A'
                                // //         ? null
                                // //         : '';
                                // //////////print('place Order');
                                // widget.applyMethod != null
                                //     ? onPlaceOrder()
                                //     : modifiedBidInAPI();

                                // deleteBidInAPI();
                              },
                        child: Text(
                          widget.ncbMasterDetails.buttonText!,
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
              deleteApplication: () =>
                  // //////////print('deleted')
                  deleteBidInAPI(),
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
          const SizedBox(
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
