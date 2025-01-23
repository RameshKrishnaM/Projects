import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showHistoryBottomSheet(String applicationNo, dynamic masterId, context) {
  // Navigator.pop(context);
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return SizedBox(
        // height: MediaQuery.of(context).size.height * 0.75,
        child: Stack(
          // alignment: Alignment.centerRight,
          children: [
            // SingleChildScrollView(
            //   // mainAxisSize: MainAxisSize.min,
            //   child: ShowHistoryDetail(
            //     appNo: applicationNo,
            //     masterid: masterId,
            //     isHistorypage: false,
            //   ),
            // ),
            Positioned(
                top: 10.0,
                right: 15.0,
                child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(CupertinoIcons.multiply))),
          ],
        ),
      );
    },
  );
}
