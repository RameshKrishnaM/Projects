import 'package:flutter/material.dart';

import 'custom_radio_button.dart';

class CustomRadioTile extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final Function onChanged;

  const CustomRadioTile({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(
        children: [
          CustomRadioButton(
            color: groupValue == value
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
          SizedBox(width: 8.0),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
      onTap: () {
        onChanged(value);
      },
    );
  }
}
