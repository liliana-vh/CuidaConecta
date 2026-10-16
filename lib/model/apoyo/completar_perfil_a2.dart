class PerfilA2Model {
  final String comuna;
  final String calle;
  final String numero;
  final String detalles;

  PerfilA2Model({
    required this.comuna,
    required this.calle,
    required this.numero,
    this.detalles = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'direccionServicio': {
        'comuna': comuna,
        'calle': calle,
        'numero': numero,
        'detalles': detalles,
      },
    };
  }
}