import 'package:flutter/material.dart';

class TecladoPantalla extends StatefulWidget {
  const TecladoPantalla({super.key});

  @override
  State<TecladoPantalla> createState() => _TecladoPantallaState();
}

class _TecladoPantallaState extends State<TecladoPantalla> {
  // Estado: Esta variable guarda que categoría está activa
  // 0 = Alimentacion, 1 = Transporte, 2 = Servicios, 3 = Otros
  int categoriaSeleccionada = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Agregar Gasto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Cantidad grande

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$ 0.00',
                  style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold, height: 1),
                ),
                SizedBox(width: 8),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'USD',
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Categorías horizontales
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //_buildCategoriaItem(Icons.restaurant, 'Alimentación', 0),
                  //_buildCategoriaItem(Icons.local_taxi, 'Transporte', 1),
                  //_buildCategoriaItem(Icons.local_laundry_service, 'Servicios', 2),
                  //_buildCategoriaItem(Icons.other_houses, 'Otros', 3),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Contenedor del teclado numérico gris
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botones con UX
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // 1 Accion Principal
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                '+ Agregar gasto', 
                                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 2 Accion Secundaria
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),                                
                              ),
                              child: const Text(
                                'Cancelar', 
                                style: TextStyle(fontSize: 18, color: Colors.black54),
                                ),
                            ),
                          ),
                        ],
                      )
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}