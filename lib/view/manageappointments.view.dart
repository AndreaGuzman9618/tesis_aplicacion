import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:tesis_aplicacion/utils/global.colors.dart'; // Archivo de colores globales
import 'package:tesis_aplicacion/view/appointment.view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tesis_aplicacion/utils/apiURL.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GestionCitasPage extends StatefulWidget {
  final int userId;

  GestionCitasPage({required this.userId});

  @override
  _GestionCitasPageState createState() => _GestionCitasPageState();
}

class _GestionCitasPageState extends State<GestionCitasPage> {
  List<Map<String, dynamic>> _citas = [];

  List<Map<String, dynamic>> _fechasDisponibles = [];
  List<String> _horariosDisponibles = [];
  String? _selectedFecha;
  String? _selectedHorario;

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('es_ES', null).then((_) {
      _fetchCitasProgramadas();
    });
  }

  void _agendarCita() {
    Get.to(() =>
        AgendarCitaPage(userId: widget.userId)); // Asegurar que se pasa userId
  }

  Future<void> _fetchCitasProgramadas() async {
    try {
      final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/citas/programadas/${widget.userId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _citas = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print("Error al cargar citas");
        _showSnackbar(context, 'Error al cargar citas', 'error');
      }
    } catch (e) {
      print("Error de conexión al cargar citas");
      _showSnackbar(context, 'Error de conexión al cargar citas"', 'error');
    }
  }

  Future<void> _cancelarCita(int citaId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/citas/cancelar/$citaId'),
      );

      if (response.statusCode == 200) {
        // Remover la cita cancelada de la lista actual
        setState(() {
          _citas.removeWhere((cita) => cita['id_cita'] == citaId);
        });

        // Mostrar Snackbar de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cita cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Recargar la lista de citas desde el servidor
        await _fetchCitasProgramadas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar la cita'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión al cancelar la cita'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

  void _reagendarCita(int idCita, String especialidad, int idCentro,
      int idEspecialidad, String centro) async {
    await _fetchFechasDisponibles(idCentro,
        idEspecialidad); // Asegura que se carguen las fechas antes de abrir el diálogo

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Reagendar Cita"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Especialidad: $especialidad",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Centro de salud: $centro",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text("Fechas disponibles:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _fechasDisponibles.isEmpty
                      ? Text("No hay fechas disponibles",
                          style: TextStyle(color: Colors.red))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _fechasDisponibles.map((fecha) {
                            return ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _selectedFecha = fecha['fecha'];
                                });

                                // Llama al método para obtener horarios disponibles
                                await _fetchHorariosDisponibles(
                                    idCentro, idEspecialidad, _selectedFecha!);

                                setState(() {
                                  print(
                                      "Horarios actualizados: $_horariosDisponibles");
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _selectedFecha == fecha['fecha']
                                        ? GlobalColors.mainColor
                                        : Colors.grey[300],
                                foregroundColor:
                                    _selectedFecha == fecha['fecha']
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
                  Text("Horarios disponibles:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedFecha != null && _selectedHorario != null) {
                      await _confirmarReagendamiento(
                          idCita, _selectedFecha!, _selectedHorario!);
                      Navigator.pop(context); // Close the modal
                    } else {
                      _showSnackbar(
                          context, "Selecciona una fecha y horario", "error");
                    }
                  },
                  child: Text("Confirmar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarReagendamiento(
      int idCita, String fecha, String hora) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/citas/reagendar'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_cita": idCita,
          "nueva_fecha": fecha,
          "nueva_hora": hora,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackbar(context, 'Cita reagendada con éxito', 'success');
        await _fetchCitasProgramadas(); // Actualizar la lista de citas
      } else {
        _showSnackbar(context, 'Error al reagendar la cita', 'error');
      }
    } catch (e) {
      _showSnackbar(context, 'Error de conexión al reagendar la cita', 'error');
    }
  }

  Future<void> _fetchFechasDisponibles(int centroId, int especialidadId) async {
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

        //print("Fechas disponibles: $_fechasDisponibles");
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

        print("Horarios disponibles actualizados: $_horariosDisponibles");
      } else {
        _showSnackbar(
            context, 'No hay horarios disponibles para esta fecha', 'info');
      }
    } catch (e) {
      _showSnackbar(
          context, 'Error de conexión al cargar los horarios', 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de Citas Médicas',
          style: TextStyle(color: Colors.white), // Texto en color blanco
        ),
        backgroundColor: GlobalColors.mainColor, // Azul del logo
        iconTheme: IconThemeData(
            color: Colors
                .white), // Si necesitas que los íconos del AppBar también sean blancos
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _agendarCita,
              child: Text('Agendar Nueva Cita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalColors.borderColor, // Amarillo del logo
                foregroundColor: Colors.white, // Texto en color blanco
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Citas Programadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GlobalColors.focusColor, // Rojo del logo
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _citas.length,
                itemBuilder: (context, index) {
                  final cita = _citas[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        '${cita['especialidad']}',
                        style: TextStyle(color: GlobalColors.textColor),
                      ),
                      subtitle: Text(
                        cita['fecha_cita'] != null && cita['hora_cita'] != null
                            ? '${DateFormat.yMMMMd('es_ES').format(DateTime.parse(cita['fecha_cita']))} a las ${cita['hora_cita'].substring(0, 5)}'
                            : 'Fecha no disponible',
                        style: TextStyle(
                            color: GlobalColors.textColor.withOpacity(0.6)),
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          int citaId =
                              int.tryParse(cita['id_cita'].toString()) ?? 0;

                          if (value == 'reagendar') {
                            _reagendarCita(
                                citaId,
                                cita['especialidad'],
                                int.tryParse(cita['id_centro'].toString()) ?? 0,
                                int.tryParse(
                                        cita['id_especialidad'].toString()) ??
                                    0,
                                cita['centro']);
                          } else if (value == 'cancelar') {
                            _cancelarCita(citaId);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'reagendar',
                            child: Text('Reagendar'),
                          ),
                          PopupMenuItem(
                            value: 'cancelar',
                            child: Text('Cancelar'),
                          ),
                        ],
                      ),
                      leading: Icon(
                        cita['id_estado'] == 2
                            ? Icons.check_circle
                            : Icons.pending_actions,
                        color: cita['id_estado'] == 2
                            ? Colors.green
                            : GlobalColors.focusColor, // Rojo para pendientes
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
