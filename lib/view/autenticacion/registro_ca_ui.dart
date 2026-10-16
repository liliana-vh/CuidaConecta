import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/autenticacion/registro_ca_vm.dart';

class RegistroCuidadorApoyoView extends StatelessWidget {
  const RegistroCuidadorApoyoView({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final tipoUsuario = (extra is String && extra.isNotEmpty) ? extra : 'Cuidador';

    return ChangeNotifierProvider(
      create: (_) => RegistroCAViewModel(),
      child: _Contenido(tipoUsuario: tipoUsuario),
    );
  }
}

class _Contenido extends StatelessWidget {
  final String tipoUsuario;

  const _Contenido({required this.tipoUsuario});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistroCAViewModel>();

    Future<void> registrar() async {
      final ok = await vm.registrarUsuario(tipoUsuario);
      if (!context.mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registro exitoso. Se envió un correo de verificación a ${vm.correoController.text.trim()}.\n'
              'Por favor, verificar antes de iniciar sesión.',
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro - $tipoUsuario'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF941F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: vm.correoController,
              decoration: const InputDecoration(
                labelText: 'Ingrese su Correo Electrónico',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: vm.contrasenaController,
              obscureText: vm.ocultarContrasena,
              decoration: InputDecoration(
                labelText: 'Ingrese su Contraseña',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(vm.ocultarContrasena ? Icons.visibility_off : Icons.visibility),
                  onPressed: vm.alternarOcultarContrasena,
                ),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: vm.confirmarContrasenaController,
              obscureText: vm.ocultarConfirmarContrasena,
              decoration: InputDecoration(
                labelText: 'Confirmar Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    vm.ocultarConfirmarContrasena ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: vm.alternarOcultarConfirmarContrasena,
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (vm.error != null)
              Text(
                vm.error!,
                style: const TextStyle(color: Color(0xFFE51B23)),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 15),

            vm.cargando
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: registrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE51B23),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Registrarse', style: TextStyle(fontSize: 16)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}