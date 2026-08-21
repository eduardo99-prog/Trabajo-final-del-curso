import 'package:flutter/material.dart';
import 'teclado_pantalla.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gastos_app/modelos/gastos.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salmonColor = Theme.of(context).primaryColor;
    final caja = Hive.box<Gasto>('caja_gastos');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ValueListenableBuilder(
            valueListenable: caja.listenable(),
            builder: (context, Box<Gasto> caja, _) {
              final hoy = DateTime.now();
              final gastosDeHoy = caja.values
                  .where((g) =>
                      g.fecha.year == hoy.year &&
                      g.fecha.month == hoy.month &&
                      g.fecha.day == hoy.day)
                  .toList();
              final totalHoy = gastosDeHoy.fold<double>(0.0, (sum, g) => sum + g.monto);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total gastos hoy', style: TextStyle(fontSize: 14, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Text('\$ ${totalHoy.toStringAsFixed(2)}', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Gastos de hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: gastosDeHoy.isEmpty
                        ? const Center(child: Text('No hay gastos registrados hoy.', style: TextStyle(color: Colors.black54)))
                        : ListView.builder(
                            itemCount: gastosDeHoy.length,
                            itemBuilder: (context, i) {
                              final g = gastosDeHoy[i];
                              return _GastoCard(
                                icono: _iconoCategoria(g.categoria),
                                nombre: g.concepto,
                                categoria: g.categoria,
                                precio: '\$ ${g.monto.toStringAsFixed(2)}',
                                hora: _formatearHora(g.fecha),
                              );
                            },
                          ),
                  )
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 56,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TecladoPantalla()));
          },
          backgroundColor: salmonColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          label: const Text('+ Agregar gasto', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

String _iconoCategoria(String categoria) {
  switch (categoria) {
    case 'Alimentación': return '🍔';
    case 'Transporte': return '🚌';
    case 'Servicios': return '🎮';
    case 'Salud': return '💊';
    default: return '💰';
  }
}

String _formatearHora(DateTime fecha) {
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');
  return '$hora:$minuto';
}

class _GastoCard extends StatelessWidget {
  final String icono, nombre, categoria, precio, hora;
  const _GastoCard({required this.icono, required this.nombre, required this.categoria, required this.precio, required this.hora});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Text(icono, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(categoria, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(precio, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(hora, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}