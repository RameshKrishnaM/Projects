import 'package:flutter/material.dart';

import '../Nodifier/nodifierCLass.dart';

class CustomButton extends StatelessWidget {
  final String? buttonText;
  final buttonFunc;
  final FormValidateNodifier? valueListenable;
  final bool isSmall;
  final Color? color;
  final bool isBackgroundTrans;
  final Widget? child;
  final bool backgroundWithOpacity;
  const CustomButton(
      {super.key,
      this.valueListenable,
      required this.buttonFunc,
      this.buttonText,
      this.isSmall = false,
      this.isBackgroundTrans = false,
      this.color,
      this.child,
      this.backgroundWithOpacity = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        style: ButtonStyle(
            elevation: const MaterialStatePropertyAll(0),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                side: isBackgroundTrans || backgroundWithOpacity
                    ? BorderSide(
                        width: 1.3,
                        color: Theme.of(context).colorScheme.primary)
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(6))),
            backgroundColor: MaterialStatePropertyAll(color ??
                (isBackgroundTrans
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.primary.withOpacity(
                        buttonFunc == null || backgroundWithOpacity
                            ? 0.3
                            : 1))),
            fixedSize: const MaterialStatePropertyAll(Size(240, 50))),
        onPressed: buttonFunc,
        child: child ??
            Text(
              buttonText ?? "Continue",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: isBackgroundTrans
                      ? Color.fromRGBO(58, 57, 57, 1)
                      : Color.fromRGBO(255, 255, 255, 1)),
            ),
      ),
    );
  }
}
