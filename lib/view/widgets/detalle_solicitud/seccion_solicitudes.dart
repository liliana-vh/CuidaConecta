import 'package:flutter/material.dart';

import '../../../model/solicitud/solicitud.dart';

// Titulo + lista de solicitudes desde un stream
class SeccionSolicitudes extends StatelessWidget {
  final String titulo;
  final Stream<List<Solicitud>> stream;
  final Widget Function(BuildContext context, Solicitud solicitud) itemBuilder;
  final String mensajeVacio;
  final double tamanoTitulo;
  final double tamanoMensajeVacio;

  const SeccionSolicitudes({
    super.key,
    required this.titulo,
    required this.stream,
    required this.itemBuilder,
    this.mensajeVacio = 'No hay solicitudes en esta sección.',
    this.tamanoTitulo = 18,
    this.tamanoMensajeVacio = 14,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Solicitud>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Error cargando solicitudes: ${snapshot.error}');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No se pudieron cargar las solicitudes.',
              style: TextStyle(
                fontSize: tamanoMensajeVacio,
                color: Colors.black54,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final lista = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: tamanoTitulo,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            if (lista.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 4),
                child: Text(
                  mensajeVacio,
                  style: TextStyle(
                    fontSize: tamanoMensajeVacio,
                    color: Colors.black54,
                  ),
                ),
              )
            else
              ...lista.map((s) => itemBuilder(context, s)),
          ],
        );
      },
    );
  }
}
