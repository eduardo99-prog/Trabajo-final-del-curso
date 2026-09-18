import 'package:flutter/material.dart';
import 'pantallas/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'modelos/gastos.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// NUEVO main asíncrono
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GastoAdapter());
  await Hive.openBox<Gasto>('caja_gastos');

  // Conexion con Supabase
  await Supabase.initialize(
    url: 'https://qdihyttdkyxlragdophv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFkaWh5dHRka3l4bHJhZ2RvcGh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg0NzM0MzgsImV4cCI6MjEwNDA0OTQzOH0.JhbmfagD3xmW11MV3BaNgPFm0jtzzgh4VzcjsgrTknw',
  );

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