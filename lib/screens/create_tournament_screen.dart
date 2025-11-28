import 'package:flutter/material.dart';
import 'tournament_detail_screen.dart'; // Para reutilizar PartidaCard

class BracketView extends StatelessWidget {
  final List<dynamic> partidas;
  final bool isOrganizador;
  final Function(dynamic) onPartidaTap;

  const BracketView({
    super.key,
    required this.partidas,
    required this.isOrganizador,
    required this.onPartidaTap,
  });

  @override
  Widget build(BuildContext context) {
    if (partidas.isEmpty) {
      return const Center(child: Text("No hay partidas."));
    }

    // 1. Agrupar partidas por Ronda
    // roundMap será: { 1: [Partida, Partida], 2: [Partida], 3: [Final] }
    Map<int, List<dynamic>> roundMap = {};
    for (var p in partidas) {
      int round = p['round'] ?? 1; // Si es nulo, asumimos ronda 1
      if (!roundMap.containsKey(round)) {
        roundMap[round] = [];
      }
      roundMap[round]!.add(p);
    }

    // Convertir a lista para mostrar columnas en orden
    var roundKeys = roundMap.keys.toList()..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Scroll horizontal para ver el bracket
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: roundKeys.map((round) {
          return Container(
            width: 320, // Ancho fijo para cada ronda
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título de la Ronda
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _getRoundTitle(round, roundKeys.last),
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 18
                    ),
                  ),
                ),
                // Lista de Partidas de esta ronda
                ...roundMap[round]!.map((partida) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: InkWell(
                      onTap: (isOrganizador && partida['status'] == 'Pendiente')
                          ? () => onPartidaTap(partida)
                          : null,
                      child: PartidaCard(
                        partida: partida,
                        isOrganizador: isOrganizador,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getRoundTitle(int round, int maxRound) {
    if (round == maxRound) return "🏆 GRAN FINAL";
    if (round == maxRound - 1) return "Semifinales";
    return "Ronda $round";
  }
}
