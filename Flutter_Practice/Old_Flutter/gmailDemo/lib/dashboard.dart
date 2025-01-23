import 'package:flutter/material.dart';

import 'addclient.dart';
import 'companydashboard.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Thandal\n',
                    style: TextStyle(
                        fontFamily: 'Moonkids',
                        fontSize: 25.0,
                        letterSpacing: 2.0,
                        color: Colors.grey[500]),
                  ),
                  TextSpan(
                    text: 'Karuppiah\n',
                    style: TextStyle(
                        fontFamily: 'Moonkids',
                        fontSize: 50.0,
                        letterSpacing: 2.0,
                        color: Color.fromRGBO(9, 101, 218, 1)),
                  ),
                  TextSpan(
                    text: '%',
                    style: TextStyle(
                        fontFamily: 'Moonkids',
                        fontSize: 70.0,
                        fontWeight: FontWeight.bold,
                        //  color: Color.fromRGBO(9, 101, 218, 1)

                        color: Colors.green),
                  ),
                ],
              ),
            )),

            //    Text("Neeeds", style: TextStyle( fontFamily: 'Moonkids', fontSize: 70.0, letterSpacing: 10.0, color: Color.fromRGBO(9, 101, 218, 1)),),

            SizedBox(
              height: 25.0,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 0.0, right: 0.0),
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
                        '  Add User  ',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                            color: Color.fromRGBO(255, 255, 255, 1)),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary:
                            Color.fromRGBO(9, 101, 218, 1), // Background color
                        onPrimary: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                              color: Colors.blue), // Optional border side
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                      ),
                    )),
                SizedBox(
                  height: 25.0,
                ),
                Padding(
                    padding: EdgeInsets.only(left: 0.0, right: 0.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle button press here
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    CompanyDashboard()));
                      },
                      child: Text(
                        'View Users',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                            color: Color.fromRGBO(255, 255, 255, 1)),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary:
                            Color.fromRGBO(9, 101, 218, 1), // Background color
                        onPrimary: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                              color: Colors.blue), // Optional border side
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
