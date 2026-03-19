import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/story.dart';

class ApiService {
  static const String _baseUrl = 'https://story-api.dicoding.dev/v1';

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Story>> getStories({required String token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/stories'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] == true) throw Exception(data['message']);
    final list = data['listStory'] as List<dynamic>;
    return list.map((e) => Story.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Story> getStoryDetail({
    required String token,
    required String id,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/stories/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] == true) throw Exception(data['message']);
    return Story.fromJson(data['story'] as Map<String, dynamic>);
  }

  Future<void> addStory({
    required String token,
    required String description,
    required File photo,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/stories'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['description'] = description;
    request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] == true) throw Exception(data['message']);
  }
}
