
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart'; 


class PartidaResponse {
  final bool success;
  final String message;
  PartidaResponse(this.success, this.message);
}
// --------------------------------------

class PartidaService {
  final AuthService _authService = AuthService();
  Future<List<dynamic>> getPartidas(int tournamentId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/api/Partidas/torneo/$tournamentId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falló al cargar las partidas');
    }
  }


  Future<bool> createPartida(int tournamentId, int teamAId, int teamBId, DateTime scheduledTime, String? twitchChannel) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No autenticado');
    
    final response = await http.post(
      Uri.parse('$apiUrl/api/Partidas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tournamentId': tournamentId,
        'teamA_Id': teamAId,
        'teamB_Id': teamBId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'twitchChannelName': twitchChannel,
      }),
    );
    return response.statusCode == 200; 
  }

  Future<bool> registerResultado(int partidaId, int scoreA, int scoreB, int winnerId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No autenticado');

    final response = await http.post(
      Uri.parse('$apiUrl/api/Partidas/$partidaId/resultado'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'scoreTeamA': scoreA,
        'scoreTeamB': scoreB,
        'winnerTeamId': winnerId,
      }),
    );
    return response.statusCode == 200;
  }


  Future<PartidaResponse> generarFixture(int tournamentId) async {
    final token = await _authService.getToken();
    if (token == null) return PartidaResponse(false, 'No autenticado');

    final response = await http.post(
      Uri.parse('$apiUrl/api/Partidas/generar/$tournamentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

  
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return PartidaResponse(true, data['message'] ?? 'Sorteo realizado con éxito');
    } else {
      return PartidaResponse(false, data['message'] ?? 'Error al generar sorteo');
    }
  }
}
