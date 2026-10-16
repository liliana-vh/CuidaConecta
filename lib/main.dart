import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'rutas/app_router.dart';
import 'firebase_options.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart'; 

//control animaciones navegacion
class SinAnimacionPageTransitionsBuilder extends PageTransitionsBuilder {
  const SinAnimacionPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CuidaConectaApp());
}

class CuidaConectaApp extends StatelessWidget {
  const CuidaConectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CuidaConecta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 250, 144, 73)),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: SinAnimacionPageTransitionsBuilder(),
            TargetPlatform.iOS: SinAnimacionPageTransitionsBuilder(),
          },
        ),
      ),
      routerConfig: router,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('en', ''), 
        Locale('es', ''),
      ],
    );
  }
}