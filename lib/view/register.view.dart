import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tesis_aplicacion/utils/global.config.dart';
import 'package:tesis_aplicacion/utils/global.colors.dart';
import 'package:tesis_aplicacion/view/widgets/button.global.dart';
import 'package:tesis_aplicacion/view/widgets/text.form.global.dart';
import 'package:tesis_aplicacion/view/login.view.dart';
import 'package:tesis_aplicacion/utils/apiURL.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  LatLng? selectedLocation;
  bool _acceptedTerms = false;

  void _openMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
    if (result != null && result is Map) {
      setState(() {
        selectedLocation = result['location'];
        addressController.text = result['address'] ?? "Dirección no encontrada";
      });
    }
  }

  Future<void> registerUser({
    required BuildContext context,
    required String cedula,
    required String nombres,
    required String email,
    required String password,
    required String repeatPassword,
    required String direccion,
    required String telefono,
    required bool acceptedTerms,
    LatLng? selectedLocation,
  }) async {
    print("Iniciando registro de usuario...");

    // Validación de contraseñas
    if (password != repeatPassword) {
      print("Error: Las contraseñas no coinciden");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Las contraseñas no coinciden"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validación de términos y condiciones
    if (!acceptedTerms) {
      print("Error: No aceptó los términos y condiciones");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Debe aceptar los términos y condiciones."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("Preparando datos para el backend...");
    // Crear un objeto para enviar al backend
    final Map<String, dynamic> requestBody = {
      'nombre': nombres,
      'email': email,
      'password': password,
      'telefono': telefono,
      'cedula': cedula,
      'direccion': direccion,
      'coordenadas_lat': selectedLocation?.latitude,
      'coordenadas_lon': selectedLocation?.longitude,
      'id_rol': '1',
    };

    // Usar la URL correcta según el entorno
    final Uri url;
    url = Uri.parse('${ApiConfig.baseUrl}/register');

    print("Enviando solicitud a $url...");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print("Código de respuesta: ${response.statusCode}");

      if (response.statusCode == 201) {
        print("Usuario registrado con éxito");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Usuario registrado con éxito."),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Login()), // Cambia HomeScreen a tu pantalla de inicio
        );
      } else {
        final errorMessage =
            json.decode(response.body)['message'] ?? 'Error desconocido';
        print("Error: $errorMessage");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $errorMessage"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error en la solicitud: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error en la solicitud: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: Config.standardPadding,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo_msp.png',
                  width: 256,
                  height: 74.5,
                ),
                Config.spaceMedium,
                Column(
                  children: [
                    TextFormGlobal(
                      controller: cedulaController,
                      text: 'Cédula',
                      obscure: false,
                      textInputType: TextInputType.number,
                    ),
                    Config.spaceSmall,
                    TextFormGlobal(
                      controller: nombresController,
                      text: 'Nombres',
                      obscure: false,
                      textInputType: TextInputType.text,
                    ),
                    Config.spaceSmall,
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.map, color: GlobalColors.mainColor),
                          onPressed: _openMap,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    Config.spaceSmall,
                    TextFormGlobal(
                      controller: emailController,
                      text: 'Email',
                      obscure: false,
                      textInputType: TextInputType.emailAddress,
                    ),
                    Config.spaceSmall,
                    TextFormGlobal(
                      controller: telefonoController,
                      text: 'Teléfono',
                      obscure: false,
                      textInputType: TextInputType.text,
                    ),
                    Config.spaceSmall,
                    TextFormGlobal(
                      controller: passwordController,
                      text: 'Contraseña',
                      obscure: true,
                      textInputType: TextInputType.text,
                    ),
                    Config.spaceSmall,
                    TextFormGlobal(
                      controller: repeatPasswordController,
                      text: 'Repetir Contraseña',
                      obscure: true,
                      textInputType: TextInputType.text,
                    ),
                    Config.spaceSmall,
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (bool? value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Acepto los términos y condiciones.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    Config.spaceSmall,
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label: 'Registrarse',
                        onPressed: () {
                          // Recoger los datos del formulario
                          String cedula = cedulaController.text;
                          String nombres = nombresController.text;
                          String email = emailController.text;
                          String password = passwordController.text;
                          String repeatPassword = repeatPasswordController.text;
                          String direccion = addressController.text;
                          String telefono = telefonoController.text;
                          bool acceptedTerms = _acceptedTerms;

                          // Llamar a la función registerUser
                          registerUser(
                            context: context,
                            cedula: cedula,
                            telefono: telefono,
                            nombres: nombres,
                            email: email,
                            password: password,
                            repeatPassword: repeatPassword,
                            direccion: direccion,
                            acceptedTerms: acceptedTerms,
                            selectedLocation: selectedLocation,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

  Future<String?> getAddressFromLatLng(
      double latitude, double longitude) async {
    const String apiKey =
        'AIzaSyBscbM7aq7pygWcvtSRPavGpBQfJkRFQv0'; // Reemplaza con tu clave de API
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
