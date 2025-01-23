import 'package:flutter/material.dart';

class AgeCalc extends StatefulWidget {
  const AgeCalc({Key? key});

  @override
  State<AgeCalc> createState() => _AgeCalcState();
}

class _AgeCalcState extends State<AgeCalc> {
  String myAge = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Age Calculator"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your age is',
              // style: Theme.of(context).textTheme.displayLarge,
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(myAge),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () => pickDob(context),
              child: const Text('Pick Your Date of Birth'),
            )
          ],
        ),
      ),
    );
  }

  pickDob(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) {
        calculateAge(pickedDate);
      }
    });
  }

  calculateAge(DateTime birth) {
    DateTime now = DateTime.now();
    Duration age = now.difference(birth);
    int years = age.inDays ~/ 365;
    int months = (age.inDays % 365) ~/ 30;
    int days = ((age.inDays % 365) % 30);
    setState(() {
      myAge = '$years years, $months months, and $days days';
    });
  }
}
