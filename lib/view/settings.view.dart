import 'package:flutter/material.dart';
import 'package:tesis_aplicacion/utils/global.colors.dart';
import 'package:get/get.dart';
import 'package:tesis_aplicacion/utils/shared_preferences_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuración"),
        backgroundColor: GlobalColors.mainColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsOption(
            context,
            "Modo Oscuro",
            "Activa o desactiva el modo oscuro para la aplicación.",
            Icons.dark_mode,
            onTap: () {
              // Lógica para activar o desactivar modo oscuro
            },
          ),
          _buildSettingsOption(
            context,
            "Tamaño del Texto",
            "Ajusta el tamaño del texto para mejor accesibilidad.",
            Icons.text_fields,
            onTap: () {
              // Navegar a pantalla para ajustar tamaño de texto
            },
          ),
          _buildSettingsOption(
            context,
            "Sincronización con Calendario",
            "Conecta tu calendario para gestionar recordatorios automáticos.",
            Icons.calendar_today,
            onTap: () {
              // Navegar a configuración de sincronización
            },
          ),
          _buildSettingsOption(
            context,
            "Notificaciones",
            "Configura las notificaciones de la aplicación.",
            Icons.notifications,
            onTap: () {
              // Navegar a configuración de notificaciones
            },
          ),
          _buildSettingsOption(
            context,
            "Privacidad y Seguridad",
            "Administra tus datos y preferencias de privacidad.",
            Icons.lock,
            onTap: () {
              // Navegar a configuración de privacidad
            },
          ),
          _buildSettingsOption(
            context,
            "Ayuda y Soporte",
            "Obtén asistencia en caso de problemas o dudas.",
            Icons.help,
            onTap: () {
              // Navegar a página de ayuda
            },
          ),
          _buildSettingsOption(
            context,
            "Evaluar Aplicación",
            "Califica la aplicación y déjanos tu opinión.",
            Icons.star_rate,
            onTap: () async {
              int? userId = await SharedPreferencesHelper
                  .getUserId(); // Usar la función desde el helper
              if (userId != null) {
                // Si el ID existe, navegar al perfil
                Get.toNamed('/evaluations', arguments: userId);
              } else {
                // Manejar el caso donde no se encuentra el ID
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ID de usuario no encontrado')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption(
    BuildContext context,
    String titulo,
    String descripcion,
    IconData icono, {
    required VoidCallback onTap,
  }) {
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
        onTap: onTap,
      ),
    );
  }
}
