import 'package:flutter/material.dart';
import 'package:project2/custom_form_field.dart';

class Screen4 extends StatefulWidget {
  const Screen4({super.key});

  @override
  State<Screen4> createState() => _Screen4State();
}

class _Screen4State extends State<Screen4> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();
  TextEditingController controller5 = TextEditingController();
  TextEditingController controller6 = TextEditingController();
  TextEditingController controller7 = TextEditingController();
  TextEditingController controller8 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: Colors.orange.shade300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextFormField(
            controller: controller1,
            labelText: "Dummy1",
            hintText: 'Dummy1',
          ),
          CustomTextFormField(
            controller: controller2,
            labelText: "Dummy2",
            hintText: 'Dummy2',
          ),
          CustomTextFormField(
            controller: controller3,
            labelText: "Dummy3",
            hintText: 'Dummy3',
          ),
        ],
      ),
    );
  }
}
