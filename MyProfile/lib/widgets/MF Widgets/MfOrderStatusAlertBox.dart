// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:novo/utils/colors.dart';

import '../NOVO Widgets/snackbar.dart';
import 'imagedecoderWidget.dart';

mfOrderStatusAlartBox({
  required BuildContext context,
  required String message,
  required String status,
  required String completeImg,
  required String transactionMsg,
  required String errorImg,
  String ftTransactionCode = '',
  String bscOrderNo = '',
  dynamic orderPlacedResp,
  String furtherSteps = '',
  String sympolImage = '',
  String purchaseType = '',
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24.0))),
          titlePadding: EdgeInsets.zero,
          contentPadding:
              const EdgeInsets.only(top: 20, bottom: 0, left: 20, right: 0),
          content: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(24.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: Image.asset(
                    status == "S" ? completeImg : errorImg,
                    width: 100,
                    height: 100,
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(
                //       top: 5, left: 10, right: 25.0, bottom: 5),
                //   child: Text(
                //     message,
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.bold,
                //         color: status == 'S'
                //             ? primaryGreenColor
                //             : primaryRedColor),
                //   ),
                // ),
                if (ftTransactionCode.isNotEmpty &&
                    status == 'S' &&
                    orderPlacedResp != null &&
                    purchaseType != 'redeem')
                  Padding(
                    padding: const EdgeInsets.only(right: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.only(
                        //       top: 5, left: 10, bottom: 5),
                        //   child: Text(
                        //     message,
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.bold,
                        //         color: status == 'S'
                        //             ? primaryGreenColor
                        //             : primaryRedColor),
                        //   ),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40.0,
                              height: 40.0,
                              margin: const EdgeInsets.only(
                                  top: 8, bottom: 8, right: 8),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child:
                                  //  Image.asset(
                                  //   status == "S" ? completeImg : errorImg,
                                  //   // width: 100,
                                  //   // height: 100,
                                  // ),
                                  sympolImage.isNotEmpty
                                      ?
                                      // Image.network(imageUrl)
                                      ImageLoader(
                                          loadingImg: sympolImage,
                                        )
                                      : const SizedBox(),
                            ),
                            Flexible(
                              child: Text(
                                orderPlacedResp['schemeName'] ?? '',
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          endIndent: 5,
                          color: inactiveColor,
                          height: 1,
                          thickness: 1,
                          indent: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Flattrade Trans No ",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Flexible(
                                child: InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                          text: ftTransactionCode));
                                      appExit(context, 'Text copied');
                                    },
                                    child: Text.rich(
                                        overflow: TextOverflow.visible,
                                        textAlign: TextAlign.justify,
                                        TextSpan(children: [
                                          TextSpan(
                                            text: ftTransactionCode,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                          WidgetSpan(
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 3.0,
                                                          bottom: 1.5),
                                                  child: Icon(
                                                    Icons.copy_rounded,
                                                    size: 14,
                                                    color: appPrimeColor,
                                                  ))),
                                        ]))),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          endIndent: 5,
                          color: inactiveColor,
                          height: 1,
                          thickness: 1,
                          indent: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "BSE Order Id",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Flexible(
                                child: InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: bscOrderNo));
                                      appExit(context, 'Text copied');
                                    },
                                    child: Text.rich(
                                        overflow: TextOverflow.visible,
                                        textAlign: TextAlign.justify,
                                        TextSpan(children: [
                                          TextSpan(
                                            text: bscOrderNo,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                          WidgetSpan(
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 3.0,
                                                          bottom: 1.5),
                                                  child: Icon(
                                                    Icons.copy_rounded,
                                                    size: 14,
                                                    color: appPrimeColor,
                                                  ))),
                                        ]))),
                              ),
                              // Flexible(
                              //   child: Padding(
                              //     padding: const EdgeInsets.only(left: 5.0),
                              //     child: Text(
                              //       bscOrderNo,
                              //       overflow: TextOverflow.visible,
                              //       textAlign: TextAlign.justify,
                              //       style:
                              //           Theme.of(context).textTheme.bodyLarge,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        Divider(
                          endIndent: 5,
                          color: inactiveColor,
                          height: 1,
                          thickness: 1,
                          indent: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Order Date",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                orderPlacedResp['orderDate'] ?? '',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          endIndent: 5,
                          color: inactiveColor,
                          height: 1,
                          thickness: 1,
                          indent: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Amount",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: Text(
                                    formatNumber(
                                        orderPlacedResp['orderValue'] ?? 0),
                                    overflow: TextOverflow.visible,
                                    textAlign: TextAlign.justify,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          endIndent: 5,
                          color: inactiveColor,
                          height: 1,
                          thickness: 1,
                          indent: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Status",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text.rich(TextSpan(children: [
                                WidgetSpan(
                                    child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 3.0, bottom: 1.5),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 14,
                                    color: primaryGreenColor,
                                  ),
                                )),
                                TextSpan(
                                  text: orderPlacedResp['cardStatus'] ?? '',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                )
                              ]))
                              // Text(
                              //   orderPlacedResp['cardStatus'],
                              //   style: Theme.of(context).textTheme.bodySmall,
                              // ),
                            ],
                          ),
                        ),
                        Divider(
                          endIndent: 5,
                          color: inactiveColor,
                          height: 1,
                          thickness: 1,
                          indent: 5,
                        ),
                        if (furtherSteps.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Next Step',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                                SizedBox(
                                  height: 10,
                                ),
                                HtmlWidget(furtherSteps,
                                    // onTapUrl: (url) => launchUrl(url),

                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          overflow: TextOverflow.visible,
                                        )),
                              ],
                            ),
                          ),
                        // Text(
                        //   transactionMsg,
                        //   style: Theme.of(context).textTheme.bodySmall,
                        // ),
                        // const SizedBox(
                        //   height: 2,
                        // ),
                        // InkWell(
                        //   onTap: () {
                        //     Clipboard.setData(
                        //         ClipboardData(text: ftTransactionCode));
                        //     appExit(context, 'Text copied');
                        //   },
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     children: [
                        //       Text(
                        //         ftTransactionCode,
                        //         style: Theme.of(context).textTheme.titleSmall,
                        //       ),
                        //       const SizedBox(
                        //         width: 2,
                        //       ),
                        //       const Icon(
                        //         Icons.copy_rounded,
                        //         size: 13,
                        //       )
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                Visibility(
                  visible: status != 'S' ||
                      purchaseType == 'redeem' ||
                      (status == 'S' && orderPlacedResp == null),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 5, left: 10, right: 25.0, bottom: 5),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: status == 'S'
                              ? primaryGreenColor
                              : primaryRedColor),
                    ),
                  ),
                ),
                Visibility(
                  visible: (status != 'E' ||
                          purchaseType == 'redeem' ||
                          (status == 'S' && orderPlacedResp == null)) &&
                      ftTransactionCode.isNotEmpty,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        transactionMsg,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: ftTransactionCode));
                          appExit(context, 'Text copied');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              ftTransactionCode,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
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
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                          color: primaryRedColor.withOpacity(0.2),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24))),
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: primaryRedColor,
                          )),
                    ),
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
