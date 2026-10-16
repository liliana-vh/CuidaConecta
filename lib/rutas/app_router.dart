import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// cosas no hechas aun (chat, comprobantes, evaluaciones, hacer pantalla 'falsa' sim pago o solo boton? PREGUNTAR PROFE)
import '../view/widgets/placeholder_funcionalidad.dart';

// bienvenida y autenticacion
import '../view/bienvenida.dart';
import '../view/seleccion_iniciar.dart';
import '../view/seleccion_usuario.dart';
import '../view/am/registro_am_ui.dart';
import '../view/am/login_am_ui.dart';
import '../view/autenticacion/registro_ca_ui.dart';
import '../view/autenticacion/login_ca_ui.dart';

// completar perfil
import '../view/apoyo/completar_perfila1_ui.dart';
import '../view/apoyo/completar_perfila2_ui.dart';
import '../view/apoyo/completar_perfila3_ui.dart';
import '../view/cuidador/completar_perfilc1_ui.dart';
import '../view/cuidador/completar_perfilc2_ui.dart';
import '../view/am/completar_perfilam1_ui.dart';
import '../view/am/completar_perfilam2_ui.dart';
import '../view/am/completar_perfilam3_ui.dart';
import '../view/am/completar_perfilam4_ui.dart';
import '../view/am/completar_perfilam5_ui.dart';
import '../view/am/completar_perfilam6_ui.dart';

// compartidas
import '../view/detalle_aviso_ui.dart';
import '../view/historial_solicitudes_ui.dart';
import '../view/solicitudes_ui.dart';
import '../view/detalle_solicitud_ui.dart';
import '../view/widgets/visor_pdf.dart';

// flujo cuidador
import '../view/cuidador/inicio_c_ui.dart';
import '../view/cuidador/mostrar_perfilc_ui.dart';
import '../view/cuidador/editar_perfilc_ui.dart';
import '../view/cuidador/publicar_aviso_ui.dart';

// flujo apoyo
import '../view/apoyo/inicio_a_ui.dart';
import '../view/apoyo/mostrar_perfila_ui.dart';
import '../view/apoyo/editar_perfila_ui.dart';
import '../view/apoyo/agendar_a_ui.dart';

// flujo adulto mayor
import '../view/am/inicio_am_ui.dart';
import '../view/am/catalogo_avisos_ui.dart';
import '../view/am/avisos_filtrados_ui.dart';
import '../view/am/detalle_avisoam_ui.dart';
import '../view/am/agendar_am_ui.dart';
import '../view/am/solicitudes_am_ui.dart';
import '../view/am/detalle_solicitudam_ui.dart';
import '../view/am/mostrar_perfilam_ui.dart';

const Color _naranja = Color(0xFFFF941F);

// SHELL (barra inferior compartida por cuidador y apoyo) //////////////////////////////////////////////
class _ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<String> titulos;
  final List<BottomNavigationBarItem> items;

  const _ShellScaffold({
    required this.navigationShell,
    required this.titulos,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titulos[navigationShell.currentIndex],
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: _naranja,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        selectedItemColor: _naranja,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}

// una pestaña del shell = una rama con una sola ruta
StatefulShellBranch _rama(String path, Widget Function() pantalla) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (_, __) => pantalla())],
  );
}

// INICIO Y AUTENTICACIÓN //////////////////////////////////////////////////////////////////////////////
final List<RouteBase> _rutasInicioYAuth = [
  GoRoute(path: '/', builder: (_, __) => const Bienvenida()),
  GoRoute(
    path: '/auth/seleccion-iniciar',
    builder: (_, __) => const SeleccionIniciar(),
  ),
  GoRoute(
    path: '/auth/seleccion-usuario',
    builder: (_, __) => const SeleccionUsuario(),
  ),
  GoRoute(
    path: '/auth/login-am',
    builder: (_, __) => const LoginAdultoMayorView(),
  ),
  GoRoute(
    path: '/auth/login-cuidador-apoyo',
    builder: (_, __) => const LoginCuidadorApoyoView(),
  ),
  GoRoute(
    path: '/auth/registro-am',
    builder: (_, __) => const RegistroAdultoMayorView(),
  ),
  GoRoute(
    path: '/auth/registro-cuidador-apoyo',
    builder: (_, __) => const RegistroCuidadorApoyoView(),
  ),
];

