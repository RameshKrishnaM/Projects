import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final T value;
  final ValueChanged<T?> onChanged;
  final String hint;

  CustomDropdown({
    required this.items,
    required this.value,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      items: items,
      value: value,
      onChanged: onChanged,
      hint: Text(hint),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _selectedValue;
  final List<DropdownMenuItem<String>> _dropdownItems = [
    DropdownMenuItem(value: 'One', child: Text('One')),
    DropdownMenuItem(value: 'Two', child: Text('Two')),
    DropdownMenuItem(value: 'Three', child: Text('Three')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Dropdown Example'),
      ),
      body: Center(
        child: CustomDropdown<String>(
          items: _dropdownItems,
          value: _selectedValue!,
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
          },
          hint: 'Select an item',
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}
