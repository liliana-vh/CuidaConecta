//como se ven horarios aviso
const List<String> _ordenDias = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

// ["a", "b", "c"] -> "a, b y c"
String unirConY(List<String> items) {
  if (items.length <= 1) return items.join();
  return '${items.sublist(0, items.length - 1).join(', ')} y ${items.last}';
}

List<String> horariosAgrupados(Map<String, dynamic> disponibilidad) {
  final grupos = <String, List<String>>{};

  for (final dia in _ordenDias) {
    final franja = disponibilidad[dia];
    if (franja is! Map) continue;

    final inicio = '${franja['inicio']}';
    final fin = '${franja['fin']}';
    final horario = inicio == '24 horas' ? 'las 24 horas' : 'de $inicio a $fin';

    grupos.putIfAbsent(horario, () => []).add(dia);
  }

  return grupos.entries.map((e) => '${unirConY(e.value)}: ${e.key}').toList();
}