import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final String id;
  final String email;
  final String name;
  final String token;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
    );
  }
}

class AuthService extends ChangeNotifier {
  static const String _baseUrlFromEnv = String.fromEnvironment('API_BASE_URL');
  static const String _authTokenKey = 'auth_token';
  static const String _authUserKey = 'auth_user';

  AuthUser? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  /// Ordem de prioridade:
  /// 1) --dart-define=API_BASE_URL=...
  /// 2) Web/Desktop/iOS -> localhost
  /// 3) Android Emulator -> 10.0.2.2
  String get _baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) {
      return _baseUrlFromEnv;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }

  AuthService() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_authTokenKey);

    if (token == null || token.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = _decodeBody(response);
        final rawUser = data['user'];
        final userMap = rawUser is Map
            ? Map<String, dynamic>.from(rawUser)
            : <String, dynamic>{};

        userMap['token'] = token;

        _currentUser = AuthUser.fromJson(userMap);
        await prefs.setString(_authUserKey, jsonEncode(_currentUser!.toJson()));
      } else {
        await _clearSession();
      }
    } catch (_) {
      await _clearSession();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _errorMessage = null;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = _decodeBody(response);

      if (response.statusCode == 201) {
        final rawUser = data['user'];
        final userMap = rawUser is Map
            ? Map<String, dynamic>.from(rawUser)
            : <String, dynamic>{};

        userMap['token'] = (data['token'] ?? '').toString();

        final user = AuthUser.fromJson(userMap);
        await _saveSession(user);
        return true;
      }

      _errorMessage =
          (data['message'] ?? 'Não foi possível criar a conta.').toString();
      return false;
    } catch (_) {
      _errorMessage =
          'Não foi possível conectar ao backend. Verifique se a API está rodando.';
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = _decodeBody(response);

      if (response.statusCode == 200) {
        final rawUser = data['user'];
        final userMap = rawUser is Map
            ? Map<String, dynamic>.from(rawUser)
            : <String, dynamic>{};

        userMap['token'] = (data['token'] ?? '').toString();

        final user = AuthUser.fromJson(userMap);
        await _saveSession(user);
        return true;
      }

      _errorMessage =
          (data['message'] ?? 'Não foi possível entrar na conta.').toString();
      return false;
    } catch (_) {
      _errorMessage =
          'Não foi possível conectar ao backend. Verifique se a API está rodando.';
      return false;
    }
  }

  Future<void> logout() async {
    await _clearSession();
    notifyListeners();
  }

  Future<void> _saveSession(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();

    _currentUser = user;

    await prefs.setString(_authTokenKey, user.token);
    await prefs.setString(_authUserKey, jsonEncode(user.toJson()));

    notifyListeners();
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    _currentUser = null;
    _errorMessage = null;

    await prefs.remove(_authTokenKey);
    await prefs.remove(_authUserKey);
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }
}