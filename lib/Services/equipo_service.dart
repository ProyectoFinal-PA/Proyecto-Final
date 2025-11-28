
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class ApiResponse {
  final bool success;
  final String message;
  ApiResponse(this.success, this.message);
}

class EquipoService {
  final AuthService _authService = AuthService();


  Future<List<dynamic>> getEquipos(int tournamentId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/api/Equipos/torneo/$tournamentId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falló al cargar los equipos');
    }
  }


  Future<ApiResponse> createEquipo(String name, int tournamentId) async {
    final token = await _authService.getToken();
    if (token == null) return ApiResponse(false, 'No autenticado');

    final response = await http.post(
      Uri.parse('$apiUrl/api/Equipos'),
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
      body: jsonEncode({ 'name': name, 'tournamentId': tournamentId }),
    );

    if (response.statusCode == 200) {
      return ApiResponse(true, 'Equipo creado');
    } else {
      final errorData = jsonDecode(response.body);
      return ApiResponse(false, errorData['message'] ?? 'Error desconocido');
    }
  }


  Future<ApiResponse> joinEquipo(int teamId) async {
    final token = await _authService.getToken();
    if (token == null) return ApiResponse(false, 'No autenticado');

    final response = await http.post(
      Uri.parse('$apiUrl/api/Equipos/$teamId/join'),
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse(true, data['message'] ?? 'Éxito');
    } else {
      final errorData = jsonDecode(response.body);
      return ApiResponse(false, errorData['message'] ?? 'Error desconocido');
    }
  }


  Future<bool> deleteEquipo(int teamId) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$apiUrl/api/Equipos/$teamId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 204; 
  }

 
  Future<ApiResponse> leaveCurrentTeam() async {
    final token = await _authService.getToken();
    if (token == null) return ApiResponse(false, 'No autenticado');

    final response = await http.post(
      Uri.parse('$apiUrl/api/Equipos/leave'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse(true, data['message'] ?? 'Has salido del equipo');
    } else {
      final errorData = jsonDecode(response.body);
      return ApiResponse(false, errorData['message'] ?? 'Error al salir');
    }
  }
}
