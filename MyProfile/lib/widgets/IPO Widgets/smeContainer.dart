import 'package:flutter/cupertino.dart';
import 'package:novo/utils/colors.dart';

class SmeContainer extends StatelessWidget {
  const SmeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.only(top: 3.0, bottom: 3.0, left: 7.0, right: 7.0),
      decoration: const BoxDecoration(
          color: Color.fromRGBO(227, 242, 253, 1),
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: Center(
          child: Text('SME',
              style: TextStyle(
                  color: appPrimeColor,
                  fontSize: 8.0,
                  fontFamily: 'inter',
                  fontWeight: FontWeight.w600))),
    );
  }
}
