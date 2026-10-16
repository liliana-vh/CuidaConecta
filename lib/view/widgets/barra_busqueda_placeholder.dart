import 'package:flutter/material.dart';

class BarraBusquedaPlaceholder extends StatelessWidget {
  final String texto;

  const BarraBusquedaPlaceholder({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),
            Text(texto, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}