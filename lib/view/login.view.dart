import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tesis_aplicacion/utils/global.colors.dart';
import 'package:tesis_aplicacion/utils/global.config.dart';
import 'package:tesis_aplicacion/view/widgets/text.form.global.dart';
import 'package:tesis_aplicacion/view/widgets/button.global.dart';
import 'package:tesis_aplicacion/view/register.view.dart';
import 'package:tesis_aplicacion/view/forgotpassword.view.dart';
import 'package:tesis_aplicacion/view/home.view.dart';
import 'package:tesis_aplicacion/utils/apiURL.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// Función para guardar el ID del usuario
  Future<void> saveUserId(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

// Recuperar el ID del usuario
  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> loginUser({
    required BuildContext context,
    required String cedula,
    required String password,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/login'); // Usa baseUrl aquí

    if (cedula.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor, completa todos los campos."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'cedula': cedula,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        await saveUserId(data['data']['id_usuario']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Inicio de sesión exitoso."),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        final errorMessage = json.decode(response.body)['message'] ??
            'Credenciales incorrectas.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $errorMessage"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error en la conexión: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo en la parte superior
                    SizedBox(
                      child: Image.asset(
                        'assets/images/logo_msp.png',
                        height: 250, // Ajusta la altura de la imagen
                        width: 250, // Ajusta el ancho de la imagen
                        fit: BoxFit.contain,
                      ),
                    ),
                    //Config.spaceSmall,
                    SizedBox(height: 10),
                    // Formulario
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormGlobal(
                            controller: cedulaController,
                            text: 'Cédula',
                            obscure: false,
                            textInputType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu cédula';
                              }
                              if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                return 'Por favor ingresa una cédula válido';
                              }
                              return null;
                            },
                          ),
                          Config.spaceSmall,
                          TextFormGlobal(
                            controller: passwordController,
                            text: 'Contraseña',
                            obscure: true,
                            textInputType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen()),
                                );
                              },
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: GlobalColors.mainColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          Config.spaceMedium,
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              label: 'Iniciar sesión',
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  loginUser(
                                    context: context,
                                    cedula: cedulaController.text.trim(),
                                    password: passwordController.text.trim(),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Config.spaceMedium,

                    // Botón de registro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "¿No tienes una cuenta?",
                          style: TextStyle(fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()),
                            );
                          },
                          child: Text(
                            'Regístrate aquí',
                            style: TextStyle(
                              color: GlobalColors.mainColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Config.spaceSmall,

                    // Imagen inferior
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 25), // Espaciado inferior
                      child: SizedBox(
                        child: Image.asset(
                          'assets/images/LogoGobierno.png',
                          height: 200, // Ajusta la altura deseada
                          width: 200, // Ajusta el ancho deseado
                          fit: BoxFit.contain,
                        ),
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
