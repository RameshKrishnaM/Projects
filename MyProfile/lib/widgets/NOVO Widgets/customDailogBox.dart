import 'package:flutter/material.dart';

import '../../utils/colors.dart';

customeDailogBox(context, onclickFuncHni, onclickFuncInd, String titleText) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        // canPop: forceUpdate == 'N' ? false : true,

        onPopInvoked: (didPop) => false,
        child: AlertDialog(
          // title: const Text('Update Available'),
          content: Text(titleText),
          actions: [
            MaterialButton(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              color: appPrimeColor,
              onPressed: () => onclickFuncInd(context),
              child: const Text(
                "IND",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ),
            MaterialButton(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              color: appPrimeColor,
              onPressed: () => onclickFuncHni(context),
              child: const Text(
                "HNI",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
