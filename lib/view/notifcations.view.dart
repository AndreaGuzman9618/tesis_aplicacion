import 'package:flutter/material.dart';
import 'package:tesis_aplicacion/utils/global.colors.dart';

class NotificacionesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notificaciones"),
        backgroundColor: GlobalColors.mainColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNotificacionCard(
            context,
            "Recordatorio de Cita",
            "Tienes una cita programada para el 28 de noviembre a las 10:00 AM en el Centro de Salud Quitumbe.",
            Icons.calendar_today,
          ),
          _buildNotificacionCard(
            context,
            "Cita Reagendada",
            "Tu cita con el cardiólogo ha sido reagendada para el 30 de noviembre a las 11:00 AM.",
            Icons.update,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificacionCard(
    BuildContext context,
    String titulo,
    String descripcion,
    IconData icono,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icono, color: GlobalColors.mainColor, size: 40),
        title: Text(
          titulo,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: GlobalColors.textColor,
          ),
        ),
        subtitle: Text(
          descripcion,
          style: TextStyle(fontSize: 14, color: GlobalColors.textColor),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: GlobalColors.mainColor),
        onTap: () {
          // Acción al tocar la notificación
        },
      ),
    );
  }
}
