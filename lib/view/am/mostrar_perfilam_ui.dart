import 'package:flutter/material.dart';

import '../../model/am/registro_am.dart';
import '../../model/comunas_disponibles.dart';
import '../../model/reglas_edad.dart';
import '../../viewmodel/am/mostrar_perfilam_vm.dart';
import '../widgets/am/tarjeta_dato_am.dart';
import '../widgets/am/dialogo_comuna_am.dart';
import 'editar_campo_am_ui.dart';
import '../widgets/am/capitalizar_texto.dart';

class MostrarDatosAMView extends StatefulWidget {
  const MostrarDatosAMView({super.key});

  @override
  State<MostrarDatosAMView> createState() => _MostrarDatosAMViewState();
}

class _MostrarDatosAMViewState extends State<MostrarDatosAMView> {
  final MostrarDatosAMViewModel _viewModel = MostrarDatosAMViewModel();

  AdultoMayorModel? _datos;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final datos = await _viewModel.cargarDatos();
    if (!mounted) return;
    setState(() {
      _datos = datos;
      _cargando = false;
    });
  }

  Future<void> _editarTexto({
    required String titulo,
    required IconData icono,
    required String campoFirestore,
    required String valorInicial,
    required String mensajeErrorVacio,
    int minLength = 2,
  }) async {
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarCampoAMView(
          titulo: titulo,
          icono: icono,
          campoFirestore: campoFirestore,
          valorInicial: valorInicial,
          validar: (texto) =>
              texto.trim().length < minLength ? mensajeErrorVacio : null,
          transformar: (texto) => capitalizar(texto),
        ),
      ),
    );
    if (actualizado == true) _cargarDatos();
  }

  Future<void> _editarNumero({
    required String titulo,
    required IconData icono,
    required String campoFirestore,
    required String valorInicial,
    required int maxLength,
    required String? Function(String texto) validar,
    required dynamic Function(String texto) transformar,
  }) async {
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarCampoAMView(
          titulo: titulo,
          icono: icono,
          campoFirestore: campoFirestore,
          valorInicial: valorInicial,
          esNumerico: true,
          maxLength: maxLength,
          textAlign: TextAlign.center,
          validar: validar,
          transformar: transformar,
        ),
      ),
    );
    if (actualizado == true) _cargarDatos();
  }

  Future<void> _editarComuna() async {
    final seleccion = await mostrarDialogoComunaAM(
      context,
      opciones: ComunasDisponibles.lista,
      actual: _datos?.comuna,
    );
    if (seleccion != null) {
      await _viewModel.actualizarComuna(seleccion);
      _cargarDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis datos', style: TextStyle(fontSize: 22)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF941F),
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _datos == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No se pudieron cargar sus datos.',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TarjetaDatoAM(
                    icono: Icons.person,
                    etiqueta: 'Nombre',
                    valor: _datos!.nombre,
                    onEditar: () => _editarTexto(
                      titulo: 'Nombre',
                      icono: Icons.person,
                      campoFirestore: 'nombre',
                      valorInicial: _datos!.nombre,
                      mensajeErrorVacio: 'NOMBRE NO ESCRITO',
                    ),
                  ),
                  TarjetaDatoAM(
                    icono: Icons.person_outline,
                    etiqueta: 'Apellido',
                    valor: _datos!.apellido,
                    onEditar: () => _editarTexto(
                      titulo: 'Apellido',
                      icono: Icons.person_outline,
                      campoFirestore: 'apellido',
                      valorInicial: _datos!.apellido,
                      mensajeErrorVacio: 'APELLIDO NO INGRESADO',
                    ),
                  ),
                  TarjetaDatoAM(
                    icono: Icons.cake,
                    etiqueta: 'Edad',
                    valor: _datos!.edad == null ? '' : '${_datos!.edad} años',
                    onEditar: () => _editarNumero(
                      titulo: 'Edad',
                      icono: Icons.cake,
                      campoFirestore: 'edad',
                      valorInicial: _datos!.edad?.toString() ?? '',
                      maxLength: 2,
                      validar: (texto) => ReglasEdad.validar(texto) == null
                          ? 'EDAD NO VÁLIDA'
                          : null,
                      transformar: (texto) => int.parse(texto),
                    ),
                  ),
                  TarjetaDatoAM(
                    icono: Icons.phone,
                    etiqueta: 'Teléfono',
                    valor: _datos!.telefono,
                  ),
                  TarjetaDatoAM(
                    icono: Icons.signpost,
                    etiqueta: 'Calle',
                    valor: _datos!.calle,
                    onEditar: () => _editarTexto(
                      titulo: 'Calle',
                      icono: Icons.signpost,
                      campoFirestore: 'calle',
                      valorInicial: _datos!.calle,
                      mensajeErrorVacio: 'CALLE NO ESCRITA',
                      minLength: 3,
                    ),
                  ),
                  TarjetaDatoAM(
                    icono: Icons.numbers,
                    etiqueta: 'Número',
                    valor: _datos!.numero,
                    onEditar: () => _editarNumero(
                      titulo: 'Número',
                      icono: Icons.numbers,
                      campoFirestore: 'numero',
                      valorInicial: _datos!.numero,
                      maxLength: 6,
                      validar: (texto) => texto.trim().isEmpty
                          ? 'ESCRIBA SU NUMERO DE HOGAR'
                          : null,
                      transformar: (texto) => texto.trim(),
                    ),
                  ),
                  TarjetaDatoAM(
                    icono: Icons.map,
                    etiqueta: 'Comuna',
                    valor: _datos!.comuna,
                    onEditar: _editarComuna,
                  ),
                  TarjetaDatoAM(
                    icono: Icons.badge,
                    etiqueta: 'RUT',
                    valor: _datos!.rut,
                  ),
                ],
              ),
      ),
    );
  }
}
