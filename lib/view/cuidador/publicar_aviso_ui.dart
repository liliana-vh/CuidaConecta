import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/cuidador/publicar_aviso_vm.dart';
import '../widgets/aviso/selector_disponibilidad.dart';

// Si recibe idAviso funciona en modo edición
class PublicarAvisoView extends StatelessWidget {
  final String? idAviso;

  const PublicarAvisoView({super.key, this.idAviso});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PublicarAvisoViewModel(idAviso: idAviso)..cargarPerfil(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const Color _naranja = Color(0xFFFF941F);

  Future<void> _seleccionarHora(
    BuildContext context,
    PublicarAvisoViewModel vm,
    String dia, {
    required bool esInicio,
  }) async {
    final actual = esInicio ? vm.horaInicioDe(dia) : vm.horaFinDe(dia);

    final hora = await showTimePicker(
      context: context,
      initialTime: actual ?? TimeOfDay(hour: esInicio ? 9 : 13, minute: 0),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (hora != null) vm.fijarHora(dia, esInicio: esInicio, hora: hora);
  }

  Future<void> _publicar(
    BuildContext context,
    PublicarAvisoViewModel vm,
  ) async {
    FocusScope.of(context).unfocus();

    try {
      await vm.publicar();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vm.esEdicion
                ? 'Cambios guardados'
                : 'Aviso publicado correctamente',
          ),
        ),
      );

      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/cuidador/inicio');
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PublicarAvisoViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(vm.esEdicion ? 'Editar Aviso' : 'Publicar Nuevo Aviso'),
        backgroundColor: _naranja,
        centerTitle: true,
      ),
      body: SafeArea(child: _buildCuerpo(context, vm)),
    );
  }

  Widget _buildCuerpo(BuildContext context, PublicarAvisoViewModel vm) {
    if (vm.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorCarga != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            vm.errorCarga!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (vm.esEdicion)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Los cambios no afectan los servicios ya contratados.',
              style: TextStyle(color: Colors.black54),
            ),
          ),

        TextField(
          controller: vm.tituloController,
          decoration: const InputDecoration(
            labelText: 'Título del aviso',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: vm.descripcionController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Descripción / Detalles del servicio',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            const Icon(Icons.place, color: _naranja),
            const SizedBox(width: 8),
            Text(
              'Comuna: ${vm.comuna.isEmpty ? 'No definida' : vm.comuna}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextField(
          controller: vm.tarifaController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Tarifa por hora',
            prefixText: '\$ ',
            suffixText: 'por hora',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Tipo de servicio',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        if (vm.serviciosDisponibles.isEmpty)
          const Text(
            'Tu perfil no tiene servicios registrados.',
            style: TextStyle(color: Colors.black54),
          )
        else
          Wrap(
            spacing: 6,
            children: vm.serviciosDisponibles.map((servicio) {
              return ChoiceChip(
                label: Text(servicio),
                selected: vm.servicioSeleccionado(servicio),
                onSelected: (v) {
                  if (v) vm.seleccionarServicio(servicio);
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 20),

        SelectorDisponibilidad(
          vm: vm,
          onSeleccionarHora: (dia, {required esInicio}) =>
              _seleccionarHora(context, vm, dia, esInicio: esInicio),
        ),

        const SizedBox(height: 24),

        vm.guardando
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _publicar(context, vm),
                  icon: Icon(vm.esEdicion ? Icons.save : Icons.send),
                  label: Text(vm.esEdicion ? 'Guardar cambios' : 'Publicar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _naranja,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
        const SizedBox(height: 36),
      ],
    );
  }
}
