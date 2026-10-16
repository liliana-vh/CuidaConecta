import 'package:flutter/material.dart';
import '../../../viewmodel/utilidades/logica_rut.dart' as logica_rut;

class CampoRutFormateado extends StatelessWidget {
  final TextEditingController controller;
  final bool conValidator;

  const CampoRutFormateado({
    super.key,
    required this.controller,
    this.conValidator = true,
  });

  void _onChanged(String value) {
    final limpio = logica_rut.limpiarRut(value);
    if (limpio.length > 1) {
      final formateado = logica_rut.formatearRut(limpio);
      controller.value = TextEditingValue(
        text: formateado,
        selection: TextSelection.collapsed(offset: formateado.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'RUT',
        prefixIcon: Icon(Icons.badge_outlined),
        border: OutlineInputBorder(),
      ),
      onChanged: _onChanged,
      validator: conValidator
          ? (v) => (v == null || !logica_rut.validarRut(v)) ? 'RUT no válido' : null
          : null,
    );
  }
}