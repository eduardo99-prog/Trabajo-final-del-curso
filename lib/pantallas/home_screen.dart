import 'package:flutter/material.dart';
//import 'add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salmonColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
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
                  children: const [
                    Text('Total gastos hoy', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    SizedBox(height: 8),
                    Text('\$ 14.50', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // 2. Título de la lista
              const Text('Gastos de hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              
              // 3. Lista de Gastos (Reutilizando el Custom Widget)
              Expanded(
                child: ListView(
                  children: const [
                    _GastoCard(icono: '☕', nombre: 'Starbucks', categoria: 'Comidas & Bebidas', precio: '\$6.50', hora: '9:15 AM'),
                    _GastoCard(icono: '🚕', nombre: 'Uber', categoria: 'Transporte', precio: '\$2.75', hora: '11:30 AM'),
                    _GastoCard(icono: '🍽️', nombre: 'Almuerzo', categoria: 'Comidas & Bebidas', precio: '\$5.25', hora: '1:30 PM'),
                  ],
                ),
              )
            ],
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
            // Navegación a la Pantalla 2
            //Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
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