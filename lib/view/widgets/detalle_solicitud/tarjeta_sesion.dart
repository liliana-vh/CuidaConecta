import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/solicitud/estado_solicitud.dart';
import '../../../model/solicitud/sesion_solicitud.dart';
import '../../../model/solicitud/tarea_realizada.dart';

class TarjetaSesion extends StatelessWidget {
  final Sesion sesion;

  // null = sin boton (vista del cliente solo lectura)
  final VoidCallback? onIniciar;
  final VoidCallback? onFinalizar;
  final String? motivoBloqueo;
  final bool procesando;
  final bool grande;

  // null = tareas de solo lectura (vista del cliente).
  final void Function(int indiceTarea, bool completada, String? comentario)?
  onTareaCambio;

  const TarjetaSesion({
    super.key,
    required this.sesion,
    this.onIniciar,
    this.onFinalizar,
    this.motivoBloqueo,
    this.procesando = false,
    this.grande = false,
    this.onTareaCambio,
  });

  static const Color _naranja = Color(0xFFFF941F);

  @override
  Widget build(BuildContext context) {
    final rango =
        '${DateFormat('EEEE dd/MM', 'es').format(sesion.inicio)} · '
        '${DateFormat('HH:mm').format(sesion.inicio)} - '
        '${DateFormat('HH:mm').format(sesion.fin)}';

    final Color color;
    final String etiqueta;
    switch (sesion.estado) {
      case EstadoSesion.enProgreso:
        color = Colors.blue;
        etiqueta = 'En curso';
        break;
      case EstadoSesion.finalizada:
        color = Colors.green;
        etiqueta = 'Finalizada';
        break;
      default:
        color = Colors.grey;
        etiqueta = 'Pendiente';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    rango,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: grande ? 19 : 14,
                      color: grande ? Colors.black : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    etiqueta.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (sesion.estado == EstadoSesion.pendiente &&
                onIniciar != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: procesando || motivoBloqueo != null
                      ? null
                      : onIniciar,
                  style: ElevatedButton.styleFrom(backgroundColor: _naranja),
                  child: const Text('Iniciar sesión'),
                ),
              ),
              if (motivoBloqueo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    motivoBloqueo!,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ),
            ],

            if (sesion.estado == EstadoSesion.enProgreso &&
                onFinalizar != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: procesando ? null : onFinalizar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Finalizar sesión'),
                ),
              ),
            ],

            if (sesion.tareas.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              const Text(
                'Tareas de este día',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              for (int i = 0; i < sesion.tareas.length; i++)
                _itemTarea(context, i, sesion.tareas[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _itemTarea(BuildContext context, int indice, TareaRealizada tarea) {
    final editable =
        onTareaCambio != null && sesion.estado == EstadoSesion.enProgreso;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: editable ? () => _alternar(context, indice, tarea) : null,
            child: Row(
              children: [
                Icon(
                  tarea.completada
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: tarea.completada ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tarea.titulo,
                    style: TextStyle(
                      fontSize: grande ? 18 : 14,
                      color: grande
                          ? Colors.black
                          : (tarea.completada
                                ? Colors.black54
                                : Colors.black87),
                      decoration: tarea.completada
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (tarea.comentario != null && tarea.comentario!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 2, bottom: 4),
              child: Text(
                '"${tarea.comentario}"',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _alternar(
    BuildContext context,
    int indice,
    TareaRealizada tarea,
  ) async {
    if (tarea.completada) {
      onTareaCambio!(indice, false, null);
      return;
    }

    // comentario es opcionsl
    final comentario = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoComentario(titulo: tarea.titulo),
    );
    if (comentario == null) return; // canceló
    onTareaCambio!(indice, true, comentario.isEmpty ? null : comentario);
  }
}

class _DialogoComentario extends StatelessWidget {
  final String titulo;
  const _DialogoComentario({required this.titulo});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AlertDialog(
      title: Text('Completar: $titulo'),
      content: TextField(
        controller: controller,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Comentario (opcional)',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Marcar como hecha'),
        ),
      ],
    );
  }
}
