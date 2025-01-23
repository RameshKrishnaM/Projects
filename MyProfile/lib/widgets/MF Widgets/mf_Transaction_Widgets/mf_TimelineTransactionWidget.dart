import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/utils/colors.dart';
import 'package:novo/widgets/MF%20Widgets/mfCustomAlertBox.dart';
import 'package:novo/widgets/NOVO%20Widgets/customLoadingAni.dart';
import 'package:novo/widgets/NOVO%20Widgets/custom_NodataWidget.dart';
import 'package:novo/widgets/NOVO%20Widgets/netWorkConnectionAlertBox.dart';
import 'package:novo/widgets/NOVO%20Widgets/validationformat.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../../API/MFAPICall.dart';
import '../../../model/mfModels/mf_transactionStatus_model.dart';
import '../../../model/mfModels/mf_transaction_data.dart';
import '../mfcustomvisibelSnackbar.dart';

Future mfTransactionBottomSheet(
    {required BuildContext context,
    required MfTransactionDatum mfTransactionDatum}) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    elevation: 0,
    context: context,
    backgroundColor: Colors.white,
    useSafeArea: true,
    builder: (context) {
      return TransactionStatusWidget(
        mfTransactionDatum: mfTransactionDatum,
      );
    },
  );
}

class TransactionStatusWidget extends StatefulWidget {
  final MfTransactionDatum mfTransactionDatum;
  const TransactionStatusWidget({super.key, required this.mfTransactionDatum});

  @override
  State<TransactionStatusWidget> createState() =>
      _TransactionStatusWidgetState();
}

class _TransactionStatusWidgetState extends State<TransactionStatusWidget> {
  bool showCopyTextSnackBar = false;
  bool remarkShow = false;
  bool isLoading = true;
  MfTransactionStatusDetails? mfTransactionStatusDetails;
  @override
  void initState() {
    super.initState();
    getTransStatausData(context);
  }

