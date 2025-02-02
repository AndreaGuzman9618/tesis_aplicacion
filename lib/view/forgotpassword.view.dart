import 'package:flutter/material.dart';
import 'package:tesis_aplicacion/utils/global.config.dart';
import 'package:tesis_aplicacion/utils/global.colors.dart';
import 'package:tesis_aplicacion/view/widgets/button.global.dart';
import 'package:tesis_aplicacion/view/widgets/text.form.global.dart';
import 'package:get/get.dart';


class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController cedulaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // GlobalKey para el formulario

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: Config.standardPadding,
              child: Form(
                key: _formKey, // Asociar el key al formulario
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Título
                    Text(
                      'Olvidé mi Contraseña',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: GlobalColors.mainColor,
                      ),
                    ),
                    Config.spaceMedium,

                    // Descripción
                    Text(
                      'Ingresa tu número de cédula. Verificaremos que exista y luego podrás restablecer tu contraseña.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: GlobalColors.textColor),
                    ),
                    Config.spaceMedium,

                    // Input de Cédula
                    TextFormGlobal(
                      controller: cedulaController,
                      text: 'Cédula',
                      obscure: false,
                      textInputType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu número de cédula';
                        }
                        if (value.length != 10) {
                          return 'La cédula debe tener exactamente 10 caracteres';
                        }
                        return null;
                      },
                    ),
                    Config.spaceMedium,

                    // Botón de Verificar
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label: 'Recuperación de contraseña',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Si la validación pasa
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Recuperación de contraseña'),
                                content: Text('Se ha enviado una notificación al correo registrado.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Get.offNamed('/login');
                                    },
                                    child: Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Si la validación falla, el mensaje ya lo maneja el validator
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
