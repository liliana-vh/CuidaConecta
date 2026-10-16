import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../model/solicitud/solicitud.dart';

class ResumenSolicitudAM extends StatelessWidget {
  final Solicitud previa;
  final NumberFormat moneda;

  const ResumenSolicitudAM({
    super.key,
    required this.previa,
    required this.moneda,
  });

  static const Color _naranja = Color(0xFFFF941F);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            _fila('Días elegidos', '${previa.sesiones.length}'),
            _fila(
              'Horas totales',
              previa.horasTotales.toStringAsFixed(
                previa.horasTotales % 1 == 0 ? 0 : 1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _naranja,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    moneda.format(previa.montoEstimado),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Total a pagar',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              previa.textoPago,
              style: const TextStyle(fontSize: 17, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: const TextStyle(fontSize: 18, color: Colors.black)),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}