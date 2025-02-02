import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tesis_aplicacion/utils/global.colors.dart';
import 'package:tesis_aplicacion/utils/apiURL.dart';
import 'package:tesis_aplicacion/view/manageappointments.view.dart';

class AgendarCitaPage extends StatefulWidget {
  final int userId; // Receive userId

  AgendarCitaPage({required this.userId});

  @override
  _AgendarCitaPageState createState() => _AgendarCitaPageState();
}

class _AgendarCitaPageState extends State<AgendarCitaPage> {
  late int userId;
  int? _selectedEspecialidad;
  int? _selectedCentroId;
  String? _selectedFecha;
  String? _selectedHorario;

  List<Map<String, dynamic>> _especialidades = [];
  List<Map<String, dynamic>> _centrosSalud = [];
  List<Map<String, dynamic>> _fechasDisponibles = [];
  List<String> _horariosDisponibles = [];
  List<int> _especialidadesReservadas = [];

  @override
  void initState() {
    super.initState();
    userId = widget.userId;

    initializeDateFormatting('es_ES', null).then((_) {
      _fetchEspecialidades();
    });

    _fetchEspecialidadesReservadas();
  }

  // Cargar especialidades desde el backend
  Future<void> _fetchEspecialidades() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/citas/especialidades'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _especialidades = List<Map<String, dynamic>>.from(data.map((e) => {
                'id_especialidad':
                    int.tryParse(e['id_especialidad'].toString()) ?? 0,
                'nombre': e['nombre'],
              }));
        });
      } else {
        _showSnackbar(context, 'Error al cargar las especialidades', 'error');
      }
    } catch (e) {
      _showSnackbar(
          context, 'Error de conexión al cargar las especialidades', 'error');
    }
  }

  void _seleccionarEspecialidad(int especialidadId) {
    if (_especialidadesReservadas.contains(especialidadId)) {
      _mostrarMensaje('Ya tienes una cita programada para esta especialidad.');
      return;
    }
    setState(() {
      _selectedEspecialidad = especialidadId;
      _fetchCentros(especialidadId);
    });
  }

  // Cargar centros de salud según la especialidad seleccionada
  Future<void> _fetchCentros(int especialidadId) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/citas/centros/$especialidadId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _centrosSalud = List<Map<String, dynamic>>.from(data.map((e) => {
                'id_centro': int.tryParse(e['id_centro'].toString()) ?? 0,
                'nombre': e['nombre'],
              }));
        });

        if (_centrosSalud.isEmpty) {
          _showSnackbar(
              context, 'No hay centros de salud disponibles.', 'info');
        }
      } else {
        _showSnackbar(context, 'Error al cargar los centros de salud', 'error');
      }
    } catch (e) {
      _showSnackbar(
          context, 'Error de conexión al cargar los centros de salud', 'error');
    }
  }

  Future<void> _fetchFechas(int centroId, int especialidadId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/citas/fechas/$centroId/$especialidadId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          // Clear previous selections
          _selectedFecha = null;
          _horariosDisponibles.clear();

          // Parse and update available dates
          _fechasDisponibles = List<Map<String, dynamic>>.from(
            data.map((e) => {
                  'fecha': e['fecha'],
                  'horarios': List<String>.from(e['horarios'] ?? []),
                }),
          ).where((e) => e['horarios'].isNotEmpty).toList();
        });

        print("Fechas disponibles: $_fechasDisponibles");
      } else {
        _showSnackbar(
            context, 'No hay fechas disponibles para este centro', 'info');
      }
    } catch (e) {
      _showSnackbar(context,
          'Error de conexión al cargar las fechas disponibles', 'error');
    }
  }

  Future<void> _fetchHorariosDisponibles(
      int centroId, int especialidadId, String fechaSeleccionada) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/citas/horarios/$centroId/$especialidadId/$fechaSeleccionada'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];

        setState(() {
          _horariosDisponibles = List<String>.from(data);
        });

        print("Horarios disponibles: $_horariosDisponibles");
      } else {
        _showSnackbar(
            context, 'No hay horarios disponibles para esta fecha', 'info');
      }
    } catch (e) {
      _showSnackbar(
          context, 'Error de conexión al cargar los horarios', 'error');
    }
  }

  Future<void> _fetchEspecialidadesReservadas() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/citas/especialidades_reservadas/${userId}'),
      );

      print('userId: $userId');

      if (response.statusCode == 200) {
        print("Response Status: ${response.statusCode}");
        print("Response Body: ${response.body}");

        final data = json.decode(response.body)['data'];
      } else {
        print(
            "Error al cargar especialidades reservadas. Status: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      // Log the error message and stack trace for detailed debugging
      print("Error de conexión al cargar especialidades reservadas: $e");
      print("StackTrace: $stackTrace");
    }
  }

  Future<void> _reservarCita() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/citas/reservar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_usuario': userId, // Reemplazar con el ID real del usuario
          'id_centro': _selectedCentroId,
          'id_especialidad': _selectedEspecialidad,
          'fecha_cita': _selectedFecha,
          'hora_cita': _selectedHorario,
          'id_estado': '1',
        }),
      );

      if (response.statusCode == 201) {
        _showSnackbar(context, 'Cita agendada correctamente', 'success');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => GestionCitasPage(
                  userId: userId)), // Cambia HomeScreen a tu pantalla de inicio
        );
      } else {
        _showSnackbar(context, 'Error al agendar la cita', 'error');
      }
    } catch (e) {
      _showSnackbar(context, 'Error de conexión al reservar la cita', 'error');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Mostrar mensaje de error
  void _showSnackbar(BuildContext context, String message, String type) {
    Color backgroundColor;

    switch (type) {
      case 'success': // Éxito - Verde
        backgroundColor = Colors.green;
        break;
      case 'error': // Error - Rojo
        backgroundColor = Colors.red;
        break;
      case 'info': // Información - Azul
        backgroundColor = Colors.blue;
        break;
      default:
        backgroundColor = Colors.grey; // Color por defecto
    }

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nueva Cita", style: TextStyle(color: Colors.white)),
        backgroundColor: GlobalColors.mainColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                decoration:
                    InputDecoration(labelText: "Selecciona un servicio"),
                items:
                    _especialidades.map<DropdownMenuItem<int>>((especialidad) {
                  bool estaReservada = _especialidadesReservadas
                      .contains(especialidad['id_especialidad']);

                  return DropdownMenuItem<int>(
                    value:
                        estaReservada ? null : especialidad['id_especialidad'],
                    child: Text(
                      especialidad['nombre'],
                      style: TextStyle(
                        color: estaReservada
                            ? Colors.grey
                            : Colors.black, // Especialidades reservadas en gris
                      ),
                    ),
                    enabled: !estaReservada, // Deshabilitar la selección
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedEspecialidad = value;
                      _fetchCentros(value);
                      _selectedCentroId = null;
                      _centrosSalud.clear();
                      _fechasDisponibles.clear();
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                    labelText: "Selecciona un establecimiento de salud"),
                items: _centrosSalud
                    .map<DropdownMenuItem<int>>(
                        (centro) => DropdownMenuItem<int>(
                              value: centro['id_centro'],
                              child: Text(centro['nombre']),
                            ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCentroId = value;
                    print("Centro de salud seleccionado: $_selectedCentroId");
                    _fetchFechas(_selectedCentroId!, _selectedEspecialidad!);
                  });
                },
              ),
              SizedBox(height: 16),
              Text("Fechas disponibles:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _fechasDisponibles.isEmpty
                  ? Text("No hay fechas disponibles",
                      style: TextStyle(color: Colors.red))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _fechasDisponibles.map((fecha) {
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedFecha = fecha['fecha'];
                              _horariosDisponibles =
                                  fecha['horarios']; // Cargar horarios locales

                              print("Fecha seleccionada: $_selectedFecha");

                              _fetchHorariosDisponibles(_selectedCentroId!,
                                  _selectedEspecialidad!, _selectedFecha!);

                              print(
                                  "Horarios disponibles: $_horariosDisponibles");
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedFecha == fecha['fecha']
                                ? GlobalColors.mainColor
                                : Colors.grey[300],
                            foregroundColor: _selectedFecha == fecha['fecha']
                                ? Colors.white
                                : Colors.black,
                          ),
                          child: Text(
                            DateFormat('EEEE, d MMM', 'es_ES')
                                .format(DateTime.parse(fecha['fecha'])),
                          ),
                        );
                      }).toList(),
                    ),
              SizedBox(height: 16),

              // Mostrar horarios disponibles cuando el usuario selecciona una fecha
              Text("Horarios disponibles:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _horariosDisponibles.isEmpty
                  ? Text("Selecciona una fecha para ver horarios",
                      style: TextStyle(color: Colors.grey))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _horariosDisponibles.map((horario) {
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedHorario = horario;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedHorario == horario
                                ? GlobalColors.mainColor
                                : Colors.grey[300],
                            foregroundColor: _selectedHorario == horario
                                ? Colors.white
                                : Colors.black,
                          ),
                          child: Text(horario),
                        );
                      }).toList(),
                    ),
              SizedBox(height: 32),
// Agregar botones en fila
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Espacio entre los botones
                children: [
                  // Botón Cancelar
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cierra la pantalla o modal
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    child: Text("Cancelar"),
                  ),
                  // Botón Confirmar
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedEspecialidad != null &&
                          _selectedCentroId != null &&
                          _selectedFecha != null &&
                          _selectedHorario != null) {
                        _reservarCita();
                      } else {
                        _showSnackbar(context,
                            'Por favor, completa todos los campos', 'error');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalColors.mainColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Confirmar Cita"),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Add the note at the bottom
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  "Nota: Las especialidades con citas programadas no están habilitadas para seleccionar.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
