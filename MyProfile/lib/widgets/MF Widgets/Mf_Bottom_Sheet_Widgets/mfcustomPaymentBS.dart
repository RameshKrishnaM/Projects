// ignore_for_file: file_names

import 'package:flutter/material.dart';

import 'package:novo/widgets/NOVO%20Widgets/loadingDailogwithCircle.dart';
import 'package:provider/provider.dart';
import '../../../API/MFAPICall.dart';
import '../../../Provider/provider.dart';
import '../../../utils/colors.dart';
import '../../../utils/launchurl.dart';
import 'MfBuyScreen_Widget.dart';

// Widget conditionalMfMainScreen(context) {
//   NavigationProvider navigationProvider =
//       Provider.of<NavigationProvider>(context, listen: false);
//   if ((navigationProvider.mfCheckActive['status'] == 'W' ||
//           navigationProvider.mfCheckActive['status'] == 'R' ||
//           navigationProvider.mfCheckActive['status'] == 'E') &&
//       navigationProvider.mfCheckActive['mfSoftLiveKey'] == 'Y') {
//     // Show MFMainScreen if terms are accepted
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _showRiskDisclosureDialog(context);
//     });
//     return Container(
//       color: Colors.transparent,
//     );
//   }
//   // else if (navigationProvider.mfCheckActive['status'] == 'E') {
//   //   // showSnackbar(context, navigationProvider.mfCheckActive['errMsg'], primaryRedColor);
//   //   return Placeholder();
//   // }
//   else {
//     return MfMainScreen();
//     // Show dialog and return an empty Container until the dialog is handled
//     // Prevent navigation until dialog is handled
//   }
// }
getMfboActivateAPI(context) async {
  // LoadingProgress();
  loadingDailogWithCircle(context);
  NavigationProvider navigationProvider =
      Provider.of<NavigationProvider>(context, listen: false);
  if (navigationProvider.mfCheckActive['status'] == 'R' ||
      navigationProvider.mfCheckActive['status'] == 'W') {
    String data = '';
    if (navigationProvider.mfCheckActive['status'] == 'R') {
      data = 'REGISTERED';
    } else if (navigationProvider.mfCheckActive['status'] == 'W') {
      data = 'NEW';
    }
    var response = await fetchMfBoActivate(context, data);

    if (response != null) {
      Navigator.pop(context);
      if (response['status'] == 'S') {
        if (navigationProvider.mfCheckActive['status'] == 'R') {
          print('show the url launcher');
          print(navigationProvider.mfCheckActive['navigateLink']);
          // launchUrl(navigationProvider.mfCheckActive['navigateLink']);
          launchUrlFunction(navigationProvider.mfCheckActive['navigateLink']);
          // setState(() {
          // changeindex.value = 0;
          // });
          navigationProvider.getMfCheckActivateAPI(context);
          Navigator.pop(context);
        } else if (navigationProvider.mfCheckActive['status'] == 'W') {
          // setState(() {
          // changeindex.value = 0;
          // });
          navigationProvider.getMfCheckActivateAPI(context);
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
      }
    }
  } else {}
}

mfInvestBottomSheet(
    {required BuildContext context,
    required String isin,
    required String type,
    num? amount,
    int? id,
    func}) {
  showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      elevation: 0,
      context: context,
      useSafeArea: true,
      builder: (context) {
        NavigationProvider navigationProvider =
            Provider.of<NavigationProvider>(context, listen: false);
        if ((navigationProvider.mfCheckActive['status'] == 'W' ||
            navigationProvider.mfCheckActive['status'] == 'R' ||
            navigationProvider.mfCheckActive['status'] == 'E')) {
          // Show MFMainScreen if terms are accepted
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   _showRiskDisclosureDialog(context);
          // });
          return Padding(
            padding: const EdgeInsets.only(
              top: 25.0,
              bottom: 0,
              left: 15,
              right: 15,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     InkWell(
                //         onTap: () => Navigator.pop(context),
                //         child: const Icon(
                //           Icons.close,
                //           size: 22,
                //         )),
                //   ],
                // ),
                // SizedBox(
                //   height: 5,
                // ),
                RichText(
                    textAlign: TextAlign.justify, // Apply text alignment here

                    text: TextSpan(
                        // textAlign: TextAlign.justify,

                        children: [
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.blue
                                    : appPrimeColor,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: navigationProvider.mfCheckActive['errMsg'],
                            // textAlign: TextAlign.justify,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ])),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(
                      visible:
                          navigationProvider.mfCheckActive['boActive'] == 'Y',
                      child: TextButton(
                        onPressed: () async {
                          // if (navigationProvider.mfCheckActive['status']=='R') {

                          // } else {
                          await getMfboActivateAPI(
                            context,
                          );
                          // }
                        },
                        child: Text(
                          'Send Request',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: primaryGreenColor),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // changeindex.value = 0;
                        // Close dialog without accepting
                      },
                      child: Text(
                        'Go to Explore',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: appPrimeColor),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
        // else if (navigationProvider.mfCheckActive['status'] == 'E') {
        //   // showSnackbar(context, navigationProvider.mfCheckActive['errMsg'], primaryRedColor);
        //   return Placeholder();
        // }
        else {
          return CustomBuyMF(
            isin: isin,
            type: type,
            amount: amount,
            func: func,
            id: id,
          );
          // Show dialog and return an empty Container until the dialog is handled
          // Prevent navigation until dialog is handled
        }
      }
      // return

      //     CustomBuyMF(
      //   isin: isin,
      //   type: type,
      //   amount: amount,
      //   func: func,
      //   id: id,
      // );
      // },
      );
}
