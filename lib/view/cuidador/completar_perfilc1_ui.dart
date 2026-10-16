import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../viewmodel/autenticacion/datos_personales_ca_vm.dart';
import '../widgets/perfil/campo_rut_formateado.dart';

class CompletarPerfilC1View extends StatelessWidget {
  const CompletarPerfilC1View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DatosPersonalesCAViewModel('Cuidador')..cargarDatosActuales(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const primaryColor = Color(0xFFFF941F);

  Future<void> _seleccionarImagen(DatosPersonalesCAViewModel vm) async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (imagen != null) vm.seleccionarImagen(File(imagen.path));
  }

  Future<void> _guardar(BuildContext context, DatosPersonalesCAViewModel vm) async {
    final ok = await vm.guardarPerfil();
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos personales guardados. Continúa con la siguiente sección.')),
      );
      context.go('/cuidador/completar-perfil/paso-2');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DatosPersonalesCAViewModel>();

    if (vm.cargando) {
      return Scaffold(
        appBar: AppBar(title: const Text('Completar Perfil (1/2)'), backgroundColor: primaryColor),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Completar Perfil (1/2)'), backgroundColor: primaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: () => _seleccionarImagen(vm),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: vm.imagenPerfil != null
                      ? FileImage(vm.imagenPerfil!)
                      : (vm.fotoActualUrl != null ? NetworkImage(vm.fotoActualUrl!) : null) as ImageProvider?,
                  child: (vm.imagenPerfil == null && vm.fotoActualUrl == null)
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Datos Personales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 10),

            TextFormField(
              controller: vm.nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: vm.apellidoController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            const SizedBox(height: 16),
            CampoRutFormateado(controller: vm.rutController, conValidator: false),
            const SizedBox(height: 16),
            TextFormField(
              controller: vm.telefonoController,
              decoration: const InputDecoration(labelText: 'Teléfono', prefixText: '+56 '),
              maxLength: 9,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Nivel de estudios'),
              value: vm.nivelEstudios,
              items: DatosPersonalesCAViewModel.nivelesEstudios
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: vm.seleccionarNivelEstudios,
            ),

            const SizedBox(height: 15),
            if (vm.error != null)
              Text(vm.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),

            const SizedBox(height: 25),

            Center(
              child: vm.guardando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _guardar(context, vm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 221, 25, 25),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      ),
                      child: const Text('Continuar', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}