import 'package:flutter/material.dart';

class BusinessPage extends StatelessWidget {
  const BusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: 50,
            ),
            Text('Business Page'),
          ],
        ),
      ),
    );
  }
}
