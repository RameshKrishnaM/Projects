import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Bsheethead extends StatelessWidget {
  final String name;
  const Bsheethead({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset('assets/images/blackperson.svg'),
        SizedBox(
          width: 5,
        ),
        Text(name, style: Theme.of(context).textTheme.displayMedium)
      ],
    );
  }
}
