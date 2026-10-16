import 'package:flutter/material.dart';

//botones opciones desde perfil (cuidador/apoyo)
class BotonesPerfilAcciones extends StatelessWidget {
  final VoidCallback onEditar;
  final VoidCallback onCambiarContrasena;
  final VoidCallback onCerrarSesion;
  final bool enviandoContrasena;
  final Color color;

  const BotonesPerfilAcciones({
    super.key,
    required this.onEditar,
    required this.onCambiarContrasena,
    required this.onCerrarSesion,
    required this.enviandoContrasena,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onEditar,
            icon: const Icon(Icons.edit, color: Colors.black),
            label: const Text('Editar Perfil', style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: enviandoContrasena ? null : onCambiarContrasena,
            icon: enviandoContrasena
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.lock_reset, color: Colors.black),
            label: const Text('Cambiar contraseña', style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade400,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onCerrarSesion,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}