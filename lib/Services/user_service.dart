import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class UserService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getProfile() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('$apiUrl/api/Users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar perfil');
    }
  }


  Future<bool> updateAvatar(String avatarId) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$apiUrl/api/Users/avatar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'avatarId': avatarId}),
    );

    return response.statusCode == 200;
  }
}
