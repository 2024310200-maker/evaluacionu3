import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  // Lógica para seleccionar la URL correcta automáticamente
  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    return 'http://localhost:8000';
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnack("⚠️ Faltan datos de acceso");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final url = Uri.parse('$_baseUrl/login/');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          // Navegar a la pantalla de inicio (HomeScreen)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userId: data['user_id'], username: data['username']),
            ),
          );
        }
      } else {
        _showSnack("❌ Acceso denegado");
      }
    } catch (e) {
      _showSnack("🔌 Sin conexión al servidor");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.teal[900],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo con degradado moderno
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade300, Colors.teal.shade900],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              // Tarjeta flotante para el formulario
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícono circular moderno (Caja 3D)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.view_in_ar_rounded, size: 60, color: Colors.orange[800]),
                    ),
                    const SizedBox(height: 20),
                    
                    // Títulos
                    Text(
                      "LOGÍSTICA",
                      style: TextStyle(fontSize: 14, letterSpacing: 2, color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Paquexpress",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.teal),
                    ),
                    const SizedBox(height: 30),
                    
                    // Campos de Texto
                    TextField(
                      controller: _userController,
                      decoration: const InputDecoration(labelText: "ID Agente", prefixIcon: Icon(Icons.badge_outlined)),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Clave de Acceso", prefixIcon: Icon(Icons.fingerprint)),
                    ),
                    const SizedBox(height: 30),
                    
                    // Botón de Acción
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                          : const Text("INICIAR RUTA"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}