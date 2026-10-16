import 'package:flutter/material.dart';

// Pide la contraseña actual antes de un cambio correo
Future<String?> mostrarDialogoContrasena(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirma tu contraseña'),
      content: TextField(
        controller: controller,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Contraseña actual'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
}