// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminService _adminService = AdminService();
  late Future<List<dynamic>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _adminService.getUsers();
    });
  }

  void _promoteUser(int userId) async {
    try {
      bool success = await _adminService.promoteUser(userId);
      if (success) {
        _loadUsers(); // Recargar la lista
      }
    } catch (e) {
      // Manejar error
    }
  }

  void _demoteUser(int userId) async {
    try {
      bool success = await _adminService.demoteUser(userId);
      if (success) {
        _loadUsers(); // Recargar la lista
      }
    } catch (e) {
      // Manejar error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron usuarios.'));
          }

          final users = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _loadUsers(),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                String role = user['role'];
                IconData roleIcon;
                Color roleColor;
                Widget actionButton;

                if (role == 'Admin') {
                  roleIcon = Icons.admin_panel_settings;
                  roleColor = Colors.amber;
                  actionButton = const SizedBox(width: 48); // Espacio vacío
                } else if (role == 'Organizador') {
                  roleIcon = Icons.supervisor_account;
                  roleColor = Colors.blueAccent;
                  actionButton = IconButton(
                    icon: const Icon(Icons.arrow_downward, color: Colors.redAccent),
                    tooltip: 'Degradar a Jugador',
                    onPressed: () => _demoteUser(user['id']),
                  );
                } else {
                  roleIcon = Icons.person;
                  roleColor = Colors.grey;
                  actionButton = IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Colors.greenAccent),
                    tooltip: 'Promover a Organizador',
                    onPressed: () => _promoteUser(user['id']),
                  );
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Icon(roleIcon, color: roleColor),
                    title: Text(user['nickname'] ?? 'N/A'),
                    subtitle: Text(user['email'] ?? 'N/A'),
                    trailing: actionButton,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
