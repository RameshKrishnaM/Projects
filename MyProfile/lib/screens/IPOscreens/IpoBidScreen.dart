// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, must_be_immutable, file_names, prefer_typing_uninitialized_variables

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:novo/API/APICall.dart';
import 'package:novo/Provider/provider.dart';

import 'package:novo/model/ipoModels/ipoMasterDetails.dart';

import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/utils/colors.dart';
import 'package:novo/utils/launchurl.dart';
import 'package:novo/widgets/IPO%20Widgets/hniCategoryBottomSheet.dart';
import 'package:novo/widgets/IPO%20Widgets/ipoFooter.dart';
import 'package:provider/provider.dart';
import '../../widgets/IPO Widgets/bidContainer.dart';

import '../../widgets/NOVO Widgets/LoadingAlertBox.dart';
import '../../widgets/NOVO Widgets/infoContainer.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionAlertBox.dart';
import '../../widgets/NOVO Widgets/snackbar.dart';
import '../../widgets/NOVO Widgets/validationformat.dart';
import '/Roating/route.dart' as route;

enum Availability { loading, available, unavailable }

class BidScreen extends StatefulWidget {
  const BidScreen({
    super.key,
    required this.bidscreendetails,
    required this.bidCategoryData,
    required this.suggestUPI,
  });

  final CategoryList bidCategoryData;
  final IpoDetail bidscreendetails;
  final String suggestUPI;
  @override
  State<BidScreen> createState() => _BidScreenState();
}

class _BidScreenState extends State<BidScreen> {
  bool addenable = true;
  bool deleteLoading = false;
  // bool isChecked = false;
  bool isLoaded = true;
  bool onchange = false;
  bool recheck = false;
  bool submitLoading = false;
  bool upiread = false;
  dynamic amountPayable = 0;
  List bidList = [];

  List<BidFieldWidget> containers = [];

  dynamic discountApplied = 0;
  Color? highestColor;

  int? maxTotalValue;
  int? minTotalValue;
  bool? showSI;
  bool? siValue;
  String? siText;
  String? categoryValue;
  String? categorytext;
  String? infotext;
  String? cateResetText;
  String? cateChangeText;
  bool? showDiscount;
  bool? modifyAllowed;
  String? catePurFlag;
  String? appNo;
  String? appliedUpiId;
  bool? hniIndicator;

  int minLot = 1;
  int? minPrice;

  List? cateDisclaimer;
  bool hniEnable = false;
  bool? cutOffFlag;
  // int minQty = 1;
  String? hniApplicable;
  String? buttonText;
  bool isDeleteIndicator = false;

  // List of items for the dropdown

  List<AppliedBid>? modifyDetails;

  Map? placeOrderDetailsMap;
  Map qpvalues = {};

  int totalAmount = 0;
  TextEditingController upiController = TextEditingController();
  String upiEndPoint = '';
  String upiId = '';
  String upiIdStart = '';
  int selectedTilevalue = 1;
  bool buttonEnable = false;
  indInitializer() {
    maxTotalValue = widget.bidCategoryData.maxValue;
    minTotalValue = widget.bidCategoryData.minValue;
    categoryValue = widget.bidCategoryData.code;
    categorytext = widget.bidCategoryData.category;
    hniApplicable = 'N';
    hniEnable = false;
    infotext = widget.bidCategoryData.infoText;
    cateResetText = widget.bidCategoryData.indRangeText;

    cateChangeText = widget.bidCategoryData.subCategoryInfoText;
    cateDisclaimer = widget.bidCategoryData.categorydisclaimerText;
    cutOffFlag = widget.bidCategoryData.cutOffFlag;
    siText = widget.bidCategoryData.sItext;
    siValue = widget.bidCategoryData.sIvalue;
    showSI = widget.bidCategoryData.showSi;
    buttonText = widget.bidCategoryData.categoryButtonText;
    showDiscount = widget.bidCategoryData.showDiscount;
    modifyAllowed = widget.bidCategoryData.modifyAllowed;
    catePurFlag = widget.bidCategoryData.purchaseFlag;
    appNo = widget.bidCategoryData.applicationNo;
    appliedUpiId = widget.bidCategoryData.appliedDetail!.appliedUpi!;
    minLot = widget.bidCategoryData.minimumlot ?? 1;
    hniIndicator = false;
    minPrice = widget.bidscreendetails.minPrice!;
    print(cutOffFlag);
    print("ind cuttoff");
    setState(() {});
  }

