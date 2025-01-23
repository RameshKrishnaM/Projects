// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novo/utils/colors.dart';

class CustomBuyFormField extends StatelessWidget {
  final TextEditingController contorller;
  final Color borderColor;
  final Color bgColor;
  final bool? readonly;
  final Widget? prefix;
  final Widget? suffix;
  final Color? textColor;
  final double? fontsize;
  final InputBorder? focusBorder;
  final List<TextInputFormatter>? inputFormat;
  final dynamic validator;
  final dynamic onChange;
  final TextAlign? textAlign;
  const CustomBuyFormField(
      {super.key,
      required this.contorller,
      this.prefix,
      this.suffix,
      this.readonly,
      required this.borderColor,
      required this.bgColor,
      this.fontsize,
      this.focusBorder,
      this.textColor,
      this.onChange,
      this.textAlign,
      this.inputFormat,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textAlign: textAlign ?? TextAlign.center,
      style: TextStyle(
          color: textColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? titleTextColorDark
                  : titleTextColorLight),
          fontSize: fontsize ?? 14.0,
          fontWeight: FontWeight.bold),
      controller: contorller,
      readOnly: readonly ?? false,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        // FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
        ...?inputFormat,
      ],
      onChanged: onChange,
      validator: validator ?? (value) => null,
      decoration: InputDecoration(
        prefix: prefix,
        suffix: suffix,
        isDense: true,
        prefixStyle: const TextStyle(fontSize: 15),
        suffixStyle: const TextStyle(fontSize: 15),
        border: InputBorder.none,
        errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryRedColor, width: 1.0)),
        focusedBorder: focusBorder ?? InputBorder.none,
      ),
    );
  }
}
