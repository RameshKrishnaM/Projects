import 'package:flutter/material.dart';
import 'package:novo/Provider/change_index.dart';
import 'package:novo/screens/NOVOscreens/novoPage.dart';
import 'package:provider/provider.dart';

import '../../../API/MFAPICall.dart';
import '../../../Provider/provider.dart';
import '../../../utils/colors.dart';
import '../../../utils/launchurl.dart';

getMfboActivateAPI(context) async {
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
      if (response['status'] == 'S') {
        if (navigationProvider.mfCheckActive['status'] == 'R') {
          // launchUrl(navigationProvider.mfCheckActive['navigateLink']);
          launchUrlFunction(navigationProvider.mfCheckActive['navigateLink']);
          // setState(() {
          ChangeIndex().value = 0;
          // });
          navigationProvider.getMfCheckActivateAPI(context);
          Navigator.pop(context);
        } else if (navigationProvider.mfCheckActive['status'] == 'W') {
          // setState(() {
          ChangeIndex().value = 0;
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

showRiskDisclosureDialog(context, NavigationProvider navigationProvider) {
  // NavigationProvider navigationProvider =
  //     Provider.of<NavigationProvider>(context, listen: false);
  showDialog(
    barrierColor: Colors.transparent,
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          // title: Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: [
          //     Icon(
          //       Icons.info_outline,
          //       size: 17,
          //       color: Theme.of(context).brightness == Brightness.dark
          //           ? Colors.blue
          //           : appPrimeColor,
          //     ),
          //     SizedBox(
          //       width: 10,
          //     ),
          //     Text(
          //       'Mutual Fund Activation Status',
          //       style: Theme.of(context).textTheme.titleMedium!.copyWith(
          //           color: Theme.of(context).brightness == Brightness.dark
          //               ? Colors.blue
          //               : appPrimeColor),
          //     ),
          //   ],
          // ),
          contentPadding: EdgeInsets.only(
            top: 15,
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 15,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue
                      : appPrimeColor,
                ),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: Text(
                    navigationProvider.mfCheckActive['errMsg'] ??
                        somethingError,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.visible,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.only(right: 15),
          actions: [
            Visibility(
              visible: navigationProvider.mfCheckActive['boActive'] == 'Y',
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
              onPressed: () async {
                // Navigator.of(context).pop();
                // ChangeIndex().value = 0;
                // Navigator.of(context).pop(false);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => NovoPage(
                      showBiometricDailog: false,
                    ),
                  ),
                  (route) => false,
                );
                ChangeIndex().value = 0;
                // Close dialog without accepting
              },
              child: Text(
                'Cancel',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: primaryRedColor),
              ),
            ),
          ],
        ),
      );
    },
  );
}
