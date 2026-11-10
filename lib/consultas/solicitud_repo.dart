import 'package:cloud_firestore/cloud_firestore.dart';
import 'streams_sesion.dart';
import '../model/solicitud/agenda.dart';
import '../model/solicitud/estado_solicitud.dart';
import '../model/solicitud/sesion_solicitud.dart';
import '../model/solicitud/solicitud.dart';
import '../model/chat/mensaje.dart';
import '../viewmodel/utilidades/fecha_hora.dart';

class SolicitudRepo {
  final CollectionReference<Map<String, dynamic>> _coleccion = FirebaseFirestore
      .instance
      .collection('solicitudes');

  Stream<List<Solicitud>> solicitudesDeCuidador(String uidCuidador) {
    return _coleccion
        .where('uidCuidador', isEqualTo: uidCuidador)
        .snapshots()
        .map(_aListaOrdenada)
        .hastaCerrarSesion();
  }

  Stream<List<Solicitud>> solicitudesDeCliente(String uidCliente) {
    return _coleccion
        .where('uidCliente', isEqualTo: uidCliente)
        .snapshots()
        .map(_aListaOrdenada)
        .hastaCerrarSesion();
  }

  Stream<Solicitud?> solicitud(String id) {
    return _coleccion
        .doc(id)
        .snapshots()
        .map(
          (doc) => doc.exists ? Solicitud.desdeMapa(doc.id, doc.data()!) : null,
        )
        .hastaCerrarSesion();
  }

  Future<Solicitud?> obtener(String id) async {
    final doc = await _coleccion.doc(id).get();
    if (!doc.exists) return null;
    return Solicitud.desdeMapa(doc.id, doc.data()!);
  }

  Future<List<Sesion>> sesionesOcupadasDeCuidador(
    String uidCuidador, {
    String? excluirSolicitud,
  }) async {
    final snapshot = await _coleccion
        .where('uidCuidador', isEqualTo: uidCuidador)
        .where('estado', whereIn: EstadoSolicitud.queOcupanAgenda)
        .get();

    return snapshot.docs
        .where((d) => d.id != excluirSolicitud)
        .expand((d) => Solicitud.desdeMapa(d.id, d.data()).sesiones)
        .toList();
  }

  Future<List<Sesion>> sesionesActivasDeCliente(String uidCliente) async {
    final snapshot = await _coleccion
        .where('uidCliente', isEqualTo: uidCliente)
        .where('estado', whereIn: EstadoSolicitud.activas)
        .get();

    return snapshot.docs
        .expand((d) => Solicitud.desdeMapa(d.id, d.data()).sesiones)
        .toList();
  }

  // ESCRITURA ////////////////////////////////////////////////////////////////////////////////////

  Future<String> crear(Solicitud solicitud) async {
    final ref = await _coleccion.add(solicitud.toMap());
    return ref.id;
  }

  Future<void> aceptar(String id) {
    return _transformar(id, (s) async {
      if (s.estado != EstadoSolicitud.pendiente) {
        throw Exception('Esta solicitud ya no está pendiente.');
      }

      final ocupadas = await sesionesOcupadasDeCuidador(
        s.uidCuidador,
        excluirSolicitud: s.id,
      );
      final agenda = Agenda(ocupadas);

      for (final sesion in s.sesiones) {
        if (agenda.hayConflicto(sesion.inicio, sesion.fin)) {
          throw Exception(
            'Ya no se puede aceptar: choca con otra solicitud aceptada '
            'en ese horario.',
          );
        }
      }

      return {'estado': EstadoSolicitud.aceptada};
    });
  }

  Future<void> rechazar(String id, {String? motivo}) {
    return _coleccion.doc(id).update({
      'estado': EstadoSolicitud.rechazada,
      if (motivo != null && motivo.isNotEmpty) 'motivo': motivo,
    });
  }

  //cambio a estado 'en progreso' + mensaje de sistema en el chat
  Future<void> iniciarSesion(String id, int indice) {
    final mensajes = <Mensaje>[];

    return _transformar(id, (s) async {
      final motivo = s.motivoNoPuedeIniciar(indice, DateTime.now());
      if (motivo != null) throw Exception(motivo);

      final ahora = DateTime.now();
      final sesiones = [...s.sesiones];
      sesiones[indice] = sesiones[indice].copiarCon(
        estado: EstadoSesion.enProgreso,
        inicioReal: ahora,
      );

      final inicio = s.sesiones[indice].inicio;
      mensajes.add(
        Mensaje.automatico(
          'El cuidador inició el servicio del ${nombreDia(inicio)} '
          '${dm(inicio)} a las ${hhmm(ahora)}. El chat está activo.',
        ),
      );

      return {
        'sesiones': sesiones.map((x) => x.toMap()).toList(),
        'estado': EstadoSolicitud.enProgreso,
      };
    }, mensajes: mensajes);
  }

