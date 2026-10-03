import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/aida_state.dart';
import '../theme.dart';
import '../widgets/aida_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = context.read<AidaState>();
      _nameController.text = state.profile.name;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AidaState>(
        builder: (context, state, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- SECCION 1: Arma tu AIDA ---
                _buildSectionTitle('Arma tu AIDA'),
                const SizedBox(height: 16),
                _buildAvatarSection(state),
                const SizedBox(height: 24),
                _buildRopaSelector(state),
                const SizedBox(height: 16),
                _buildPeloSelector(state),
                const SizedBox(height: 16),
                _buildLentesToggle(state),
                const SizedBox(height: 32),

                // --- SECCION 2: Tu perfil ---
                _buildSectionTitle('Tu perfil'),
                const SizedBox(height: 16),
                _buildNameField(state),
                const SizedBox(height: 20),
                _buildTratoSelector(state),
                const SizedBox(height: 20),
                _buildAutonomiaSelector(state),
                const SizedBox(height: 20),
                _buildFocoSelector(state),
                const SizedBox(height: 20),
                _buildEntornoSelector(state),
                const SizedBox(height: 32),
                _buildSaveButton(state),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      );
  }

  // ===================== SECCION 1: AVATAR =====================

  Widget _buildAvatarSection(AidaState state) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AidaColors.primary.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AidaAvatar(
          ropa: state.profile.ropa,
          pelo: state.profile.pelo,
          lentes: state.profile.lentes,
          size: 200,
        ),
      ),
    );
  }

  Widget _buildRopaSelector(AidaState state) {
    final opciones = <_ChipOption>[
      _ChipOption('ninguna', 'Sin ropa', Icons.block),
      _ChipOption('remera', 'Remera', Icons.checkroom),
      _ChipOption('vestido', 'Vestido', Icons.dry_cleaning),
      _ChipOption('traje', 'Traje', Icons.business_center),
      _ChipOption('pollera', 'Pollera', Icons.accessibility_new),
    ];

    return _buildChipRow(
      label: 'Ropa',
      opciones: opciones,
      valorActual: state.profile.ropa,
      onSeleccionar: (valor) {
        setState(() {
          state.profile.ropa = valor;
        });
      },
    );
  }

  Widget _buildPeloSelector(AidaState state) {
    final opciones = <_ChipOption>[
      _ChipOption('ninguno', 'Sin pelo', Icons.block),
      _ChipOption('rubio', 'Rubio', Icons.circle, color: const Color(0xFFF2B84D)),
      _ChipOption('castano', 'Castano', Icons.circle, color: const Color(0xFF8B4513)),
      _ChipOption('canoso', 'Canoso', Icons.circle, color: const Color(0xFFC0C0C0)),
      _ChipOption('negro', 'Negro', Icons.circle, color: const Color(0xFF2D2D2D)),
    ];

    return _buildChipRow(
      label: 'Pelo',
      opciones: opciones,
      valorActual: state.profile.pelo,
      onSeleccionar: (valor) {
        setState(() {
          state.profile.pelo = valor;
        });
      },
    );
  }

  Widget _buildChipRow({
    required String label,
    required List<_ChipOption> opciones,
    required String valorActual,
    required ValueChanged<String> onSeleccionar,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: opciones.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final opcion = opciones[index];
              final seleccionado = opcion.valor == valorActual;
              return Material(
                elevation: seleccionado ? 4 : 2,
                shadowColor: seleccionado
                    ? AidaColors.accent.withValues(alpha: 0.4)
                    : Colors.black26,
                borderRadius: BorderRadius.circular(AidaTheme.buttonRadius),
                child: InkWell(
                  onTap: () => onSeleccionar(opcion.valor),
                  borderRadius: BorderRadius.circular(AidaTheme.buttonRadius),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: seleccionado ? AidaColors.accent : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AidaTheme.buttonRadius),
                      border: Border.all(
                        color: seleccionado ? AidaColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          opcion.icono,
                          size: 22,
                          color: opcion.color ??
                              (seleccionado ? Colors.white : AidaColors.textSecondary),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          opcion.etiqueta,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
                            color: seleccionado ? Colors.white : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLentesToggle(AidaState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility, color: AidaColors.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Lentes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Switch(
            value: state.profile.lentes,
            activeColor: AidaColors.accent,
            activeTrackColor: AidaColors.accent.withValues(alpha: 0.4),
            onChanged: (valor) {
              setState(() {
                state.profile.lentes = valor;
              });
            },
          ),
        ],
      ),
    );
  }

  // ===================== SECCION 2: PERFIL =====================

  Widget _buildNameField(AidaState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tu nombre',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: const TextStyle(fontSize: 18),
          decoration: const InputDecoration(
            hintText: 'Como te llamas?',
            prefixIcon: Icon(Icons.person, color: AidaColors.primary),
          ),
          onChanged: (value) {
            state.profile.name = value;
          },
        ),
      ],
    );
  }

  Widget _buildTratoSelector(AidaState state) {
    return _buildOptionSection(
      titulo: 'Como te hablo?',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSegmentButton(
                etiqueta: 'Vos',
                seleccionado: state.profile.trato == 'vos',
                onTap: () {
                  setState(() {
                    state.profile.trato = 'vos';
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSegmentButton(
                etiqueta: 'Usted',
                seleccionado: state.profile.trato == 'usted',
                onTap: () {
                  setState(() {
                    state.profile.trato = 'usted';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAutonomiaSelector(AidaState state) {
    return _buildOptionSection(
      titulo: 'Con el celular...',
      children: [
        _buildRadioOption(
          etiqueta: 'Me manejo bien',
          valor: 'A',
          grupoValor: state.profile.autonomia,
          onChanged: (v) => setState(() => state.profile.autonomia = v),
        ),
        _buildRadioOption(
          etiqueta: 'Mas o menos',
          valor: 'B',
          grupoValor: state.profile.autonomia,
          onChanged: (v) => setState(() => state.profile.autonomia = v),
        ),
        _buildRadioOption(
          etiqueta: 'Me cuesta',
          valor: 'C',
          grupoValor: state.profile.autonomia,
          onChanged: (v) => setState(() => state.profile.autonomia = v),
        ),
      ],
    );
  }

  Widget _buildFocoSelector(AidaState state) {
    return _buildOptionSection(
      titulo: 'Lo que mas me interesa',
      children: [
        _buildRadioOption(
          etiqueta: 'Aprender',
          valor: 'A',
          grupoValor: state.profile.foco,
          onChanged: (v) => setState(() => state.profile.foco = v),
        ),
        _buildRadioOption(
          etiqueta: 'Tramites y estafas',
          valor: 'B',
          grupoValor: state.profile.foco,
          onChanged: (v) => setState(() => state.profile.foco = v),
        ),
        _buildRadioOption(
          etiqueta: 'Organizar',
          valor: 'C',
          grupoValor: state.profile.foco,
          onChanged: (v) => setState(() => state.profile.foco = v),
        ),
        _buildRadioOption(
          etiqueta: 'Charlar',
          valor: 'D',
          grupoValor: state.profile.foco,
          onChanged: (v) => setState(() => state.profile.foco = v),
        ),
      ],
    );
  }

  Widget _buildEntornoSelector(AidaState state) {
    return _buildOptionSection(
      titulo: 'Vivo...',
      children: [
        _buildRadioOption(
          etiqueta: 'Solo/a',
          valor: 'A',
          grupoValor: state.profile.entorno,
          onChanged: (v) => setState(() => state.profile.entorno = v),
        ),
        _buildRadioOption(
          etiqueta: 'Con familia',
          valor: 'B',
          grupoValor: state.profile.entorno,
          onChanged: (v) => setState(() => state.profile.entorno = v),
        ),
        _buildRadioOption(
          etiqueta: 'Con asistencia',
          valor: 'C',
          grupoValor: state.profile.entorno,
          onChanged: (v) => setState(() => state.profile.entorno = v),
        ),
      ],
    );
  }

  // ===================== COMPONENTES COMUNES =====================

  Widget _buildSectionTitle(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AidaColors.primary,
      ),
    );
  }

  Widget _buildSegmentButton({
    required String etiqueta,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: seleccionado ? 4 : 2,
      shadowColor: seleccionado
          ? AidaColors.accent.withValues(alpha: 0.4)
          : Colors.black26,
      borderRadius: BorderRadius.circular(AidaTheme.buttonRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AidaTheme.buttonRadius),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: seleccionado ? AidaColors.primary : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AidaTheme.buttonRadius),
            border: Border.all(
              color: seleccionado ? AidaColors.primary : AidaColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Text(
            etiqueta,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: seleccionado ? Colors.white : AidaColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionSection({
    required String titulo,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String etiqueta,
    required String valor,
    required String grupoValor,
    required ValueChanged<String> onChanged,
  }) {
    final seleccionado = valor == grupoValor;
    return InkWell(
      onTap: () => onChanged(valor),
      borderRadius: BorderRadius.circular(AidaTheme.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: seleccionado ? AidaColors.primary : AidaColors.textSecondary,
                  width: 2,
                ),
              ),
              child: seleccionado
                  ? Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AidaColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                etiqueta,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
                  color: seleccionado ? AidaColors.primary : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(AidaState state) {
    return ElevatedButton(
      onPressed: () {
        state.profile.name = _nameController.text;
        state.saveProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Perfil guardado',
              style: TextStyle(fontSize: 16),
            ),
            backgroundColor: AidaColors.primary,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: const Text('Guardar'),
    );
  }
}

/// Modelo interno para las opciones de los chips de seleccion
class _ChipOption {
  final String valor;
  final String etiqueta;
  final IconData icono;
  final Color? color;

  _ChipOption(this.valor, this.etiqueta, this.icono, {this.color});
}
