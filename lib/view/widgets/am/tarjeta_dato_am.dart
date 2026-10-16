import 'package:flutter/material.dart';

class TarjetaDatoAM extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final VoidCallback? onEditar;

  const TarjetaDatoAM({
    super.key,
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 32, color: const Color(0xFFE51B23)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(valor.isEmpty ? '—' : valor, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
          ),
          if (onEditar != null)
            IconButton(icon: const Icon(Icons.edit, size: 28, color: Colors.black54), onPressed: onEditar),
        ],
      ),
    );
  }
}