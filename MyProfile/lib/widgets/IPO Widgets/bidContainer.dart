// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/colors.dart';
import 'package:provider/provider.dart';

class BidFieldWidget extends StatefulWidget {
  int index;
  final Function(int) removeContainer;
  final Function calculateHighestTotal;
  var onChangeVerification;
  var onbuttonValidation;
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  bool checkbox = false;
  final String? priceControllerValue;
  final String? quantityControllerValue;
  final String? totalControllerValue;
  bool checkboxValue;
  bool cancelButtonEnable;
  bool modifyAllowed;
  String catePurFlag;
  bool hniEnable;

  final int lot;
  final int bidminPrice;
  final int minPrice;
  final int minQty;
  final int cutOfPrice;
  final dynamic cutOffFlag;
  int discountPrice;
  String discountType;
  BidFieldWidget({
    super.key,
    required this.index,
    required this.removeContainer,
    required this.calculateHighestTotal,
    required this.lot,
    required this.bidminPrice,
    required this.minPrice,
    required this.minQty,
    required this.cutOfPrice,
    required this.cutOffFlag,
    required this.onChangeVerification,
    this.checkboxValue = true,
    this.priceControllerValue,
    this.quantityControllerValue,
    this.totalControllerValue,
    this.cancelButtonEnable = true,
    required this.modifyAllowed,
    required this.catePurFlag,
    required this.discountPrice,
    required this.discountType,
    required this.onbuttonValidation,
    required this.hniEnable,
  }) {
    checkbox = checkboxValue;

    priceController.text = priceControllerValue ?? '$cutOfPrice';
    quantityController.text = quantityControllerValue ?? '$minQty';
    dynamic total = int.parse(quantityController.text) *
        (int.parse(priceController.text)) *
        lot;

    // discountType == "A"
    //     // ? quantityController.text * (int.parse(priceController.text)  - discountPrice) * lot
    //     // : quantityController.text * (int.parse(priceController.text) - (priceController.text * categoryDiscount! / 100)) * lot;
    //     ? int.parse(quantityController.text) *
    //         (int.parse(priceController.text) - discountPrice) *
    //         lot
    //     : int.parse(quantityController.text) *
    //         lot *
    //         (int.parse(priceController.text) -
    //             (int.parse(priceController.text) * discountPrice / 100))

    // (double.parse(priceController.text) * discountPrice / 100)
    // ;

    totalController.text = totalControllerValue ?? '$total';
  }

  @override
  State<BidFieldWidget> createState() => _BidFieldWidgetState();
  void updateIndex(int newIndex) {
    index = newIndex;
  }

  void clearControllers() {
    quantityController.clear();
    priceController.clear();
  }
}

class _BidFieldWidgetState extends State<BidFieldWidget> {
  void onchangecheckBoxValue(value) {
    if (widget.cutOffFlag!) {
      widget.checkbox = !widget.checkbox;
      if (widget.checkbox == true) {
        widget.priceController.text = widget.cutOfPrice.toString();
      } else {
        widget.priceController.text = widget.bidminPrice.toString();
      }
      calculateTotal();
    }
    widget.onChangeVerification(true);
    widget.onbuttonValidation();
    // _formKey1.currentState!.validate();
  }

  int? categoryDiscount;
  String? categoryType;
  void calculateTotal() {
    setState(() {
      if (widget.quantityController.text.isNotEmpty &&
          widget.priceController.text.isNotEmpty) {
        int quantity = int.tryParse(widget.quantityController.text) ?? 0;
        int price = int.tryParse(widget.priceController.text) ?? 0;
        // ////////print('categoryDiscount');
        // ////////print(categoryDiscount);
        // ////////print(' widget.discountType');
        // ////////print(widget.discountType);

        dynamic total = quantity * price * widget.lot;

        // categoryType == "A"
        //     ? quantity * (price - categoryDiscount!) * widget.lot
        //     : quantity *
        //         widget.lot *
        //         (price - (price * categoryDiscount! / 100));

        widget.totalController.text = total.toString();
        // ////////print('^^^^^^^^^^');
        // ////////print('quantity$quantity');
        // ////////print('price$price');
        // ////////print('total$total');
        // ////////print('^^^^^^^^^^');

        widget.calculateHighestTotal();
      } else {
        widget.totalController.text = '0';
        widget.calculateHighestTotal();
      }
      widget.onbuttonValidation();
    });
  }
  // calculatediscountTotal(int Lot,int quanity,int price){
  //   int total=

  // }

  // bool? isCheckboxEnabled;
  // void setCutOffFlag(bool flag) {
  //   setState(() {
  //     if (widget.cutOffFlag == 'Y') {
  //       isCheckboxEnabled = flag;
  //       widget.checkbox = widget.checkboxValue;
  //     } else {
  //       isCheckboxEnabled = false;
  //     }
  //   });
  // }

