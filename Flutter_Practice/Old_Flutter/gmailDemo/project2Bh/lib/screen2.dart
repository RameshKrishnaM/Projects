import 'package:flutter/material.dart';
import 'package:project2/custom_form_field.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
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
      color: Colors.teal.shade300,
      elevation: 12,
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
          CustomTextFormField(
            controller: controller4,
            labelText: "Dummy4",
            hintText: 'Dummy4',
          ),
          CustomTextFormField(
            controller: controller5,
            labelText: "Dummy5",
            hintText: 'Dummy5',
          ),
          CustomTextFormField(
            controller: controller6,
            labelText: "Dummy6",
            hintText: 'Dummy6',
          ),
          CustomTextFormField(
            controller: controller7,
            labelText: "Dummy7",
            hintText: 'Dummy7',
          ),
          CustomTextFormField(
            controller: controller8,
            labelText: "Dummy8",
            hintText: 'Dummy8',
          ),
        ],
      ),
    );
  }
}
