import 'package:appbar/expansiontilewidget.dart';
import 'package:flutter/material.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  int _currentIndex = 0;
  // Color color1 = Colors.deepOrange;
  // Color color2 = Colors.teal;
  List pages = [
    const HomePage(),
    const Screen2(),
    const Screen3(),
    const Screen4(),
    const Screen5(),
  ];

  openbottomsheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.blueGrey,
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              const Text('BottomSheet'),
              OutlinedButton(
                style: ButtonStyle(),
                onPressed: () {
                  // Navigator.pop(context);
                },
                child: Text("close"),
              ),
            ],
          ),
        );
      },
    );
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text("This is a snackbar")),
    // );
    // showDialog(
    //   // barrierColor: Colors.amber,
    //   barrierLabel: 'Barrier Label',
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(title: Text("Alert Dialog"));
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          // drawerEdgeDragWidth: double.infinity,
          // drawerEnableOpenDragGesture: false,
          // appBar: PreferredSize(
          //     preferredSize: Size(0, 56),
          //     child: Container(
          //       color: Colors.deepOrange,
          //       child: Text('AppBar'),
          //     )),
          appBar: AppBar(
            elevation: 0.0,
            scrolledUnderElevation: 10.0,
            leading: Builder(
              builder: (context) {
                return InkWell(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: const Icon(Icons.access_alarm_outlined),
                );
              },
            ),
            title: const Text('AppBar'),
            // toolbarTextStyle: const TextStyle(color: Colors.amber),
            // flexibleSpace: Text(
            //   'Text Widget',
            //   style: TextStyle(fontSize: 100.0),
            // ),

            // toolbarHeight: 100,
            actions: [
              const DrawerButton(),
              InkWell(
                onTap: () {},
                child: const Icon(Icons.add),
              ),
              IconButton(
                isSelected: true,
                selectedIcon: Text('evjasVM'),
                onPressed: () {
                  openbottomsheet(context);
                  // Navigator.pop(context);
                },
                icon: const Icon(Icons.search),
              ),
              const EndDrawerButton(
                style: ButtonStyle(),
              )
            ],
            // bottom: const TabBar(
            //   // isScrollable: true,
            //   tabs: [
            //     Tab(
            //       icon: Icon(Icons.more_horiz),
            //     ),
            //     Text('krishna'),
            //     Icon(Icons.settings),
            //     Tab(
            //       text: "Settings",
            //     )
            //   ],
            // ),
            // bottom: const PreferredSize(
            //     preferredSize: Size(0, 50), child: Text('')),
            // flexibleSpace: Container(
            //   decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //           colors: [Colors.amber, Colors.greenAccent])),
            // ),
          ),
          drawer: Drawer(
            width: MediaQuery.of(context).size.width * 0.6,
            backgroundColor: Colors.blueGrey,
            child: const Column(
              children: [
                UserAccountsDrawerHeader(
                  currentAccountPictureSize: Size.fromRadius(40.0),
                  // currentAccountPicture: Container(
                  //   color: Colors.amber,
                  // ),
                  currentAccountPicture: CircleAvatar(
                    // child: Image.network(
                    //   'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvZ44JBNYm0elDbU51pqkCeOoSaJ6coRKLUFzsAy3YQerw4USWY1UMYDeFh-g-NciW44c&usqp=CAU',
                    //   fit: BoxFit.fill,
                    // ),
                    backgroundImage: NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvZ44JBNYm0elDbU51pqkCeOoSaJ6coRKLUFzsAy3YQerw4USWY1UMYDeFh-g-NciW44c&usqp=CAU',
                    ),
                    child: Text('Ramesh'),
                  ),
                  // ClipRRect(
                  //   borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  //   child: Image.network(
                  //     'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvZ44JBNYm0elDbU51pqkCeOoSaJ6coRKLUFzsAy3YQerw4USWY1UMYDeFh-g-NciW44c&usqp=CAU',
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  accountName: Text('Ramesh'),
                  accountEmail: Text('ramesh@gmail.com'),
                ),
                ListTile(
                  iconColor: Colors.amber,
                  // selected: true,
                  // selectedColor: Colors.amber,
                  leading: Icon(Icons.account_circle),
                  title: Text("Profile"),
                  subtitle: Text('krish'),
                  // isThreeLine: true,
                  trailing: Icon(Icons.more_vert_outlined),
                ),
                ListTile(
                  style: ListTileStyle.drawer,
                  selected: true,
                  selectedColor: Colors.amber,
                  leading: Icon(Icons.account_circle),
                  title: Text("Profileeee"),
                  subtitle: Text('krish'),
                  dense: true,
                  // isThreeLine: true,
                  trailing: Icon(Icons.more_vert_outlined),
                ),
                ListTile(
                  leadingAndTrailingTextStyle: TextStyle(color: Colors.purple),
                  titleTextStyle: TextStyle(color: Colors.deepOrange),
                  style: ListTileStyle.drawer,
                  // selected: true,
                  selectedColor: Colors.amber,
                  leading: Icon(Icons.account_circle),
                  title: Text(
                    "Profile",
                    style: TextStyle(color: Colors.orange),
                  ),
                  subtitle: Text('krish'),
                  selectedTileColor: Colors.teal,
                  // isThreeLine: true,
                  trailing: Icon(Icons.more_vert_outlined),
                ),
                ListTile(
                  tileColor: Colors.amberAccent,
                  style: ListTileStyle.drawer,
                  // selected: true,
                  // selectedColor: Colors.amber,
                  leading: Icon(Icons.account_circle),
                  title: Text("Profile"),
                  subtitle: Text('krish'),
                  // isThreeLine: true,
                  trailing: Icon(Icons.more_vert_outlined),
                ),
              ],
            ),
          ),
          endDrawer: const Drawer(),
          // body: Center(
          //   child: Text('Ramesh'),
          // ),
          body: pages[_currentIndex],

          extendBody: true,
          // body: pages[_currentIndex],
          // body: const TabBarView(
          //   physics: ClampingScrollPhysics(),
          //   children: [
          //     Center(
          //       child: Text('More'),r
          //     ),
          //     Center(
          //       child: Text('krishna'),
          //     ),
          //     Center(
          //       child: Text('Settings'),
          //     ),
          //     Center(
          //       child: Text('textSettings'),
          //     ),
          //   ],
          // ),
          // body: Column(
          //   children: [
          //     Container(
          //       color: Colors.amber,
          //       child: Text('sdvkjbaklc'),
          //     ),
          //   ],
          // ),
          // floatingActionButton: FloatingActionButton(
          //   // shape: StarBorder.polygon(sides: 4),
          //   onPressed: () {},
          //   child: Icon(Icons.add),
          // ),
          // bottomNavigationBar: BottomNavBarCurvedFb1(),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.amber,
            // useLegacyColorScheme: false,
            // showUnselectedLabels: true,
            // selectedIconTheme: IconThemeData(color: Colors.deepPurple),
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.teal,
            // selectedLabelStyle: TextStyle(
            //   color: Colors.deepOrange,
            // ),
            // unselectedLabelStyle: TextStyle(
            //   color: color2,
            // ),
            // type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                // activeIcon: Icon(Icons.favorite),
                icon: Icon(
                  Icons.add,
                  // color: Colors.blue,
                ),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                // backgroundColor: Colors.transparent,
                icon: Icon(
                  Icons.add_a_photo_outlined,
                  // color: Colors.blue,
                ),
                label: 'Add Photo',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  // color: Colors.blue,
                ),
                label: 'Settings',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.workspaces_outlined,
                  // color: Colors.blue,
                ),
                label: 'workspace',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.energy_savings_leaf_rounded,
                  // color: Colors.blue,
                ),
                label: 'leaf',
              ),
            ],
          ),
          // bottomNavigationBar: BottomAppBar(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [DrawerButton(), EndDrawerButton()],
          //   ),
          //   height: 56,
          //   color: Colors.blueAccent,
          // ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedItem;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton(
        menuMaxHeight: 250.0,
        dropdownColor: Colors.teal,
        isExpanded: true,
        iconEnabledColor: Colors.red,
        icon: Icon(Icons.filter_vintage),
        onTap: () {},
        disabledHint: Text('Disable Hint'),
        hint: Text('Hint Text'),
        items: ['1', '2', '3', '4', '5'].map<DropdownMenuItem<String>>((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        value: selectedItem,
        onChanged: (value) {
          setState(() {
            selectedItem = value;
          });
        },
      ),
      // child: DropdownButton(
      //   value: selectedItem,
      //   items: [
      //     DropdownMenuItem(
      //       value: 'ramesh',
      //       child: Text('ramesh'),
      //     ),
      //     DropdownMenuItem(
      //       value: 'krishna',
      //       child: Text('krishna'),
      //     ),
      //     DropdownMenuItem(
      //       value: 'kumar',
      //       child: Text('kumar'),
      //     ),
      //     DropdownMenuItem(
      //       value: 'krish',
      //       child: Text('krish'),
      //     ),
      //   ],
      //   onChanged: (value) {
      //     setState(() {
      //       selectedItem = value!;
      //     });
      //   },
      // ),
    );
  }
}

