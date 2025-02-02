import 'package:flutter/material.dart';
import 'package:tesis_aplicacion/utils/global.colors.dart';
import 'package:tesis_aplicacion/utils/global.config.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  CustomButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: GlobalColors.mainColor, // Color de fondo del botón
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Bordes redondeados
        ),
        elevation: 5, // Sombra opcional para profundidad
      ),
      child: Text(
        label,
        style: Config.standardTextStyle.copyWith(
          fontSize: 16,
          color: Colors.white, // Color del texto del botón
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
