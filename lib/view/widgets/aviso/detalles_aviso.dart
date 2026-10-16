import 'package:flutter/material.dart';

import '../../../model/lista_servicios.dart';
import 'package:go_router/go_router.dart';

const Color kNaranja = Color(0xFFFF941F);
const Color kNaranjaClaro = Color.fromARGB(255, 255, 186, 121);

class SeccionDetalle extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Widget child;

  const SeccionDetalle({
    super.key,
    required this.titulo,
    required this.icono,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: kNaranjaClaro),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kNaranja,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class FilaInfo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const FilaInfo({
    super.key,
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Icon(icono, color: kNaranja, size: 26),
      title: Text(
        titulo,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        valor,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      ),
    );
  }
}

// Checklist desplegable con las tareas de un tipo de servicio
class ChecklistServicio extends StatelessWidget {
  final String servicio;
  final bool grande;

  const ChecklistServicio({
    super.key,
    required this.servicio,
    this.grande = false,
  });

  @override
  Widget build(BuildContext context) {
    final tareas = ListaServicios.tareas[servicio] ?? const <String>[];
    final incluye = ListaServicios.incluye[servicio];
    final descripcion = ListaServicios.descripciones[servicio];

    String nombreDe(String s) =>
        grande ? (ListaServicios.nombresCortos[s] ?? s) : s;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 4, bottom: 8),
      expandedAlignment: Alignment.centerLeft,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      shape: const Border(),
      collapsedShape: const Border(),
      iconColor: grande ? Colors.black : null,
      collapsedIconColor: grande ? Colors.black : null,
      title: Text(
        nombreDe(servicio),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: grande ? 24 : 16,
          color: grande ? Colors.black : null,
        ),
      ),
      children: [
        if (incluye != null)
          _ItemCheck(
            'Incluye todo el servicio "${nombreDe(incluye)}"',
            destacado: true,
            grande: grande,
          ),
        for (final tarea in tareas) _ItemCheck(tarea, grande: grande),
        if (tareas.isEmpty && incluye == null && descripcion != null)
          Text(
            descripcion,
            style: TextStyle(
              fontSize: grande ? 19 : null,
              color: grande ? Colors.black : Colors.black54,
            ),
          ),
      ],
    );
  }
}

class _ItemCheck extends StatelessWidget {
  final String texto;
  final bool destacado;
  final bool grande;

  const _ItemCheck(this.texto, {this.destacado = false, this.grande = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: grande ? 4 : 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            destacado ? Icons.add_circle_outline : Icons.check_circle_outline,
            size: grande ? 26 : 20,
            color: grande
                ? Colors.black
                : (destacado ? kNaranja : Colors.green),
          ),
          SizedBox(width: grande ? 10 : 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: grande ? 19 : 15,
                color: grande ? Colors.black : null,
                fontWeight: destacado
                    ? (grande ? FontWeight.bold : FontWeight.w600)
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DisponibilidadSemanal extends StatelessWidget {
  final Map<String, dynamic> disponibilidad;

  const DisponibilidadSemanal({super.key, required this.disponibilidad});

  static const List<String> _dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  @override
  Widget build(BuildContext context) {
    if (disponibilidad.isEmpty) {
      return const Text(
        'El cuidador no tiene horarios de disponibilidad registrados.',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _dias.map((dia) {
        final franja = disponibilidad[dia];
        final disponible = franja is Map;

        final horario = !disponible
            ? 'No disponible'
            : franja['inicio'] == '24 horas'
            ? 'Disponible 24 horas'
            : '${franja['inicio']} - ${franja['fin']}';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                disponible ? Icons.check_circle_outline : Icons.cancel_outlined,
                size: 18,
                color: disponible ? Colors.green : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Text(
                '$dia:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: disponible ? null : Colors.redAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  horario,
                  style: TextStyle(
                    fontSize: 16,
                    color: disponible ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Documento PDF adjunto, abrir visor o no hay nada adjunto
class DocumentoAdjuntoTile extends StatelessWidget {
  final String titulo;
  final String? url;

  const DocumentoAdjuntoTile({super.key, required this.titulo, this.url});

  @override
  Widget build(BuildContext context) {
    final link = url;

    if (link == null || link.isEmpty) {
      return FilaInfo(
        icono: Icons.verified_user,
        titulo: titulo,
        valor: 'No adjunto',
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.picture_as_pdf, color: kNaranja),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: const Text('Toca para ver el documento PDF'),
      trailing: const Icon(Icons.visibility),
      onTap: () =>
          context.push('/visor-pdf', extra: {'url': link, 'titulo': titulo}),
    );
  }
}
