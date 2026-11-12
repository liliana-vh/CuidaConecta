import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/solicitud/comprobante.dart';
import '../../../model/solicitud/estado_solicitud.dart';
import '../../../model/solicitud/solicitud.dart';

// Lista de comprobantes de pago de una solicitud (se oculta si no hay ninguno)
class SeccionComprobantes extends StatelessWidget {
  final Solicitud solicitud;
  final List<Comprobante> comprobantes;

  const SeccionComprobantes({
    super.key,
    required this.solicitud,
    required this.comprobantes,
  });

  static final NumberFormat _moneda = NumberFormat.currency(
    locale: 'es_CL',
    customPattern: '\$#,##0',
    decimalDigits: 0,
  );

  static final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    if (comprobantes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comprobantes de pago',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        for (final c in comprobantes)
          _TarjetaComprobante(
            comprobante: c,
            onTap: () => _abrirHoja(context, c),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _abrirHoja(BuildContext context, Comprobante c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HojaComprobante(solicitud: solicitud, comprobante: c),
    );
  }
}

class _TarjetaComprobante extends StatelessWidget {
  final Comprobante comprobante;
  final VoidCallback onTap;

  const _TarjetaComprobante({required this.comprobante, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = comprobante;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.green.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c.creadoEn == null
                          ? c.numero
                          : '${c.numero} · ${SeccionComprobantes._fechaHora.format(c.creadoEn!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Text(
                SeccionComprobantes._moneda.format(c.monto),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HojaComprobante extends StatelessWidget {
  final Solicitud solicitud;
  final Comprobante comprobante;

  const _HojaComprobante({required this.solicitud, required this.comprobante});

  @override
  Widget build(BuildContext context) {
    final s = solicitud;
    final c = comprobante;
    final esTarjeta = c.metodoPago == MetodoPago.tarjeta;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 40),
            const SizedBox(height: 8),
            const Text(
              'Comprobante de pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              c.numero,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const Divider(height: 28),

            _fila('Concepto', c.titulo),
            _fila('Servicio', s.servicio),
            _fila('Cliente', s.nombreCliente),
            _fila('Cuidador', s.nombreCuidador),
            _fila('Método de pago', esTarjeta ? 'Tarjeta' : 'Efectivo'),
            _fila(
              'Fecha',
              c.creadoEn == null
                  ? 'Procesando...'
                  : SeccionComprobantes._fechaHora.format(c.creadoEn!),
            ),
            if (c.comision > 0)
              _fila(
                'Comisión de la plataforma',
                SeccionComprobantes._moneda.format(c.comision),
              ),

            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monto pagado',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  SeccionComprobantes._moneda.format(c.monto),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Text(
              'Pago simulado: comprobante generado por CuidaConecta.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}