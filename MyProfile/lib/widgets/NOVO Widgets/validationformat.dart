import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NoSpaceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String trimmedNewValue = newValue.text.trim();
    if (trimmedNewValue.contains(' ')) {
      // If the new value contains a space, don't allow the change
      return oldValue;
    }
    return TextEditingValue(
        text: trimmedNewValue,
        selection: TextSelection.collapsed(offset: trimmedNewValue.length));
  }
}

class NoSpecialCharactersFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove special characters from the new value
    final sanitizedValue = newValue.text.replaceAll(RegExp(r'[^\w\s]'), '');
    return TextEditingValue(
      text: sanitizedValue,
      selection: newValue.selection,
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class RupeesFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      if (!newValue.text.contains("₹")) {
        return TextEditingValue(
          text: "₹${newValue.text}",
          selection: newValue.selection.copyWith(
            baseOffset: newValue.selection.baseOffset + 1,
            extentOffset: newValue.selection.extentOffset + 1,
          ),
        );
      } else if (newValue.text == "₹") {
        return TextEditingValue(
          text: "",
          selection: newValue.selection,
        );
      }
    } else if (newValue.text.contains("₹")) {
      return TextEditingValue(
        text: "₹${newValue.text}",
        selection: newValue.selection,
      );
    }
    return TextEditingValue(
      text: newValue.text,
      selection: newValue.selection,
    );
  }
}

extension StringExtension on String {
  bool panValidation() {
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(this);
  }
}

upiValidation(value) {
  final RegExp upiIdPattern = RegExp(r'^[a-zA-Z0-9_-]+@[\w]+[a-zA-Z_-]');
  if (value!.isEmpty) {
    return "";
  } else if (!upiIdPattern.hasMatch(value)) {
    return 'Invalid UPI ID';
  }
  return null;
}

validator(value) {
  {
    if (value!.isEmpty) {
      return "";
    }
    return null;
  }
}

var indRupeesFormat = NumberFormat.currency(
  // name: "",
  locale: 'en_IN',
  decimalDigits: 0,
  // change it to get decimal places
  symbol: '₹ ',
);
String doubleformatAmount(num amount) {
  NumberFormat formatter = NumberFormat("#,##,##,##0.00", "en_IN");
  return formatter.format(amount);
}
