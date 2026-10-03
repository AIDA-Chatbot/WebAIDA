import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> init({double speed = 0.5, String language = 'es-AR'}) async {
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(speed);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((msg) => _isSpeaking = false);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await stop();
    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
  }

  Future<void> setSpeed(double speed) async {
    await _tts.setSpeechRate(speed);
  }

  Future<void> setLanguage(String lang) async {
    final locale = switch (lang) {
      'english' => 'en-US',
      'português' => 'pt-BR',
      _ => 'es-AR',
    };
    await _tts.setLanguage(locale);
  }

  void dispose() {
    _tts.stop();
  }
}
