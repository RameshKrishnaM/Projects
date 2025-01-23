import 'package:flutter/material.dart';
import 'package:projectbottomsheet/custombottomsheet.dart';

class BottomSheet1 extends StatefulWidget {
  @override
  State<BottomSheet1> createState() => _BottomSheet1State();
}

class _BottomSheet1State extends State<BottomSheet1> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showbottomsheet(context);
    });
  }

  void showbottomsheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // isDismissible: false,
      builder: (BuildContext context) {
        return CustomBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () {},
                child: Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
