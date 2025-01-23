import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projectbottomsheet/fileclass.dart';

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  bool isLoading = true;
  Welcome? welcome;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    try {
      var response = await http.get(Uri.parse('https://dummyjson.com/users'));
      if (response.statusCode == 200) {
        //
        welcome = welcomeFromJson(response.body);
        if (kDebugMode) {
          print(welcome!.users[1].firstName);
        }

        // details = jsonDecode(response.body);
        isLoading = false;
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(fontSize: 14.0, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          elevation: 20,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: Scaffold());
  }
}
