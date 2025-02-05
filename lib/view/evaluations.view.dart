import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tesis_aplicacion/utils/apiURL.dart';

class EvaluacionesPage extends StatefulWidget {
  final int userId;

  EvaluacionesPage({required this.userId});

  @override
  _EvaluacionesPageState createState() => _EvaluacionesPageState();
}

class _EvaluacionesPageState extends State<EvaluacionesPage> {
  int _rating = 0;
  TextEditingController _commentController = TextEditingController();

  Future<void> _submitEvaluation() async {
    if (_rating == 0) {
      _showSnackbar("Por favor, selecciona una calificación.", "error");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/evaluaciones/guardar'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_usuario": widget.userId,
          "calificacion": _rating,
          "comentario": _commentController.text,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackbar("¡Gracias por tu evaluación!", "success");
        setState(() {
          _rating = 0;
          _commentController.clear();
        });
      } else {
        _showSnackbar("Error al enviar la evaluación.", "error");
      }
    } catch (e) {
      _showSnackbar("Error de conexión.", "error");
    }
  }

  void _showSnackbar(String message, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: type == "success" ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Evaluación de la Aplicación")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Califica nuestra aplicación:"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: index < _rating ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Escribe un comentario (opcional)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton(
                  onPressed: _submitEvaluation,
                  child: Text("Enviar Evaluación"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
