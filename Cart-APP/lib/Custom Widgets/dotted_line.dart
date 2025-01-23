import 'package:flutter/material.dart';

class DottedLine extends StatelessWidget {
  final bool isSmall;
  final Color? color;
  const DottedLine({super.key, this.isSmall = false, this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          direction: Axis.horizontal,
          children: List.generate(
              ((constraints.constrainWidth()) / (isSmall ? 6 : 12)).floor(),
              (index) => SizedBox(
                    width: isSmall ? 3 : 7,
                    height: 2,
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: color ?? Color.fromRGBO(0, 0, 0, 1))),
                  )),
        );
      },
    );
  }
}
