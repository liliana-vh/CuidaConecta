class ListaServicios {
  static const List<String> nombres = [
    'Acompañamiento y apoyo básico',
    'Cuidado a domicilio avanzado',
  ];

  // Resumen corto para detalles
  static const Map<String, String> descripciones = {
    'Acompañamiento y apoyo básico':
        'Compañía, alimentación, compras, orden básico, paseos, estimulación cognitiva, recordatorios de medicamentos.',
    'Cuidado a domicilio avanzado':
        'Acompañamiento y apoyo básico + asistencia en higiene personal, movilidad, asistencia con medicamentos o tratamientos médicos.',
  };

  // Tareas servicios (hacer mas largas o cortas? RECORDAR)
  static const Map<String, List<String>> tareas = {
    'Acompañamiento y apoyo básico': [
      'Brindar compañía y conversación',
      'Preparación comidas',
      'Realizar compras necesarias',
      'Orden basico del espacio',
      'Sacar a paseos',
      'Recordatorio de medicamentos',
    ],
    'Cuidado a domicilio avanzado': [
      'Asistencia en higiene personal',
      'Asistencia en movilidad',
      'Asistencia con medicamentos o tratamientos médicos',
    ],
  };

  static const Map<String, String> incluye = {
    'Cuidado a domicilio avanzado': 'Acompañamiento y apoyo básico',
  };

  /// resumido 1
  static const Map<String, String> nombresCortos = {
    'Acompañamiento y apoyo básico': 'Compañía y ayuda basica',
    'Cuidado a domicilio avanzado': 'Cuidado y ayuda avanzada',
  };

  //resumido 2
  static const Map<String, String> resumenesSimples = {
    'Acompañamiento y apoyo básico':
        'Compañía, comidas, orden, paseos y recordatorio medicamentos.',
    'Cuidado a domicilio avanzado':
        'Compañia y ayuda basica, además de ayuda con el aseo, movimiento y los medicamentos.',
  };
}