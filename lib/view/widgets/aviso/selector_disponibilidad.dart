import 'package:flutter/material.dart';
import 'package:cuida_conecta/model/solicitud/reglas_servicio.dart';
import 'package:cuida_conecta/viewmodel/cuidador/publicar_aviso_vm.dart';

class SelectorDisponibilidad extends StatelessWidget {
  final PublicarAvisoViewModel vm;
  final Future<void> Function(String dia, {required bool esInicio}) onSeleccionarHora;

  const SelectorDisponibilidad({
    super.key,
    required this.vm,
    required this.onSeleccionarHora,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Disponibilidad',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Horario permitido: '
          '${PublicarAvisoViewModel.hhmm(ReglasServicio.horaMinima)} a '
          '${PublicarAvisoViewModel.hhmm(ReglasServicio.horaMaxima)}',
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        ...PublicarAvisoViewModel.dias.map((dia) => _buildDiaItem(dia)),
      ],
    );
  }

  Widget _buildDiaItem(String dia) {
    final activo = vm.diaActivo(dia);
    final inicio = vm.horaInicioDe(dia);
    final fin = vm.horaFinDe(dia);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(dia),
          value: activo,
          onChanged: (v) => vm.alternarDia(dia, v ?? false),
        ),
        if (activo)
          Padding(
            padding: const EdgeInsets.only(left: 40, bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text(
                    inicio != null
                        ? 'Inicio: ${PublicarAvisoViewModel.hhmm(inicio)}'
                        : 'Hora de inicio',
                  ),
                  onPressed: () => onSeleccionarHora(dia, esInicio: true),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text(
                    fin != null
                        ? 'Fin: ${PublicarAvisoViewModel.hhmm(fin)}'
                        : 'Hora de fin',
                  ),
                  onPressed: () => onSeleccionarHora(dia, esInicio: false),
                ),
              ],
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}