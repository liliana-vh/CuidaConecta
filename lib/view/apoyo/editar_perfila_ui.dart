import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../viewmodel/apoyo/editar_perfila_vm.dart';
import '../widgets/perfil/selector_foto_perfil.dart';
import '../widgets/perfil/seccion_titulo.dart';
import '../widgets/perfil/campo_rut_formateado.dart';
import '../widgets/perfil/dialogo_contrasena.dart';

class EditarPerfilAView extends StatelessWidget {
  final String uid;

  const EditarPerfilAView({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditarPerfilAViewModel()..cargarDatosActuales(uid),
      child: _Contenido(uid: uid),
    );
  }
}

class _Contenido extends StatelessWidget {
  final String uid;
  static const primaryColor = Color(0xFFFF941F);

  const _Contenido({required this.uid});

  Future<void> _guardar(BuildContext context, EditarPerfilAViewModel vm) async {
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
    final vm = context.watch<EditarPerfilAViewModel>();

    if (vm.cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Mi Perfil'),
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
              titulo: 'Dirección de Atención',
              color: primaryColor,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: vm.calleController,
                    decoration: const InputDecoration(
                      labelText: 'Calle',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: vm.numeroController,
                    decoration: const InputDecoration(
                      labelText: 'N°',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: vm.comunaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Comuna',
                border: OutlineInputBorder(),
              ),
              items: EditarPerfilAViewModel.comunasDisponibles
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: vm.seleccionarComuna,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: vm.detallesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Referencia o detalles adicionales',
                border: OutlineInputBorder(),
              ),
            ),

            const Divider(height: 50),
            const SeccionTitulo(
              titulo: 'Datos del Familiar (Adulto Mayor)',
              color: primaryColor,
            ),
            DropdownButtonFormField<String>(
              value: vm.relacionSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Mi relación con él/ella',
                border: OutlineInputBorder(),
              ),
              items: EditarPerfilAViewModel.relaciones
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: vm.seleccionarRelacion,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: vm.edadFamiliarController,
              decoration: const InputDecoration(
                labelText: 'Edad del adulto mayor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
                counterText: '',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 2,
            ),
            DropdownButtonFormField<String>(
              value: vm.condicionSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Condición principal',
                border: OutlineInputBorder(),
              ),
              items: EditarPerfilAViewModel.condiciones
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: vm.seleccionarCondicion,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: vm.dependenciaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Nivel de Dependencia',
                border: OutlineInputBorder(),
              ),
              items: EditarPerfilAViewModel.nivelesDependencia
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: vm.seleccionarDependencia,
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
                      backgroundColor: const Color(0xFFE51B23),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'GUARDAR CAMBIOS',
                      style: TextStyle(
                        color: Colors.white,
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
