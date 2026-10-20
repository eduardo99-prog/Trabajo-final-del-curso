import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OptiMovilApp());
}

class OptiMovilApp extends StatelessWidget {
  const OptiMovilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OptiMóvil',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1769AA),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F6FA),
        fontFamily: 'Roboto',
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  bool ahorroEnergia = true;
  bool reducirAnimaciones = true;
  bool avisosAlmacenamiento = true;
  bool cargaLigera = true;
  bool cargando = true;

  List<Map<String, dynamic>> registros = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? datos = prefs.getString('registros');
      final String? configuracion = prefs.getString('configuracion');

      final nuevosRegistros = datos == null
          ? <Map<String, dynamic>>[]
          : (jsonDecode(datos) as List)
              .map(
                (item) => Map<String, dynamic>.from(item as Map),
              )
              .toList();

      Map<String, dynamic> config = {};

      if (configuracion != null) {
        config = Map<String, dynamic>.from(
          jsonDecode(configuracion) as Map,
        );
      }

      if (!mounted) return;

      setState(() {
        registros = nuevosRegistros;
        ahorroEnergia = config['ahorroEnergia'] ?? true;
        reducirAnimaciones = config['reducirAnimaciones'] ?? true;
        avisosAlmacenamiento =
            config['avisosAlmacenamiento'] ?? true;
        cargaLigera = config['cargaLigera'] ?? true;
        cargando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      notificar('No se pudieron cargar los datos guardados.');
    }
  }

