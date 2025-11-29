import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart'; 
import 'delivery_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String username;

  const HomeScreen({super.key, required this.userId, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _packages = [];
  bool _isLoading = true;

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    return 'http://localhost:8000';
  }

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('$_baseUrl/packages/${widget.userId}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() => _packages = jsonDecode(response.body));
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _logout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Asignaciones"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.teal[800],
              child: IconButton(
                icon: const Icon(Icons.power_settings_new, color: Colors.white, size: 20),
                onPressed: _logout,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Cabecera informativa con color sólido
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hola, ${widget.username}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                Text("${_packages.length} Entregas Pendientes", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // Lista de paquetes estilizada
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.teal))
              : _packages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.thumb_up_alt_outlined, size: 80, color: Colors.teal.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          const Text("Ruta completada", style: TextStyle(color: Colors.grey, fontSize: 18)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _packages.length,
                      itemBuilder: (context, index) {
                        final pkg = _packages[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DeliveryScreen(
                                        packageId: pkg['id'],
                                        trackingCode: pkg['tracking_code'],
                                        address: pkg['address'],
                                      ),
                                    ),
                                  ).then((_) => _fetchPackages());
                                },
                                child: Row(
                                  children: [
                                    // Barra lateral naranja (Indicador visual de estado)
                                    Container(width: 8, height: 100, color: Colors.orangeAccent),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(pkg['tracking_code'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.teal)),
                                                const Icon(Icons.touch_app, size: 18, color: Colors.orangeAccent),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.place, size: 16, color: Colors.grey),
                                                const SizedBox(width: 5),
                                                Expanded(child: Text(pkg['address'], style: TextStyle(color: Colors.grey[800]), maxLines: 1)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(pkg['description'] ?? "Sin notas", style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}