import '../Custom%20Widgets/custom_radio_button.dart';
import 'package:flutter/material.dart';

class CustomTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final List selectedTile;
  final onPressed;
  const CustomTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selectedTile,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      margin: const EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: selectedTile.contains(title)
              ? const Color.fromRGBO(9, 101, 218, 1)
              : const Color.fromRGBO(102, 98, 98, 1),
        ),
        borderRadius: BorderRadius.circular(7.0),
        color: selectedTile.contains(title)
            ? const Color(0x190965da)
            : Colors.white,
      ),
      child: ListTile(
          onTap: onPressed,
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing:
              //  CustomRadioButton(
              //   color: selectedTile.contains(title)
              //       ? const Color.fromRGBO(9, 101, 218, 1)
              //       : Colors.transparent,
              // ),
              Checkbox(
            side: BorderSide(color: Colors.grey),
            fillColor: MaterialStatePropertyAll(selectedTile.contains(title)
                ? Color.fromRGBO(9, 101, 218, 1)
                : Colors.grey[200]),
            value: selectedTile.contains(title),
            onChanged: (value) => onPressed(),
          )),
    );
  }
}