  Future<void> guardarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'configuracion',
      jsonEncode({
        'ahorroEnergia': ahorroEnergia,
        'reducirAnimaciones': reducirAnimaciones,
        'avisosAlmacenamiento': avisosAlmacenamiento,
        'cargaLigera': cargaLigera,
      }),
    );
  }

  Future<void> guardarRegistros() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('registros', jsonEncode(registros));
  }

  void notificar(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> cambiarOpcion(
    String opcion,
    bool valor,
  ) async {
    setState(() {
      switch (opcion) {
        case 'energia':
          ahorroEnergia = valor;
          break;
        case 'animaciones':
          reducirAnimaciones = valor;
          break;
        case 'almacenamiento':
          avisosAlmacenamiento = valor;
          break;
        case 'interfaz':
          cargaLigera = valor;
          break;
      }
    });

    try {
      await guardarConfiguracion();

      if (mounted) {
        notificar('Configuración guardada.');
      }
    } catch (_) {
      if (mounted) {
        notificar('No se pudo guardar la configuración.');
      }
    }
  }

  Future<void> ejecutarOptimizacion() async {
    final ahora = DateTime.now();

    setState(() {
      registros.insert(0, {
        'titulo': 'Revisión de optimización',
        'detalle':
            'Ahorro: ${ahorroEnergia ? "activado" : "desactivado"}. '
            'Interfaz ligera: ${cargaLigera ? "activada" : "desactivada"}.',
        'fecha': ahora.toIso8601String(),
      });

      if (registros.length > 30) {
        registros = registros.take(30).toList();
      }
    });

    try {
      await guardarRegistros();

      if (mounted) {
        notificar('Revisión guardada correctamente.');
      }
    } catch (_) {
      if (mounted) {
        notificar('No se pudo guardar la revisión.');
      }
    }
  }

  Future<void> limpiarRegistros() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text(
          '¿Deseas eliminar el historial de revisiones guardado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      registros.clear();
    });

    try {
      await guardarRegistros();

      if (mounted) {
        notificar('Historial eliminado correctamente.');
      }
    } catch (_) {
      if (mounted) {
        notificar('No se pudo guardar el cambio.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      construirInicio(),
      construirOptimizacion(),
      construirAlmacenamiento(),
      construirConfiguracion(),
      const ChatPanel(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(
              Icons.speed_rounded,
              color: Color(0xFF1769AA),
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              'OptiMóvil',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: IndexedStack(
                    index: selectedIndex,
                    children: paginas,
                  ),
                ),
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            label: 'Optimizar',
          ),
          NavigationDestination(
            icon: Icon(Icons.storage_outlined),
            label: 'Almacenamiento',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Ajustes',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
        ],
      ),
    );
  }

  Widget construirInicio() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Panel de rendimiento',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Administra los recursos y mejora la eficiencia de tu aplicación.',
          style: TextStyle(
            color: Colors.blueGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1769AA),
                Color(0xFF123B70),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.phonelink_setup,
                color: Colors.white,
                size: 38,
              ),
              const SizedBox(height: 15),
              const Text(
                'Optimización de recursos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Administra las preferencias de rendimiento '
                'y registra las revisiones realizadas.',
                style: TextStyle(
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1769AA),
                    padding: const EdgeInsets.all(14),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Configurar optimización'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.all(14),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedIndex = 4;
                    });
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Abrir chat'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Recursos del dispositivo',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount:
              MediaQuery.of(context).size.width > 560 ? 2 : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio:
              MediaQuery.of(context).size.width > 560 ? 2.1 : 2.5,
          children: [
            tarjetaRecurso(
              Icons.memory,
              'Procesamiento',
              'Tareas sencillas',
              'Evitar operaciones innecesarias',
              Colors.blue,
            ),
            tarjetaRecurso(
              Icons.memory_outlined,
              'Memoria RAM',
              'Interfaz ligera',
              'Reutilizar componentes',
              Colors.green,
            ),
            tarjetaRecurso(
              Icons.sd_storage,
              'Almacenamiento',
              '${registros.length} registros',
              'Historial local',
              Colors.orange,
            ),
            tarjetaRecurso(
              Icons.battery_saver,
              'Energía',
              ahorroEnergia ? 'Ahorro activado' : 'Ahorro desactivado',
              'Preferencia de consumo',
              Colors.teal,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Últimas revisiones',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (registros.isEmpty)
          tarjetaMensaje(
            Icons.history,
            'Todavía no hay revisiones guardadas.',
          )
        else
          ...registros.take(3).map(tarjetaRegistro),
      ],
    );
  }

  Widget tarjetaRecurso(
    IconData icono,
    String titulo,
    String valor,
    String detalle,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icono, color: color, size: 27),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detalle,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget construirOptimizacion() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Optimización del sistema',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configura las opciones para favorecer una aplicación ligera.',
          style: TextStyle(
            color: Colors.blueGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        tarjetaOpcion(
          icono: Icons.battery_charging_full,
          titulo: 'Ahorro de energía',
          descripcion: 'Guarda la preferencia de ahorro.',
          valor: ahorroEnergia,
          opcion: 'energia',
        ),
        tarjetaOpcion(
          icono: Icons.animation,
          titulo: 'Reducir animaciones',
          descripcion: 'Guarda la preferencia de una interfaz sencilla.',
          valor: reducirAnimaciones,
          opcion: 'animaciones',
        ),
        tarjetaOpcion(
          icono: Icons.layers_outlined,
          titulo: 'Interfaz ligera',
          descripcion: 'Prioriza componentes sencillos.',
          valor: cargaLigera,
          opcion: 'interfaz',
        ),
        tarjetaOpcion(
          icono: Icons.notifications_active_outlined,
          titulo: 'Avisos de almacenamiento',
          descripcion: 'Mostrar consejos sobre los datos guardados.',
          valor: avisosAlmacenamiento,
          opcion: 'almacenamiento',
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: ejecutarOptimizacion,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Guardar revisión'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Estas opciones guardan preferencias locales. No controlan '
          'directamente la CPU, la RAM ni la batería física.',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget tarjetaOpcion({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required bool valor,
    required String opcion,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        secondary: Icon(
          icono,
          color: const Color(0xFF1769AA),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(descripcion),
        ),
        value: valor,
        onChanged: (nuevoValor) {
          cambiarOpcion(opcion, nuevoValor);
        },
      ),
    );
  }

  Widget construirAlmacenamiento() {
    final bytesEstimados = utf8.encode(jsonEncode(registros)).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Almacenamiento local',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Consulta y administra los datos de revisión guardados.',
          style: TextStyle(
            color: Colors.blueGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.sd_storage_outlined,
                  color: Color(0xFF1769AA),
                  size: 42,
                ),
                const SizedBox(height: 14),
                const Text('Historial de revisiones'),
                const SizedBox(height: 6),
                Text(
                  '$bytesEstimados bytes aproximados de datos JSON',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${registros.length} registros almacenados'),
                const SizedBox(height: 10),
                const Text(
                  'El tamaño corresponde al JSON del historial, '
                  'no al almacenamiento completo del dispositivo.',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Historial completo',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (registros.isEmpty)
          tarjetaMensaje(
            Icons.inventory_2_outlined,
            'No hay datos guardados.',
          )
        else
          ...registros.map(tarjetaRegistro),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: registros.isEmpty ? null : limpiarRegistros,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Eliminar historial'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.all(15),
          ),
        ),
        if (avisosAlmacenamiento) ...[
          const SizedBox(height: 14),
          const Text(
            'Consejo: conserva únicamente los registros que necesites.',
            style: TextStyle(color: Colors.blueGrey),
          ),
        ],
      ],
    );
  }

  Widget construirConfiguracion() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Configuración',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Personaliza el funcionamiento de OptiMóvil.',
          style: TextStyle(color: Colors.blueGrey),
        ),
        const SizedBox(height: 20),
        tarjetaOpcion(
          icono: Icons.battery_saver,
          titulo: 'Modo de ahorro',
          descripcion: 'Guardar preferencia de ahorro.',
          valor: ahorroEnergia,
          opcion: 'energia',
        ),
        tarjetaOpcion(
          icono: Icons.motion_photos_off,
          titulo: 'Reducir animaciones',
          descripcion: 'Guardar preferencia visual.',
          valor: reducirAnimaciones,
          opcion: 'animaciones',
        ),
        tarjetaOpcion(
          icono: Icons.speed,
          titulo: 'Componentes ligeros',
          descripcion: 'Priorizar una interfaz sencilla.',
          valor: cargaLigera,
          opcion: 'interfaz',
        ),
        tarjetaOpcion(
          icono: Icons.notifications_outlined,
          titulo: 'Avisos de almacenamiento',
          descripcion: 'Mostrar consejos sobre el historial.',
          valor: avisosAlmacenamiento,
          opcion: 'almacenamiento',
        ),
        const SizedBox(height: 22),
        const Card(
          child: ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Color(0xFF1769AA),
            ),
            title: Text('OptiMóvil'),
            subtitle: Text(
              'Aplicación desarrollada con Flutter y Dart.',
            ),
          ),
        ),
      ],
    );
  }

  Widget tarjetaRegistro(Map<String, dynamic> registro) {
    final fecha = DateTime.tryParse(
      registro['fecha']?.toString() ?? '',
    );

    final fechaTexto = fecha == null
        ? 'Fecha desconocida'
        : '${fecha.day.toString().padLeft(2, '0')}/'
            '${fecha.month.toString().padLeft(2, '0')}/'
            '${fecha.year} '
            '${fecha.hour.toString().padLeft(2, '0')}:'
            '${fecha.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.check_circle_outline),
        ),
        title: Text(
          registro['titulo']?.toString() ?? 'Revisión',
        ),
        subtitle: Text(
          '${registro['detalle'] ?? ''}\n$fechaTexto',
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget tarjetaMensaje(IconData icono, String texto) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Icon(icono, color: Colors.blueGrey, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(texto)),
          ],
        ),
      ),
    );
  }
}


