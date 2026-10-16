
//estados que se guardan a firestore 
class EstadoSolicitud {
  static const String pendiente = 'pendiente';
  static const String aceptada = 'aceptada';
  static const String enProgreso = 'en_progreso';
  static const String finalizada = 'finalizada';
  static const String rechazada = 'rechazada';

  static const List<String> queOcupanAgenda = [aceptada, enProgreso];

  //solicitudes activas para clientes
  static const List<String> activas = [pendiente, aceptada, enProgreso];
}

class EstadoSesion {
  static const String pendiente = 'pendiente';
  static const String enProgreso = 'en_progreso';
  static const String finalizada = 'finalizada';
}

class MetodoPago {
  static const String tarjeta = 'tarjeta';
  static const String efectivo = 'efectivo';
}