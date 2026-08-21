import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gastos_app/modelos/gastos.dart';

class TecladoPantalla extends StatefulWidget {
  const TecladoPantalla({super.key});

  @override
  State<TecladoPantalla> createState() => _TecladoPantallaState();
}

class _TecladoPantallaState extends State<TecladoPantalla> {
  String montoIngresado = '0';
  final conceptoController = TextEditingController();
  String categoriaSeleccionadaTexto = 'Otros';

  @override
  void dispose() {
    conceptoController.dispose();
    super.dispose();
  }

  void agregarNumero(String numero) {
    setState(() {
      if (montoIngresado == '0' && numero != '.') {
        montoIngresado = numero;
      } else if (montoIngresado.contains('.') && numero == '.') {
        return;
      } else {
        montoIngresado += numero;
      }
    });
  }

  void borrarUltimo() {
    setState(() {
      if (montoIngresado.length > 1) {
        montoIngresado = montoIngresado.substring(0, montoIngresado.length - 1);
      } else {
        montoIngresado = '0';
      }
    });
  }

  Widget _buildBotonTeclado(String texto) {
    return Expanded(
      child: TextButton(
        onPressed: () {
          if (texto == '⌫') {
            borrarUltimo();
          } else {
            agregarNumero(texto);
          }
        },
        child: Text(
          texto,
          style: const TextStyle(fontSize: 28, color: Colors.black87),
        ),
      ),
    );
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$ $montoIngresado',
                  style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, height: 1),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'USD',
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // ========== CAMPO CONCEPTO (sin amarillo) ==========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: conceptoController,
                decoration: InputDecoration(
                  labelText: 'Concepto',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  // Etiqueta flotante en rojo
                  floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ========== CAMPO CATEGORÍA (sin amarillo) ==========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: DropdownButtonFormField<String>(
                value: categoriaSeleccionadaTexto,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
                ),
                items: const [
                  DropdownMenuItem(value: 'Alimentación', child: Text('Alimentación')),
                  DropdownMenuItem(value: 'Transporte', child: Text('Transporte')),
                  DropdownMenuItem(value: 'Servicios', child: Text('Servicios')),
                  DropdownMenuItem(value: 'Otros', child: Text('Otros')),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      categoriaSeleccionadaTexto = valor;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 40),
            // ========== TECLADO NUMÉRICO ==========
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(children: [_buildBotonTeclado('1'), _buildBotonTeclado('2'), _buildBotonTeclado('3')]),
                          Row(children: [_buildBotonTeclado('4'), _buildBotonTeclado('5'), _buildBotonTeclado('6')]),
                          Row(children: [_buildBotonTeclado('7'), _buildBotonTeclado('8'), _buildBotonTeclado('9')]),
                          Row(children: [_buildBotonTeclado('.'), _buildBotonTeclado('0'), _buildBotonTeclado('⌫')]),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () async {
                                final monto = double.tryParse(montoIngresado);
                                if (monto == null || monto <= 0) return;

                                final concepto = conceptoController.text.trim().isEmpty
                                    ? 'Gasto'
                                    : conceptoController.text.trim();

                                final caja = Hive.box<Gasto>('caja_gastos');
                                final gasto = Gasto(
                                  concepto: concepto,
                                  monto: monto,
                                  categoria: categoriaSeleccionadaTexto,
                                  fecha: DateTime.now(),
                                );

                                await caja.add(gasto);

                                if (!context.mounted) return;
                                Navigator.pop(context);
                              },
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
                      ),
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