import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../MF Widgets/Mf_Button_Widget.dart';

class CurrentlyUnavailableWidget extends StatelessWidget {
  final dynamic refressFunc;
  const CurrentlyUnavailableWidget({super.key, required this.refressFunc});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.exclamationmark_triangle,
          size: 100,
          color: primaryOrangeColor,
        ),
        Text(
          'Currently Unavailable',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
        ),
        Container(
          height: 30,
          margin: EdgeInsets.only(top: 15),
          child: CustomButton(
              buttonWidget: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Try Again',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: titleTextColorDark),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.rotate_right_outlined,
                    size: 20,
                    color: titleTextColorDark,
                  )
                ],
              ),
              onTapFunc: () async {
                await refressFunc;
              }),
        )
        // IconButton(
        //     iconSize: 30,
        //     splashColor: appPrimeColor,
        //     splashRadius: 20,
        //     onPressed: () async {
        //       await fetchIPODetailsInAPI(context);
        //     },
        //     icon: CustomButton(
        //         buttonWidget: Text('Try Again'),
        //         onTapFunc: onTapFunc))
      ],
    );
  }
}
