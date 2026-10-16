import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../model/solicitud/estado_solicitud.dart';
import '../model/solicitud/solicitud.dart';
import '../viewmodel/utilidades/errores.dart';
import '../viewmodel/detalle_solicitud_vm.dart';
import 'widgets/detalle_solicitud/estado_visual.dart';
import 'widgets/detalle_solicitud/info_solicitud_tarjeta.dart';
import 'widgets/detalle_solicitud/tarjeta_sesion.dart';
import 'widgets/detalle_solicitud/panel_pago.dart';

// Detalle solicitud compartido por cuidador y apoyo
class DetalleSolicitudView extends StatelessWidget {
  final String idSolicitud;

  const DetalleSolicitudView({super.key, required this.idSolicitud});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetalleSolicitudViewModel(idSolicitud)..escuchar(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const Color _naranja = Color(0xFFFF941F);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetalleSolicitudViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la solicitud'),
        backgroundColor: _naranja,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(child: _buildCuerpo(context, vm)),
    );
  }

  Widget _buildCuerpo(BuildContext context, DetalleSolicitudViewModel vm) {
    if (vm.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final s = vm.solicitud;
    if (vm.error != null || s == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            vm.error ?? 'Esta solicitud ya no existe.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    final esCuidador = vm.esCuidador;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: ChipEstado(s.estado)),
        const SizedBox(height: 20),
        InfoSolicitudTarjeta(solicitud: s, mostrarNombreCliente: esCuidador),
        const SizedBox(height: 16),

        // PanelPago solo usa los callbacks que le corresponden al rol
        PanelPago(
          solicitud: s,
          esCuidador: esCuidador,
          procesando: vm.procesando,
          onPagarGarantia: () => ejecutarAccion(context, vm.pagarGarantia),
          onPagarFinal: () => ejecutarAccion(context, vm.registrarPagoFinal),
          onConfirmarPago: () => ejecutarAccion(context, vm.registrarPagoFinal),
          onReportarImpago: () => ejecutarAccion(context, vm.reportarImpago),
        ),
        const SizedBox(height: 16),

        if (esCuidador && s.estado == EstadoSolicitud.pendiente)
          _panelPendiente(context, vm, s),

        if (s.sesiones.isNotEmpty) ...[
          const Text(
            'Días de servicio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < s.sesiones.length; i++)
            esCuidador
                ? _sesionEditable(context, vm, s, i)
                // cliente solo mira solicitud, no botones interactivos
                : TarjetaSesion(sesion: s.sesiones[i]),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _sesionEditable(
    BuildContext context,
    DetalleSolicitudViewModel vm,
    Solicitud s,
    int i,
  ) {
    return TarjetaSesion(
      sesion: s.sesiones[i],
      procesando: vm.procesando,
      motivoBloqueo: s.motivoNoPuedeIniciar(i, DateTime.now()),
      onIniciar: () => ejecutarAccion(context, () => vm.iniciarSesion(i)),
      onFinalizar: () => ejecutarAccion(context, () => vm.finalizarSesion(i)),
      onTareaCambio: (indiceTarea, completada, comentario) => ejecutarAccion(
        context,
        () => vm.actualizarTarea(
          i,
          indiceTarea,
          completada: completada,
          comentario: comentario,
        ),
      ),
    );
  }

  //panel cuidador
  Widget _panelPendiente(
    BuildContext context,
    DetalleSolicitudViewModel vm,
    Solicitud s,
  ) {
    return Card(
      color: Colors.orange.shade50,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '¿Aceptar esta solicitud?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Si acepta, estos ${s.sesiones.length} días quedarán '
              'reservados en su agenda.',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: vm.procesando
                        ? null
                        : () => _rechazar(context, vm),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: vm.procesando
                        ? null
                        : () => _aceptar(context, vm),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: vm.procesando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _aceptar(
    BuildContext context,
    DetalleSolicitudViewModel vm,
  ) async {
    final ok = await ejecutarAccion(context, vm.aceptar);
    if (ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Solicitud aceptada')));
    }
  }

  Future<void> _rechazar(
    BuildContext context,
    DetalleSolicitudViewModel vm,
  ) async {
    final motivo = await _pedirTexto(context);
    if (motivo == null || !context.mounted) return;

    final ok = await ejecutarAccion(context, () => vm.rechazar(motivo: motivo));
    if (ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Solicitud rechazada')));
      if (context.canPop()) context.pop();
    }
  }

  Future<String?> _pedirTexto(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rechazar solicitud'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Motivo (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}
