import 'package:flutter/material.dart';

import 'companydashboard.dart';
import 'dashboard.dart';

class AddClient extends StatefulWidget {
  const AddClient({super.key});

  @override
  State<AddClient> createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  DateTime? startDate;
  DateTime? endDate;
  String? selectedOption;
  String? selectedValue = 'Daily';

  Future<void> _startDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _endDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  void setSelectedOption(String option) {
    setState(() {
      selectedOption = option;
    });
  }

  void _onValueChanged(String? newValue) {
    setState(() {
      selectedValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width - 80;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Container(
          alignment: Alignment.center,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: 'Thandal ',
                  style: TextStyle(
                      fontFamily: 'Moonkids',
                      fontSize: 15.0,
                      height: 0.30,
                      letterSpacing: 1.0,
                      color: Colors.grey[500]),
                ),
                const TextSpan(
                  text: 'Karuppiah ',
                  style: TextStyle(
                      fontFamily: 'Moonkids',
                      fontSize: 25.0,
                      height: 1.5,
                      letterSpacing: 2.0,
                      color: Color.fromRGBO(9, 101, 218, 1)),
                ),
              ],
            ),
          ),
        ),
        /*   actions: [
          IconButton( icon: Icon(Icons.dashboard, color: Colors.blue,), // Icon to display
            onPressed: () {
              // Action to perform when the IconButton is pressed
              Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                Otp()));
            },), IconButton( icon: Icon(Icons.logout, color: Colors.blue,), // Icon to display
            onPressed: () {

                  Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                MobileNumber()));
         
            },),
        ],*/
      ),
      body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                  child: ListView(
                children: [
                  const Text(
                    "Add User",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(108, 114, 127, 1)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10.0),
                      labelText: 'Client Name',
                      labelStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(108, 114, 127, 1)),
                      hintText: 'Enter Client Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.blue, // Border color
                          width: 2, // Border width
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.red, // Border color
                          width: 2, // Border width
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Mobile Number';
                      }
                      return null; // Return null if the input is valid
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(108, 114, 127, 1)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10.0),
                      labelText: 'Phone Number',
                      labelStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(108, 114, 127, 1)),
                      hintText: 'Enter Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.blue, // Border color
                          width: 2, // Border width
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.red, // Border color
                          width: 2, // Border width
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Mobile Number';
                      }
                      return null; // Return null if the input is valid
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(108, 114, 127, 1)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10.0),
                      labelText: 'Loan Amount',
                      labelStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(108, 114, 127, 1)),
                      hintText: 'Enter Loan Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.blue, // Border color
                          width: 2, // Border width
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.red, // Border color
                          width: 2, // Border width
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Mobile Number';
                      }
                      return null; // Return null if the input is valid
                    },
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 2.0,
                          color: const Color.fromRGBO(244, 244, 246, 1),
                        ),
                        borderRadius: BorderRadius.circular(20.0)),
                    child: DropdownButton<String>(
                      underline: Container(),
                      isExpanded: true,
                      elevation: 0,
                      value: selectedValue,
                      onChanged: _onValueChanged,
                      items: <String>['Daily', 'Weekly', 'Monthly']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(108, 114, 127, 1)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10.0),
                      labelText: 'No. of Installment',
                      labelStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(108, 114, 127, 1)),
                      hintText: 'Number of Installment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.blue, // Border color
                          width: 2, // Border width
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.red, // Border color
                          width: 2, // Border width
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Mobile Number';
                      }
                      return null; // Return null if the input is valid
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(108, 114, 127, 1)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10.0),
                      labelText: 'Installment Amount',
                      labelStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(108, 114, 127, 1)),
                      hintText: 'Enter Installment Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.blue, // Border color
                          width: 2, // Border width
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.red, // Border color
                          width: 2, // Border width
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Mobile Number';
                      }
                      return null; // Return null if the input is valid
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(108, 114, 127, 1)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10.0),
                      labelText: 'Paid Amount',
                      labelStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(108, 114, 127, 1)),
                      hintText: 'Enter Paid Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.blue, // Border color
                          width: 2, // Border width
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.red, // Border color
                          width: 2, // Border width
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Mobile Number';
                      }
                      return null; // Return null if the input is valid
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    onTap: () {
                      _startDate(context);
                    },
                    readOnly: true,
                    controller: TextEditingController(
                      text: startDate != null
                          ? "${startDate?.toLocal()}".split(' ')[0]
                          : "",
                    ),
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(108, 114, 127, 1)),
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.calendar_today),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10.0),
                      labelText: 'Start Date',
                      labelStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(108, 114, 127, 1)),
                      hintText: 'Enter Start Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.blue, // Border color
                          width: 2, // Border width
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.red, // Border color
                          width: 2, // Border width
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Mobile Number';
                      }
                      return null; // Return null if the input is valid
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    onTap: () {
                      _endDate(context);
                    },
                    readOnly: true,
                    controller: TextEditingController(
                      text: endDate != null
                          ? "${endDate?.toLocal()}".split(' ')[0]
                          : "",
                    ),
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(108, 114, 127, 1)),
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.calendar_today),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10.0),
                      labelText: 'End Date',
                      labelStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(108, 114, 127, 1)),
                      hintText: 'Enter End Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color:
                              Color.fromRGBO(244, 244, 246, 1), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.blue, // Border color
                          width: 2, // Border width
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.red, // Border color
                          width: 2, // Border width
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Mobile Number';
                      }
                      return null; // Return null if the input is valid
                    },
                  ),
                  const SizedBox(height: 30.0),
                  Padding(
                      padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle button press here

                          // Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (BuildContext context) => Otp()));
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(255, 255, 255, 1)),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 10.0),
                        ),
                      )),
                  const SizedBox(height: 50.0),
                ],
              )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const DashBoard()));
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home,
                          size: 30.0,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          "Home",
                          style: TextStyle(fontSize: 15.0, color: Colors.blue),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 25.0),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const CompanyDashboard()));
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list,
                          size: 30.0,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          "View",
                          style: TextStyle(fontSize: 15.0, color: Colors.blue),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )),

      /*     bottomNavigationBar: 
     BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.currency_rupee_rounded),
              label: 'Lending',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Master',
            ),
          ],
        ),

        */
    );
  }
}
