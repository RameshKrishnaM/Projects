import 'package:flutter/services.dart';

String? validateNotNull(String? value, String validateContent) {
  if (value == null || value.trim().isEmpty) {
    return '$validateContent is required';
  }
  return null; // Return null if the input is valid
}

String? validateName(String? value, String label, int length) {
  if (value == null || value.trim().isEmpty) {
    return '$label is required';
  }

  if (value.trim().length < length) {
    return 'Please enter valid $label';
  }
  return null;
}

String? validateAddresss(
    String? value, String label, int length, int maxLength) {
  if (value == null || value.trim().isEmpty) {
    return '$label is required';
  }

  if (value.trim().length < length) {
    return 'Please enter valid $label';
  }
  if (value.length > maxLength) {
    return 'upto $maxLength characters';
  }

  return null;
}

String? validateAddress(String? value) {
  if (value == null || value.isEmpty) {
    return 'Address is required';
  }

  if (value.trim().length < 10) {
    return 'Please enter valid address';
  }
  return null;
}

String? validatePlace(String? value) {
  if (value == null || value.isEmpty) {
    return 'place is required';
  }

  if (value.trim().length < 4) {
    return 'Please enter valid place';
  }
  return null;
}

String? validateProofNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Proof No is required';
  }

  if (value.trim().length < 4) {
    return 'Please enter valid Proof No';
  }
  return null;
}

String? validatePrcentage(String? value) {
  if (value == null || value.isEmpty) {
    return 'Percentage is required';
  }

  if (value.trim().length < 4) {
    return 'Please enter valid Percentage';
  }
  return null;
}

String? mobileNumberValidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'Mobile Number is required';
  }
  if (value.trim().length != 10) {
    return 'Please enter valid Mobile Number';
  } else if (int.parse(value.substring(0, 1)) <= 5) {
    return 'Please enter valid Mobile Number';
  }
  return null;
}

String? nullValidation(String? value) {
  return null;
}

String? nullValidationWithMaxLength(String? value, int maxLength) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length > maxLength) {
    return 'upto $maxLength characters';
  }
  return null;
}

String? emailValidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email Id is required';
  }
  if (!RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{1,4}$',
    caseSensitive: false,
    multiLine: false,
  ).hasMatch(value)) {
    return 'Please enter valid Email Id';
  }
  return null;
}

String? validatePinCode(String? value) {
  if (value == null || value.isEmpty) {
    return "pinCode is required";
  }
  if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
    return 'Please enter a valid pinCode';
  }
  return null;
}

String? validateEmail(String value) {
  if (value.isEmpty) {
    return 'Email ID is required';
  } else if (!RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{1,4}$')
      .hasMatch(value)) {
    return 'Please enter a valid email address.';
  }
  return null;
}

String? validatePercentage(value) {
  try {
    int percentage = int.parse(value);
    if (percentage < 1 || percentage > 100) {
      return 'Enter a percentage between 1 to 100';
    }
  } catch (e) {
    return 'Enter a valid percentage';
  }
  return null;
}

String? validatePanCard(String? value) {
  if (value == null || value.isEmpty) {
    return 'PAN Number is required';
  }
  final RegExp panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
  if (!panRegex.hasMatch(value.toUpperCase())) {
    return 'Invalid PAN Number';
  }
  return null;
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.toUpperCase() == newValue.text) {
      return newValue;
    } else {
      return TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
      );
    }
  }
}
