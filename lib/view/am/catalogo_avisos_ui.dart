import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../model/lista_servicios.dart';

class CatalogoServiciosAMView extends StatelessWidget {
  const CatalogoServiciosAMView({super.key});

  static const Color _naranja = Color(0xFFFF941F);

  static const Map<String, IconData> _iconos = {
    'Acompañamiento y apoyo básico': Icons.handshake,
    'Cuidado a domicilio avanzado': Icons.medical_services,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '¿Qué necesita?',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: _naranja,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: ListaServicios.nombres.map((servicio) {
          final nombre = ListaServicios.nombresCortos[servicio] ?? servicio;
          final resumen = ListaServicios.resumenesSimples[servicio] ?? '';

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _iconos[servicio] ?? Icons.volunteer_activism,
                        size: 48,
                        color: _naranja,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (resumen.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(resumen, style: const TextStyle(fontSize: 19)),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push(
                        '/am/catalogo-avisos-filtrados/${Uri.encodeComponent(servicio)}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _naranja,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Ver cuidadores'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}