import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tesis_aplicacion/view/splash.view.dart';
import 'package:tesis_aplicacion/view/login.view.dart';
import 'package:tesis_aplicacion/view/forgotpassword.view.dart';
import 'package:tesis_aplicacion/view/manageappointments.view.dart';
import 'package:tesis_aplicacion/view/profile.view.dart';
import 'package:tesis_aplicacion/view/notifcations.view.dart';
import 'package:tesis_aplicacion/view/settings.view.dart';

void main() {
  runApp(const App());
}

// Función para obtener el ID del usuario desde SharedPreferences
Future<int?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userId');
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashView(),
      getPages: [
        GetPage(name: '/splash', page: () => SplashView()),
        GetPage(name: '/login', page: () => Login()),
        GetPage(name: '/forgot_password', page: () => ForgotPasswordScreen()),
        GetPage(
          name: '/appointments',
          page: () {
            print("Arguments received: ${Get.arguments}");
            final userId1 = Get.arguments as int?;
            if (userId1 == null) {
              throw Exception("ID del usuario no encontrado");
            }
            return GestionCitasPage(userId: userId1);
          },
        ),
        GetPage(name: '/notifications', page: () => NotificacionesPage()),
        GetPage(name: '/settings', page: () => SettingsPage()),
        GetPage(
          name: '/profile',
          page: () {
            final userId = Get.arguments as int?;
            if (userId == null) {
              throw Exception("ID del usuario no encontrado");
            }
            return PerfilPage(userId: userId);
          },
        ),
      ],
    );
  }
}
