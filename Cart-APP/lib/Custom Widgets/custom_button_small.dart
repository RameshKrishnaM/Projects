import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomButtonSmall extends StatelessWidget {
  final String childText;
  final onPressed;
  final ValueListenable? valueListenable;
  final isBackgroundColorNull;
  const CustomButtonSmall(
      {super.key,
      this.valueListenable,
      required this.onPressed,
      this.childText = "Continue",
      this.isBackgroundColorNull = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: valueListenable ?? ButtonEnableNodifier(),
        builder: (context, value, child) {
          return ElevatedButton(
            style: ButtonStyle(
                elevation: const MaterialStatePropertyAll(0),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1.3,
                        color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(6))),
                backgroundColor: MaterialStatePropertyAll(isBackgroundColorNull
                    ? Colors.transparent
                    : Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(onPressed != null && value ? 1 : 0.5)),
                fixedSize: const MaterialStatePropertyAll(Size(240, 50))),
            onPressed: onPressed != null && value ? onPressed : null,
            child: Text(
              childText,
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: isBackgroundColorNull
                      ? Color.fromRGBO(58, 57, 57, 1)
                      : Color.fromRGBO(255, 255, 255, 1)),
            ),
          );
        });
  }
}

class ButtonEnableNodifier extends ValueNotifier<bool> {
  ButtonEnableNodifier() : super(true);
  changeValue(bool newValue) {
    value = newValue;
  }
}
