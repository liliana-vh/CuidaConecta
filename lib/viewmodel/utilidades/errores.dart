import 'package:flutter/material.dart';

//para centralizar errores antes de entrega final proyecto RECORDAR
void mostrarError(BuildContext context, Object e) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(e.toString().replaceAll('Exception: ', '')),
      backgroundColor: Colors.red,
    ),
  );
}

Future<bool> ejecutarAccion(
  BuildContext context,
  Future<void> Function() accion,
) async {
  try {
    await accion();
    return true;
  } catch (e) {
    if (context.mounted) mostrarError(context, e);
    return false;
  }
}