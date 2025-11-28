// lib/services/admin_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class AdminService {
  final AuthService _authService = AuthService();

  // --- 1. NUEVA FUNCIÓN: OBTENER ESTADÍSTICAS ---
  // Llama a: GET /api/Admin/stats
  Future<Map<String, dynamic>> getStats() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('$apiUrl/api/Admin/stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falló al cargar estadísticas');
    }
  }

  // --- 2. OBTENER TODOS LOS USUARIOS ---
  // Llama a: GET /api/Admin/users
  Future<List<dynamic>> getUsers() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No autenticado como Admin');

    final response = await http.get(
      Uri.parse('$apiUrl/api/Admin/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falló al cargar usuarios');
    }
  }

  // --- 3. PROMOVER A ORGANIZADOR ---
  // Llama a: POST /api/Admin/promote/{userId}
  Future<bool> promoteUser(int userId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No autenticado como Admin');

    final response = await http.post(
      Uri.parse('$apiUrl/api/Admin/promote/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }

  // --- 4. DEGRADAR A JUGADOR ---
  // Llama a: POST /api/Admin/demote/{userId}
  Future<bool> demoteUser(int userId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No autenticado como Admin');

    final response = await http.post(
      Uri.parse('$apiUrl/api/Admin/demote/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }
}
