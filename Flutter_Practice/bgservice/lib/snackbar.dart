import 'package:flutter/material.dart';

dynamic showSnackbar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14.0, color: Colors.white),
        textAlign: TextAlign.left,
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      dismissDirection: DismissDirection.up,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.05,
          left: 10,
          right: 10),
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      // behavior: SnackBarBehavior.fixed,
    ),
  );
}

appExit(context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.up,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.035,
          left: MediaQuery.of(context).size.width * 0.30,
          right: MediaQuery.of(context).size.width * 0.30),
      // dismissDirection: DismissDirection.horizontal,
      // width: 150,
      backgroundColor: const Color.fromRGBO(67, 67, 79, 1),
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      duration: const Duration(seconds: 2),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10.0,
          ),
          Text(
            "Press again to Exit",
            style: TextStyle(fontSize: 14.0, color: Colors.white),
          )
        ],
      )));
}



    // print('%%%%%%%%%%%%%%%%%%%%%%%');
    // channel.stream.listen(
    //   (message) {
    //     // print('*&*************');
    //     // print(message);
    //     var data = jsonDecode(message);
    //     for (var i = 0; i < widget.watchListDatas.marketwatcharr.length; i++) {
    //       for (var j = 0;
    //           j < widget.watchListDatas.marketwatcharr[i].scripsarr.length;
    //           j++) {
    //         if (widget.watchListDatas.marketwatcharr[i].scripsarr[j].exch
    //                     .name ==
    //                 data['e'] &&
    //             widget.watchListDatas.marketwatcharr[i].scripsarr[j].token ==
    //                 data['tk']) {
    //           widget.watchListDatas.marketwatcharr[i].scripsarr[j].lp =
    //               data['lp'] ?? '0.0';
    //         }
    //       }
    //     }
    //   },
    // );