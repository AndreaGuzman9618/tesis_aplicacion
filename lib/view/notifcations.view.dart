import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tesis_aplicacion/utils/apiURL.dart';

class NotificacionesPage extends StatefulWidget {
  final int userId;
  const NotificacionesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  List<Map<String, dynamic>> _notificaciones = [];

  @override
  void initState() {
    super.initState();
    _fetchNotificaciones();
  }

  Future<void> _fetchNotificaciones() async {
    try {
      final response = await http.get(Uri.parse(
          '${ApiConfig.baseUrl}/notificaciones/usuario/${widget.userId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _notificaciones = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print("Error al cargar notificaciones");
      }
    } catch (e) {
      print("Error de conexión al cargar notificaciones");
    }
  }

  Future<void> _marcarComoLeida(int idNotificacion) async {
    await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones/leer/$idNotificacion'));
    _fetchNotificaciones();
  }

  Future<void> _eliminarNotificacion(int idNotificacion) async {
    await http.put(Uri.parse(
        '${ApiConfig.baseUrl}/notificaciones/eliminar/$idNotificacion'));
    _fetchNotificaciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notificaciones")),
      body: ListView.builder(
        itemCount: _notificaciones.length,
        itemBuilder: (context, index) {
          final notificacion = _notificaciones[index];
          return ListTile(
            title: Text(notificacion['titulo']),
            subtitle: Text(notificacion['descripcion']),
            trailing: IconButton(
              icon: Icon(Icons.check),
              onPressed: () =>
                  _marcarComoLeida(int.parse(notificacion['id_notificacion'])),
            ),
            onLongPress: () => _eliminarNotificacion(
                int.parse(notificacion['id_notificacion'])),
          );
        },
      ),
    );
  }
}
