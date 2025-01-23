import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Nodifier/nodifierclass.dart';
import '../Service/validate_func.dart';

List<Widget> customFormField(
    {formValidateNodifier,
    required controller,
    keyboardType,
    inputFormatters,
    required String labelText,
    textAlign,
    hintText,
    helperText,
    validator,
    onChange,
    readOnly,
    onTap,
    suffixIcon,
    prefixIcon,
    contenModifytPadding,
    notSuffixIcon,
    textIsGrey,
    obscure,
    focusNode,
    restrictCopyAndPaste,
    noNeedErrorText,
    borderIsRed}) {
  labelText = labelText.contains("@")
      ? labelText.substring(0, labelText.length - 1)
      : "$labelText*";
  return [
    Text(labelText),
    const SizedBox(height: 5.0),
    CustomFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      validator: validator,
      onChange: onChange,
      readOnly: readOnly,
      onTap: onTap,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contenModifytPadding: contenModifytPadding,
      formValidateNodifier: formValidateNodifier,
      textAlign: textAlign,
      textIsGrey: textIsGrey,
      notSuffixIcon: notSuffixIcon,
      obscure: obscure,
      restrictCopyAndPaste: restrictCopyAndPaste,
      noNeedErrorText: noNeedErrorText,
      borderIsRed: borderIsRed,
      focusNode: focusNode,
    )
  ];
}

class CustomFormField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? labelText;
  final String? hintText;
  final validator;
  final onChange;
  final bool? readOnly;
  final bool? textIsGrey;
  final onTap;
  final Widget? prefixIcon;
  final suffixIcon;
  final EdgeInsets? contenModifytPadding;
  final FormValidateNodifier? formValidateNodifier;
  final TextAlign? textAlign;
  final bool? notSuffixIcon;
  final bool filled;
  final bool? obscure;
  final bool? noNeedErrorText;
  final String? helperText;
  final bool? restrictCopyAndPaste;
  final bool? borderIsRed;
  final bool autoFocus;
  final focusNode;
  CustomFormField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChange,
    this.readOnly,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
    this.contenModifytPadding,
    this.formValidateNodifier,
    this.textAlign,
    this.notSuffixIcon,
    this.textIsGrey,
    this.filled = false,
    this.obscure,
    this.helperText,
    this.noNeedErrorText,
    this.restrictCopyAndPaste,
    this.borderIsRed,
    this.autoFocus = false,
    this.focusNode,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  String previousValue = "";

  onChangeFunc(value) {
    bool isValiadte = (null ==
        (widget.validator != null
            ? widget.validator(value)
            : validateNotNull(value, "")));

    widget.onChange != null ? widget.onChange(value) : null;
    if (previousValue.isEmpty != value.toString().isEmpty &&
        previousValue.isNotEmpty != value.toString().isNotEmpty) {
      setState(() {});
    }
    previousValue = value;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.text = widget.controller.text;
      widget.readOnly == true ? null : onChangeFunc(widget.controller.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: widget.focusNode,
      contextMenuBuilder: widget.restrictCopyAndPaste == true
          ? null
          : (context, editableTextState) {
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: editableTextState.contextMenuButtonItems,
              );
            },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofocus: widget.autoFocus,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscure ?? false,
      obscuringCharacter: "*",
      inputFormatters: widget.inputFormatters,
      onTap: widget.onTap,
      readOnly: widget.readOnly ?? false,
      textAlign: widget.textAlign ?? TextAlign.start,
      style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
          color: widget.textIsGrey == true
              ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.4)
              : Theme.of(context).textTheme.bodyLarge!.color),
      decoration: InputDecoration(
        errorStyle:
            widget.noNeedErrorText == true ? TextStyle(height: 0) : null,
        helperText: widget.helperText,
        filled: true,
        fillColor: widget.filled
            ? Color.fromRGBO(248, 247, 247, 1)
            : Color.fromRGBO(255, 255, 255, 1),
        contentPadding: widget.contenModifytPadding ??
            const EdgeInsets.symmetric(horizontal: 10.0),
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon ??
            (widget.notSuffixIcon == true ||
                    widget.controller.text.isEmpty ||
                    widget.readOnly == true
                ? null
                : widget.suffixIcon is IconData
                    ? Icon(
                        widget.suffixIcon,
                      )
                    : IconButton(
                        onPressed: () {
                          widget.controller.clear();
                          onChangeFunc("");
                        },
                        icon: const Icon(
                          Icons.cancel_outlined,
                          size: 17.0,
                          color: Colors.black,
                        ),
                      )),
        border: widget.borderIsRed == true
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.0),
                borderSide: const BorderSide(
                  color: Colors.red, // Border color
                  width: 1.3, // Border width
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.0),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(
                      9, 101, 218, 1), //9, 101, 218, 1 // Border color
                  width: 1.3, // Border width
                ),
              ),
        enabledBorder: widget.borderIsRed == true
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.0),
                borderSide: const BorderSide(
                  color: Colors.red, // Border color
                  width: 1.3, // Border width
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.0),
                borderSide: BorderSide(
                  color: widget.textIsGrey == true ||
                          widget.controller.text.isEmpty
                      ? const Color.fromRGBO(195, 195, 195, 1)
                      : const Color.fromRGBO(
                          9, 101, 218, 1), //9, 101, 218, 1, // Border color
                  width: 1.3, // Border width
                ),
              ),
        focusedBorder: widget.borderIsRed == true
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.0),
                borderSide: const BorderSide(
                  color: Colors.red, // Border color
                  width: 1.3, // Border width
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.0),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(9, 101, 218, 1), // Border color
                  width: 1.3, // Border width
                ),
              ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(
            color: Colors.red, // Border color
            width: 1.3, // Border width
          ),
        ),
      ),
      validator: widget.validator ??
          (value) => validateNotNull(value, widget.labelText ?? ""),
      onChanged: onChangeFunc,
    );
  }
}
