import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/cuidador/completar_perfilc2_vm.dart';

class CompletarPerfilC2View extends StatelessWidget {
  const CompletarPerfilC2View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompletarPerfilC2ViewModel()..cargarDatosActuales(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const primaryColor = Color(0xFFFF941F);

  Future<void> _guardar(BuildContext context, CompletarPerfilC2ViewModel vm) async {
    final ok = await vm.guardarPerfilYFinalizar();
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Perfil completado con éxito!')),
      );
      context.go('/cuidador/inicio');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompletarPerfilC2ViewModel>();

    if (vm.cargando) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Completar Perfil (2/2)'),
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/cuidador/completar-perfil/paso-1'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Completar Perfil (2/2)'),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cuidador/completar-perfil/paso-1'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 16,
        ),
        child: Column(
          children: [
            TextFormField(
              controller: vm.descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción personal (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: vm.experienciaSeleccionada,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Años de experiencia'),
              items: const [
                DropdownMenuItem(value: '0-1', child: Text('0–1 años')),
                DropdownMenuItem(value: '1-3', child: Text('1–3 años')),
                DropdownMenuItem(value: '3-5', child: Text('3–5 años')),
                DropdownMenuItem(value: '5+', child: Text('5+ años')),
              ],
              onChanged: vm.seleccionarExperiencia,
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: vm.formacionSeleccionada,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Formación'),
              items: CompletarPerfilC2ViewModel.formaciones
                  .map((f) => DropdownMenuItem(value: f, child: Text(f, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: vm.seleccionarFormacion,
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: vm.comunaSeleccionada,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Comuna donde se trabaja'),
              items: CompletarPerfilC2ViewModel.comunasDisponibles
                  .map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: vm.seleccionarComuna,
            ),
            const SizedBox(height: 25),

            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Servicios que ofrece', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...CompletarPerfilC2ViewModel.serviciosDisponibles.map((servicio) {
                    final seleccionado = vm.serviciosSeleccionados.contains(servicio);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FilterChip(
                          label: Text(servicio),
                          selected: seleccionado,
                          onSelected: (v) => vm.alternarServicio(servicio, v),
                        ),
                        if (seleccionado)
                          Container(
                            margin: const EdgeInsets.only(left: 8, top: 4, bottom: 8),
                            padding: const EdgeInsets.all(8),
                            width: double.infinity,
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              CompletarPerfilC2ViewModel.descripcionServicios[servicio]!,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text('Subir Certificado de cuidador o curriculum (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                if (result?.files.single.path != null) {
                  vm.seleccionarPdf(File(result!.files.single.path!));
                }
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(vm.nombreArchivoPdf != null ? 'Actualizar PDF' : 'Seleccionar archivo'),
            ),
            Text(vm.nombreArchivoPdf ?? 'Ningún archivo seleccionado', overflow: TextOverflow.ellipsis),

            const SizedBox(height: 15),
            if (vm.error != null)
              Text(vm.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),

            const SizedBox(height: 30),
            vm.guardando
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: () => _guardar(context, vm),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Finalizar registro'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      backgroundColor: const Color.fromARGB(255, 228, 47, 47),
                      foregroundColor: Colors.white,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}