  getTransStatausData(context) async {
    if (await isInternetConnected()) {
      mfTransactionStatusDetails = await fetchMfTransStatusDetailsAPI(
          context: context,
          transactionstatusDetails: {
            "transNo": widget.mfTransactionDatum.transNo
          });
      isLoading = false;
      setState(() {});
    } else {
      noInternetConnectAlertDialog(context, () => getTransStatausData(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 25,
              ),
              LoadingProgress(),
              SizedBox(
                height: 25,
              ),
            ],
          )
        : mfTransactionStatusDetails == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: noDataFoundWidget(context),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //       top: 10.0, bottom: 0, left: 20, right: 10),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       const Expanded(child: SizedBox()),
                  //       Icon(
                  //         widget.mfTransactionDatum.maxOrderColor == "S"
                  //             ? Icons.check_circle_rounded
                  //             : widget.mfTransactionDatum.maxOrderColor == "F"
                  //                 ? Icons.cancel
                  //                 : Icons.access_time_filled_rounded,
                  //         size: 18,
                  //         color: widget.mfTransactionDatum.maxOrderColor == "S"
                  //             ? primaryGreenColor
                  //             : widget.mfTransactionDatum.maxOrderColor == "F"
                  //                 ? primaryRedColor
                  //                 : titleTextColorLight,
                  //       ),
                  //       const SizedBox(
                  //         width: 6,
                  //       ),
                  //       Text(
                  //         widget.mfTransactionDatum.stepperInfo!,
                  //         textAlign: TextAlign.center,
                  //         style: ThemeClass.lighttheme.textTheme.bodySmall!
                  //             .copyWith(
                  //                 fontSize: 16,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: widget.mfTransactionDatum.maxOrderColor ==
                  //                         "S"
                  //                     ? primaryGreenColor
                  //                     : widget.mfTransactionDatum.maxOrderColor ==
                  //                             "F"
                  //                         ? primaryRedColor
                  //                         : titleTextColorLight),
                  //       ),
                  //       const Expanded(child: SizedBox()),
                  //       InkWell(
                  //         onTap: () => Navigator.pop(context),
                  //         child: Icon(
                  //           Icons.close,
                  //           size: 20,
                  //           color: titleTextColorLight,
                  //         ),
                  //       )
                  //     ],
                  //   ),

                  //   //  Row(
                  //   //   mainAxisAlignment: MainAxisAlignment.end,
                  //   //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   //   children: [
                  //   //     const Expanded(child: SizedBox()),
                  //   //     Icon(
                  //   //       widget.mfTransactionDatum.maxOrderColor == "S"
                  //   //           ? Icons.check_circle_rounded
                  //   //           : widget.mfTransactionDatum.maxOrderColor == "F"
                  //   //               ? Icons.cancel
                  //   //               : Icons.access_time_filled_rounded,
                  //   //       size: 18,
                  //   //       color: widget.mfTransactionDatum.maxOrderColor == "S"
                  //   //           ? primaryGreenColor
                  //   //           : widget.mfTransactionDatum.maxOrderColor == "F"
                  //   //               ? primaryRedColor
                  //   //               : titleTextColorLight,
                  //   //     ),
                  //   //     const SizedBox(
                  //   //       width: 6,
                  //   //     ),
                  //   //     Text(
                  //   //       widget.mfTransactionDatum.stepperInfo!,
                  //   //       textAlign: TextAlign.center,
                  //   //       style: ThemeClass.lighttheme.textTheme.bodySmall!
                  //   //           .copyWith(
                  //   //               fontSize: 16,
                  //   //               fontWeight: FontWeight.bold,
                  //   //               color: widget.mfTransactionDatum.maxOrderColor ==
                  //   //                       "S"
                  //   //                   ? primaryGreenColor
                  //   //                   : widget.mfTransactionDatum.maxOrderColor ==
                  //   //                           "F"
                  //   //                       ? primaryRedColor
                  //   //                       : titleTextColorLight),
                  //   //     ),
                  //   //     const Expanded(child: SizedBox()),
                  //   //     InkWell(
                  //   //       onTap: () => Navigator.pop(context),
                  //   //       child: Icon(
                  //   //         Icons.close,
                  //   //         size: 20,
                  //   //         color: titleTextColorLight,
                  //   //       ),
                  //   //     )
                  //   //   ],
                  //   // ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                widget.mfTransactionDatum.maxOrderColor == "S"
                                    ? Icons.check_circle_rounded
                                    : widget.mfTransactionDatum.maxOrderColor ==
                                                "F" ||
                                            widget.mfTransactionDatum
                                                    .maxOrderColor ==
                                                "CL"
                                        ? Icons.cancel
                                        : Icons.timelapse_rounded,
                                size: 18,
                                color: widget
                                            .mfTransactionDatum.maxOrderColor ==
                                        "S"
                                    ? primaryGreenColor
                                    : widget.mfTransactionDatum.maxOrderColor ==
                                            "F"
                                        ? primaryRedColor
                                        : widget.mfTransactionDatum
                                                    .maxOrderColor ==
                                                "CL"
                                            ? primaryOrangeColor
                                            : titleTextColorLight,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(
                                mfTransactionStatusDetails!.transInfo ?? '',
                                textAlign: TextAlign.center,
                                style: ThemeClass
                                    .lighttheme.textTheme.bodySmall!
                                    .copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: mfTransactionStatusDetails!
                                                    .transStatus ==
                                                "S"
                                            ? primaryGreenColor
                                            : mfTransactionStatusDetails!
                                                        .transStatus ==
                                                    "F"
                                                ? primaryRedColor
                                                : mfTransactionStatusDetails!
                                                            .transStatus ==
                                                        "CL"
                                                    ? primaryOrangeColor
                                                    : titleTextColorLight),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.close,
                              color: titleTextColorLight,
                              size: 20,
                            )),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.only(left: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
//PlaceOrder TimeLine Widget...
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: TimelineTile(
                            axis: TimelineAxis.vertical,
                            isFirst: true,
                            isLast: mfTransactionStatusDetails!
                                        .orderColor!.isEmpty ||
                                    mfTransactionStatusDetails!.orderColor ==
                                        'E'
                                ? true
                                : false,
                            indicatorStyle: IndicatorStyle(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                iconStyle: IconStyle(
                                    iconData: mfTransactionStatusDetails!
                                                .placedColor ==
                                            "S"
                                        ? Icons.done
                                        : mfTransactionStatusDetails!
                                                    .placedColor ==
                                                "D"
                                            ? Icons.timelapse_rounded
                                            : Icons.close,
                                    fontSize: 9,
                                    color: Colors.white),
                                width: 15,
                                color: mfTransactionStatusDetails!
                                            .placedColor ==
                                        "S"
                                    ? activeColor
                                    : mfTransactionStatusDetails!.placedColor ==
                                            "F"
                                        ? primaryRedColor
                                        : titleTextColorLight.withOpacity(0.5)),
                            afterLineStyle: LineStyle(
                                thickness: 1.7,
                                color: mfTransactionStatusDetails!.orderColor ==
                                        "S"
                                    ? activeColor
                                    : mfTransactionStatusDetails!.orderColor ==
                                            'F'
                                        ? primaryRedColor
                                        : mfTransactionStatusDetails!
                                                    .orderColor ==
                                                'CL'
                                            ? primaryOrangeColor
                                            : mfTransactionStatusDetails!
                                                        .orderColor ==
                                                    "D"
                                                ? titleTextColorLight
                                                    .withOpacity(0.5)
                                                : titleTextColorLight
                                                    .withOpacity(0.5)),
                            endChild: Container(
                              margin: const EdgeInsets.only(left: 10, top: 20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 4),
                              decoration: BoxDecoration(
                                  color:
                                      mfTransactionStatusDetails!.placedColor ==
                                              "S"
                                          ? primaryGreenColor.withOpacity(0.1)
                                          : mfTransactionStatusDetails!
                                                      .placedColor ==
                                                  "F"
                                              ? primaryRedColor.withOpacity(0.1)
                                              : inactiveColor,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mfTransactionStatusDetails!
                                              .placedStatus ??
                                          '-',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: mfTransactionStatusDetails!
                                                          .placedColor ==
                                                      "S"
                                                  ? primaryGreenColor
                                                  : mfTransactionStatusDetails!
                                                              .placedColor ==
                                                          "F"
                                                      ? primaryRedColor
                                                      : titleTextColorLight),
                                    ),
                                    Visibility(
                                      visible: mfTransactionStatusDetails!
                                              .placedDate!.isNotEmpty ||
                                          mfTransactionStatusDetails!
                                              .placedTime!.isNotEmpty,
                                      child: Text(
                                        '${mfTransactionStatusDetails!.placedDate!}, ${mfTransactionStatusDetails!.placedTime!}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                height: 1.5,
                                                color: mfTransactionStatusDetails!
                                                            .placedColor ==
                                                        "S"
                                                    ? primaryGreenColor
                                                        .withOpacity(0.7)
                                                    : mfTransactionStatusDetails!
                                                                .placedColor ==
                                                            "F"
                                                        ? primaryRedColor
                                                            .withOpacity(0.5)
                                                        : titleTextColorLight
                                                            .withOpacity(0.5),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10),
                                      ),
                                    ),
                                    Visibility(
                                      visible: mfTransactionStatusDetails!
                                          .transNo!.isNotEmpty,
                                      child: InkWell(
                                        onTap: () async {
                                          Clipboard.setData(ClipboardData(
                                              text: mfTransactionStatusDetails!
                                                  .transNo!));
                                          showCopyTextSnackBar = true;
                                          if (mounted) {
                                            setState(() {});
                                          }

                                          await Future.delayed(
                                              const Duration(seconds: 3));

                                          showCopyTextSnackBar = false;
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text('Order# ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                        fontSize: 11,
                                                        height: 1.5,
                                                        color: mfTransactionStatusDetails!
                                                                    .placedColor ==
                                                                "S"
                                                            ? primaryGreenColor
                                                            : mfTransactionStatusDetails!
                                                                        .placedColor ==
                                                                    "F"
                                                                ? primaryRedColor
                                                                : titleTextColorLight)),
                                            Text(
                                                mfTransactionStatusDetails!
                                                    .transNo!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 1.5,
                                                        color: mfTransactionStatusDetails!
                                                                    .placedColor ==
                                                                "S"
                                                            ? primaryGreenColor
                                                            : mfTransactionStatusDetails!
                                                                        .placedColor ==
                                                                    "F"
                                                                ? primaryRedColor
                                                                : titleTextColorLight)),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Icon(
                                              Icons.copy_rounded,
                                              color: subTitleTextColor,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
//Order Status For Timeline Widget....
                        Visibility(
                          visible:
                              mfTransactionStatusDetails!.placedColor != 'F' &&
                                  mfTransactionStatusDetails!
                                      .orderColor!.isNotEmpty,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.65,
                            child: TimelineTile(
                              axis: TimelineAxis.vertical,
                              isFirst: false,
                              isLast:
                                  mfTransactionStatusDetails!.orderColor ==
                                              'D' ||
                                          mfTransactionStatusDetails!
                                                  .orderColor ==
                                              'F' ||
                                          mfTransactionStatusDetails!
                                                  .orderColor ==
                                              'CL'
                                      ? true
                                      : false,
                              indicatorStyle: IndicatorStyle(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  iconStyle: IconStyle(
                                      iconData: mfTransactionStatusDetails!
                                                  .orderColor ==
                                              "S"
                                          ? Icons.done
                                          : mfTransactionStatusDetails!.orderColor ==
                                                      "F" ||
                                                  mfTransactionStatusDetails!
                                                          .orderColor ==
                                                      "CL"
                                              ? Icons.close
                                              : mfTransactionStatusDetails!
                                                          .orderColor ==
                                                      "D"
                                                  ? Icons.timelapse_rounded
                                                  : mfTransactionStatusDetails!
                                                              .orderColor ==
                                                          "E"
                                                      ? Icons.circle
                                                      : Icons.circle,
                                      fontSize: 9,
                                      color: Colors.white),
                                  width: 15,
                                  color: mfTransactionStatusDetails!.orderColor ==
                                          "S"
                                      ? activeColor
                                      : mfTransactionStatusDetails!.orderColor ==
                                              'F'
                                          ? primaryRedColor
                                          : mfTransactionStatusDetails!.orderColor ==
                                                  'CL'
                                              ? primaryOrangeColor
                                              : mfTransactionStatusDetails!
                                                          .orderColor ==
                                                      "D"
                                                  ? titleTextColorLight
                                                      .withOpacity(0.5)
                                                  : titleTextColorLight
                                                      .withOpacity(0.5)),
                              beforeLineStyle: LineStyle(
                                  thickness: 1.7,
                                  color:
                                      mfTransactionStatusDetails!.orderColor ==
                                              "S"
                                          ? activeColor
                                          : mfTransactionStatusDetails!
                                                      .orderColor ==
                                                  'F'
                                              ? primaryRedColor
                                              : mfTransactionStatusDetails!
                                                          .orderColor ==
                                                      'CL'
                                                  ? primaryOrangeColor
                                                  : mfTransactionStatusDetails!
                                                              .orderColor ==
                                                          "D"
                                                      ? titleTextColorLight
                                                          .withOpacity(0.5)
                                                      : titleTextColorLight
                                                          .withOpacity(0.5)),
                              afterLineStyle: LineStyle(
                                  thickness: 1.7,
                                  color: mfTransactionStatusDetails!
                                              .allotmentColor ==
                                          "S"
                                      ? activeColor
                                      : mfTransactionStatusDetails!
                                                  .allotmentColor ==
                                              'F'
                                          ? primaryRedColor
                                          : mfTransactionStatusDetails!
                                                      .allotmentColor ==
                                                  'D'
                                              ? titleTextColorLight
                                                  .withOpacity(0.5)
                                              : titleTextColorLight
                                                  .withOpacity(0.5)),
                              endChild: Container(
                                margin:
                                    const EdgeInsets.only(left: 10, top: 20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 4),
                                decoration: BoxDecoration(
                                    color: mfTransactionStatusDetails!
                                                .orderColor ==
                                            "S"
                                        ? primaryGreenColor.withOpacity(0.1)
                                        : mfTransactionStatusDetails!
                                                    .orderColor ==
                                                "F"
                                            ? primaryRedColor.withOpacity(0.1)
                                            : mfTransactionStatusDetails!
                                                        .orderColor ==
                                                    "CL"
                                                ? primaryOrangeColor
                                                    .withOpacity(0.1)
                                                : inactiveColor,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 5.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mfTransactionStatusDetails!
                                            .orderStatus!,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: mfTransactionStatusDetails!
                                                            .orderColor ==
                                                        "S"
                                                    ? primaryGreenColor
                                                    : mfTransactionStatusDetails!
                                                                .orderColor ==
                                                            "F"
                                                        ? primaryRedColor
                                                        : mfTransactionStatusDetails!
                                                                    .orderColor ==
                                                                "CL"
                                                            ? primaryOrangeColor
                                                            : titleTextColorLight),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            mfTransactionStatusDetails!
                                                        .orderColor ==
                                                    'D'
                                                ? '${mfTransactionStatusDetails!.placedDate!}, ${mfTransactionStatusDetails!.placedTime!}'
                                                : '${mfTransactionStatusDetails!.orderStatusDate!}, ${mfTransactionStatusDetails!.orderStatusTime!}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    height: 1.5,
                                                    color: mfTransactionStatusDetails!
                                                                .orderColor ==
                                                            "S"
                                                        ? primaryGreenColor
                                                            .withOpacity(0.7)
                                                        : mfTransactionStatusDetails!
                                                                    .orderColor ==
                                                                "F"
                                                            ? primaryRedColor
                                                                .withOpacity(
                                                                    0.5)
                                                            : mfTransactionStatusDetails!
                                                                        .orderColor ==
                                                                    "CL"
                                                                ? primaryOrangeColor
                                                                    .withOpacity(
                                                                        0.5)
                                                                : titleTextColorLight
                                                                    .withOpacity(
                                                                        0.5),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Visibility(
                                            visible: mfTransactionStatusDetails!
                                                    .orderColor ==
                                                'F',
                                            child: InkWell(
                                              onTap: () {
                                                customMfAlertBox(
                                                    context: context,
                                                    title: 'Info',
                                                    contentWidget: Text(
                                                      mfTransactionStatusDetails!
                                                              .remarks ??
                                                          '',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall,
                                                    ),
                                                    func1: null);
                                              },
                                              child: Icon(
                                                Icons.info_outline_rounded,
                                                color: subTitleTextColor,
                                                size: 14,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Visibility(
                                        visible:
                                            mfTransactionStatusDetails!.nfo ==
                                                    'Y' &&
                                                (mfTransactionStatusDetails!
                                                            .orderColor ==
                                                        "D" ||
                                                    mfTransactionStatusDetails!
                                                            .allotmentColor ==
                                                        "D"),
                                        child: Row(
                                          children: [
                                            Text('NFO ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                        fontSize: 11,
                                                        height: 1.5,
                                                        color: mfTransactionStatusDetails!
                                                                    .allotmentColor ==
                                                                "S"
                                                            ? primaryGreenColor
                                                            : mfTransactionStatusDetails!
                                                                        .allotmentColor ==
                                                                    "F"
                                                                ? primaryRedColor
                                                                : titleTextColorLight)),
                                            Text('Closed Date: ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                        fontSize: 11,
                                                        height: 1.5,
                                                        color: mfTransactionStatusDetails!
                                                                    .allotmentColor ==
                                                                "S"
                                                            ? primaryGreenColor
                                                            : mfTransactionStatusDetails!
                                                                        .allotmentColor ==
                                                                    "F"
                                                                ? primaryRedColor
                                                                : titleTextColorLight)),
                                            Text(
                                                '${mfTransactionStatusDetails!.closeDate}',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 1.5,
                                                        color: mfTransactionStatusDetails!
                                                                    .allotmentColor ==
                                                                "S"
                                                            ? primaryGreenColor
                                                            : mfTransactionStatusDetails!
                                                                        .allotmentColor ==
                                                                    "F"
                                                                ? primaryRedColor
                                                                : titleTextColorLight)),
                                            Visibility(
                                              visible:
                                                  mfTransactionStatusDetails!
                                                      .closeDateMessage!
                                                      .isNotEmpty,
                                              child: InkWell(
                                                onTap: () {
                                                  customMfAlertBox(
                                                      context: context,
                                                      title: 'NFO Info',
                                                      contentWidget: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                right: 15),
                                                        child: Text(
                                                          textAlign:
                                                              TextAlign.justify,
                                                          mfTransactionStatusDetails!
                                                                  .closeDateMessage ??
                                                              '',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                        ),
                                                      ),
                                                      func1: null);
                                                },
                                                child: Icon(
                                                  Icons.info_outline_rounded,
                                                  color: subTitleTextColor,
                                                  size: 14,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
//Allotment Status For Timeline Widget.......
                        Visibility(
                          visible: mfTransactionStatusDetails!
                                  .allotmentColor!.isNotEmpty &&
                              (mfTransactionStatusDetails!.allotmentColor !=
                                  'E') &&
                              mfTransactionStatusDetails!.orderColor != 'D' &&
                              mfTransactionStatusDetails!.orderColor != 'F',
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.65,
                            child: TimelineTile(
                              axis: TimelineAxis.vertical,
                              isFirst: false,
                              isLast: true,
                              indicatorStyle: IndicatorStyle(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  iconStyle: IconStyle(
                                      iconData: mfTransactionStatusDetails!
                                                  .allotmentColor ==
                                              "S"
                                          ? Icons.done
                                          : mfTransactionStatusDetails!
                                                      .allotmentColor ==
                                                  "F"
                                              ? Icons.close
                                              : mfTransactionStatusDetails!
                                                          .allotmentColor ==
                                                      "D"
                                                  ? Icons.timelapse_rounded
                                                  : Icons.close,
                                      fontSize: 9,
                                      color: Colors.white),
                                  width: 15,
                                  color: mfTransactionStatusDetails!
                                              .allotmentColor ==
                                          "S"
                                      ? activeColor
                                      : mfTransactionStatusDetails!
                                                  .allotmentColor ==
                                              "F"
                                          ? primaryRedColor
                                          : titleTextColorLight
                                              .withOpacity(0.5)),
                              beforeLineStyle: LineStyle(
                                  thickness: 1.7,
                                  color: mfTransactionStatusDetails!
                                              .allotmentColor ==
                                          "S"
                                      ? activeColor
                                      : mfTransactionStatusDetails!
                                                  .allotmentColor ==
                                              'F'
                                          ? primaryRedColor
                                          : mfTransactionStatusDetails!
                                                      .allotmentColor ==
                                                  'D'
                                              ? titleTextColorLight
                                                  .withOpacity(0.5)
                                              : titleTextColorLight
                                                  .withOpacity(0.5)),
                              endChild: Container(
                                margin:
                                    const EdgeInsets.only(left: 10, top: 20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 4),
                                decoration: BoxDecoration(
                                    color: mfTransactionStatusDetails!
                                                .allotmentColor ==
                                            "S"
                                        ? primaryGreenColor.withOpacity(0.1)
                                        : mfTransactionStatusDetails!
                                                    .allotmentColor ==
                                                "F"
                                            ? primaryRedColor.withOpacity(0.1)
                                            : inactiveColor,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mfTransactionStatusDetails!
                                            .allotmentStatus!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: mfTransactionStatusDetails!
                                                          .allotmentColor ==
                                                      "S"
                                                  ? primaryGreenColor
                                                  : mfTransactionStatusDetails!
                                                              .allotmentColor ==
                                                          "F"
                                                      ? primaryRedColor
                                                      : titleTextColorLight,
                                            ),
                                      ),
                                      Text(
                                        mfTransactionStatusDetails!
                                                    .allotmentColor !=
                                                "D"
                                            ? mfTransactionStatusDetails!
                                                .allotmentStatusDate!
                                            : '${mfTransactionStatusDetails!.orderStatusDate!}, ${mfTransactionStatusDetails!.orderStatusTime!}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                height: 1.5,
                                                color: mfTransactionStatusDetails!
                                                            .allotmentColor ==
                                                        "S"
                                                    ? primaryGreenColor
                                                        .withOpacity(0.7)
                                                    : mfTransactionStatusDetails!
                                                                .allotmentColor ==
                                                            "F"
                                                        ? primaryRedColor
                                                            .withOpacity(0.5)
                                                        : titleTextColorLight
                                                            .withOpacity(0.5),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10),
                                      ),
                                      Visibility(
                                        visible: mfTransactionStatusDetails!
                                                .allotmentColor !=
                                            "D",
                                        child: Text(
                                            mfTransactionStatusDetails!
                                                        .buySell ==
                                                    'R'
                                                ? mfTransactionStatusDetails!
                                                            .allotmentAmount
                                                        is double
                                                    ? '₹ ${doubleformatAmount(mfTransactionStatusDetails!.allotmentAmount)}'
                                                    : '₹ ${mfTransactionStatusDetails!.allotmentAmount!.toString()}'
                                                : mfTransactionStatusDetails!
                                                            .buySell ==
                                                        'P'
                                                    ? '${mfTransactionStatusDetails!.allotmentUnits!} Unit(s)'
                                                    : '',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.5,
                                                    color: mfTransactionStatusDetails!
                                                                .allotmentColor ==
                                                            "S"
                                                        ? primaryGreenColor
                                                        : mfTransactionStatusDetails!
                                                                    .allotmentColor ==
                                                                "F"
                                                            ? primaryRedColor
                                                            : titleTextColorLight)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25,
                    child: CustomSnackbarwithDelay(
                      bgColor: subTitleTextColor,
                      visible: showCopyTextSnackBar,
                      value: 'Text Copied',
                    ),
                  )
                  // SizedBox(
                  //   height: 25,
                  //   child: Visibility(
                  //     visible: showCopyTextSnackBar,
                  //     child: Container(
                  //       margin: const EdgeInsets.only(bottom: 5),
                  //       padding: const EdgeInsets.only(
                  //           top: 3, bottom: 5.0, left: 15, right: 15),
                  //       decoration: BoxDecoration(
                  //           color: subTitleTextColor,
                  //           borderRadius: BorderRadius.circular(10.0)),
                  //       child: Text(
                  //         'Text Copied',
                  //         style: TextStyle(
                  //             fontSize: 10.0,
                  //             fontWeight: FontWeight.bold,
                  //             color: titleTextColorDark),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              );
  }
}
