import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FireBStore extends StatefulWidget {
  const FireBStore({super.key});

  @override
  State<FireBStore> createState() => _FireBStoreState();
}

class _FireBStoreState extends State<FireBStore> {
  @override
  void initState() {
    firestore.collection('User Details').snapshots().listen((event) {
      for (var change in event.docChanges) {
        print('Name : ' + change.doc['Name']);
      }
    });
    // TODO: implement initState
    super.initState();
  }

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController adController = TextEditingController();
  TextEditingController phnController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900, 1),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dobController.text) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      dobController.text = formattedDate;
    }
    setState(() {
      // selectedDate = picked;
      // dobController.text =
      //     '${selectedDate.day}-${selectedDate.month}- ${selectedDate.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Insert User Details',
                style: TextStyle(fontSize: 28),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber))),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2)
                ],
                decoration: InputDecoration(
                    labelText: 'age',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber))),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                onTap: () {
                  _selectDate(context);
                },
                controller: dobController,
                decoration: InputDecoration(
                    labelText: 'Date Of Birth',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber))),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: adController,
                decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber))),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: phnController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ],
                decoration: InputDecoration(
                  labelText: 'Mob_No',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirmation"),
                        content: Text(
                            "Are you sure you want to submit these details?"),
                        actions: [
                          TextButton(
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.amber),
                            ),
                            onPressed: () {
                              nameController.clear();
                              ageController.clear();
                              dobController.clear();
                              adController.clear();
                              phnController.clear();
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Submit",
                              style: TextStyle(color: Colors.amber),
                            ),
                            onPressed: () async {
                              firestore.collection("User Details").add({
                                "Name": nameController.text,
                                "Age": ageController.text,
                                "Date Of Birth": dobController.text,
                                "Address.": adController.text,
                                "Phone No.": phnController.text,
                              });
                              Navigator.of(context).pop();
                              nameController.clear();
                              ageController.clear();
                              dobController.clear();
                              adController.clear();
                              phnController.clear();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
