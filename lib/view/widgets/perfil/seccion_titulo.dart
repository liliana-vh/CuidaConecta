import 'package:flutter/material.dart';

//para cuidador
class SeccionTitulo extends StatelessWidget {
  final String titulo;
  final Color color;

  const SeccionTitulo({super.key, required this.titulo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        titulo,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}