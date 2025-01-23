import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FireBStore extends StatefulWidget {
  // final FirebaseFirestore firestore;
  const FireBStore({
    super.key,
    /* required this.firestore */
  });

  @override
  State<FireBStore> createState() => _FireBStoreState();
}

final ref = FirebaseDatabase.instance.ref("Users");

class _FireBStoreState extends State<FireBStore> {
  @override
  void initState() {
    // getData();
    // TODO: implement initState
    super.initState();
  }

  // FirebaseDatabase database = FirebaseDatabase.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController adController = TextEditingController();
  TextEditingController phnController = TextEditingController();

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
                            onPressed: () async {
                              print('Ramesh');
                              // var count = await database.ref('count').get();
                              // print(count);
                              // var a = await widget.firestore
                              //     .collection('new')
                              //     .doc('MyDetails')
                              //     .set({
                              //   'name': nameController.text,
                              //   'age': ageController.text,
                              //   'dob': dobController.text,
                              //   'address': adController.text,
                              //   'phone ': phnController.text,
                              // });
                              // // print(a);
                              // print('success');

                              // nameController.clear();
                              // ageController.clear();
                              // dobController.clear();
                              // adController.clear();
                              // phnController.clear();
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Submit",
                              style: TextStyle(color: Colors.amber),
                            ),
                            onPressed: () {
                              print('Submit');

                              ref.child('Details').set({
                                "name": "Ramesh",
                                "age": 24,
                                "address": {"line1": "TVL View"}
                              });
                              print('Sucess');
                              // var a = await widget.firestore
                              //     .collection('new')
                              //     .doc('MyDetails')
                              //     .set({
                              //   'name': nameController.text,
                              //   'age': ageController.text,
                              //   'dob': dobController.text,
                              //   'address': adController.text,
                              //   'phone ': phnController.text,
                              // });
                              // // print(a);
                              // print('success');

                              // Navigator.of(context).pop();
                              // nameController.clear();
                              // ageController.clear();
                              // dobController.clear();
                              // adController.clear();
                              // phnController.clear();
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

  void getData() async {
    print('GetData');
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    // Path to the data you want to retrieve from the database
    String path = 'count'; // Replace 'users' with your actual database path

    // Using the get method to fetch data
    await reference.child(path).get().then((DataSnapshot snapshot) {
      print('ref');
      if (snapshot.value != null) {
        print('snapShot');
        // Data retrieval successful
        var data = snapshot.value;
        print('Data: $data');
      } else {
        // Data not found or empty
        print('No data found');
      }
    }).catchError((error) {
      // Error occurred during data retrieval
      print('Error: $error');
    });
  }
}
