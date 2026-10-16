import 'package:flutter/material.dart';

//para funcionalidades aun no hechas (chat, boton comprobantes a agregar?)
class PlaceholderFuncionalidad extends StatelessWidget {
  final String? mensaje;

  const PlaceholderFuncionalidad({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              mensaje ?? 'Funcionalidad no disponible',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}