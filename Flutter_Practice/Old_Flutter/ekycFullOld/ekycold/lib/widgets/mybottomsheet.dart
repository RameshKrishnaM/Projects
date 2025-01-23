import 'package:ekycold/util/colors.dart';
import 'package:ekycold/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class MyBottomSheet extends StatefulWidget {
  final bool isExpanded;
  final Null Function()? onPressed;
  const MyBottomSheet({
    super.key,
    required this.isExpanded,
    required this.onPressed,
  });

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        CircleBorder(),
      ),
      child: widget.isExpanded
          ? Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
              ),
              child: ListView(
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.account_circle_rounded,
                        color: grey,
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      const Text(
                        'Saravanan Selvam',
                      ),
                      const Expanded(child: Text('')),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.date_range_outlined,
                        color: grey,
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      const Text(
                        '08/05/2000',
                      ),
                      const Expanded(child: Text('')),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: grey,
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      const Text(
                        'Male',
                      ),
                      const Expanded(child: Text('')),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.mail,
                        color: grey,
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      const Text(
                        'xxyyzzzz@gmail.com',
                      ),
                      const Expanded(child: Text('')),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: grey,
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      const Flexible(
                        child: Text(
                          '59 Vaisiyar Street Tiyagadurugam Kallakurichi Taluk Viluppuram Tamil Nadu 606206 India',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  CustomButton(
                    onPressed: widget.onPressed,
                    child: const Text('Next'),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
