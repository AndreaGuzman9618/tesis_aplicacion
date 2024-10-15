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
      Get.to(Login);
    });
    return Scaffold(
      backgroundColor: GlobalColors.mainColor,
      body: Center(
          child: Text('Logo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ))),
    );
  }
}
