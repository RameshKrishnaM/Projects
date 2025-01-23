import 'package:flutter/material.dart';

class Drawer1 extends StatefulWidget {
  const Drawer1({super.key});

  @override
  State<Drawer1> createState() => _Drawer1State();
}

class _Drawer1State extends State<Drawer1> {
  final TextEditingController name = TextEditingController();
  final n = GlobalKey<FormState>();
  String a = 'submit';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text('Drawer Task'),
        ),
        drawer: Drawer(
          width: 250.0,
          child: Column(
            children: [
              Container(
                color: Colors.teal,
                height: 200.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 15.0,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 50.0),
                          height: 80.0,
                          width: 80.0,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                                image: NetworkImage(
                                    'https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D&w=1000&q=80'),
                                fit: BoxFit.cover),
                            border: Border.all(width: 1.0),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
                        const SizedBox(
                          width: 50.0,
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 60.0),
                          height: 35.0,
                          width: 35.0,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQEbaur4lJpEYfDzJDKiV8F2UfX80l39nm_qMXnf5BxyuDqVpu2ttgkPLc_CwZBICB03Hc&usqp=CAU'),
                            ),
                            border: Border.all(width: 1.0),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 60.0),
                          height: 35.0,
                          width: 35.0,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfXpi1Nrns6Lg_qmU2V4jJ4kexQbqsgKyCxg&usqp=CAU'),
                            ),
                            border: Border.all(width: 1.0),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ramesh Krishna M'),
                          Text(
                            'krish852000@gmail.com',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      selectedColor: Colors.amber,
                      selected: true,
                      leading: Icon(Icons.mail),
                      title: Text('All inbox'),
                    ),
                    Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: Icon(Icons.inbox),
                      title: Text('Primary'),
                    ),
                    Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: Icon(Icons.people),
                      title: Text('Social'),
                    ),
                    Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: Icon(Icons.local_offer),
                      title: Text('Promotion'),
                    ),
                    Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: Icon(Icons.label_important),
                      title: Text('important'),
                    ),
                    Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: Icon(Icons.send),
                      title: Text('send'),
                    ),
                    Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: Icon(Icons.report_gmailerrorred_sharp),
                      title: Text('spam'),
                    ),
                    Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: Icon(Icons.insert_drive_file_outlined),
                      title: Text('Draft'),
                    ),
                    Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: Icon(Icons.delete_forever),
                      title: Text('Trash'),
                    ),
                    Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                    ),
                    Divider(
                      height: 1,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        body: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  // Image(image: AssetImage('assets/images/72695.png')),
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Card(
                      child: Column(
                        children: [
                          TextField(
                            controller: name,
                          ),
                          TextButton(
                              onLongPress: () {
                                setState(() {
                                  name.text = '6382480112';
                                });
                              },
                              onPressed: () {
                                setState(() {
                                  name.text = 'Ramesh Krishna M';
                                });
                              },
                              child: const Text('Submit')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    height: 250,
                    width: 250,
                    child: ListView(
                      children: [
                        Card(
                          child: Column(
                            children: [
                              Form(
                                key: n,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      decoration: InputDecoration(
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.account_circle),
                                        prefixIconColor: Colors.blue.shade300,
                                        hintText: 'Enter User Name',
                                        labelText: 'Enter User Name',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Container is Empty';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.phone_android),
                                        prefixIconColor: Colors.blue.shade300,
                                        hintText: 'Enter Phone Number',
                                        labelText: 'Enter Phone Number',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      validator: (value) {
                                        try {
                                          int.parse(value!);
                                          if (value.length != 10) {
                                            return "Please Enter a Valid 10-digit Mobile No";
                                          }
                                        } catch (e) {
                                          return 'Enter valid Number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        prefixIcon: const Icon(Icons.lock),
                                        prefixIconColor: Colors.blue.shade300,
                                        suffixIcon:
                                            const Icon(Icons.visibility),
                                        hintText: 'Enter Password',
                                        labelText: 'Enter Password',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (!RegExp(
                                                r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[.!@#\$&*~]).{8,}$')
                                            .hasMatch(value!)) {
                                          return 'Enter a valid password!';
                                        }
                                        return null;
                                      },
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (n.currentState!.validate()) {}
                                      },
                                      child: Text(a),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
