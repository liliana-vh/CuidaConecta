import 'package:flutter/material.dart';

class SeccionTitulo extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;

  const SeccionTitulo({
    super.key,
    required this.titulo,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icono, color: color),
          const SizedBox(width: 10),
          Text(
            titulo,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String etiqueta;
  final String? valor;

  const InfoTile({super.key, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$etiqueta: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(valor ?? 'No disponible')),
        ],
      ),
    );
  }
}