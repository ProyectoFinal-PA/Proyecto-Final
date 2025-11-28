import 'package:flutter/material.dart';
import '../services/equipo_service.dart'; 
import '../services/auth_service.dart'; 
import '../services/partida_service.dart'; 
import 'stream_screen.dart'; 

class TournamentDetailScreen extends StatefulWidget {
  final dynamic tournament; 
  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  final EquipoService _equipoService = EquipoService();
  final PartidaService _partidaService = PartidaService(); 
  final AuthService _authService = AuthService();

  late Future<List<dynamic>> _equiposFuture;
  late Future<List<dynamic>> _partidasFuture;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); 
    _loadDetails();
  }

  void _loadDetails() {
    _authService.getRole().then((role) {
      if (mounted) setState(() => _userRole = role);
    });
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _equiposFuture = _equipoService.getEquipos(widget.tournament['id']);
      _partidasFuture = _partidaService.getPartidas(widget.tournament['id']);
    });
  }

  // --- LÓGICA PARA SALIR DEL EQUIPO ---
  void _leaveTeam() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Abandonar Equipo?'),
        content: const Text('Saldrás de tu equipo actual.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true), 
            child: const Text('Abandonar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _equipoService.leaveCurrentTeam();
        if (!mounted) return;
        if (response.success) {
          _showSnackBar(response.message, false);
          _refreshData(); 
        } else {
          _showSnackBar(response.message, true);
        }
      } catch (e) {
        if (mounted) _showSnackBar(e.toString(), true);
      }
    }
  }

  // --- FUNCIÓN ELIMINAR EQUIPO (ORGANIZADOR) ---
  void _deleteEquipo(int teamId, String teamName) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Equipo'),
        content: Text('¿Seguro que quieres eliminar al equipo "$teamName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true), 
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await _equipoService.deleteEquipo(teamId);
      if (success) {
        _showSnackBar('Equipo eliminado', false);
        _refreshData();
      } else {
        _showSnackBar('Error al eliminar', true);
      }
    }
  }

  // --- GENERAR SORTEO ---
  void _generarSorteo() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Generar Sorteo?'),
        content: const Text('Se crearán enfrentamientos aleatorios. Esto no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Generar')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _partidaService.generarFixture(widget.tournament['id']);
        if (!mounted) return;
        if (response.success) {
          _showSnackBar(response.message, false);
          _refreshData(); 
        } else {
          _showSnackBar(response.message, true);
        }
      } catch (e) {
        if (mounted) _showSnackBar(e.toString(), true);
      }
    }
  }

  // --- Diálogos ---
  void _showCreateEquipoDialog() {
    final _nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) { 
        return AlertDialog(
          title: const Text('Crear Nuevo Equipo'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre del Equipo'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty) return;
                try {
                  final response = await _equipoService.createEquipo(
                    _nameController.text,
                    widget.tournament['id'],
                  );
                  if (!mounted) return;
                  Navigator.of(ctx).pop(); 
                  if (response.success) {
                    _showSnackBar('¡Equipo creado!', false);
                    _refreshData(); 
                  } else {
                    _showSnackBar(response.message, true);
                  }
                } catch (e) {
                  if (mounted) _showSnackBar(e.toString(), true);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _joinEquipo(int teamId, String teamName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Seguro que quieres unirte a "$teamName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await _equipoService.joinEquipo(teamId);
                if (!mounted) return;
                Navigator.of(ctx).pop(); 
                if (response.success) {
                  _showSnackBar(response.message, false);
                  _refreshData();
                } else {
                  _showSnackBar(response.message, true); 
                }
              } catch (e) {
                if (mounted) _showSnackBar(e.toString(), true);
              }
            },
            child: const Text('Unirme'),
          ),
        ],
      ),
    );
  }

  void _showRegisterResultadoDialog(dynamic partida) {
    final _scoreAController = TextEditingController();
    final _scoreBController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Registrar Resultado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _scoreAController,
              decoration: InputDecoration(labelText: 'Puntaje ${partida['teamA']}'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _scoreBController,
              decoration: InputDecoration(labelText: 'Puntaje ${partida['teamB']}'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                final scoreA = int.parse(_scoreAController.text);
                final scoreB = int.parse(_scoreBController.text);
                int winnerId;
                if (scoreA > scoreB) {
                    winnerId = partida['teamAId']; 
                } else {
                    winnerId = partida['teamBId']; 
                }

                final success = await _partidaService.registerResultado(
                  partida['id'],
                  scoreA,
                  scoreB,
                  winnerId,
                );
                
                if (!mounted) return;
                Navigator.of(ctx).pop();
                if (success) {
                  _showSnackBar('Resultado registrado', false);
                  _refreshData();
                } else {
                  _showSnackBar('Error al registrar resultado', true);
                }
              } catch (e) {
                if (mounted) _showSnackBar(e.toString(), true);
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, bool isError) {
    if (!mounted) return; 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String tournamentName = widget.tournament['name'] ?? 'Detalle del Torneo';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(tournamentName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Información'),
            Tab(icon: Icon(Icons.group), text: 'Equipos'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Bracket'), 
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(), 
          _buildEquiposTab(), 
          _buildPartidasTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    String? kickChannel = widget.tournament['kickChannel'];
    String? prize = widget.tournament['prize'];
    String? rules = widget.tournament['rules'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.tournament['name'], style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  InfoRow(icon: Icons.videogame_asset, label: 'Juego:', value: widget.tournament['game']),
                  InfoRow(icon: Icons.person, label: 'Organizador:', value: widget.tournament['organizadorNickname']),
                  
                  if (prize != null && prize.isNotEmpty) ...[
                    const Divider(height: 24),
                    Row(children: [const Icon(Icons.emoji_events, color: Colors.amber), const SizedBox(width: 8), Text("Premio:", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.amber))]),
                    const SizedBox(height: 4),
                    Text(prize, style: const TextStyle(fontSize: 16)),
                  ],

                  if (rules != null && rules.isNotEmpty) ...[
                    const Divider(height: 24),
                    Row(children: [const Icon(Icons.rule, color: Colors.blueAccent), const SizedBox(width: 8), Text("Reglas:", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blueAccent))]),
                    const SizedBox(height: 4),
                    Text(rules, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                  
                  if (kickChannel != null && kickChannel.isNotEmpty) ...[
                    const Divider(height: 32),
                    const Text("Transmisión Oficial:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF53FC18), 
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => StreamScreen(channelName: kickChannel)));
                        },
                        icon: const Icon(Icons.videocam),
                        label: Text('Ver a $kickChannel en vivo'),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquiposTab() {
    return Column(
      children: [
        if (_userRole == 'Jugador')
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _showCreateEquipoDialog, 
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Equipo'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
                ),
                const SizedBox(width: 16), 
                OutlinedButton.icon(
                  onPressed: _leaveTeam, 
                  icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                  label: const Text('Salir de mi Equipo', style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _equiposFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Aún no hay equipos inscritos.'));
              
              final equipos = snapshot.data!;
              return RefreshIndicator(
                onRefresh: () async => _refreshData(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: equipos.length,
                  itemBuilder: (context, index) {
                    final equipo = equipos[index];
                    List<dynamic> members = equipo['memberNicknames'] ?? [];
                    String captain = equipo['captainNickname'] ?? 'N/A';

                    Widget? trailingButton;
                    if (_userRole == 'Jugador') {
                       trailingButton = IconButton(
                          icon: const Icon(Icons.login, color: Colors.greenAccent),
                          onPressed: () => _joinEquipo(equipo['id'], equipo['name']), 
                        );
                    } else if (_userRole == 'Organizador') {
                       trailingButton = IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteEquipo(equipo['id'], equipo['name']), 
                        );
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ExpansionTile(
                        leading: const Icon(Icons.security, color: Colors.deepPurpleAccent),
                        title: Text(equipo['name'] ?? 'Sin Nombre', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Integrantes: ${members.length}'),
                        children: [
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [const Icon(Icons.star, size: 16, color: Colors.amber), const SizedBox(width: 8), Text("Capitán: $captain", style: const TextStyle(fontWeight: FontWeight.bold))]),
                                const SizedBox(height: 8),
                                ...members.map((m) => Padding(
                                  padding: const EdgeInsets.only(left: 24.0, top: 4.0),
                                  child: Row(children: [const Icon(Icons.person, size: 14, color: Colors.grey), const SizedBox(width: 8), Text(m.toString())]),
                                )),
                                const SizedBox(height: 16),
                                if (trailingButton != null) Center(child: trailingButton),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPartidasTab() {
    return FutureBuilder<List<dynamic>>(
      future: _partidasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          if (_userRole == 'Organizador') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shuffle, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Aún no hay partidas.'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _generarSorteo, 
                    icon: const Icon(Icons.casino), 
                    label: const Text('Generar Sorteo Automático'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Bracket no generado.'));
          }
        }
        
        final partidas = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => _refreshData(),
          child: BracketView(
            partidas: partidas,
            isOrganizador: _userRole == 'Organizador',
            onPartidaTap: _showRegisterResultadoDialog,
          ),
        );
      },
    );
  }
}

class BracketView extends StatelessWidget {
  final List<dynamic> partidas;
  final bool isOrganizador;
  final Function(dynamic) onPartidaTap;

  const BracketView({super.key, required this.partidas, required this.isOrganizador, required this.onPartidaTap});

  @override
  Widget build(BuildContext context) {
    Map<int, List<dynamic>> roundMap = {};
    int maxRound = 0;
    for (var p in partidas) {
      int round = p['round'] ?? 1;
      if (round > maxRound) maxRound = round;
      if (!roundMap.containsKey(round)) roundMap[round] = [];
      roundMap[round]!.add(p);
    }
    var roundKeys = roundMap.keys.toList()..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, 
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: roundKeys.map((round) {
          return Container(
            width: 320, 
            margin: const EdgeInsets.only(right: 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _getRoundTitle(round, maxRound),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
                  ),
                ),
                ...roundMap[round]!.map((partida) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: InkWell(
                      onTap: (isOrganizador && partida['status'] == 'Pendiente') 
                          ? () => onPartidaTap(partida) 
                          : null,
                      child: PartidaCard(partida: partida, isOrganizador: isOrganizador),
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
    if (round == maxRound - 2) return "Cuartos de Final";
    return "Ronda $round";
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const InfoRow({super.key, required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [Icon(icon, size: 20, color: Colors.deepPurpleAccent), const SizedBox(width: 12), Text(label), const Spacer(), Text(value)]),
    );
  }
}

class PartidaCard extends StatelessWidget {
  final dynamic partida; final bool isOrganizador; 
  const PartidaCard({super.key, required this.partida, this.isOrganizador = false});

  @override
  Widget build(BuildContext context) {
    String teamA = partida['teamA'] ?? 'TBD';
    String teamB = partida['teamB'] ?? 'TBD';
    String status = partida['status'] ?? 'Pendiente';
    
    String formattedTime = partida['scheduledTime'].toString();
    try {
      DateTime t = DateTime.parse(partida['scheduledTime']);
      formattedTime = '${t.day}/${t.month} ${t.hour}:${t.minute.toString().padLeft(2, '0')}';
    } catch (e) {}

    String scoreText = 'VS';
    if (status == 'Jugada' && partida['resultado'] != null) {
      scoreText = '${partida['resultado']['scoreTeamA']} - ${partida['resultado']['scoreTeamB']}';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.deepPurple.withOpacity(0.3))),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(teamA, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(scoreText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
                ),
                Expanded(child: Text(teamB, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            Text(formattedTime, style: TextStyle(color: Colors.grey[500], fontSize: 12)),

            if (isOrganizador && status == 'Pendiente')
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('Toca para puntuar', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              ),
          ],
        ),
      ),
    );
  }
}
