import 'package:flutter/material.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        height: 400,
        width: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(480.0)),
          color: Colors.orangeAccent,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 360,
            width: 400,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(480.0)),
              color: Colors.blueGrey,
            ),
            child: Text('sdgsdgsdsdg'),
          ),
        ),
      ),
    ));
  }
}
