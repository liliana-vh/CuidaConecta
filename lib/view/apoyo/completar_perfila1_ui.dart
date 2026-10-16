import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../viewmodel/autenticacion/datos_personales_ca_vm.dart';
import '../widgets/perfil/campo_rut_formateado.dart';
import '../widgets/perfil/boton_continuar_flujoa.dart';

class CompletarPerfilA1View extends StatelessWidget {
  const CompletarPerfilA1View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DatosPersonalesCAViewModel('Apoyo')..cargarDatosActuales(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const primaryColor = Color(0xFFFF941F);

  Future<void> _seleccionarImagen(DatosPersonalesCAViewModel vm) async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (imagen != null) vm.seleccionarImagen(File(imagen.path));
  }

  Future<void> _guardar(BuildContext context, DatosPersonalesCAViewModel vm) async {
    final ok = await vm.guardarPerfil();
    if (!context.mounted) return;
    if (ok) context.go('/apoyo/completar-perfil/paso-2');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DatosPersonalesCAViewModel>();

    if (vm.cargando) {
      return Scaffold(
        appBar: AppBar(title: const Text('Completar perfil (1/3)'), backgroundColor: primaryColor, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Completar perfil (1/3)'), backgroundColor: primaryColor, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: vm.imagenPerfil != null
                      ? FileImage(vm.imagenPerfil!)
                      : (vm.fotoActualUrl != null ? NetworkImage(vm.fotoActualUrl!) : null) as ImageProvider?,
                  child: (vm.imagenPerfil == null && vm.fotoActualUrl == null)
                      ? const Icon(Icons.person, size: 70, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: primaryColor,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      onPressed: () => _seleccionarImagen(vm),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            TextFormField(
              controller: vm.nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: vm.apellidoController,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            CampoRutFormateado(controller: vm.rutController, conValidator: false),
            const SizedBox(height: 16),
            TextFormField(
              controller: vm.telefonoController,
              maxLength: 9,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Teléfono móvil',
                prefixText: '+56 ',
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder(),
                counterText: "",
              ),
            ),

            const SizedBox(height: 15),
            if (vm.error != null)
              Text(vm.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),

            const SizedBox(height: 25),

            BotonContinuarFlujo(cargando: vm.guardando, onPressed: () => _guardar(context, vm)),
          ],
        ),
      ),
    );
  }
}