  Future<void> finalizarSesion(String id, int indice) {
    final mensajes = <Mensaje>[];

    return _transformar(id, (s) async {
      if (indice < 0 || indice >= s.sesiones.length) {
        throw Exception('Sesión inválida.');
      }
      if (s.sesiones[indice].estado != EstadoSesion.enProgreso) {
        throw Exception('Esta sesión no está en curso.');
      }

      final sesiones = [...s.sesiones];
      sesiones[indice] = sesiones[indice].copiarCon(
        estado: EstadoSesion.finalizada,
        finReal: DateTime.now(),
      );

      final quedanPorHacer = sesiones.any(
        (x) => x.estado != EstadoSesion.finalizada,
      );

      // mensaje automático////////////////////////////////////////////////////////////////
      if (quedanPorHacer) {
        final pendientes = sesiones
            .where((x) => x.estado == EstadoSesion.pendiente)
            .toList();
        mensajes.add(
          Mensaje.automatico(
            pendientes.isEmpty
                ? 'Servicio del día finalizado. El chat se cerró.'
                : 'Servicio del día finalizado. El chat se cerró y se '
                    'activará en la próxima sesión: '
                    '${nombreDia(pendientes.first.inicio)} '
                    '${dm(pendientes.first.inicio)} a las '
                    '${hhmm(pendientes.first.inicio)}.',
          ),
        );
      } else if (s.metodoPago == MetodoPago.tarjeta) {
        mensajes.add(
          Mensaje.automatico(
            'El servicio finalizó por completo. Ya se puede pagar el saldo '
            'desde los detalles de la solicitud. Fecha máxima de pago: '
            '${nombreDia(s.fechaPago)} ${dm(s.fechaPago)}.',
          ),
        );
      } else {
        mensajes.add(
          Mensaje.automatico(
            'El servicio finalizó por completo. El pago en efectivo lo '
            'confirma el cuidador desde la app.',
          ),
        );
      }

      return {
        'sesiones': sesiones.map((x) => x.toMap()).toList(),
        'estado': quedanPorHacer
            ? EstadoSolicitud.enProgreso
            : EstadoSolicitud.finalizada,
      };
    }, mensajes: mensajes);
  }

  Future<void> actualizarTarea(
    String id,
    int indiceSesion,
    int indiceTarea, {
    required bool completada,
    String? comentario,
  }) {
    final mensajes = <Mensaje>[];

    return _transformar(id, (s) async {
      if (indiceSesion < 0 || indiceSesion >= s.sesiones.length) {
        throw Exception('Sesión inválida.');
      }
      final sesion = s.sesiones[indiceSesion];
      if (sesion.estado != EstadoSesion.enProgreso) {
        throw Exception(
          'Solo se pueden marcar tareas mientras la sesión está en curso.',
        );
      }
      if (indiceTarea < 0 || indiceTarea >= sesion.tareas.length) {
        throw Exception('Tarea inválida.');
      }

      final tareas = [...sesion.tareas];
      tareas[indiceTarea] = tareas[indiceTarea].copiarCon(
        completada: completada,
        comentario: comentario,
        fechaActualizacion: DateTime.now(),
      );

      final sesiones = [...s.sesiones];
      sesiones[indiceSesion] = sesion.copiarCon(tareas: tareas);

      mensajes.add(
        Mensaje.automatico(
          _textoActividad(tareas[indiceTarea].titulo, completada, comentario),
        ),
      );

      return {'sesiones': sesiones.map((x) => x.toMap()).toList()};
    }, mensajes: mensajes);
  }

  Future<void> pagarGarantia(String id) {
    return _transformar(id, (s) async {
      if (s.estado != EstadoSolicitud.aceptada) {
        throw Exception('La solicitud debe estar aceptada.');
      }
      if (!s.requiereGarantia) {
        throw Exception('Esta solicitud no requiere garantía.');
      }
      if (s.garantiaPagada) {
        throw Exception('La garantía ya fue pagada.');
      }
      return {'garantiaPagada': true};
    });
  }

  //sim pago cuidador
  Future<void> registrarPagoFinal(String id) {
    return _transformar(id, (s) async {
      if (!s.puedePagarFinal) {
        throw Exception('Aún no se puede pagar: falta finalizar el servicio.');
      }
      return {
        'pagoRealizado': true,
        'comisionPlataforma': s.calcularComision(),
      };
    });
  }

  Future<void> reportarImpago(String id) {
    return _transformar(id, (s) async {
      if (!s.pagoVencido) {
        throw Exception('Este pago todavía no está vencido.');
      }
      return {'impagoReportado': true};
    });
  }

  // AYUDANTES ///////////////////////////////////////////////////////////

  // Lectura y actualizaciones solcitud
  Future<void> _transformar(
    String id,
    Future<Map<String, dynamic>> Function(Solicitud s) cambios, {
    List<Mensaje>? mensajes,
  }) async {
    final ref = _coleccion.doc(id);

    final doc = await ref.get();
    if (!doc.exists) throw Exception('La solicitud ya no existe.');
    final solicitud = Solicitud.desdeMapa(doc.id, doc.data()!);
    final actualizacion = await cambios(solicitud);

    return FirebaseFirestore.instance.runTransaction((tx) async {
      final docActual = await tx.get(ref);
      if (!docActual.exists) throw Exception('La solicitud ya no existe.');
      tx.update(ref, actualizacion);

      // mensajes aut del chat
      for (final m in mensajes ?? const <Mensaje>[]) {
        tx.set(ref.collection('mensajes').doc(), m.toMap());
      }
    });
  }

  String _textoActividad(String titulo, bool completada, String? comentario) {
    final base = completada
        ? 'Actividad completada: $titulo'
        : 'Actividad desmarcada: $titulo';
    final nota = comentario?.trim() ?? '';
    return nota.isEmpty ? base : '$base\nNota: $nota';
  }

  List<Solicitud> _aListaOrdenada(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final ahora = DateTime.now().millisecondsSinceEpoch;
    int ms(dynamic t) => t is Timestamp ? t.millisecondsSinceEpoch : ahora;

    final docs = snapshot.docs.toList()
      ..sort(
        (a, b) => ms(b.data()['creadaEn']).compareTo(ms(a.data()['creadaEn'])),
      );

    return docs.map((d) => Solicitud.desdeMapa(d.id, d.data())).toList();
  }
}