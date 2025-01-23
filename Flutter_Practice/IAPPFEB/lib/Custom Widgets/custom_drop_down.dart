import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../Nodifier/nodifierCLass.dart';

class CustomDropDown extends StatefulWidget {
  final TextEditingController controller;
  final List values;
  final bool isIcon;
  final String? label;
  final bool buttonSizeIsSmall;
  final FormValidateNodifier formValidateNodifier;
  final double menuHeight;
  final onChange;
  final String? hint;
  final bool textSizeSmall;
  final bool? showError;
  const CustomDropDown(
      {super.key,
      required this.controller,
      this.label,
      required this.values,
      this.buttonSizeIsSmall = false,
      this.isIcon = false,
      required this.formValidateNodifier,
      this.onChange,
      this.menuHeight = 150,
      this.hint,
      this.textSizeSmall = false,
      this.showError});

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  String? previousValue;
  onChangeFunc(value) {
    if (widget.formValidateNodifier.getValue["${widget.label}"] == false) {
      widget.formValidateNodifier.changeValue(
          widget.formValidateNodifier.getValue..["${widget.label}"] = true);
    }
    widget.controller.text = value ?? "";

    widget.onChange != null && value != null ? widget.onChange(value) : null;
    if (previousValue != value) {
      setState(() {});
    }
    previousValue = value;
  }

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    widget.controller.text != ""
        ? onChangeFunc(
            widget.controller.text == "" ? null : widget.controller.text)
        : null;
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton2(
          hint: Text(
            widget.hint ?? "",
            // style: TextStyle(
            //     fontSize: 14.0, color: Color.fromRGBO(102, 98, 98, 0.5)),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          alignment: Alignment.centerLeft,
          // style: TextStyle(
          //     fontSize: 17.0,
          //     fontWeight: FontWeight.bold,
          //     color: Color.fromRGBO(0, 0, 0, 1)),
          isExpanded: true,
          underline: const Text(""),
          iconStyleData: IconStyleData(
              icon: const Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 20.0,
                ),
              ),
              iconSize: widget.isIcon ? 30 : 0),
          buttonStyleData: ButtonStyleData(
            height: widget.buttonSizeIsSmall ? 30.0 : 48.0,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  width: 1.3,
                  color: widget.controller.text != ""
                      ? const Color.fromRGBO(9, 101, 218, 1)
                      : widget.showError == true
                          ? Colors.red
                          : const Color.fromRGBO(195, 195, 195, 1)),
              borderRadius: BorderRadius.circular(6.5),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.only(left: 15.0, right: 0),
            height: 35.0,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: widget.menuHeight,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
          // hint: Text(
          //   widget.label ?? "",
          //   textAlign: TextAlign.center,
          //   style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14.0),
          // ),
          items: widget.values.map<DropdownMenuItem<String>>((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Scrollbar(
                  child: Text(
                item,
                style: widget.controller.text == item
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: widget.textSizeSmall ? 12.0 : 15.0)
                    : Theme.of(context).textTheme.bodyMedium!,
              )),
            );
          }).toList(),
          value: widget.controller.text == "" ? null : widget.controller.text,
          onChanged: onChangeFunc,
        ),
        if (widget.showError == true &&
            widget.label != null &&
            widget.label!.isNotEmpty &&
            widget.controller.text.isEmpty) ...[
          const SizedBox(width: 5.0),
          Row(
            children: [
              const SizedBox(width: 10.0),
              Text(
                "Please enter the ${widget.label}",
                style: const TextStyle(
                    color: Color.fromRGBO(176, 0, 32, 1), fontSize: 10.0),
              ),
            ],
          )
        ]
      ],
    );
  }
}
