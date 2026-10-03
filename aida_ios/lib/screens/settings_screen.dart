import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/aida_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AidaState>(
        builder: (context, state, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Voice settings ──
              _SectionHeader(title: 'Voz'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _SwitchTile(
                    icon: Icons.record_voice_over_rounded,
                    title: 'Voz activada',
                    subtitle: 'AIDA lee las respuestas en voz alta',
                    value: state.voiceEnabled,
                    onChanged: (value) {
                      state.voiceEnabled = value;
                      state.saveSettings();
                    },
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.speed_rounded,
                              color: AidaColors.primary,
                              size: 26,
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'Velocidad de voz',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Lenta',
                              style: TextStyle(
                                fontSize: 16,
                                color: AidaColors.textSecondary,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: state.voiceSpeed,
                                min: 0.1,
                                max: 1.0,
                                divisions: 9,
                                activeColor: AidaColors.primary,
                                inactiveColor:
                                    AidaColors.primary.withValues(alpha: 0.2),
                                label: state.voiceSpeed.toStringAsFixed(1),
                                onChanged: (value) {
                                  state.voiceSpeed = value;
                                  state.saveSettings();
                                },
                              ),
                            ),
                            const Text(
                              'Rápida',
                              style: TextStyle(
                                fontSize: 16,
                                color: AidaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Accessibility ──
              _SectionHeader(title: 'Accesibilidad'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _SwitchTile(
                    icon: Icons.accessibility_new_rounded,
                    title: 'Modo accesible',
                    subtitle: 'Respuestas pensadas para escuchar',
                    value: state.accessibleMode,
                    onChanged: (value) {
                      state.accessibleMode = value;
                      state.saveSettings();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Language ──
              _SectionHeader(title: 'Idioma'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.language_rounded,
                          color: AidaColors.primary,
                          size: 26,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Idioma de AIDA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AidaColors.primary.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: state.language,
                              style: const TextStyle(
                                fontSize: 17,
                                color: AidaColors.textPrimary,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'español',
                                  child: Text('Español'),
                                ),
                                DropdownMenuItem(
                                  value: 'english',
                                  child: Text('English'),
                                ),
                                DropdownMenuItem(
                                  value: 'português',
                                  child: Text('Português'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  state.language = value;
                                  state.saveSettings();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Data management ──
              _SectionHeader(title: 'Mis datos'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _ActionTile(
                    icon: Icons.delete_sweep_rounded,
                    title: 'Borrar todo lo que hablamos',
                    subtitle: 'Elimina la conversación actual',
                    iconColor: AidaColors.gold,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AidaTheme.cardRadius),
                          ),
                          title: const Text(
                            '¿Borrar la conversación?',
                            style: TextStyle(fontSize: 20),
                          ),
                          content: const Text(
                            'Se va a borrar todo lo que hablaste con AIDA. Esta acción no se puede deshacer.',
                            style: TextStyle(fontSize: 17),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: AidaColors.textSecondary,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                state.clearConversation();
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Conversación borrada',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AidaColors.gold,
                                foregroundColor: AidaColors.textPrimary,
                                elevation: 3,
                                shadowColor:
                                    AidaColors.gold.withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Borrar',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _ActionTile(
                    icon: Icons.delete_forever_rounded,
                    title: 'Borrar mis datos',
                    subtitle: 'Elimina toda tu información de AIDA',
                    iconColor: AidaColors.error,
                    titleColor: AidaColors.error,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AidaTheme.cardRadius),
                          ),
                          title: const Text(
                            '¿Borrar todos tus datos?',
                            style: TextStyle(
                              fontSize: 20,
                              color: AidaColors.error,
                            ),
                          ),
                          content: const Text(
                            'Se van a borrar todas tus conversaciones, tu perfil y tus preferencias. AIDA se va a reiniciar como si fuera la primera vez. Esta acción no se puede deshacer.',
                            style: TextStyle(fontSize: 17),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: AidaColors.textSecondary,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                final success = await state.deleteAllData();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Datos borrados'
                                            : 'No se pudieron borrar los datos. Intentá de nuevo.',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AidaColors.error,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shadowColor:
                                    AidaColors.error.withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Borrar todo',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── About ──
              _SectionHeader(title: 'Acerca de AIDA'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AidaColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: AidaColors.primary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'AIDA',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AidaColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Versión 1.0.0',
                          style: TextStyle(
                            fontSize: 16,
                            color: AidaColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Proyecto AIDA - Asistente para personas mayores',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 17, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            // Opens GitHub link
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'github.com/aida-project',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.open_in_new_rounded,
                            color: AidaColors.accent,
                          ),
                          label: const Text(
                            'Ver en GitHub',
                            style: TextStyle(
                              fontSize: 17,
                              color: AidaColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      );
  }
}

// ──────────────────────────────────────────────
// Reusable widgets
// ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AidaColors.primary,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AidaColors.primary.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AidaColors.primary, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AidaColors.primary,
            activeTrackColor: AidaColors.accent.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
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
              color: iconColor.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
