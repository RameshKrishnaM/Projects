import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../Nodifier/nodifierCLass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomDateFormField extends StatelessWidget {
  final String? label;
  final DateChange date;

  final onChange;
  final FormValidateNodifier formValidateNodifier;
  final bool? borderIsRed;
  final String? errorText;
  CustomDateFormField(
      {super.key,
      required this.date,
      this.onChange,
      required this.formValidateNodifier,
      this.label,
      this.borderIsRed,
      this.errorText});

  @override
  Widget build(BuildContext context) {
    date.value != null
        ? formValidateNodifier.changeValue(
            formValidateNodifier.getValue..[label ?? "Date of Birth"] = true)
        : null;

    // _showDatePicker() async {
    //   DateTime today = DateTime.now();
    //   DateTime? picked = await showDatePicker(
    //       context: context,
    //       initialDate: date.value ?? today,
    //       firstDate: DateTime(1900),
    //       lastDate: today);
    //   if (picked != null && picked != date.value) {
    //     date.onchange(picked);
    //     onChange != null ? onChange(picked) : null;
    //     formValidateNodifier.getValue["Date of Birth"] == false
    //         ? formValidateNodifier.changeValue(
    //             formValidateNodifier.getValue..["Date of Birth"] = true)
    //         : null;
    //   }
    // }

    datePick() {
      DateTime today = DateTime.now();
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: SizedBox(
              height: 300,
              width: 250.0,
              child: SfDateRangePicker(
                // showTodayButton: true,
                showNavigationArrow: true,
                // showActionButtons: true,
                initialDisplayDate: date.value ?? today,
                initialSelectedDate: date.value,
                minDate: DateTime(1900),
                maxDate: today,
                onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
                  Navigator.pop(context);
                  if (dateRangePickerSelectionChangedArgs.value != null &&
                      dateRangePickerSelectionChangedArgs.value != date.value) {
                    date.onchange(dateRangePickerSelectionChangedArgs.value);
                    onChange != null
                        ? onChange(dateRangePickerSelectionChangedArgs.value)
                        : null;
                    formValidateNodifier.getValue["Date of Birth"] == false
                        ? formValidateNodifier.changeValue(
                            formValidateNodifier.getValue
                              ..["Date of Birth"] = true)
                        : null;
                  }
                },
                onSubmit: (pickDate) {
                  Navigator.pop(context);
                  if (pickDate != null && pickDate != date.value) {
                    date.onchange(pickDate as DateTime);
                    onChange != null ? onChange(pickDate) : null;
                    formValidateNodifier.getValue["Date of Birth"] == false
                        ? formValidateNodifier.changeValue(
                            formValidateNodifier.getValue
                              ..["Date of Birth"] = true)
                        : null;
                  }
                },
                onCancel: () {
                  Navigator.pop(context);
                },
                selectionMode: DateRangePickerSelectionMode.single,
              ),
            ),
          );
        },
      );
    }

    return ValueListenableBuilder(
        valueListenable: date,
        builder: (context, value, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: CustomDOBFormField(
                      borderIsRed: borderIsRed == true ||
                          (errorText != null && errorText!.isNotEmpty),
                      controller: TextEditingController(
                          text: value?.toString().substring(8, 10) ?? ""),
                      hint: "DD",
                      onTap: datePick,
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Flexible(
                    child: CustomDOBFormField(
                      borderIsRed: borderIsRed == true ||
                          (errorText != null && errorText!.isNotEmpty),
                      controller: TextEditingController(
                          text: value?.toString().substring(5, 7) ?? ""),
                      hint: "MM",
                      onTap: datePick,
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Flexible(
                    flex: 2,
                    child: CustomDOBFormField(
                      borderIsRed: borderIsRed == true ||
                          (errorText != null && errorText!.isNotEmpty),
                      controller: TextEditingController(
                          text: value?.toString().substring(0, 4) ?? ""),
                      hint: "YYYY",
                      onTap: datePick,
                    ),
                  ),
                ],
              ),
              if (errorText != null && errorText!.isNotEmpty) ...[
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      errorText!,
                      style: TextStyle(
                          color: Color.fromRGBO(176, 0, 32, 1), fontSize: 10.0),
                    ),
                  ],
                )
              ]
            ],
          );
        });
  }
}

class CustomDOBFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final onTap;
  final bool? borderIsRed;
  const CustomDOBFormField(
      {super.key,
      required this.controller,
      required this.hint,
      required this.onTap,
      this.borderIsRed});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      onTap: onTap,
      keyboardType: TextInputType.number,
      inputFormatters: [LengthLimitingTextInputFormatter(hint.length)],
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(0, 0, 0, 1)),
      decoration: InputDecoration(
        enabledBorder: borderIsRed == true
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
                  color: controller.text != ""
                      ? const Color.fromRGBO(9, 101, 218, 1)
                      : const Color.fromRGBO(
                          195, 195, 195, 1), //9, 101, 218, 1, // Border color
                  width: 1.3, // Border width
                ),
              ),
        focusedBorder: borderIsRed == true
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
                  color: const Color.fromRGBO(9, 101, 218, 1),

                  width: 1.3, // Border width
                ),
              ),
        // suffixIcon: hint == "YYYY"
        //     ? IconButton(onPressed: () {}, icon: Icon(Icons.calendar_today))
        //     : null,
        hintStyle: TextStyle(
            color:
                Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.4),
            fontSize: 15.0,
            fontWeight: FontWeight.w600),
        contentPadding: EdgeInsets.zero,
        hintText: hint,
      ),
      validator: (value) => null,
    );
  }
}
