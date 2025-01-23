import 'package:apitask/customwidgets.dart';
import 'package:flutter/material.dart';

class SecondApiPage extends StatefulWidget {
  final Map user;
  SecondApiPage({required this.user});
  @override
  State<SecondApiPage> createState() => _SecondApiPageState();
}

class _SecondApiPageState extends State<SecondApiPage> {
  List nameList = [
    'Personal Details',
    'Website Details',
    'Bank Details',
    'Company Details'
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  height: MediaQuery.of(context).size.height * 0.4,
                  color: Colors.green.shade50,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: const CircleBorder(),
                                    content: Image.network(
                                      widget.user['image'],
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                },
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                widget.user['image'],
                              ),
                              radius: 60.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        '${widget.user['firstName']} ${widget.user['maidenName']} ${widget.user['lastName']}',
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(widget.user['phone']),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(widget.user['email']),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('DOB : ${widget.user['birthDate']}'),
                          Text('Age : ${widget.user['age']}'),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Gender : ${widget.user['gender']}'),
                          Text('Blood Group : ${widget.user['bloodGroup']}'),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 0.94,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                    children: List.generate(
                      nameList.length,
                      (index) {
                        return InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alertbox(context,
                                    boxName: nameList[index],
                                    user: widget.user);
                              },
                            );
                          },
                          child: Card(
                            color: Colors.orangeAccent.shade100,
                            child: Center(
                              child: Text(
                                nameList[index],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
