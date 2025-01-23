// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final dynamic onChangeFunc;
  final double min;
  final double max;
  const CustomSlider(
      {super.key,
      required this.value,
      required this.onChangeFunc,
      required this.min,
      required this.max});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
      ),
      child: Slider(
        activeColor: appPrimeColor,
        thumbColor: appPrimeColor,
        inactiveColor: modifyButtonColor,
        min: min,
        max: max,
        value: value,
        onChanged: onChangeFunc,
      ),
    );
  }
}
