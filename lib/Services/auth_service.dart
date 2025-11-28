// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http; // <-- ¡¡IMPORTANTE!!
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('role', data['role']); 
        return true;
      } else {
        print('Error de login: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción de login: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<bool> register(String email, String password, String nickname) async {
    final response = await http.post(
      Uri.parse('$apiUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'nickname': nickname,
      }),
    );
    return response.statusCode == 200;
  }
}
