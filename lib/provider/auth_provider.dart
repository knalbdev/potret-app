import 'package:flutter/foundation.dart';

import '../data/api/api_service.dart';
import '../data/preferences/auth_preferences.dart';
import '../utils/error_parser.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final AuthPreferences _preferences;

  AuthState _state = AuthState.initial;
  String? _token;
  String? _name;
  String? _errorMessage;

  AuthProvider({
    required ApiService apiService,
    required AuthPreferences preferences,
  }) : _apiService = apiService,
       _preferences = preferences;

  AuthState get state => _state;
  String? get token => _token;
  String? get name => _name;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> checkSession() async {
    _state = AuthState.loading;
    notifyListeners();

    final token = await _preferences.getToken();
    if (token != null && token.isNotEmpty) {
      _token = token;
      _name = await _preferences.getName();
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loginResult = await _apiService.login(
        email: email,
        password: password,
      );

      _token = loginResult.token;
      _name = loginResult.name;

      await _preferences.saveSession(
        token: loginResult.token,
        userId: loginResult.userId,
        name: loginResult.name,
      );

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = parseError(e);
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.register(name: name, email: email, password: password);
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = parseError(e);
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _preferences.clearSession();
    _token = null;
    _name = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
