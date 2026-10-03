import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_client.dart';

class ChatMessage {
  final String role; // 'user' o 'assistant'
  final String text;
  final String? imagePath;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.text,
    this.imagePath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toApiMessage() {
    if (imagePath != null && role == 'user') {
      return {
        'role': role,
        'content': [
          {'type': 'text', 'text': text},
        ],
      };
    }
    return {'role': role, 'content': text};
  }
}

class UserProfile {
  String name;
  String trato; // 'vos' o 'usted'
  String autonomia; // 'A', 'B', 'C'
  String foco; // 'A', 'B', 'C', 'D'
  String entorno; // 'A', 'B', 'C'
  // Personalización del pingüino
  String ropa; // 'remera', 'vestido', 'traje', 'pollera', 'ninguna'
  String pelo; // 'rubio', 'castano', 'canoso', 'negro', 'ninguno'
  bool lentes;

  UserProfile({
    this.name = '',
    this.trato = 'vos',
    this.autonomia = 'B',
    this.foco = 'D',
    this.entorno = 'B',
    this.ropa = 'ninguna',
    this.pelo = 'ninguno',
    this.lentes = false,
  });
}

class AidaState extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final UserProfile profile = UserProfile();
  bool voiceEnabled = true;
  double voiceSpeed = 0.5;
  bool accessibleMode = false;
  String language = 'español';
  bool _isLoading = false;
  String? _token;

  final _storage = const FlutterSecureStorage();
  late final ApiClient _api;
  SharedPreferences? _prefs;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get hasToken => _token != null;
  static const int maxMessages = 16;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadProfile();
    _loadSettings();
    _token = await _storage.read(key: 'aida_token');
    _api = ApiClient();
    if (_token == null) {
      await _register();
    }
    notifyListeners();
  }

  Future<void> _register() async {
    final token = await _api.install();
    if (token != null) {
      _token = token;
      await _storage.write(key: 'aida_token', value: token);
    }
  }

  Future<String?> sendMessage(String text, {String? imageBase64}) async {
    if (_token == null) return null;

    final userMsg = ChatMessage(role: 'user', text: text);
    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();

    try {
      final history = _buildHistory();
      final systemPrompt = _buildSystemPrompt();
      final userContent = _buildUserMessage(text);

      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': systemPrompt},
        ...history,
      ];

      if (imageBase64 != null) {
        messages.add({
          'role': 'user',
          'content': [
            {'type': 'text', 'text': userContent},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'}
            },
          ],
        });
      } else {
        messages.add({'role': 'user', 'content': userContent});
      }

      final tipo = imageBase64 != null ? 'vision' : 'texto';
      final response = await _api.chat(_token!, messages, tipo);

      if (response != null) {
        final cleaned = _cleanResponse(response);
        final aidaMsg = ChatMessage(role: 'assistant', text: cleaned);
        _messages.add(aidaMsg);
        _trimHistory();
        _isLoading = false;
        notifyListeners();
        return cleaned;
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> sendReport(String motivo, String pregunta, String respuesta) async {
    if (_token == null) return false;
    return await _api.report(_token!, motivo, pregunta, respuesta);
  }

  Future<bool> deleteAllData() async {
    if (_token == null) return false;
    final ok = await _api.deleteInstallation(_token!);
    if (ok) {
      _messages.clear();
      _token = null;
      await _storage.delete(key: 'aida_token');
      await _register();
      notifyListeners();
    }
    return ok;
  }

  void clearConversation() {
    _messages.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> _buildHistory() {
    final start = _messages.length > maxMessages ? _messages.length - maxMessages : 0;
    return _messages
        .sublist(start, _messages.length - 1)
        .map((m) => {'role': m.role, 'content': m.text})
        .toList();
  }

  String _buildSystemPrompt() {
    final buf = StringBuffer();
    buf.write(_base);
    buf.write(_sobreAida);
    buf.write(_sinPantalla);
    buf.write(_buildProfile());
    if (accessibleMode) buf.write(_accesibleCharla);
    buf.write(_buildIdioma());
    return buf.toString();
  }

  String _buildUserMessage(String text) {
    return 'La persona dice: ${text.length > 4000 ? text.substring(0, 4000) : text}';
  }

  String _buildProfile() {
    final buf = StringBuffer();
    buf.write('\nCOMO LE HABLAS\n');
    if (profile.trato == 'usted') {
      buf.write('- Si contestás en castellano, tratala de usted, con respeto y calidez: "toque", "abra", "fíjese". Nunca de vos ni de tú.\n');
    } else {
      buf.write('- Si contestás en castellano, hablale de vos, como se habla en Argentina: "tocá", "abrí", "fijate", "apoyá el dedo". Nunca de tú: nada de "toca", "abre", "busca", "mueve".\n');
    }
    buf.write('- Si no sabés si es hombre o mujer, usá formas que no marquen género.\n');

    if (profile.name.isNotEmpty) {
      buf.write('\nLO QUE SABES DE LA PERSONA (te lo conto ella; usalo para contestar mejor, no lo repitas)\n');
      buf.write('- Se llama ${profile.name}. Podes nombrarla de vez en cuando, no en cada respuesta.\n');

      switch (profile.autonomia) {
        case 'A':
          buf.write('- Se maneja bien con el celular: podes ir directo, sin explicar lo basico.\n');
          break;
        case 'C':
          buf.write('- Le cuesta bastante usar el celular: explicale de a un paso por vez, con todo detalle, y deci siempre donde esta cada cosa.\n');
          break;
        default:
          buf.write('- Con el celular se maneja mas o menos: a veces necesita que le expliquen.\n');
      }

      switch (profile.foco) {
        case 'A':
          buf.write('- Lo que mas quiere es aprender cosas nuevas.\n');
          break;
        case 'B':
          buf.write('- Lo que mas le importan son los tramites, los pagos y cuidarse de las estafas.\n');
          break;
        case 'C':
          buf.write('- Lo que mas le importa es recordar cosas y organizarse: alarmas, turnos, anotaciones.\n');
          break;
        default:
          buf.write('- Lo que mas le gusta es charlar.\n');
      }

      switch (profile.entorno) {
        case 'A':
          buf.write('- Vive sin compania.\n');
          break;
        case 'C':
          buf.write('- Vive en una residencia o con asistencia.\n');
          break;
        default:
          buf.write('- Vive con su pareja o su familia.\n');
      }
    }
    return buf.toString();
  }

  String _buildIdioma() {
    return '\nEL IDIOMA\nEste telefono esta configurado en $language. Contesta en ese idioma. Si la persona te habla en otro, contesta en el que te hablo.\n';
  }

  String _cleanResponse(String text) {
    var cleaned = text;
    // Quitar etiquetas de razonamiento
    cleaned = cleaned.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '');
    // Quitar markdown
    cleaned = cleaned.replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'\*(.+?)\*'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'^#+\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^[-*]\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '');
    // Quitar marcas [[...]]
    cleaned = cleaned.replaceAll(RegExp(r'\[\[.*?\]\]'), '');
    // Limpiar espacios extra
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return cleaned.trim();
  }

  void _trimHistory() {
    while (_messages.length > maxMessages) {
      _messages.removeAt(0);
    }
  }

  void _loadProfile() {
    if (_prefs == null) return;
    profile.name = _prefs!.getString('profile_name') ?? '';
    profile.trato = _prefs!.getString('profile_trato') ?? 'vos';
    profile.autonomia = _prefs!.getString('profile_autonomia') ?? 'B';
    profile.foco = _prefs!.getString('profile_foco') ?? 'D';
    profile.entorno = _prefs!.getString('profile_entorno') ?? 'B';
    profile.ropa = _prefs!.getString('profile_ropa') ?? 'ninguna';
    profile.pelo = _prefs!.getString('profile_pelo') ?? 'ninguno';
    profile.lentes = _prefs!.getBool('profile_lentes') ?? false;
  }

  void saveProfile() {
    if (_prefs == null) return;
    _prefs!.setString('profile_name', profile.name);
    _prefs!.setString('profile_trato', profile.trato);
    _prefs!.setString('profile_autonomia', profile.autonomia);
    _prefs!.setString('profile_foco', profile.foco);
    _prefs!.setString('profile_entorno', profile.entorno);
    _prefs!.setString('profile_ropa', profile.ropa);
    _prefs!.setString('profile_pelo', profile.pelo);
    _prefs!.setBool('profile_lentes', profile.lentes);
    notifyListeners();
  }

  void _loadSettings() {
    if (_prefs == null) return;
    voiceEnabled = _prefs!.getBool('voice_enabled') ?? true;
    voiceSpeed = _prefs!.getDouble('voice_speed') ?? 0.5;
    accessibleMode = _prefs!.getBool('accessible_mode') ?? false;
    language = _prefs!.getString('language') ?? 'español';
  }

  void saveSettings() {
    if (_prefs == null) return;
    _prefs!.setBool('voice_enabled', voiceEnabled);
    _prefs!.setDouble('voice_speed', voiceSpeed);
    _prefs!.setBool('accessible_mode', accessibleMode);
    _prefs!.setString('language', language);
    notifyListeners();
  }

  static const _base = '''Eres AIDA, una asistente que acompana a personas mayores a usar su celular y a no caer en estafas.

COMO ES TU RESPUESTA
- Se lee en voz alta. Escribe como se habla: sin asteriscos, sin markdown, sin vinetas, sin emojis, sin titulos.
- Como maximo tres oraciones cortas, mas una cuarta si hace falta describir un movimiento del dedo. Nada de listas ni de pasos numerados salvo que la persona pida el paso a paso.
- Nunca digas coordenadas, pixeles ni numeros de posicion. Di donde esta con palabras: arriba, abajo, al centro, a la derecha, en la barra de abajo, al lado de tal cosa.
- Nunca digas que algo es facil, simple, sencillo, rapido ni obvio. Si te esta preguntando es porque para ella no lo es. Tampoco la felicites de mas ni le hables como a un nino.
- Si algo tiene un nombre larguisimo, di solamente la parte corta que se alcanza a leer en la pantalla.
- No expliques como llegaste a la respuesta. Ve directo a lo que la persona necesita.

LAS PALABRAS QUE USAS
- Hablas con alguien que no crecio con esto. Si una palabra la aprendiste de la tecnologia, no la digas: describi lo que se ve y lo que hay que hacer con el dedo.
- Nunca digas: widget, interfaz, menu desplegable, banner, pop-up, cache, sincronizar, deslizar, swipe, scroll, pestana, link, tab, barra de navegacion, ni ningun nombre de gesto en ingles.
- Tampoco digas app: di aplicacion. Tampoco digas icono: di el dibujito.
- Los nombres propios de las aplicaciones si se dicen tal cual: WhatsApp, Instagram, Facebook.
- Si no te queda otra que usar una palabra dificil, explicala en la misma oracion con palabras de todos los dias.

CUANDO HABLAR DE ESTAFAS
- Solo hablas de estafas si hay una senal concreta en lo que te mostraron o en lo que te preguntaron: un premio, una urgencia, un pedido de plata o de datos personales, un remitente desconocido, un enlace raro, algo que apura.
- Si la hay, decilo primero y sin rodeos: que es lo peligroso y que no hay que hacer.
- Si no la hay, NO la menciones. Nada de advertencias por las dudas ni de avisos preventivos pegados al final.
''';

  static const _sobreAida = '''
SOBRE VOS Y SOBRE AIDA
- Solo si te lo preguntan. Que sos: una asistente para usar el celular y no caer en estafas. Contesta en una o dos oraciones.
- Quien te hizo: el equipo del proyecto AIDA. No eres de OpenAI, Google ni de ninguna otra empresa, y no digas fechas de lanzamiento ni versiones: no las sabes.
- Seguridad: AIDA nunca pide claves, codigos ni datos de tarjetas, y la persona decide que se comparte.
- Si te piden programar o escribir codigo, decilo con amabilidad en una oracion: eso no es lo tuyo, pero con el celular y con las estafas si podes ayudar.
''';

  static const _sinPantalla = '''
ESTAN CHARLANDO
Ahora NO estas viendo ninguna pantalla: la persona te esta escribiendo o hablando desde tu propia aplicacion. Es una charla comun.

- No pidas capturas, ni fotos, ni que te describan la pantalla. No digas que no podes ver lo que hay en pantalla salvo que te lo pregunten explicitamente.
- Contesta la pregunta que te hicieron, con lo que sabes, como lo haria una persona que acompana.
''';

  static const _accesibleCharla = '''
QUIEN TE USA NO VE BIEN
Todo lo que le expliques tiene que entenderse escuchando: no le pidas que mire ni que lea nada.
''';
}
