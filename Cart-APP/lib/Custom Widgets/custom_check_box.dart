import 'package:flutter/material.dart';

class CustomCheckBox extends StatelessWidget {
  final Widget child;
  final bool isCheck;
  final onChange;
  final bool showReq;
  const CustomCheckBox({
    super.key,
    required this.isCheck,
    required this.showReq,
    this.onChange,
    required this.child,
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
                      ? Icon(Icons.check_sharp, size: 12, color: Colors.white)
                      : null,
                ),
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
