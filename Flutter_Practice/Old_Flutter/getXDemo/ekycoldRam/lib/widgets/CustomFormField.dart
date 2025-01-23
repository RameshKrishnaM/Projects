import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projectdemo2/widgets/mycolor.dart';

class CustomTextFormFieldramesh extends StatelessWidget {
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
  const CustomTextFormFieldramesh(
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
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onTap: onTap,
      readOnly: readOnly,
      style: const TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        floatingLabelStyle: TextStyle(color: btcolor),
        prefixIconColor: highlightcolor,
        labelStyle: TextStyle(color: btcolor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: btcolor),
          borderRadius: BorderRadius.circular(25.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: dropdownbordercolor),
          borderRadius: BorderRadius.circular(25.0),
        ),
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator ?? (value) => validateNotNull(value, labelText),
      onChanged: onChange,
    );
  }
}

String? validateNotNull(String? value, String validateContent) {
  if (value == null || value.isEmpty) {
    return 'Please enter the $validateContent';
  }
  return null;
}
