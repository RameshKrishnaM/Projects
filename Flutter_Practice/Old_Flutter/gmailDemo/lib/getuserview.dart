import 'package:flutter/material.dart';
import 'getuserlist.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // GetUserList - Model name
  // getuserlistModel - Object name

  late GetUserList getuserlistModel;
  var isLoaded = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    getuserlistModel = (await getUsers())!;
    setState(() {});
  }

  Future<GetUserList?> getUsers() async {

/*
When it is from button click
isLoaded = true;
setState(() {  
});
*/

    try {
      final response = await http.get(
        Uri.parse('https://reqres.in/api/users?page=2'),
      );
      if (response.statusCode == 200) {
        isLoaded = false;
        setState(() {});
        var json = response.body;
        return getUserListFromJson(json);
      }
      else {
      isLoaded = false;
      setState(() {});
      }

    } catch (e) {
      print("Exception" + e.toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Get"),
        ),
        body: !isLoaded
            ? getuserlistModel.data.isNotEmpty ?
            ListView.builder(
                itemCount: getuserlistModel.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Text("ID: ${getuserlistModel.data[index].id}, ");
                },
              ) : const Center(child:Text("No Data Found"))
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
