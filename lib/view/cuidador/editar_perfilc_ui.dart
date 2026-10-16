import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodel/cuidador/editar_perfilc_vm.dart';
import '../widgets/perfil/selector_foto_perfil.dart';
import '../widgets/perfil/seccion_titulo.dart';
import '../widgets/perfil/campo_rut_formateado.dart';
import '../widgets/perfil/dialogo_contrasena.dart';

class EditarPerfilCView extends StatelessWidget {
  final String uid;

  const EditarPerfilCView({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditarPerfilCViewModel()..cargarDatosActuales(uid),
      child: _Contenido(uid: uid),
    );
  }
}

class _Contenido extends StatelessWidget {
  final String uid;
  static const primaryColor = Color(0xFFFF941F);

  const _Contenido({required this.uid});

  Future<void> _guardar(BuildContext context, EditarPerfilCViewModel vm) async {
    final resultado = await vm.guardarCambios(uid);
    if (!context.mounted) return;

    if (resultado == 'correo_pendiente') {
      final contrasena = await mostrarDialogoContrasena(context);
      if (!context.mounted) return;
      await vm.confirmarCambioCorreo(uid, contrasena ?? '');
      return;
    }

    if (vm.error == null) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditarPerfilCViewModel>();

    if (vm.cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SelectorFotoPerfil(
              fotoActualUrl: vm.fotoActualUrl,
              imagenNueva: vm.imagenNueva,
              onImagenSeleccionada: vm.seleccionarImagen,
              colorBoton: primaryColor,
            ),
            const SizedBox(height: 25),

            const SeccionTitulo(titulo: 'Mis Datos', color: primaryColor),
            TextFormField(
              controller: vm.nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: vm.apellidoController,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            CampoRutFormateado(
              controller: vm.rutController,
              conValidator: false,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: vm.correoController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
                helperText:
                    'Si lo cambias, deberás confirmar el cambio desde tu correo nuevo',
                helperMaxLines: 2,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: vm.telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixText: '+56 ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 9,
            ),

            const Divider(height: 40),
            const SeccionTitulo(
              titulo: 'Datos Profesionales',
              color: primaryColor,
            ),
            TextFormField(
              controller: vm.descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción personal (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: vm.nivelEstudiosSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Nivel de estudios',
                border: OutlineInputBorder(),
              ),
              items: EditarPerfilCViewModel.nivelesEstudios
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: vm.seleccionarNivelEstudios,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: vm.experienciaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Años de experiencia',
                border: OutlineInputBorder(),
              ),
              items: EditarPerfilCViewModel.experiencias
                  .map(
                    (e) => DropdownMenuItem(value: e, child: Text('$e años')),
                  )
                  .toList(),
              onChanged: vm.seleccionarExperiencia,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: vm.formacionSeleccionada,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Formación',
                border: OutlineInputBorder(),
              ),
              items: EditarPerfilCViewModel.formaciones
                  .map(
                    (f) => DropdownMenuItem(
                      value: f,
                      child: Text(f, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: vm.seleccionarFormacion,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: vm.comunaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Comuna donde trabajas',
                border: OutlineInputBorder(),
              ),
              items: EditarPerfilCViewModel.comunasDisponibles
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: vm.seleccionarComuna,
            ),
            const SizedBox(height: 20),

            const Text(
              'Servicios que ofreces',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: EditarPerfilCViewModel.serviciosDisponibles.map((
                servicio,
              ) {
                final seleccionado = vm.serviciosSeleccionados.contains(
                  servicio,
                );
                return FilterChip(
                  label: Text(servicio),
                  selected: seleccionado,
                  onSelected: (v) => vm.alternarServicio(servicio, v),
                  selectedColor: primaryColor.withValues(alpha: 0.3),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text(
              'Certificado de Antecedentes (PDF)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result?.files.single.path != null) {
                  vm.seleccionarPdf(File(result!.files.single.path!));
                }
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(
                vm.nombreArchivoPdf != null
                    ? 'Actualizar PDF'
                    : 'Subir Certificado PDF',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
            ),
            Text(
              vm.nombreArchivoPdf ?? 'Ningún archivo seleccionado',
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 15),
            if (vm.error != null)
              Text(
                vm.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            if (vm.exito != null)
              Text(
                vm.exito!,
                style: const TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 30),
            vm.guardando
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () => _guardar(context, vm),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'GUARDAR CAMBIOS',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            const SafeArea(top: false, child: SizedBox(height: 10)),
          ],
        ),
      ),
    );
  }
}
