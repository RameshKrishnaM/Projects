// lib/screens/profile_screen.dart

import 'package:album/API/api_call.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final ApiService apiService;

  ProfileScreen({required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder(
        future: apiService.fetchProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final profile = snapshot.data as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      child: Image.asset(
                        "assets/images/default_profile.jpg",
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Name: ${profile['name']}'),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Email: ${profile['email']}'),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Phone: ${profile['phone']}'),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
