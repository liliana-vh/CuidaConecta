import 'package:flutter/material.dart';

// Campo de texto de solo lectura con teclado numerico
class CampoTecladoAM extends StatelessWidget {
  final TextEditingController controller;
  final String? etiqueta;
  final IconData? icono;
  final String? prefijo;
  final String? hintText;

  final bool resaltado;
  final bool mostrarCursor;
  final VoidCallback? onTap;
  final TextAlign textAlign;
  final String? Function(String?)? validator;

  const CampoTecladoAM({
    super.key,
    required this.controller,
    this.etiqueta,
    this.icono,
    this.prefijo,
    this.hintText,
    this.resaltado = false,
    this.mostrarCursor = true,
    this.onTap,
    this.textAlign = TextAlign.start,
    this.validator,
  });

  static const Color _rojo = Color(0xFFE51B23);

  @override
  Widget build(BuildContext context) {
    final campo = TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      showCursor: mostrarCursor,
      textAlign: textAlign,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        prefixIcon: icono != null ? Icon(icono, size: 22) : null,
        prefixText: prefijo,
        hintText: hintText,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: resaltado ? _rojo : Colors.grey,
            width: resaltado ? 3 : 1,
          ),
        ),
      ),
      validator: validator,
    );

    if (etiqueta == null) return campo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        campo,
      ],
    );
  }
}
