// lib/screens/posts_screen.dart

import 'package:album/API/api_call.dart';
import 'package:album/Screens/post_details_screen.dart';
import 'package:flutter/material.dart';

class PostsScreen extends StatelessWidget {
  final ApiService apiService;

  PostsScreen({required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: FutureBuilder(
        future: apiService.fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final posts = snapshot.data as List<dynamic>;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(posts[index]['title']),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PostDetailsScreen(
                                postId: posts[index]['id'],
                                apiService: apiService)));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
