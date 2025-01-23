import 'package:flutter/material.dart';

class CustomClickableContainer extends StatelessWidget {
  final String btntTxt;
  final clickFunc;
  final double? btnWidth;
  final double? btnHeight;
  const CustomClickableContainer(
      {required this.btntTxt,
      required this.clickFunc,
      this.btnWidth,
      this.btnHeight,
      super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return InkWell(
      onTap: clickFunc,
      child: Container(
          width: btnWidth ?? screenSize.width,
          height: btnHeight ?? 42.0,
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.0,
                style: BorderStyle.solid),
          ),
          child: Center(
            child: Text(btntTxt,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    fontWeight: FontWeight.w600)),
          )),
    );
  }
}
