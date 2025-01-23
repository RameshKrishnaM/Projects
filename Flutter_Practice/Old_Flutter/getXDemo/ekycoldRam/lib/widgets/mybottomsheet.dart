import 'package:flutter/material.dart';
import 'package:projectdemo2/widgets/mycolor.dart';

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
    return AnimatedContainer(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      duration: const Duration(milliseconds: 500),
      height: widget.isExpanded ? 270.0 : 30.0,
      child: BottomAppBar(
        color: bgcolor1,
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
                          color: bottomiconcolor,
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          'Saravanan Selvam',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: textcolor2.withOpacity(0.8),
                          ),
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
                          color: bottomiconcolor,
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          '08/05/2000',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: textcolor2.withOpacity(0.8),
                          ),
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
                          color: bottomiconcolor,
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          'Male',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: textcolor2.withOpacity(0.8),
                          ),
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
                          color: bottomiconcolor,
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          'xxyyzzzz@gmail.com',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: textcolor2.withOpacity(0.8),
                          ),
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
                          color: bottomiconcolor,
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Flexible(
                          child: Text(
                            '59 Vaisiyar Street Tiyagadurugam Kallakurichi Taluk Viluppuram Tamil Nadu 606206 India',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: textcolor2.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(btcolor),
                        ),
                        onPressed: widget.onPressed,
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
