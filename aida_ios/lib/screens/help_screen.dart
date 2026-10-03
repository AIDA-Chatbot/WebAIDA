import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/aida_state.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HelpCard(
            icon: Icons.menu_book_rounded,
            title: 'Guías',
            subtitle: 'Aprende paso a paso',
            color: AidaColors.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _GuidesSection()),
            ),
          ),
          const SizedBox(height: 12),
          _HelpCard(
            icon: Icons.abc_rounded,
            title: 'Glosario',
            subtitle: 'Palabras explicadas fácil',
            color: AidaColors.accent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _GlossarySection()),
            ),
          ),
          const SizedBox(height: 12),
          _HelpCard(
            icon: Icons.phone_in_talk_rounded,
            title: 'Teléfonos útiles',
            subtitle: 'Números de emergencia',
            color: AidaColors.gold,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _PhonesSection()),
            ),
          ),
          const SizedBox(height: 12),
          _HelpCard(
            icon: Icons.shield_rounded,
            title: '¿Es seguro?',
            subtitle: 'Analizá mensajes sospechosos',
            color: AidaColors.error,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _SafetyCheckSection()),
            ),
          ),
        ],
      );
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HelpCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AidaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: color,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Guías - Step by step guides
// ──────────────────────────────────────────────

class _GuidesSection extends StatelessWidget {
  const _GuidesSection();

