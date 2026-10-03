import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../state/aida_state.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _speechService = SpeechService();
  final _ttsService = TtsService();
  bool _speechReady = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    _speechReady = await _speechService.init();
    if (!mounted) return;
    final state = context.read<AidaState>();
    await _ttsService.init(
      speed: state.voiceSpeed,
      language: state.language == 'english'
          ? 'en-US'
          : state.language == 'português'
              ? 'pt-BR'
              : 'es-AR',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _speechService.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _focusNode.unfocus();
    _scrollToBottom();

    final state = context.read<AidaState>();
    final response = await state.sendMessage(text);
    _scrollToBottom();

    if (response != null && state.voiceEnabled) {
      await _ttsService.speak(response);
    }
  }

  Future<void> _toggleRecording() async {
    if (!_speechReady) return;

    if (_isRecording) {
      setState(() => _isRecording = false);
      await _speechService.stopListening();
      return;
    }

    await _ttsService.stop();
    setState(() => _isRecording = true);

    if (!mounted) return;
    final locale = switch (context.read<AidaState>().language) {
      'english' => 'en_US',
      'português' => 'pt_BR',
      _ => 'es_AR',
    };

    await _speechService.startListening(
      locale: locale,
      onResult: (text) {
        setState(() => _isRecording = false);
        if (text.isNotEmpty) {
          _controller.text = text;
          _sendText();
        }
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (image == null) return;

    final bytes = await File(image.path).readAsBytes();
    final base64 = base64Encode(bytes);

    if (!mounted) return;
    final state = context.read<AidaState>();
    _scrollToBottom();
    final response = await state.sendMessage(
      'Te muestro esta imagen, ¿qué ves?',
      imageBase64: base64,
    );
    _scrollToBottom();

    if (response != null && state.voiceEnabled) {
      await _ttsService.speak(response);
    }
  }

  Future<void> _pasteForScamCheck() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null || data!.text!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay nada copiado. Copiá el mensaje sospechoso y volvé a tocar.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
      return;
    }

    final pasted = data.text!;
    if (!mounted) return;

    final state = context.read<AidaState>();
    _scrollToBottom();
    final response = await state.sendMessage(
      'Me llegó este mensaje y quiero saber si es seguro o es una estafa: "$pasted"',
    );
    _scrollToBottom();

    if (response != null && state.voiceEnabled) {
      await _ttsService.speak(response);
    }
  }

  void _showReportDialog(ChatMessage aidaMessage) {
    final userMessage = _findPreviousUserMessage(aidaMessage);
    String? selectedMotivo;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text(
            '¿Qué tiene de malo esta respuesta?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final motivo in [
                'Información incorrecta',
                'No entendió la pregunta',
                'Respuesta confusa',
                'Contenido inapropiado',
              ])
                RadioListTile<String>(
                  title: Text(motivo, style: const TextStyle(fontSize: 16)),
                  value: motivo,
                  groupValue: selectedMotivo,
                  activeColor: AidaColors.primary,
                  onChanged: (v) => setDialogState(() => selectedMotivo = v),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: selectedMotivo == null
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      final state = context.read<AidaState>();
                      await state.sendReport(
                        selectedMotivo!,
                        userMessage,
                        aidaMessage.text,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Gracias por avisar. Nos ayuda a mejorar.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
              child: const Text('Enviar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  String _findPreviousUserMessage(ChatMessage aidaMessage) {
    final messages = context.read<AidaState>().messages;
    final idx = messages.indexOf(aidaMessage);
    if (idx > 0) return messages[idx - 1].text;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Consumer<AidaState>(
            builder: (context, state, _) {
              if (state.messages.isEmpty && !state.isLoading) {
                return _buildWelcome();
              }
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.messages.length) {
                    return _buildTypingIndicator();
                  }
                  final msg = state.messages[index];
                  return ChatBubble(
                    text: msg.text,
                    isUser: msg.role == 'user',
                    onReport: msg.role == 'assistant'
                        ? () => _showReportDialog(msg)
                        : null,
                  );
                },
              );
            },
          ),
        ),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/aida_penguin.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            Text(
              '¡Hola! Soy AIDA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AidaColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Preguntame lo que necesites sobre tu celular. Estoy acá para ayudarte.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AidaColors.textSecondaryDark
                    : AidaColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildQuickAction(
              icon: Icons.content_paste,
              label: '¿Es seguro este mensaje?',
              onTap: _pasteForScamCheck,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AidaColors.gold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
          border: Border.all(color: AidaColors.gold.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AidaColors.gold, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AidaColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AidaColors.primary,
            child: const Text('🐧', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AidaColors.aidaBubbleDark
                  : AidaColors.aidaBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                  child: _BouncingDot(delay: i * 200),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AidaColors.cardDark : AidaColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt_outlined),
            color: AidaColors.primary,
            iconSize: 26,
            tooltip: 'Sacar foto',
          ),
          IconButton(
            onPressed: _pasteForScamCheck,
            icon: const Icon(Icons.content_paste),
            color: AidaColors.gold,
            iconSize: 26,
            tooltip: '¿Es seguro?',
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 17),
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Escribí tu pregunta...',
                hintStyle: TextStyle(
                  fontSize: 17,
                  color: isDark
                      ? AidaColors.textSecondaryDark
                      : AidaColors.textSecondary,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AidaColors.surfaceDark : AidaColors.surface,
              ),
              onSubmitted: (_) => _sendText(),
            ),
          ),
          const SizedBox(width: 4),
          Consumer<AidaState>(
            builder: (context, state, _) {
              if (state.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AidaColors.primary,
                    ),
                  ),
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_speechReady)
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording
                              ? AidaColors.error
                              : AidaColors.accent,
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _sendText,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AidaColors.primary,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: child,
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AidaColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
