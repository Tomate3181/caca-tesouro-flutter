import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// Widget de exibição da Bússola 2D Custom (Seção 3.2 do DESIGN_SYSTEM.md)
/// Implementação em Canvas/CustomPainter — sem dependências externas pesadas.
class Compass3DView extends StatefulWidget {
  final double targetAngleDegrees; // Ângulo calculado (Bearing - Heading)
  final Color glowColor;

  const Compass3DView({
    super.key,
    required this.targetAngleDegrees,
    this.glowColor = AppConstants.colorCold,
  });

  @override
  State<Compass3DView> createState() => _Compass3DViewState();
}

class _Compass3DViewState extends State<Compass3DView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 260,
        width: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow pulsante atrás da bússola
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.glowColor.withValues(
                          alpha: 0.15 + 0.1 * _pulseController.value,
                        ),
                        blurRadius: 30 + 10 * _pulseController.value,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Mostrador / Dial estilizado em Canvas
            CustomPaint(
              size: const Size(260, 260),
              painter: _CompassDialPainter(glowColor: widget.glowColor),
            ),

            // Agulha / ponteiro animado
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: widget.targetAngleDegrees),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              builder: (context, angleDegrees, _) {
                return Transform.rotate(
                  angle: angleDegrees * (math.pi / 180.0),
                  child: CustomPaint(
                    size: const Size(220, 220),
                    painter: _CompassNeedlePainter(glowColor: widget.glowColor),
                  ),
                );
              },
            ),

            // Indicador de ângulo digital no centro
            Positioned(
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.glowColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${widget.targetAngleDegrees.toStringAsFixed(0)}°',
                  style: TextStyle(
                    color: widget.glowColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desenha o anel externo, divisões de graus e pontos cardeais da bússola
class _CompassDialPainter extends CustomPainter {
  final Color glowColor;

  _CompassDialPainter({required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Fundo do mostrador
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1E293B),
          const Color(0xFF0F172A),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Anel externo duplo
    final outerRimPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius + 2, outerRimPaint);

    // Borda brilhante
    final rimPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, rimPaint);

    // Anel interno decorativo
    final innerRimPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 20, innerRimPaint);

    // Traços de graus ao redor do mostrador
    final tickPaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1.0;

    final majorTickPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.0;

    for (int deg = 0; deg < 360; deg += 5) {
      final rad = deg * (math.pi / 180.0);
      final isMajor = deg % 30 == 0;
      final isCardinal = deg % 90 == 0;
      final isMinor = deg % 10 != 0;

      final tickLen = isCardinal ? 14.0 : (isMajor ? 9.0 : (isMinor ? 3.0 : 5.0));
      final start = Offset(
        center.dx + (radius - tickLen) * math.sin(rad),
        center.dy - (radius - tickLen) * math.cos(rad),
      );
      final end = Offset(
        center.dx + radius * math.sin(rad),
        center.dy - radius * math.cos(rad),
      );

      canvas.drawLine(start, end, isMajor ? majorTickPaint : tickPaint);
    }

    // Textos dos Pontos Cardeais (N, L, S, O)
    _drawCardinalText(canvas, center, radius - 28, 'N', AppConstants.colorVeryHot);
    _drawCardinalText(canvas, center, radius - 28, 'S', Colors.white70, angleDeg: 180);
    _drawCardinalText(canvas, center, radius - 28, 'L', Colors.white70, angleDeg: 90);
    _drawCardinalText(canvas, center, radius - 28, 'O', Colors.white70, angleDeg: 270);

    // Sub-cardeais menores
    _drawCardinalText(canvas, center, radius - 26, 'NE', Colors.white38, angleDeg: 45, fontSize: 9);
    _drawCardinalText(canvas, center, radius - 26, 'SE', Colors.white38, angleDeg: 135, fontSize: 9);
    _drawCardinalText(canvas, center, radius - 26, 'SO', Colors.white38, angleDeg: 225, fontSize: 9);
    _drawCardinalText(canvas, center, radius - 26, 'NO', Colors.white38, angleDeg: 315, fontSize: 9);
  }

  void _drawCardinalText(
    Canvas canvas,
    Offset center,
    double r,
    String text,
    Color color, {
    double angleDeg = 0,
    double fontSize = 14,
  }) {
    final rad = angleDeg * (math.pi / 180.0);
    final pos = Offset(
      center.dx + r * math.sin(rad),
      center.dy - r * math.cos(rad),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.glowColor != glowColor;
}

/// Desenha a agulha da bússola com ponta vermelha que aponta para o tesouro
class _CompassNeedlePainter extends CustomPainter {
  final Color glowColor;

  _CompassNeedlePainter({required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const needleLength = 70.0;
    const needleWidth = 14.0;

    // Sombra da agulha
    final shadowPath = Path()
      ..moveTo(center.dx, center.dy - needleLength)
      ..lineTo(center.dx + needleWidth, center.dy)
      ..lineTo(center.dx, center.dy + needleLength)
      ..lineTo(center.dx - needleWidth, center.dy)
      ..close();
    canvas.drawPath(
      shadowPath.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Ponta Norte (Aponta para o tesouro) - Lado Direito (claro)
    final northRightPath = Path()
      ..moveTo(center.dx, center.dy - needleLength)
      ..lineTo(center.dx + needleWidth, center.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(
      northRightPath,
      Paint()..color = AppConstants.colorVeryHot,
    );

    // Ponta Norte - Lado Esquerdo (sombreado)
    final northLeftPath = Path()
      ..moveTo(center.dx, center.dy - needleLength)
      ..lineTo(center.dx - needleWidth, center.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(
      northLeftPath,
      Paint()..color = const Color(0xFFB71C1C),
    );

    // Ponta Sul - Lado Direito
    final southRightPath = Path()
      ..moveTo(center.dx, center.dy + needleLength)
      ..lineTo(center.dx + needleWidth, center.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(
      southRightPath,
      Paint()..color = const Color(0xFFE2E8F0),
    );

    // Ponta Sul - Lado Esquerdo (sombreado)
    final southLeftPath = Path()
      ..moveTo(center.dx, center.dy + needleLength)
      ..lineTo(center.dx - needleWidth, center.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(
      southLeftPath,
      Paint()..color = const Color(0xFF94A3B8),
    );

    // Pino central dourado
    canvas.drawCircle(
      center,
      8.0,
      Paint()..color = AppConstants.colorGold,
    );
    canvas.drawCircle(
      center,
      4.0,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _CompassNeedlePainter oldDelegate) =>
      oldDelegate.glowColor != glowColor;
}
