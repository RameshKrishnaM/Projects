import 'package:flutter/material.dart';
import 'package:transitionui/widget/locations_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: buildAppBar(),
        body: const LocationsWidget(),
        bottomNavigationBar: buildBottomNavigation(),
      );

  buildAppBar() => AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('INTERESTS'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_pin),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.search_outlined),
          onPressed: () {},
        ),
      );

  Widget buildBottomNavigation() => BottomNavigationBar(
        elevation: 0,
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.transparent,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pin_drop_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '',
          ),
        ],
      );
}
