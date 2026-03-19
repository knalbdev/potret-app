import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

import '../data/api/api_service.dart';
import '../data/model/story.dart';
import '../utils/error_parser.dart';

enum StoryState { initial, loading, loaded, error }

class StoryProvider extends ChangeNotifier {
  final ApiService _apiService;

  StoryState _state = StoryState.initial;
  List<Story> _stories = [];
  Story? _selectedStory;
  String? _errorMessage;
  bool _isUploading = false;
  String? _locationAddress;

  int _currentPage = 1;
  static const int _pageSize = 10;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  StoryProvider({required ApiService apiService}) : _apiService = apiService;

  StoryState get state => _state;
  List<Story> get stories => _stories;
  Story? get selectedStory => _selectedStory;
  String? get errorMessage => _errorMessage;
  bool get isUploading => _isUploading;
  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;
  String? get locationAddress => _locationAddress;

  Future<void> fetchStories({required String token}) async {
    _currentPage = 1;
    _hasMore = true;
    _stories = [];
    _state = StoryState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final newStories = await _apiService.getStories(
        token: token,
        page: _currentPage,
        size: _pageSize,
      );
      _stories = newStories;
      _hasMore = newStories.length >= _pageSize;
      _state = StoryState.loaded;
    } catch (e) {
      _errorMessage = parseError(e);
      _state = StoryState.error;
    }
    notifyListeners();
  }

  Future<void> fetchMoreStories({required String token}) async {
    if (_isFetchingMore || !_hasMore || _state == StoryState.loading) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newStories = await _apiService.getStories(
        token: token,
        page: nextPage,
        size: _pageSize,
      );
      _currentPage = nextPage;
      _stories.addAll(newStories);
      _hasMore = newStories.length >= _pageSize;
    } catch (_) {
      // pagination errors fail silently
    }

    _isFetchingMore = false;
    notifyListeners();
  }

  Future<void> fetchStoryDetail({
    required String token,
    required String id,
  }) async {
    _state = StoryState.loading;
    _selectedStory = null;
    _locationAddress = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedStory = await _apiService.getStoryDetail(token: token, id: id);
      _state = StoryState.loaded;
      notifyListeners();
      if (_selectedStory?.lat != null && _selectedStory?.lon != null) {
        await fetchLocationAddress(_selectedStory!.lat!, _selectedStory!.lon!);
      }
    } catch (e) {
      _errorMessage = parseError(e);
      _state = StoryState.error;
      notifyListeners();
    }
  }

  Future<void> fetchLocationAddress(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((s) => s != null && s.isNotEmpty).toList();
        _locationAddress = parts.join(', ');
      }
    } catch (_) {
      _locationAddress = null;
    }
    notifyListeners();
  }

  Future<bool> addStory({
    required String token,
    required String description,
    required File photo,
    double? lat,
    double? lon,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.addStory(
        token: token,
        description: description,
        photo: photo,
        lat: lat,
        lon: lon,
      );
      _isUploading = false;
      notifyListeners();
      await fetchStories(token: token);
      return true;
    } catch (e) {
      _errorMessage = parseError(e);
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }
}
