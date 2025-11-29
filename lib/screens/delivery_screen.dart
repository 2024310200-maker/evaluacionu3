import 'dart:typed_data'; // Necesario para Uint8List
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class DeliveryScreen extends StatefulWidget {
  final int packageId;
  final String trackingCode;
  final String address;

  const DeliveryScreen({
    super.key,
    required this.packageId,
    required this.trackingCode,
    required this.address,
  });

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  LatLng _currentPosition = const LatLng(20.5888, -100.3899);
  bool _isLoadingLocation = true;
  bool _isSubmitting = false;
  
  // CAMBIO 1: Guardamos los bytes en memoria en lugar del archivo
  // Esto elimina la necesidad de usar 'File' y 'dart:io'
  Uint8List? _evidenceBytes;
  
  final MapController _mapController = MapController();

  String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    return 'http://10.0.2.2:8000';
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack("⚠️ GPS apagado");
      setState(() => _isLoadingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      _mapController.move(_currentPosition, 16.5);
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    
    if (photo != null) {
      // CAMBIO 2: Leemos los bytes inmediatamente al tomar la foto
      final bytes = await photo.readAsBytes();
      setState(() {
        _evidenceBytes = bytes;
      });
    }
  }

  Future<void> _submitDelivery() async {
    if (_evidenceBytes == null) {
      _showSnack("📷 La foto es obligatoria");
      return;
    }
    setState(() => _isSubmitting = true);
    
    try {
      var uri = Uri.parse('$_baseUrl/deliver/${widget.packageId}');
      var request = http.MultipartRequest('POST', uri);
      
      request.fields['latitude'] = _currentPosition.latitude.toString();
      request.fields['longitude'] = _currentPosition.longitude.toString();
      
      // CAMBIO 3: Usamos los bytes que ya tenemos en memoria
      // Esto es seguro en todas las plataformas
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', 
          _evidenceBytes!, 
          filename: 'evidence_${DateTime.now().millisecondsSinceEpoch}.jpg'
        )
      );
      
      var response = await request.send();
      
      if (response.statusCode == 200) {
        _showSnack("✅ Entrega registrada");
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } else {
        _showSnack("❌ Error servidor: ${response.statusCode}");
      }
    } catch (e) {
      print("Error detallado: $e");
      _showSnack("❌ Error conexión: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.black87)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text(
          "Entrega ${widget.trackingCode}",
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black.withOpacity(0.7), 
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // MAPA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _currentPosition, initialZoom: 15.0),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 100,
                    height: 100,
                    child: const Icon(Icons.water_drop, color: Colors.blueAccent, size: 60),
                  ),
                ],
              ),
            ],
          ),
          
          if (_isLoadingLocation)
            const Center(
              child: Card(
                elevation: 4,
                color: Colors.white,
                shape: CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: Colors.teal),
                ),
              ),
            ),
          
          // TARJETA INFERIOR
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.home_work_outlined, color: Colors.teal),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Destino", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(widget.address, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Botón Foto
                    InkWell(
                      onTap: _takePhoto,
                      borderRadius: BorderRadius.circular(15), 
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey[300]!, width: 2), 
                        ),
                        // CAMBIO 4: Mostrar imagen desde memoria (Uint8List)
                        // Image.memory funciona en TODAS las plataformas sin dart:io
                        child: _evidenceBytes == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.orange),
                                  SizedBox(height: 5),
                                  Text("Añadir Evidencia", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.memory(_evidenceBytes!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitDelivery,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, 
                          foregroundColor: Colors.white,
                        ),
                        child: _isSubmitting 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text("CONFIRMAR ENTREGA"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}