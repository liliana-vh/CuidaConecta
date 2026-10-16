class ReglasEdad {
  static const int minima = 45;
  static const int maxima = 90;

  static String get mensajeError =>
      'Ingrese una edad entre $minima y $maxima años.';

  static int? validar(String texto) {
    final edad = int.tryParse(texto.trim());
    if (edad == null || edad < minima || edad > maxima) return null;
    return edad;
  }
}