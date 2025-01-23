import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/cupertino.dart';

class SkeletonizerDemoPage extends StatefulWidget {
  const SkeletonizerDemoPage({super.key});

  @override
  State<SkeletonizerDemoPage> createState() => _SkeletonizerDemoPageState();
}

class _SkeletonizerDemoPageState extends State<SkeletonizerDemoPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _enabled = false;
      });
    });
  }

  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Skeletonizer Demo'),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 0, right: 4),
          child: Padding(
            padding: EdgeInsets.only(bottom: 110),
            child: CupertinoButton(
              child: Icon(
                _enabled
                    ? Icons.hourglass_bottom_rounded
                    : Icons.hourglass_disabled_outlined,
              ),
              onPressed: () {
                setState(() {
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('Alert'),
                        content:
                            Text('This is a Cupertino-style alert dialog.'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                });
              },
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Skeletonizer(
          // containersColor: Colors.lightBlue,
          // effect: PulseEffect(
          //   from: Colors.teal,
          //   to: Colors.deepOrange,
          // ),
          effect: ShimmerEffect.raw(
            colors: [
              Colors.teal.shade100,
              Colors.transparent,
            ],
            tileMode: TileMode.mirror,
          ),
          enabled: _enabled,
          child: ListView.builder(
            itemCount: 10,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.list_outlined),
                  title: Text('Item number ${index + 1} as title'),
                  subtitle: const Text('Subtitle here'),
                  trailing: const Icon(
                    Icons.ac_unit,
                    size: 32,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
