import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/providerclass.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor:
              value.isDarkMode ? Colors.black : Colors.grey.shade400,
          appBar: AppBar(
            backgroundColor:
                value.isDarkMode ? const Color(0xFF424242) : Colors.blueAccent,
            title: const Text('Name Bar'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                'Ramesh Krishna M',
                style: TextStyle(
                  color: value.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
