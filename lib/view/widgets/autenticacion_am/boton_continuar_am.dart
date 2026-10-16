import 'package:flutter/material.dart';

// Boton CONTINUAR de las pantallas de autenticacion am (mezclar con el otro boton o no? RECORDAR)
class BotonContinuarAM extends StatelessWidget {
  final bool cargando;
  final VoidCallback onPressed;
  final IconData icono;
  final String texto;
  final double fontSize;

  const BotonContinuarAM({
    super.key,
    required this.cargando,
    required this.onPressed,
    this.icono = Icons.arrow_forward_rounded,
    this.texto = 'Continuar',
    this.fontSize = 20,
  });

  static const Color _rojo = Color(0xFFE51B23);

  @override
  Widget build(BuildContext context) {
    if (cargando) return const CircularProgressIndicator();

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icono, size: 24),
      label: Text(texto, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _rojo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}