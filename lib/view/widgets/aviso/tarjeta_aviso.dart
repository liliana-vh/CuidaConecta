import 'package:flutter/material.dart';

import '../../../model/cuidador/aviso_servicio.dart';

//vista mini de avisos
class TarjetaAviso extends StatelessWidget {
  final AvisoServicio aviso;

  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
  final VoidCallback? onTapCallback;

  const TarjetaAviso({
    super.key,
    required this.aviso,
    this.onEditar,
    this.onEliminar,
    this.onTapCallback,
  });

  static const List<String> _ordenDias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  List<String> _generarHorarios() {
    final salida = <String>[];

    for (final dia in _ordenDias) {
      final horas = aviso.disponibilidad[dia];
      if (horas is Map) {
        salida.add('$dia ${horas['inicio']} - ${horas['fin']}');
      }
    }

    return salida;
  }

  Widget _buildChips(List<String> items, Color color) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: items
          .map(
            (e) => Chip(
              label: Text(e, style: const TextStyle(color: Colors.white)),
              backgroundColor: color,
              visualDensity: VisualDensity.compact,
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horarios = _generarHorarios();
    final nombre = aviso.nombreCuidador;
    final foto = aviso.fotoCuidador;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTapCallback ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Detalles del aviso (placeholder)'),
                ),
              );
            },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFFF941F),
                          backgroundImage:
                              foto != null ? NetworkImage(foto) : null,
                          child: foto != null
                              ? null
                              : Text(
                                  nombre.isNotEmpty
                                      ? nombre[0].toUpperCase()
                                      : 'C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            nombre,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEditar != null)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          onPressed: onEditar,
                        ),
                      if (onEliminar != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onEliminar,
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                aviso.titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                aviso.descripcion,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),

              const SizedBox(height: 12),

              if (aviso.servicios.isNotEmpty) ...[
                const Text(
                  'Servicios:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildChips(aviso.servicios, Colors.deepPurple),
                const SizedBox(height: 6),
              ],

              if (aviso.comuna.isNotEmpty) ...[
                const Text(
                  'Comuna:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildChips([aviso.comuna], Colors.teal),
                const SizedBox(height: 6),
              ],

              if (horarios.isNotEmpty) ...[
                const Text(
                  'Disponibilidad:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildChips(horarios, Colors.orange),
                const SizedBox(height: 6),
              ],

              Text(
                'Tarifa por hora: \$${aviso.tarifaHora.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}