import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/gastos.dart';

class GastosService {
  static final supabase = Supabase.instance.client;

  // READ: trae todos los gastos desde Supabase

  static Future<List<Gasto>> obtenerGastos() async {
    final datos = await supabase
        .from('gastos')
        .select()
        .order('fecha', ascending: false);
    return datos.map((fila) => Gasto.fromMap(fila)).toList();
}
}