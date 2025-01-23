import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: const Color.fromRGBO(255, 0, 0, 1.0),
          title: const Text(
            'MyApp',
            style: TextStyle(color: Colors.black),
          ),
          // leading: Icon(Icons.menu),
          actions: [
            const Icon(
              Icons.search,
              color: Colors.black,
            ),
            // Text('dsvonsd'),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
            )
          ],
          flexibleSpace: const Center(
            child: Icon(
              Icons.camera,
              color: Colors.black,
            ),
          ),
        ),
        drawer: const Drawer(
          elevation: 20.0,
          // backgroundColor: Color.fromRGBO(255, 255 , 255, 1.0),
          shadowColor: Color.fromRGBO(255, 0, 0, 1.0),
          width: 250.0,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                // arrowColor: Colors.amber,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 0, 0, 1.0),
                ),
                accountName: Text('Ramesh Krishna M'),
                accountEmail: Text('krish852000@gmail.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Mangekyou_Sharingan_Sasuke_%28Eternal%29.svg/300px-Mangekyou_Sharingan_Sasuke_%28Eternal%29.svg.png'),
                ),
                otherAccountsPictures: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPfPRsDejhR8Spi-MyGe6SQdCuYslerqd7fQ&usqp=CAU'),
                  ),
                ],
              ),
              ListTile(
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
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          // enableFeedback: true,
          // mouseCursor: SystemMouseCursors.help,
          items: const [
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: 'Search',
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              label: 'More',
              icon: Icon(Icons.more_horiz),
            ),
          ],
        ),
        body: SizedBox(
          height: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                color: Colors.red,
                height: 100.0,
                width: 100.0,
              ),
              Container(
                color: Colors.blueAccent,
                height: 100.0,
                width: 100.0,
              ),
              Container(
                color: Colors.yellow,
                height: 100.0,
                width: 100.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
