import 'package:flutter/material.dart';

class AccountType extends StatelessWidget {
  final String txt;
  final String accType;
  const AccountType({
    super.key,
    required this.txt,
    required this.accType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromRGBO(212, 212, 212, 1),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(7.0),
        color: accType == txt ? const Color(0xff0965da) : Colors.transparent,
      ),
      child: Text(
        txt,
        textAlign: TextAlign.center,
        style: TextStyle(
          height: 1,
          color: accType == txt
              ? Colors.white
              : const Color.fromRGBO(102, 98, 98, 1),
        ),
      ),
    );
  }
}
