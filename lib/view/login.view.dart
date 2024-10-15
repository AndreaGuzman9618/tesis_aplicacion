import 'package:flutter/material.dart';
import 'package:tesis_aplicacion/utils/global.colors.dart';
import 'package:tesis_aplicacion/view/widgets/text.form.global.dart';

class Login extends StatelessWidget {
    const Login({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text('Logo',
                        style: TextStyle(
                          color: GlobalColors.mainColor,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                    ),
                    const SizedBox(height:50),
                    Text('Iniciar sesión',
                      style: TextStyle(
                        color: GlobalColors.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      )
                    ),   
                    const SizedBox(height:15),
                    TextFormGlobal(),
                ]
              )
            ),
          ),
        ),
      );
    }

}