import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/login_result.dart';
import '../model/story.dart';

class ApiService {
  static const String _baseUrl = 'https://story-api.dicoding.dev/v1';

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] == true) throw Exception(data['message']);
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] == true) throw Exception(data['message']);
    return LoginResult.fromJson(
      data['loginResult'] as Map<String, dynamic>,
    );
  }

  Future<List<Story>> getStories({
    required String token,
    int page = 1,
    int size = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/stories?page=$page&size=$size'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] == true) throw Exception(data['message']);
    final list = data['listStory'] as List<dynamic>;
    return list
        .map((e) => Story.fromJson(e as Map<String, dynamic>))
        .toList();
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
    double? lat,
    double? lon,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/stories'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['description'] = description;
    if (lat != null) request.fields['lat'] = lat.toString();
    if (lon != null) request.fields['lon'] = lon.toString();
    request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] == true) throw Exception(data['message']);
  }
}
