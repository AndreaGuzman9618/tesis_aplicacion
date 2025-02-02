import 'package:flutter/material.dart';
import 'package:tesis_aplicacion/utils/global.colors.dart';

class Config {
  static MediaQueryData? mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;

  // Inicialización de width y height
  void init(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData!.size.width;
    screenHeight = mediaQueryData!.size.height;
  }

  static get widthSize {
    return screenWidth;
  }

  static get heightSize {
    return screenHeight;
  }

  // Margen estándar
  static const EdgeInsets standardPadding = EdgeInsets.all(15.0);

  // Tipografía estándar
  static TextStyle standardTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: GlobalColors.textColor,
  );

  // Espaciados comunes
  static const spaceSmall = SizedBox(height: 25);
  static const spaceMedium = SizedBox(height: 50);
  static const spaceBig = SizedBox(height: 70);

  // Bordes comunes (sin `const` aquí)
  static OutlineInputBorder outlinedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: GlobalColors.borderColor),
  );

  static OutlineInputBorder focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: GlobalColors.focusColor),
  );

  static OutlineInputBorder errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: GlobalColors.errorColor),
  );
}
