import 'package:flutter/material.dart';

//test widget manejo de error, o mejor solo una utilidad en vm o repo?
class TextoErrorPerfil extends StatelessWidget {
  final String? mensaje;

  const TextoErrorPerfil({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    if (mensaje == null || mensaje!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Text(
        mensaje!,
        style: const TextStyle(color: Color(0xFFE51B23), fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}