// COMPLETAR PERFIL ////////////////////////////////////////////////////////////////////////////////////
final List<RouteBase> _rutasCompletarPerfil = [
  // apoyo
  GoRoute(
    path: '/apoyo/completar-perfil/paso-1',
    builder: (_, __) => const CompletarPerfilA1View(),
  ),
  GoRoute(
    path: '/apoyo/completar-perfil/paso-2',
    builder: (_, __) => const CompletarPerfilA2View(),
  ),
  GoRoute(
    path: '/apoyo/completar-perfil/paso-3',
    builder: (_, __) => const CompletarPerfilA3View(),
  ),

  // cuidador
  GoRoute(
    path: '/cuidador/completar-perfil/paso-1',
    builder: (_, __) => const CompletarPerfilC1View(),
  ),
  GoRoute(
    path: '/cuidador/completar-perfil/paso-2',
    builder: (_, __) => const CompletarPerfilC2View(),
  ),

  // adulto mayor
  GoRoute(
    path: '/am/completar-perfil/paso-1',
    builder: (_, __) => const CompletarPerfilAM1View(),
  ),
  GoRoute(
    path: '/am/completar-perfil/paso-2',
    builder: (_, state) {
      final data = state.extra as Map<String, dynamic>?;
      return CompletarPerfilAM2View(nombre: data?['nombre'] ?? '');
    },
  ),
  GoRoute(
    path: '/am/completar-perfil/paso-3',
    builder: (_, __) => const CompletarPerfilAM3View(),
  ),
  GoRoute(
    path: '/am/completar-perfil/paso-4',
    builder: (_, __) => const CompletarPerfilAM4View(),
  ),
  GoRoute(
    path: '/am/completar-perfil/paso-5',
    builder: (_, state) {
      final data = state.extra as Map<String, dynamic>?;
      return CompletarPerfilAM5View(comuna: data?['comuna'] ?? '');
    },
  ),
  GoRoute(
    path: '/am/completar-perfil/paso-6',
    builder: (_, state) {
      final data = state.extra as Map<String, dynamic>?;
      return CompletarPerfilAM6View(
        comuna: data?['comuna'] ?? '',
        calle: data?['calle'] ?? '',
      );
    },
  ),
];

// CUIDADOR ////////////////////////////////////////////////////////////////////////////////////////////
final List<RouteBase> _rutasCuidador = [
  // shell
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => _ShellScaffold(
      navigationShell: navigationShell,
      titulos: const ['Inicio', 'Mis Servicios', 'Mensajes', 'Mi Perfil'],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Servicios'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Mensajes'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    ),
    branches: [
      _rama('/cuidador/inicio', () => const InicioCuidadorView()),
      _rama('/cuidador/servicios', () => const SolicitudesView.cuidador()),
      _rama('/cuidador/mensajes', () => const PlaceholderFuncionalidad()),
      _rama('/cuidador/perfil', () => const PerfilCuidadorView()),
    ],
  ),

  // fuera del shell
  GoRoute(
    path: '/cuidador/editar-perfil',
    builder: (_, state) {
      final data = state.extra as Map<String, dynamic>?;
      return EditarPerfilCView(uid: data?['uid'] ?? '');
    },
  ),
  GoRoute(
    path: '/cuidador/publicar-aviso',
    builder: (_, __) => const PublicarAvisoView(),
  ),
  GoRoute(
    path: '/cuidador/editar-aviso/:id',
    builder: (_, state) =>
        PublicarAvisoView(idAviso: state.pathParameters['id']),
  ),
  GoRoute(
    path: '/cuidador/detalle-solicitud/:id',
    builder: (_, state) =>
        DetalleSolicitudView(idSolicitud: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/cuidador/historial-solicitudes',
    builder: (_, __) => const HistorialSolicitudesView.cuidador(),
  ),
];

