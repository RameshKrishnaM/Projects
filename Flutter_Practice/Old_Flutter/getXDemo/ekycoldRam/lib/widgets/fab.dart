import 'package:flutter/material.dart';
import 'package:projectdemo2/widgets/mycolor.dart';
import 'package:projectdemo2/widgets/providerclss.dart';
import 'package:provider/provider.dart';

class MyFAB extends StatefulWidget {
  const MyFAB({super.key});

  @override
  State<MyFAB> createState() => _MyFABState();
}

class _MyFABState extends State<MyFAB> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyProvider>(
      builder: (BuildContext context, value, Widget? child) {
        return FloatingActionButton(
          highlightElevation: 0.0,
          elevation: 0.0,
          backgroundColor: btcolor,
          mini: true,
          onPressed: () {
            value.chngExp();
          },
          child: Icon(
            value.isExpanded
                ? Icons.keyboard_double_arrow_down_sharp
                : Icons.keyboard_double_arrow_up_sharp,
            // color: Colors.black54,
          ),
        );
      },
    );
  }
}