class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 300,
        width: 300,
        child: Card(
          shadowColor: Colors.amber,
          elevation: 20.0,
          child: Column(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.canPop(context);
                  },
                  child: Text('Demo')),
              // TextField(
              //   // style: TextStyle(),
              //   decoration: InputDecoration(),
              // ),
              TextFormField(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Ramesh ',
                    ),
                    TextSpan(
                      text: 'Krishna ',
                    ),
                    WidgetSpan(
                      child: Icon(
                        Icons.filter_vintage_outlined,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Screen3 extends StatelessWidget {
  const Screen3({super.key});

  @override
  Widget build(BuildContext context) {
    String text =
        'expansion******************************************************************************************************************************';
    String tile1 = 'Ramesh';
    String tile2 = 'Krishna';
    String tile3 = 'Kumar';
    return Center(
      child: ExpansionTileWidget(
        tilePadding: EdgeInsets.zero,
        // controlAffinity: ListTileControlAffinity.leading,
        title: Container(
          // transform: Matrix4.translationValues(48, 0, 0),
          child: Text(text),
        ),

        // collapsedIconColor: Colors.amber,
        // trailing: SizedBox.shrink(),
        // leading: Text(''),
        children: [
          ListTile(
            title: Text(tile1),
          ),
          ListTile(
            title: Text(tile2),
          ),
          ListTile(
            title: Text(tile3),
          ),
        ],
      ),
    );
  }
}

class Screen4 extends StatelessWidget {
  const Screen4({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          height: 100,
          width: 100,
          color: Colors.teal,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepOrange,
                  child: const Text('Ramesh'),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.amber,
                ),
              ),
              // Center(
              //   child: Container(
              //     height: 30,
              //     width: 30,
              //     color: Colors.blueAccent,
              //   ),
              // ),
              // Center(
              //   child: Container(
              //     height: 10,
              //     width: 10,
              //     color: Colors.purple,
              //   ),
              // ),
              // Center(
              //   child: Container(
              //     height: 3,
              //     width: 3,
              //     color: Colors.black,
              //   ),
              // ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.teal,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepOrange,
                  child: const Text('Ramesh'),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.teal,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepOrange,
                  child: const Text('Ramesh'),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.teal,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepOrange,
                  child: const Text('Ramesh'),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.teal,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepOrange,
                  child: const Text('Ramesh'),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.teal,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepOrange,
                  child: const Text('Ramesh'),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.teal,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepOrange,
                  child: const Text('Ramesh'),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.teal,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepOrange,
                  child: const Text('Ramesh'),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.teal,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepOrange,
                  child: const Text('Ramesh'),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.teal,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepOrange,
                  child: const Text('Ramesh'),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.teal,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepOrange,
                  child: const Text('Ramesh'),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.teal,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepOrange,
                  child: const Text('Ramesh'),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Screen5 extends StatelessWidget {
  const Screen5({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      color: Colors.amber,
      child: Center(
        child: Container(
          height: 50,
          width: 50,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}
