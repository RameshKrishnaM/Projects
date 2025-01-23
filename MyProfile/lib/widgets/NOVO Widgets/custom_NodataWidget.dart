import 'package:flutter/material.dart';

Widget noDataFoundWidget(context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          Theme.of(context).brightness == Brightness.dark
              ? 'assets/Error B.png'
              : 'assets/Error W.png',
          height: 100,
          width: 100,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Record Not Found!',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        )
      ],
    ),
  );
}

Widget cartNotFoundWidget(context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          Theme.of(context).brightness == Brightness.dark
              ? 'assets/cartNotfound.png'
              : 'assets/cartNotfound.png',
          height: 170,
          width: 170,
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 10),
        //   child: Text(
        //     'Record Not Found!',
        //     style: Theme.of(context).textTheme.titleMedium,
        //   ),
        // )
      ],
    ),
  );
}
