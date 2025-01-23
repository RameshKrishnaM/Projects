import 'package:flutter/material.dart';

class MyFAB extends StatefulWidget {
  final IconData icon;
  final bool mini;
  final onPressed;
  final double elevation;
  const MyFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.mini = false,
    this.elevation = 0,
  });

  @override
  State<MyFAB> createState() => _MyFABState();
}

class _MyFABState extends State<MyFAB> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      highlightElevation: 0.0,
      elevation: widget.elevation,
      mini: widget.mini,
      onPressed: widget.onPressed,
      child: Icon(
        widget.icon,
        color: Colors.white,
      ),
    );
  }
}
