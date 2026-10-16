import 'package:flutter/material.dart';

// Dialogo simple para elegir comuna
Future<String?> mostrarDialogoComunaAM(
  BuildContext context, {
  required List<String> opciones,
  required String? actual,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: const Text('Seleccione su comuna', style: TextStyle(fontSize: 20)),
      children: opciones.map((comuna) {
        return SimpleDialogOption(
          onPressed: () => Navigator.pop(dialogContext, comuna),
          child: Row(
            children: [
              Icon(
                comuna == actual ? Icons.check_circle : Icons.circle_outlined,
                color: comuna == actual ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 10),
              Text(comuna, style: const TextStyle(fontSize: 20)),
            ],
          ),
        );
      }).toList(),
    ),
  );
}