import 'package:flutter/material.dart';

import 'addclient.dart';
import 'dashboard.dart';

class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({super.key});

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
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
              style: TextStyle(
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
                TextSpan(
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
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                  child: ListView(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding: EdgeInsets.all(0),
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle button press here

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        AddClient()));
                          },
                          child: Text(
                            'Add Client',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                                color: Color.fromRGBO(255, 255, 255, 1)),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromRGBO(
                                9, 101, 218, 1), // Background color
                            onPrimary: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                  color: Colors.blue), // Optional border side
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 0.0),
                          ),
                        )),
                  ),
                  SizedBox(height: 10.0),
                  DataTable(
                    columnSpacing: 0,
                    columns: [
                      DataColumn(
                          label: Container(
                              alignment: Alignment.centerLeft,
                              width: deviceWidth / 4,
                              child: Text('Name',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)))),
                      DataColumn(
                          label: Container(
                              alignment: Alignment.center,
                              width: deviceWidth / 4,
                              child: Text('Loan Amount',
                                  softWrap: true,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)))),
                      DataColumn(
                          label: Container(
                              alignment: Alignment.center,
                              width: deviceWidth / 4,
                              child: Text('Paid Amount',
                                  softWrap: true,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)))),
                      DataColumn(
                          label: Container(
                              alignment: Alignment.center,
                              width: deviceWidth / 4,
                              child: Text('Outstanding',
                                  softWrap: true,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)))),
                    ],
                    rows: List.generate(
                      5, // Replace with the number of dynamic rows you need
                      (index) => DataRow(
                        cells: [
                          DataCell(Container(
                              alignment: Alignment.centerLeft,
                              width: deviceWidth / 4,
                              child: Text('Vijay', softWrap: true))),
                          DataCell(Container(
                              alignment: Alignment.centerLeft,
                              width: deviceWidth / 4,
                              child: Text('10000', softWrap: true))),
                          DataCell(Container(
                              alignment: Alignment.centerLeft,
                              width: deviceWidth / 4,
                              child: Text('1000', softWrap: true))),
                          DataCell(Container(
                              alignment: Alignment.centerLeft,
                              width: deviceWidth / 4,
                              child: Text('9000', softWrap: true))),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Divider(
                    color: Colors.black,
                    height: 4.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: deviceWidth / 4,
                        child: Text(
                          "Total",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: deviceWidth / 4,
                        child: Text(
                          "30000",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: deviceWidth / 4,
                        child: Text(
                          "3000",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: deviceWidth / 4,
                        child: Text(
                          "90000",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
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
                              builder: (BuildContext context) => DashBoard()));
                    },
                    child: Column(
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
                ],
              ),
            ],
          )),
    );
  }
}
