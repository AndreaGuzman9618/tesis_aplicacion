import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tesis_aplicacion/utils/global.colors.dart';
import 'package:tesis_aplicacion/utils/shared_preferences_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    await SharedPreferencesHelper
        .clearUserSession(); // Eliminar datos de sesión
    Get.offAllNamed('/login'); // Redirigir al login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inicio',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: GlobalColors.mainColor,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Bienvenido!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Botones de acción principales
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Número de botones por fila
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionButton(
                    icon: Icons.calendar_today,
                    label: 'Mis Citas',
                    onTap: () async {
                      int? userId = await SharedPreferencesHelper
                          .getUserId(); // Usar la función desde el helper
                      if (userId != null) {
                        // Si el ID existe, navegar al perfil
                        Get.toNamed('/appointments', arguments: userId);
                      } else {
                        // Manejar el caso donde no se encuentra el ID
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error: ID de usuario no encontrado')),
                        );
                      }
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.person,
                    label: 'Perfil',
                    onTap: () async {
                      int? userId = await SharedPreferencesHelper
                          .getUserId(); // Usar la función desde el helper
                      if (userId != null) {
                        // Si el ID existe, navegar al perfil
                        Get.toNamed('/profile', arguments: userId);
                      } else {
                        // Manejar el caso donde no se encuentra el ID
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error: ID de usuario no encontrado')),
                        );
                      }
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.notifications,
                    label: 'Notificaciones',
                    onTap: () async {
                      int? userId = await SharedPreferencesHelper
                          .getUserId(); // Usar la función desde el helper
                      if (userId != null) {
                        // Si el ID existe, navegar al perfil
                        Get.toNamed('/notifications', arguments: userId);
                      } else {
                        // Manejar el caso donde no se encuentra el ID
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error: ID de usuario no encontrado')),
                        );
                      }
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.settings,
                    label: 'Configuración',
                    onTap: () => Get.toNamed('/settings'),
                  ),
                  _buildActionButton(
                    icon: Icons.star_rate,
                    label: 'Evaluar App',
                    onTap: () async {
                      int? userId = await SharedPreferencesHelper
                          .getUserId(); // Usar la función desde el helper
                      if (userId != null) {
                        // Si el ID existe, navegar al perfil
                        Get.toNamed('/evaluations', arguments: userId);
                      } else {
                        // Manejar el caso donde no se encuentra el ID
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error: ID de usuario no encontrado')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: GlobalColors.mainColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Get.toNamed('/home');
              break;
            case 1:
              Get.toNamed('/appointments');
              break;
            case 2:
              Get.toNamed('/settings');
              break;
          }
        },
      ),
    );
  }

  // Widget para los botones de acción
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: GlobalColors.mainColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
