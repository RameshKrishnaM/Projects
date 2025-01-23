// lib/services/api_service.dart

import 'dart:convert';

import 'package:album/offlineHandling/offline.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class ApiService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';
  final DatabaseService _databaseService = DatabaseService();

  Future<List<dynamic>> fetchAlbums() async {
    final db = await _databaseService.database;
    final albums = await db.query('albums');

    if (albums.isNotEmpty) {
      return albums;
    } else {
      final response = await http.get(Uri.parse('$baseUrl/albums?userId=1'));
      final data = jsonDecode(response.body);
      for (var album in data) {
        db.insert('albums', album,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      return data;
    }
  }

  Future<List<dynamic>> fetchPhotos(int albumId) async {
    final db = await _databaseService.database;
    final photos =
        await db.query('photos', where: 'albumId = ?', whereArgs: [albumId]);

    if (photos.isNotEmpty) {
      return photos;
    } else {
      final response =
          await http.get(Uri.parse('$baseUrl/photos?albumId=$albumId'));
      final data = jsonDecode(response.body);
      for (var photo in data) {
        db.insert('photos', photo,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      return data;
    }
  }

  Future<List<dynamic>> fetchPosts() async {
    final db = await _databaseService.database;
    final posts = await db.query('posts');

    if (posts.isNotEmpty) {
      return posts;
    } else {
      final response = await http.get(Uri.parse('$baseUrl/posts?userId=1'));
      final data = jsonDecode(response.body);
      for (var post in data) {
        db.insert('posts', post, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      return data;
    }
  }

  Future<List<dynamic>> fetchComments(int postId) async {
    final db = await _databaseService.database;
    final comments =
        await db.query('comments', where: 'postId = ?', whereArgs: [postId]);

    if (comments.isNotEmpty) {
      return comments;
    } else {
      final response =
          await http.get(Uri.parse('$baseUrl/comments?postId=$postId'));
      final data = jsonDecode(response.body);
      for (var comment in data) {
        db.insert('comments', comment,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      return data;
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final db = await _databaseService.database;
    final profile =
        await db.query('profile', where: 'id = ?', whereArgs: [1], limit: 1);

    if (profile.isNotEmpty) {
      return profile.first;
    } else {
      final response = await http.get(Uri.parse('$baseUrl/users?id=1'));
      final data = jsonDecode(response.body)[0];
      db.insert(
          'profile',
          {
            'id': data['id'],
            'name': data['name'],
            'username': data['username'],
            'email': data['email'],
            'phone': data['phone'],
            'website': data['website']
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
      return data;
    }
  }
}
