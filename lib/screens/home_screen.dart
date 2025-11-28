// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/tournament_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'create_tournament_screen.dart'; 
import 'tournament_detail_screen.dart';
import 'admin_screen.dart'; 
import 'profile_screen.dart'; // <-- ¡IMPORTANTE: IMPORTAMOS LA PANTALLA DE PERFIL!

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TournamentService _tournamentService = TournamentService();
  final AuthService _authService = AuthService();
  
  late Future<List<dynamic>> _tournamentsFuture;
  String? _userRole; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _tournamentsFuture = _tournamentService.getTournaments();
    _authService.getRole().then((role) {
      if (mounted) {
        setState(() {
          _userRole = role;
        });
      }
    });
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _navigateToCreateTournament() async {
    final didCreate = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const CreateTournamentScreen()),
    );
    if (didCreate == true) {
      _refreshData();
    }
  }
  
  Future<void> _refreshData() async {
    setState(() {
      _tournamentsFuture = _tournamentService.getTournaments();
    });
  }

  void _navigateToTournamentDetail(dynamic tournament) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TournamentDetailScreen(
          tournament: tournament, 
        ),
      ),
    ).then((_) => _refreshData()); 
  }

  void _navigateToAdminPanel() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AdminScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Torneos E-Sports'),
          actions: [
            if (_userRole == 'Admin')
              IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                tooltip: 'Panel de Admin',
                onPressed: _navigateToAdminPanel,
              ),
            
            // --- BOTÓN DE PERFIL (AÑADIDO) ---
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Mi Perfil',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            // ---------------------------------

            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar Sesión',
              onPressed: _logout,
            ),
          ],
          
          bottom: const TabBar(
            indicatorColor: Colors.deepPurpleAccent,
            labelColor: Colors.deepPurpleAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Inscripciones', icon: Icon(Icons.app_registration)),
              Tab(text: 'En Juego', icon: Icon(Icons.sports_esports)),
              Tab(text: 'Finalizados', icon: Icon(Icons.emoji_events)),
            ],
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _tournamentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            
            final allTournaments = snapshot.data ?? [];

            // Filtramos las listas
            final inscripciones = allTournaments.where((t) => t['status'] == 'Inscripciones').toList();
            final enJuego = allTournaments.where((t) => t['status'] == 'En Juego').toList();
            final finalizados = allTournaments.where((t) => t['status'] == 'Finalizado').toList();

            return TabBarView(
              children: [
                _buildTournamentList(inscripciones, "No hay torneos abiertos."),
                _buildTournamentList(enJuego, "No hay torneos en curso."),
                _buildTournamentList(finalizados, "No hay torneos finalizados."),
              ],
            );
          },
        ),
        floatingActionButton: _userRole == 'Organizador'
            ? FloatingActionButton.extended(
                onPressed: _navigateToCreateTournament,
                icon: const Icon(Icons.add),
                label: const Text('Crear Torneo'),
                backgroundColor: Colors.deepPurpleAccent,
              )
            : null, 
      ),
    );
  }

  Widget _buildTournamentList(List<dynamic> tournaments, String emptyMessage) {
    if (tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: tournaments.length,
        itemBuilder: (context, index) {
          final tournament = tournaments[index];
          return _buildTournamentCard(tournament);
        },
      ),
    );
  }

  Widget _buildTournamentCard(dynamic tournament) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToTournamentDetail(tournament),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tournament['name'] ?? 'Sin Nombre',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.gamepad, color: Colors.deepPurpleAccent),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Juego: ${tournament['game'] ?? 'N/A'}',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    tournament['organizadorNickname'] ?? 'N/A',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
              if (tournament['prize'] != null && tournament['prize'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(tournament['prize'], style: const TextStyle(color: Colors.amber, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

