import 'package:album/API/api_call.dart';
import 'package:album/Screens/album_view.dart';
import 'package:album/Screens/post_screen.dart';
import 'package:album/Screens/profule_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final ApiService apiService = ApiService();

  HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Album App'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Albums'),
              Tab(text: 'Posts'),
              Tab(text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(apiService: apiService)));
              },
            ),
            ListTile(
              title: Text('Albums'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AlbumsScreen(apiService: apiService)));
              },
            ),
            ListTile(
              title: Text('Posts'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PostsScreen(apiService: apiService)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
