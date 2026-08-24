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
              // Filtrar los gastos de hoy
              final hoy = DateTime.now();
              final gastosDeHoy = caja.values
                .where((g) =>
                  g.fecha.year == hoy.year &&
                  g.fecha.month == hoy.month &&
                  g.fecha.day == hoy.day)
                .toList();
              // Calcular el total de gastos de hoy
              final totalHoy = gastosDeHoy.fold<double>(0.0, (sum, g) => sum + g.monto);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,           

            children: [
              // 1. Tarjeta de Total Gastos
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
                    SizedBox(height: 8),
                    Text('\$ ${totalHoy.toStringAsFixed(2)}', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // 2. Título de la lista
              const Text('Gastos de hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              
              // 3. Lista de Gastos (Reutilizando el Custom Widget)
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
      
      // 4. Botón Flotante Gigante (Ley de Fitts)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 56,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TecladoPantalla(),));
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
    case 'Comida':
      return '🍔';
    case 'Transporte':
      return '🚌';
    case 'Entretenimiento':
      return '🎮';
    case 'Salud':
      return '💊';
    default:
      return '💰';
  }
}

String _formatearHora(DateTime fecha) {
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');
  return '$hora:$minuto';
}

// Custom Widget para no repetir el código de la tarjeta blanca
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
          // Icono
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Text(icono, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          // Textos centrales
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(categoria, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          // Precio y hora
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