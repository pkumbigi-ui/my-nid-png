import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  String? _token;
  String? _role;
  bool _isLoading = false;

  String? get token => _token;
  String? get role => _role;
  bool get isLoading => _isLoading;

  // ✅ NEW: Critical getter to avoid stack overflow
  bool get isAuthenticated => _token != null;

  final String baseUrl = 'http://127.0.0.1:5000'; // Your Flask backend URL

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> register(
      String givenName,
      String surname,
      String email,
      String password,
      String role,
      ) async {
    _setLoading(true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'given_name': givenName,   // ✅ Correct key: snake_case, no space
          'surname': surname,        // ✅ Add surname
          'email': email,
          'password': password,
          'role': role.toLowerCase(),
        }),
      );

      if (response.statusCode == 201) {
        _setLoading(false);
        return true;
      } else if (response.statusCode == 409) {
        throw Exception('Email already registered');
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _role = data['role']?.toString().toLowerCase();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('role', _role!);

        _setLoading(false);
        notifyListeners(); // Ensure listeners update after login
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  // ✅ NEW: Added password reset functionality
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send reset email: ${response.body}');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    notifyListeners(); // Important: UI should react
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _role = prefs.getString('role');
    notifyListeners(); // Notify UI to update auth state
  }
}