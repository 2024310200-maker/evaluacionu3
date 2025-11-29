import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const PaquexpressApp());
}

class PaquexpressApp extends StatelessWidget {
  const PaquexpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paquexpress', // Puedes cambiar el nombre si quieres
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // CAMBIO 1: Paleta de colores Teal (Verde azulado)
        primarySwatch: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F4F4), // Fondo ligeramente verdozo
        
        // CAMBIO 2: Estilo de AppBar más limpio
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: false, // Título a la izquierda
          titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),

        // CAMBIO 3: Campos de texto muy redondeados
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0), // Bordes muy redondos
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          prefixIconColor: Colors.teal,
        ),
        
        // CAMBIO 4: Botones con estilo píldora
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent[700], // Botones naranjas
            foregroundColor: Colors.white,
            elevation: 5,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}