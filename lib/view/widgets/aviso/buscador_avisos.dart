import 'package:flutter/material.dart';

import '../../../viewmodel/filtro_avisos.dart';

// Barra busqueda avisos funcional 1
class BuscadorAvisos extends StatelessWidget {
  final FiltroAvisos filtro;

  const BuscadorAvisos({super.key, required this.filtro});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        onChanged: filtro.cambiarTexto,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, título o servicio',
          prefixIcon: const Icon(Icons.search),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}