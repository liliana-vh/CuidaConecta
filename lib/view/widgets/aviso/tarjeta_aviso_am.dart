import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/lista_servicios.dart';
import '../../../model/cuidador/aviso_servicio.dart';
import '../formato_horarios.dart';

//tarjeta aviso version am
class TarjetaAvisoAM extends StatelessWidget {
  final AvisoServicio aviso;
  final VoidCallback onTap;

  const TarjetaAvisoAM({super.key, required this.aviso, required this.onTap});

  static const Color _naranja = Color(0xFFFF941F);

  static final NumberFormat _moneda = NumberFormat.currency(
    locale: 'es_CL',
    customPattern: '\$#,##0',
    decimalDigits: 0,
  );

  // Junta los dias que comparten horario
  @override
  Widget build(BuildContext context) {
    final foto = aviso.fotoCuidador;
    final nombre = aviso.nombreCuidador;
    final servicios = aviso.servicios
        .map((s) => ListaServicios.nombresCortos[s] ?? s)
        .toList();
    final horarios = horariosAgrupados(aviso.disponibilidad);

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: _naranja,
                    backgroundImage: foto != null ? NetworkImage(foto) : null,
                    child: foto != null
                        ? null
                        : Text(
                            nombre.isNotEmpty ? nombre[0].toUpperCase() : 'C',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                aviso.titulo,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _naranja,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      _moneda.format(aviso.tarifaHora),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      'por hora',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (servicios.isNotEmpty)
                _fila(Icons.volunteer_activism, unirConY(servicios)),
              if (aviso.comuna.isNotEmpty) _fila(Icons.place, aviso.comuna),
              for (final linea in horarios) _fila(Icons.schedule, linea),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Ver más'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fila(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 28, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
