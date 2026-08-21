import 'package:flutter/material.dart';
import 'pantallas/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'modelos/gastos.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GastoAdapter());
  if (!Hive.isBoxOpen('caja_gastos')) {
    await Hive.openBox<Gasto>('caja_gastos');
  }
  runApp(const GastosApp());
}

class GastosApp extends StatelessWidget {
  const GastosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gastos App',
      theme: ThemeData(
        primaryColor: const Color(0xFFFF6B6B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B6B),
          // Forzar que el color de enfoque sea el mismo primario (rojo)
          primary: const Color(0xFFFF6B6B),
          secondary: const Color(0xFFFF6B6B),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        // === ELIMINA CUALQUIER RASTRO DE AMARILLO ===
        inputDecorationTheme: const InputDecorationTheme(
          // Borde cuando está enfocado (ROJO, no amarillo)
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFF6B6B), width: 2),
          ),
          // Borde normal (gris)
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          // Borde cuando tiene error (rojo)
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          // También forzamos el color de la etiqueta flotante
          floatingLabelStyle: TextStyle(color: Color(0xFFFF6B6B)),
        ),
        // Forzar colores de enfoque y resaltado
        focusColor: const Color(0xFFFF6B6B),
        highlightColor: const Color(0xFFFF6B6B),
        splashColor: const Color(0xFFFF6B6B),
      ),
      home: const HomeScreen(),
    );
  }
}