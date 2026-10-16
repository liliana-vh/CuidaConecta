import 'package:flutter/material.dart';

import '../../../../model/solicitud/agenda.dart';
import '../../../../model/solicitud/agenda_semanal.dart';
import '../../../viewmodel/utilidades/fecha_hora.dart';
import '../../../viewmodel/agendar_vm.dart';

class TarjetaDiaAgendarAM extends StatelessWidget {
  final AgendarViewModel vm;
  final DiaAgenda dia;

  const TarjetaDiaAgendarAM({super.key, required this.vm, required this.dia});

  static const Color _naranja = Color(0xFFFF941F);
  static const Color _verde = Color(0xFF1B7A1B);
  static const Color _rojo = Color(0xFFB3261E);

  static String _rango(Intervalo i) => '${hhmm(i.inicio)} a ${hhmm(i.fin)}';

  @override
  Widget build(BuildContext context) {
    final sel = dia.seleccion;
    final fin = sel?.fin;

    final Color color = dia.seleccionado
        ? _naranja
        : dia.habilitado
            ? _verde
            : _rojo;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color, width: dia.seleccionado ? 3 : 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  dia.seleccionado
                      ? Icons.check_circle
                      : dia.habilitado
                          ? Icons.check_circle_outline
                          : Icons.cancel,
                  color: color,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${dia.nombre} ${dia.fecha.day}/${dia.fecha.month}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            if (!dia.habilitado) ...[
              const SizedBox(height: 8),
              Text(
                dia.bloqueo!,
                style: const TextStyle(fontSize: 17, color: _rojo, fontWeight: FontWeight.w600),
              ),
            ],

            if (dia.habilitado) ...[
              const SizedBox(height: 8),
              Text(
                'Horas libres: ${dia.libres.map(_rango).join(', ')}',
                style: const TextStyle(fontSize: 16, color: _verde, fontWeight: FontWeight.w600),
              ),
              if (dia.ocupados.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Ya ocupado: ${dia.ocupados.map(_rango).join(', ')}',
                  style: const TextStyle(fontSize: 15, color: _rojo),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => vm.alternarDia(dia.fecha, !dia.seleccionado),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dia.seleccionado ? _naranja : Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(dia.seleccionado ? 'Quitar este día' : 'Elegir este día'),
                ),
              ),
            ],

            if (sel != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Hora de inicio',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 6),
              _stepper(
                texto: hhmm(sel.inicio),
                onMenos: () => _moverHora(sel, -30),
                onMas: () => _moverHora(sel, 30),
              ),
              const SizedBox(height: 14),
              const Text(
                'Cuántas horas',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 6),
              _stepper(
                texto: '${sel.horas} horas',
                onMenos: sel.horas > vm.opcionesHoras.first
                    ? () => vm.fijarHoras(dia.fecha, sel.horas - 1)
                    : null,
                onMas: sel.horas < vm.opcionesHoras.last
                    ? () => vm.fijarHoras(dia.fecha, sel.horas + 1)
                    : null,
              ),
              if (fin != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Termina a las ${hhmm(fin)}',
                  style: const TextStyle(fontSize: 17, color: Colors.black),
                ),
              ],
              if (dia.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  dia.error!,
                  style: const TextStyle(fontSize: 16, color: _rojo, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _moverHora(Intervalo sel, int minutos) {
    final total = (sel.inicio.hour * 60 + sel.inicio.minute + minutos)
        .clamp(0, 23 * 60 + 30);
    vm.fijarInicio(dia.fecha, TimeOfDay(hour: total ~/ 60, minute: total % 60));
  }

  Widget _stepper({
    required String texto,
    required VoidCallback? onMenos,
    required VoidCallback? onMas,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _botonStepper(Icons.remove, onMenos),
          Expanded(
            child: Center(
              child: Text(
                texto,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _botonStepper(Icons.add, onMas),
        ],
      ),
    );
  }

  Widget _botonStepper(IconData icono, VoidCallback? onPressed) {
    return SizedBox(
      width: 56,
      height: 56,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icono, size: 28),
        color: onPressed == null ? Colors.grey.shade400 : Colors.black,
      ),
    );
  }
}