// lib/screens/albums_screen.dart

import 'package:album/API/api_call.dart';
import 'package:album/Screens/photos_screen.dart';
import 'package:flutter/material.dart';

class AlbumsScreen extends StatelessWidget {
  final ApiService apiService;

  AlbumsScreen({required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Albums'),
      ),
      body: FutureBuilder(
        future: apiService.fetchAlbums(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final albums = snapshot.data as List<dynamic>;
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: albums.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhotosScreen(
                                albumId: albums[index]['id'],
                                apiService: apiService)));
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Text(albums[index]['title']),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
