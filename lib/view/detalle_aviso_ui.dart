import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../viewmodel/detalle_aviso_vm.dart';
import 'widgets/aviso/detalles_aviso.dart';

// compartido por cuidador y clientes
class DetalleAvisoView extends StatelessWidget {
  final String idAviso;

  const DetalleAvisoView({super.key, required this.idAviso});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetalleAvisoViewModel(idAviso)..cargar(),
      child: const _DetalleAvisoContenido(),
    );
  }
}

class _DetalleAvisoContenido extends StatelessWidget {
  const _DetalleAvisoContenido();

  static final NumberFormat _moneda = NumberFormat.currency(
    locale: 'es_CL',
    customPattern: '\$#,##0',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetalleAvisoViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Aviso'),
        backgroundColor: kNaranja,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(child: _buildCuerpo(context, vm)),
    );
  }

  Widget _buildCuerpo(BuildContext context, DetalleAvisoViewModel vm) {
    if (vm.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final aviso = vm.aviso;
    if (vm.error != null || aviso == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            vm.error ?? 'Este aviso ya no está disponible.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    final cuidador = vm.cuidador;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: kNaranjaClaro,
                  backgroundImage: vm.tieneFoto ? NetworkImage(vm.fotoCuidadorUrl!) : null,
                  child: vm.tieneFoto ? null : const Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  aviso.nombreCuidador,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 30),

          Text(aviso.titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(aviso.descripcion),
          const SizedBox(height: 20),

          SeccionDetalle(
            titulo: 'Tarifa y zona',
            icono: Icons.payments_outlined,
            child: Column(
              children: [
                FilaInfo(icono: Icons.attach_money, titulo: 'Tarifa por hora', valor: _moneda.format(aviso.tarifaHora)),
                FilaInfo(icono: Icons.place, titulo: 'Comuna', valor: vm.comunaTexto),
              ],
            ),
          ),

          SeccionDetalle(
            titulo: 'Servicios',
            icono: Icons.checklist,
            child: aviso.servicios.isEmpty
                ? const Text(
                    'El cuidador no ha seleccionado servicios.',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  )
                : Column(children: aviso.servicios.map((s) => ChecklistServicio(servicio: s)).toList()),
          ),

          SeccionDetalle(
            titulo: 'Disponibilidad semanal',
            icono: Icons.schedule,
            child: DisponibilidadSemanal(disponibilidad: aviso.disponibilidad),
          ),

          if (cuidador != null)
            SeccionDetalle(
              titulo: 'Formación y experiencia',
              icono: Icons.school,
              child: Column(
                children: [
                  FilaInfo(icono: Icons.school, titulo: 'Formación', valor: vm.formacionTexto),
                  FilaInfo(icono: Icons.work, titulo: 'Experiencia', valor: vm.experienciaTexto),
                  if (!vm.esDuenio)
                    DocumentoAdjuntoTile(titulo: 'Certificado de antecedentes', url: vm.certificadoUrl),
                ],
              ),
            ),

          const SizedBox(height: 8),
          if (vm.esDuenio)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.push('/cuidador/editar-aviso/${aviso.id}');
                  if (context.mounted) vm.cargar();
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar aviso'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kNaranja,
                  side: const BorderSide(color: kNaranja),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            )
          else ...[
            const Text(
              'Si la disponibilidad y los servicios cumplen con lo que '
              'necesita, ¡solicite este servicio!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push('/apoyo/solicitar-servicio/${aviso.id}'),
              icon: const Icon(Icons.calendar_month, size: 26),
              label: const Text('Solicitar servicio (reservar)', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kNaranja,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}