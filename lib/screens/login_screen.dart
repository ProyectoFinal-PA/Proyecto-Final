// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart'; // <-- ¡IMPORTAMOS LA NUEVA PANTALLA!

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Rellenamos con el Admin para pruebas rápidas
  final _emailController = TextEditingController(text: "admin@test.com"); 
  final _passwordController = TextEditingController(text: "123"); 
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    bool success = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (success && mounted) { 
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Credenciales inválidas')),
      );
    }
  }

  // --- ¡¡NUEVA FUNCIÓN!! ---
  void _navigateToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }
  // -------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card( // <-- Diseño de tarjeta
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox( // Hacemos el botón más grande
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text('Ingresar'),
                    ),
                  ),
            const SizedBox(height: 20),
            // --- ¡¡BOTÓN DE REGISTRO AÑADIDO!! ---
            TextButton(
              onPressed: _navigateToRegister,
              child: const Text('¿No tienes cuenta? Regístrate aquí'),
            )
            // ------------------------------------
          ],
        ),
      ),
    );
  }
}
