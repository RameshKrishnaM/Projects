import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class PincodeDetails extends StatefulWidget {
  @override
  _PincodeDetailsState createState() => _PincodeDetailsState();
}

class _PincodeDetailsState extends State<PincodeDetails> {
  final TextEditingController _pincodeController = TextEditingController();
  String _city = '';
  String _state = '';
  String _country = '';

  Future<void> _getPincodeDetails(String pincode) async {
    final String apiUrl = 'https://api.postalpincode.in/pincode/$pincode';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final postOfficeData = data[0]['PostOffice'][0];
          setState(() {
            _city = postOfficeData['District'];
            _state = postOfficeData['State'];
            _country = postOfficeData['Country'];
          });
        } else {
          // Handle empty response
          print('Empty response');
        }
      } else {
        // Handle errors
        print(
            'Error fetching pincode details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Pincode Details')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Enter Pincode'),
                onChanged: (value) {
                  if (value.length == 6) {
                    _getPincodeDetails(value);
                  }
                },
              ),
              SizedBox(height: 20),
              Text('City: $_city'),
              Text('State: $_state'),
              Text('Country: $_country'),
            ],
          ),
        ),
      ),
    );
  }
}
