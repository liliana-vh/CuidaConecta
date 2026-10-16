//ahora mismo solo para los teclados espeicales de am, usar en otros usuarios?
String capitalizar(String texto) {
  final palabras = texto.trim().toLowerCase().split(' ');
  return palabras
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + p.substring(1))
      .join(' ');
}