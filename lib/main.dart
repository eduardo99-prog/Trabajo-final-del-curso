import 'package:flutter/material.dart';
import 'pantallas/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'modelos/gastos.dart';

// NUEVO main asíncrono
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GastoAdapter());
  await Hive.openBox<Gasto>('caja_gastos');

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B6B)),
        useMaterial3: true,
        // configuracion de la fuente por defecto
        fontFamily: 'Roboto',

      ),
      home: const HomeScreen(),
    );
  }
}