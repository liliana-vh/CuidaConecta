import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../model/solicitud/estado_solicitud.dart';
import '../../../../model/solicitud/solicitud.dart';

class PanelPago extends StatelessWidget {
  final Solicitud solicitud;
  final bool esCuidador;
  final bool procesando;

  final VoidCallback? onPagarGarantia;
  final VoidCallback? onPagarFinal;      // tarjeta: paga el cliente
  final VoidCallback? onConfirmarPago;   // efectivo: confirma el cuidador
  final VoidCallback? onReportarImpago;  // tarjeta vencida: lo marca el cuidador

  const PanelPago({
    super.key,
    required this.solicitud,
    required this.esCuidador,
    this.procesando = false,
    this.onPagarGarantia,
    this.onPagarFinal,
    this.onConfirmarPago,
    this.onReportarImpago,
  });

  static final NumberFormat _moneda = NumberFormat.currency(
    locale: 'es_CL',
    customPattern: '\$#,##0',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final s = solicitud;

    // garantia inicial (solo tarjeta)
    if (s.requiereGarantia &&
        s.estado == EstadoSolicitud.aceptada &&
        !s.garantiaPagada) {
      if (esCuidador) {
        return _mensaje(
          'Esperando que el cliente pague la garantía inicial '
          '(${_moneda.format(s.montoGarantia)}).',
          Colors.orange,
        );
      }
      return _boton(
        'Pagar garantía inicial (${_moneda.format(s.montoGarantia)})',
        Colors.orange.shade800,
        onPagarGarantia,
      );
    }

    // --- 2. Pago final (recién cuando la solicitud terminó) ---
    if (s.puedePagarFinal) {
      if (s.metodoPago == MetodoPago.tarjeta) {
        if (esCuidador) {
          if (s.pagoVencido) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _mensaje(
                  'El plazo máx de pago venció (domingo '
                  '${DateFormat('dd/MM').format(s.fechaPago)}) y el cliente '
                  'no ha pagado.',
                  Colors.red,
                ),
                const SizedBox(height: 10),
                _boton('Reportar pago no recibido', Colors.red, onReportarImpago),
              ],
            );
          }
          return _mensaje(
            'Esperando el pago del saldo final por parte del cliente '
            '(${_moneda.format(s.montoEstimado - s.montoGarantia)}), '
            'antes del domingo ${DateFormat('dd/MM').format(s.fechaPago)}.',
            Colors.blue,
          );
        }

        if (s.pagoVencido) {
          return _mensaje(
            'El plazo máx para pagar venció el domingo '
            '${DateFormat('dd/MM').format(s.fechaPago)}.',
            Colors.red,
          );
        }
        return _boton(
          'Pagar saldo final (${_moneda.format(s.montoEstimado - s.montoGarantia)})',
          Colors.green.shade700,
          onPagarFinal,
        );
      }

      // Efectivo: el cuidador confirma, el cliente solo espera
      if (esCuidador) {
        return _boton(
          'Confirmar pago recibido (${_moneda.format(s.montoEstimado)})',
          Colors.green.shade700,
          onConfirmarPago,
        );
      }
      return _mensaje(
        'Pague en efectivo directamente al cuidador. '
        'Él confirmará la recepción en la app.',
        Colors.blue,
      );
    }
    //pago realizado confirmado
    if (s.pagoRealizado) {
      final texto = s.metodoPago == MetodoPago.tarjeta
          ? 'Pago completado. Comisión de la plataforma: '
              '${_moneda.format(s.comisionPlataforma)}.'
          : 'Pago recibido y confirmado.';
      return _mensaje(texto, Colors.green.shade700, icono: Icons.check_circle);
    }

    return const SizedBox.shrink();
  }

  Widget _boton(String texto, Color color, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: procesando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: procesando
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _mensaje(String texto, Color color, {IconData icono = Icons.info_outline}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto, style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}