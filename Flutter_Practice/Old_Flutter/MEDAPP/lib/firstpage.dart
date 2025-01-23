import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:medapp/customwidget.dart';
import 'package:medapp/loginpage.dart';
import 'package:medapp/widgets/adduser.dart';
import 'package:medapp/widgets/billentry.dart';
import 'package:medapp/widgets/dashboardWidget.dart';
import 'package:medapp/widgets/loginhistory.dart';
import 'package:medapp/widgets/salesreport.dart';
import 'package:medapp/widgets/snackBar.dart';
import 'package:medapp/widgets/stockentry.dart';
import 'package:medapp/widgets/stockview.dart';

import 'package:shared_preferences/shared_preferences.dart';

class FirstPage extends StatefulWidget {
  final String username;
  final String role;
  const FirstPage({super.key, required this.username, required this.role});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  var method;
  List? loginhistory;
  SharedPreferences? sref;
  String? appBarName;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showsnackbar();
    });

    appBarName = 'Dashboard';
    method = Dashboard(role: widget.role, username: widget.username);
    fetchData();
  }

  fetchData() async {
    sref = await SharedPreferences.getInstance();
    String data = sref!.getString('login History') ?? '[]';
    loginhistory = jsonDecode(data);
    setState(() {});
  }

  changeAppBarName(String name) {
    setState(() {
      appBarName = name;
    });
  }

  showsnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const MySnackBar(message: 'Login Sucessfully...!!!', color: Colors.green)
          .openSnackBar(),
    );
  }

  changebody(bodymethod) {
    setState(() {
      method = bodymethod;
    });
  }

  Brightness currentBrightness = Brightness.light;

  void toggleTheme() {
    setState(() {
      currentBrightness = currentBrightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark;
    });
  }

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(
          Icons.wb_sunny,
          color: Colors.amber,
        );
      }
      return const Icon(
        Icons.nightlight_round,
        color: Colors.white,
      );
    },
  );
  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, dynamic>> dashboardMap = {
      'Biller': {
        'Dashboard': Dashboard(role: widget.role, username: widget.username),
        'Stock View': const StockView(),
        'Bill Entry': BillEntry(userId: widget.username),
      },
      'Manager': {
        'Dashboard': Dashboard(role: widget.role, username: widget.username),
        'Stock View': const StockView(),
        'Stock Entry': const StockEntry(),
        'Sales Report': const SalesReport(),
      },
      'Inventory': {
        'Dashboard': Dashboard(role: widget.role, username: widget.username),
        'Stock View': const StockView(),
        'Stock Entry': const StockEntry(),
      },
      'System Admin': {
        'Dashboard': Dashboard(role: widget.role, username: widget.username),
        'Login History': const LoginHistory(),
        'Add Users': const AddUser(),
      },
    };

    List tileText = dashboardMap[widget.role]!.keys.toList();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: currentBrightness,
      ),
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(
                    Icons.account_circle_rounded,
                    size: 45.0,
                  ),
                );
              },
            ),
            title: Text(appBarName!),
            centerTitle: true,
          ),
          drawer: Drawer(
            width: MediaQuery.of(context).size.width * 0.65,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  color: currentBrightness == Brightness.light
                      ? Colors.blueAccent
                      : const Color(0xFF424242),
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username[0].toUpperCase() +
                            widget.username.substring(1),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.role),
                          Switch(
                            activeTrackColor: Colors.white,
                            thumbIcon: thumbIcon,
                            value: currentBrightness == Brightness.light,
                            onChanged: (value) {
                              toggleTheme();
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: dashboardMap[widget.role]!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(
                            () {
                              changebody(
                                dashboardMap[widget.role]![tileText[index]],
                              );
                              changeAppBarName(tileText[index]);
                            },
                          );
                          Navigator.pop(context);
                        },
                        child: ListTile(
                          title: Text(
                            tileText[index],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 1.0,
                      );
                    },
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: const Text('Do you want to log out'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ));
                                loginhistory!.add({
                                  'User Id ': widget.username,
                                  'Type': 'Logout',
                                  'Date': dateTime(),
                                });
                                sref!.setString(
                                    'login History', jsonEncode(loginhistory));
                              },
                              child: const Text('Ok'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const ListTile(
                    selected: true,
                    selectedTileColor: Colors.red,
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    trailing: Icon(
                      Icons.logout,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
          body: SizedBox(
            height: double.infinity,
            child: ListView(
              children: [
                method,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
