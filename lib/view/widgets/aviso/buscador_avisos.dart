import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../viewmodel/filtro_avisos.dart';

// Barra de búsqueda + botón de filtros
class BuscadorAvisos extends StatelessWidget {
  final FiltroAvisos filtro;
  final List<String> servicios;
  final double tarifaTope;
  final int Function() contarResultados;

  // false si esa pantalla ya filtra por servicio (ej: adulto mayor AGREGAR LEUGO)
  final bool mostrarServicio;

  const BuscadorAvisos({
    super.key,
    required this.filtro,
    required this.servicios,
    required this.tarifaTope,
    required this.contarResultados,
    this.mostrarServicio = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: filtro.cambiarTexto,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, título o servicio',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Filtros',
            onPressed: () => _abrirPanel(context),
            icon: Badge(
              isLabelVisible: filtro.cantidadFiltros > 0,
              label: Text('${filtro.cantidadFiltros}'),
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PanelFiltros(
        filtro: filtro,
        servicios: servicios,
        tarifaTope: tarifaTope,
        contarResultados: contarResultados,
        mostrarServicio: mostrarServicio,
      ),
    );
  }
}

class _PanelFiltros extends StatelessWidget {
  final FiltroAvisos filtro;
  final List<String> servicios;
  final double tarifaTope;
  final int Function() contarResultados;
  final bool mostrarServicio;

  const _PanelFiltros({
    required this.filtro,
    required this.servicios,
    required this.tarifaTope,
    required this.contarResultados,
    required this.mostrarServicio,
  });

  static const Color _naranja = Color(0xFFFF941F);

  static final NumberFormat _moneda = NumberFormat.currency(
    locale: 'es_CL',
    customPattern: '\$#,##0',
    decimalDigits: 0,
  );

  String _textoTarifa() {
    final min = filtro.tarifaMin;
    final max = filtro.tarifaMax;
    if (min == null && max == null) return 'Tarifa por hora: cualquiera';
    if (min == null) return 'Tarifa por hora: hasta ${_moneda.format(max)}';
    if (max == null) return 'Tarifa por hora: desde ${_moneda.format(min)}';
    return 'Tarifa por hora: ${_moneda.format(min)} - ${_moneda.format(max)}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: filtro,
      builder: (context, _) {
        final fin = (filtro.tarifaMax ?? tarifaTope)
            .clamp(0.0, tarifaTope)
            .toDouble();
        final inicio = (filtro.tarifaMin ?? 0).clamp(0.0, fin).toDouble();

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: filtro.limpiar,
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),

                if (mostrarServicio && servicios.isNotEmpty) ...[
                  _titulo('Servicio'),
                  _opciones(servicios, filtro.servicio, filtro.elegirServicio),
                ],

                _titulo('Día disponible'),
                _opciones(FiltroAvisos.dias, filtro.dia, filtro.elegirDia),

                if (tarifaTope > 0) ...[
                  _titulo(_textoTarifa()),
                  RangeSlider(
                    min: 0,
                    max: tarifaTope,
                    divisions: (tarifaTope / 1000).round(),
                    values: RangeValues(inicio, fin),
                    activeColor: _naranja,
                    onChanged: (v) =>
                        filtro.elegirTarifa(v.start, v.end, tarifaTope),
                  ),
                ],

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _naranja,
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Ver ${contarResultados()} avisos'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _opciones(
    List<String> opciones,
    String? elegida,
    void Function(String?) alElegir,
  ) {
    return Wrap(
      spacing: 8,
      children: [
        for (final o in opciones)
          ChoiceChip(
            label: Text(o),
            selected: elegida == o,
            selectedColor: _naranja.withValues(alpha: 0.3),
            onSelected: (marcado) => alElegir(marcado ? o : null),
          ),
      ],
    );
  }
}