class ChatPanel extends StatefulWidget {
  const ChatPanel({super.key});

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<Map<String, String>> mensajes = [];

  bool respondiendo = false;

  String generarRespuesta(String mensaje) {
    final texto = mensaje.toLowerCase().trim();

    if (RegExp(r'\b(hola|buenas|saludos|hey)\b').hasMatch(texto)) {
      return '¡Hola! Soy el asistente de OptiMóvil. '
          'Estoy aquí para ayudarte con el rendimiento, '
          'la configuración y el almacenamiento de tu aplicación.';
    }

    if (texto.contains('cómo estás') ||
        texto.contains('como estas')) {
      return '¡Estoy listo para ayudarte! ¿Qué necesitas saber '
          'sobre OptiMóvil?';
    }

    if (texto.contains('tu nombre') ||
        texto.contains('quién eres') ||
        texto.contains('quien eres')) {
      return 'Soy el asistente virtual integrado en OptiMóvil. '
          'Puedo orientarte sobre el uso de la aplicación '
          'y sus funciones.';
    }

    if (texto.contains('optimiz') ||
        texto.contains('rendimiento')) {
      return 'En la sección Optimizar puedes configurar el ahorro '
          'de energía, reducir las animaciones, activar la interfaz '
          'ligera y habilitar los avisos de almacenamiento. '
          'Después, pulsa Guardar revisión para registrar '
          'la configuración actual.';
    }

    if (texto.contains('batería') ||
        texto.contains('bateria') ||
        texto.contains('energía') ||
        texto.contains('energia')) {
      return 'La opción Ahorro de energía guarda tu preferencia '
          'en la aplicación. No controla directamente el consumo '
          'físico de la batería del dispositivo.';
    }

    if (texto.contains('memoria ram') ||
        texto.contains('procesador') ||
        texto.contains('cpu')) {
      return 'OptiMóvil presenta recomendaciones para mantener '
          'una interfaz sencilla y reducir trabajo innecesario. '
          'Sus opciones no modifican directamente la memoria RAM '
          'ni la velocidad física del procesador.';
    }

    if (texto.contains('almacenamiento') ||
        texto.contains('espacio') ||
        texto.contains('historial') ||
        texto.contains('registros')) {
      return 'En la sección Almacenamiento puedes consultar '
          'el historial de revisiones, ver el tamaño aproximado '
          'de sus datos y eliminar los registros guardados.';
    }

    if (texto.contains('configuración') ||
        texto.contains('configuracion') ||
        texto.contains('ajustes') ||
        texto.contains('preferencias')) {
      return 'Abre la sección Ajustes para cambiar las preferencias '
          'de ahorro de energía, animaciones, componentes ligeros '
          'y avisos de almacenamiento. Los cambios se guardan '
          'localmente.';
    }

    if (texto.contains('chat') ||
        texto.contains('mensaje') ||
        texto.contains('responder')) {
      return 'Puedes escribir tu mensaje en el campo inferior '
          'y pulsar el botón de enviar. Este asistente utiliza '
          'respuestas locales basadas en palabras clave.';
    }

    if (texto.contains('gracias')) {
      return '¡De nada! Estoy aquí para ayudarte a utilizar '
          'OptiMóvil.';
    }

    if (texto.contains('adiós') ||
        texto.contains('adios') ||
        texto.contains('hasta luego')) {
      return '¡Hasta luego! Cuando necesites ayuda con OptiMóvil, '
          'puedes volver a escribirme.';
    }

    if (texto.contains('ayuda') ||
        texto.contains('qué puedes hacer') ||
        texto.contains('que puedes hacer')) {
      return 'Puedo orientarte sobre estas funciones:\n\n'
          '• Optimización y ahorro de energía.\n'
          '• Memoria RAM y rendimiento.\n'
          '• Almacenamiento e historial.\n'
          '• Configuración de la aplicación.\n\n'
          'Escribe una pregunta sobre cualquiera de estos temas.';
    }

    return 'Gracias por tu mensaje. Soy el asistente local '
        'de OptiMóvil y todavía no tengo una respuesta específica '
        'para esa consulta. Puedes preguntarme sobre optimización, '
        'ahorro de energía, memoria RAM, almacenamiento '
        'o configuración.';
  }

