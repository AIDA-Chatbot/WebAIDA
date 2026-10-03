import 'package:flutter/material.dart';

/// Widget que dibuja el pinguino AIDA con capas de personalizacion.
/// Usa CustomPainter para dibujar el cuerpo base, ropa, pelo y lentes.
class AidaAvatar extends StatelessWidget {
  final String ropa;
  final String pelo;
  final bool lentes;
  final double size;

  const AidaAvatar({
    super.key,
    this.ropa = 'ninguna',
    this.pelo = 'ninguno',
    this.lentes = false,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _AidaPainter(
          ropa: ropa,
          pelo: pelo,
          lentes: lentes,
        ),
      ),
    );
  }
}

class _AidaPainter extends CustomPainter {
  final String ropa;
  final String pelo;
  final bool lentes;

  _AidaPainter({
    required this.ropa,
    required this.pelo,
    required this.lentes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width; // cuadrado, usamos width como referencia
    final cx = s / 2; // centro X

    // --- PATAS (detras del cuerpo) ---
    _drawFeet(canvas, s, cx);

    // --- CUERPO BASE ---
    _drawBody(canvas, s, cx);

    // --- PANZA BLANCA ---
    _drawBelly(canvas, s, cx);

    // --- ROPA ---
    _drawClothing(canvas, s, cx);

    // --- ALITAS ---
    _drawWings(canvas, s, cx);

    // --- PICO ---
    _drawBeak(canvas, s, cx);

    // --- OJOS ---
    _drawEyes(canvas, s, cx);

    // --- LENTES ---
    if (lentes) {
      _drawGlasses(canvas, s, cx);
    }

    // --- PELO ---
    _drawHair(canvas, s, cx);
  }

  void _drawFeet(Canvas canvas, double s, double cx) {
    final footPaint = Paint()
      ..color = const Color(0xFFF2B84D)
      ..style = PaintingStyle.fill;
    final footOutline = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.012;

    // Pata izquierda
    final leftFoot = Path()
      ..moveTo(cx - s * 0.18, s * 0.88)
      ..quadraticBezierTo(cx - s * 0.28, s * 0.95, cx - s * 0.22, s * 0.97)
      ..lineTo(cx - s * 0.06, s * 0.92)
      ..close();
    canvas.drawPath(leftFoot, footPaint);
    canvas.drawPath(leftFoot, footOutline);

    // Pata derecha
    final rightFoot = Path()
      ..moveTo(cx + s * 0.18, s * 0.88)
      ..quadraticBezierTo(cx + s * 0.28, s * 0.95, cx + s * 0.22, s * 0.97)
      ..lineTo(cx + s * 0.06, s * 0.92)
      ..close();
    canvas.drawPath(rightFoot, footPaint);
    canvas.drawPath(rightFoot, footOutline);
  }

  void _drawBody(Canvas canvas, double s, double cx) {
    final bodyRect = Rect.fromCenter(
      center: Offset(cx, s * 0.55),
      width: s * 0.7,
      height: s * 0.75,
    );

    // Gradiente teal
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF196F77), Color(0xFF3BB7B4)],
      ).createShader(bodyRect)
      ..style = PaintingStyle.fill;

    final bodyOutline = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018;

    // Cuerpo como ovalo
    canvas.drawOval(bodyRect, bodyPaint);
    canvas.drawOval(bodyRect, bodyOutline);

    // Cabeza (circulo arriba del cuerpo)
    final headCenter = Offset(cx, s * 0.28);
    final headRadius = s * 0.22;

    final headPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.0,
        colors: [const Color(0xFF3BB7B4), const Color(0xFF196F77)],
      ).createShader(
        Rect.fromCircle(center: headCenter, radius: headRadius),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(headCenter, headRadius, headPaint);
    canvas.drawCircle(headCenter, headRadius, bodyOutline);
  }

  void _drawBelly(Canvas canvas, double s, double cx) {
    final bellyRect = Rect.fromCenter(
      center: Offset(cx, s * 0.6),
      width: s * 0.45,
      height: s * 0.52,
    );

    final bellyPaint = Paint()
      ..color = const Color(0xFFF5F5F0)
      ..style = PaintingStyle.fill;

    canvas.drawOval(bellyRect, bellyPaint);
  }

  void _drawClothing(Canvas canvas, double s, double cx) {
    if (ropa == 'ninguna') return;

    final clothPaint = Paint()
      ..style = PaintingStyle.fill;
    final clothOutline = Paint()
      ..color = const Color(0xFF2D2D2D).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.01;

    switch (ropa) {
      case 'remera':
        // Banda horizontal tipo remera en el pecho
        clothPaint.color = const Color(0xFFE74C3C).withValues(alpha: 0.85);
        final remeraPath = Path()
          ..moveTo(cx - s * 0.22, s * 0.44)
          ..quadraticBezierTo(cx, s * 0.40, cx + s * 0.22, s * 0.44)
          ..lineTo(cx + s * 0.22, s * 0.56)
          ..quadraticBezierTo(cx, s * 0.53, cx - s * 0.22, s * 0.56)
          ..close();
        canvas.drawPath(remeraPath, clothPaint);
        canvas.drawPath(remeraPath, clothOutline);
        // Cuello
        final neckPaint = Paint()
          ..color = const Color(0xFFC0392B).withValues(alpha: 0.85)
          ..style = PaintingStyle.fill;
        final neckPath = Path()
          ..moveTo(cx - s * 0.10, s * 0.42)
          ..quadraticBezierTo(cx, s * 0.39, cx + s * 0.10, s * 0.42)
          ..lineTo(cx + s * 0.10, s * 0.45)
          ..quadraticBezierTo(cx, s * 0.42, cx - s * 0.10, s * 0.45)
          ..close();
        canvas.drawPath(neckPath, neckPaint);
        break;

      case 'vestido':
        // Vestido triangular desde el pecho hasta abajo
        clothPaint.color = const Color(0xFF9B59B6).withValues(alpha: 0.85);
        final vestidoPath = Path()
          ..moveTo(cx - s * 0.12, s * 0.44)
          ..lineTo(cx + s * 0.12, s * 0.44)
          ..lineTo(cx + s * 0.28, s * 0.85)
          ..quadraticBezierTo(cx, s * 0.88, cx - s * 0.28, s * 0.85)
          ..close();
        canvas.drawPath(vestidoPath, vestidoPath.contains(Offset.zero) ? clothPaint : clothPaint);
        canvas.drawPath(vestidoPath, clothPaint);
        canvas.drawPath(vestidoPath, clothOutline);
        // Tirantes
        final tirantePaint = Paint()
          ..color = const Color(0xFF8E44AD).withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.025;
        canvas.drawLine(
          Offset(cx - s * 0.08, s * 0.44),
          Offset(cx - s * 0.06, s * 0.38),
          tirantePaint,
        );
        canvas.drawLine(
          Offset(cx + s * 0.08, s * 0.44),
          Offset(cx + s * 0.06, s * 0.38),
          tirantePaint,
        );
        break;

      case 'traje':
        // Cuello V y corbata
        clothPaint.color = const Color(0xFF2C3E50).withValues(alpha: 0.85);
        // Solapas
        final solapaIzq = Path()
          ..moveTo(cx, s * 0.42)
          ..lineTo(cx - s * 0.20, s * 0.48)
          ..lineTo(cx - s * 0.22, s * 0.70)
          ..lineTo(cx - s * 0.05, s * 0.70)
          ..lineTo(cx, s * 0.52)
          ..close();
        canvas.drawPath(solapaIzq, clothPaint);
        canvas.drawPath(solapaIzq, clothOutline);

        final solapaDer = Path()
          ..moveTo(cx, s * 0.42)
          ..lineTo(cx + s * 0.20, s * 0.48)
          ..lineTo(cx + s * 0.22, s * 0.70)
          ..lineTo(cx + s * 0.05, s * 0.70)
          ..lineTo(cx, s * 0.52)
          ..close();
        canvas.drawPath(solapaDer, clothPaint);
        canvas.drawPath(solapaDer, clothOutline);

        // Corbata
        final tiePaint = Paint()
          ..color = const Color(0xFFE74C3C)
          ..style = PaintingStyle.fill;
        final tiePath = Path()
          ..moveTo(cx - s * 0.03, s * 0.42)
          ..lineTo(cx + s * 0.03, s * 0.42)
          ..lineTo(cx + s * 0.025, s * 0.65)
          ..lineTo(cx, s * 0.70)
          ..lineTo(cx - s * 0.025, s * 0.65)
          ..close();
        canvas.drawPath(tiePath, tiePaint);
        // Nudo
        canvas.drawCircle(
          Offset(cx, s * 0.43),
          s * 0.025,
          tiePaint,
        );
        break;

      case 'pollera':
        // Falda en la parte inferior
        clothPaint.color = const Color(0xFF2ECC71).withValues(alpha: 0.85);
        final polleraPath = Path()
          ..moveTo(cx - s * 0.22, s * 0.62)
          ..quadraticBezierTo(cx, s * 0.59, cx + s * 0.22, s * 0.62)
          ..lineTo(cx + s * 0.30, s * 0.88)
          ..quadraticBezierTo(cx, s * 0.92, cx - s * 0.30, s * 0.88)
          ..close();
        canvas.drawPath(polleraPath, clothPaint);
        canvas.drawPath(polleraPath, clothOutline);
        // Cinturon
        final beltPaint = Paint()
          ..color = const Color(0xFFF2B84D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.02;
        final beltPath = Path()
          ..moveTo(cx - s * 0.22, s * 0.62)
          ..quadraticBezierTo(cx, s * 0.59, cx + s * 0.22, s * 0.62);
        canvas.drawPath(beltPath, beltPaint);
        break;
    }
  }

  void _drawWings(Canvas canvas, double s, double cx) {
    final wingOutline = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.015;

    final wingPaint = Paint()
      ..color = const Color(0xFF196F77)
      ..style = PaintingStyle.fill;

    // Alita izquierda
    final leftWing = Path()
      ..moveTo(cx - s * 0.33, s * 0.45)
      ..quadraticBezierTo(cx - s * 0.42, s * 0.58, cx - s * 0.36, s * 0.72)
      ..quadraticBezierTo(cx - s * 0.30, s * 0.68, cx - s * 0.30, s * 0.50)
      ..close();
    canvas.drawPath(leftWing, wingPaint);
    canvas.drawPath(leftWing, wingOutline);

    // Alita derecha
    final rightWing = Path()
      ..moveTo(cx + s * 0.33, s * 0.45)
      ..quadraticBezierTo(cx + s * 0.42, s * 0.58, cx + s * 0.36, s * 0.72)
      ..quadraticBezierTo(cx + s * 0.30, s * 0.68, cx + s * 0.30, s * 0.50)
      ..close();
    canvas.drawPath(rightWing, wingPaint);
    canvas.drawPath(rightWing, wingOutline);
  }

  void _drawBeak(Canvas canvas, double s, double cx) {
    final beakPaint = Paint()
      ..color = const Color(0xFFF2B84D)
      ..style = PaintingStyle.fill;
    final beakOutline = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.012;

    final beakPath = Path()
      ..moveTo(cx - s * 0.06, s * 0.30)
      ..quadraticBezierTo(cx, s * 0.38, cx + s * 0.06, s * 0.30)
      ..quadraticBezierTo(cx, s * 0.34, cx - s * 0.06, s * 0.30);
    canvas.drawPath(beakPath, beakPaint);
    canvas.drawPath(beakPath, beakOutline);
  }

  void _drawEyes(Canvas canvas, double s, double cx) {
    final eyeWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final eyePupil = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.fill;
    final eyeHighlight = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const eyeOffsetX = 0.10;
    const eyeY = 0.25;
    const whiteR = 0.055;
    const pupilR = 0.035;
    const highlightR = 0.015;

    // Ojo izquierdo
    canvas.drawCircle(Offset(cx - s * eyeOffsetX, s * eyeY), s * whiteR, eyeWhite);
    canvas.drawCircle(Offset(cx - s * eyeOffsetX, s * eyeY), s * pupilR, eyePupil);
    canvas.drawCircle(
      Offset(cx - s * eyeOffsetX + s * 0.015, s * eyeY - s * 0.015),
      s * highlightR,
      eyeHighlight,
    );

    // Ojo derecho
    canvas.drawCircle(Offset(cx + s * eyeOffsetX, s * eyeY), s * whiteR, eyeWhite);
    canvas.drawCircle(Offset(cx + s * eyeOffsetX, s * eyeY), s * pupilR, eyePupil);
    canvas.drawCircle(
      Offset(cx + s * eyeOffsetX + s * 0.015, s * eyeY - s * 0.015),
      s * highlightR,
      eyeHighlight,
    );
  }

  void _drawGlasses(Canvas canvas, double s, double cx) {
    final glassPaint = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018;

    const eyeOffsetX = 0.10;
    const eyeY = 0.25;
    const glassR = 0.07;

    // Marco izquierdo
    canvas.drawCircle(Offset(cx - s * eyeOffsetX, s * eyeY), s * glassR, glassPaint);
    // Marco derecho
    canvas.drawCircle(Offset(cx + s * eyeOffsetX, s * eyeY), s * glassR, glassPaint);
    // Puente entre los dos lentes
    canvas.drawLine(
      Offset(cx - s * eyeOffsetX + s * glassR, s * eyeY),
      Offset(cx + s * eyeOffsetX - s * glassR, s * eyeY),
      glassPaint,
    );
    // Patillas
    final patillaPaint = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.014
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - s * eyeOffsetX - s * glassR, s * eyeY),
      Offset(cx - s * 0.22, s * eyeY - s * 0.02),
      patillaPaint,
    );
    canvas.drawLine(
      Offset(cx + s * eyeOffsetX + s * glassR, s * eyeY),
      Offset(cx + s * 0.22, s * eyeY - s * 0.02),
      patillaPaint,
    );
  }

  void _drawHair(Canvas canvas, double s, double cx) {
    if (pelo == 'ninguno') return;

    Color hairColor;
    switch (pelo) {
      case 'rubio':
        hairColor = const Color(0xFFF2B84D);
        break;
      case 'castano':
        hairColor = const Color(0xFF8B4513);
        break;
      case 'canoso':
        hairColor = const Color(0xFFC0C0C0);
        break;
      case 'negro':
        hairColor = const Color(0xFF2D2D2D);
        break;
      default:
        return;
    }

    final hairPaint = Paint()
      ..color = hairColor
      ..style = PaintingStyle.fill;
    final hairOutline = Paint()
      ..color = const Color(0xFF2D2D2D).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.01;

    // Mechones de pelo arriba de la cabeza
    final topY = s * 0.08;

    // Mechon central
    final center = Path()
      ..moveTo(cx - s * 0.04, s * 0.12)
      ..quadraticBezierTo(cx - s * 0.02, topY - s * 0.04, cx, topY - s * 0.02)
      ..quadraticBezierTo(cx + s * 0.02, topY - s * 0.04, cx + s * 0.04, s * 0.12)
      ..close();
    canvas.drawPath(center, hairPaint);
    canvas.drawPath(center, hairOutline);

    // Mechon izquierdo
    final left = Path()
      ..moveTo(cx - s * 0.10, s * 0.14)
      ..quadraticBezierTo(cx - s * 0.10, topY, cx - s * 0.04, topY + s * 0.02)
      ..quadraticBezierTo(cx - s * 0.06, s * 0.10, cx - s * 0.03, s * 0.13)
      ..close();
    canvas.drawPath(left, hairPaint);
    canvas.drawPath(left, hairOutline);

    // Mechon derecho
    final right = Path()
      ..moveTo(cx + s * 0.10, s * 0.14)
      ..quadraticBezierTo(cx + s * 0.10, topY, cx + s * 0.04, topY + s * 0.02)
      ..quadraticBezierTo(cx + s * 0.06, s * 0.10, cx + s * 0.03, s * 0.13)
      ..close();
    canvas.drawPath(right, hairPaint);
    canvas.drawPath(right, hairOutline);
  }

  @override
  bool shouldRepaint(covariant _AidaPainter oldDelegate) {
    return oldDelegate.ropa != ropa ||
        oldDelegate.pelo != pelo ||
        oldDelegate.lentes != lentes;
  }
}
