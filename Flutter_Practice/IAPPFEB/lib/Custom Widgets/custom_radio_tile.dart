import 'package:flutter/material.dart';

import 'custom_radio_button.dart';

/*
class CustomRadioTile extends StatefulWidget {
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
  State<CustomRadioTile> createState() => _CustomRadioTileState();
}

class _CustomRadioTileState extends State<CustomRadioTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        children: [
          Transform.scale(
            scale: 0.9,
            child: Radio(
              value: widget.value,
              groupValue: widget.groupValue,
              onChanged: (value) {
                widget.onChanged(value);
                setState(() {});
              },
            ),
          ),
          Text(
            widget.label,
            style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
                color: Colors.black),
          ),
        ],
      ),
      onTap: () {
        widget.onChanged(widget.value);
        setState(() {});
      },
    );
  }
}
*/

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
          // Container(
          //   width: 16.0,
          //   height: 16.0,
          //   decoration: BoxDecoration(
          //       border: Border.all(
          //           width: 1.8, color: const Color.fromRGBO(0, 0, 0, 1)),
          // color: groupValue == value
          //     ? Theme.of(context).colorScheme.primary
          //     : Colors.transparent,
          //       borderRadius: BorderRadius.circular(16.0)),
          // ),
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

// Container(
//             height: 18,
//             width: 18,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(width: 2.0),
//               color: color,
//             ),
//           ),