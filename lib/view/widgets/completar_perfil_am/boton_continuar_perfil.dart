import 'package:flutter/material.dart';

/// Botón de avanzar/finalizar completar perfil am inicial
class BotonContinuarPerfil extends StatelessWidget {
  final bool cargando;
  final VoidCallback onPressed;
  final bool esFinal;

  const BotonContinuarPerfil({
    super.key,
    required this.cargando,
    required this.onPressed,
    this.esFinal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        esFinal ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
        size: 26,
      ),
      label: Text(
        esFinal ? 'Finalizar' : 'Continuar',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: esFinal ? Colors.green.shade600 : const Color(0xFFE51B23),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}