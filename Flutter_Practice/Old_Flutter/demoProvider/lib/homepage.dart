import 'package:demo_provider/provider_number.dart';
import 'package:demo_provider/secondpage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<Number_Provider>(
        builder: (context, numbervalue, child) => Scaffold(
          appBar: AppBar(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              numbervalue.add();
            },
            child: const Icon(Icons.add),
          ),
          body: Consumer<Number_Provider>(
            builder: (context, numberproviders, child) => Center(
              child: Column(
                children: [
                  Text(
                    numberproviders.numbers.last.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: numberproviders.numbers.length,
                      itemBuilder: (context, index) {
                        return Text(
                          numberproviders.numbers[index].toString(),
                          style: const TextStyle(fontSize: 20),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SecondPage(),
                      ),
                    ),
                    child: const Text('SecondPage'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
