import 'package:cloud_firestore/cloud_firestore.dart';

class TareaRealizada {
  final String titulo;
  final bool completada;
  final String? comentario;
  final DateTime? fechaActualizacion;

  const TareaRealizada({
    required this.titulo,
    this.completada = false,
    this.comentario,
    this.fechaActualizacion,
  });

  TareaRealizada copiarCon({
    bool? completada,
    String? comentario,
    DateTime? fechaActualizacion,
  }) {
    return TareaRealizada(
      titulo: titulo,
      completada: completada ?? this.completada,
      comentario: comentario ?? this.comentario,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  factory TareaRealizada.desdeMapa(Map<String, dynamic> mapa) {
    return TareaRealizada(
      titulo: mapa['titulo'] ?? '',
      completada: mapa['completada'] ?? false,
      comentario: mapa['comentario'] as String?,
      fechaActualizacion:
          (mapa['fechaActualizacion'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'completada': completada,
      if (comentario != null) 'comentario': comentario,
      if (fechaActualizacion != null)
        'fechaActualizacion': Timestamp.fromDate(fechaActualizacion!),
    };
  }
}