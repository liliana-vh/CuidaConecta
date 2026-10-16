import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodel/am/inicio_am_vm.dart';
import '../widgets/am/boton_menu_am.dart';

class InicioAdultoMayorView extends StatefulWidget {
  const InicioAdultoMayorView({super.key});

  @override
  State<InicioAdultoMayorView> createState() => _InicioAdultoMayorViewState();
}

class _InicioAdultoMayorViewState extends State<InicioAdultoMayorView> {
  final InicioAMViewModel _viewModel = InicioAMViewModel();

  String _nombre = '';

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  Future<void> _cargarNombre() async {
    final nombre = await _viewModel.obtenerNombrePila();
    if (!mounted) return;
    setState(() => _nombre = nombre);
  }

  Future<void> _cerrarSesion() async {
    await _viewModel.cerrarSesion();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF941F),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            Text(
              _nombre.isEmpty ? '¡Hola!' : '¡Hola, $_nombre!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '¿Qué necesita hoy?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(137, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 28),

            BotonMenuAm(
              icon: Icons.search,
              title: 'Buscar servicios',
              subtitle: 'Encuentre quien le ayude',
              destacado: true,
              onPressed: () => context.push('/am/catalogo-avisos'),
            ),
            const SizedBox(height: 16),

            BotonMenuAm(
              icon: Icons.event_note,
              title: 'Mis servicios',
              onPressed: () => context.push('/am/catalogo-solicitudes'),
            ),
            const SizedBox(height: 16),
            BotonMenuAm(
              icon: Icons.person,
              title: 'Mis datos',
              onPressed: () => context.push('/am/mis-datos'),
            ),
            const SizedBox(height: 16),
            const BotonMenuAm(icon: Icons.help_outline, title: 'Ayuda'),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