// APOYO ///////////////////////////////////////////////////////////////////////////////////////////////
final List<RouteBase> _rutasApoyo = [
  // shell
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => _ShellScaffold(
      navigationShell: navigationShell,
      titulos: const [
        'Cuidadores Disponibles',
        'Mis Solicitudes',
        'Mensajes',
        'Mi Perfil',
      ],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Solicitudes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: 'Mensajes',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    ),
    branches: [
      _rama('/apoyo/inicio', () => const InicioApoyoView()),
      _rama('/apoyo/servicios', () => const SolicitudesView.apoyo()),
      _rama('/apoyo/mensajes', () => const PlaceholderFuncionalidad()),
      _rama('/apoyo/perfil', () => const PerfilApoyoView()),
    ],
  ),

  // fuera del shell
  GoRoute(
    path: '/apoyo/editar-perfil',
    name: 'editar_perfil_apoyo',
    builder: (_, state) {
      final data = state.extra as Map<String, dynamic>?;
      return EditarPerfilAView(uid: data?['uid'] ?? '');
    },
  ),
  GoRoute(
    path: '/apoyo/solicitar-servicio/:idAviso',
    name: 'solicitudServicio',
    builder: (_, state) =>
        AgendarView(idAviso: state.pathParameters['idAviso']!),
  ),
  GoRoute(
    path: '/apoyo/detalle-solicitud/:id',
    builder: (_, state) =>
        DetalleSolicitudView(idSolicitud: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/apoyo/historial-solicitudes',
    builder: (_, __) => const HistorialSolicitudesView.apoyo(),
  ),
];

// ADULTO MAYOR ////////////////////////////////////////////////////////////////////////////////////////
final List<RouteBase> _rutasAdultoMayor = [
  GoRoute(
    path: '/am/inicio',
    builder: (_, __) => const InicioAdultoMayorView(),
  ),
  GoRoute(
    path: '/am/mis-datos',
    builder: (_, __) => const MostrarDatosAMView(),
  ),

  // catálogo de avisos
  GoRoute(
    path: '/am/catalogo-avisos',
    builder: (_, __) => const CatalogoServiciosAMView(),
  ),
  GoRoute(
    path: '/am/catalogo-avisos-filtrados/:servicio',
    builder: (_, state) =>
        AvisosFiltradosAMView(servicio: state.pathParameters['servicio']!),
  ),
  GoRoute(
    path: '/am/aviso-detalle/:idAviso',
    name: 'detalleAvisoAM',
    builder: (_, state) =>
        DetalleAvisoAMView(idAviso: state.pathParameters['idAviso']!),
  ),

  // solicitudes
  GoRoute(
    path: '/am/solicitar-servicio/:idAviso',
    builder: (_, state) =>
        AgendarAMView(idAviso: state.pathParameters['idAviso']!),
  ),
  GoRoute(
    path: '/am/catalogo-solicitudes',
    builder: (_, __) => const SolicitudesAMView(),
  ),
  GoRoute(
    path: '/am/detalle-solicitud/:id',
    builder: (_, state) =>
        DetalleSolicitudAMView(idSolicitud: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/am/historial-solicitudes',
    builder: (_, __) => const HistorialSolicitudesView.am(),
  ),
];

// RUTAS COMPARTIDAS Y REDIRECCIONES ///////////////////////////////////////////////////////////////////
final List<RouteBase> _rutasCompartidas = [
  // detalle de aviso (cuidador y clientes)
  GoRoute(
    path: '/aviso/:idAviso',
    name: 'detalleAviso',
    builder: (_, state) =>
        DetalleAvisoView(idAviso: state.pathParameters['idAviso']!),
  ),

  // visor de PDF (se abre sobre la barra inferior)
  GoRoute(
    path: '/visor-pdf',
    name: 'visorPdf',
    builder: (_, state) {
      final data = state.extra as Map<String, dynamic>? ?? {};
      return VisorPDFView(
        url: data['url'] as String? ?? '',
        titulo: data['titulo'] as String? ?? 'Documento',
      );
    },
  ),

  // redirección de seguridad
  GoRoute(path: '/inicio_apoyo', redirect: (_, __) => '/apoyo/inicio'),
];

// ROUTER //////////////////////////////////////////////////////////////////////////////////////////////
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    ..._rutasInicioYAuth,
    ..._rutasCompletarPerfil,
    ..._rutasCuidador,
    ..._rutasApoyo,
    ..._rutasAdultoMayor,
    ..._rutasCompartidas,
  ],
);