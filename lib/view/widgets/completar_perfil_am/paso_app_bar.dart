import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//intento centralizacion codigo con widgets separados 2
class PasoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int numeroPaso;
  final int totalPasos;
  final String? rutaAtras;

  const PasoAppBar({
    super.key,
    required this.numeroPaso,
    this.totalPasos = 6,
    this.rutaAtras,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: rutaAtras != null,
      centerTitle: true,
      title: Text(
        'Paso $numeroPaso de $totalPasos',
        style: const TextStyle(fontSize: 20),
      ),
      backgroundColor: const Color(0xFFFF941F),
      leading: rutaAtras == null
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back, size: 28),
              onPressed: () => context.go(rutaAtras!),
            ),
    );
  }
}