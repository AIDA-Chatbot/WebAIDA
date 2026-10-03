import 'package:flutter/material.dart';
import '../theme.dart';

class CantoButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final double fontSize;
  final bool destructive;

  const CantoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.textColor,
    this.icon,
    this.fontSize = 18,
    this.destructive = false,
  });

  @override
  State<CantoButton> createState() => _CantoButtonState();
}

class _CantoButtonState extends State<CantoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.destructive
        ? AidaColors.error
        : (widget.color ?? AidaColors.gold);
    final fgColor = widget.destructive
        ? Colors.white
        : (widget.textColor ?? AidaColors.textPrimary);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.diagonal3Values(
          _pressed ? 0.97 : 1.0,
          _pressed ? 0.97 : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AidaTheme.buttonRadius),
          boxShadow: [
            BoxShadow(
              color: _pressed
                  ? bgColor.withValues(alpha: 0.2)
                  : bgColor.withValues(alpha: 0.4),
              offset: Offset(0, _pressed ? 1 : 3),
              blurRadius: _pressed ? 2 : 6,
            ),
            if (!_pressed)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                offset: const Offset(0, -1),
                blurRadius: 0,
                spreadRadius: 0,
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: fgColor, size: 24),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
