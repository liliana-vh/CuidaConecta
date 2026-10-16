// calculo de rut chileno mod 11

String limpiarRut(String rut) => rut.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();

String _calcularDv(String rut) {
  int suma = 0, multiplo = 2;
  for (int i = rut.length - 1; i >= 0; i--) {
    suma += int.parse(rut[i]) * multiplo;
    multiplo = multiplo == 7 ? 2 : multiplo + 1;
  }
  final resto = 11 - (suma % 11);
  if (resto == 11) return "0";
  if (resto == 10) return "K";
  return resto.toString();
}

bool validarRut(String rut) {
  rut = limpiarRut(rut);
  if (rut.length < 2) return false;
  final cuerpo = rut.substring(0, rut.length - 1);
  final dv = rut.substring(rut.length - 1);
  if (int.tryParse(cuerpo) == null) return false;
  return _calcularDv(cuerpo) == dv;
}

String formatearRut(String rut) {
  rut = limpiarRut(rut);
  if (rut.length < 2) return rut;
  final cuerpo = rut.substring(0, rut.length - 1);
  final dv = rut.substring(rut.length - 1);
  final formateado = cuerpo.replaceAllMapped(RegExp(r'(?=(?:...)+$)'), (m) => m.start == 0 ? '' : '.');
  return "$formateado-$dv";
}