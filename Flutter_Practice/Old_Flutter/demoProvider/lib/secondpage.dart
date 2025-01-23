import 'package:demo_provider/provider_number.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<Number_Provider>(
        builder: (context, numberValue, child) => Scaffold(
          appBar: AppBar(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              numberValue.add();
            },
            child: const Icon(Icons.add),
          ),
          body: Consumer<Number_Provider>(
            builder: (context, numberProvider, child) => Center(
              child: Column(
                children: [
                  Text(
                    numberProvider.numbers.last.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: numberProvider.numbers.length,
                      itemBuilder: (context, index) {
                        return Text(
                          numberProvider.numbers[index].toString(),
                          style: const TextStyle(fontSize: 20),
                        );
                      },
                    ),
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
