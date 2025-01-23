import 'package:flutter/material.dart';

class Task2 extends StatefulWidget {
  const Task2({super.key});

  @override
  State<Task2> createState() => _Task2State();
}

class _Task2State extends State<Task2> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 200.0,
              width: 200.0,
              child: Card(
                surfaceTintColor: Colors.orange,
              ),
            )
          ],
        ),
      ),
    );
  }
}
