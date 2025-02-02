import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:tesis_aplicacion/utils/global.colors.dart';
import 'package:tesis_aplicacion/view/login.view.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {

    Timer(const Duration(seconds: 1), () {
      Get.to(() => Login()); // Usar el constructor correcto
    });

    return Scaffold(
      backgroundColor: Color(0xFF4A90E2), // Aplicar opacidad o un azul derivado
      body: Center(
          child: Image.asset(
          'assets/images/logo_msp.png', // Ruta de la imagen
          width: 350,  // Ajusta el tamaño según sea necesario
          height: 350, // Ajusta el tamaño según sea necesario
        ),
      ),
    );
  }
}
