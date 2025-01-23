// lib/screens/post_details_screen.dart

import 'package:album/API/api_call.dart';
import 'package:flutter/material.dart';

class PostDetailsScreen extends StatelessWidget {
  final int postId;
  final ApiService apiService;

  PostDetailsScreen({required this.postId, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: FutureBuilder(
        future: Future.wait(
            [apiService.fetchPosts(), apiService.fetchComments(postId)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final post =
                snapshot.data![0].firstWhere((post) => post['id'] == postId);
            final comments = snapshot.data![1] as List<dynamic>;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['title'],
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(post['body']),
                  Divider(),
                  Text('Comments',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...comments.map((comment) => ListTile(
                        title: Text(comment['name']),
                        subtitle: Text(comment['body']),
                      )),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
