import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../Nodifier/nodifierCLass.dart';

class CustomCheckBox extends StatelessWidget {
  final Widget child;
  // final CheckBoxValueNodifier checkBoxValueNodifier;
  // final isCenter;
  final bool isCheck;
  final onChange;
  final bool showReq;
  const CustomCheckBox({
    super.key,
    // required this.checkBoxValueNodifier,
    required this.isCheck,
    required this.showReq,
    this.onChange,
    required this.child,
    // this.isCenter = false
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  height: 15.0,
                  width: 15.0,
                  decoration: BoxDecoration(
                      color: isCheck
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                          width: isCheck ? 1 : 1.5,
                          color: !isCheck && showReq
                              ? Colors.red
                              : Theme.of(context).textTheme.bodyLarge!.color!)),
                  child: isCheck
                      ? Icon(Icons.check_sharp,
                          size: 12,
                          color:
                              // MediaQuery.of(context).platformBrightness ==
                              //         Brightness.light
                              //     ?
                              Colors.white
                          // : Color.fromRGBO(0, 0, 0, 1),
                          )
                      : null,
                ),
                // Text(
                //   "*required",
                //   style: TextStyle(
                //       color: showReq ? Colors.red : Colors.transparent),
                // )
              ],
            ),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(child: child)
          ],
        ),
        onTap: () {
          onChange != null ? onChange() : null;
        });
  }
}
