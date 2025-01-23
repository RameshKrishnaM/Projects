// lib/screens/photos_screen.dart

import 'package:album/API/api_call.dart';
import 'package:flutter/material.dart';

class PhotosScreen extends StatelessWidget {
  final int albumId;
  final ApiService apiService;

  PhotosScreen({required this.albumId, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photos'),
      ),
      body: FutureBuilder(
        future: apiService.fetchPhotos(albumId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final photos = snapshot.data as List<dynamic>;
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      Image.network(photos[index]['thumbnailUrl']),
                      Text(photos[index]['title']),
                    ],
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
