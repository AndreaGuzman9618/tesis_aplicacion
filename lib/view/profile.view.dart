import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tesis_aplicacion/utils/global.colors.dart';
import 'package:tesis_aplicacion/utils/apiURL.dart';


class PerfilPage extends StatefulWidget {
  final int userId;

  PerfilPage({required this.userId});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  LatLng? selectedLocation;
  bool isLoading = true;
  bool isEditing = false;

  void _openMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
    if (result != null && result is Map) {
      setState(() {
        selectedLocation = result['location'];
        direccionController.text = result['address'] ?? "Dirección no encontrada";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/perfil/${widget.userId}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          nombreController.text = data['nombre'];
          emailController.text = data['email'];
          telefonoController.text = data['telefono'];
          direccionController.text = data['direccion'];
          selectedLocation = LatLng(data['coordenadas_lat'], data['coordenadas_lon']);
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar el perfil.');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/perfil/${widget.userId}');
    final body = {
      'email': emailController.text,
      'telefono': telefonoController.text,
      'direccion': direccionController.text,
      'coordenadas_lat': selectedLocation?.latitude,
      'coordenadas_lon': selectedLocation?.longitude,
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil actualizado con éxito.')),
        );
      } else {
        throw Exception('Error al actualizar el perfil.');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el perfil.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil',
          style: TextStyle(color: Colors.white),),
        backgroundColor: GlobalColors.mainColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Imagen de usuario
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: GlobalColors.mainColor,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  // Campos del perfil
                  TextField(
                    controller: nombreController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    readOnly: true, // Siempre de solo lectura
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Correo Electrónico'),
                    readOnly: !isEditing, // Editable solo en modo edición
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: telefonoController,
                    decoration: InputDecoration(labelText: 'Teléfono'),
                    readOnly: !isEditing, // Editable solo en modo edición
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: direccionController,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      suffixIcon: isEditing
                          ? IconButton(
                              icon: Icon(Icons.map),
                              onPressed: _openMap,
                            )
                          : null,
                    ),
                    readOnly: !isEditing, // Editable solo en modo edición
                  ),
                ],
              ),
            ),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? currentLocation;
  LatLng? selectedLocation;
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        selectedLocation = currentLocation;
      });
    } catch (e) {
      print("Error al obtener la ubicación: $e");
    }
  }

  Future<String?> getAddressFromLatLng(double latitude, double longitude) async {
    const String apiKey = 'AIzaSyBscbM7aq7pygWcvtSRPavGpBQfJkRFQv0'; // Reemplaza con tu clave de API
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      print("Solicitando dirección para: $url");
      final response = await http.get(Uri.parse(url));
      print("Código de respuesta: ${response.statusCode}");
      print("Respuesta: ${response.body}");
          
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      } else {
        print("Error en la respuesta de la API: ${response.body}");
      }
    } catch (e) {
      print("Error al obtener la dirección: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Selecciona tu ubicación')),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLocation!,
                zoom: 14,
              ),
              onMapCreated: (controller) => mapController = controller,
              onTap: (LatLng location) {
                setState(() {
                  selectedLocation = location;
                });
              },
              markers: {
                if (selectedLocation != null)
                  Marker(
                    markerId: MarkerId('selected-location'),
                    position: selectedLocation!,
                  ),
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (selectedLocation != null) {
            String? address = await getAddressFromLatLng(
              selectedLocation!.latitude,
              selectedLocation!.longitude,
            );
            Navigator.pop(context, {
              'location': selectedLocation,
              'address': address,
            });
          } else {
            Navigator.pop(context, null);
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}