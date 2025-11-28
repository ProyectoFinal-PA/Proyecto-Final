import 'package:flutter/material.dart';
import '../services/tournament_service.dart'; 

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gameController = TextEditingController();
  final _kickController = TextEditingController();
  final _prizeController = TextEditingController(); // Nuevo
  final _rulesController = TextEditingController(); // Nuevo
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;
  final TournamentService _tournamentService = TournamentService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        bool success = await _tournamentService.createTournament(
          _nameController.text,
          _gameController.text,
          _selectedDate,
          _kickController.text.isEmpty ? null : _kickController.text,
          _prizeController.text.isEmpty ? null : _prizeController.text, // Enviamos
          _rulesController.text.isEmpty ? null : _rulesController.text, // Enviamos
        );
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Torneo creado!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        } else if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear'), backgroundColor: Colors.red),
          );
        }

      } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
           );
         }
      } finally {
         setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nuevo Torneo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre del Torneo'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _gameController,
                        decoration: const InputDecoration(labelText: 'Juego'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _kickController,
                        decoration: const InputDecoration(
                          labelText: 'Canal de Kick (Opcional)',
                          prefixIcon: Icon(Icons.video_camera_back),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // --- NUEVOS CAMPOS ---
                      TextFormField(
                        controller: _prizeController,
                        decoration: const InputDecoration(
                          labelText: 'Premio (Opcional)',
                          prefixIcon: Icon(Icons.emoji_events),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _rulesController,
                        decoration: const InputDecoration(
                          labelText: 'Reglas (Opcional)',
                          prefixIcon: Icon(Icons.rule),
                        ),
                        maxLines: 3, // Permite escribir más texto
                      ),
                      // ---------------------
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fecha de Inicio:'),
                          TextButton(
                            onPressed: () => _selectDate(context),
                            child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Guardar Torneo'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
