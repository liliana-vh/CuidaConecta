import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/detalle_aviso_vm.dart';
import '../widgets/aviso/detalles_aviso.dart';
import '../widgets/formato_horarios.dart';

class DetalleAvisoAMView extends StatelessWidget {
  final String idAviso;

  const DetalleAvisoAMView({super.key, required this.idAviso});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetalleAvisoViewModel(idAviso)..cargar(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static final NumberFormat _moneda = NumberFormat.decimalPattern('es_CL');

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetalleAvisoViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: kNaranja,
        iconTheme: const IconThemeData(color: Colors.black),
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
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vm.error ?? 'Este aviso ya no está disponible.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, color: Colors.black),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 22),
                ),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final cuidador = vm.cuidador;
    final horarios = horariosAgrupados(aviso.disponibilidad);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 60,
            backgroundColor: kNaranja,
            backgroundImage: vm.tieneFoto
                ? NetworkImage(vm.fotoCuidadorUrl!)
                : null,
            child: vm.tieneFoto
                ? null
                : const Icon(Icons.person, size: 70, color: Colors.black),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          aviso.nombreCuidador,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          aviso.titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          aviso.descripcion,
          style: const TextStyle(fontSize: 20, color: Colors.black),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: kNaranja,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                '\$${_moneda.format(aviso.tarifaHora)}',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                'por hora',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _SeccionAM(
          titulo: 'Qué incluye',
          icono: Icons.volunteer_activism,
          child: aviso.servicios.isEmpty
              ? const Text(
                  'El cuidador no ha indicado servicios.',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                )
              : Column(
                  children: aviso.servicios
                      .map((s) => ChecklistServicio(servicio: s, grande: true))
                      .toList(),
                ),
        ),

        _SeccionAM(
          titulo: 'Cuándo atiende',
          icono: Icons.schedule,
          child: horarios.isEmpty
              ? const Text(
                  'Sin horarios registrados.',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: horarios
                      .map(
                        (h) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            h,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),

        _SeccionAM(
          titulo: 'Dónde',
          icono: Icons.place,
          child: Text(
            vm.comunaTexto,
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),

        if (cuidador != null)
          _SeccionAM(
            titulo: 'Sobre el cuidador',
            icono: Icons.badge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Linea('Formación: ${vm.formacionTexto}'),
                _Linea('Experiencia: ${vm.experienciaTexto}'),
                const SizedBox(height: 6),
                if (vm.tieneCertificado)
                  OutlinedButton.icon(
                    onPressed: () => context.push(
                      '/visor-pdf',
                      extra: {
                        'url': vm.certificadoUrl!,
                        'titulo': 'Certificado de Antecedentes',
                      },
                    ),

                    icon: const Icon(Icons.picture_as_pdf, size: 28),
                    label: const Text(
                      'Ver certificado de antecedentes',
                      style: TextStyle(fontSize: 19),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 2),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  )
                else
                  const _Linea('Certificado de antecedentes: no adjunto'),
              ],
            ),
          ),

        const SizedBox(height: 8),
        const Text(
          '¿Le sirve este servicio?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: () => context.push('/am/solicitar-servicio/${aviso.id}'),
          icon: const Icon(Icons.calendar_month, size: 30),
          label: const Text('Solicitar este servicio'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 68),
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class _SeccionAM extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Widget child;

  const _SeccionAM({
    required this.titulo,
    required this.icono,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 32, color: Colors.black),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Colors.black),
            child,
          ],
        ),
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  final String texto;

  const _Linea(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }
}
