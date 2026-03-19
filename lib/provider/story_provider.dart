import 'dart:io';

import 'package:flutter/foundation.dart';

import '../data/api/api_service.dart';
import '../data/model/story.dart';

enum StoryState { initial, loading, loaded, error }

class StoryProvider extends ChangeNotifier {
  final ApiService _apiService;

  StoryState _state = StoryState.initial;
  List<Story> _stories = [];
  Story? _selectedStory;
  String? _errorMessage;
  bool _isUploading = false;

  StoryProvider({required ApiService apiService}) : _apiService = apiService;

  StoryState get state => _state;
  List<Story> get stories => _stories;
  Story? get selectedStory => _selectedStory;
  String? get errorMessage => _errorMessage;
  bool get isUploading => _isUploading;

  Future<void> fetchStories({required String token}) async {
    _state = StoryState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _stories = await _apiService.getStories(token: token);
      _state = StoryState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = StoryState.error;
    }
    notifyListeners();
  }

  Future<void> fetchStoryDetail({
    required String token,
    required String id,
  }) async {
    _state = StoryState.loading;
    _selectedStory = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedStory = await _apiService.getStoryDetail(token: token, id: id);
      _state = StoryState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = StoryState.error;
    }
    notifyListeners();
  }

  Future<bool> addStory({
    required String token,
    required String description,
    required File photo,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.addStory(
        token: token,
        description: description,
        photo: photo,
      );
      _isUploading = false;
      notifyListeners();
      await fetchStories(token: token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }
}
