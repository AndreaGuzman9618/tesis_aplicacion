import 'package:flutter/material.dart';
import 'package:tesis_aplicacion/view/splash.view.dart';
import 'package:tesis_aplicacion/view/login.view.dart';
import 'package:get/get.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner : false,      
      home: Login(),
    );
  }
}