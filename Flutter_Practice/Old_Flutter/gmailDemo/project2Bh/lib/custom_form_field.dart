import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String labelText;
  final String hintText;
  final validator;
  final onChange;
  final bool readOnly;
  final onTap;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final EdgeInsets? contenModifytPadding;
  const CustomTextFormField(
      {super.key,
      required this.controller,
      required this.labelText,
      required this.hintText,
      this.validator,
      this.keyboardType = TextInputType.text,
      this.inputFormatters,
      this.readOnly = false,
      this.onChange,
      this.onTap,
      this.suffixIcon,
      this.prefixIcon,
      this.contenModifytPadding});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onTap: onTap,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        contentPadding: contenModifytPadding,
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Icon(
                suffixIcon,
              )
            : null,
      ),
      validator: validator ?? (value) => validationNotNull(value, labelText),
      onChanged: onChange,
    );
  }
}

String? validationNotNull(String? value, String validateContent) {
  if (value == null || value.isEmpty) {
    return 'Please enter the $validateContent';
  }
  return null;
}