  priceValidator(value) {
    if (value == null || value.isEmpty) {
      return '';
    } else if (widget.cutOfPrice < int.parse(value) ||
        widget.minPrice > int.parse(value)) {
      return '${widget.minPrice}-${widget.cutOfPrice}';
    }
    return null;
  }

  quantityValidator(value) {
    if (value == null || value.isEmpty) {
      return '';
    } else if (int.parse(value) == 0) {
      return "";
    }
    return null;
  }

  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    categoryDiscount = widget.discountPrice;
    categoryType = widget.discountType;
    //print("widget.modifyAllowed");
    //print(widget.modifyAllowed);
    //print('________');
    //print(widget.catePurFlag);
    // isCheckboxEnabled = widget.cutOffFlag;
    ////print('checkbox...........');
    ////print(widget.cutOffFlag);
    ////print('checkboxValue...........');
    ////print(widget.cutOffFlag);
    setState(() {});

    // setCutOffFlag(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    return widget.catePurFlag == 'Y' && !widget.modifyAllowed
        ? Container(
            padding: const EdgeInsets.all(15.0),
            margin: const EdgeInsets.symmetric(vertical: 10),
            // margin: biddetail!.indexOf(biddata) !=
            //         biddetail!.length - 1
            //     ? const EdgeInsets.only(bottom: 15.0)
            //     : null,
            decoration: BoxDecoration(
                border: Border.all(
                    color: const Color.fromARGB(94, 151, 136, 136),
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
                      style:
                          TextStyle(fontSize: 12.0, color: subTitleTextColor),
                    ),
                    Text(
                      '${widget.quantityController.text}',
                      style: TextStyle(
                        fontSize: subTitleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Provider.of<NavigationProvider>(context)
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
                            fontSize: 12.0, color: subTitleTextColor)),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 1.0, bottom: 1.0, left: 5.0, right: 5.0),
                      decoration: BoxDecoration(
                          color: widget.checkbox == true
                              ? primaryGreenColor
                              : primaryOrangeColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0))),
                      child: Center(
                          child: widget.checkbox == true
                              ? const Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.0,
                                      fontWeight: FontWeight.bold),
                                )
                              : const Text(
                                  'No',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.0,
                                      fontWeight: FontWeight.bold),
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
                            fontSize: 12.0, color: subTitleTextColor)),
                    Text('${widget.priceController.text}',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: subTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Provider.of<NavigationProvider>(context)
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
                    // biddata.activityType == 'new' ||
                    //         biddata.activityType == 'modify'
                    //     ?
                    Text('Placed Bid',
                        style: TextStyle(
                            fontSize: subTitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: primaryGreenColor))
                    // : Text('Bid Deleted',
                    //     style: TextStyle(
                    //         fontSize: subTitleFontSize,
                    //         fontWeight: FontWeight.bold,
                    //         color: primaryRedColor))
                  ],
                )
              ],
            ),
          )
        : Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            // height: 218,
            decoration: BoxDecoration(
              color: Provider.of<NavigationProvider>(context).themeMode ==
                      ThemeMode.dark
                  ? const Color.fromRGBO(48, 48, 48, 1)
                  : Colors.white,
              border: Border.all(
                color: Provider.of<NavigationProvider>(context).themeMode ==
                        ThemeMode.dark
                    ? Colors.white10 // Light mode
                    : const Color.fromRGBO(235, 237, 236, 1),
              ),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: Provider.of<NavigationProvider>(context).themeMode ==
                      ThemeMode.dark
                  ? null
                  : [
                      BoxShadow(
                        color: const Color.fromARGB(255, 230, 228, 228)
                            .withOpacity(0.3),
                        offset: const Offset(0,
                            1.0), // Offset (x, y) controls the shadow's position
                        blurRadius: 15, // Spread of the shadow
                        spreadRadius:
                            5.0, // Positive values expand the shadow, negative values shrink it
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bid (${widget.index + 1}/3)',
                        style: TextStyle(
                            fontFamily: 'inter',
                            color: themeBasedColor,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold),
                      ),
                      Visibility(
                        visible: widget.cancelButtonEnable,
                        replacement: Visibility(
                          visible: widget.priceControllerValue !=
                                  widget.priceController.text ||
                              widget.quantityControllerValue !=
                                  widget.quantityController.text ||
                              widget.checkboxValue != widget.checkbox,
                          child: InkWell(
                              onTap: () {
                                widget.priceController.text =
                                    widget.priceControllerValue ?? '';
                                widget.quantityController.text =
                                    widget.quantityControllerValue ?? '';
                                widget.checkbox = widget.checkboxValue;
                                calculateTotal();
                                setState(() {});
                              },
                              child: Icon(
                                Icons.undo_rounded,
                                size: 23,
                                color: themeBasedColor,
                              )),
                        ),
                        child: Visibility(
                          visible: widget.index != 0,
                          child: InkWell(
                              onTap: () {
                                widget.removeContainer(widget.index);
                              },
                              child: Icon(Icons.cancel_outlined,
                                  size: 23, color: themeBasedColor)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        // width: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    focusNode: focusNode,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    textAlign: TextAlign.center,
                                    key: Key('quantity_${widget.index}'),
                                    controller: widget.quantityController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    // enabled: widget.modifyAllowed,
                                    style: TextStyle(
                                      fontFamily: 'inter',
                                      fontSize: subTitleFontSize,
                                      color: themeBasedColor,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]'))
                                    ],
                                    validator: (value) =>
                                        quantityValidator(value),
                                    onChanged: (value) {
                                      calculateTotal();

                                      // widget.onChangeVerification();
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Provider.of<NavigationProvider>(
                                                                  context)
                                                              .themeMode ==
                                                          ThemeMode.dark
                                                      ? Colors
                                                          .white10 // Light mode
                                                      : const Color.fromRGBO(
                                                          235, 237, 236, 1),
                                              width: 2.0)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: primaryGreenColor,
                                              width: 0.4)),
                                      counterText: '',
                                      labelText: 'No of Lot',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      hintText: '0',
                                      labelStyle: TextStyle(
                                          fontFamily: 'inter',
                                          height: 1.0,
                                          fontSize: 18,
                                          color: subTitleTextColor),
                                      errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: primaryRedColor
                                                  .withOpacity(1),
                                              width: 2)),
                                      contentPadding: EdgeInsets.zero,
                                      prefix: InkWell(
                                        onTap: () {
                                          String currentValue =
                                              widget.quantityController.text;
                                          int currentQuantity =
                                              int.tryParse(currentValue) ?? 0;
                                          if (currentQuantity > widget.minQty) {
                                            widget.quantityController.text =
                                                (currentQuantity - 1)
                                                    .toString();
                                            calculateTotal();
                                            // widget.onChangeVerification();
                                          }
                                        },
                                        child: Transform.scale(
                                          scale: 1.3,
                                          child: Text(
                                            '-',
                                            style: TextStyle(
                                              fontFamily: 'inter',
                                              color: int.parse(widget
                                                              .quantityController
                                                              .text
                                                              .isEmpty
                                                          ? '0'
                                                          : widget
                                                              .quantityController
                                                              .text) >
                                                      widget.minQty
                                                  ? subTitleTextColor
                                                  : subTitleTextColor
                                                      .withOpacity(0.3),
                                              fontSize: 24,
                                              height: 0.9,
                                              letterSpacing: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      suffix: InkWell(
                                        onTap: () {
                                          String currentValue =
                                              widget.quantityController.text;
                                          int currentQuantity =
                                              int.tryParse(currentValue) ?? 0;
                                          if (currentQuantity < widget.minQty) {
                                            widget.quantityController.text =
                                                widget.minQty.toString();
                                          } else {
                                            widget.quantityController.text =
                                                (currentQuantity + 1)
                                                    .toString();
                                          }

                                          calculateTotal();
                                          // widget.onChangeVerification();
                                        },
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
                              ],
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              'Qty: ${widget.quantityController.text.isNotEmpty ? (int.tryParse(widget.quantityController.text) ?? 0) * widget.lot : widget.lot}',
                              style: TextStyle(
                                fontFamily: 'inter',
                                fontSize: subTitleFontSize,
                                color: themeBasedColor,
                              ),
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Visibility(
                        replacement: const SizedBox(
                          width: 20.0,
                        ),
                        visible: widget.cutOffFlag!,
                        child: SizedBox(
                          height: 80,
                          // color: Colors.red,
                          child: GestureDetector(
                            onTap: widget.cutOffFlag!
                                ? () => onchangecheckBoxValue(!widget.checkbox)
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Transform.scale(
                                  scale: 0.8,
                                  child: Checkbox(
                                    activeColor:
                                        Provider.of<NavigationProvider>(context)
                                                    .themeMode ==
                                                ThemeMode.dark
                                            ? Colors.transparent
                                            : Colors.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    side: MaterialStateBorderSide.resolveWith(
                                      (states) => BorderSide(
                                          width: 2.0, color: subTitleTextColor),
                                    ),
                                    visualDensity: const VisualDensity(
                                      horizontal:
                                          -4.0, // Adjust the horizontal spacing
                                      vertical:
                                          -4.0, // Adjust the vertical spacing
                                    ),
                                    value: widget
                                        .checkbox, // Check when isChecked and enabled
                                    onChanged: widget.cutOffFlag!
                                        ? (value) {
                                            setState(() {
                                              onchangecheckBoxValue(value);
                                              widget.checkbox = value ??
                                                  false; // Update isChecked when enabled
                                            });
                                            // Handle checkbox change here
                                          }
                                        : null, // Disable the checkbox when not enabled
                                  ),
                                ),
                                Text(
                                  // 'total:${widget.totalController.text}',
                                  'Cutoff',
                                  style: TextStyle(
                                    fontFamily: 'inter',
                                    fontSize: subTitleFontSize,
                                    color: themeBasedColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              textAlign: widget.minPrice != widget.cutOfPrice
                                  ? TextAlign.center
                                  : TextAlign.left,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              style: TextStyle(
                                fontFamily: 'inter',
                                fontSize: subTitleFontSize,
                                color: themeBasedColor,
                              ),
                              key: Key('price_${widget.index}'),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'))
                              ],
                              controller: widget.priceController,
                              validator: (value) => priceValidator(value),
                              // enabled:
                              //     !widget.checkbox, //with out HNI condition
                              enabled: !widget.checkbox ||
                                  widget.hniEnable, //with HNI condition
                              maxLength: widget.cutOfPrice.toString().length,
                              onChanged: (value) {
                                setState(() {
                                  priceValidator(value);
                                });

                                calculateTotal();
                                // widget.onChangeVerification();
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Provider.of<NavigationProvider>(
                                                        context)
                                                    .themeMode ==
                                                ThemeMode.dark
                                            ? Colors.white10 // Light mode
                                            : const Color.fromRGBO(
                                                235, 237, 236, 1),
                                        width: 2.0)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Provider.of<NavigationProvider>(
                                                        context)
                                                    .themeMode ==
                                                ThemeMode.dark
                                            ? Colors.blue
                                            : primaryGreenColor,
                                        width: 0.4)),
                                counterText: '',
                                labelText: 'Price',
                                hintText: '0',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                    fontFamily: 'inter',
                                    height: 1.0,
                                    fontSize: 18,
                                    color: subTitleTextColor),
                                errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: primaryRedColor.withOpacity(1),
                                        width: 2)),
                                contentPadding: EdgeInsets.zero,
                                prefix: Visibility(
                                  visible: widget.minPrice != widget.cutOfPrice,
                                  child: InkWell(
                                    onTap: () {
                                      int currentPrice = int.tryParse(
                                              widget.priceController.text) ??
                                          0;
                                      if (currentPrice > widget.minPrice) {
                                        if (currentPrice > widget.cutOfPrice) {
                                          widget.priceController.text =
                                              widget.cutOfPrice.toString();
                                        } else {
                                          widget.priceController.text =
                                              (currentPrice - 1).toString();
                                        }

                                        calculateTotal();
                                      }
                                    },
                                    child: Transform.scale(
                                      scale: 1.3,
                                      child: Text(
                                        '-',
                                        style: TextStyle(
                                          fontFamily: 'inter',
                                          color: int.parse(widget
                                                              .priceController
                                                              .text
                                                              .isEmpty
                                                          ? '0'
                                                          : widget
                                                              .priceController
                                                              .text) >
                                                      widget.minPrice &&
                                                  (widget.checkbox == false ||
                                                      widget.hniEnable)
                                              ? subTitleTextColor
                                              : subTitleTextColor
                                                  .withOpacity(0.3),
                                          fontSize: 24,
                                          height: 0.9,
                                          letterSpacing: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                suffix: Visibility(
                                  visible: widget.minPrice != widget.cutOfPrice,
                                  child: InkWell(
                                    onTap: () {
                                      // String currentValue =
                                      //     widget.priceController.text;
                                      int currentPrice = int.tryParse(
                                              widget.priceController.text) ??
                                          0;
                                      if (currentPrice < widget.cutOfPrice) {
                                        if (currentPrice < widget.minPrice) {
                                          widget.priceController.text =
                                              widget.minPrice.toString();
                                        } else {
                                          widget.priceController.text =
                                              (currentPrice + 1).toString();
                                        }
                                        calculateTotal();
                                      }

                                      // widget.onChangeVerification();
                                    },
                                    child: Text(
                                      '+',
                                      style: TextStyle(
                                        fontFamily: 'inter',
                                        color: int.parse(widget.priceController
                                                        .text.isEmpty
                                                    ? '0'
                                                    : widget
                                                        .priceController.text) <
                                                widget.cutOfPrice
                                            ? subTitleTextColor
                                            : subTitleTextColor
                                                .withOpacity(0.3),
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
                            FittedBox(
                              child: Text(
                                  '\u20B9${widget.minPrice} - \u20B9${widget.cutOfPrice}',
                                  style: TextStyle(
                                    fontFamily: 'inter',
                                    fontSize: subTitleFontSize,
                                    color: themeBasedColor,
                                  )),
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ));
  }
}