  hniIntializer() {
    hniApplicable = 'Y';
    minTotalValue = widget.bidCategoryData.subCategoryList![0].minValue;
    maxTotalValue = widget.bidCategoryData.subCategoryList![0].maxValue;
    categorytext = widget.bidCategoryData.subCategoryList![0].category;
    categoryValue = widget.bidCategoryData.subCategoryList![0].code;
    infotext = widget.bidCategoryData.subCategoryList![0].infoText;
    hniEnable = true;
    cateResetText = widget.bidCategoryData.hniRangeText;

    cateChangeText = widget.bidCategoryData.categoryorderText;
    cateDisclaimer =
        widget.bidCategoryData.subCategoryList![0].categorydisclaimerText;
    cutOffFlag = widget.bidCategoryData.subCategoryList![0].cutOffFlag;
    siText = widget.bidCategoryData.subCategoryList![0].sItext;
    siValue = widget.bidCategoryData.subCategoryList![0].sIvalue;
    showSI = widget.bidCategoryData.subCategoryList![0].showSi;
    minLot = widget.bidCategoryData.subCategoryList![0].minimumlot ?? 1;
    showDiscount = widget.bidCategoryData.subCategoryList![0].showDiscount;
    modifyAllowed = widget.bidCategoryData.subCategoryList![0].modifyAllowed;
    catePurFlag = widget.bidCategoryData.subCategoryList![0].purchaseFlag;
    appNo = widget.bidCategoryData.subCategoryList![0].applicationNo;
    appliedUpiId =
        widget.bidCategoryData.subCategoryList![0].appliedDetail!.appliedUpi!;
    buttonText = widget.bidCategoryData.subCategoryList![0].categoryButtonText;
    hniIndicator = false;
    minPrice = widget.bidscreendetails.cutOffPrice!;
    print(cutOffFlag);
    print("hni cuttoff");
    setState(() {});
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  /*Init State*/
  @override
  void initState() {
    super.initState();
    indInitializer();
    // cutOffFlag = widget.bidscreendetails.cutOffFlag;
    // cutOffFlag = widget.bidCategoryData.cutOffFlag;
    // buttonText = widget.bidCategoryData.categoryButtonText;
    upiController.text = widget.suggestUPI;
    hniIndicator = false;
    if (widget.bidscreendetails.ipoPurchased == 'Y') {
      ////print('entry1');
      isModify = true;
      if (widget.bidCategoryData.purchaseFlag == 'Y' ||
          (widget.bidCategoryData.subCategoryFound == 'Y' &&
              widget.bidCategoryData.subCategoryList![0].purchaseFlag == 'Y')) {
        ////print('entry2');
        getModifyBidDetailsInAPI();
      } else {
        // siText = widget.bidCategoryData.sItext;
        // siValue = widget.bidCategoryData.sIvalue;
        // showSI = widget.bidCategoryData.showSi;
        // buttonText = widget.bidCategoryData.categoryButtonText;
        isModify = false;
        indInitializer();
        addFirstBidField();
      }
    } else {
      isModify = false;
      indInitializer();
      addFirstBidField();
      // siText = widget.bidCategoryData.sItext;
      // siValue = widget.bidCategoryData.sIvalue;
      // showSI = widget.bidCategoryData.showSi;
      // buttonText = widget.bidCategoryData.categoryButtonText;
    }
  }

  indCateFunc(context) {
    indInitializer();
    // cutOffFlag = widget.bidCategoryData.cutOffFlag;
    selectedTilevalue = 1;
    // siText = widget.bidCategoryData.sItext;
    // siValue = widget.bidCategoryData.sIvalue;
    // showSI = widget.bidCategoryData.showSi;
    // minLot = widget.bidCategoryData.minimumlot ?? 1;
    containers.clear();
    addFirstBidField();
    calculateHighestTotal();
    setState(() {});
    if (amountPayable <= maxTotalValue && amountPayable >= minTotalValue) {
      highestColor = primaryGreenColor;
    } else {
      highestColor = primaryRedColor;
    }

    Navigator.of(context).pop();
  }

  hniCateFunc(context) {
    // hniApplicable = 'Y';
    // minTotalValue = widget.bidCategoryData.subCategoryList![0].minValue;
    // maxTotalValue = widget.bidCategoryData.subCategoryList![0].maxValue;
    // categorytext = widget.bidCategoryData.subCategoryList![0].category;
    // categoryValue = widget.bidCategoryData.subCategoryList![0].code;
    // infotext = widget.bidCategoryData.subCategoryList![0].infoText;
    // hniEnable = true;
    // cateResetText = widget.bidCategoryData.hniResetText;
    // cateChangeText = widget.bidCategoryData.categoryorderText;
    // cateDisclaimer =
    //     widget.bidCategoryData.subCategoryList![0].categorydisclaimerText;
    // cutOffFlag = widget.bidCategoryData.subCategoryList![0].cutOffFlag;
    // siText = widget.bidCategoryData.subCategoryList![0].sItext;
    // siValue = widget.bidCategoryData.subCategoryList![0].sIvalue;
    // showSI = widget.bidCategoryData.subCategoryList![0].showSi;
    // minLot = widget.bidCategoryData.subCategoryList![0].minimumlot ?? 1;
    // buttonText = widget.bidCategoryData.categoryButtonText;
    selectedTilevalue = 2;
    hniIntializer();
    containers.clear();
    addFirstBidField();
    calculateHighestTotal();
    setState(() {});
    if (amountPayable <= maxTotalValue && amountPayable >= minTotalValue) {
      highestColor = primaryGreenColor;
    } else {
      highestColor = primaryRedColor;
    }
    Navigator.of(context).pop();
  }

//   /*Initialy First Bidfield ...*/
  void addFirstBidField() {
    setState(() {
      isLoaded = false;
    });
    if (containers.isEmpty) {
      containers.add(BidFieldWidget(
        hniEnable: hniEnable,
        index: 0,
        removeContainer: removeContainer,
        calculateHighestTotal: calculateHighestTotal,
        cutOfPrice: widget.bidscreendetails.cutOffPrice!,
        lot: widget.bidscreendetails.lotSize!,
        bidminPrice: minPrice!,
        minPrice: widget.bidscreendetails.minPrice!,
        //  widget.bidscreendetails.minPrice!,
        minQty: minLot,
        // hniEnable
        //     ? widget.bidCategoryData.subCategoryList![0].minimumlot!
        //     : widget.bidCategoryData.minimumlot!,
        cutOffFlag: cutOffFlag,
        //  hniEnable
        //     ? widget.bidCategoryData.subCategoryList![0].cutOffFlag
        //     : widget.bidCategoryData.cutOffFlag,
        onChangeVerification: onChangeValidation,
        discountPrice: widget.bidCategoryData.discountPrice!,
        modifyAllowed: modifyAllowed!,
        catePurFlag: catePurFlag!,
        discountType: widget.bidCategoryData.discountType!,
        onbuttonValidation: () => checkButtonValidation(),
        // Pass the callback
      ));
    }
  }

//   /*Adding BidField ...*/

  void addBidField() {
    if (containers.length < 3) {
      setState(() {
        containers.add(BidFieldWidget(
          hniEnable: hniEnable,
          index: containers.length,
          removeContainer: removeContainer,
          calculateHighestTotal: calculateHighestTotal,
          cutOfPrice: widget.bidscreendetails.cutOffPrice!,
          lot: widget.bidscreendetails.lotSize!,
          bidminPrice: minPrice!,
          minPrice: widget.bidscreendetails.minPrice!,
          // widget.bidscreendetails.minPrice!,
          minQty: minLot,

          // hniEnable
          //     ? widget.bidCategoryData.subCategoryList![0].minimumlot!
          //     : widget.bidCategoryData.minimumlot!,
          cutOffFlag: cutOffFlag,
          //  hniEnable
          //     ? widget.bidCategoryData.subCategoryList![0].cutOffFlag
          //     : widget.bidCategoryData.cutOffFlag,
          onChangeVerification: onChangeValidation,
          modifyAllowed: modifyAllowed!,
          catePurFlag: catePurFlag!,
          discountPrice: widget.bidCategoryData.discountPrice!,
          discountType: widget.bidCategoryData.discountType!,
          onbuttonValidation: () => checkButtonValidation(),
        ));
      });
    } else {
      setState(() {
        addenable = false;
      });
    }
  }

  getModifyBidDetailsInAPI() async {
    if (await isInternetConnected()) {
      if (widget.bidCategoryData.purchaseFlag == 'Y') {
        ////print(2);
        if (widget.bidCategoryData.appliedDetail!.appliedBids != null) {
          ////print(2.1);
          modifyDetails = widget.bidCategoryData.appliedDetail!.appliedBids!;
          for (var i = 0; i < modifyDetails!.length; i++) {
            amountPayable = modifyDetails![i].amount! > amountPayable
                ? modifyDetails![i].amount
                : amountPayable;
            indInitializer();
            // hniApplicable = 'N';
            // minTotalValue = widget.bidCategoryData.minValue;
            // maxTotalValue = widget.bidCategoryData.maxValue;
            // categorytext = widget.bidCategoryData.category;
            // categoryValue = widget.bidCategoryData.code;
            // infotext = widget.bidCategoryData.infoText;
            // hniEnable = false;
            // cateResetText = widget.bidCategoryData.indResetText;
            // cateChangeText = widget.bidCategoryData.subCategoryInfoText;
            // cateDisclaimer = widget.bidCategoryData.categorydisclaimerText;
            // siText = widget.bidCategoryData.sItext;
            // siValue = widget.bidCategoryData.sIvalue;
            // showSI = widget.bidCategoryData.showSi;
            // buttonText = widget.bidCategoryData.categoryButtonText;
            addModifyBidField(modifyDetails![i]);
            l.add({
              "price": modifyDetails![i].price,
              "qty": modifyDetails![i].quantity,
              "cut": modifyDetails![i].cutOff
            });
          }
          if (amountPayable <= maxTotalValue &&
              amountPayable >= minTotalValue) {
            ////print(2.2);
            // setState(() {});
            highestColor = primaryGreenColor;
          } else {
            ////print(2.3);
            highestColor = Colors.red;
          }
        }
      } else if (widget.bidCategoryData.subCategoryFound == 'Y' &&
          widget.bidCategoryData.subCategoryList![0].purchaseFlag == 'Y') {
        ////print(3);

        if (widget.bidCategoryData.subCategoryList![0].appliedDetail!
                .appliedBids !=
            null) {
          ////print(3.1);
          // //print(widget.bidCategoryData.subCategoryList![0].modifyAllowed);
          // //print(modifyAllowed);
          hniIntializer();
          // //print(modifyAllowed);
          // ////print(minLot);
          // ////print(widget.bidCategoryData.subCategoryList![0].minimumlot);

          modifyDetails = widget
              .bidCategoryData.subCategoryList![0].appliedDetail!.appliedBids!;
          for (var i = 0; i < modifyDetails!.length; i++) {
            amountPayable = modifyDetails![i].amount! > amountPayable
                ? modifyDetails![i].amount
                : amountPayable;
            hniIntializer();

            // hniApplicable = 'Y';
            // minTotalValue = widget.bidCategoryData.subCategoryList![0].minValue;
            // maxTotalValue = widget.bidCategoryData.subCategoryList![0].maxValue;
            // categorytext = widget.bidCategoryData.subCategoryList![0].category;
            // categoryValue = widget.bidCategoryData.subCategoryList![0].code;
            // infotext = widget.bidCategoryData.subCategoryList![0].infoText;
            // hniEnable = true;
            // cateResetText = widget.bidCategoryData.hniResetText;
            // cateChangeText = widget.bidCategoryData.categoryorderText;
            // cateDisclaimer = widget
            //     .bidCategoryData.subCategoryList![0].categorydisclaimerText;
            // siText = widget.bidCategoryData.subCategoryList![0].sItext;
            // siValue = widget.bidCategoryData.subCategoryList![0].sIvalue;
            // showSI = widget.bidCategoryData.subCategoryList![0].showSi;
            // buttonText =
            //     widget.bidCategoryData.subCategoryList![0].categoryButtonText;
            addModifyBidField(modifyDetails![i]);
            l.add({
              "price": modifyDetails![i].price,
              "qty": modifyDetails![i].quantity,
              "cut": modifyDetails![i].cutOff
            });
            minLot = widget.bidCategoryData.subCategoryList![0].minimumlot ?? 1;
          }

          if (amountPayable <= maxTotalValue &&
              amountPayable >= minTotalValue) {
            ////print(3.2);
            highestColor = primaryGreenColor;
          } else {
            ////print(3.3);
            highestColor = Colors.red;
          }
        }
      }

      setState(() {});
      isLoaded = false;
    } else {
      noInternetConnectAlertDialog(context, () => getModifyBidDetailsInAPI());
    }
  }

  /*Add ModifyBidField the Existing getModify Data*/
  void addModifyBidField(AppliedBid modifyDetails) {
    if (containers.length < 3) {
      setState(() {
        containers.add(BidFieldWidget(
          hniEnable: hniEnable,
          index: containers.length,
          removeContainer: removeContainer,
          calculateHighestTotal: calculateHighestTotal,
          cutOfPrice: widget.bidscreendetails.cutOffPrice!,
          lot: widget.bidscreendetails.lotSize!,
          bidminPrice: minPrice!,
          minPrice: widget.bidscreendetails.minPrice!,
          // widget.bidscreendetails.minPrice!,
          minQty: minLot,
          // hniEnable
          //     ? widget.bidCategoryData.subCategoryList![0].minimumlot!
          //     : widget.bidCategoryData.minimumlot!,
          cutOffFlag: cutOffFlag,
          // hniEnable
          //     ? widget.bidCategoryData.subCategoryList![0].cutOffFlag!
          //     : widget.bidCategoryData.cutOffFlag!,
          checkboxValue: modifyDetails.cutOff!,
          priceControllerValue: modifyDetails.price.toString(),
          quantityControllerValue: modifyDetails.quantity.toString(),
          totalControllerValue: modifyDetails.amount.toString(),
          cancelButtonEnable: false,
          modifyAllowed: modifyAllowed!,
          catePurFlag: catePurFlag!,
          onChangeVerification: onChangeValidation,
          discountPrice: widget.bidCategoryData.discountPrice!,
          discountType: widget.bidCategoryData.discountType!,
          onbuttonValidation: () => checkButtonValidation(),
        ));
      });
    } else {
      setState(() {
        addenable = false;
      });
    }
  }

  /*Remove BidField...*/
  void removeContainer(int index) {
    if (containers.length > 1) {
      // setState(() {
      containers.removeAt(index);
      // Update the indices of the remaining containers
      for (int i = index; i < containers.length; i++) {
        containers[i].updateIndex(i);
      }
      calculateHighestTotal();
      // });
      checkButtonValidation();
      setState(() {});
    } else {
      showSnackbar(context, "First Bid Can't Be Remove", primaryRedColor);
    }
  }

  void postbidListValues() {
    bidList.clear();
    upiId = upiController.text;
    List<String> upiParts = upiId.split('@');

    if (upiParts.length == 2) {
      upiIdStart = upiParts[0]; //
      upiEndPoint = upiParts[1]; // icici
    } else {
      showSnackbar(context, 'Invalid UPI ID format', Colors.red);
    }
    List<BidFieldWidget> containersCopy = List.from(containers);

    for (var container in containersCopy) {
      final quantityController = container.quantityController;
      final priceController = container.priceController;
      bool checkbox = container.checkbox;

      if (quantityController.text.isNotEmpty &&
          priceController.text.isNotEmpty) {
        Map<String, dynamic> qpvalues = {
          'quantity': int.parse(quantityController.text),
          'price': int.parse(priceController.text),
          'cutOff': hniEnable ? false : checkbox,
          'activityType': 'new',
          'bidReferenceNo': generateSixDigitRandomNumber().toString(),
          'lotSize': widget.bidscreendetails.lotSize,
        };
        bidList.add(qpvalues);
      }
    }

    setState(() {});
  }

  newBidPlaceOrderFun() async {
    setState(() {
      recheck = true;
    });
    if (!siValue!) {
      showSnackbar(context, 'Agree to Terms and Apply', Colors.red);
      return;
    }
    // buttonEnable = true;
    postbidListValues();
    placeOrderDetailsMap = {
      'upiId': upiIdStart,
      'upiEndPoint': '@$upiEndPoint',
      'category': widget.bidCategoryData.code,
      'symbol': widget.bidscreendetails.symbol.toString(),
      'masterId': int.parse(widget.bidscreendetails.id.toString()),
      'HNI': hniApplicable ?? 'N',
      'bids': bidList,
      'preApply': widget.bidscreendetails.preApply ?? ''
    };
    loadingAlertBox(context, 'Applying IPO...');
    // //print("NewplaceOrderDetailsMap");
    // //print(placeOrderDetailsMap);
    Map? placeorderResponse = await ipoPlaceOrderApi(
        context: context, postBidDetails: placeOrderDetailsMap!);

    if (placeorderResponse != null && placeorderResponse.isNotEmpty) {
      if (placeorderResponse['status'] == 'S') {
        showSnackbar(
            context, placeorderResponse['appReason'], primaryGreenColor);
        Navigator.pushNamed(context, route.novoPage, arguments: 2);
      } else {
        Navigator.pop(context);

        showSnackbar(context, placeorderResponse['errMsg'], primaryRedColor);
      }
    } else {
      showSnackbar(context, somethingError, primaryRedColor);
      // Navigator.pop(context);
    }
  }

  modifyPlaceOrderFun() async {
    if (widget.bidCategoryData.purchaseFlag == 'Y') {
      //print('IND placeOrder');
      placeOrderDetailsMap = {
        "applicationNo": widget.bidCategoryData.applicationNo,
        "upiId":
            widget.bidCategoryData.appliedDetail!.appliedUpi!.split("@")[0],
        "upiEndPoint":
            "@${widget.bidCategoryData.appliedDetail!.appliedUpi!.split("@")[1]}",
        "category": widget.bidCategoryData.code,
        "symbol": widget.bidscreendetails.symbol,
        "masterId": widget.bidscreendetails.id,
        'HNI': 'N',
        "bids": []
      };

      for (var i = 0; i < modifyDetails!.length; i++) {
        AppliedBid element = modifyDetails![i];

        if ((element.price != int.parse(containers[i].priceController.text) ||
            element.quantity !=
                int.parse(containers[i].quantityController.text) ||
            element.cutOff != containers[i].checkbox)) {
          placeOrderDetailsMap!["bids"].add({
            "id": element.id,
            "activityType": "modify",
            "bidReferenceNo": element.bidReferenceNo.toString(),
            "cutOff": hniEnable ? false : containers[i].checkbox,
            "lotSize": widget.bidscreendetails.lotSize,
            "price": int.parse(containers[i].priceController.text),
            "quantity": int.parse(containers[i].quantityController.text)
          });
        }
      }
      if (containers.length > modifyDetails!.length) {
        for (var i = modifyDetails!.length; i < containers.length; i++) {
          placeOrderDetailsMap!["bids"].add({
            "id": 0,
            "activityType": "new",
            "bidReferenceNo": generateSixDigitRandomNumber().toString(),
            "cutOff": hniEnable ? false : containers[i].checkbox,
            "lotSize": widget.bidscreendetails.lotSize,
            "price": int.parse(containers[i].priceController.text),
            "quantity": int.parse(containers[i].quantityController.text)
          });
        }
      }

      // loadingAlertBox(context, 'Modifying SGB...');
      if (placeOrderDetailsMap!["bids"].isNotEmpty) {
        loadingAlertBox(context, 'Modifying IPO...');
        Map? placeorderResponse = await ipoPlaceOrderApi(
            context: context, postBidDetails: placeOrderDetailsMap!);

        if (placeorderResponse != null && placeorderResponse.isNotEmpty) {
          if (placeorderResponse['status'] == 'S') {
            showSnackbar(
                context, placeorderResponse['appReason'], primaryGreenColor);
            Navigator.pushNamed(context, route.novoPage, arguments: 2);
          } else {
            Navigator.pop(context);

            showSnackbar(
                context, placeorderResponse['errMsg'], primaryRedColor);
          }
        } else {
          showSnackbar(context, somethingError, primaryRedColor);
        }
      } else {
        showSnackbar(context, 'Please Modify or New BID..', primaryRedColor);
      }
    } else if (widget.bidCategoryData.subCategoryList![0].purchaseFlag == 'Y') {
      //print('HNI placeOrder');
      placeOrderDetailsMap = {
        "applicationNo":
            widget.bidCategoryData.subCategoryList![0].applicationNo,
        "upiId": widget
            .bidCategoryData.subCategoryList![0].appliedDetail!.appliedUpi!
            .split("@")[0],
        "upiEndPoint":
            "@${widget.bidCategoryData.subCategoryList![0].appliedDetail!.appliedUpi!.split("@")[1]}",
        "category": widget.bidCategoryData.code,
        "symbol": widget.bidscreendetails.symbol,
        "masterId": widget.bidscreendetails.id,
        'HNI': hniApplicable ?? 'N',
        "bids": []
      };
      //HNI LOOp.............

      for (var i = 0; i < modifyDetails!.length; i++) {
        AppliedBid element = modifyDetails![i];
        // if (widget.bidCategoryData.subCategoryList![0].minimumlot! >
        //     int.parse(containers[i].quantityController.text)) {
        //   showSnackbar(
        //       context, "Bid Size Cannot be reduced for HNI", primaryRedColor);
        //   return;
        // }

        if ((element.price != int.parse(containers[i].priceController.text) ||
            element.quantity !=
                int.parse(containers[i].quantityController.text) ||
            element.cutOff != containers[i].checkbox)) {
          placeOrderDetailsMap!["bids"].add({
            "id": element.id,
            "activityType": "modify",
            "bidReferenceNo": element.bidReferenceNo.toString(),
            "cutOff": hniEnable ? false : containers[i].checkbox,
            "lotSize": widget.bidscreendetails.lotSize,
            "price": int.parse(containers[i].priceController.text),
            "quantity": int.parse(containers[i].quantityController.text)
          });
        }
      }
      if (containers.length > modifyDetails!.length) {
        for (var i = modifyDetails!.length; i < containers.length; i++) {
          // if (widget.bidCategoryData.subCategoryList![0].minimumlot! >
          //     int.parse(containers[i].quantityController.text)) {
          //   showSnackbar(
          //       context, "Bid Size Cannot be reduced for HNI", primaryRedColor);
          //   return;
          // }

          placeOrderDetailsMap!["bids"].add({
            "id": 0,
            "activityType": "new",
            "bidReferenceNo": generateSixDigitRandomNumber().toString(),
            "cutOff": hniEnable ? false : containers[i].checkbox,
            "lotSize": widget.bidscreendetails.lotSize,
            "price": int.parse(containers[i].priceController.text),
            "quantity": int.parse(containers[i].quantityController.text)
          });
        }
      }

      // loadingAlertBox(context, 'Modifying SGB...');
      if (placeOrderDetailsMap!["bids"].isNotEmpty) {
        loadingAlertBox(context, 'Modifying IPO...');
        //print("placeOrderDetailsMap");
        //print(placeOrderDetailsMap);
        Map? placeorderResponse = await ipoPlaceOrderApi(
            context: context, postBidDetails: placeOrderDetailsMap!);

        if (placeorderResponse != null && placeorderResponse.isNotEmpty) {
          if (placeorderResponse['status'] == 'S') {
            showSnackbar(
                context, placeorderResponse['appReason'], primaryGreenColor);
            Navigator.pushNamed(context, route.novoPage, arguments: 2);
          } else {
            Navigator.pop(context);
            showSnackbar(
                context, placeorderResponse['errMsg'], primaryRedColor);
          }
        } else {
          showSnackbar(context, somethingError, primaryRedColor);
        }
      } else {
        showSnackbar(context, 'Please Modify or New BID..', primaryRedColor);
      }
    }
  }

  List l = [];
  checkButtonValidation() {
    if (upiController.text.isNotEmpty) {
      buttonEnable = _formKey.currentState!.validate() && (siValue == true);
      calculateHighestTotal();
      ////print('+++++++++');
      //print(buttonEnable);
      // //print('ismodify');
      // //print(isModify);
      if (isModify == true) {
        buttonEnable = containers.every((element) {
          int index = containers.indexOf(element);
          if (index < l.length) {
            bool condition = l[index]["price"].toString() ==
                    containers[index].priceController.text &&
                l[index]["qty"].toString() ==
                    containers[index].quantityController.text &&
                l[index]["cut"] == containers[index].checkbox;
            //print("condition");
            //print(condition);
            if (!condition) {
              //print('!condition');
              //print('++++++++++++++++');
              // if ((num.tryParse(element.quantityController.text) ?? 0) <
              //     minLot) {

              //   // showSnackbar(context, 'Bid size cannot be reduced for HNI',
              //   //     primaryRedColor);
              // }

              // //print(num.tryParse(element.quantityController.text));
              // //print(minLot);
              // if ((num.tryParse(element.quantityController.text) ?? 0) <=
              //     minLot) {
              //   element.quantityController.text = minLot.toString();
              // }

              // //print((num.tryParse(element.quantityController.text) ?? 0) >=
              //     minLot);
              return ((num.tryParse(element.quantityController.text) ?? 0) >=
                      minLot) &&
                  // ((num.tryParse(element.priceController.text) ?? 0) >=
                  //     minPrice!) &&
                  element.quantityController.text.isNotEmpty &&
                  element.priceController.text.isNotEmpty;
            } else {
              //print('conditionelse');
              return true;
            }
          } else {
            // //print('else2*********');
            // if ((num.tryParse(element.quantityController.text) ?? 0) < minLot) {
            //   // showSnackbar(
            //   //     context, 'Bid size cannot be reduced for HNI', primaryRedColor);
            // }
            // if ((num.tryParse(element.quantityController.text) ?? 0) <= minLot) {
            //   element.quantityController.text = minLot.toString();
            // }
            return (num.tryParse(element.quantityController.text) ?? 0) >=
                    minLot &&
                element.quantityController.text.isNotEmpty &&
                element.priceController.text.isNotEmpty;
          }
        });
        calculateHighestTotal();
      }

      // if (isLessThenMinLot == true) {
      //   buttonEnable = false;
      // }
      //keela potta if..
      //print("buttonEnable");
      //print(buttonEnable);
      if (l.length == containers.length) {
        bool buttonEn = containers.every((element) {
          int index = containers.indexOf(element);
          return l[index]["price"].toString() ==
                  containers[index].priceController.text &&
              l[index]["qty"].toString() ==
                  containers[index].quantityController.text &&
              l[index]["cut"] == containers[index].checkbox;
        });
        if (buttonEn == true) {
          buttonEnable = false;
          // setState(() {});
          // return;
        }
      }
      setState(() {});
    }
    ////print(' button Enable $buttonEnable');
  }

  deleteBidInAPI() async {
    setState(() {
      recheck = true;
      deleteLoading = false;
    });
    if (!_formKey.currentState!.validate()) {
      showSnackbar(context, 'Requried field cannot be left blank', Colors.red);
      return;
    }

    if (await isInternetConnected()) {
      placeOrderDetailsMap = {
        "applicationNo": widget.bidCategoryData.applicationNo,
        "upiId":
            widget.bidCategoryData.appliedDetail!.appliedUpi!.split("@")[0],
        "upiEndPoint":
            "@${widget.bidCategoryData.appliedDetail!.appliedUpi!.split("@")[1]}",
        "category": widget.bidCategoryData.code,
        "symbol": widget.bidscreendetails.symbol,
        "masterId": widget.bidscreendetails.id,
        'HNI': hniApplicable ?? 'N',
        "bids": []
      };
      for (var element in modifyDetails!) {
        placeOrderDetailsMap!["bids"].add({
          "activityType": "cancel",
          "bidReferenceNo": element.bidReferenceNo.toString(),
          "cutOff": element.cutOff,
          "lotSize": widget.bidscreendetails.lotSize,
          "price": element.price,
          "quantity": element.quantity
        });
      }
      Navigator.pop(context);

      loadingAlertBox(context, 'Deleting IPO...');
      Map? placeorderResponse = await ipoPlaceOrderApi(
          context: context, postBidDetails: placeOrderDetailsMap!);

      if (placeorderResponse != null && placeorderResponse.isNotEmpty) {
        if (placeorderResponse['status'] == 'S') {
          showSnackbar(
              context, placeorderResponse['appReason'], primaryGreenColor);
          Navigator.pushNamed(context, route.novoPage, arguments: 2);
        } else {
          Navigator.pop(context);

          showSnackbar(context, placeorderResponse['errMsg'], primaryRedColor);
        }
      } else {
        showSnackbar(context, somethingError, primaryRedColor);
        // Navigator.pop(context);
      }
    } else {
      noInternetConnectAlertDialog(context, () => deleteBidInAPI());
    }
  }

  // bool buttonEnable = false;
  postIpoPlaceOrder() async {
    setState(() {
      recheck = true;
    });
    if (!_formKey.currentState!.validate()) {
      showSnackbar(context, 'Requried field cannot be left blank', Colors.red);
      return;
    }
    if (amountPayable <= maxTotalValue && amountPayable >= minTotalValue) {
      if (await isInternetConnected()) {
        setState(() {
          submitLoading = true;
        });

        if (widget.bidscreendetails.ipoPurchased == 'N') {
          await newBidPlaceOrderFun();
        } else if (widget.bidscreendetails.ipoPurchased == 'Y') {
          if (widget.bidCategoryData.purchaseFlag == 'Y') {
            //print('indcategory modifyplaceorder');
            await modifyPlaceOrderFun();
          } else if (widget.bidCategoryData.subCategoryFound == 'Y' &&
              widget.bidCategoryData.subCategoryList![0].purchaseFlag == 'Y') {
            //print('subcategory modifyplaceorder');
            await modifyPlaceOrderFun();
          } else {
            //print('elseIfplaceorder emp or share');
            await newBidPlaceOrderFun();
          }
        }
        setState(() {
          submitLoading = false;
        });
      } else {
        noInternetConnectAlertDialog(context, () => postIpoPlaceOrder);
      }
    } else {
      showSnackbar(
          context,
          'The total amount should not exceed $minTotalValue - $maxTotalValue for $categorytext',
          primaryRedColor);
    }
  }

  // String? cateInfoText;

  bool isModify = true;
  /*Calculate the HigestTotal From the BidField total value*/
  void calculateHighestTotal() {
    dynamic highest = 0;
    for (var container in containers) {
      totalAmount = int.tryParse(container.totalController.text) ?? 0;
      if (totalAmount > highest) {
        int qty = int.tryParse(container.quantityController.text) ?? 0;
        int price = int.tryParse(container.priceController.text) ?? 0;
        highest = totalAmount;

        if (qty != 0 && price != 0 && showDiscount!) {
          discountApplied = qty *
              widget.bidscreendetails.lotSize! *
              (widget.bidCategoryData.discountType! == 'A'
                  ? widget.bidCategoryData.discountPrice!.toDouble()
                  : (widget.bidCategoryData.discountPrice!.toInt() *
                      price /
                      100));
        } else {
          discountApplied = 0;
        }
        highest = highest - discountApplied;

        if (highest <= maxTotalValue && highest >= minTotalValue) {
          highestColor = primaryGreenColor;
          hniIndicator = false;
          isDeleteIndicator = false;
        } else {
          if (isModify == false &&
              container.quantityController.text.isNotEmpty &&
              container.quantityController.text != "0" &&
              container.priceController.text.isNotEmpty &&
              container.priceController.text != "0" &&
              !hniEnable &&
              widget.bidCategoryData.code == 'IND' &&
              widget.bidCategoryData.subCategoryFound == 'Y' &&
              widget.bidCategoryData.subCategoryList != null) {
            hniIndicator = true;
            // isDeleteIndicator = true;
            buttonEnable = false;
            setState(() {});
          } else if (container.quantityController.text.isNotEmpty &&
              container.quantityController.text != "0" &&
              container.priceController.text.isNotEmpty &&
              container.priceController.text != "0" &&
              !hniEnable &&
              widget.bidCategoryData.code == 'IND' &&
              widget.bidCategoryData.subCategoryFound == 'Y' &&
              widget.bidCategoryData.subCategoryList != null) {
            //print('deleteenable');
            isDeleteIndicator = true;
            buttonEnable = false;
          } else if (isModify == false &&
              container.quantityController.text.isNotEmpty &&
              container.quantityController.text != "0" &&
              container.priceController.text.isNotEmpty &&
              container.priceController.text != "0" &&
              highest <= minTotalValue) {
            //print('highest <= minTotalValue');
            hniIndicator = true;
            // isDelete = true;
            buttonEnable = false;
            highestColor = primaryRedColor;
          } else {
            buttonEnable = false;
            highestColor = primaryRedColor;
          }
          buttonEnable = false;
          highestColor = primaryRedColor;
        }
      } else {
        if (container.quantityController.text.isNotEmpty &&
            container.quantityController.text != "0" &&
            container.priceController.text.isNotEmpty &&
            container.priceController.text != "0" &&
            isModify == false &&
            totalAmount <= minTotalValue!) {
          buttonEnable = false;
          hniIndicator = true;
        }
      }
    }
    amountPayable = highest;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

/* Gernerate The SixDigit RandomNumber for Bid Reference Number */
  int generateSixDigitRandomNumber() {
    final random = Random();
    const min = 100000; // Minimum six-digit number
    const max = 999999; // Maximum six-digit number
    return min + random.nextInt(max - min + 1);
  }

/* OnChange Validation For TextFeild */
  onChangeValidation([check = false]) {
    if (onchange || check) {
      if (_formKey.currentState!.validate()) {}
    }
  }

/* Calculate the Total Amount with using The Validation */
  totalAmountValidation() {
    if (_formKey.currentState!.validate()) {
      List<BidFieldWidget> containersCopy = List.from(containers);
      // Iterate over the copy of the list
      for (var container in containersCopy) {
        if (amountPayable <= maxTotalValue &&
            amountPayable >= minTotalValue &&
            int.parse(container.quantityController.text) > 0) {
          addBidField();
        } else {
          showSnackbar(
            context,
            'The total amount should not exceed  $maxTotalValue for $categorytext',
            primaryRedColor,
          );
        }
      }
    }
  }

/*Convert  100000 to Lakhs ..... */
  String formatNumber(int number) {
    if (number < 100000) {
      return number.toString(); // Return as is if less than 1 lakh
    } else if (number >= 100000 && number < 10000000) {
      double lakhs = number / 100000;
      return '${lakhs.toStringAsFixed(2)} Lakhs';
    } else {
      double crores = number / 10000000;
      return '${crores.toStringAsFixed(2)} Crores';
    }
  }

  /* Post Method..*/

  /* Post The BidList Values...*/

  @override
  Widget build(BuildContext context) {
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    var themeModeLight =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.light;

    return Scaffold(
      // backgroundColor: Colors.transparent,
      // backgroundColor:
      //     Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
      //         ? Colors.black
      //         : Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Provider.of<NavigationProvider>(context).themeMode ==
                        ThemeMode.dark
                    ? Brightness.light
                    : Brightness.dark),
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              CupertinoIcons.back,
              size: 25.0,
              color: themeBasedColor,
            )),
        title: Text(widget.bidscreendetails.symbol!,
            overflow: TextOverflow.visible,
            style: themeModeLight
                ? ThemeClass.lighttheme.textTheme.titleMedium
                : ThemeClass.Darktheme.textTheme.titleMedium),
        toolbarHeight: MediaQuery.of(context).size.height * 0.06,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
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
                          FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(widget.bidscreendetails.name!,
                                  style: ThemeClass
                                      .lighttheme.textTheme.displayMedium)),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Visibility(
                                visible: catePurFlag == 'N',
                                replacement: Text('App.No: $appNo',
                                    style: themeModeLight
                                        ? ThemeClass
                                            .lighttheme.textTheme.bodyMedium
                                        : ThemeClass
                                            .Darktheme.textTheme.bodyMedium),
                                child: Text(
                                  widget.bidscreendetails.dateRange!,
                                  style: themeModeLight
                                      ? ThemeClass
                                          .lighttheme.textTheme.bodyMedium
                                      : ThemeClass
                                          .Darktheme.textTheme.bodyMedium,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Visibility(
                                visible: widget
                                    .bidscreendetails.drhpLink!.isNotEmpty,
                                child: InkWell(
                                    onTap: () {
                                      launchUrlFunction(
                                          widget.bidscreendetails.drhpLink!);
                                    },
                                    child: Row(
                                      children: [
                                        Text('DRHP',
                                            style: ThemeClass.lighttheme
                                                .textTheme.bodyMedium!
                                                .copyWith(
                                                    color:
                                                        Colors.blue.shade400)),
                                        Icon(
                                          CupertinoIcons.link,
                                          size: 14.0,
                                          color: Colors.blue.shade400,
                                        )
                                      ],
                                    )),
                              ),
                              Expanded(child: SizedBox()),
                              Visibility(
                                visible: widget.bidCategoryData.cancelAllowed!,
                                child: Transform.scale(
                                  scale: 0.7,
                                  child: InkWell(
                                    // elevation: 2,

                                    // padding: EdgeInsets.all(10),
                                    // elevation: 20,
                                    // shape: CircleBorder(
                                    //     // eccentricity: 0.0,
                                    //     side: BorderSide(
                                    //         width: 0.4, color: subTitleTextColor)),
                                    splashColor:
                                        primaryRedColor.withOpacity(0.30),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: Text(
                                              'Do you want to delete the IPO Application ?',
                                              style: TextStyle(
                                                  fontFamily: 'inter',
                                                  fontSize: 13,
                                                  color:
                                                      Provider.of<NavigationProvider>(
                                                                      context)
                                                                  .themeMode ==
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
                                                      deleteBidInAPI(),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 25.0,
                                                child: ElevatedButton(
                                                    style: ButtonStyle(
                                                        shape: MaterialStatePropertyAll(
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            18.0))),
                                                        backgroundColor: MaterialStatePropertyAll(
                                                            Provider.of<NavigationProvider>(
                                                                            context)
                                                                        .themeMode ==
                                                                    ThemeMode
                                                                        .dark
                                                                ? Colors.white
                                                                : appPrimeColor)),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: Text(
                                                      'No',
                                                      style: TextStyle(
                                                          fontFamily: 'inter',
                                                          fontSize:
                                                              subTitleFontSize,
                                                          color: Provider.of<NavigationProvider>(
                                                                          context)
                                                                      .themeMode ==
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
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: primaryRedColor,
                                      size: 35.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No. of shares: ',
                                style: themeModeLight
                                    ? ThemeClass.lighttheme.textTheme.bodyMedium
                                    : ThemeClass.Darktheme.textTheme.bodyMedium,
                              ),
                              Text(
                                widget.bidscreendetails.issueSizeWithText!,
                                style: themeModeLight
                                    ? ThemeClass.lighttheme.textTheme.bodyMedium
                                    : ThemeClass.Darktheme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Visibility(
                            visible: showDiscount!,
                            child: Row(
                              children: [
                                Text(
                                  '${widget.bidCategoryData.discountText} : ',
                                  style: themeModeLight
                                      ? ThemeClass
                                          .lighttheme.textTheme.bodyMedium
                                      : ThemeClass
                                          .Darktheme.textTheme.bodyMedium,
                                ),
                                Text(
                                  widget.bidCategoryData.discountPrice != 0
                                      ? '${widget.bidCategoryData.discountPrice}'
                                      : 'NA',
                                  style: themeModeLight
                                      ? ThemeClass
                                          .lighttheme.textTheme.bodyMedium
                                      : ThemeClass
                                          .Darktheme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Issue price: ',
                                style: themeModeLight
                                    ? ThemeClass.lighttheme.textTheme.bodyMedium
                                    : ThemeClass.Darktheme.textTheme.bodyMedium,
                              ),
                              Text(
                                '${widget.bidscreendetails.minPrice} -${widget.bidscreendetails.cutOffPrice}',
                                style: themeModeLight
                                    ? ThemeClass.lighttheme.textTheme.bodyMedium
                                    : ThemeClass.Darktheme.textTheme.bodyMedium,
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Text(
                                'Lot size: ',
                                style: themeModeLight
                                    ? ThemeClass.lighttheme.textTheme.bodyMedium
                                    : ThemeClass.Darktheme.textTheme.bodyMedium,
                              ),
                              Text(
                                '${widget.bidscreendetails.lotSize}',
                                style: themeModeLight
                                    ? ThemeClass.lighttheme.textTheme.bodyMedium
                                    : ThemeClass.Darktheme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Visibility(
                            visible: infotext!.isNotEmpty,
                            child: InfoContainer(
                                // infoMsg: widget.bidCategoryData.infoText!
                                infoMsg: infotext!
                                // 'IPO window will remain open from 10 AM to 5 PM,\nHowever your may apply after 5 PM as offline.',
                                ),
                          ),
                          Visibility(
                            visible: widget.bidscreendetails.sme!,
                            child: SizedBox(
                              height: 15.0,
                            ),
                          ),
                          Visibility(
                            visible: widget.bidscreendetails.sme!,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.90, // Set the maximum width as a percentage of the screen width
                              child: Text(
                                widget.bidscreendetails.smeText!,
                                // 'This stock belongs to the SME (Small & Medium enterprises) segment which usually has low liquidity and is hence also riskier. It will be traded in a lot size of ${widget.bidscreendetails.lotSize} shares after listing on NSE.',
                                style: themeModeLight
                                    ? ThemeClass.lighttheme.textTheme.bodySmall
                                    : ThemeClass.Darktheme.textTheme.bodySmall,
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow
                                    .visible, // Set the overflow behavior
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),

                          /*UpiTextField..*/
                          Visibility(
                            visible: catePurFlag == 'N',
                            replacement: Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Provider.of<NavigationProvider>(
                                                      context)
                                                  .themeMode ==
                                              ThemeMode.dark
                                          ? Colors.white10 // Light mode
                                          : Color.fromRGBO(235, 237, 236, 1)),
                                  boxShadow:
                                      Provider.of<NavigationProvider>(context)
                                                  .themeMode ==
                                              ThemeMode.dark
                                          ? null
                                          : [
                                              BoxShadow(
                                                color: const Color.fromARGB(
                                                        255, 230, 228, 228)
                                                    .withOpacity(0.5),
                                                offset: Offset(0,
                                                    1.0), // Offset (x, y) controls the shadow's position
                                                blurRadius:
                                                    15, // Spread of the shadow
                                                spreadRadius:
                                                    5.0, // Positive values expand the shadow, negative values shrink it
                                              ),
                                            ],
                                  color:
                                      Provider.of<NavigationProvider>(context)
                                                  .themeMode ==
                                              ThemeMode.dark
                                          ? Color.fromRGBO(48, 48, 48, 1)
                                          : Color.fromRGBO(227, 242, 253, 1),
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'UPI ID',
                                        style: TextStyle(
                                            fontFamily: 'inter',
                                            fontSize: subTitleFontSize,
                                            color: subTitleTextColor),
                                      ),
                                      Text(
                                        appliedUpiId!,
                                        // Disable text wrapping
                                        overflow: TextOverflow
                                            .ellipsis, // Specify overflow behavior
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontFamily: 'inter',
                                          fontSize: subTitleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: themeBasedColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('Category',
                                          style: TextStyle(
                                              fontFamily: 'inter',
                                              fontSize: subTitleFontSize,
                                              color: subTitleTextColor)),
                                      Text(categoryValue ?? "",
                                          style: TextStyle(
                                            fontFamily: 'inter',
                                            fontSize: subTitleFontSize,
                                            fontWeight: FontWeight.bold,
                                            color: themeBasedColor,
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            //     Container(
                            //   width: MediaQuery.of(context).size.width,
                            //   padding: const EdgeInsets.all(15.0),
                            //   decoration: BoxDecoration(
                            //       color: Provider.of<NavigationProvider>(context)
                            //                   .themeMode ==
                            //               ThemeMode.dark
                            //           ? const Color.fromRGBO(227, 242, 253, 1)
                            //           : const Color.fromRGBO(227, 242, 253, 1),
                            //       border: Border.all(
                            //           color: Provider.of<NavigationProvider>(
                            //                           context)
                            //                       .themeMode ==
                            //                   ThemeMode.dark
                            //               ? Colors.white10 // Light mode
                            //               : const Color.fromRGBO(235, 237, 236, 1)),
                            //       boxShadow:
                            //           Provider.of<NavigationProvider>(context)
                            //                       .themeMode ==
                            //                   ThemeMode.dark
                            //               ? null
                            //               : [
                            //                   BoxShadow(
                            //                     color: const Color.fromARGB(
                            //                             255, 230, 228, 228)
                            //                         .withOpacity(0.5),
                            //                     offset: const Offset(0,
                            //                         1.0), // Offset (x, y) controls the shadow's position
                            //                     blurRadius:
                            //                         15, // Spread of the shadow
                            //                     spreadRadius:
                            //                         5.0, // Positive values expand the shadow, negative values shrink it
                            //                   ),
                            //                 ],
                            //       borderRadius: BorderRadius.circular(8.0)),
                            //   child: Column(
                            //     children: [
                            //       Row(
                            //         mainAxisAlignment:
                            //             MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           Expanded(
                            //             child: Column(
                            //               mainAxisAlignment:
                            //                   MainAxisAlignment.start,
                            //               crossAxisAlignment:
                            //                   CrossAxisAlignment.start,
                            //               children: [
                            //                 Text(
                            //                   'UPI ID',
                            //                   style: TextStyle(
                            //                       fontSize: 12.0,
                            //                       color: subTitleTextColor),
                            //                 ),
                            //                 Text(
                            //                   widget.bidCategoryData.appliedDetail!
                            //                           .appliedUpi! ??
                            //                       "",
                            //                   // Disable text wrapping

                            //                   overflow: TextOverflow
                            //                       .ellipsis, // Specify overflow behavior
                            //                   maxLines: 1,
                            //                   style: TextStyle(
                            //                     fontSize: subTitleFontSize,
                            //                     fontWeight: FontWeight.bold,
                            //                     color: titleTextColorLight,
                            //                   ),
                            //                 ),
                            //               ],
                            //             ),
                            //           ),
                            //           Column(
                            //             mainAxisAlignment: MainAxisAlignment.start,
                            //             crossAxisAlignment: CrossAxisAlignment.end,
                            //             children: [
                            //               Text(
                            //                 '${widget.bidCategoryData.discountText ?? ""} ',
                            //                 style: TextStyle(
                            //                     fontSize: 12.0,
                            //                     color: subTitleTextColor),
                            //               ),
                            //               Text(
                            //                 widget.bidCategoryData.discountPrice !=
                            //                         0
                            //                     ? '${widget.bidCategoryData.discountPrice}'
                            //                     : 'NA',
                            //                 // Disable text wrapping

                            //                 overflow: TextOverflow
                            //                     .ellipsis, // Specify overflow behavior
                            //                 maxLines: 1,
                            //                 style: TextStyle(
                            //                   fontSize: subTitleFontSize,
                            //                   fontWeight: FontWeight.bold,
                            //                   color: titleTextColorLight,
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         ],
                            //       ),
                            //       const SizedBox(
                            //         height: 10.0,
                            //       ),
                            //       Row(
                            //         mainAxisAlignment:
                            //             MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           Expanded(
                            //             child: Column(
                            //               mainAxisAlignment:
                            //                   MainAxisAlignment.start,
                            //               crossAxisAlignment:
                            //                   CrossAxisAlignment.start,
                            //               children: [
                            //                 Text('Category',
                            //                     style: TextStyle(
                            //                         fontSize: 12.0,
                            //                         color: subTitleTextColor)),
                            //                 Text(widget.bidCategoryData.code ?? "",
                            //                     style: TextStyle(
                            //                       fontSize: subTitleFontSize,
                            //                       fontWeight: FontWeight.bold,
                            //                       color: titleTextColorLight,
                            //                     )),
                            //               ],
                            //             ),
                            //           ),
                            //           // const SizedBox(
                            //           //   width: 10.0,
                            //           // ),
                            //           Expanded(
                            //             child: Column(
                            //                 mainAxisAlignment:
                            //                     MainAxisAlignment.start,
                            //                 crossAxisAlignment:
                            //                     CrossAxisAlignment.end,
                            //                 children: [
                            //                   Text('Amt. Payable',
                            //                       style: TextStyle(
                            //                           fontSize: 12.0,
                            //                           color: subTitleTextColor)),
                            //                   FittedBox(
                            //                     child: Text(
                            //                         rsFormat.format(
                            //                             amountPayable < 0
                            //                                 ? 0
                            //                                 : amountPayable),
                            //                         // '${getHistoryrecord?.total ?? ""}',
                            //                         style: TextStyle(
                            //                           fontSize: subTitleFontSize,
                            //                           fontWeight: FontWeight.bold,
                            //                           color: titleTextColorLight,
                            //                         )),
                            //                   ),
                            //                 ]),
                            //           ),
                            //         ],
                            //       ),
                            //       // const SizedBox(
                            //       //   height: 10.0,
                            //       // ),
                            //     ],
                            //   ),
                            // ),
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              style: TextStyle(
                                fontFamily: 'inter',
                                fontSize: titleFontSize,
                                color: themeBasedColor,
                              ),
                              controller: upiController,
                              onChanged: (value) {
                                checkButtonValidation();
                              },
                              validator: (value) => upiValidation(value),
                              decoration: InputDecoration(
                                  isDense: true,
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Provider.of<NavigationProvider>(context).themeMode ==
                                                  ThemeMode.dark
                                              ? Colors.white10 // Light mode
                                              : Color.fromRGBO(
                                                  235, 237, 236, 1),
                                          width: 2.0)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Provider.of<NavigationProvider>(context)
                                                          .themeMode ==
                                                      ThemeMode.dark
                                                  ? Colors.blue
                                                  : primaryGreenColor,
                                          width: 0.4)),
                                  counterText: '',
                                  labelText: 'UPI ID',
                                  helperText: 'example:test@ybl',
                                  labelStyle: TextStyle(
                                      fontFamily: 'inter',
                                      fontSize: subTitleFontSize,
                                      color: subTitleTextColor),
                                  helperStyle: TextStyle(
                                      fontFamily: 'inter',
                                      fontSize: contentFontSize,
                                      color: subTitleTextColor),
                                  errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: primaryRedColor.withOpacity(1),
                                          width: 2)),
                                  contentPadding: EdgeInsets.zero),
                            ),
                          ),
                          Visibility(
                            visible: catePurFlag == 'N',
                            child: SizedBox(
                              height: 15.0,
                              // color: Colors.green,
                            ),
                          ),
                          Visibility(
                            visible: catePurFlag == 'N',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Category: ',
                                  style: TextStyle(
                                    fontFamily: 'inter',
                                    fontSize: subTitleFontSize,
                                    color: subTitleTextColor,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: widget.bidCategoryData
                                                  .subCategoryFound ==
                                              'Y' &&
                                          widget.bidscreendetails
                                                  .ipoPurchased ==
                                              'N'
                                      ? () {
                                          showModalBottomSheet(
                                            enableDrag: false,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(20)),
                                            ),
                                            context: context,
                                            isDismissible: false,
                                            useSafeArea: true,
                                            builder: (BuildContext context) {
                                              return MyBottomSheet(
                                                hniFunc: () {
                                                  hniCateFunc(context);
                                                },
                                                indFunc: () {
                                                  indCateFunc(context);
                                                },
                                                selectedvalue:
                                                    selectedTilevalue,
                                                cateChangeText: cateChangeText!,
                                                cateInfoText: cateResetText!,
                                                indtext: widget
                                                    .bidCategoryData.category!,
                                                hnitext: widget
                                                    .bidCategoryData
                                                    .subCategoryList![0]
                                                    .category!,
                                                indCode: widget
                                                    .bidCategoryData.code!,
                                                hniCode: widget.bidCategoryData
                                                    .subCategoryList![0].code!,
                                                hniRangText: widget
                                                    .bidCategoryData
                                                    .hniRangeText!,
                                                indRangText: widget
                                                    .bidCategoryData
                                                    .indRangeText!,
                                              );
                                            },
                                          );
                                        }
                                      : null,
                                  child: Row(
                                    children: [
                                      Text(
                                        categorytext!,
                                        style: TextStyle(
                                          fontFamily: 'inter',
                                          fontSize: subTitleFontSize,
                                          color: themeBasedColor,
                                        ),
                                      ),
                                      Visibility(
                                        visible: categoryValue!.isNotEmpty,
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 3),
                                          padding: const EdgeInsets.only(
                                              top: 1.0,
                                              bottom: 2.0,
                                              left: 5.0,
                                              right: 5.0),
                                          decoration: BoxDecoration(
                                              color: subTitleTextColor
                                                  .withOpacity(0.6),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(5.0))),
                                          child: Center(
                                            child: Text(
                                              categoryValue!,
                                              style: TextStyle(
                                                fontFamily: 'inter',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                                color: themeModeLight
                                                    ? titleTextColorDark
                                                    : titleTextColorDark,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Visibility(
                                        visible: widget.bidCategoryData
                                                    .subCategoryFound ==
                                                'Y' &&
                                            widget.bidscreendetails
                                                    .ipoPurchased ==
                                                'N',
                                        child: Icon(
                                            Icons.keyboard_arrow_down_rounded),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          // Visibility(
                          //   visible: hniIndicator!,
                          //   // hniEnable &&
                          //   //     widget.bidCategoryData.subCategoryFound == 'Y' &&
                          //   //     widget.bidscreendetails.ipoPurchased == 'N',
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       showModalBottomSheet(
                          //         enableDrag: false,
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.vertical(
                          //               top: Radius.circular(20)),
                          //         ),
                          //         context: context,
                          //         isDismissible: false,
                          //         useSafeArea: true,
                          //         builder: (BuildContext context) {
                          //           return MyBottomSheet(
                          //             hniFunc: () {
                          //               hniCateFunc(context);
                          //             },
                          //             indFunc: () {
                          //               indCateFunc(context);
                          //             },
                          //             selectedvalue: selectedTilevalue,
                          //             cateChangeText: cateChangeText!,
                          //             cateInfoText: cateResetText!,
                          //             indtext: widget.bidCategoryData.category!,
                          //             hnitext: widget.bidCategoryData
                          //                 .subCategoryList![0].category!,
                          //             indCode: widget.bidCategoryData.code!,
                          //             hniCode: widget.bidCategoryData
                          //                 .subCategoryList![0].code!,
                          //             hniRangText:
                          //                 widget.bidCategoryData.hniRangeText!,
                          //             indRangText:
                          //                 widget.bidCategoryData.indRangeText!,
                          //           );
                          //         },
                          //       );
                          //     },
                          //     child: Container(
                          //       alignment: Alignment.center,
                          //       padding: EdgeInsets.all(10),
                          //       decoration: BoxDecoration(
                          //           boxShadow: [
                          //             BoxShadow(
                          //               color: themeModeLight
                          //                   ? Color.fromARGB(255, 228, 225, 225)
                          //                       .withOpacity(0.6)
                          //                   : titleTextColorLight
                          //                       .withOpacity(0.5),
                          //               spreadRadius: 3,
                          //               blurRadius: 3,
                          //               offset: Offset(
                          //                   0, 1), // changes position of shadow
                          //             ),
                          //           ],
                          //           color: themeModeLight
                          //               ? modifyButtonColor.withOpacity(0.5)
                          //               : modifyButtonColor,
                          //           // border: Border.all(
                          //           //     color:
                          //           //         subTitleTextColor.withOpacity(0.5),
                          //           //     width: 0.8),
                          //           borderRadius: BorderRadius.circular(10)),
                          //       child: Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceAround,
                          //         children: [
                          //           Expanded(
                          //             child: Text(
                          //               softWrap: true,
                          //               cateChangeText!,
                          //               style: TextStyle(
                          //                   color: titleTextColorLight
                          //                       .withOpacity(0.9),
                          //                   fontSize: 12,
                          //                   fontWeight: FontWeight.w600),
                          //             ),
                          //           ),
                          //           SizedBox(
                          //             width: 5,
                          //           ),
                          //           Icon(
                          //             Icons.arrow_forward_ios_rounded,
                          //             color: titleTextColorLight,
                          //             size: 17,
                          //           )
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Visibility(
                          //   visible: (isModify == false &&
                          //           // hniEnable &&
                          //           widget.bidCategoryData.code == 'IND' &&
                          //           widget.bidCategoryData.subCategoryFound ==
                          //               'Y' &&
                          //           widget.bidCategoryData.subCategoryList != null
                          //       //  &&
                          //       // subMaxTotalvalue >= highest &&
                          //       // subMinTotalvalue <= highest
                          //       ),
                          //   child: Center(
                          //     child: InkWell(
                          //         onTap: () {
                          //           showModalBottomSheet(
                          //             shape: RoundedRectangleBorder(
                          //               borderRadius: BorderRadius.vertical(
                          //                   top: Radius.circular(20)),
                          //             ),
                          //             context: context,
                          //             builder: (BuildContext context) {
                          //               // int _selectedValue = 1;
                          //               return
                          //                   // Container(
                          //                   //   // decoration: BoxDecoration(
                          //                   //   //   color: Colors.red,
                          //                   //   //   borderRadius: BorderRadius.only(
                          //                   //   //     topLeft: Radius.circular(20.0),
                          //                   //   //     topRight: Radius.circular(20.0),
                          //                   //   //   ),
                          //                   //   // ),
                          //                   //   child: Wrap(
                          //                   //     children: <Widget>[
                          //                   //       ListTile(
                          //                   //         title: Center(
                          //                   //             child: Text('Select Option')),
                          //                   //         titleAlignment:
                          //                   //             ListTileTitleAlignment.center,
                          //                   //         // trailing: Expanded(child: SizedBox()),
                          //                   //       ),
                          //                   //       RadioListTile(
                          //                   //         title: Text('IND'),
                          //                   //         value: 1,
                          //                   //         groupValue: _selectedValue,
                          //                   //         onChanged: (int? value) {
                          //                   //           setState(() {
                          //                   //             _selectedValue = value!;
                          //                   //           });
                          //                   //           ////print(_selectedValue);
                          //                   //           // Navigator.pop(context);
                          //                   //         },
                          //                   //       ),
                          //                   //       RadioListTile(
                          //                   //         title: Text('HNI'),
                          //                   //         value: 2,
                          //                   //         groupValue: _selectedValue,
                          //                   //         onChanged: (int? value) {
                          //                   //           setState(() {
                          //                   //             _selectedValue = value!;
                          //                   //           });
                          //                   //           ////print(_selectedValue);
                          //                   //           // Navigator.pop(context);
                          //                   //         },
                          //                   //       ),
                          //                   //     ],
                          //                   //   ),
                          //                   // );

                          //                   MyBottomSheet(
                          //                 hniFunc: () {
                          //                   hniCateFunc(context);
                          //                 },
                          //                 indFunc: () {
                          //                   indCateFunc(context);
                          //                 },
                          //                 selectedvalue: selectedTilevalue,
                          //                 cateChangeText: cateChangeText!,
                          //                 cateInfoText: cateResetText!,
                          //                 indtext: widget.bidCategoryData.category!,
                          //                 hnitext: widget.bidCategoryData
                          //                     .subCategoryList![0].category!,
                          //                 indCode: widget.bidCategoryData.code!,
                          //                 hniCode: widget.bidCategoryData
                          //                     .subCategoryList![0].code!,
                          //                 // selectedvalue: 2,
                          //               );
                          //             },
                          //           );
                          //         },
                          //         child: Container(
                          //           width: double.infinity,
                          //           margin: EdgeInsets.all(8),
                          //           padding: EdgeInsets.all(15.0),
                          //           decoration: BoxDecoration(
                          //               // color: Colors.red,
                          //               border: Border.all(
                          //                   width: 1.0, color: themeBasedColor),
                          //               borderRadius: BorderRadius.circular(20.0)),
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               Expanded(
                          //                 child: Text(
                          //                   cateChangeText!,
                          //                   softWrap: true,
                          //                   style: TextStyle(fontSize: 13.0),
                          //                 ),
                          //               ),
                          //               Icon(
                          //                 Icons.arrow_forward_ios_rounded,
                          //                 size: 16.0,
                          //               )
                          //             ],
                          //           ),
                          //         )

                          //         // InfoContainer(
                          //         //     // infoMsg: widget.bidCategoryData.infoText!
                          //         //     infoMsg: cateResetText!
                          //         //     // 'IPO window will remain open from 10 AM to 5 PM,\nHowever your may apply after 5 PM as offline.',
                          //         //     ),

                          //         //  Text(cateResetText!),
                          //         ),
                          //   ),
                          // ),
                          // DropdownButtonFormField(
                          //   value: _selectedItem,
                          //   items: widget.bidCategoryData.subcategoryOptions!
                          //       .map((String item) {
                          //     return DropdownMenuItem(
                          //       value: item,
                          //       child: Text(item),
                          //     );
                          //   }).toList(),
                          //   onChanged: (value) {
                          //     setState(() {
                          //       _selectedItem = value;
                          //     });
                          //   },
                          //   decoration: InputDecoration(
                          //     labelText: 'Select an item',
                          //     border: OutlineInputBorder(),
                          //   ),
                          // ),
                          SizedBox(
                            height: 25,
                            // widget.bidCategoryData.cancelAllowed! ? 10 : 25.0,
                          ),
                          /* BidField Container...*/
                          isLoaded
                              ? LinearProgressIndicator(
                                  color: Colors.white38,
                                  backgroundColor: Colors.grey.shade400,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(50),
                                )
                              : Column(
                                  children: containers
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => entry.value,
                                      )
                                      .toList(),
                                ),
                          Visibility(
                            visible: !(modifyAllowed == false &&
                                    catePurFlag == 'Y') &&
                                (isLoaded || containers.length >= 3
                                    ? false
                                    : true),
                            child: Center(
                              child: TextButton(
                                  onPressed: () {
                                    // _requestReview();
                                    setState(() {
                                      onchange = true;
                                    });
                                    totalAmountValidation();
                                  },
                                  child: Icon(
                                    CupertinoIcons.add,
                                    size: 30.0,
                                  )),
                            ),
                          ),
                          // SizedBox(
                          //   height: 5.0,
                          // ),

                          // SizedBox(
                          //   height: 15.0,
                          // ),

                          SizedBox(
                            height: 15.0,
                          ),
                          Visibility(
                            visible: cateDisclaimer!.isNotEmpty &&
                                cateDisclaimer != null,
                            child: Column(
                              children: [
                                BulletList(cateDisclaimer!, infoColor),
                                const SizedBox(
                                  height: 20.0,
                                ),
                              ],
                            ),
                          ),

                          Visibility(
                            visible: showSI == true,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  siValue = !(siValue ?? false);

                                  checkButtonValidation();
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      // color: Colors.red,
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            5.0), // Set the radius to 2.0
                                        color: siValue == true &&
                                                Provider.of<NavigationProvider>(
                                                            context)
                                                        .themeMode !=
                                                    ThemeMode.dark
                                            ? appPrimeColor
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: siValue == false && recheck
                                              ? primaryRedColor
                                              : subTitleTextColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: siValue == true
                                          ? const Icon(
                                              CupertinoIcons.check_mark,
                                              color: Colors.white,
                                              size: 12,
                                            )
                                          : null,
                                    ),
                                    SizedBox(
                                      width: 12.0,
                                    ),
                                    Expanded(
                                      // width: MediaQuery.of(context).size.width *
                                      //     0.78, // Set the maximum width as a percentage of the screen width
                                      child: Text(
                                        // 'I hereby undertake that I have read the Red Herring Prospectus and I am an eligible UPI bidder as per the application provisions of the SEBI (Issue of Capital and Disclosure Requirement) Regulation, 2009.',
                                        siText ?? '',
                                        style: TextStyle(
                                            fontFamily: 'inter',
                                            fontSize: contentFontSize,
                                            color: subTitleTextColor),
                                        textAlign: TextAlign.justify,
                                        overflow: TextOverflow
                                            .visible, // Set the overflow behavior
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              color: Provider.of<NavigationProvider>(context).themeMode ==
                      ThemeMode.dark
                  ? Color.fromRGBO(48, 48, 48, 1)
                  : Color.fromRGBO(240, 240, 240, 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.end,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /*Total Amount Section...*/
                  Visibility(
                    visible: isDeleteIndicator &&
                        widget.bidCategoryData.hniModifyInfoText!.isNotEmpty,
                    child: Container(
                      // alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: themeModeLight
                                  ? Color.fromARGB(255, 228, 225, 225)
                                      .withOpacity(0.6)
                                  : titleTextColorLight.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset:
                                  Offset(0, 1), // changes position of shadow
                            ),
                          ],
                          color: themeModeLight
                              ? modifyButtonColor.withOpacity(0.5)
                              : modifyButtonColor,
                          // border: Border.all(
                          //     color:
                          //         subTitleTextColor.withOpacity(0.5),
                          //     width: 0.8),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: titleTextColorLight,
                            size: 16,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Text(
                              softWrap: true,
                              widget.bidCategoryData.hniModifyInfoText!,
                              style: TextStyle(
                                  color: titleTextColorLight.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: hniIndicator! && cateChangeText!.isNotEmpty,
                    // hniEnable &&
                    //     widget.bidCategoryData.subCategoryFound == 'Y' &&
                    //     widget.bidscreendetails.ipoPurchased == 'N',
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          enableDrag: false,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          context: context,
                          isDismissible: false,
                          useSafeArea: true,
                          builder: (BuildContext context) {
                            return MyBottomSheet(
                              hniFunc: () {
                                hniCateFunc(context);
                              },
                              indFunc: () {
                                indCateFunc(context);
                              },
                              selectedvalue: selectedTilevalue,
                              cateChangeText: cateChangeText!,
                              cateInfoText: cateResetText!,
                              indtext: widget.bidCategoryData.category!,
                              hnitext: widget.bidCategoryData
                                  .subCategoryList![0].category!,
                              indCode: widget.bidCategoryData.code!,
                              hniCode: widget
                                  .bidCategoryData.subCategoryList![0].code!,
                              hniRangText: widget.bidCategoryData.hniRangeText!,
                              indRangText: widget.bidCategoryData.indRangeText!,
                            );
                          },
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: themeModeLight
                                    ? Color.fromARGB(255, 228, 225, 225)
                                        .withOpacity(0.6)
                                    : titleTextColorLight.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 3,
                                offset:
                                    Offset(0, 1), // changes position of shadow
                              ),
                            ],
                            color: themeModeLight
                                ? modifyButtonColor.withOpacity(0.5)
                                : modifyButtonColor,
                            // border: Border.all(
                            //     color:
                            //         subTitleTextColor.withOpacity(0.5),
                            //     width: 0.8),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Text(
                                softWrap: true,
                                cateChangeText!,
                                style: TextStyle(
                                    color: titleTextColorLight.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: titleTextColorLight,
                              size: 17,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Visibility(
                  //   visible: widget.bidCategoryData.discountPrice != 0,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         'Total Amount: ',
                  //         style: TextStyle(
                  //             fontFamily: 'inter',
                  //             color: Provider.of<NavigationProvider>(
                  //                             context)
                  //                         .themeMode ==
                  //                     ThemeMode.dark
                  //                 ? Colors.black
                  //                 : titleTextColorLight,
                  //             fontSize: 12.0,
                  //             fontWeight: FontWeight.bold),
                  //       ),
                  //       Text(
                  //         '${totalAmount.toString()}',
                  //         style: TextStyle(
                  //             fontSize: 14,
                  //             color: primaryGreenColor,
                  //             fontWeight: FontWeight.bold),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Visibility(
                  //   visible: widget.bidCategoryData.discountPrice != 0,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         'Discount Applied: ',
                  //         style: TextStyle(
                  //             fontFamily: 'inter',
                  //             color: Provider.of<NavigationProvider>(
                  //                             context)
                  //                         .themeMode ==
                  //                     ThemeMode.dark
                  //                 ? Colors.black
                  //                 : titleTextColorLight,
                  //             fontSize: 12.0,
                  //             fontWeight: FontWeight.bold),
                  //       ),
                  //       Text(
                  //         widget.bidCategoryData.discountType == 'A'
                  //             ? widget.bidCategoryData.discountPrice !=
                  //                     0
                  //                 ? discountApplied
                  //                 : 'NA'
                  //             : widget.bidCategoryData.discountPrice !=
                  //                     0
                  //                 ? discountApplied
                  //                 : 'NA',
                  //         style: TextStyle(
                  //             fontSize: 14,
                  //             color: primaryGreenColor,
                  //             fontWeight: FontWeight.bold),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          Provider.of<NavigationProvider>(context).themeMode ==
                                  ThemeMode.dark
                              ? Color.fromRGBO(48, 48, 48, 1)
                              : Colors.white,
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(1, 0),
                            spreadRadius: 1,
                            color: Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? Color.fromRGBO(99, 97, 97, 1)
                                : const Color.fromARGB(255, 221, 220, 220),
                            blurRadius: 2)
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount Payable ',
                            style: TextStyle(
                                fontFamily: 'inter',
                                color: Provider.of<NavigationProvider>(context)
                                            .themeMode ==
                                        ThemeMode.dark
                                    ? const Color.fromARGB(255, 240, 231, 231)
                                    : titleTextColorLight,
                                fontSize: 14.0,
                                height: 1.5,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            rsFormat
                                .format(amountPayable < 0 ? 0 : amountPayable),
                            style: TextStyle(
                                fontFamily: 'inter',
                                color: amountPayable == 0.0
                                    ? Provider.of<NavigationProvider>(context)
                                                .themeMode ==
                                            ThemeMode.dark
                                        ? Colors.black
                                        : Colors.black
                                    : highestColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !(modifyAllowed == false && catePurFlag == 'Y'),
                    child: MaterialButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        disabledColor: Color.fromARGB(255, 133, 130, 130),
                        minWidth: MediaQuery.of(context).size.width,
                        height: 40,
                        color: appPrimeColor,
                        onPressed: submitLoading ||
                                buttonEnable == false ||
                                (modifyAllowed == false && catePurFlag == 'Y')
                            ? null
                            : () {
                                postIpoPlaceOrder();
                              },
                        child: Text(
                          // widget.bidCategoryData.categoryButtonText!.isEmpty
                          buttonText!.isEmpty ? 'Submit' : buttonText!,
                          style: TextStyle(
                            color: (modifyAllowed == false &&
                                        catePurFlag == 'Y') ||
                                    buttonEnable
                                ? Colors.white
                                : Colors.white.withOpacity(0.20),
                            fontSize: 18.0,
                            fontFamily: 'inter',
                            fontWeight: FontWeight.w700,
                            height: 1.04,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Deleteappbutton extends StatefulWidget {
  Deleteappbutton(
      {super.key,
      required this.deleteLoading,
      required this.deleteApplication});

  final deleteApplication;
  bool deleteLoading;

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