  static const _guides = <Map<String, dynamic>>[
    {
      'title': 'Cómo hacer una videollamada',
      'steps': [
        'Abrí WhatsApp desde la pantalla principal.',
        'Buscá el contacto con el que querés hablar.',
        'Tocá su nombre para abrir la conversación.',
        'Arriba a la derecha vas a ver un dibujito de una cámara de video. Tocalo.',
        'Esperá a que la otra persona atienda. ¡Listo!',
      ],
    },
    {
      'title': 'Cómo mandar una foto por WhatsApp',
      'steps': [
        'Abrí WhatsApp y entrá a la conversación donde querés mandar la foto.',
        'Abajo, al lado de donde escribís, vas a ver un dibujito de un clip. Tocalo.',
        'Elegí "Galería" para buscar una foto que ya tenés.',
        'Tocá la foto que querés mandar.',
        'Si querés, escribí algo debajo de la foto.',
        'Tocá la flechita verde para enviarla.',
      ],
    },
    {
      'title': 'Cómo poner una alarma',
      'steps': [
        'Buscá la aplicación "Reloj" en tu celular.',
        'Tocá donde dice "Alarma" (generalmente arriba).',
        'Tocá el botón de "+" para agregar una alarma nueva.',
        'Elegí la hora moviendo los números con el dedo.',
        'Tocá "Guardar" o "Aceptar".',
        'Asegurate de que la alarma quede activada (con la palanquita encendida).',
      ],
    },
    {
      'title': 'Cómo agrandar la letra',
      'steps': [
        'Abrí "Ajustes" o "Configuración" de tu celular.',
        'Buscá donde dice "Pantalla" o "Accesibilidad".',
        'Tocá "Tamaño de texto" o "Tamaño de fuente".',
        'Mové la barrita hacia la derecha para agrandar la letra.',
        'Vas a ver cómo cambia el tamaño en la vista previa.',
      ],
    },
    {
      'title': 'Cómo conectarse al WiFi',
      'steps': [
        'Abrí "Ajustes" o "Configuración" de tu celular.',
        'Tocá donde dice "WiFi" o "Conexiones".',
        'Asegurate de que la palanquita del WiFi esté encendida (en color).',
        'Va a aparecer una lista de redes. Tocá el nombre de tu red.',
        'Escribí la contraseña del WiFi y tocá "Conectar".',
        'Cuando se conecte, vas a ver el dibujito del WiFi arriba en la pantalla.',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guías')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _guides.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final guide = _guides[index];
          return Card(
            elevation: 3,
            shadowColor: AidaColors.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AidaColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AidaColors.primary,
                ),
              ),
              title: Text(
                guide['title'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AidaColors.primary,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _GuideDetailView(
                    title: guide['title'] as String,
                    steps: List<String>.from(guide['steps'] as List),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GuideDetailView extends StatelessWidget {
  final String title;
  final List<String> steps;

  const _GuideDetailView({required this.title, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AidaColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: AidaColors.primary.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      steps[index],
                      style: const TextStyle(fontSize: 18, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Glosario - Glossary of tech terms
// ──────────────────────────────────────────────

class _GlossarySection extends StatelessWidget {
  const _GlossarySection();

  static const _terms = <Map<String, String>>[
    {
      'term': 'WiFi',
      'definition':
          'Es la conexión a internet sin cables que tenés en tu casa o en un lugar público.',
    },
    {
      'term': 'Captura de pantalla',
      'definition':
          'Es una foto de lo que se ve en la pantalla de tu celular en ese momento.',
    },
    {
      'term': 'Nube',
      'definition':
          'Es un lugar en internet donde se guardan tus fotos y archivos para que no se pierdan.',
    },
    {
      'term': 'Bluetooth',
      'definition':
          'Es una forma de conectar aparatos cercanos sin cables, como auriculares o parlantes.',
    },
    {
      'term': 'Contraseña',
      'definition':
          'Es una palabra o código secreto que protege tus cuentas para que nadie más entre.',
    },
    {
      'term': 'Aplicación',
      'definition':
          'Es un programa que instalás en el celular para hacer algo, como WhatsApp o el banco.',
    },
    {
      'term': 'Navegador',
      'definition':
          'Es la aplicación que usás para buscar cosas en internet, como Google Chrome.',
    },
    {
      'term': 'Datos móviles',
      'definition':
          'Es la conexión a internet que usa tu celular cuando no estás conectado al WiFi.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Glosario')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _terms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final term = _terms[index];
          return Card(
            elevation: 3,
            shadowColor: AidaColors.accent.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    term['term']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AidaColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    term['definition']!,
                    style: const TextStyle(fontSize: 18, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Teléfonos útiles - Emergency phones
// ──────────────────────────────────────────────

class _PhonesSection extends StatelessWidget {
  const _PhonesSection();

  static const _phones = <Map<String, String>>[
    {'name': 'Emergencias', 'number': '911', 'icon': 'emergency'},
    {'name': 'Bomberos', 'number': '100', 'icon': 'fire'},
    {'name': 'Policía', 'number': '101', 'icon': 'police'},
    {'name': 'Ambulancia', 'number': '107', 'icon': 'ambulance'},
    {'name': 'Violencia de género', 'number': '144', 'icon': 'gender'},
    {
      'name': 'Defensa del consumidor',
      'number': '0800-666-1518',
      'icon': 'consumer',
    },
  ];

  IconData _getIcon(String key) {
    switch (key) {
      case 'emergency':
        return Icons.warning_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'police':
        return Icons.local_police_rounded;
      case 'ambulance':
        return Icons.local_hospital_rounded;
      case 'gender':
        return Icons.people_rounded;
      case 'consumer':
        return Icons.gavel_rounded;
      default:
        return Icons.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teléfonos útiles')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _phones.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final phone = _phones[index];
          return Card(
            elevation: 3,
            shadowColor: AidaColors.gold.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AidaColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getIcon(phone['icon']!),
                  color: AidaColors.gold,
                  size: 26,
                ),
              ),
              title: Text(
                phone['name']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AidaColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  phone['number']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────
// ¿Es seguro? - Safety check via AIDA
// ──────────────────────────────────────────────

class _SafetyCheckSection extends StatefulWidget {
  const _SafetyCheckSection();

  @override
  State<_SafetyCheckSection> createState() => _SafetyCheckSectionState();
}

class _SafetyCheckSectionState extends State<_SafetyCheckSection> {
  final _controller = TextEditingController();
  String? _result;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _result = null;
    });

    final state = Provider.of<AidaState>(context, listen: false);
    final response = await state.sendMessage(
      '¿Es seguro este mensaje? Analizalo por estafas: $text',
    );

    setState(() {
      _isAnalyzing = false;
      _result = response ?? 'No pude analizar el mensaje. Intentá de nuevo.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('¿Es seguro?')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shadowColor: AidaColors.error.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AidaColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Pegá acá el mensaje que te parece sospechoso y AIDA te dice si puede ser una estafa.',
                        style: const TextStyle(fontSize: 17, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 6,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Pegá el mensaje sospechoso acá...',
                hintStyle: const TextStyle(fontSize: 17),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AidaColors.gold,
                  foregroundColor: AidaColors.textPrimary,
                  elevation: 4,
                  shadowColor: AidaColors.gold.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AidaTheme.buttonRadius),
                  ),
                ),
                child: _isAnalyzing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AidaColors.textPrimary,
                        ),
                      )
                    : const Text(
                        'Analizar mensaje',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                shadowColor: AidaColors.primary.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shield_rounded,
                            color: AidaColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Resultado del análisis',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: AidaColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _result!,
                        style: const TextStyle(fontSize: 18, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