  Future<void> enviarMensaje() async {
    final texto = controller.text.trim();

    if (texto.isEmpty || respondiendo) return;

    controller.clear();

    setState(() {
      mensajes.add({
        'tipo': 'usuario',
        'texto': texto,
      });

      respondiendo = true;
    });

    desplazarAlFinal();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final respuesta = generarRespuesta(texto);

    setState(() {
      mensajes.add({
        'tipo': 'asistente',
        'texto': respuesta,
      });

      if (mensajes.length > 200) {
        mensajes.removeRange(0, mensajes.length - 200);
      }

      respondiendo = false;
    });

    desplazarAlFinal();
  }

  void desplazarAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          color: Colors.white,
          child: const Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFFE3F0FF),
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: Color(0xFF1769AA),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Asistente OptiMóvil',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Asistente automático local',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: mensajes.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.smart_toy_outlined,
                          size: 65,
                          color: Color(0xFF9EADBF),
                        ),
                        SizedBox(height: 14),
                        Text(
                          '¡Bienvenido a OptiMóvil!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Escribe un mensaje para recibir '
                          'una respuesta automática.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(14),
                  itemCount: mensajes.length + (respondiendo ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= mensajes.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(
                            right: 35,
                            bottom: 10,
                          ),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Preparando respuesta...'),
                            ],
                          ),
                        ),
                      );
                    }

                    final mensaje = mensajes[index];
                    final esUsuario = mensaje['tipo'] == 'usuario';

                    return Align(
                      alignment: esUsuario
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        margin: EdgeInsets.only(
                          left: esUsuario ? 35 : 0,
                          right: esUsuario ? 0 : 35,
                          bottom: 10,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: esUsuario
                              ? const Color(0xFF1769AA)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          mensaje['texto'] ?? '',
                          style: TextStyle(
                            color: esUsuario
                                ? Colors.white
                                : const Color(0xFF263238),
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE1E7EF)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !respondiendo,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => enviarMensaje(),
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu mensaje...',
                    filled: true,
                    fillColor: const Color(0xFFF3F6FA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: respondiendo ? null : enviarMensaje,
                tooltip: 'Enviar mensaje',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF1769AA),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(48, 48),
                ),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
